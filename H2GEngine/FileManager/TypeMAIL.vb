Imports System.IO
Imports System.Net.Mail
Imports System.Net.Mime
Imports System.Threading
Imports System.ComponentModel

Namespace FileManager
    Public Class TypeMAIL
        Private Mail As New MailMessage
        Private ContentMail As New StringBuilder
        Private emailExp As New Regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$")
        Public ErrorMessage As String = ""
        Public From As String = ""

        Public Enum SendTo
            [FROM]
            [TO]
            [CC]
            [BCC]
        End Enum

        Public Sub New(ByVal email_from As String, ByVal subject As String, ByVal ns_email As Boolean)
            Try
                If (Not String.IsNullOrEmpty(email_from) And Not String.IsNullOrEmpty(subject)) Then
                    If (Not emailExp.IsMatch(email_from)) Then Throw New Exception("Invalid email from.")
                    Mail.From = New MailAddress(email_from)
                    From = email_from
                    Mail.IsBodyHtml = True
                    Mail.Subject = "MBOS :: " & subject
                    Mail.SubjectEncoding = System.Text.Encoding.UTF8
                End If
                If (ns_email) Then
                    For Each email As String In CompanyProfile.BCCEmail.Split(",")
                        If (Not String.IsNullOrEmpty(email)) Then Mail.Bcc.Add(New MailAddress(email))
                    Next
                End If

            Catch ex As Exception
                ErrorMessage = ex.Message()
            End Try
        End Sub

        Public Sub New(ByVal email_from As String, ByVal subject As String)
            Me.New(email_from, subject, False)
        End Sub

        Public Sub New()
            Me.New(Nothing, Nothing, False)
        End Sub

        Public Sub Subject(ByVal subject As String)
            Mail.Subject = "MBOS :: " & subject
        End Sub

        Public Sub Add(ByVal email As String)
            Me.Add(SendTo.TO, email)
        End Sub
        Public Sub Add(ByVal type As SendTo, ByVal email As String)
            If Not String.IsNullOrEmpty(email) Then
                For Each list As String In Regex.Split(email, "[;,]")
                    'emailExp.IsMatch(list.ToLower())) Then ' And Not Mail.Bcc.Contains(New MailAddress(list))
                    If (Not String.IsNullOrEmpty(list.Trim())) Then
                        If (Mail.Bcc.Contains(New MailAddress(list))) Then Mail.Bcc.Remove(New MailAddress(list))
                        If (emailExp.IsMatch(list)) Then
                            Select Case type
                                Case SendTo.FROM : Mail.From = New MailAddress(list)
                                Case SendTo.TO : Mail.To.Add(New MailAddress(list))
                                Case SendTo.CC : Mail.CC.Add(New MailAddress(list))
                                Case SendTo.BCC : Mail.Bcc.Add(New MailAddress(list))
                            End Select
                        End If
                    End If
                Next
            End If
        End Sub

        Public Sub Attach(ByVal filename As String)
            If (File.Exists(filename)) Then
                Mail.Attachments.Add(New Attachment(filename))
            Else
                ContentMail.Insert(0, "<p class=""error""><b>Not Found File :</b>" & Path.GetFileName(filename) & "</p>")
            End If
        End Sub

        Public Sub Content(ByVal contents As String)
            Mail.IsBodyHtml = False
            ContentMail = New StringBuilder()
            ContentMail.Append(contents)
        End Sub

        Public Sub Body(ByVal contents As String)
            Mail.IsBodyHtml = True
            ContentMail.Append(contents)
        End Sub

        Public Sub BodyHTML(ByVal template_name As String)
            Mail.IsBodyHtml = True
            Dim filename As String = H2G.Path & "Resources\TemplateMail\" & H2G.CompanyCode & "\" & template_name & ".html"
            If (Not File.Exists(filename)) Then filename = filename.Replace("\" & H2G.CompanyCode & "\", "\MOS\")
            If (File.Exists(filename)) Then
                filename = File.ReadAllText(filename).Replace("  ", " ")
                ContentMail.Append(filename)
            End If
        End Sub

        Public Sub DataSource(ByVal param As NameValueCollection)
            If (param.Count > 0) Then
                For Each item As String In param.AllKeys
                    If (ContentMail.ToString.Contains("{" & item & "}")) Then
                        If (String.IsNullOrEmpty(param(item).ToString())) Then param(item) = "&nbsp;"
                        ContentMail.Replace("{" & item & "}", param(item))
                    End If
                Next
            End If
        End Sub
        Public Sub DataSource(ByVal data As DataTable)
            If (data.Rows.Count > 0) Then
                For Each row As DataRow In data.Rows
                    For Each column As DataColumn In data.Columns
                        If (ContentMail.ToString.Contains("{" & column.ColumnName & "}")) Then
                            If (String.IsNullOrEmpty(row(column).ToString())) Then row(column) = "&nbsp;"
                            ContentMail.Replace("{" & column.ColumnName & "}", row(column))
                        End If
                    Next
                    Exit For
                Next
            End If
        End Sub
        Public Sub DataSourceRow(ByVal data As DataTable)
            Dim BodyRow As New StringBuilder()
            Dim tag_begin As String = "{" & data.TableName & "}"
            Dim tag_end As String = "{/" & data.TableName & "}"
            If (ContentMail.ToString.Contains(tag_begin) And ContentMail.ToString.Contains(tag_end) And data.Rows.Count > 0) Then
                Dim index_begin As Integer = ContentMail.ToString.IndexOf(tag_begin)
                Dim index_end As Integer = ContentMail.ToString.IndexOf(tag_end)
                Dim rowHTML As String = ContentMail.ToString.Substring((index_begin), (index_end + tag_begin.Length) - index_begin + 1)
                ContentMail.Remove(index_begin, rowHTML.Length)
                rowHTML = rowHTML.Replace(tag_begin, "").Replace(tag_end, "")
                For Each row As DataRow In data.Rows
                    Dim dataRow As String = rowHTML.Clone()
                    For Each column As DataColumn In data.Columns
                        If (rowHTML.Contains("{" & column.ColumnName & "}")) Then
                            If (String.IsNullOrEmpty(row(column).ToString())) Then row(column) = "&nbsp;"
                            dataRow = dataRow.Replace("{" & column.ColumnName & "}", row(column)).Trim()
                        End If
                    Next
                    BodyRow.Append(dataRow)
                Next
                ContentMail.Insert(index_begin, BodyRow.ToString())
            End If
        End Sub

        Public Function Sending() As Boolean
            Dim isSuccess As Boolean = True
            Try
                If (ErrorMessage <> Nothing) Then Throw New Exception(ErrorMessage)
                If (Mail.To.Count = 0) Then Throw New Exception("Can not find the destination email.")

                Dim client As New SmtpClient()
                Mail.Body = IIf(Mail.IsBodyHtml, Me.HTMLPattern().ToString(), ContentMail.ToString())
                If H2G.CompanyCode = "CCT" Then
                    client.Credentials = New Net.NetworkCredential("info@travelconnecxion.com", "Chaamcct9!")
                    client.Host = "mail.travelconnecxion.com"
                    client.Port = 587
                Else
                    client.Host = New DBQuery().QueryField("SELECT TOP 1 ip_smtp_server FROM /*[GLOBAL]*/initial")
                End If
                client.Send(Mail)
            Catch ex As Exception
                ErrorMessage = "Send :: " & ex.Message()
                isSuccess = False
                Extensions.GlobalTravox.LogErrorMessage(ErrorMessage & vbCrLf & ex.StackTrace() & vbCrLf & ex.Source())
            End Try
            Mail.Dispose()
            Return isSuccess
        End Function
        Public Function MBOSSending() As Boolean
            Return Me.Sending()
        End Function

        Public Function GetContent() As StringBuilder
            Return IIf(Mail.IsBodyHtml, Me.HTMLPattern(), ContentMail)
        End Function

        Private Function HTMLPattern() As StringBuilder
            Dim pattern As New StringBuilder()
            pattern.Append("<!DOCTYPE html>")
            pattern.Append("<html><head><title>H2GEngine E-Mail</title>")
            pattern.Append("<meta http-equiv=""Content-Type"" content=""text/html; charset=utf-8""></head><body>")
            pattern.Append("<style type='text/css'>html,body{padding:0px;margin:0px;background:#FFF;}html,body,table{font-size:12px;font-family:Tahoma;}</style>")
            pattern.Append(ContentMail.ToString())
            pattern.Append("</body></html>")
            Return pattern
        End Function
    End Class
End Namespace
