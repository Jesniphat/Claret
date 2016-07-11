Imports H2GEngine
Public Class donor_search
    Inherits UI.Page 'System.Web.UI.Page
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Call H2G.setMasterData(Me.Page)

    End Sub

End Class