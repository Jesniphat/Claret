Namespace UI
    Public Class Control

        Public Shared Sub DropdownBind(ByRef ddl As HtmlControls.HtmlSelect, ByVal dt As DataTable)
            Control.DropdownBind(ddl, dt, False)
        End Sub
        Public Shared Sub DropdownBind(ByRef ddl As HtmlControls.HtmlSelect, ByVal dt As DataTable, ByVal NullValue As Boolean)
            ddl.DataTextField = "title"
            ddl.DataValueField = "val"
            ddl.Items.Clear()
            If (dt.Columns.Count >= 2) Then
                dt.Columns(0).ColumnName = "title"
                dt.Columns(1).ColumnName = "val"
                ddl.DataSource = dt
                ddl.DataBind()
            End If
            If (NullValue) Then ddl.Items.Insert(0, New ListItem("", ""))
        End Sub

        Public Shared Sub DropdownBind(ByRef ddl As HtmlControls.HtmlSelect, ByVal dt As NameValueCollection)
            ddl.Items.Clear()
            For Each title As String In dt.AllKeys()
                ddl.Items.Add(New ListItem(title, dt(title)))
            Next
        End Sub


    End Class
End Namespace
