Public Class Language
   Inherits List(Of ParameterLanguage)

   Private _Current As Type
   Private Store As New List(Of Choose)

   Public Enum Type
      TH
      EN
      JP
   End Enum

   Private Sub GenerateLanguageStore()
      Me.Language("test", "Thai", "Japanese")
   End Sub

   Public Sub New(ByVal language As Type)
      _Current = language
   End Sub

   Private Sub Language(ByVal name As String, ByVal th As String, ByVal jp As String)
      Dim _c As New Choose()
      _c.Name = name
      _c.TH = th
      _c.JP = jp
      Store.Add(_c)
   End Sub

End Class

Public Class ParameterLanguage
   Public Name As String
   Public Value As String
End Class

Friend Structure Choose
   Public Name As String
   Public TH As String
   Public JP As String
End Structure