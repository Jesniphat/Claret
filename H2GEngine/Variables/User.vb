Public Class User
    Public ID As String
    Public Code As String
    Public Name As String
    Public SiteID As String
    Public CollectionPointID As String
    Public PlanID As String
    Public PlanDate As String

    Public Shared SessionTime As Long = 3600 ' Second

    Public Shared Function DepartmentName() As String
        Dim param As New SQLCollection("@id", DbType.Int64, H2G.Login.ID)
        Return New DBQuery().QueryField("SELECT depart_name FROM department WHERE id = (SELECT TOP 1  department_id FROM staff WHERE id = @id)", param)
    End Function

    Public Shared Sub InitializeEngine(ByRef page As Object, ByVal com_code As String, ByVal user_code As String, ByVal pass_code As String)
        Dim session As HttpSessionState = HttpContext.Current.Session
        Dim base As New DBQuery()

        Try

            'Extensions.GlobalTravox.LoginHistory(com_code, user_code, "MBOS")
            'Dim aaa As Integer = New StackFrame(0, True).GetFileLineNumber()
            Dim param As New SQLCollection()
            param.Add("@code", DbType.String, com_code)
            param.Add("@user", DbType.String, user_code)
            param.Add("@pass", DbType.String, pass_code)
            param.Add("@created", DbType.DateTime, DateTime.Now.ToString("dd-MM-yyyy HH:mm:ss"))
            param.Add("@expired", DbType.DateTime, DateTime.Now.AddHours(1).ToString("dd-MM-yyyy HH:mm:ss"))
            param.Add("@session", DbType.String, Response.Cookie("ASP.NET_SessionId").ToUpper())
            param.Add("@ip", DbType.String, HttpContext.Current.Request.ServerVariables("remote_addr"))

            base.Execute("UPDATE sys_session.login SET alive='N' WHERE alive = 'Y' AND expired_date <= GETDATE()")

            Dim StaffSignIn As String = base.QueryField("SELECT COUNT(*) FROM sys_session.login WHERE alive='Y' AND staff_id > 0", param)
            Dim StaffLimit As Integer = CompanyProfile.LimitStaff()

            If String.IsNullOrEmpty(base.QueryField("SELECT id FROM /*[GLOBAL]*/site_customer WHERE code=@code", param)) Then
                Throw New Exception("Does your company have purchased products from us.")
            ElseIf String.IsNullOrEmpty(base.QueryField("SELECT id FROM staff WHERE code=@user", param)) Then
                Throw New Exception("The username you entered is incorrect.")
            ElseIf String.IsNullOrEmpty(base.QueryField("SELECT id FROM staff WHERE code=@user AND password=@pass", param)) Then
                Throw New Exception("The password you entered is incorrect.")
            ElseIf StaffLimit > 0 And H2G.Int(StaffSignIn) > StaffLimit Then
                Throw New Exception(String.Format("User login is limit {0} account.", StaffLimit))
            Else
                param.Add("@name", DbType.String, base.QueryField("SELECT name FROM staff WHERE code=@user AND password=@pass", param))
                param.Add("@staff", DbType.String, base.QueryField("SELECT id FROM staff WHERE code=@user AND password=@pass", param))

                Dim unCrypt As New Response(page, False)
                unCrypt.Destroy()
                unCrypt.Write("COMPANY_ACCESS", com_code)
                unCrypt.Write("Name", param("@name").DefaultValue)

                Dim Crypt As New Response(page, True)
                Crypt.Write("BASE_ACCESS", com_code)
                Crypt.Write("ID", param("@staff").DefaultValue)
                Crypt.Write("Code", user_code)

                If Not String.IsNullOrEmpty(base.QueryField("SELECT id FROM sys_session.login WHERE staff_id=@staff AND session_id=@session AND alive='Y'", param)) Then
                    base.Execute("UPDATE sys_session.login SET expired_date=@expired WHERE staff_id=@staff AND session_id=@session AND alive='Y'", param)
                Else
                    base.Execute("INSERT INTO sys_session.login(created_date, expired_date, staff_id, username, session_id, ip_address) VALUES(@created, @expired, @staff, @name, @session, @ip)", param)
                End If
                base.Apply()
            End If
        Catch ex As Exception
            base.Rollback()
        End Try
    End Sub

    Public Shared Function SessionExpired(ByVal page As Object) As Boolean
        Dim base As New DBQuery()
        Dim param As New SQLCollection()
        Try
            param.Add("@code", DbType.String, H2G.CompanyCode)
            param.Add("@user", DbType.String, H2G.Login.Code)
            param.Add("@expired", DbType.DateTime, DateTime.Today.AddHours(1).ToString("dd-MM-yyyy hh:mm:ss"))
            param.Add("@session", DbType.String, Response.Cookie("ASP.NET_SessionId"))
            param.Add("@ip", DbType.String, HttpContext.Current.Request.ServerVariables("remote_addr"))

            If String.IsNullOrEmpty(base.QueryField("SELECT code FROM sys_session.login WHERE username=@code AND session_id=@session AND ipv4_address=@ip", param)) Then
                Throw New Exception("Session timeout. You stopped using more than 1 hour, Please re-login.")
            Else
                base.Execute("UPDATE sys_session.login SET expired_date = @expired WHERE username=@user AND session_id = @session AND ipv4_address = @ip", param)
            End If

        Catch ex As Exception
            base.Rollback()
        End Try
    End Function

End Class
