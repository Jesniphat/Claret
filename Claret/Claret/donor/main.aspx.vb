Imports H2GEngine
Public Class donor_main
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Call H2G.setMasterData(Me.Page)
    End Sub

    'Private Sub setMasterData(current As Page)
    '    Dim data As HtmlInputText
    '    data = CType(current.Master.FindControl("data"), HtmlInputText)

    '    If Not data Is Nothing Then
    '        For Each key As String In Request.Form.Keys
    '            If Not (key = "__VIEWSTATE" OrElse key = "ctl00$data" OrElse key = "__VIEWSTATEGENERATOR" OrElse key = "__EVENTVALIDATION") Then
    '                data.Attributes.Add(key, Request.Form(key))
    '            End If
    '        Next
    '    End If
    'End Sub
End Class