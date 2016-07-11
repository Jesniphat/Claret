Imports System.Net.NetworkInformation
Imports System.Net.NetworkInformation.NetworkInterface

Namespace Extensions
    Public Class GlobalTravox

        Public Shared ReadOnly Property BrowserCollection() As NameValueCollection
            Get
                Dim _arr = New NameValueCollection()
                _arr.add("IE 5", "MSIE 5.0")
                _arr.add("IE 5.5", "MSIE 5.5")
                _arr.add("IE 6", "MSIE 6.0")
                _arr.add("IE 7", "MSIE 7.0")
                _arr.add("IE 8", "MSIE 8.0")
                _arr.add("IE 9", "MSIE 9.0")
                _arr.add("IE 10", "MSIE 10.0")
                _arr.add("IE 11", "rv:11.0")
                _arr.add("Chrome", "Chrome")
                _arr.add("Firefox", "Firefox")
                _arr.add("Safari", "Safari")
                _arr.add("Opera", "Opera")
                Return _arr
            End Get
        End Property
        Public Shared ReadOnly Property OSCollection() As NameValueCollection
            Get
                Dim _arr = New NameValueCollection()
                _arr.add("Windows XP", "Windows NT 5.1")
                _arr.add("Windows XP 64-bit Edition", "Windows NT 5.2")
                _arr.add("Windows Vista", "Windows NT 6.0")
                _arr.add("Windows 7", "Windows NT 6.1")
                _arr.add("Windows 8", "Windows NT 6.2")
                _arr.add("Windows 8.1", "Windows NT 6.3")
                _arr.add("Mac OS X 10", "Mac OS X 10")
                _arr.add("Mac OS X (iPhone)", "iPhone;")
                _arr.add("Mac OS X (iPad)", "iPad;")
                _arr.add("Android", "Android")
                _arr.add("Linux", "Linux")
                _arr.add("QNX", "QNX")
                Return _arr
            End Get
        End Property

        Public Shared Sub LogErrorMessage(ByVal message As String)
            Dim database As New DBQuery()
            Dim param As New ParameterCollection()
            param.Add("@company_code", DbType.String, H2G.CompanyCode())
            param.Add("@err_msg", DbType.String, message)
            param.Add("@err_page", DbType.String, IO.Path.GetFileName(HttpContext.Current.Request.Url.AbsolutePath()))
            database.Execute(My.Resources.INSERT_err_message, param)
            database.Apply()
        End Sub

        Public Shared Sub LoginHistory(ByVal com_code As String, ByVal user_code As String, ByVal status As String)
            Dim database As New DBQuery()
            Dim param As New ParameterCollection()
            Dim browser_name As String = "UNKNOW"
            Dim os_name As String = "UNKNOW"
            Dim user_agent As String = HttpContext.Current.Request.ServerVariables("HTTP_USER_AGENT")
            Dim mac_addr As String = "UNKNOW"
            Try
                For Each item As String In BrowserCollection.AllKeys
                    If (user_agent.Contains(BrowserCollection(item))) Then
                        browser_name = item
                        Exit For
                    End If
                Next

                For Each item As String In OSCollection.AllKeys
                    If (user_agent.Contains(OSCollection(item))) Then
                        os_name = item
                        Exit For
                    End If
                Next

                param.Add("@com_code", DbType.String, com_code.ToUpper())
                param.Add("@user_code", DbType.String, user_code.ToUpper())
                param.Add("@ip", DbType.String, HttpContext.Current.Request.ServerVariables("remote_addr"))
                param.Add("@mac", DbType.String, mac_addr)
                param.Add("@browser", DbType.String, browser_name)
                param.Add("@os", DbType.String, os_name)
                param.Add("@status", DbType.String, status)
                param.Add("@user_agent", DbType.String, user_agent)
                database.Execute(My.Resources.INSERT_login_history, param)
                database.Apply()
            Catch
                database.Rollback()
                Throw New Exception("Login History. Saved Exceiption")
            End Try
        End Sub
    End Class
End Namespace