Imports System.Web.HttpContext

Namespace Booking
    Public Class Item
        Public WriteOnly Property SyncConnection() As DBQuery
            Set(ByVal value As DBQuery)
                Sync = value
            End Set
        End Property
        Protected Sync As New DBQuery()
        Protected CurrentItem As ItemType
        Protected IDItem As String
        Protected CurrentBooking As BookingType = BookingType.Normal

        Public Sub SyncApply()
            Me.SyncApply(False)
        End Sub
        Public Sub SyncApply(ByVal SyncConnected As Boolean)
            If (Not SyncConnected) Then Sync.Apply()
        End Sub
        Public Sub SyncRollback()
            Me.SyncRollback(True)
        End Sub
        Public Sub SyncRollback(ByVal SyncConnected As Boolean)
            If (SyncConnected) Then Sync.Rollback()
        End Sub

        Public Shared Function GetBillableColumn(ByVal type_item As ItemType) As String
            Dim _column As String = ""
            Select Case type_item
                Case ItemType.Package : _column = "booking_package_id"
                Case ItemType.Ticket : _column = "booking_ticket_id"
                Case ItemType.Hotel : _column = "booking_hotel_id"
                Case ItemType.Transfer : _column = "booking_transfer_id"
                Case ItemType.Other : _column = "booking_others_id"
                Case ItemType.Grouptour : _column = "booking_group_tour_id"
            End Select
            Return _column
        End Function
        Protected Function GetBillableColumn() As String
            Dim _column As String = ""
            Select Case CurrentItem
                Case ItemType.Package : _column = "booking_package_id"
                Case ItemType.Ticket : _column = "booking_ticket_id"
                Case ItemType.Hotel : _column = "booking_hotel_id"
                Case ItemType.Transfer : _column = "booking_transfer_id"
                Case ItemType.Other : _column = "booking_others_id"
                Case ItemType.Grouptour : _column = "booking_group_tour_id"
            End Select
            Return _column
        End Function
        Protected Function GetTableName() As String
            Dim _column As String = ""
            Select Case CurrentItem
                Case ItemType.Package : _column = "booking_package"
                Case ItemType.Ticket : _column = "booking_ticket"
                Case ItemType.Hotel : _column = "booking_hotel"
                Case ItemType.Transfer : _column = "booking_transfer"
                Case ItemType.Other : _column = "booking_others"
                Case ItemType.Grouptour : _column = "booking_group_tour"
            End Select
            Return _column
        End Function

        Protected Function NextNO(ByVal item_date As String, ByVal account_type As ItemStatus) As String
            Dim base As New DBQuery()
            If (Sync.Connected) Then base = Sync
            Dim BeginNo As String = ""
            Dim NoItemFormat As String = ""
            Dim ItemLastNO As String = ""
            Select Case CurrentItem
                Case ItemType.Invoice
                    ItemLastNO = My.Resources.ITEM_GetLastInvoiceNo
                    Select Case account_type
                        Case ItemStatus.TEMP
                            NoItemFormat = CompanyProfile.FormatITEMP
                            BeginNo = "num_inv_temp"
                        Case ItemStatus.NOVAT
                            NoItemFormat = CompanyProfile.FormatINOVAT
                            BeginNo = "num_inv_novat"
                        Case ItemStatus.VAT
                            NoItemFormat = CompanyProfile.FormatIVAT
                            BeginNo = "num_inv_vat"
                    End Select
                Case ItemType.Receipt
                    ItemLastNO = My.Resources.ITEM_GetLastReceiptNo
                    Select Case account_type
                        Case ItemStatus.TEMP
                            NoItemFormat = CompanyProfile.FormatRTEMP
                            BeginNo = "num_rec_temp"
                        Case ItemStatus.VAT
                            NoItemFormat = CompanyProfile.FormatRVAT
                            BeginNo = "num_rec_vat"
                    End Select
                Case ItemType.Tax
                    ItemLastNO = My.Resources.ITEM_GetLastTaxNo
                    NoItemFormat = CompanyProfile.FormatTAX
                    BeginNo = "num_tax_vat"
                Case ItemType.TaxAirline
                    ItemLastNO = My.Resources.ITEM_GetLastTaxAirlineNo
                    NoItemFormat = CompanyProfile.FormatTAXAirline
                    BeginNo = "1"
                Case ItemType.Payment
                    ItemLastNO = My.Resources.ITEM_GetLastPaymentNo
                    NoItemFormat = CompanyProfile.FormatPAYMENT
                    BeginNo = "num_payment"
            End Select

            Dim ItemDate As DateTime = H2G.DT(item_date)

            ' FIXED PATTERN
            Dim ResultNoNext As String = ""
            If (CurrentItem = ItemType.TaxAirline) Then
                Dim RegexNO As Match = Regex.Match(NoItemFormat, "(?<PreText>.*?)<(?<Format>.*)>")
                ResultNoNext = ItemDate.ToString(RegexNO.Groups("Format").Value)

                Dim FormatFixedNo As String = RegexNO.Groups("PreText").Value & Regex.Replace(ResultNoNext, "[#]+", "")
                ItemLastNO = base.QueryField(String.Format(ItemLastNO, FormatFixedNo, IIf(account_type = ItemStatus.NOVAT, "NO VAT", account_type.ToString())))

                Dim PatternNO As String = Regex.Match(ResultNoNext, "[#]+").Value
                If String.IsNullOrEmpty(ItemLastNO) Then
                    BeginNo = base.QueryField(String.Format(My.Resources.ITEM_BeginNo, BeginNo, ItemDate.ToString("yyyy"), ItemDate.ToString("MM")))
                Else
                    BeginNo = H2G.Int(Regex.Replace(ItemLastNO, FormatFixedNo, ""))
                End If
                BeginNo = Regex.Replace(((H2G.Int(BeginNo) + 1) / (10 ^ PatternNO.Length)).ToString("." & PatternNO), "\.", "")
                ResultNoNext = FormatFixedNo & BeginNo & Regex.Match(PatternNO, "(#{" & (PatternNO.Length - BeginNo.Length) & "})").Groups(1).Value.Replace("#", "0")
            Else
                If (Not String.IsNullOrEmpty(NoItemFormat)) Then
                    If (NoItemFormat.Split(",")(0) <> "yy" And NoItemFormat.Split(",")(0) <> "yyyy" And NoItemFormat.Split(",")(0) <> "mm") Then
                        ResultNoNext = NoItemFormat.Split(",")(0)
                        NoItemFormat = NoItemFormat.Replace(ResultNoNext, "")
                    End If
                End If
                NoItemFormat = NoItemFormat.Replace(",", "")
                Dim result As String = ItemDate.ToString(NoItemFormat.Replace("m", "M"))
                ResultNoNext = ResultNoNext & result.Replace("x", "")
                result = Regex.Match(result, "(x)+").Value

                ' Fixed Error Cann't Parse Last Number
                Dim type As String = account_type.ToString()
                If (account_type = ItemStatus.NOVAT) Then type = "NO VAT"
                ItemLastNO = base.QueryField(String.Format(ItemLastNO, ResultNoNext, type))
                BeginNo = H2G.Int(ItemLastNO.Replace(ResultNoNext, "")) + 1

                For i As Integer = 1 To (result.Length - BeginNo.Length)
                    BeginNo = "0" & BeginNo
                Next i
                ResultNoNext = ResultNoNext & BeginNo
            End If
            Return ResultNoNext
        End Function

        Protected Function ChangeSupplierWithPayment() As Boolean
            Dim result As Boolean = True
            Dim base As New DBQuery()
            If (Sync.Connected) Then base = Sync
            Try
                Dim billable_detail_id As String = String.Format("SELECT id FROM booking_billable_detail WHERE {0}={1}", Me.GetBillableColumn(), IDItem)
                billable_detail_id = base.QueryField(billable_detail_id)
                Dim param As New ParameterCollection()
                param.Add("@billable_detail_id", DbType.String, billable_detail_id)
                Dim costPayment As Decimal = H2G.Convert(Of Decimal)(base.QueryField(My.Resources.Billable_PaymentDetailCost, param))
                Dim supplier_id As String = base.QueryField(String.Format("SELECT supplier_id FROM {0} WHERE id={1}", Me.GetTableName(), IDItem))
                If (costPayment <> 0 And supplier_id <> "-1") Then result = False
            Catch
                Throw New Exception("Not found product in booking.")
            End Try
            Return result
        End Function

        Protected Function ItemCostTotal(ByVal booking_id As String) As Decimal
            Return CostBindPackageORCostProduct(booking_id, IDItem)
        End Function

        REM :: OLD FUNCTION
        Protected Function CostBindPackageORCostProduct(ByVal booking_id As String, ByVal product_id As String) As Decimal
            Dim base As New DBQuery()
            If (Sync.Connected) Then base = Sync
            Dim bindPackage As Decimal = 0
            Dim param As New ParameterCollection()
            param.Add("@booking_id", DbType.Int32, booking_id)
            For Each dRow As DataRow In base.QueryTable(My.Resources.Booking_TotalCostTotalPrice, param).Rows
                If (bindPackage > 0 And dRow("ref_id") = bindPackage And dRow("product") = "Package") Then
                    bindPackage = dRow("cost")
                ElseIf (dRow("ref_id") = product_id.Trim()) Then
                    If (CDec(dRow("ref_id")) > -1) Then
                        bindPackage = CDec(dRow("package_id"))
                    Else
                        bindPackage = CDec(dRow("cost"))
                    End If
                End If
            Next
            Return bindPackage
        End Function

    End Class

    Public Enum BookingType
        [Normal]
        [Grouptour]
    End Enum
    Public Enum ItemType
        [Unknow]
        [Quotation]
        [Package]
        [Ticket]
        [Hotel]
        [Transfer]
        [Grouptour]
        [Discount]
        [Other]
        [Payment]
        [Invoice]
        [Receipt]
        [Tax]
        [TaxAirline]
        [Refund]
    End Enum
    Public Enum ItemStatus
        [OK]
        [SEND]
        [FOC]
        [PACKAGE]
        [OPTIONAL]
        [CANCEL]
        [TEMP]
        [NOVAT]
        [VAT]
    End Enum
End Namespace
