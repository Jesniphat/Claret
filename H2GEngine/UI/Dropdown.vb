Imports System.IO
Imports H2GEngine.FileManager
Namespace UI
    Public Class Dropdown
        Inherits UI.Page

        Public TextValue As String
        Protected TitleItems As New List(Of DropdownItem)
        Private param As New ParameterCollection
        Private SQL As String
        Private ModifyItems As Boolean = True

        Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            TextValue = _REQUEST("values")
            If (TextValue.Trim().Length = 0) Then TextValue = TextValue.Trim()
            SQL = _REQUEST("sql").Trim()
            param.Add("@search", DbType.String, "%" & TextValue & "%")
            param.Add("@search2", DbType.String, _REQUEST("values2"))
            param.Add("@start", DbType.Int32, _REQUEST("s").Trim())
            param.Add("@finish", DbType.Int32, _REQUEST("f").Trim())
        End Sub

        Protected Function DropdownQuery(ByVal TitleColumn As String) As DataTable
            Return DropdownQuery(SQL, TitleColumn, TitleColumn, "")
        End Function

        Protected Function DropdownQuery(ByVal TitleColumn As String, ByVal OrderColumn As String) As DataTable
            Return DropdownQuery(SQL, TitleColumn, OrderColumn, "")
        End Function

        Protected Function DropdownQuery(ByVal QueryString As String, ByVal TitleColumn As String, ByVal OrderColumn As String, ByVal parameter As String) As DataTable
            param.Add("_PARAM_", DbType.String, parameter)
            QueryString = H2G.FileRead("!SQLStore\" & QueryString.Replace("SQL::", "") & ".sql")
            QueryString = My.Resources.SELECT_UI_AutoComplate.Replace("/*_SQL_QUERY_*/", QueryString).Replace("/*_NAME_*/", OrderColumn)
            Dim database As New DBQuery()
            Dim dt As DataTable = database.QueryTable(QueryString, param)
            For Each dr As DataRow In dt.Rows
                Dim item As New DropdownItem
                item.Title = dr(TitleColumn)
                TitleItems.Add(item)
            Next
            Return dt
        End Function

        Protected Function Serialize(Of T)(ByVal v As T) As String
            Return "[" & JSON.Serialize(Of List(Of DropdownItem))(TitleItems) & "," & JSON.Serialize(Of T)(v) & "]"
        End Function
        Protected Function Serialize() As String
            Return "[" & JSON.Serialize(Of List(Of DropdownItem))(TitleItems) & "]"
        End Function

        Protected Sub SetItemTitle(ByVal title As String)
            If (ModifyItems) Then TitleItems = New List(Of DropdownItem)
            Dim item As New DropdownItem
            item.Title = title
            TitleItems.Add(item)
            ModifyItems = False
        End Sub

        Protected Function DropdownPlatform(ByVal group_document As String, ByVal type_document As String) As Integer
            Dim OnlistID As Integer = 1
            Dim OnFlagRemove As Boolean = False
            Dim ReportViewerPath As String = H2G.Path & IIf(H2G.DEBUG, "..\..\MBOSViewer\", "..\report_viewer\") & "#Documents\" & H2G.CompanyCode & "\"
            If (Not Directory.Exists(ReportViewerPath)) Then Throw New Exception("Please insert crytalReport file.")

            'REM CHECK FILE
            If (group_document = "V") Then
                For Each filepath As String In Directory.GetFiles(ReportViewerPath)
                    If (Regex.Match(filepath, "\\\w\$(\w+|)_(.+)?\.").Groups(1).Value = group_document + type_document) Then OnFlagRemove = True
                Next
            End If

            REM BIND DROPDOWN LIST 
            For Each filepath As String In Directory.GetFiles(ReportViewerPath)
                Dim DOC As Match = Regex.Match(filepath, "\\\w\$(\w+|)_(.+)?\.")
                If (DOC.Success) Then
                    If (DOC.Groups(1).Value = group_document + type_document Or (DOC.Groups(1).Value = group_document And Not OnFlagRemove)) Then
                        For Each name As Match In Regex.Matches(DOC.Groups(2).Value, "\[(.+?)\]")
                            Dim RelistID As Match = Regex.Match(name.Groups(0).Value, "(\d)-(.+)\]")
                            Dim Value As String = IIf(RelistID.Success, RelistID.Groups(2).Value, name.Groups(1).Value)
                            Dim DDLRename As String = IIf(RelistID.Success, RelistID.Groups(1).Value, OnlistID) & "!" & Path.GetFileName(filepath)
                            Dim item As New DropdownItem
                            item.Title = DDLRename
                            item.Value = Value
                            TitleItems.Add(item)
                            OnlistID += 1
                        Next
                    End If
                End If
            Next

            REM SORT HTML DropDown List
            If (TitleItems.Count > 1) Then
                Dim ComparerNormal As New DropDownSortNormal
                Dim ArrItems(TitleItems.Count) As ArrayDropdown
                For i As Integer = 0 To TitleItems.Count - 1
                    Dim item As ArrayDropdown
                    Dim idValue As Match = Regex.Match(TitleItems(i).Value, "(\d)!")
                    item.ID = IIf(idValue.Success, idValue.Groups(1).Value, 0)
                    item.Text = TitleItems(i).Title
                    item.Value = TitleItems(i).Value
                    ArrItems(i) = item
                Next
                Array.Sort(ArrItems, ComparerNormal)
                TitleItems = New List(Of DropdownItem)
                For i As Integer = 0 To ArrItems.Length - 1
                    Dim item As New DropdownItem
                    item.Title = ArrItems(i).Text
                    item.Value = ArrItems(i).Value
                    TitleItems.Add(item)
                Next
            End If
            Return IIf(TitleItems.Count = 1, True, False)
        End Function

        Public Structure DropdownItem
            Public Title As String
            Public Value As String
        End Structure
    End Class
End Namespace
