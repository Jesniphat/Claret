Imports System.IO
Imports ICSharpCode.SharpZipLib.Core
Imports ICSharpCode.SharpZipLib.Zip

Imports CrystalDecisions.Shared
Imports CrystalDecisions.CrystalReports.Engine
Imports H2GEngine.DataCollection
Imports H2GEngine.Extensions

Namespace FileManager
    Public Class FileExport
        Public Enum TypeFile
            [PDF]
            [XLS]
            [HTML]
            [DOC]
            [ZIP]
        End Enum

        Private FileName As String
        Private Directory As String
        Private Extension As String
        Private PaperName As String = "A4"
        Private PrinterName As String = "Microsoft XPS Document Writer"
        Private Landscape As Boolean = False
        Private dcTableSet As New Dictionary(Of String, DataSet)
        Public CrystalDocument As ReportDocument
        Private ListParameter As New List(Of ReportParameter)()
        Public Log As New Logfile("Export Documents", True)

        Public ReadOnly Property Path() As String
            Get
                Return H2G.Path & Directory & FileName & Extension.ToLower()
            End Get
        End Property
        Public ReadOnly Property URL() As String
            Get
                Return Directory.Replace("\", "/") & FileName & Extension.ToLower()
            End Get
        End Property

        Public Sub New(ByVal name As String)
            dcTableSet.Add("MAIN", New DataSet())
            Directory = "Temp\Reports\" & DateTime.Now.Date.ToString("yyyyMMdd") & "\" & H2G.CompanyCode.ToUpper() & "\"
            If (Not IO.Directory.Exists(H2G.Path & Directory)) Then IO.Directory.CreateDirectory(H2G.Path & Directory)
            FileName = name & "__H2G" & Regex.Replace(DateTime.Now.ToString("s"), "(\W+|T)", "")
        End Sub

        Public Sub AddTable(ByVal dtTable As DataTable)
            If (Not String.IsNullOrEmpty(dtTable.TableName) And dtTable.TableName <> "H2G_TableQuery") Then
                dcTableSet.Item("MAIN").Tables.Add(dtTable)
            Else
                Throw New Exception("ExportFile:AddDataTable() Not found tablename.")
            End If
        End Sub

        Public Sub AddTable(ByVal dsTable As DataSet)
            For Each dtTable As DataTable In dsTable.Tables
                If (Not String.IsNullOrEmpty(dtTable.TableName) And dtTable.TableName <> "H2G_TableQuery") Then
                    dcTableSet.Item("MAIN").Tables.Add(dtTable.Copy())
                Else
                    Throw New Exception("ExportFile:AddDataSet() Not found tablename.")
                End If
            Next
        End Sub

        Public Sub AddTable(ByVal subreport As String, ByVal table As DataTable)
            If (Not String.IsNullOrEmpty(table.TableName)) Then
                If (dcTableSet.ContainsKey(subreport)) Then
                    dcTableSet.Item(subreport).Tables.Add(table)
                Else
                    dcTableSet.Add(subreport, New DataSet())
                    dcTableSet.Item(subreport).Tables.Add(table)
                End If
            Else
                Throw New Exception("ExportFile:AddTable() Not found tablename.")
            End If
        End Sub

        Public Function IsTableNullOrEmpty(Optional ByVal skip As Boolean = False) As Boolean
            Dim result As Boolean = False
            If (dcTableSet.Item("MAIN").Tables.Count() = 0) Then
                result = True
            Else
                For Each table As DataTable In dcTableSet.Item("MAIN").Tables
                    If (table.Rows.Count = 0) Then
                        result = True
                        Exit For
                    End If
                Next
            End If
            Return IIf(skip, False, result)
        End Function

        Public Sub AddFile(ByVal filepath As String)
            If (File.Exists(H2G.Path & filepath)) Then
                ListParameter.Add(New ReportParameter("Filename_" & Regex.Replace(DateTime.Now.ToString("s"), "(\W+|T)", ""), filepath))
            End If
        End Sub

        Public Sub SetParameterIs(ByVal parameter_name As String, ByVal pretext As String, ByVal value As String)
            If (String.IsNullOrEmpty(value)) Then value = "ALL"
            ListParameter.Add(New ReportParameter(parameter_name, pretext.Trim() & " " & value.Trim()))
        End Sub
        Public Sub SetParameterIs(ByVal parameter_name As String, ByVal pretext As String, ByVal value_from As String, ByVal value_to As String)
            Dim value As String = " "
            If (Not String.IsNullOrEmpty(value_from)) Then value &= value_from Else value &= "first day to "
            If (Not String.IsNullOrEmpty(value_from) And Not String.IsNullOrEmpty(value_to)) Then value &= " to "
            If (Not String.IsNullOrEmpty(value_to)) Then value &= value_to Else value &= " to last day"
            If (String.IsNullOrEmpty(value_from) And String.IsNullOrEmpty(value_to)) Then value = " every day"
            ListParameter.Add(New ReportParameter(parameter_name, pretext.Trim() & value))
        End Sub
        Public Sub SetParameter(ByVal name As String, ByVal value As String)
            If (String.IsNullOrEmpty(value)) Then value = ""
            ListParameter.Add(New ReportParameter(name, value))
        End Sub
        Public Sub SetParameter(ByVal name As String, ByVal value As String, ByVal subreport As String)
            If (String.IsNullOrEmpty(value)) Then value = ""
            ListParameter.Add(New ReportParameter(name, value, subreport))
        End Sub

        Public Function CreateFile(ByVal filename As String, ByVal type As TypeFile, ByVal paper As String, ByVal land As Boolean) As String
            PaperName = paper
            Landscape = land
            Return Me.CreateFile(filename, type)
        End Function
        Public Function CreateFile(ByVal type As TypeFile) As String
            Return Me.CreateFile("", type)
        End Function
        Public Function CreateFile(ByVal filename As String, ByVal type As TypeFile) As String
            Try
                Extension = "." & type.ToString.ToLower()

                Select Case type
                    Case TypeFile.PDF, TypeFile.XLS, TypeFile.HTML
                        Dim diskOpts As New DiskFileDestinationOptions()
                        Dim docprint As New System.Drawing.Printing.PrintDocument()
                        CrystalDocument = New ReportDocument()
                        CrystalDocument.Load(H2G.Path & filename)
                        CrystalDocument.SetDataSource(dcTableSet.Item("MAIN"))
                        For Each kTable As String In dcTableSet.Keys
                            If (kTable <> "MAIN") Then CrystalDocument.Subreports(kTable).SetDataSource(dcTableSet.Item(kTable))
                        Next
                        Log.Progress("Crystal Document Report Loaded")

                        For Each param As ReportParameter In ListParameter.ToArray()
                            Try
                                If (String.IsNullOrEmpty(param.SubReport)) Then
                                    CrystalDocument.SetParameterValue(param.Name, param.Value)
                                Else
                                    CrystalDocument.SetParameterValue(param.Name, param.Value, param.SubReport)
                                End If
                            Catch
                                'Throw New Exception("Parameter """ & param.Name & """ in report not found.")
                            End Try
                        Next
                        Log.Progress("Crystal Parameter Report Loaded")
                        diskOpts.DiskFileName = Me.Path
                        CrystalDocument.ExportOptions.DestinationOptions = diskOpts
                        CrystalDocument.ExportOptions.ExportDestinationType = ExportDestinationType.DiskFile
                        Select Case type
                            Case TypeFile.PDF
                                CrystalDocument.ExportOptions.ExportFormatType = ExportFormatType.PortableDocFormat
                                docprint.PrinterSettings.PrinterName = "Microsoft XPS Document Writer"

                                If Regex.Match(filename, "@(.+)($|)(.+)\.rpt").Success Then
                                    Dim Options As Match = Regex.Match(filename, "@(?<PaperName>.+)(\@)(?<PaperLanscape>.+)\.rpt")
                                    CrystalDocument.PrintOptions.PaperOrientation = IIf(Not Landscape, PaperOrientation.Portrait, PaperOrientation.Landscape)

                                    Log.Message("CURRENT: " & CrystalDocument.PrintOptions.PaperSize.ToString())
                                    For i As Integer = 0 To docprint.PrinterSettings.PaperSizes.Count - 1
                                        If docprint.PrinterSettings.PaperSizes(i).PaperName = Options.Groups("PaperName").Value Then
                                            Dim PaperSize As System.Reflection.FieldInfo = docprint.PrinterSettings.PaperSizes(i).GetType().GetField("kind", Reflection.BindingFlags.Instance Or Reflection.BindingFlags.NonPublic)
                                            CrystalDocument.PrintOptions.PaperSize = CInt(PaperSize.GetValue(docprint.PrinterSettings.PaperSizes(i)))
                                            Dim OptionLandscape As Boolean = False
                                            If Boolean.TryParse(Options.Groups("PaperLanscape").Value, OptionLandscape) Then
                                                CrystalDocument.PrintOptions.PaperOrientation = IIf(Not OptionLandscape, PaperOrientation.Portrait, PaperOrientation.Landscape)
                                            End If
                                            Exit For
                                        End If
                                    Next
                                    Log.Message("CHANGE: " & CrystalDocument.PrintOptions.PaperSize.ToString())
                                    Log.Progress("Crystal PaperSizes Initialize")
                                ElseIf Regex.Match(filename, "@\.rpt").Success Then
                                    ' SKIPING SETTING
                                    ' NISSIN PRINTER
                                Else
                                    CrystalDocument.PrintOptions.PaperSource = PaperSource.FormSource
                                    CrystalDocument.PrintOptions.PaperSize = PaperSize.PaperA4
                                    CrystalDocument.PrintOptions.PaperOrientation = IIf(Not Landscape, PaperOrientation.Portrait, PaperOrientation.Landscape)
                                End If

                                CrystalDocument.Export()
                            Case TypeFile.XLS
                                CrystalDocument.ExportOptions.ExportFormatType = ExportFormatType.Excel
                                CrystalDocument.Export()
                            Case TypeFile.HTML
                                CrystalDocument.ExportOptions.ExportFormatType = ExportFormatType.HTML32
                                Dim oStream As IO.MemoryStream = DirectCast(CrystalDocument.ExportToStream(ExportFormatType.HTML32), IO.MemoryStream)
                                Dim oFile As IO.FileStream = IO.File.Create(Me.Path)
                                oStream.WriteTo(oFile)
                                oStream.Close()
                                oFile.Close()
                        End Select
                        Log.Progress("Export file Complated")
                        Log.Write()
                        CrystalDocument.Close()
                        For Each kTable As String In dcTableSet.Keys
                            dcTableSet.Item(kTable).Clear()
                            dcTableSet.Item(kTable).Reset()
                        Next
                    Case TypeFile.ZIP
                        Directory = Regex.Replace(Directory, "\\Reports\\", "\ZIP\")
                        If (Not IO.Directory.Exists(H2G.Path & Directory)) Then IO.Directory.CreateDirectory(H2G.Path & Directory)


                        Dim zip As ZipOutputStream = New ZipOutputStream(File.Create(Me.Path))
                        zip.SetLevel(9)

                        Dim strFile As String = ""
                        Dim abyBuffer(4096) As Byte

                        For Each param As ReportParameter In ListParameter.ToArray()
                            strFile = H2G.Path & param.Value
                            If (File.Exists(strFile)) Then
                                Dim strmFile As FileStream = File.OpenRead(strFile)
                                Dim objZipEntry As ZipEntry = New ZipEntry(IO.Path.GetFileName(strFile))

                                objZipEntry.DateTime = DateTime.Now
                                objZipEntry.Size = strmFile.Length

                                zip.PutNextEntry(objZipEntry)
                                StreamUtils.Copy(strmFile, zip, abyBuffer)
                                strmFile.Close()
                                IO.File.Delete(strFile)
                            End If
                        Next
                        If (IO.Directory.Exists(IO.Path.GetDirectoryName(strFile))) Then IO.Directory.Delete(IO.Path.GetDirectoryName(strFile))
                        zip.Finish()
                        zip.Close()
                End Select
            Catch ex As Exception
                Throw New Exception("Export " & type.ToString() & " File <br>" & ex.Message())
            End Try
            Return Me.URL
        End Function
    End Class
End Namespace
