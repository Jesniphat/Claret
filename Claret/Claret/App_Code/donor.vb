Imports Microsoft.VisualBasic
Imports H2GEngine
Imports H2GEngine.DataItem
Public Class donor
    'Public Shared Function CollectionToParameter(ByVal data As donoritem) As SQLCollection
    '    Dim param As New SQLCollection()
    '    If (data.RefundID = "NEW") Then data.RefundID = -1
    '    param.Add("@id", DbType.Int64, data.RefundID)
    '    param.Add("@system_staff", DbType.Int64, MBOS.Login.ID)
    '    param.Add("@update_staff", DbType.Int64, MBOS.Login.ID)
    '    param.Add("@booking_id", DbType.Int64, data.BookingID)
    '    param.Add("@booking_ticket_passenger_id", DbType.Int64, data.PassengerID)
    '    param.Add("@route", DbType.String, data.Route)
    '    param.Add("@status", DbType.String, data.Status)
    '    param.Add("@request_staff", DbType.Int64, data.SalesStaffID)
    '    param.Add("@refund_no", DbType.String, data.RefundNo)
    '    param.Add("@refund_date", DbType.DateTime, data.RefundDate)
    '    param.Add("@refund_remark", DbType.String, data.Remarks)
    '    param.Add("@departure_date", DbType.DateTime, data.DepartureDate.Replace("/", "-"))
    '    param.Add("@arrival_date", DbType.DateTime, data.ArrivalDate.Replace("/", "-"))
    '    param.Add("@supplier_currency", DbType.String, data.SupCurrency)
    '    param.Add("@supplier_rate", DbType.Decimal, data.SupRate)
    '    param.Add("@customer_currency", DbType.String, data.CusCurrency)
    '    param.Add("@customer_rate", DbType.Decimal, data.CusRate)
    '    param.Add("@receive_amt", DbType.Decimal, data.ReceiveAmount)
    '    param.Add("@refund_amt", DbType.Decimal, data.RefundAmount)
    '    If data.Status.ToUpper = "CANCEL" Then
    '        param.Add("@ticket_refund_enable", DbType.String, "N")
    '    Else
    '        param.Add("@ticket_refund_enable", DbType.String, "Y")
    '    End If

    '    Return param
    'End Function
End Class
