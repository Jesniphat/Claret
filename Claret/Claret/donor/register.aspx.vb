Imports H2GEngine
Public Class donor_register
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Call H2G.setMasterData(Me.Page)

        Dim str As String = H2G.Login.Code
    End Sub

End Class