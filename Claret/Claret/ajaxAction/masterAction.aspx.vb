Imports H2GEngine
Public Class masterAction
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'Call H2G.setMasterData(Me.Page)
        Try
            Response.Write(Action())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try

    End Sub

    Private Function Action()
        Dim JSONResponse As New CallbackException()
        Dim param As New SQLCollection()
        Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
        Try
            Select Case _REQUEST("action")
                Case "site"
                    Dim countryList As New List(Of KeyCodeIDItem)
                    Dim CountryItem As KeyCodeIDItem
                    Dim dt As DataTable = Cbase.QueryTable("select id, code, name from site where 1=1 order by name ")

                    For Each dr As DataRow In dt.Rows()
                        CountryItem = New KeyCodeIDItem
                        CountryItem.valueid = dr("id").ToString()
                        CountryItem.value = dr("code").ToString()
                        CountryItem.text = dr("name").ToString()
                        countryList.Add(CountryItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeIDItem))(countryList))
                Case "collection"
                    Dim countryList As New List(Of KeyCodeIDItem)
                    Dim CountryItem As KeyCodeIDItem
                    Dim dt As DataTable = Cbase.QueryTable("select id, code, name from collection_point order by name ")

                    For Each dr As DataRow In dt.Rows()
                        CountryItem = New KeyCodeIDItem
                        CountryItem.valueID = dr("id").ToString()
                        CountryItem.value = dr("code").ToString()
                        CountryItem.text = dr("name").ToString()
                        countryList.Add(CountryItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeIDItem))(countryList))
                Case "country"
                    Dim countryList As New List(Of KeyCodeItem)
                    Dim CountryItem As KeyCodeItem
                    If Not String.IsNullOrEmpty(_REQUEST("countryid")) Then param.Add("#id", "and id = '" & _REQUEST("countryid") & "'")
                    If Not String.IsNullOrEmpty(_REQUEST("countryCode")) Then param.Add("#id", "and h2g_code = '" & _REQUEST("countryCode") & "'")
                    If Not String.IsNullOrEmpty(_REQUEST("countryName")) Then param.Add("#id", "and description = '" & _REQUEST("countryName") & "'")
                    Dim dt As DataTable = Cbase.QueryTable("select id, hiig_code, description from country where 1=1 /*#id*/ /*#code*/ /*#name*/ order by description ")

                    For Each dr As DataRow In dt.Rows()
                        CountryItem = New KeyCodeItem
                        CountryItem.value = dr("id").ToString()
                        CountryItem.text = dr("description").ToString()
                        countryList.Add(CountryItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(countryList))
                Case "externalcard"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim dt As DataTable = Cbase.QueryTable("select id, hiig_code, description, card_type from external_card where 1=1 order by description ")

                    For Each dr As DataRow In dt.Rows()
                        DataItem = New KeyCodeItem
                        DataItem.value = dr("id").ToString()
                        DataItem.text = dr("description").ToString()
                        'DataItem.cardType = dr("card_type").ToString()
                        DataList.Add(DataItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "titlename"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, hiig_code, title_m as title_name from title where title_m is not null order by title_m"
                    If _REQUEST("gender") = "F" Then sql = "select id, hiig_code, title_f as title_name from title where title_m is not null order by title_f"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    For Each dr As DataRow In dt.Rows()
                        DataItem = New KeyCodeItem
                        DataItem.value = dr("id").ToString()
                        DataItem.text = dr("title_name").ToString()
                        DataList.Add(DataItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "occupation"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, hiig_code, description from occupation order by description"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    For Each dr As DataRow In dt.Rows()
                        DataItem = New KeyCodeItem
                        DataItem.value = dr("id").ToString()
                        DataItem.text = dr("description").ToString()
                        DataList.Add(DataItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "nationality"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, description from nationality order by description"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Nationality has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "association"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, code, code || ' ' || name as name from association where name is not null order by name"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("name").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Association has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "hospital"
                    Dim DataList As New List(Of LabHospitalItem)
                    Dim DataItem As LabHospitalItem
                    Dim sql As String = "select hpt.id, trim(hpt.code) as code, hpt.name, wmsys.wm_concat(hdpm.department_id) as department_id
                                        from hospital hpt 
                                        left join HOSPITAL_DEPARTMENT hdpm on hdpm.hospital_id = hpt.id
                                        GROUP BY hpt.id, trim(hpt.code), hpt.name
                                        ORDER BY hpt.name "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New LabHospitalItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("code").ToString()
                            DataItem.text = dr("name").ToString()
                            DataItem.departmentID = "," & dr("department_id").ToString() & ","
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Hospital has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of LabHospitalItem))(DataList))
                Case "department"
                    Dim DataList As New List(Of KeyCodeIDItem)
                    Dim DataItem As KeyCodeIDItem
                    Dim sql As String = "select dep.id, trim(dep.code) as code, dep.name 
                                        from department dep
                                        ORDER BY dep.name "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeIDItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("code").ToString()
                            DataItem.text = dr("name").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Department has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeIDItem))(DataList))
                Case "lab"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, trim(code) as code, description from lab ORDER BY code "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.value = dr("code").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Hospital has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "examination"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select * from (
                                            select trim(code) as code, trim(code) || ' : ' || description as description, 'E' as exam_type from EXAMINATION 
                                            union ALL
                                            select trim(code) as code, trim(code) || ' : ' || description as description, 'G' as exam_type from EXAMINATION_GROUP 
                                         ) dn order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.value = dr("code").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Examination has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "reason"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, description from REASON where used_module = 'TEST REQUEST REASON' order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Reason has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "donationto"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, description from DONATION_TO where used_module like '%H,%' order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)

                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Donation To has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "staff"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, code, code || ' - ' || name || ' ' || surname as name from staff order by code || ' - ' || name || ' ' || surname "
                    Dim dt As DataTable = Cbase.QueryTable(sql)


                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("name").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Staff has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
            End Select

        Catch ex As Exception
            Throw ex
        End Try
        Return JSONResponse.ToJSON()
    End Function
End Class

Public Structure KeyCodeItem
    Public value As String
    Public text As String

End Structure

Public Structure KeyCodeIDItem
    Public value As String
    Public text As String
    Public valueID As String

End Structure

Public Structure LabHospitalItem
    Public value As String
    Public text As String
    Public valueID As String
    Public departmentID As String

End Structure


