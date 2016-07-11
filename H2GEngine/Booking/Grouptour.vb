Namespace Booking
    Public Class Grouptour
        Inherits Item
        Private IDBooking As Integer
        Private IDGrouptour As Integer

        Public Sub New(ByVal booking_id As Integer, ByVal id As Integer)
            IDGrouptour = id
            IDBooking = booking_id
            CurrentItem = ItemType.Grouptour
        End Sub

        Public Function ListGrouptourName() As DataTable
            Dim database As New DBQuery()
            Dim param As New ParameterCollection
            param.Add("@booking_id", DbType.Int32, IDBooking.ToString)
            Dim query As String = "SELECT bgt.id, gt.code + ' : ' + bgt.temp_group_code AS name "
            query += "FROM booking_group_tour bgt INNER JOIN group_tour gt ON gt.id=bgt.group_tour_id WHERE booking_id=@booking_id"
            Return database.QueryTable(query, param)
        End Function

        Public Function EnabledSupplier() As Boolean
            IDItem = IDGrouptour
            Return Me.ChangeSupplierWithPayment()
        End Function
    End Class
End Namespace
