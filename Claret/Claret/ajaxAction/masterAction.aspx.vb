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
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(countryList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(countryList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(countryList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
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
                    JSONResponse.setItems(Of List(Of LabHospitalItem))(DataList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(DataList)
                Case "lab"
                    Dim DataList As New List(Of KeyCodeIDItem)
                    Dim DataItem As KeyCodeIDItem
                    Dim sql As String = "select id, trim(code) as code, description from lab ORDER BY code "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeIDItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("code").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Hospital has no record"))
                    End If
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(DataList)
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
                Case "reason"
                    Dim DataList As New List(Of KeyCodeIDItem)
                    Dim DataItem As KeyCodeIDItem
                    Dim sql As String = "select id, description from REASON where used_module = 'TEST REQUEST REASON' order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeIDItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Reason has no record"))
                    End If
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(DataList)
                Case "donationto"
                    Dim DataList As New List(Of KeyCodeIDItem)
                    Dim DataItem As KeyCodeIDItem
                    Dim sql As String = "select id, description from DONATION_TO where used_module like '%H,%' order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeIDItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)

                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Donation To has no record"))
                    End If
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(DataList)
                Case "staff"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, code, code || ' - ' || firstname || ' ' || lastname as name from staff order by code || ' - ' || firstname || ' ' || lastname "
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
                    JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
                Case "deferral"
                    Dim DataList As New List(Of DeferralItem)
                    Dim DataItem As DeferralItem
                    Dim sql As String = "select DEF.ID, DEF.CODE, DEF.DESCRIPTION, nvl(DED.DURATION,'') as DURATION, DED.DONATION_TYPE_ID
                                        , DED.DEFERRAL_TYPE, DEF.CODE || ' : ' || DEF.DESCRIPTION as text
                                        from DEFERRAL def
                                        inner join DEFERRAL_DETAIL ded on ded.DEFERRAL_ID = DEF.id
                                        where GENDER = '" & _REQUEST("gender") & "' "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New DeferralItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("CODE").ToString()
                            DataItem.desc = dr("DESCRIPTION").ToString()
                            DataItem.duration = dr("DURATION").ToString()
                            DataItem.donationID = dr("DONATION_TYPE_ID").ToString()
                            DataItem.deferralType = dr("DEFERRAL_TYPE").ToString()
                            DataItem.text = dr("text").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Staff has no record"))
                    End If
                    JSONResponse.setItems(Of List(Of DeferralItem))(DataList)
                Case "donationtype"
                    Dim DataList As New List(Of KeyCodeIDItem)
                    Dim DataItem As KeyCodeIDItem
                    Dim sql As String = "select id, description from DONATION_TYPE order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeIDItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)

                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Donation To has no record"))
                    End If
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(DataList)
                Case "bag"
                    Dim DataList As New List(Of KeyCodeIDItem)
                    Dim DataItem As KeyCodeIDItem
                    Dim sql As String = "select id, description from bag order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeIDItem
                            DataItem.valueID = dr("id").ToString()
                            DataItem.value = dr("id").ToString()
                            DataItem.text = dr("description").ToString()
                            DataList.Add(DataItem)

                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Donation To has no record"))
                    End If
                    JSONResponse.setItems(Of List(Of KeyCodeIDItem))(DataList)
                Case "questionnaire"
                    Dim QuestionnaireItem As New QuestionnaireItem
                    QuestionnaireItem.QuestionItem = New List(Of QuestionItem)
                    QuestionnaireItem.AnswerItem = New List(Of AnswerItem)
                    Dim sql As String = "select qq.id, qq.code, qq.description, qq.required, qq.answer_type 
                                        , wmsys.wm_concat(qa.code) as preset, qq.description_th
                                        from QUESTIONNAIRE_QUESTION qq
                                        LEFT JOIN QUESTIONNAIRE_ANSWER qa on qa.QUESTIONNAIRE_QUESTION_ID = qq.id
                                        GROUP BY qq.id, qq.code, qq.description, qq.required, qq.answer_type, qq.description_th 
                                        order by qq.code"
                    Dim dt As DataTable = Cbase.QueryTable(sql)
                    If dt.Rows.Count > 0 Then
                        Dim QuestItem = New QuestionItem
                        For Each dr As DataRow In dt.Rows()
                            QuestItem.QuestionID = dr("id").ToString()
                            QuestItem.Code = dr("code").ToString()
                            QuestItem.Description = dr("description").ToString()
                            QuestItem.DescriptionTH = dr("description_th").ToString()
                            QuestItem.Required = dr("required").ToString()
                            QuestItem.AnswerType = dr("answer_type").ToString()
                            QuestItem.Preset = dr("preset").ToString()
                            QuestionnaireItem.QuestionItem.Add(QuestItem)

                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("QUESTIONNAIRE has no record"))
                    End If

                    sql = "select qa.id, qa.questionnaire_question_id, qa.code, qa.description
                            , qa.flag_next_question, qa.flag_deferral, qa.flag_examination 
                            , wmsys.wm_concat(qaq.questionnaire_question_id) as to_quest_id
                            , wmsys.wm_concat(qad.deferral_id) as deferral_id
                            , wmsys.wm_concat(exa.code) as examination_id
                            , wmsys.wm_concat(exg.code) as group_examination_id
                            from QUESTIONNAIRE_ANSWER qa
                            left join QUEST_ANSWER_QUESTION qaq on qaq.QUESTIONNAIRE_ANSWER_ID = QA.id
                            left join QUEST_ANSWER_DEFERRAL qad on qad.QUESTIONNAIRE_ANSWER_ID = QA.id
                            left join QUEST_ANSWER_EXAMINATION qae on qae.QUESTIONNAIRE_ANSWER_ID = qa.id
                            left join EXAMINATION exa on exa.id = qae.examination_id
                            left join EXAMINATION_GROUP exg on exg.id = qae.examination_group_id
                            GROUP BY qa.id, qa.questionnaire_question_id, qa.code, qa.description
                            , qa.flag_next_question, qa.flag_deferral, qa.flag_examination  "

                    dt = Cbase.QueryTable(sql)
                    If dt.Rows.Count > 0 Then
                        Dim AnsItem = New AnswerItem
                        For Each dr As DataRow In dt.Rows()
                            AnsItem = New AnswerItem
                            AnsItem.AnswerID = dr("id").ToString()
                            AnsItem.QuestionID = dr("questionnaire_question_id").ToString()
                            AnsItem.Code = dr("code").ToString()
                            AnsItem.Description = dr("description").ToString()
                            AnsItem.ToQuestID = dr("to_quest_id").ToString()
                            AnsItem.DeferralID = dr("deferral_id").ToString()
                            AnsItem.ExamID = dr("examination_id").ToString()
                            AnsItem.GroupExamID = dr("group_examination_id").ToString()
                            QuestionnaireItem.AnswerItem.Add(AnsItem)

                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Answer has no record"))
                    End If

                    JSONResponse.setItems(Of QuestionnaireItem)(QuestionnaireItem)
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

Public Structure DeferralItem
    Public value As String
    Public text As String
    Public valueID As String
    Public desc As String
    Public duration As String
    Public donationID As String
    Public deferralType As String
End Structure


Public Structure QuestionnaireItem
    Public QuestionItem As List(Of QuestionItem)
    Public AnswerItem As List(Of AnswerItem)
End Structure

Public Structure QuestionItem
    Public QuestionID As String
    Public Code As String
    Public Description As String
    Public DescriptionTH As String
    Public Required As String
    Public AnswerType As String
    Public Preset As String
End Structure

Public Structure AnswerItem
    Public AnswerID As String
    Public QuestionID As String
    Public Code As String
    Public Description As String
    Public ToQuestID As String
    Public DeferralID As String
    Public ExamID As String
    Public GroupExamID As String
End Structure

