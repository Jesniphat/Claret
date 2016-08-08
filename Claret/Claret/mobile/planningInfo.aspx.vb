Imports H2GEngine
Public Class planning_info
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Call H2G.setMasterData(Me.Page)
    End Sub

End Class