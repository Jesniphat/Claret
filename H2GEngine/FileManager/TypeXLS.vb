Imports System.Data.OleDb

Namespace FileManager
    Public Class TypeXLS
        Public Shared Function Import(ByVal path As String, ByVal sheet_name As String) As DataTable
            Dim dtReturn As New DataTable
            Dim cnExcel As New OleDb.OleDbConnection(String.Format(My.Resources.ConnectionExcel, path))
            If String.IsNullOrEmpty(sheet_name) Then
                cnExcel.Open()
                dtReturn = cnExcel.GetOleDbSchemaTable(OleDbSchemaGuid.Tables, Nothing)
                sheet_name = dtReturn.Rows(0)("TABLE_NAME").ToString()
                cnExcel.Close()
            Else : sheet_name &= "$"
            End If

            Dim sql As String = "SELECT * FROM [" & sheet_name & "]"
            Dim da As New OleDb.OleDbDataAdapter(sql, cnExcel)
            da.Fill(dtReturn)
            da.Dispose()
            Return dtReturn
        End Function
        Public Shared Function Import(ByVal path As String) As DataTable
            Return TypeXLS.Import(path, Nothing)
        End Function
    End Class
End Namespace