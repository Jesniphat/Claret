Public Class _Default
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Response.Redirect("login.aspx")

        '### TEST ###
        'Dim strOldRunning As String = "GDS160000123"
        'Dim intRunningDigit As Int16 = 7
        'Dim intNumber As Int64 = CInt(strOldRunning.Substring(strOldRunning.Length - intRunningDigit))
        'Response.Write(intNumber)

    End Sub

End Class