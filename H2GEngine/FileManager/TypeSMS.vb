Imports System
Imports System.Text
Imports System.Net
Imports System.Web
Imports System.IO
Imports System.Uri
Imports H2GEngine.Extensions

Namespace FileManager
    Public Class TypeSMS
        Const SMSDelivery As String = "https://sms-delivery.com/api.php?userid={0}&password={1}&sender={2}&recipient={3}&message={4}"
        Private _error As String = ""

        Public Sub New()
            Dim database As New DBQuery()
            Dim dtInital As DataTable = database.QueryTable(My.Resources.SELECT_InitialSMS)
        End Sub

        Public Shared Function Convert(ByVal number As String) As String
            Return Regex.Split(number, ",")(0).Trim().Replace("-", "")
        End Function

        Public Shared Function Convert(ByVal country As String, ByVal number As String) As String
            number = Convert(number)
            If (number.Substring(0, 1) = "0") Then number = country & number.Substring(1)
            Return number
        End Function

        Public Function Send(ByVal number As String, ByVal message As String) As Boolean
            Dim result As Boolean = False
            Try
                System.Net.ServicePointManager.Expect100Continue = False
                Dim request As WebRequest = WebRequest.Create("http://mos.travox.com/mbos_v4/api/sms_api.aspx")
                request.Method = "POST"
                Dim postData As String = String.Format("type=json&sender=TRAVOX&msisdn={0}&message={1}", EscapeUriString(number), EscapeUriString(message))
                Dim byteArray As Byte() = Encoding.UTF8.GetBytes(postData)
                request.ContentType = "application/x-www-form-urlencoded"
                request.ContentLength = byteArray.Length
                Dim dataStream As Stream = request.GetRequestStream()
                dataStream.Write(byteArray, 0, byteArray.Length)
                dataStream.Close()
                Dim response As WebResponse = request.GetResponse()
                Console.WriteLine(CType(response, HttpWebResponse).StatusDescription)
                dataStream = response.GetResponseStream()
                Dim reader As New StreamReader(dataStream)
                _error = reader.ReadToEnd()
                reader.Close()
                dataStream.Close()
                response.Close()
                result = True
                ' (results.IndexOf("yes") <> -1) Then result = True Else _error = Byte.Parse(results)
            Catch
                _error = "Exception Sending."
            End Try
            Return result
        End Function

        Public Function ErrorMessage() As String
            Return _error
        End Function
    End Class
End Namespace
