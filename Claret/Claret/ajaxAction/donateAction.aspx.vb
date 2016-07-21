Imports H2GEngine
Imports H2GEngine.DataItem
Public Class donateAction
    Inherits UI.Page 'System.Web.UI.Page

    Dim JSONResponse As New CallbackException()
    Dim param As New SQLCollection()
    Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
    Dim Hbase As New oraDBQuery(oraDBQuery.Schema.HEMATOS)
    Dim sqlMain As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Select Case _REQUEST("action")
            Case "getDonateTypeList"
                Call GetDonateTypeList()

        End Select

    End Sub

    Private Sub GetDonateTypeList()

        Try
            Dim sql As String = "select * from Donation_type"

            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim DonationTypeList As New List(Of DonationType)
            For Each dr As DataRow In dt.Rows
                Dim Item As New DonationType
                Item.Id = dr("ID").ToString
                Item.Code = dr("CODE").ToString
                Item.Description = dr("DESCRIPTION").ToString
                Item.Hiig_code = dr("HIIG_CODE").ToString
                Item.Donation_group = dr("DONATION_GROUP").ToString

                DonationTypeList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of DonationType))(DonationTypeList))
            JSONResponse.ToJSON()
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
        Response.End()
    End Sub

End Class

Public Structure DonationType
    Public Id As String
    Public Code As String
    Public Description As String
    Public Hiig_code As String
    Public Donation_group As String
End Structure

