Namespace Booking
    Public Class Ticket
        Inherits Item

        Private IDBooking As Integer
        Private IDTicket As Integer

        Public Sub New(ByVal booking_id As Integer, ByVal id As Integer)
            IDTicket = id
            IDBooking = booking_id
            CurrentItem = ItemType.Ticket
        End Sub


        Public Function EnabledSupplier() As Boolean
            IDItem = IDTicket
            Return Me.ChangeSupplierWithPayment()
        End Function

    End Class
End Namespace
