Public Class CompanyModule

    Public Shared Function LockBookingCreate() As Boolean
        Dim Booking As String = H2G.Int(New DBQuery().QueryField("SELECT COUNT(*) record FROM (SELECT id FROM booking UNION ALL SELECT id FROM gbooking) book"))
        Dim LimitBooking As Integer = CompanyProfile.LimitBooking()
        Dim Duedate As String = CompanyProfile.LimitDueDate()
        Dim CheckDueDate As Boolean = Not String.IsNullOrEmpty(Duedate)
        If (CheckDueDate) Then CheckDueDate = H2G.DT(Duedate) < Date.Now()
        ' Duedate
        Return IIf((Booking >= LimitBooking And LimitBooking <> 0) Or CheckDueDate, True, False)
    End Function

End Class
