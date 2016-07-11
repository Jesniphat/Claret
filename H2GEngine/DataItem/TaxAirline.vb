Namespace DataItem

    Public Class ItemTaxAirline
        Public ID As String
        Public TaxNo As String
        Public CretaedDate As String
        Public PeriodFrom As String
        Public PeriodTo As String
        Public TaxDate As String
        Public Period As String
        Public Name As String
        Public Address As String
        Public Tel As String
        Public Fax As String
        Public Remark As String

        Public Shared Function WithItems(ByVal item As ItemTaxAirline, ByVal dRow As DataRow) As ItemTaxAirline
            With item
                .ID = dRow("id")
                .TaxNo = dRow("tax_no")
                .CretaedDate = dRow("system_date")
                .TaxDate = dRow("tax_date")
                .PeriodFrom = dRow("period_from")
                .PeriodTo = dRow("period_to")
                .Period = dRow("period_code")
                .Name = dRow("billing_name")
                .Address = dRow("billing_address")
                .Tel = dRow("tel")
                .Fax = dRow("fax")
                .Remark = dRow("remarks")
            End With
            Return item
        End Function

        Public Shared Function WithCollection(ByVal item As ItemTaxAirline) As SQLCollection
            Dim param As New SQLCollection()
            With item
                param.Add("@tax_airline_id", DbType.Int64, .ID)
                param.Add("@tax_no", DbType.String, .TaxNo)
                param.Add("@tax_date", DbType.DateTime, .TaxDate)
                param.Add("@period_from", DbType.DateTime, .PeriodFrom)
                param.Add("@period_to", DbType.DateTime, .PeriodTo)
                param.Add("@update_staff", DbType.Int64, H2G.Login.ID)
                param.Add("@period_code", DbType.Int64, 0)
                param.Add("@airline_id", DbType.Int64, 0)
                param.Add("@billing_name", DbType.String, .Name)
                param.Add("@billing_address", DbType.String, .Address)
                param.Add("@tel", DbType.String, .Tel)
                param.Add("@fax", DbType.String, .Fax)
                param.Add("@remark", DbType.String, .Remark)
            End With
            Return param
        End Function
    End Class

    Public Class ItemTaxAirlineDetail
        Public ID As String
        Public Cost As String
        Public Net As String
        Public Vat As String
        Public VatType As String
        Public Description As String
        Public Manual As String

        Public Shared Function WithItems(ByVal item As ItemTaxAirlineDetail, ByVal dRow As DataRow) As ItemTaxAirlineDetail
            With item
                .ID = dRow("id")
                .Cost = New Money(dRow("cost")).ToString()
                .Net = New Money(dRow("price")).ToString()
                .Vat = dRow("vat")
                .VatType = dRow("vat_type")
                .Description = dRow("description")
                .Manual = dRow("manual")
            End With
            Return item
        End Function

        Public Shared Function WithCollection(ByVal item As ItemTaxAirlineDetail) As SQLCollection
            Dim param As New SQLCollection()
            With item
                param.Add("@tax_airline_detail_id", DbType.Int64, .ID) '@tax_airline_id, @airline_id, @cost, @commission
                param.Add("@cost", DbType.Decimal, .Cost)
                param.Add("@commission", DbType.Decimal, .Net)
                param.Add("@vat", DbType.Decimal, .Vat)
                param.Add("@vat_type", DbType.String, .VatType)
                param.Add("@description", DbType.String, .Description)
                param.Add("@manual", DbType.String, .Manual)
            End With
            Return param
        End Function
    End Class
End Namespace
