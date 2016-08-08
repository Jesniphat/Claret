Imports H2GEngine
Imports System.Globalization
Imports System.Threading

Public Class MasterPage
    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Call H2G.setMasterData(Me.Page)
        Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
        Dim strUserInfo As String = ""

        Thread.CurrentThread.CurrentCulture = New CultureInfo("th-TH")
        strUserInfo = "หน่วย " & Cbase.QueryField("select name as name from collection_point where id = '" & H2G.Login.CollectionPointID & "'", "")
        strUserInfo &= " : แผน " & DateTime.Today.ToString("dd MMMM yyyy")
        spCollectionPoint.InnerText = strUserInfo
        spUserName.InnerText = Cbase.QueryField("select firstname || ' ' || lastname || ' (' || code || ')' as name from staff where id = '" & H2G.Login.ID & "'")

    End Sub

End Class