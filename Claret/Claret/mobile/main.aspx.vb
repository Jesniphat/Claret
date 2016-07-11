Imports H2GEngine
Public Class mobile_main
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Call H2G.setMasterData(Me.Page)
    End Sub

End Class