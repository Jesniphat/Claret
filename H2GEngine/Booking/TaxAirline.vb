Namespace Booking
    Public Class TaxAirline
        Inherits Item

        Public Sub New()
            CurrentItem = ItemType.TaxAirline
        End Sub

        Public Function NextTaxNo(ByVal tax_date As String) As String
            Return Me.NextNO(tax_date, ItemStatus.VAT)
        End Function
    End Class
End Namespace
