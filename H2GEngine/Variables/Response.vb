
Public Class Response
    Private ReadCookie As HttpRequest
    Private WriteCookie As HttpResponse
    Private EncodeCookie As Boolean

    Public Sub New(ByVal current As Object)
        Me.New(current, True)
    End Sub
    Public Sub New(ByVal current As Object, ByVal encode As Boolean)
        ReadCookie = current.Page.Request
        WriteCookie = current.Page.Response
        EncodeCookie = encode
    End Sub
    Public Sub Write(ByVal name As String, ByVal value As String)
        Write(name, value, 0)
    End Sub
    Public Sub Write(ByVal name As String, ByVal value As String, ByVal hour As Decimal)
        Try
            If (Not H2G.DEBUG And EncodeCookie) Then
                name = H2G.MD5(name)
                value = H2G.Encrypt(value)
            End If
            Dim isCookie = New HttpCookie(name)
            isCookie.Value = value
            If (hour > 0) Then isCookie.Expires = DateTime.Now.AddMinutes(hour * 60)
            WriteCookie.Cookies.Add(isCookie)
        Catch ex As Exception
            Throw New Exception("Cookie is not allow.")
        End Try
    End Sub
    Public Function Read(ByVal name As String) As String
        If (Not H2G.DEBUG And EncodeCookie) Then name = H2G.MD5(name)
        Dim result As String = "|" & String.Join("|", ReadCookie.Cookies.AllKeys) & "|"
        If result.Contains("|" & name & "|") Then
            If (Not H2G.DEBUG And EncodeCookie) Then
                result = H2G.Decrypt(ReadCookie.Cookies.Item(name).Value)
            Else
                result = ReadCookie.Cookies.Item(name).Value
            End If
        Else
            result = "N/A"
        End If
        Return result
    End Function
    Public Function Destroy(ByVal name As String) As Boolean
        Dim iFound As Boolean = True
        If (Not H2G.DEBUG And EncodeCookie) Then name = H2G.MD5(name)
        If WriteCookie.Cookies.Item(name) Is Nothing Then
            iFound = False
        Else
            WriteCookie.Cookies(name).Expires = DateTime.Now.AddDays(-1)
            WriteCookie.Cookies.Remove(name)
        End If
        Return iFound
    End Function
    Public Sub Destroy()
        For Each name As String In ReadCookie.Cookies.AllKeys
            If (name <> "ASP.NET_SessionId") Then WriteCookie.Cookies(name).Expires = DateTime.Now.AddDays(-1)
        Next
    End Sub
    Public Function Contains(ByVal name As String) As Boolean
        Dim found As Boolean = False
        Dim ReadCookies As HttpCookieCollection = HttpContext.Current.Request.Cookies()
        Dim result As String = "|" & String.Join("|", ReadCookies.AllKeys) & "|"
        If result.Contains("|" & H2G.MD5(name) & "|") Or result.Contains("|" & name & "|") Then found = True
        Return found
    End Function

    Public Shared Function isCookie(ByVal name As String) As Boolean
        Return IIf(Response.Cookie(name) = "N/A", False, True)
    End Function
    Public Shared Function Cookie(ByVal name As String) As String
        Dim ReadCookies As HttpCookieCollection = HttpContext.Current.Request.Cookies()
        Dim result As String = "|" & String.Join("|", ReadCookies.AllKeys) & "|"
        Dim md5 As String = H2G.MD5(name)
        If result.Contains("|" & md5 & "|") Then
            result = H2G.Decrypt(ReadCookies.Item(md5).Value)
        ElseIf result.Contains("|" & name & "|") Then
            result = ReadCookies.Item(name).Value
        Else
            result = "N/A"
        End If
        Return result
    End Function

    Public Shared Function isSession(ByVal name As String) As Boolean
        Return IIf(Response.Session(name) = "N/A", False, True)
    End Function
    Public Shared Function Session(ByVal name As String) As String
        Dim ReadSessions As NameObjectCollectionBase.KeysCollection = HttpContext.Current.Session.Keys
        Dim result As String = "N/A"
        For Each key As String In ReadSessions
            If (key = name) Then
                result = HttpContext.Current.Session(key)
                Exit For
            End If
        Next
        Return result
    End Function


End Class

