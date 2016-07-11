Namespace Booking
    Public Class Payment
        Inherits Item

        Public Sub New()
            CurrentItem = ItemType.Payment
        End Sub

        Public Function NextPaymentNo(ByVal payment_date As String) As String
            Return Me.NextNO(payment_date, ItemStatus.VAT)
        End Function
    End Class
End Namespace
