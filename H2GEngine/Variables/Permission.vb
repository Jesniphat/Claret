Public Class Permission
    Public Shared Sub Create(ByVal page As Object, ByVal user_id As String)
        Dim Cookie As New Response(page)
        Dim param As New SQLCollection("@staff_id", DbType.String, user_id)
        Cookie.Write("MBOSPermission", New DBQuery().QueryField(My.Resources.SELECT_permission, param) & "#")
        Cookie.Write("MBOSDepartment", New DBQuery().QueryField("SELECT depart_name FROM department WHERE id = (SELECT TOP 1  department_id FROM staff WHERE id = @staff_id)", param))
    End Sub

    Public Shared Function Contains(ByVal index_name As String) As Boolean
        Dim iFound As Boolean = False
        If H2G.Login.ID > 0 Then
            index_name = New DBQuery().QueryField(String.Format(My.Resources.SELECT_permission_id, index_name.Trim()))
            If (Response.Cookie("MBOSPermission").Contains("#" & index_name & "#")) Then iFound = True
        Else
            iFound = True
        End If
        Return iFound
    End Function
End Class
