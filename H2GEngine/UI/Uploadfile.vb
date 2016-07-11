Imports System.IO

Namespace UI
    Public Class Uploadfile
        Inherits UI.Page

        Private FilePath As String
        Private FileName As String

        Protected ReadOnly Property MBOSFilePath() As String
            Get
                Return FilePath
            End Get
        End Property
        Protected ReadOnly Property MBOSFileName() As String
            Get
                Return FileName
            End Get
        End Property

        Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            If Request.Files.Count() > 0 Then
                Dim UploadDirectory As String = H2G.Path & "Temp\Attach\"
                Dim MBOSFile As HttpPostedFile = Request.Files("MBOSInputFile")
                FilePath = UploadDirectory & Path.GetFileName(MBOSFile.FileName())
                FileName = Path.GetFileName(MBOSFile.FileName())
                If (Not Directory.Exists(UploadDirectory)) Then Directory.CreateDirectory(UploadDirectory)
                If (File.Exists(FilePath)) Then
                    FilePath = UploadDirectory & Path.GetFileNameWithoutExtension(MBOSFile.FileName()) & "_" & _
                               H2G.Timestamp.ToString() & Path.GetExtension(MBOSFile.FileName())
                End If
                MBOSFile.SaveAs(FilePath)
            End If
        End Sub
    End Class
End Namespace
