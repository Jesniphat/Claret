Namespace Booking
    Public Class Hotel
        Inherits Item

        Private IDBooking As Integer
        Private IDHotel As Integer

        Public Sub New(ByVal booking_id As Integer, ByVal id As Integer)
            IDHotel = id
            IDBooking = booking_id
            CurrentItem = ItemType.Hotel
        End Sub


        Public Function EnabledSupplier() As Boolean
            IDItem = IDHotel
            Return Me.ChangeSupplierWithPayment()
        End Function

    End Class
End Namespace
