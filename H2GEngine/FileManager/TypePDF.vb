Imports System.IO
Imports org.apache.pdfbox.pdmodel
Imports org.apache.pdfbox.util

Namespace FileManager
    Public Class TypePDF

        Private Shared KeepChars As Integer = 15

        Public Shared Function Import(ByVal inFileName As String) As StringBuilder
            Dim outString As New StringBuilder
            Try
                If (Not File.Exists(inFileName)) Then Throw New Exception("PDF file path not found. " & vbCrLf & inFileName)
                Dim doc As PDDocument = Nothing
                Try
                    doc = PDDocument.load(inFileName)
                    Dim stripper As New PDFTextStripper()
                    outString.Append(stripper.getText(doc))
                Finally
                    If doc IsNot Nothing Then doc.close()
                End Try
            Catch ex As Exception
                outString.AppendLine(ex.Message)
            End Try
            Return outString
        End Function
    End Class
End Namespace

