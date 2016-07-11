Namespace Booking
    Public Class Invoice
        Inherits Item

        Public Sub New()
            CurrentItem = ItemType.Invoice
        End Sub

        Public Function NextInvoiceNo(ByVal invoice_date As String, ByVal invoice_type As String) As String
            Dim _type As ItemStatus
            Select Case invoice_type
                Case "VAT" : _type = ItemStatus.VAT
                Case "NO VAT" : _type = ItemStatus.NOVAT
                Case "TEMP" : _type = ItemStatus.TEMP
            End Select
            Return Me.NextNO(invoice_date, _type)
        End Function

        Public Shared Sub UpdateCost(ByVal new_cost As Decimal, ByVal column_name As String, ByVal product_id As String)
            REM: Update cost with Invoice issued more than one card ' Query Invoice with Group By and SUM(price) with Commission .
            Dim base As New DBQuery()
            Dim param As New SQLCollection("PRODUCT_ID", DbType.String, String.Format("AND {0}={1}", column_name, product_id))
            Try
                Dim Invoice_Commission As DataTable = base.QueryTable(My.Resources.Invoice_ListUpdateCost, param)

                Dim CostForCheckWithPrice As Decimal = new_cost
                Dim LastBillableDetailId As String = ""
                REM: Get invoice list by Product is change cost.
                Dim CurrentRow As Integer = 1
                For Each drLinked As DataRow In Invoice_Commission.Rows

                    Dim InvoicePrice As Decimal = drLinked("price")
                    Dim PriceCommission As Decimal = 0
                    If (CostForCheckWithPrice <= drLinked("price") And CostForCheckWithPrice > 0) Then
                        InvoicePrice = CostForCheckWithPrice
                        PriceCommission = drLinked("price") - CostForCheckWithPrice
                    ElseIf (CostForCheckWithPrice <= 0) Then
                        InvoicePrice = 0
                        PriceCommission = drLinked("price")
                    ElseIf (Invoice_Commission.Rows.Count() = CurrentRow And (CostForCheckWithPrice - InvoicePrice) <= 0) Then
                        InvoicePrice = (InvoicePrice + (CostForCheckWithPrice - InvoicePrice))
                        If (InvoicePrice <= 0) Then InvoicePrice = 0
                    ElseIf (Invoice_Commission.Rows.Count() = 1) Then
                        InvoicePrice = new_cost
                        PriceCommission = 0
                    End If

                    ' Commission Found.
                    If (Not String.IsNullOrEmpty(drLinked("linked_to").ToString())) Then
                        ' Update Cost Product
                        param.Clear()
                        param.Add("@id", DbType.String, drLinked("id").ToString())
                        param.Add("@cost", DbType.Decimal, InvoicePrice.ToString())
                        param.Add("@price", DbType.Decimal, InvoicePrice.ToString())
                        base.Execute(My.Resources.UPDATE_InvoiceDetail, param)

                        ' Update Cost Commision
                        param.Item("@id").DefaultValue = drLinked("linked_to").ToString()
                        param.Item("@cost").DefaultValue = "0"
                        param.Item("@price").DefaultValue = PriceCommission.ToString()
                        base.Execute(My.Resources.UPDATE_InvoiceDetail, param)

                        ' Finnish Row in Commission
                        If (Invoice_Commission.Rows.Count() = CurrentRow) Then
                            Dim query As String = String.Format("SELECT price FROM booking_billable_detail WHERE id={0}", drLinked("booking_billable_detail_id"))
                            Dim dtDetail As DataTable = base.QueryTable(query)

                            param.Item("@id").DefaultValue = drLinked("linked_to").ToString()
                            param.Item("@cost").DefaultValue = "0"
                            param.Item("@price").DefaultValue = dtDetail.Rows(0)("price") - new_cost
                            base.Execute(My.Resources.UPDATE_InvoiceDetail, param)
                        End If

                    Else  ' Commission Not Found
                        param.Clear()
                        param.Add("@id", DbType.String, drLinked("id").ToString())
                        param.Add("@cost", DbType.Decimal, InvoicePrice.ToString())
                        param.Add("@price", DbType.Decimal, drLinked("price").ToString())
                        base.Execute(My.Resources.UPDATE_InvoiceDetail, param)
                    End If

                    CostForCheckWithPrice -= drLinked("price")
                    CurrentRow += 1
                Next
                base.Apply()
            Catch ex As Exception
                base.Rollback()
                Throw New Exception("Invoice.UpdateCost Method :: " & ex.Message)
            End Try
        End Sub

    End Class
End Namespace
