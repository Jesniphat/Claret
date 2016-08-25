Imports H2GEngine
Public Class masterAction
    Inherits UI.Page 'System.Web.UI.Page

    Dim JSONResponse As New CallbackException()
    Dim param As New SQLCollection()
    Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
    Dim Hbase As New oraDBQuery(oraDBQuery.Schema.HEMATOS)
    Dim sqlMain As String = ""

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Try
            Response.Write(Action())
        Catch ex As Exception
            Cbase.Rollback()
            JSONResponse = New CallbackException(ex)
            Response.Write(JSONResponse.ToJSON())
        Finally
            Cbase.Apply()
        End Try
    End Sub

    Private Function Action() As String
        Select Case _REQUEST("action")
            Case "site" : JSONResponse.setItems(Of List(Of KeyCodeIDItem))(Me.getSite())
            Case "collection" : JSONResponse.setItems(Of List(Of KeyCodeIDItem))(Me.getCollection())
            Case "country" : JSONResponse.setItems(Of List(Of KeyCodeItem))(Me.getCountry())
            Case "externalcard" : getExternalCard()
            Case "titlename" : JSONResponse.setItems(Of List(Of KeyCodeItem))(getTitleName())
            Case "occupation" : JSONResponse.setItems(Of List(Of KeyCodeItem))(getOccupation())
            Case "nationality" : JSONResponse.setItems(Of List(Of KeyCodeItem))(getNationality())
            Case "association" : JSONResponse.setItems(Of List(Of KeyCodeIDItem))(getAssociation())
            Case "hospital" : getHospital()
            Case "department" : getDepartment()
            Case "lab" : getLab()
            Case "examination" : getExamination()
            Case "reason" : getReason()
            Case "donationto" : getDonationto()
            Case "staff" : getStaff()
            Case "deferral" : getDeferral()
            Case "donationtype" : getDonationType()
            Case "donationtype2" : getDonationType2()
            Case "bag" : getBag()
            Case "questionnaire" : getQuestionnaire()
            Case "forcollection" : JSONResponse.setItems(Of List(Of KeyCodeIDItem))(getForCollection())
            Case "getdonatebagtypelist" : GetDonateBagTypeList()
            Case "getdonateapplylist" : GetDonateApplyList()
            Case "logincontent" : JSONResponse.setItems(Of LoginContent)(Me.getLoginContent())
            Case "registercontent" : JSONResponse.setItems(Of RegisterContent)(Me.getRegisterContent())
            Case Else
                Dim exMsg As String = IIf(String.IsNullOrEmpty(_REQUEST("action")), "", _REQUEST("action"))
                Throw New Exception("Not found action [" & exMsg & "].", New Exception("Please check your action name"))
        End Select

        Return JSONResponse.ToJSON()
    End Function

    Private Function getLoginContent() As LoginContent
        Dim LoginContent As New LoginContent
        LoginContent.SiteList = getSite()
        LoginContent.CollectionList = getCollection()
        Return LoginContent
    End Function
    Private Function getRegisterContent() As RegisterContent
        Dim regCon As New RegisterContent
        regCon.AssoList = getAssociation()
        regCon.CollectionList = getForCollection()
        regCon.CountryList = getCountry()
        regCon.NationList = getNationality()
        regCon.OccupationList = getOccupation()
        regCon.TitleList = getTitleName()
        Return regCon
    End Function
    Private Function getSite() As List(Of KeyCodeIDItem)
        Dim countryList As New List(Of KeyCodeIDItem)
        Dim CountryItem As KeyCodeIDItem
        Dim dt As DataTable = Cbase.QueryTable("select id, code, name from site order by name ")

        For Each dr As DataRow In dt.Rows()
            CountryItem = New KeyCodeIDItem
            CountryItem.valueID = dr("id").ToString()
            CountryItem.value = dr("code").ToString()
            CountryItem.text = dr("name").ToString()
            countryList.Add(CountryItem)
        Next
        'JSONResponse.setItems(Of List(Of KeyCodeIDItem))(countryList)
        Return countryList
    End Function
    Private Function getCollection() As List(Of KeyCodeIDItem)
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
        'JSONResponse.setItems(Of List(Of KeyCodeIDItem))(countryList)
        Return countryList
    End Function
    Private Function getCountry() As List(Of KeyCodeItem)
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
        'JSONResponse.setItems(Of List(Of KeyCodeItem))(countryList)
        Return countryList
    End Function
    Private Sub getExternalCard()
        Dim DataList As New List(Of ExternalCardItem)
        Dim DataItem As ExternalCardItem
        Dim dt As DataTable = Cbase.QueryTable("select id, hiig_code, description, card_type, min_digit, max_digit 
                                                from external_card where 1=1 order by description ")

        For Each dr As DataRow In dt.Rows()
            DataItem = New ExternalCardItem
            DataItem.value = dr("id").ToString()
            DataItem.text = dr("description").ToString()
            DataItem.valueID = dr("id").ToString()
            DataItem.minLength = dr("min_digit").ToString()
            DataItem.maxLength = dr("max_digit").ToString()
            DataList.Add(DataItem)
        Next
        JSONResponse.setItems(Of List(Of ExternalCardItem))(DataList)
    End Sub
    Private Function getTitleName() As List(Of KeyCodeItem)
        Dim DataList As New List(Of KeyCodeItem)
        Dim DataItem As KeyCodeItem
        Dim sql As String = "select id, hiig_code, title_m as title_name from title where title_m is not null order by title_m"
        If _REQUEST("gender") = "F" Then sql = "select id, hiig_code, title_f as title_name from title where title_f is not null order by title_f"
        Dim dt As DataTable = Cbase.QueryTable(sql)

        For Each dr As DataRow In dt.Rows()
            DataItem = New KeyCodeItem
            DataItem.value = dr("id").ToString()
            DataItem.text = dr("title_name").ToString()
            DataList.Add(DataItem)
        Next
        'JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
        Return DataList
    End Function
    Private Function getOccupation() As List(Of KeyCodeItem)
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
        'JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
        Return DataList
    End Function
    Private Function getNationality() As List(Of KeyCodeItem)
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
        'JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
        Return DataList
    End Function
    Private Function getAssociation() As List(Of KeyCodeIDItem)
        Dim DataList As New List(Of KeyCodeIDItem)
        Dim DataItem As KeyCodeIDItem
        Dim sql As String = "select id, code, code || ' ' || name as name from association where name is not null order by name"
        Dim dt As DataTable = Cbase.QueryTable(sql)

        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows()
                DataItem = New KeyCodeIDItem
                DataItem.valueID = dr("code").ToString()
                DataItem.value = dr("id").ToString()
                DataItem.text = dr("name").ToString()
                DataList.Add(DataItem)
            Next
        Else
            Throw New Exception("No data found.", New Exception("Association has no record"))
        End If
        'JSONResponse.setItems(Of List(Of KeyCodeItem))(DataList)
        Return DataList
    End Function
    Private Sub getHospital()
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

    End Sub
    Private Sub getDepartment()
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

    End Sub
    Private Sub getLab()
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
    End Sub
    Private Sub getExamination()
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
    End Sub
    Private Sub getReason()
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
    End Sub
    Private Sub getDonationto()
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
    End Sub
    Private Sub getStaff()
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
    End Sub
    Private Sub getDeferral()
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
    End Sub
    Private Sub getDonationType()
        Dim DataList As New List(Of DonationtypeListItem)
        Dim DataItem As DonationtypeListItem
        Dim sql As String = "select distinct dt.id, dt.description, dc.min_age, dc.max_age
                            from DONATION_TYPE dt
                            inner join DONATION_CONDITION dc on DC.DONATION_TYPE_id = dt.id
                            order by dt.description "
        Dim dt As DataTable = Cbase.QueryTable(sql)

        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows()
                DataItem = New DonationtypeListItem
                DataItem.valueID = dr("id").ToString()
                DataItem.value = dr("id").ToString()
                DataItem.text = dr("description").ToString()
                DataItem.minAge = dr("min_age").ToString()
                DataItem.maxAge = dr("max_age").ToString()
                DataList.Add(DataItem)
            Next
        Else
            Throw New Exception("No data found.", New Exception("Donation To has no record"))
        End If
        JSONResponse.setItems(Of List(Of DonationtypeListItem))(DataList)
    End Sub
    Private Sub getDonationType2()
        Dim DataList As New List(Of DonationtypeListItem)
        Dim DataItem As DonationtypeListItem
        Dim sql As String = "select distinct dt.id, dt.description, dc.min_age, dc.max_age
                            from DONATION_TYPE dt
                            inner join DONATION_CONDITION dc on DC.DONATION_TYPE_id = dt.id
                            where dt.ID > 0
                            order by dt.description "
        Dim dt As DataTable = Cbase.QueryTable(sql)

        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows()
                DataItem = New DonationtypeListItem
                DataItem.valueID = dr("id").ToString()
                DataItem.value = dr("id").ToString()
                DataItem.text = dr("description").ToString()
                DataItem.minAge = dr("min_age").ToString()
                DataItem.maxAge = dr("max_age").ToString()
                DataList.Add(DataItem)
            Next
        Else
            Throw New Exception("No data found.", New Exception("Donation To has no record"))
        End If
        JSONResponse.setItems(Of List(Of DonationtypeListItem))(DataList)
    End Sub
    Private Sub GetDonateBagTypeList()
        Dim DataList As New List(Of DonationtypeListItem)
        Dim DataItem As DonationtypeListItem
        Dim sql As String = "select * from Bag where ID > 0"

        Dim dt As DataTable = Cbase.QueryTable(sql)
        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows()
                DataItem = New DonationtypeListItem
                DataItem.valueID = dr("ID").ToString()
                DataItem.value = dr("ID").ToString()
                DataItem.text = dr("DESCRIPTION").ToString()
                DataList.Add(DataItem)
            Next
        Else
            Throw New Exception("No data found.", New Exception("Donation To has no record"))
        End If
        JSONResponse.setItems(Of List(Of DonationtypeListItem))(DataList)
    End Sub
    Private Sub GetDonateApplyList()
        Dim DataList As New List(Of DonationtypeListItem)
        Dim DataItem As DonationtypeListItem
        Dim sql As String = "select * from Donation_To where used_module like '%D,%'"

        Dim dt As DataTable = Cbase.QueryTable(sql)
        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows()
                DataItem = New DonationtypeListItem
                DataItem.valueID = dr("ID").ToString()
                DataItem.value = dr("ID").ToString()
                DataItem.text = dr("DESCRIPTION").ToString()
                DataList.Add(DataItem)
            Next
        Else
            Throw New Exception("No data found.", New Exception("Donation To has no record"))
        End If
        JSONResponse.setItems(Of List(Of DonationtypeListItem))(DataList)
    End Sub
    Private Sub getBag()
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
    End Sub
    Private Sub getQuestionnaire()
        Dim QuestionnaireItem As New QuestionnaireItem
        QuestionnaireItem.QuestionItem = New List(Of QuestionItem)
        QuestionnaireItem.AnswerItem = New List(Of AnswerItem)
        Dim sql As String = "select qq.id, qq.code, qq.description, qq.required, qq.answer_type 
                                        , wmsys.wm_concat(qa.code) as preset, nvl(qq.description_th, qq.description) as description_th
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

    End Sub
    Private Function getForCollection() As List(Of KeyCodeIDItem)
        Dim countryList As New List(Of KeyCodeIDItem)
        Dim CountryItem As KeyCodeIDItem

        If Not String.IsNullOrEmpty(_REQUEST("siteID")) Then param.Add("#SITE_ID", " and site_id = '" & _REQUEST("siteID") & "' ")

        Dim dt As DataTable = Cbase.QueryTable("select id, code, code || ' : ' || name as name from collection_point where 1=1 /*#SITE_ID*/ order by code || ' : ' || name ", param)

        For Each dr As DataRow In dt.Rows()
            CountryItem = New KeyCodeIDItem
            CountryItem.valueID = dr("id").ToString()
            CountryItem.value = dr("id").ToString()
            CountryItem.text = dr("name").ToString()
            countryList.Add(CountryItem)
        Next
        'JSONResponse.setItems(Of List(Of KeyCodeIDItem))(countryList)
        Return countryList
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

Public Structure ExternalCardItem
    Public value As String
    Public text As String
    Public valueID As String
    Public minLength As String
    Public maxLength As String

End Structure

Public Structure LoginContent
    Public SiteList As List(Of KeyCodeIDItem)
    Public CollectionList As List(Of KeyCodeIDItem)
End Structure

Public Structure DonationtypeListItem
    Public value As String
    Public text As String
    Public valueID As String
    Public minAge As String
    Public maxAge As String
End Structure

Public Structure RegisterContent
    Public AssoList As List(Of KeyCodeIDItem)
    Public TitleList As List(Of KeyCodeItem)
    Public CollectionList As List(Of KeyCodeIDItem)
    Public CountryList As List(Of KeyCodeItem)
    Public OccupationList As List(Of KeyCodeItem)
    Public NationList As List(Of KeyCodeItem)
End Structure