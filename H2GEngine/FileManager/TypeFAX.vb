Imports System.Net.Mail

Namespace FileManager
    Public Class TypeFAX
        Inherits TypeMAIL

        Private EmailFromAddress As String
        Public Sub New(ByVal subject As String)
            MyBase.New()
            MyBase.Subject(subject)

            EmailFromAddress = CompanyProfile.Email()
            Dim base As New DBQuery()
            MyBase.Add(SendTo.FROM, EmailFromAddress)
            MyBase.Add(SendTo.TO, base.QueryField("SELECT fax_email FROM travox_global.travoxmos.initial"))
            MyBase.Add(SendTo.BCC, base.QueryField("SELECT admin_email FROM travox_global.travoxmos.initial"))
        End Sub

        Public Overloads Function Sending(ByVal number As String, ByVal name As String) As Boolean
            Dim message As New StringBuilder(255)
            message.AppendLine("CLIENTVERSION: 6.7.9")
            message.AppendLine("PRINTEDFAX: TRUE")
            message.AppendFormat("FAXNUMBER: {0}", number).AppendLine()
            message.AppendFormat("FROMLINE: {0}", EmailFromAddress).AppendLine()
            message.AppendLine("BILLINGCODE: <Default>")
            message.AppendFormat("FROMNAME: {0}", name).AppendLine()
            message.AppendFormat("FROMCOMPANY: {0}", CompanyProfile.Name()).AppendLine()
            message.AppendLine("PRIORITY: 50")
            message.AppendLine("CONFIRMSEND: TRUE")
            message.AppendLine("ATTACHFAXFILE: TRUE")
            message.AppendLine("NOCOVERPAGE: TRUE")
            message.AppendFormat("COMMENTS: {0}", EmailFromAddress).AppendLine()
            message.AppendLine("RETRYATTEMPTS: 0")
            message.AppendLine("RETRYDELAY: 0")
            MyBase.Content(message.ToString())
            Return MyBase.Sending()
        End Function

    End Class
End Namespace
