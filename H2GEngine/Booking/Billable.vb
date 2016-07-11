'Imports MBOSEngine
'Imports MBOSEngine.DataItem
Imports System.Collections.Generic
Imports System.IO
Imports H2GEngine
Imports H2GEngine.DataItem
Imports H2GEngine.FileManager
Imports H2GEngine.Booking

Namespace Booking
    Public Class Billable
        Inherits Item
        Private IDBooking As String = "-1"

        Public Sub New(ByVal booking_id As String)
            IDBooking = booking_id
        End Sub

        Public Sub New(ByVal booking_id As String, ByVal product_id As String, ByVal item_type As ItemType)
            IDBooking = booking_id
            IDItem = product_id
            CurrentItem = item_type
        End Sub

        Public Sub UpdateBillable(ByVal cost As String, ByVal price As String)
            Dim SyncConnected As Boolean = Sync.Connected
            Dim ColumnName As String = Billable.GetBillableColumn(CurrentItem)
            If (Not SyncConnected) Then Sync = New DBQuery()
            Try
                ColumnName = String.Format("{0}={1}", ColumnName, IDItem)
                Dim id As String = Sync.QueryField(String.Format(My.Resources.SELECT_BillableDetail, ColumnName), New SQLCollection("@bid", DbType.String, IDItem))
                If (Not String.IsNullOrEmpty(id) And Not String.IsNullOrEmpty(cost) And Not String.IsNullOrEmpty(price)) Then
                    Sync.Execute(String.Format("UPDATE booking_billable_detail SET cost={0}, base_cost={0}, price={1}  WHERE {2}", cost, price, ColumnName))
                End If
                MyBase.SyncApply(SyncConnected)
            Catch ex As Exception
                MyBase.SyncRollback(SyncConnected)
                Throw New Exception("UpdateBillable Method :: " & ex.Message)
            End Try
        End Sub

        Public Sub InsertBillable()
            'Dim SyncConnected As Boolean = Sync.Connected
            'Dim ColumnName As String = Billable.GetBillableColumn(CurrentItem)
            'If (Not SyncConnected) Then Sync = New DBQuery()
            'Dim strCon As String = ""
            'Try
            '    strCon = "select bp.[status] from booking_ticket bt inner join booking_package bp on bp.id = bt.booking_package_id where bt.id=@doc_id "
            '    If Sync.QueryField(strCon, New SQLCollection("@doc_id", DbType.Int64, IDItem)) = "SEND" Then
            '        Dim dtData As New DataTable
            '        strCon = String.Format("select booking_billable_id from booking_billable_detail where {0}={1}", ColumnName, IDItem)
            '        Dim BillableID As String = Sync.QueryField(strCon)

            '        If String.IsNullOrEmpty(BillableID) Then
            '            strCon = "select b.id as booking_id "
            '            strCon &= ", isnull((select top 1 isnull(bb.booking_num,0)+1 as booking_num "
            '            strCon &= "	from booking_billable bb "
            '            strCon &= "	where bb.booking_id = b.id "
            '            strCon &= "	and bb.status <> 'CANCEL' and bb.for_package = 'N' "
            '            strCon &= "	order by bb.booking_num desc),1) as booking_num "
            '            strCon &= ", case when sa.id>0 then sa.name else case when cus.id>0 then cus.name else 'WALK IN' end end as bill_name "
            '            strCon &= ", case when sa.id>0 then sa.[address] else case when cus.id>0 then cus.[address] else 'N/A' end end as bill_address "
            '            strCon &= ", case when sa.id>0 then sa.office_type else case when cus.id>0 then cus.office_type else '' end end as office_type "
            '            strCon &= ", case when sa.id>0 then sa.tax_number else case when cus.id>0 then cus.tax_number else '' end end as tax_number "
            '            strCon &= ", case when sa.id>0 then sa.branch else case when cus.id>0 then cus.branch else '' end end as branch "
            '            strCon &= ", (select top 1 id from credit_term) as credit_term_id "
            '            strCon &= ", (select top 1 id from pay_by) as pay_by_id "
            '            strCon &= "from booking b "
            '            strCon &= "left join sub_agent sa on sa.id = b.sub_agent_id "
            '            strCon &= "left join customer cus on cus.id = b.customer_id "
            '            strCon &= "where b.id = @id "

            '            dtData = Sync.QueryTable(strCon, New SQLCollection("@id", DbType.Int64, IDBooking))

            '            Dim BillableItem As New BillableItem

            '            strCon = "INSERT INTO [booking_billable]([system_staff] "
            '            strCon &= ",[booking_id],[booking_num],[bill_name],[bill_date],[bill_address] "
            '            strCon &= ",[office_type],[tax_number],[branch],[credit_term_id],[pay_by_id]) "
            '            strCon &= "VALUES (@system_staff "
            '            strCon &= ",@booking_id,@booking_num,@bill_name,getdate(),@bill_address "
            '            strCon &= ",@office_type,@tax_number,@branch,@credit_term_id,@pay_by_id) select @@IDENTITY "
            '            BillableID = Sync.Execute(strCon, BillableItem.CollectionToParameterBillable(dtData.Rows(0)))

            '            strCon = "select bt.booking_id, bt.id, 0 as ref_id, bt.status, 'Air Ticket' as name, 1 as datatype "
            '            strCon &= ", ISNULL((bt.ad_cost+bt.ch_cost+bt.inf_cost+bt.ad_tax+bt.ch_tax+bt.inf_tax),0) as total_cost "
            '            strCon &= ", ISNULL((bt.ad_price+bt.ch_price+bt.inf_price+bt.ad_tax+bt.ch_tax+bt.inf_tax),0) as total_price "
            '            strCon &= ", ISNULL((bt.ad_price+bt.ch_price+bt.inf_price+bt.ad_tax+bt.ch_tax+bt.inf_tax),0) "
            '            strCon &= "- ISNULL((bt.ad_cost+bt.ch_cost+bt.inf_cost+bt.ad_tax+bt.ch_tax+bt.inf_tax),0) as profit "
            '            strCon &= ", ISNULL((bt.ad_cost+bt.ch_cost+bt.inf_cost+bt.ad_tax+bt.ch_tax+bt.inf_tax),0) as base_total_cost "
            '            strCon &= ", b.currency_rate as base_rate_cost, b.currency as currency_cost "
            '            strCon &= ", bbd.id as billable_id, isnull(bbd.currency_rate, b.currency_rate) as currency_rate "
            '            strCon &= ", isnull(convert(varchar(10),bb.bill_date,105),'') as latest_sent "
            '            strCon &= ", isnull(convert(varchar(10),bb.system_date,105),'') as first_sent "
            '            strCon &= ", isnull(convert(varchar(10),bt.ticket_date,105),'') as service_date, bt.supplier_id "
            '            strCon &= "from booking_ticket bt "
            '            strCon &= "inner join booking b on b.id = bt.booking_id "
            '            strCon &= "left join booking_billable_detail bbd on bbd.booking_ticket_id = bt.id and bbd.[status] <> 'CANCEL' "
            '            strCon &= "left join booking_billable bb on bb.id = bbd.booking_billable_id and bb.[status] <> 'CANCEL' "
            '            strCon &= "where bt.id = @doc_id "
            '            dtData = Sync.QueryTable(strCon, New SQLCollection("@doc_id", DbType.Int64, IDItem))

            '            strCon = "INSERT INTO [booking_billable_detail]( "
            '            strCon &= "[booking_billable_id],[system_staff],[" & ColumnName & "],[cost],[price],[currency_rate] "
            '            strCon &= ",[currency_cost],[base_rate_cost],[base_cost],[for_package]) "
            '            strCon &= "VALUES ( "
            '            strCon &= "@booking_billable_id,@system_staff,@doc_id,@cost,@price,@currency_rate "
            '            strCon &= ",@currency_cost,@base_rate_cost,@base_cost,'Y' "
            '            strCon &= " ) select @@IDENTITY "
            '            BillableID = Sync.Execute(strCon, BillableItem.CollectionToParameterBillDetail(dtData.Rows(0), BillableID))
            '        End If
            '    End If

            '    MyBase.SyncApply(SyncConnected)
            'Catch ex As Exception
            '    MyBase.SyncRollback(SyncConnected)
            '    Throw New Exception("UpdateBillable Method :: " & ex.Message)
            'End Try
        End Sub

        Private Sub setValueInsertBillable()

        End Sub

        Public Sub StatusBookingVerify()
            Dim SyncConnected As Boolean = Sync.Connected
            If (Not SyncConnected) Then Sync = New DBQuery()
            Dim param As New ParameterCollection
            param.Add("@booking_id", DbType.Int32, IDBooking)
            param.Add("STATUS_CONDITION", DbType.String, "WHERE b.status NOT IN('PACKAGE')")

            Dim TotalBookingPrice As Decimal = 0
            For Each dRow As DataRow In Sync.QueryTable(My.Resources.Booking_TotalCostTotalPrice, param).Rows
                TotalBookingPrice += H2G.Dec(dRow("price"))
            Next

            Dim TotalReceiptPrice As Decimal = H2G.Dec(Sync.QueryField("SELECT SUM(receipt_novat) FROM view_amount_inv2rec WHERE receipt_status NOT IN('VOID','WAIT')  AND booking_id = @booking_id", param))
            Dim SEND As Integer = 0
            Dim OK As Integer = 0
            Dim PACKAGE As Integer = 0
            For Each dtRow As DataRow In Sync.QueryTable(My.Resources.Billable_BookingTotalStatus, param).Rows
                Select Case dtRow("status")
                    Case "SEND" : SEND += H2G.Int(dtRow("total_send"))
                    Case "OK" : OK += H2G.Int(dtRow("total_send"))
                    Case "PACKAGE" : PACKAGE += H2G.Int(dtRow("total_send"))
                End Select
            Next
            Try
                If ((OK + PACKAGE >= 0) And SEND = 0) Then
                    Sync.Execute("UPDATE booking SET status='NEW BOOKING' WHERE id = @booking_id", param)
                ElseIf (SEND > 0 And OK + PACKAGE = 0 And TotalBookingPrice = TotalReceiptPrice) Then
                    Sync.Execute("UPDATE booking SET status='FINISH' WHERE id = @booking_id", param)
                Else
                    Sync.Execute("UPDATE booking SET status='ACCOUNT' WHERE id= @booking_id", param)
                End If
                MyBase.SyncApply(SyncConnected)
            Catch ex As Exception
                MyBase.SyncRollback(SyncConnected)
                Throw New Exception("StatusBookingVerify Method :: " & ex.Message)
            End Try
        End Sub

        Public Sub StatusPaymentVerify(ByVal supplier_id As String)
            Dim SyncConnected As Boolean = Sync.Connected
            If (Not SyncConnected) Then Sync = New DBQuery()
            Dim param As New ParameterCollection
            param.Add("STATUS_CONDITION", "WHERE status IN ('OK','SEND','FOC', 'PACKAGE')")
            param.Add("SUPPLIER_ID", "AND supplier_id<>-1")
            param.Add("@booking_id", DbType.String, IDBooking)

            Dim IsSupplier As Boolean = True
            Dim TotalCost As Double = 0.0
            Dim TotalPaymentCost As Double = 0.0
            For Each dRow As DataRow In Sync.QueryTable(My.Resources.Booking_TotalCostTotalPrice, param).Rows
                TotalCost += H2G.Convert(Of Decimal)(dRow("cost"))
                IsSupplier = False
            Next

            Try
                param.Clear()
                param.Add("@booking_id", DbType.String, IDBooking)
                TotalPaymentCost = H2G.Convert(Of Decimal)(Sync.QueryField(My.Resources.Booking_TotalPayment, param))

                If (IsSupplier Or (TotalCost = TotalPaymentCost And (TotalCost + TotalPaymentCost) > 0)) Then
                    Sync.Execute("UPDATE booking SET payment_status='FINISH' WHERE id=@booking_id", param)
                Else
                    Sync.Execute("UPDATE booking SET payment_status='PENDING' WHERE id=@booking_id", param)
                End If

                Dim product_column As String = String.Format(" WHERE {0}={1}", Billable.GetBillableColumn(CurrentItem), IDItem)
                Sync.Execute(String.Format("UPDATE booking_billable_detail SET supplier_id={0}{1}", supplier_id, product_column))
                Sync.Execute("UPDATE booking_billable_detail SET payment_complete='N'" & product_column)
                If (supplier_id > -1) Then
                    Dim billable_detail_id As String = "SELECT id FROM booking_billable_detail" & product_column

                    Dim billable_query As String = Sync.QueryField(String.Format(My.Resources.SELECT_BillableTotalCost, product_column))
                    Dim payment_query As String = Sync.QueryField(billable_detail_id)
                    If (String.IsNullOrEmpty(payment_query)) Then
                        payment_query = "0"
                    Else
                        param.Clear()
                        param.Add("@billable_detail_id", DbType.String, payment_query)
                        payment_query = Sync.QueryField(My.Resources.Billable_PaymentDetailCost, param)
                    End If
                    REM :: payment_complete เป็น Y เมื่อรายการนั้นออก paymentครบตามยอด cost แล้วเท่านั้น!!!
                    Dim payment_cost As Decimal = H2G.Convert(Of Decimal)(payment_query)
                    Dim billable_cost As Decimal = H2G.Convert(Of Decimal)(billable_query)
                    If (payment_cost >= billable_cost And billable_cost = 0) Then
                        Sync.Execute("UPDATE booking_billable_detail SET payment_complete='Y'" & product_column)
                    End If
                End If

                MyBase.SyncApply(SyncConnected)
            Catch ex As Exception
                MyBase.SyncRollback(SyncConnected)
                Throw New Exception("StatusPaymentVerify Method :: " & ex.Message)
            End Try
        End Sub

    End Class

    'Public Class BillableItem

    '    Public Shared Function WithItems(ByVal item As ItemBillable, ByVal dRow As DataRow, ByVal BookingNum As String) As ItemBillable
    '        With item
    '            .ID = H2G.Convert(Of Integer)(dRow("id").ToString())
    '            .BookingID = H2G.Convert(Of Integer)(dRow("id").ToString())
    '            .BookingNum = BookingNum
    '            .BillName = ""
    '            .BillDate = ""
    '            .BillAddress = ""
    '            .OfficeType = ""
    '            .TaxNumber = ""
    '            .Branch = ""
    '            .CreditTermID = ""
    '            .PayByID = ""
    '            .Status = ""
    '        End With
    '        Return item
    '    End Function

    '    Public Shared Function CollectionToParameterBillable(ByVal dRow As DataRow) As SQLCollection
    '        Dim param As New SQLCollection()
    '        param.Add("@system_staff", DbType.Int64, H2G.Login.ID)
    '        param.Add("@booking_id", DbType.Int64, dRow("booking_id"))
    '        param.Add("@booking_num", DbType.Int64, dRow("booking_num"))
    '        param.Add("@bill_name", DbType.String, dRow("bill_name"))
    '        param.Add("@bill_address", DbType.String, dRow("bill_address"))
    '        param.Add("@office_type", DbType.String, dRow("office_type"))
    '        param.Add("@tax_number", DbType.String, dRow("tax_number"))
    '        param.Add("@branch", DbType.String, dRow("branch"))
    '        param.Add("@credit_term_id", DbType.Int64, dRow("credit_term_id"))
    '        param.Add("@pay_by_id", DbType.Int64, dRow("pay_by_id"))
    '        Return param
    '    End Function

    '    Public Shared Function CollectionToParameterBillDetail(ByVal dRow As DataRow, ByVal BillableID As String) As SQLCollection
    '        Dim param As New SQLCollection()
    '        param.Add("@system_staff", DbType.Int64, H2G.Login.ID)
    '        param.Add("@booking_billable_id", DbType.Int64, BillableID)
    '        param.Add("@doc_id", DbType.Int64, dRow("id"))
    '        param.Add("@cost", DbType.Decimal, dRow("total_cost"))
    '        param.Add("@price", DbType.Decimal, dRow("total_price"))
    '        param.Add("@currency_rate", DbType.Decimal, dRow("currency_rate"))
    '        param.Add("@currency_cost", DbType.String, dRow("currency_cost"))
    '        param.Add("@base_rate_cost", DbType.Decimal, dRow("base_rate_cost"))
    '        param.Add("@base_cost", DbType.Decimal, dRow("base_total_cost"))
    '        param.Add("@supplier_id", DbType.Int64, dRow("supplier_id"))
    '        Return param
    '    End Function

    'End Class

End Namespace
