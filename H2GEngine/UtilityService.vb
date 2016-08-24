Imports System.IO
Imports Microsoft.Office.Interop
Imports Newtonsoft.Json
Imports System.Net

Partial Public Class H2G
    'Inherits UI.Page

    Public Shared Function GenMailMerge(ByVal _Code As String, ByVal _Data As String) As OBJResponse
        Dim _Result As New OBJResponse
        _Result.FileName = "ERROR"
        _Result.Print = "N"
        Dim dt As New DataTable
        Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
        Dim sql As String = "select code, file_name, path, path_des, auto_print, path_client from mailmerge where code = '" & _Code & "'"
        dt = Cbase.QueryTable(sql)

        If dt.Rows.Count <> 0 Then

            Dim _FileName As String = dt.Rows(0)("file_name").ToString
            Dim _Path As String = dt.Rows(0)("path").ToString
            Dim _PathDes As String = dt.Rows(0)("path_des").ToString
            Dim _PathClient As String = dt.Rows(0)("path_client").ToString
            Dim _AutoPrint As String = dt.Rows(0)("auto_print").ToString

            '_Data = "[{" + """Numero Donneur"":""1869900078" + """," + """fname"":""ประทีป" + """," + """lname"":""อยู่สถิตย์" + """}" + "" + "]"
            '_Data = "[{""Point_de_collecte"":""0A0000"",""Date"":""18 August 2016"",""Heure"":""13h27"",""Numero_Donneur"":""9995900003"",""Sexe"":""นาย"",""Nom"":""สิทธิชัย"",""Nom_Marital"":"""",""Date_de_Naissance"":""27/01/1985"",""Prénom"":""แหบยา"",""Adresse"":""59/5 sdfsf ปากเพรียว เมือง สระบุรี"",""Code_Postal"":""18000"",""Ville"":"""",""Code_Routage"":"""",""Région"":"""",""Département"":"""",""Communauté_Urbaine"":"""",""Téléphone_Domicile"":"""",""Téléphone_Bureau"":"""",""Poste"":"""",""Groupe_Sanguin"":""O Rh+"",""Phénotype"":"""",""Médecin_traitant"":"""",""Secrétaire"":""Dhanakoses, Preawnet"",""Profession"":""เอกชน"",""Catégorie"":"""",""Entreprise"":"""",""Poids"":""60"",""Taille"":"""",""Libelle_collecte"":""COLLECTION_POINT_TEST"",""CIDS"":"" "",""Total_dons"":""4"",""Current_dons"":""5"",""Dons_ext"":"""",""Date_dernier_don"":"""",""Type_dernier_don"":""Whole blood, CPD-A1 TB-450"",""TA_dernier_don"":"""",""Numero_Donneur_code_128"":""9995900003"",""Histo_dons_1"":"""",""Histo_dons_2"":"""",""Histo_dons_3"":"""",""Histo_dons_4"":"""",""Histo_dons_5"":"""",""Histo dons 6"":"""",""Histo dons 7"":"""",""Histo dons 8"":"""",""Histo dons 9"":"""",""Histo dons 10"":"""",""Code_Pays_Naiss"":"""",""Nom_Pays_Naiss"":"""",""Code_Depart_Naiss"":"""",""Nom_Depart_Naiss"":"""",""Ville_Naiss"":""TEST"",""Nom_Pere"":""Preawnet"",""Nom_Mere"":""Dhanakoses"",""Code_Genre"":""M"",""Nom_Genre"":""Male"",""Adresse_Compl"":""59/5 sdfsf"",""Identifiant_1"":""1101400167938"",""Identifiant_2"":""901070904"",""Cplt_Code_0"":"""",""Cplt_Nom_Code_0"":"""",""Cplt_Code_1"":"""",""Cplt_Nom_Code_1"":"""",""Cplt_Code_2"":"""",""Cplt_Nom_Code_2"":"""",""Cplt_Code_3"":"""",""Cplt_Nom_Code_3"":"""",""Cplt_Code_4"":"""",""Cplt_Nom_Code_4"":"""",""Cplt_Code_5"":"""",""Cplt_Nom_Code_5"":"""",""Cplt_Code_6"":"""",""Cplt_Nom_Code_6"":"""",""Cplt_Code_7"":"""",""Cplt_Nom_Code_7"":"""",""Cplt Code 8"":"""",""Cplt Nom Code 8"":"""",""Cplt Code 9"":"""",""Cplt Nom Code 9"":"""",""Cplt Valeur 0"":"""",""Cplt Valeur 1"":"""",""Cplt Valeur 2"":"""",""Cplt Valeur 3"":"""",""Cplt Valeur 4"":"""",""Cplt Valeur 5"":"""",""Cplt Valeur 6"":"""",""Cplt Valeur 7"":"""",""Cplt Valeur 8"":"""",""Cplt Valeur 9"":"""",""AGD"":"" Rh+"",""DATED"":""05/05/2016"",""GR"":""O"",""IM"":"" "",""NOTES"":"" "",""TITLE"":""นาย"",""TITRE"":""นาย""}]"

            Dim dttable As DataTable = JsonConvert.DeserializeObject(Of DataTable)(_Data)

            Dim _Name As String = Now().ToString("yyyymmddHHMMsss") & "_" & CInt(Math.Ceiling(Rnd() * 1000)) + 1

            File.Copy(_Path & _FileName, _PathDes & _Name & ".doc")

            Dim sTemplateFileName As String = _Name & ".doc"

            Dim moApp As New Word.Application()
            Dim sDocFileName As String = ""
            If IsNothing(moApp) = False Then
                moApp.Visible = False

                For Each row As DataRow In dttable.Rows
                    moApp.Documents.Open(System.IO.Path.Combine(_PathDes, sTemplateFileName))
                    sDocFileName = _Name & ".pdf"
                    Dim intCount As Integer = 0

                    For Each MergeField As Word.MailMergeField In moApp.ActiveDocument.MailMerge.Fields
                        MergeField.Select()
                        Dim _ColumnName As String = moApp.Selection.Range.Text
                        If _ColumnName IsNot Nothing Then
                            _ColumnName = _ColumnName.Replace("«", "")
                            _ColumnName = _ColumnName.Replace("»", "")

                            If row.Table.Columns.Contains(_ColumnName) Then
                                moApp.Selection.TypeText(row(_ColumnName).ToString())
                            End If
                        End If
                        'intCount += 1
                    Next

                    moApp.ActiveDocument.SaveAs(System.IO.Path.Combine(_PathDes, sDocFileName), Word.WdSaveFormat.wdFormatPDF)
                    moApp.Documents.Close(Word.WdSaveOptions.wdDoNotSaveChanges)
                Next
                moApp.Quit(False)
            End If
            moApp = Nothing
            dttable.Dispose()
            dttable = Nothing
            File.Delete(_PathDes & _Name & ".doc")
            _Result.FileName = _PathClient & sDocFileName
            _Result.Print = _AutoPrint

            'HttpRequest
            If _AutoPrint = "Y" Then
                RequestHttpServiceExpedia(_Result.FileName) ' "http://localhost:9091/print?path=C:\mailmerge\tmp\20164219010809_707.doc"
            End If

        Else
            _Result.FileName = "ERROR"
            _Result.Print = "N"
        End If
        '
        Return _Result

    End Function

    Private Shared Function RequestHttpServiceExpedia(ByVal sEndpoint As String) As String
        sEndpoint = "http://localhost:9091/print?path=" & sEndpoint
        Dim sUri As Uri = New Uri(sEndpoint)
        Dim responseFromServer As String = ""
        Dim request As HttpWebRequest = HttpWebRequest.Create(sUri)
        Try
            request.Method = "GET"
            request.ContentType = "application/json; charset=utf-8"
            'request.Headers.Add("Accept-Encoding", "gzip, deflate")
            request.KeepAlive = True
            request.Timeout = 20000

            'If action = "Booking_RQ" Then Throw New Exception("Operation time out.")

            Dim response As HttpWebResponse
            response = CType(request.GetResponse, HttpWebResponse)
            Dim stream As Stream
            stream = response.GetResponseStream()

            Dim sr As System.IO.StreamReader = New System.IO.StreamReader(stream)
            responseFromServer = sr.ReadToEnd
            sr.Close()
            stream.Close()
            response.Close()
        Catch ex As Exception
            Throw ex
        End Try
        Return responseFromServer
    End Function


    Public Structure OBJResponse
        Public FileName As String
        Public Print As String
    End Structure
End Class
