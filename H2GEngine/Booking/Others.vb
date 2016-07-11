Namespace Booking
    Public Class Others
        Inherits Item
        Private IDBooking As Integer
        Private IDOthers As Integer

        Public Sub New(ByVal booking_id As Integer, ByVal id As Integer)
            IDOthers = id
            IDBooking = booking_id
            CurrentItem = ItemType.Other
        End Sub

        Public Function ListOtherName() As DataTable
            Dim database As New DBQuery()
            Dim param As New ParameterCollection
            param.Add("@booking_id", DbType.Int32, IDBooking.ToString)
            Return database.QueryTable("SELECT id, product_name FROM booking_others WHERE booking_id = @booking_id", param)
        End Function

        Public Function EnabledSupplier() As Boolean
            IDItem = IDOthers
            Return Me.ChangeSupplierWithPayment()
        End Function
    End Class
End Namespace
