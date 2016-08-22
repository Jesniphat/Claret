Imports H2GEngine

Public Class _Default
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Response.Redirect("login.aspx")

        'Dim strPassword = H2G.MD5("12345")
        'Response.Write(strPassword)
        '### TEST ###
        'Dim strOldRunning As String = "GDS160000123"
        'Dim intRunningDigit As Int16 = 7
        'Dim intNumber As Int64 = CInt(strOldRunning.Substring(strOldRunning.Length - intRunningDigit))
        'Response.Write(intNumber)
        'Dim Query As String = "insert into staffx (insert_staff) values(2) "
        'Query = "update staffx set update_date = '3478642' where update_date = '34234'"
        'Query = "delete from staffx where delete_id = '34234'"
        'Dim ID As String = "2"
        'Dim code As String = "bk"
        'Dim logs As String = String.Format("$&/* {0}|{1} */ ", ID, code)
        'Dim regexInsert As String = "^\W*?insert\W+?into\W+?"
        'Dim regexUpdate As String = "^\W*?update\W+?"
        'Dim regexDelete As String = "^\W*?delete\W+?"
        'If (Regex.IsMatch(Query, regexInsert, RegexOptions.IgnoreCase)) Then
        '    Query = Regex.Replace(Query, regexInsert, logs, RegexOptions.IgnoreCase)
        'ElseIf (Regex.IsMatch(Query, regexUpdate, RegexOptions.IgnoreCase)) Then
        '    Query = Regex.Replace(Query, regexUpdate, logs, RegexOptions.IgnoreCase)
        'ElseIf (Regex.IsMatch(Query, regexDelete, RegexOptions.IgnoreCase)) Then
        '    Query = Regex.Replace(Query, regexDelete, logs, RegexOptions.IgnoreCase)
        'End If
        'Response.Write(Query)
    End Sub

End Class