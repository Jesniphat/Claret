Imports System.Collections.Generic
Namespace DataCollection
    Public Class CookieCollection
        Inherits NameValueCollection

        Private RegexKey As String = "#MBOSK>>"
        Private RegexValue As String = "#MBOSV::"

        Private Cookie As Response
        Private CookieName As String
        Public Sub New(ByVal page As Object, ByVal name As String)
            CookieName = name
            Cookie = New Response(page)
            Dim reg As Match = Regex.Match(Cookie.Read(name), RegexKey & "(.*)" & RegexValue & "(.*)")
            ' reg.Groups(1).Value()
        End Sub

        Public Overrides Sub Add(ByVal name As String, ByVal value As String)
            BaseAdd(name, value)
            Me.Write()
        End Sub

        Private Sub Write()
            Dim s(BaseGetAllValues().Length - 1) As String
            BaseGetAllValues().CopyTo(s, BaseGetAllValues().Length - 1)
            Cookie.Write(CookieName, RegexKey & String.Join("|", BaseGetAllKeys()) & RegexValue & String.Join("|", s))
        End Sub
    End Class
End Namespace
