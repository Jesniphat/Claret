Imports System.IO

Namespace FileManager

    Public Class TypeDocument
        Public Shared Function TableCompanyProfile(ByVal id As String) As DataTable
            Dim param As New SQLCollection()
            If (id Is Nothing) Then param.Add("@id", Nothing) Else param.Add("@id", DbType.String, id)
            Return New DBQuery().QueryTable("document_report_company", "SELECT * FROM company_profile_header WITH (NOLOCK) WHERE ([default]='Y' AND @id IS NULL) OR id = @id", param)
        End Function

        Public Shared Function TableCompanyProfile() As DataTable
            Return TypeDocument.TableCompanyProfile(Nothing)
        End Function

        Public Shared Function TableCompanyProfileTemp(ByVal id As String) As DataTable
            Dim param As New SQLCollection()
            If (id Is Nothing) Then param.Add("@id", Nothing) Else param.Add("@id", DbType.String, id)
            Return New DBQuery().QueryTable("document_report_company", "SELECT * FROM company_profile_header WITH (NOLOCK) WHERE ([default]='N' AND @id IS NULL) OR id = @id", param)
        End Function

        Public Shared Function TableCompanyProfileTemp() As DataTable
            Return TypeDocument.TableCompanyProfileTemp(Nothing)
        End Function

        Public Shared Function DropdownPlatformBlind(ByRef ddl As HtmlControls.HtmlSelect, ByVal group_document As String, ByVal type_document As String) As Integer
            Dim OnlistID As Integer = 1
            Dim OnFlagRemove As Boolean = False
            Dim ReportViewerPath As String = H2G.Path & IIf(H2G.DEBUG, "..\..\TravoxViewer\TravoxViewer\", "..\report_viewer\") & "#Documents\" & H2G.CompanyCode & "\"
            If (Not Directory.Exists(ReportViewerPath)) Then Throw New Exception("Please insert crytalReport file.")
            ddl.Items.Clear()

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
                            ddl.Items.Add(New ListItem(Value, DDLRename))
                            OnlistID += 1
                        Next
                    End If
                End If
            Next

            REM SORT HTML DropDown List
            If (ddl.Items.Count > 1) Then
                Dim ComparerNormal As New DropDownSortNormal()
                Dim ArrItems(ddl.Items.Count - 1) As ArrayDropdown
                For i As Integer = 0 To ddl.Items.Count - 1
                    Dim item As ArrayDropdown
                    Dim idValue As Match = Regex.Match(ddl.Items(i).Value, "(\d)!")
                    item.ID = IIf(idValue.Success, idValue.Groups(1).Value, 0)
                    item.Text = ddl.Items(i).Text
                    item.Value = ddl.Items(i).Value
                    ArrItems(i) = item
                Next
                Array.Sort(ArrItems, ComparerNormal)
                ddl.Items.Clear()
                For i As Integer = 0 To ArrItems.Length - 1
                    ddl.Items.Add(New ListItem(ArrItems(i).Text, ArrItems(i).Value))
                Next
            End If
            Return IIf(ddl.Items.Count = 1, True, False)
        End Function
        Public Shared Function DropdownPlatformBlind(ByRef ddl As DropDownList, ByVal group_document As String, ByVal type_document As String) As Integer
            Dim ddl2 As New HtmlControls.HtmlSelect()
            Dim count As Boolean = TypeDocument.DropdownPlatformBlind(ddl2, group_document, type_document)
            ddl.Items.Clear()
            For Each options As ListItem In ddl2.Items
                ddl.Items.Add(options)
            Next
            Return count
        End Function

        Public Shared Function DefaultCustomerEmail(ByVal invoice_no_or_receipt_no As String, ByVal type As String) As String
            Dim param As New SQLCollection("@no", DbType.String, invoice_no_or_receipt_no)
            param.Add("@doc", DbType.String, type)
            Return New DBQuery().QueryField(My.Resources.DefaultCustomerEmail, param)
        End Function
        Public Shared Function DefaultCustomerSMS(ByVal invoice_no As String) As String
            Return New DBQuery().QueryField(My.Resources.DefaultCustomerSMS, New SQLCollection("@no", DbType.String, invoice_no))
        End Function

        Public Shared Function ListCustomerByInvoice() As DataTable
            Return New DBQuery().QueryTable("SELECT c.name, c.id FROM (SELECT DISTINCT customer_id FROM invoice WHERE status NOT IN('VOID')) i INNER JOIN customer c ON i.customer_id = c.id WHERE status IN('ACTIVE') ORDER BY c.name")
        End Function
    End Class

    Friend Structure ArrayDropdown
        Public ID As String
        Public Text As String
        Public Value As String
    End Structure
    Public Class DropDownSortReverse : Implements IComparer
        Function Compare(ByVal x As Object, ByVal y As Object) As Integer Implements IComparer.Compare
            Return New CaseInsensitiveComparer().Compare(y.ID, x.ID)
        End Function
    End Class
    Public Class DropDownSortNormal : Implements IComparer
        Function Compare(ByVal x As Object, ByVal y As Object) As Integer Implements IComparer.Compare
            Return New CaseInsensitiveComparer().Compare(x.ID, y.ID)
        End Function
    End Class

End Namespace
