Imports System.Security.Cryptography
Imports System.Globalization
Imports System.IO

Public Class H2G
    Private Const KeyEncryption As String = "H2GkjKDF%IUuv&#r"
    Private Const PassPhrase As String = "H2G!hfYTE&#j@HFd"
    Private Const SaltCryptography As String = "H2GEngineSecurity2016"

    Public Shared ReadOnly Property DEBUG() As Boolean
        Get
            Dim _debug As Boolean = False
            If (HttpContext.Current.Request.Url.Host.Contains("localhost")) Then _debug = True
            Return _debug
        End Get
    End Property
    Public Shared ReadOnly Property DEMO() As Boolean
        Get
            Dim _debug As Boolean = False
            If (HttpContext.Current.Request.Url.AbsoluteUri.Contains("travox.com/mos_demo")) Then _debug = True
            Return _debug
        End Get
    End Property

    Private Shared SelectedCode As String = ""
    Public Shared Property CompanyCode() As String
        Get
            Dim val As String = Nothing
            Try
                Dim session As SessionState.HttpSessionState = HttpContext.Current.Session
                Dim cookie As HttpCookieCollection = HttpContext.Current.Request.Cookies()
                If (Not String.IsNullOrEmpty(session("companycode"))) Then
                    val = session("companycode").ToString.ToUpper
                ElseIf (Not String.IsNullOrEmpty(cookie("COMPANY_ACCESS").Value)) Then
                    HttpContext.Current.Session("companycode") = cookie("COMPANY_ACCESS").Value
                    HttpContext.Current.Session("ID") = cookie("ID").Value
                    val = cookie("COMPANY_ACCESS").Value
                Else
                    Throw New Exception("Session missing. Please Relogin.")
                End If
            Catch ex As Exception
                If (String.IsNullOrEmpty(SelectedCode)) Then Throw New Exception(ex.Message) Else val = SelectedCode
            End Try
            Return val.ToUpper()
        End Get
        Set(ByVal value As String)
            SelectedCode = value
        End Set
    End Property

    Public Shared ReadOnly Property Login() As User
        Get
            Dim _get As New User()
            _get.ID = IIf(Response.isSession("ID"), Response.Session("ID"), Response.Cookie("ID"))
            _get.Name = Response.Cookie("N")
            _get.Code = Response.Cookie("C")
            _get.CollectionPointID = Response.Cookie("CPID")
            _get.SiteID = Response.Cookie("SID")
            _get.PlanID = Response.Cookie("PID")
            _get.PlanDate = Response.Cookie("PD")

            Return _get
        End Get
    End Property

    Public Shared ReadOnly Property URL() As String
        Get
            Dim scheme As String = HttpContext.Current.Request.Url.Scheme & Uri.SchemeDelimiter.ToString()
            Dim reqUrl As String = HttpContext.Current.Request.Url.AbsoluteUri.ToLower
            Dim link As String = HttpContext.Current.Request.Url.Host
            If (link.Contains("localhost")) Then
                link = HttpContext.Current.Request.Url.Authority
            End If
            Return scheme & link
        End Get
    End Property
    Public Shared ReadOnly Property Path() As String
        Get
            Return HttpContext.Current.Server.MapPath("~\")
        End Get
    End Property

    Public Shared Function FileRead(ByVal name_withextension As String) As String
        Dim path As String = H2G.Path & name_withextension
        If (IO.File.Exists(path)) Then
            path = File.ReadAllText(path)
        ElseIf (IO.File.Exists(name_withextension)) Then
            path = File.ReadAllText(name_withextension)
        Else : path = Nothing
        End If
        Return path
    End Function

    Public Shared Function FileStore(ByVal pathname As String, ByVal data As String) As String
        Dim target As String = "D:\mid-backOffice_Backup\#Store_Data\" & pathname
        Dim pathfile As String = IO.Path.GetDirectoryName(target)
        If (IO.File.Exists(target)) Then IO.File.Delete(target)
        If (Not IO.Directory.Exists(pathfile)) Then IO.Directory.CreateDirectory(pathfile)
        File.WriteAllText(target, data)
        Return target
    End Function

    Public Shared Function FileWrite(ByVal pathname As String, ByVal data As String) As String
        Dim target As String = H2G.Path & pathname
        Dim pathfile As String = IO.Path.GetDirectoryName(target)
        If (IO.File.Exists(target)) Then IO.File.Delete(target)
        If (Not IO.Directory.Exists(pathfile)) Then IO.Directory.CreateDirectory(pathfile)
        File.WriteAllText(target, data)
        Return target
    End Function

    Public Shared Function FileWrite(ByVal pathname As String, ByVal data() As Byte) As String
        Dim target As String = H2G.Path & pathname
        Dim pathfile As String = IO.Path.GetDirectoryName(target)
        If (IO.File.Exists(target)) Then IO.File.Delete(target)
        If (Not IO.Directory.Exists(pathfile)) Then IO.Directory.CreateDirectory(pathfile)
        File.WriteAllBytes(target, data)
        Return target
    End Function

    Public Shared Function FileCopy(ByVal source As String, ByVal destination As String) As Boolean
        Dim success As Boolean = True
        Try
            If Not H2G.DEBUG Then
                If (Not source.Contains(":\")) Then source = H2G.Path & source
                If (Not destination.Contains(":\")) Then destination = H2G.Path & destination

                If (IO.File.Exists(destination)) Then IO.File.Delete(destination)
                If (Not IO.Directory.Exists(IO.Path.GetDirectoryName(destination))) Then IO.Directory.CreateDirectory(IO.Path.GetDirectoryName(destination))
                File.Copy(source, destination)
            End If
        Catch
            success = False
        End Try
        Return success
    End Function

    Public Shared Function Timestamp() As Long
        Return CLng(DateTime.UtcNow.Subtract(New DateTime(1970, 1, 1)).TotalSeconds)
    End Function
    Public Shared Function ParseDate(ByVal from_format As String, ByVal to_format As String, ByVal date_time As String) As String
        Dim result As String = ""
        Dim exact As DateTime
        If DateTime.TryParseExact(date_time, from_format, CultureInfo.CurrentCulture.DateTimeFormat, DateTimeStyles.NoCurrentDateDefault, exact) Then
            result = exact.ToString(to_format)
        Else
            If Date.TryParse(date_time, CultureInfo.CurrentCulture.DateTimeFormat, DateTimeStyles.NoCurrentDateDefault, exact) Then
                result = exact.ToString(to_format)
            Else
                Throw New Exception("Error ParseDate")
            End If
        End If
        Return result
    End Function

    Public Shared Function Null(ByVal value As Object) As Integer
        Return String.IsNullOrEmpty(value)
    End Function

    Public Shared Function Int(ByVal value As String) As Integer
        Return H2G.Convert(Of Integer)(value)
    End Function
    Public Shared Function Dec(ByVal value As String) As Decimal
        Return H2G.Convert(Of Decimal)(value)
    End Function
    Public Shared Function DT(ByVal value As String) As DateTime
        Return H2G.Convert(Of DateTime)(value)
    End Function
    Public Shared Function Bool(ByVal value As String) As Boolean
        Return H2G.Convert(Of Boolean)(value)
    End Function
    Public Shared Function ToYN(ByVal value As String) As String
        Return IIf(H2G.Convert(Of Boolean)(value), "Y", "N")
    End Function

    Public Shared Function Convert(Of T)(ByVal value As String) As T
        Dim type As T = Nothing
        Dim index = Nothing
        If (TypeOf type Is Boolean) Then
            If (String.IsNullOrEmpty(value) OrElse (value.ToLower = "n" Or value.ToLower = "false" Or value.ToLower = "no" Or value.ToLower = "0")) Then
                index = False
            ElseIf (value.ToLower = "y" Or value.ToLower = "true" Or value.ToLower = "yes" Or value.ToLower = "1") Then
                index = True
            End If
        ElseIf (TypeOf type Is Decimal) Then
            If (String.IsNullOrEmpty(value) Or Not IsNumeric(value)) Then value = Decimal.Parse("0")
            index = Decimal.Parse(Regex.Replace(value, ",", ""))
        ElseIf (TypeOf type Is Double) Then
            If (String.IsNullOrEmpty(value) Or Not IsNumeric(value)) Then value = Double.Parse("0")
            index = Double.Parse(Regex.Replace(value, ",", ""))
        ElseIf (TypeOf type Is Integer OrElse TypeOf type Is Int32 OrElse TypeOf type Is Int64) Then
            If (String.IsNullOrEmpty(value) Or Not IsNumeric(value)) Then value = Integer.Parse("0")
            If (value.Contains(".")) Then value = Math.Round(Decimal.Parse(value), 0).ToString()
            index = Integer.Parse(value)
        ElseIf (TypeOf type Is DateTime) Or (TypeOf type Is Date) Then
            Try
                Dim FormatDateTime As String = "dd-MM-yyyy HH:mm:ss"
                value = value.Replace("/", "-")
                If (FormatDateTime.Length <> value.Trim.Length) Then
                    Select Case value.Trim.Length
                        Case 10 : value = value.Trim & " 00:00:00"
                        Case 16 : value = value.Trim & ":00"
                    End Select
                End If
                index = DateTime.ParseExact(value, FormatDateTime, System.Globalization.CultureInfo.CurrentCulture.DateTimeFormat)
            Catch
                Throw New Exception("Datetime not format ""DD-MM-YYYY"" OR ""DD-MM-YYYY HH:MM:SS"".")
            End Try
        ElseIf (TypeOf type Is Money.VATType) Then
            If (value.ToUpper = "INCLUDE") Then
                index = Money.VATType.INCLUDE
            ElseIf (value.ToUpper = "EXCLUDE") Then
                index = Money.VATType.EXCLUDE
            End If
        ElseIf (TypeOf type Is Booking.ItemStatus) Then
            Select Case value.ToString.Replace(" ", "").ToUpper()
                Case "TEMP" : index = Booking.ItemStatus.TEMP
                Case "VAT" : index = Booking.ItemStatus.VAT
                Case "NOVAT" : index = Booking.ItemStatus.NOVAT
            End Select
        End If
        Return index
    End Function

    Public Shared Function BE2AC(ByVal value As DateTime) As DateTime
        Return value.AddYears(-543)
    End Function

    Public Shared Function AC2BE(ByVal value As DateTime) As DateTime
        Return value.AddYears(543)
    End Function

    Public Shared Function CountCharacter(ByVal value As String, ch As String) As Int32
        Return CountCharacter(value, ch, False)
    End Function

    Public Shared Function CountCharacter(ByVal value As String, ch As String, ignorCase As Boolean) As Int32
        Return IIf(ignorCase, Len(value) - Len(value.ToLower.Replace(ch.ToLower, "")), Len(value) - Len(value.Replace(ch, "")))
    End Function

    Public Shared Function nextVal(ByVal tableName As String) As String
        Return "select SQ_" & tableName & "_ID.nextval from dual"
    End Function

    Public Shared Function calAge(birthday As Date) As String
        Dim Age As New Date(Now.Subtract(birthday).Ticks)
        Return Age.Year - 1
    End Function


    Public Shared Function Encrypt(ByVal plainText As String) As String
        Dim password As Rfc2898DeriveBytes = New Rfc2898DeriveBytes(PassPhrase, Encoding.ASCII.GetBytes(SaltCryptography), 2)
        Dim symmetric As New RijndaelManaged()
        symmetric.Mode = CipherMode.CBC

        Dim textBytes As Byte() = Encoding.UTF8.GetBytes(plainText)
        Dim mem As New MemoryStream()
        Dim crypt As New CryptoStream(mem, symmetric.CreateEncryptor(password.GetBytes(32), Encoding.ASCII.GetBytes(KeyEncryption)), CryptoStreamMode.Write)
        crypt.Write(textBytes, 0, textBytes.Length)
        crypt.FlushFinalBlock()
        plainText = System.Convert.ToBase64String(mem.ToArray())
        mem.Close()
        crypt.Close()
        Return plainText
    End Function
    Public Shared Function Decrypt(ByVal cipherText As String) As String
        Dim password As Rfc2898DeriveBytes = New Rfc2898DeriveBytes(PassPhrase, Encoding.ASCII.GetBytes(SaltCryptography), 2)
        Dim symmetric As New RijndaelManaged()
        symmetric.Mode = CipherMode.CBC

        Dim mem As New MemoryStream(System.Convert.FromBase64String(cipherText))
        Dim crypt As New CryptoStream(mem, symmetric.CreateDecryptor(password.GetBytes(32), Encoding.ASCII.GetBytes(KeyEncryption)), CryptoStreamMode.Read)
        Dim textBytes As Byte() = New Byte(System.Convert.FromBase64String(cipherText).Length - 1) {}
        cipherText = Encoding.UTF8.GetString(textBytes, 0, crypt.Read(textBytes, 0, textBytes.Length))
        mem.Close()
        crypt.Close()
        Return cipherText
    End Function

    Public Shared Function MD5(ByVal plainText As String) As String
        Return BitConverter.ToString(MD5CryptoServiceProvider.Create().ComputeHash(Encoding.UTF8.GetBytes(plainText))).Replace("-", "").ToLower()
    End Function
    Public Shared Function MD5(ByVal plainText As String, ByVal cipherText As String) As Boolean
        Dim checkSum As Boolean = False
        If (MD5(plainText) = cipherText.Trim()) Then checkSum = True
        Return checkSum
    End Function

    REM :: HACK SECURITY CHECK
    Public Shared Function CookieAllowAccess() As Boolean
        If (Response.Cookie("SocketInjection") = "N/A") Then Return False Else Return True
    End Function

    Public Shared Sub setMasterData(current As Page)
        Dim data As HtmlInputText
        data = CType(current.Master.FindControl("data"), HtmlInputText)
        If current.Request.Form.Keys.Count = 0 Then Throw New Exception("Enter by hotlink")
        If Not data Is Nothing Then
            For Each key As String In current.Request.Form.Keys
                If Not (key = "__VIEWSTATE" OrElse key = "ctl00$data" OrElse key = "__VIEWSTATEGENERATOR" OrElse key = "__EVENTVALIDATION") Then
                    data.Attributes.Add(key, current.Request.Form(key))
                End If
            Next
        End If
    End Sub

End Class