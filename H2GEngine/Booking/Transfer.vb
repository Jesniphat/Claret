Namespace Booking
    Public Class Transfer
        Inherits Item
        Private IDBooking As Integer
        Private IDGrouptour As Integer

        Public Sub New(ByVal booking_id As Integer, ByVal id As Integer)
            IDGrouptour = id
            IDBooking = booking_id
            CurrentItem = ItemType.Grouptour
        End Sub

        Public Function ListTransferName() As DataTable
            Dim database As New DBQuery()
            Dim param As New ParameterCollection
            param.Add("@booking_id", DbType.Int32, IDBooking.ToString)
            Return database.QueryTable("SELECT id, transfer_name FROM booking_transfer WHERE booking_id = @booking_id", param)
        End Function

        Public Function EnabledSupplier() As Boolean
            IDItem = IDGrouptour
            Return Me.ChangeSupplierWithPayment()
        End Function

    End Class
End Namespace
