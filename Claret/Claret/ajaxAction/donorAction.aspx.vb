Imports H2GEngine
Imports H2GEngine.DataItem
Imports System.Threading
Public Class donorAction
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
            Hbase.Rollback()
            JSONResponse = New CallbackException(ex)
            Response.Write(JSONResponse.ToJSON())
        Finally
            Cbase.Apply()
            Hbase.Apply()
        End Try
    End Sub

    Private Function Action() As String
        Select Case _REQUEST("action")
            Case "savedonor" : saveDonor()
            Case "selectregister" : selectRegister()
            Case "searchdonor" : searchDonor()
            Case "getdonatereward" : getDonateReward()
            Case "historicalFileData" : historicalFileData()
            Case "immunohaemtologyDataSet1" : immunohaemtologyDataSet1()
            Case "immunohaemtologyDataSet2" : immunohaemtologyDataSet2()
            Case "examsData" : examsData()
            Case "donorpostqueue" : donorPostQueue()
            Case "visithistory" : visitHistory()
            Case "loadSynthesisSet1" : loadSynthesisSet1()
            Case "getDonateSite" : getDonateSite()
            Case "immunohaemtologyDataSetDate" : immunohaemtologyDataSetDate()
            Case "checkvisited" : checkVisited()
            Case "stickerprint" : StrickerPrint()
            Case "checksamplenumber" : checkSampleNumber()
            Case "checkextcardnumber" : checkExtCardNumber()
            Case Else
                Dim exMsg As String = IIf(String.IsNullOrEmpty(_REQUEST("action")), "", _REQUEST("action"))
                Throw New Exception("Not found action [" & exMsg & "].", New Exception("Please check your action name"))
        End Select

        Return JSONResponse.ToJSON()
    End Function
    Private Sub saveDonor()
        Dim DonorItem As DonorItem = JSON.Deserialize(Of DonorItem)(_REQUEST("md"))
        If String.IsNullOrEmpty(DonorItem.ID) Then
            DonorItem.DonorNumber = getRunningNumber("DONORID", DonorItem.AssociationID)
            DonorItem.ID = Cbase.QueryField(H2G.nextVal("DONOR"))
            DonorItem.VisitNumber = Cbase.QueryField("select nvl(max(visit_number),0)+1 from donation_visit where donor_id = " & DonorItem.ID & " ")
            Cbase.Execute("SQL::donor/InsertMasterDonor", DonorItem.WithCollection(DonorItem))
        Else
            If H2G.Convert(Of Boolean)(DonorItem.notOnlyDonor) Then
                DonorItem.VisitNumber = Cbase.QueryField("select nvl(max(visit_number),0)+1 from donation_visit where donor_id = " & DonorItem.ID & " ")
            End If
            Cbase.Execute("SQL::donor/UpdateMasterDonor", DonorItem.WithCollection(DonorItem))
        End If

        '### donation visit
        Dim DVisitItem As DonationVisitItem = JSON.Deserialize(Of DonationVisitItem)(_REQUEST("dv"))
        '### donation hospital
        Dim DHospitalItem As DonationHospitalItem = JSON.Deserialize(Of DonationHospitalItem)(_REQUEST("dh"))
        If H2G.Convert(Of Boolean)(DonorItem.notOnlyDonor) Then
            If String.IsNullOrEmpty(_REQUEST("receipthospitalid")) Then
                If String.IsNullOrEmpty(DVisitItem.ID) Then
                    DVisitItem.ID = Cbase.QueryField(H2G.nextVal("DONATION_VISIT"))
                    DVisitItem.DonorID = DonorItem.ID
                    DVisitItem.Status = "WAIT INTERVIEW" 'สร้างใหม่ต้องเป็น WAIT INTERVIEW เสมอ
                    DVisitItem.QueueNumber = Cbase.QueryField("select nvl(max(queue_number),0)+1 from donation_visit 
                                                        where to_date(to_char(VISIT_DATE, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI'),'DD/MM/YYYY')             between to_date('" & H2G.Convert(Of Date)(H2G.Login.PlanDate).ToString("ddMMyyyy") & "','ddMMyyyy') 
                                                        and to_date('" & H2G.Convert(Of Date)(H2G.Login.PlanDate).AddDays(1).ToString("ddMMyyyy") & "','ddMMyyyy') ")

                    DVisitItem.VisitNumber = DonorItem.VisitNumber

                    Cbase.Execute("SQL::donor/InsertDonationVisit", DonationVisitItem.WithCollection(DVisitItem))
                Else
                    DVisitItem.VisitNumber = DonorItem.VisitNumber
                    Cbase.Execute("SQL::donor/UpdateDonationVisit", DonationVisitItem.WithCollection(DVisitItem))
                End If
                DonorItem.VisitID = DVisitItem.ID
            Else
                If String.IsNullOrEmpty(DHospitalItem.ID) Then
                    Dim dtHospital As DataTable = Cbase.QueryTable("select id, donation_to_id, hospital_id, department_id, lab_id from receipt_hospital where id = '" & DHospitalItem.ReceiptHospitalID & "'")
                    If dtHospital.Rows.Count = 0 Then
                        Throw New Exception("No data found.", New Exception("Receipt hospital has no record"))
                    End If
                    DHospitalItem.ID = Cbase.QueryField(H2G.nextVal("DONATION_HOSPITAL"))
                    DHospitalItem.DonorID = DonorItem.ID
                    DHospitalItem.Status = "WAIT RESULT" 'สร้างใหม่ต้องเป็น WAIT RESULT เสมอ
                    DHospitalItem.OrderNumber = Cbase.QueryField("select nvl(max(order_number),0)+1 from donation_hospital where receipt_hospital_id = '" & DHospitalItem.ReceiptHospitalID & "' ")
                    DHospitalItem.ReceiptHospitalID = dtHospital.Rows(0)("id").ToString()
                    DHospitalItem.DonationToID = dtHospital.Rows(0)("donation_to_id").ToString()
                    DHospitalItem.HospitalID = dtHospital.Rows(0)("hospital_id").ToString()
                    DHospitalItem.DepartmentID = dtHospital.Rows(0)("department_id").ToString()
                    DHospitalItem.LabID = dtHospital.Rows(0)("lab_id").ToString()
                    DHospitalItem.SiteID = H2G.Login.SiteID
                    DHospitalItem.CollectionPointID = H2G.Login.CollectionPointID

                    Cbase.Execute("SQL::donor/InsertDonationHospital", DonationHospitalItem.WithCollection(DHospitalItem))
                Else
                    DHospitalItem.ID = DVisitItem.ID
                    Cbase.Execute("update donation_hospital set update_date = sysdate, update_staff = :update_staff where id = :id ", DonationHospitalItem.WithCollection(DHospitalItem))
                End If
                DonorItem.VisitID = DHospitalItem.ID
            End If
        End If

        '### donor external card
        Dim DonorExtCardList As List(Of DonorExtCardItem) = JSON.Deserialize(Of List(Of DonorExtCardItem))(_REQUEST("dec"))
        For Each item In DonorExtCardList
            If item.ID = "NEW" Then
                item.ID = Cbase.QueryField(H2G.nextVal("DONOR_EXTERNAL_CARD"))
                item.DonorID = DonorItem.ID
                Cbase.Execute("insert into donor_external_card (id, donor_id, external_card_id, card_number) values(:id, :donor_id, :external_card_id, :card_number)", DonorExtCardItem.WithCollection(item))
            ElseIf (item.ID.Contains("D#")) Then
                Cbase.Execute("delete from donor_external_card where id= '" + item.ID.Replace("D#", "") + "'")
            Else
                Cbase.Execute("update donor_external_card set card_number = :card_number where id = :id ", DonorExtCardItem.WithCollection(item))
            End If
        Next

        '### donor comment
        Dim DonorCommentList As List(Of DonorCommentItem) = JSON.Deserialize(Of List(Of DonorCommentItem))(_REQUEST("dc"))
        For Each item In DonorCommentList
            If item.ID = "NEW" Then
                item.ID = Cbase.QueryField(H2G.nextVal("DONOR_COMMENT"))
                item.DonorID = DonorItem.ID
                Cbase.Execute("insert into donor_comment (id, donor_id, create_date, create_staff, start_date, end_date, description) values(:id, :donor_id, sysdate, :create_staff, :start_date, :end_date, :description)", DonorCommentItem.WithCollection(item))
            ElseIf (item.ID.Contains("D#")) Then
                Cbase.Execute("update donor_comment set end_date = sysdate-1 where id = '" & item.ID.Replace("D#", "") & "' ")
            End If
        Next

        '### donation record
        Dim DRecordList As List(Of DonationRecordItem) = JSON.Deserialize(Of List(Of DonationRecordItem))(_REQUEST("dr"))
        For Each item In DRecordList
            If item.ID = "NEW" Then
                item.ID = Cbase.QueryField(H2G.nextVal("DONATION_RECORD"))
                Dim paramDRecord As New SQLCollection

                paramDRecord.Add(":id", DbType.Int64, item.ID)
                paramDRecord.Add(":donor_id", DbType.Int64, DonorItem.ID)
                paramDRecord.Add(":create_staff", DbType.Int64, H2G.Login.ID)
                paramDRecord.Add(":donation_from", DbType.String, item.DonateFrom)
                paramDRecord.Add(":donation_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(item.DonateDate.Replace("/", "-"))).ToString("dd-MM-yyyy"))
                paramDRecord.Add(":donation_number", DbType.Int64, item.DonateNumber)

                Cbase.Execute("insert into donation_record (id, donor_id, create_date, create_staff, donation_from, donation_date, donation_number) 
                                        values(:id, :donor_id, sysdate, :create_staff, :donation_from, :donation_date, :donation_number)", paramDRecord)

                '### check insert donation reward
                If Not String.IsNullOrEmpty(item.DonateReward) Then
                    For Each strReward As String In item.DonateReward.Split("##")
                        If Not String.IsNullOrEmpty(strReward) Then
                            Dim paramDReward As New SQLCollection

                            paramDReward.Add(":id", DbType.Int64, Cbase.QueryField(H2G.nextVal("DONATION_REWARD")))
                            paramDReward.Add(":create_staff", DbType.Int64, H2G.Login.ID)
                            paramDReward.Add(":donor_id", DbType.Int64, DonorItem.ID)
                            paramDReward.Add(":donation_record_id", DbType.Int64, item.ID)
                            paramDReward.Add(":reward_id", DbType.Int64, strReward.Split("|")(0))
                            paramDReward.Add(":reward_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(strReward.Split("|")(1).Replace("/", "-"))).ToString("dd-MM-yyyy"))
                            Cbase.Execute("insert into donation_reward (id, create_date, create_staff, donor_id, donation_record_id, reward_id, reward_date) 
                                        values(:id, sysdate, :create_staff, :donor_id, :donation_record_id, :reward_id, :reward_date)", paramDReward)

                        End If
                    Next
                End If
            ElseIf (item.ID.Contains("D#")) Then
                Cbase.Execute("delete from donation_reward where donation_record_id = '" & item.ID.Replace("D#", "") & "'")
                Cbase.Execute("delete from donation_record where id = '" & item.ID.Replace("D#", "") & "'")
            Else
                '### check insert donation reward
                If Not String.IsNullOrEmpty(item.DonateReward) Then
                    For Each strReward As String In item.DonateReward.Split("##")
                        If Not String.IsNullOrEmpty(strReward) Then
                            Dim paramDReward As New SQLCollection

                            paramDReward.Add(":id", DbType.Int64, Cbase.QueryField(H2G.nextVal("DONATION_REWARD")))
                            paramDReward.Add(":create_staff", DbType.Int64, H2G.Login.ID)
                            paramDReward.Add(":donor_id", DbType.Int64, DonorItem.ID)
                            paramDReward.Add(":donation_record_id", DbType.Int64, item.ID)
                            paramDReward.Add(":reward_id", DbType.Int64, strReward.Split("|")(0))
                            paramDReward.Add(":reward_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(strReward.Split("|")(1).Replace("/", "-"))).ToString("dd-MM-yyyy"))
                            Cbase.Execute("insert into donation_reward (id, create_date, create_staff, donor_id, donation_record_id, reward_id, reward_date) 
                                        values(:id, sysdate, :create_staff, :donor_id, :donation_record_id, :reward_id, :reward_date)", paramDReward)

                        End If
                    Next
                End If
            End If
        Next

        '### donation question
        Dim QuestionList As List(Of DonorQuestionItem) = JSON.Deserialize(Of List(Of DonorQuestionItem))(_REQUEST("dq"))
        If String.IsNullOrEmpty(_REQUEST("receipthospitalid")) Then
            For Each item In QuestionList
                If item.ID = "NEW" Then
                    item.ID = Cbase.QueryField(H2G.nextVal("DONATION_QUESTIONNAIRE"))
                    item.CreateStaff = H2G.Login.ID
                    item.VisitID = IIf(String.IsNullOrEmpty(DVisitItem.ID), DHospitalItem.ID, DVisitItem.ID)
                    Cbase.Execute("SQL::donor/InsertDonationQuestion", DonorQuestionItem.WithCollection(item))
                ElseIf item.ID.ToUpper().Contains("D#") Then
                    Cbase.Execute("delete from donation_questionnaire where id = '" & item.ID.Replace("D#", "") & "' ")
                Else

                End If
            Next
        End If

        '### donor deferral
        Dim DonorDeferralList As List(Of DonorDeferralItem) = JSON.Deserialize(Of List(Of DonorDeferralItem))(_REQUEST("dd"))
        For Each item In DonorDeferralList
            If item.ID = "NEW" Then
                item.ID = Cbase.QueryField(H2G.nextVal("DONOR_DEFERRAL"))
                item.DetailID = Cbase.QueryField(H2G.nextVal("DONOR_DEFERRAL_DETAIL"))
                item.CreateStaff = H2G.Login.ID
                item.VisitID = DVisitItem.ID
                item.DonorID = DonorItem.ID

                Cbase.Execute("SQL::donor/InsertDonorDeferral", DonorDeferralItem.WithCollection(item))
                Cbase.Execute("SQL::donor/InsertDonorDeferralDetail", DonorDeferralItem.WithCollectionDetail(item))
            ElseIf item.ID.ToUpper().Contains("D#") Then
                Cbase.Execute("delete from donor_deferral_detail where donor_deferral_id = '" & item.ID.Replace("D#", "") & "' ")
                Cbase.Execute("delete from donor_deferral where id = '" & item.ID.Replace("D#", "") & "' ")
            End If
        Next

        '### donation examination
        Dim DonationExamlList As List(Of DonationExamination) = JSON.Deserialize(Of List(Of DonationExamination))(_REQUEST("de"))
        For Each item In DonationExamlList
            If item.id = "NEW" Then
                item.id = Cbase.QueryField(H2G.nextVal("DONATION_EXAMINATION"))
                item.create_staff = H2G.Login.ID
                item.donation_visit_id = DVisitItem.ID
                item.donation_hospital_id = DHospitalItem.ID
                item.donation_from = IIf(String.IsNullOrEmpty(DVisitItem.ID), "HOSPITAL", "INTERNAL")

                Cbase.Execute("SQL::donor/InsertDonationExam", DonationExamination.WithCollection(item))
            ElseIf item.id.ToUpper().Contains("D#") Then
                Cbase.Execute("delete from donation_examination where id = '" & item.id.Replace("D#", "") & "' ")
            End If
        Next

        Cbase.Apply()

        JSONResponse.setItems(Of DonorItem)(DonorItem)

    End Sub
    Private Sub selectRegister()
        Dim DonorMainItem As New DonorMainItem
        '### DonorItem
        param.Add(":id", DbType.Int64, _REQUEST("id"))
        If String.IsNullOrEmpty(_REQUEST("visit_id")) Then _REQUEST("visit_id") = "0"

        If String.IsNullOrEmpty(_REQUEST("receipthospitalid")) Then
            param.Add(":visit_id", DbType.Int64, _REQUEST("visit_id"))
            param.Add(":plan_id", DbType.Int64, H2G.Login.PlanID)
            sqlMain = "SQL::donor\SelectMasterDonorVisit"
            For Each dRow As DataRow In Cbase.QueryTable(sqlMain, param).Rows
                DonorMainItem.Donor = DTransaction.WithItems(New DTransaction, dRow)
            Next
            Dim dt As DataTable = Cbase.QueryTable("select * FROM(select DV.weight
                , to_char(nvl(dv.visit_date,sysdate), 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as visit_date
                 From donation_visit dv where dv.donor_id = '" & _REQUEST("id") & "' And DV.id <> '" & _REQUEST("visit_id") & "' ORDER BY DV.id desc) WHERE ROWNUM <= 1")
            DonorMainItem.Donor.LastWeight = ""
            DonorMainItem.Donor.LastVisit = ""
            For Each dRow As DataRow In dt.Rows
                DonorMainItem.Donor.LastWeight = dRow("weight").ToString()
                DonorMainItem.Donor.LastVisit = dRow("visit_date").ToString()
            Next

        Else
            param.Add(":donation_hospital_id", DbType.Int64, _REQUEST("donationhospitalid"))
            sqlMain = "SQL::donor\SelectDonationHospital"
            For Each dRow As DataRow In Cbase.QueryTable(sqlMain, param).Rows
                DonorMainItem.Donor = DTransaction.WithItems(New DTransaction, dRow)
            Next

        End If

        '### ExternalCardItem
        DonorMainItem.ExtCard = New List(Of DonorExtCardItem)
        For Each dRow As DataRow In Cbase.QueryTable("
                        select dexc.id, dexc.donor_id, dexc.external_card_id, dexc.card_number, ec.description 
                        from donor_external_card dexc
                        inner join external_card ec on ec.id = dexc.external_card_id where dexc.donor_id = :id order by ec.description ", param).Rows
            DonorMainItem.ExtCard.Add(DonorExtCardItem.WithItems(New DonorExtCardItem, dRow))
        Next

        '### DeferralItem
        DonorMainItem.Deferral = New List(Of DataItem.DeferralItem)
        For Each dRow As DataRow In Cbase.QueryTable("
                        select deferral_code as deferral_code, end_date, description, deferral_type, status from (
                            select f.code as deferral_code, f.description, DDF.DEFERRAL_TYPE
                            , to_char(DDF.END_DATE, 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as END_DATE
                            , CASE WHEN DDF.END_DATE < SYSDATE THEN 'INACTIVE' ELSE 'ACTIVE' END as status
                            from DONOR_DEFERRAL df
                            inner join DONOR_DEFERRAL_DETAIL ddf on DDF.DONOR_DEFERRAL_ID = DF.id
                            inner join DEFERRAL f on f.id = df.deferral_id
                            where df.DONOR_ID = :id 
                        ) tmp order by status, end_date", param).Rows
            DonorMainItem.Deferral.Add(DataItem.DeferralItem.WithItems(New DataItem.DeferralItem, dRow))
        Next

        '### DonationTypeItem
        DonorMainItem.DonationType = New List(Of DonationTypeItem)
        For Each dRow As DataRow In Cbase.QueryTable("
                        select to_char(ld.LAST_DATE, 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as LAST_DATE, DT.code 
                        from LATEST_DONATION ld
                        inner join donation_type dt on DT.id = ld.DONATION_TYPE_ID
                        where LD.DONOR_ID = :id", param).Rows
            DonorMainItem.DonationType.Add(DonationTypeItem.WithItems(New DonationTypeItem, dRow))
        Next

        '### CommentItem
        DonorMainItem.DonorComment = New List(Of DonorCommentItem)
        For Each dRow As DataRow In Cbase.QueryTable("
                        select dc.id, dc.donor_id,to_char(dc.start_date, 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as start_date
                        , to_char(dc.end_date, 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as end_date, dc.description, '' as create_staff 
                        from donor_comment dc
                        where dc.DONOR_ID = :id and dc.end_date >= SYSDATE-1
                        order by dc.end_date ", param).Rows
            DonorMainItem.DonorComment.Add(DonorCommentItem.WithItems(New DonorCommentItem, dRow))
        Next

        '### RecordItem
        DonorMainItem.DonationRecord = New List(Of DonationRecordItem)
        For Each dRow As DataRow In Cbase.QueryTable("
                        select dr.id as record_id, DR.DONATION_FROM, nvl(DR.DONATION_DATE,sysdate) as DONATION_DATE, DR.DONATION_NUMBER
                        , to_char(nvl(DR.DONATION_DATE,sysdate), 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as DONATION_DATE_TEXT 
                        from donation_record dr 
                        where DR.DONOR_ID = :id order by DR.DONATION_NUMBER ", param).Rows
            Dim drItem As New DonationRecordItem
            drItem.ID = dRow("record_id").ToString
            drItem.DonateDate = H2G.AC2BE(CDate(dRow("DONATION_DATE").ToString)).ToString("dd/MM/yyyy")
            drItem.DonateDateText = dRow("DONATION_DATE_TEXT").ToString
            drItem.DonateFrom = dRow("DONATION_FROM").ToString
            drItem.DonateNumber = dRow("DONATION_NUMBER").ToString
            drItem.DonateReward = ""

            For Each dReward As DataRow In Cbase.QueryTable("select RE.id as reward_id, RE.DESCRIPTION as reward_desc, dr.id as donation_reward_id
                            , to_char(dr.reward_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as reward_date  
                            from REWARD re 
                            left join DONATION_REWARD dr on DR.REWARD_ID = RE.id and dr.donor_id = '" & DonorMainItem.Donor.DonorID & "'
                            where RE.DONATION_NUMBER = '" & drItem.DonateNumber & "' 
                            or (to_date('" & CDate(dRow("DONATION_DATE").ToString).ToString("dd/MM/yyyy") & "','dd/MM/yyyy') between RE.START_DATE and re.END_DATE)
                            order by re.id, RE.DONATION_NUMBER desc").Rows

                drItem.DonateReward &= dReward("reward_id").ToString() & "|" & dReward("reward_desc").ToString() & "|" & dReward("donation_reward_id").ToString() & "|" & dReward("reward_date") & "##"
            Next

            DonorMainItem.DonationRecord.Add(drItem)
        Next

        DonorMainItem.QuestionList = New List(Of DonorQuestionItem)
        If String.IsNullOrEmpty(_REQUEST("receipthospitalid")) Then
            '### donation question
            sqlMain = "select dq.id, dq.create_date, dq.create_staff, dq.donation_visit_id, dq.questionnaire_question_id, dq.questionnaire_question_code
                        , dq.questionnaire_question_desc, dq.answer, dq.parent_id, dq.questionnaire_question_desc_th
                        , wmsys.wm_concat(qa.code) as preset, qq.answer_type
                        from DONATION_QUESTIONNAIRE dq
                        left join QUESTIONNAIRE_QUESTION qq on qq.id = dq.questionnaire_question_id
                        left join QUESTIONNAIRE_ANSWER qa on qa.QUESTIONNAIRE_QUESTION_id = dq.questionnaire_question_id
                        where dq.donation_visit_id = '" & _REQUEST("visit_id") & "'
                        group by dq.id, dq.create_date, dq.create_staff, dq.donation_visit_id, dq.questionnaire_question_id, dq.questionnaire_question_code
                        , dq.questionnaire_question_desc, dq.answer, dq.parent_id, dq.questionnaire_question_desc_th, qq.answer_type
                        order by dq.id "
            For Each dRow As DataRow In Cbase.QueryTable(sqlMain).Rows
                Dim drItem As New DonorQuestionItem
                drItem.ID = dRow("id").ToString()
                drItem.VisitID = dRow("donation_visit_id").ToString()
                drItem.QuestionID = dRow("questionnaire_question_id").ToString()
                drItem.QuestionCode = dRow("questionnaire_question_code").ToString()
                drItem.QuestionDesc = dRow("questionnaire_question_desc").ToString()
                drItem.QuestionDescTH = dRow("questionnaire_question_desc_th").ToString()
                drItem.Answer = dRow("answer").ToString()
                drItem.ParentID = dRow("parent_id").ToString()
                drItem.Preset = dRow("preset").ToString()
                drItem.AnswerType = dRow("answer_type").ToString()

                DonorMainItem.QuestionList.Add(drItem)
            Next

        End If

        DonorMainItem.DonorDeferral = New List(Of DonorDeferralItem)
        '### donor deferral
        sqlMain = " select dd.id, ddd.id as detail_id, dd.donor_id, dd.deferral_id, dd.donation_visit_id , dd.create_date, dd.create_staff
                    , to_char(dd.start_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as start_date
                    , to_char(ddd.end_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as end_date
                    , dd.note, ddd.donation_type_id, ddd.deferral_type, nvl(ddd.duration,0) as duration, dd.questionnaire_question_id
                    , def.description
                    from DONOR_DEFERRAL dd
                    inner join DONOR_DEFERRAL_detail ddd on ddd.donor_deferral_id = dd.id
                    left join DEFERRAL def on def.id = dd.deferral_id
                    where dd.donor_id = '" & _REQUEST("id") & "'
                    ORDER BY dd.id "
        For Each dRow As DataRow In Cbase.QueryTable(sqlMain).Rows
            Dim drItem As New DonorDeferralItem
            drItem.ID = dRow("id").ToString()
            drItem.DetailID = dRow("detail_id").ToString()
            drItem.DonorID = dRow("donor_id").ToString()
            drItem.DeferralID = dRow("deferral_id").ToString()
            drItem.VisitID = dRow("donation_visit_id").ToString()
            drItem.StartDate = dRow("start_date").ToString()
            drItem.EndDate = dRow("end_date").ToString()
            drItem.Note = dRow("note").ToString()
            drItem.DonationTypeID = dRow("donation_type_id").ToString()
            drItem.DeferralType = dRow("deferral_type").ToString()
            drItem.Duration = dRow("duration").ToString()
            drItem.QuestionID = dRow("questionnaire_question_id").ToString()
            drItem.Desc = dRow("description").ToString()

            DonorMainItem.DonorDeferral.Add(drItem)
        Next

        DonorMainItem.DonationExam = New List(Of DonationExamination)
        '### donation examination
        If Not String.IsNullOrEmpty(_REQUEST("receipthospitalid")) And _REQUEST("visit_id") = "0" Then
            ' ### กรณีเปิดลงทะเบียนขอตรวจ Lab ใหม่ ให้เอา Exam ของ โรงพยาบาลนั้นมา Default
            sqlMain = "select 'NEW' as ID, sysdate, '' as create_staff, '' as donation_visit_id, '' as donation_hospital_id, 'HOSPITAL' as donation_from
                        , rhd.EXAMINATION_GROUP_ID, rhd.EXAMINATION_GROUP_CODE, rhd.EXAMINATION_GROUP_DESC
                        , rhd.EXAMINATION_ID, rhd.EXAMINATION_CODE, rhd.EXAMINATION_DESC, '' as questionnaire_question_id
                        from RECEIPT_HOSPITAL_DETAIL rhd
                        where rhd.RECEIPT_HOSPITAL_ID = '" & _REQUEST("receipthospitalid") & "'"

        Else
            sqlMain = " select de.id, de.create_date, de.create_staff, de.donation_visit_id, de.donation_hospital_id, de.donation_from
                    , de.examination_group_id, de.examination_group_desc, de.examination_id, de.examination_desc, de.questionnaire_question_id
                    , EXA.CODE as examination_code, exg.code as examination_group_code
                    from DONATION_EXAMINATION de
                    left join EXAMINATION exa on exa.id = DE.EXAMINATION_ID
                    LEFT JOIN EXAMINATION_GROUP exg on exg.id = DE.examination_group_id
                    where {0}
                    ORDER BY id "
        End If
        If String.IsNullOrEmpty(_REQUEST("donationhospitalid")) Then
            sqlMain = String.Format(sqlMain, "de.donation_visit_id = '" & _REQUEST("visit_id") & "'")
        Else
            sqlMain = String.Format(sqlMain, "de.donation_hospital_id = '" & _REQUEST("visit_id") & "'")
        End If

        For Each dRow As DataRow In Cbase.QueryTable(sqlMain).Rows
            Dim drItem As New DonationExamination
            drItem.id = dRow("id").ToString()
            drItem.donation_visit_id = dRow("donation_visit_id").ToString()
            drItem.donation_hospital_id = dRow("donation_hospital_id").ToString()
            drItem.donation_from = dRow("donation_from").ToString()
            drItem.examination_group_id = dRow("examination_group_id").ToString()
            drItem.examination_group_desc = dRow("examination_group_desc").ToString()
            drItem.examination_id = dRow("examination_id").ToString()
            drItem.examination_desc = dRow("examination_desc").ToString()
            drItem.question_id = dRow("questionnaire_question_id").ToString()
            drItem.examination_code = dRow("examination_code").ToString()
            drItem.examination_group_code = dRow("examination_group_code").ToString()

            DonorMainItem.DonationExam.Add(drItem)
        Next

        JSONResponse.setItems(Of DonorMainItem)(DonorMainItem)

    End Sub
    Private Sub searchDonor()
        Dim SearchItem As New SearchItem
        SearchItem.GoNext = "N"
        SearchItem.Duplicate = ""
        SearchItem.SearchList = New List(Of DonorSearchItem)
        Dim DonorSearchItem As DonorSearchItem
        Dim intItemPerPage As Integer = 20
        Dim intTotalPage As Integer = 1

        If Not String.IsNullOrEmpty(_REQUEST("donornumber")) Then
            param.Add("#DONOR_NUMBER", " and UPPER(dn.donor_number) like UPPER('" & _REQUEST("donornumber") & "') ")
            If Not _REQUEST("donornumber").ToString.Contains("%") Then
                SearchItem.GoNext = "Y"
            End If
        End If
        If Not String.IsNullOrEmpty(_REQUEST("nationnumber")) Then
            param.Add("#NATION_NUMBER", " and UPPER(dexc.card_number) like UPPER('" & _REQUEST("nationnumber") & "') ")
            If Not _REQUEST("nationnumber").ToString.Contains("%") Then
                SearchItem.GoNext = "Y"
            End If
        End If
        If Not String.IsNullOrEmpty(_REQUEST("extnumber")) Then param.Add("#EXT_NUMBER", " and UPPER(dexc.card_number) like UPPER('" & _REQUEST("extnumber") & "') ")
        If Not String.IsNullOrEmpty(_REQUEST("name")) Then param.Add("#NAME", " and (UPPER(dn.name) like UPPER('" & _REQUEST("name") & "') or UPPER(dn.name_e) like UPPER('" & _REQUEST("name") & "')) ")
        If Not String.IsNullOrEmpty(_REQUEST("surname")) Then param.Add("#SURNAME", " and (UPPER(dn.surname) like UPPER('" & _REQUEST("surname") & "') or UPPER(dn.surname_e) like UPPER('" & _REQUEST("surname") & "')) ")
        If Not String.IsNullOrEmpty(_REQUEST("birthday")) Then param.Add("#BIRTHDAY", "and to_char(dn.birthday, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("birthday") & "' ")
        If Not String.IsNullOrEmpty(_REQUEST("bloodgroup")) Then param.Add("#BLOOD_GROUP", " and UPPER(rg.description) like UPPER('" & _REQUEST("bloodgroup") & "') ")

        Dim sql1 As String = "select dn.id, dn.donor_number, ec.id as ext_id, dexc.card_number as nation_number, '' as external_number
                                        , dn.name, dn.surname, rg.description as blood_group, dn.birthday
                                        from donor dn 
                                        inner join donor_external_card dexc on dexc.donor_id = dn.id 
                                        inner join external_card ec on ec.id = dexc.external_card_id and ec.id = 3 
                                        left join rh_group rg on rg.id = dn.rh_group_id
                                        where 1=1 /*#DONOR_NUMBER*/ /*#NATION_NUMBER*/ /*#NAME*/ /*#SURNAME*/ /*#BIRTHDAY*/ /*#BLOOD_GROUP*/ "

        Dim sql2 As String = "select dn.id, dn.donor_number, ec.id as ext_id, '' as nation_number, dexc.card_number as external_number
                                        , dn.name, dn.surname, rg.description as blood_group, dn.birthday
                                        from donor dn 
                                        inner join donor_external_card dexc on dexc.donor_id = dn.id 
                                        inner join external_card ec on ec.id = dexc.external_card_id and ec.id <> 3 
                                        left join rh_group rg on rg.id = dn.rh_group_id
                                        where 1=1 /*#DONOR_NUMBER*/ /*#EXT_NUMBER*/ /*#NAME*/ /*#SURNAME*/ /*#BIRTHDAY*/ /*#BLOOD_GROUP*/ "

        Dim sql As String = " union all "

        Dim sqlRecord As String = "SELECT DN.rn as row_num, dn.id, dn.donor_number, dn.ext_id, dn.nation_number, dn.external_number, dn.name, dn.surname
			                    , dn.blood_group, to_char(dn.birthday , 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as birthday 
                                , to_char(dn.birthday , 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as birthday_format
                                FROM (
                                    SELECT ROWNUM AS rn, dn.* 
                                        FROM (
                                            SELECT dn.* 
                                                FROM (
									                {0}
                                                    {1}
                                                    {2}
									                ) dn
                                            ORDER BY dn./*#SORT_ORDER*/ /*#SORT_DIRECTION*/
                                            ) dn
                                    ) dn
                                WHERE rn BETWEEN :start_row AND :end_row "
        Dim sqlTotal As String = "SELECT count(id) from ( {0} {1} {2} ) dn"


        If (Not String.IsNullOrEmpty(_REQUEST("nationnumber")) And Not String.IsNullOrEmpty(_REQUEST("extnumber"))) Then
            sqlRecord = String.Format(sqlRecord, sql1, sql, sql2)
            sqlTotal = String.Format(sqlTotal, sql1, sql, sql2)
        ElseIf (Not String.IsNullOrEmpty(_REQUEST("nationnumber"))) Then
            sqlRecord = String.Format(sqlRecord, sql1, "", "")
            sqlTotal = String.Format(sqlTotal, sql1, "", "")
        ElseIf (Not String.IsNullOrEmpty(_REQUEST("extnumber"))) Then
            sqlRecord = String.Format(sqlRecord, sql2, "", "")
            sqlTotal = String.Format(sqlTotal, sql2, "", "")
            'ElseIf (Not String.IsNullOrEmpty(_REQUEST("donornumber"))) Then
            '    sqlRecord = String.Format(sqlRecord, sql1, sql, sql2)
            '    sqlTotal = String.Format(sqlTotal, sql1, sql, sql2)
        Else
            sqlRecord = String.Format(sqlRecord, sql1, sql, sql2)
            sqlTotal = String.Format(sqlTotal, sql1, sql, sql2)
        End If

        param.Add(":start_row", DbType.String, (intItemPerPage * _REQUEST("p")) - (intItemPerPage - 1))
        param.Add(":end_row", DbType.String, (intItemPerPage * _REQUEST("p")))
        param.Add("#SORT_ORDER", _REQUEST("so"))
        param.Add("#SORT_DIRECTION", _REQUEST("sd"))

        SearchItem.TotalPage = Math.Ceiling(CDec(Cbase.QueryField(sqlTotal, param)) / CDec(intItemPerPage))

        For Each dRow As DataRow In Cbase.QueryTable(sqlRecord, param).Rows
            DonorSearchItem = New DonorSearchItem
            DonorSearchItem.ID = dRow("id").ToString()
            DonorSearchItem.DonorNumber = dRow("donor_number").ToString()
            DonorSearchItem.NationNumber = dRow("nation_number").ToString()
            DonorSearchItem.ExternalNumber = dRow("external_number").ToString()
            DonorSearchItem.Name = dRow("name").ToString()
            DonorSearchItem.Surname = dRow("surname").ToString()
            DonorSearchItem.Birthday = dRow("birthday").ToString()
            DonorSearchItem.BloodGroup = dRow("Blood_Group").ToString()
            DonorSearchItem.BirthdayFormat = dRow("birthday_format").ToString()

            SearchItem.SearchList.Add(DonorSearchItem)
        Next

        If (SearchItem.GoNext = "Y" And SearchItem.SearchList.Count > 0) Then
            sql = "select nvl(count(DV.id),0) as visit_count, dor.id, dor.Name, dor.Surname 
                    from donor dor
                    left join donation_visit dv on DV.donor_id = dor.id and to_char(dv.create_date,'yyyyMMdd') = to_char(sysdate,'yyyyMMdd')
                    where dor.id = '" & SearchItem.SearchList(0).ID & "' 
                    GROUP BY dor.Name, dor.Surname, dor.id "
            Dim dt As DataTable = Cbase.QueryTable(sql, param)
            If dt.Rows.Count > 0 Then
                If dt.Rows(0)("visit_count").ToString() <> "0" Then
                    SearchItem.Duplicate = "วันนี้คุณ " & dt.Rows(0)("name").ToString() & " " & dt.Rows(0)("surname").ToString() & " ทำการลงทะเบียนไปแล้ว"
                End If
            End If
        End If

        JSONResponse.setItems(Of SearchItem)(SearchItem)

    End Sub
    Private Sub getDonateReward()
        '### Generate Donate Record
        Dim DRWRList As New List(Of DonateRecordWithRewardItem)
        If (Not String.IsNullOrEmpty(_REQUEST("donatenumber"))) Then
            Dim intLastRecord As Integer = H2G.Convert(Of Integer)(_REQUEST("lastrecord")) + 1
            Dim DRWRItem As DonateRecordWithRewardItem
            For i = intLastRecord To (H2G.Convert(Of Integer)(_REQUEST("donatenumber")) + intLastRecord) - 1
                DRWRItem = New DonateRecordWithRewardItem
                DRWRItem.DonationDate = H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("donatedate").Replace("/", "-"))).ToString("dd/MM/yyyy")
                DRWRItem.DonationNumber = i
                DRWRItem.DonationFrom = "EXTERNAL"
                DRWRItem.DonationRewardList = New List(Of RewardItem)
                DRWRList.Add(DRWRItem)
            Next

            '### Reward record
            Dim sql As String = ""
            Dim RewardItem As RewardItem
            For Each item As DonateRecordWithRewardItem In DRWRList
                sql = "select id, donation_number, start_date, end_date, description from reward 
                                    where donation_number = " & item.DonationNumber & " 
                                    or (start_date <= to_date('" & item.DonationDate & "','dd/mm/yyyy') and end_date >= to_date('" & item.DonationDate & "','dd/mm/yyyy'))"

                For Each dRow As DataRow In Cbase.QueryTable(sql).Rows
                    RewardItem = New RewardItem
                    RewardItem.ID = dRow("id").ToString
                    RewardItem.Description = dRow("description").ToString
                    RewardItem.DonationNumber = dRow("donation_number").ToString
                    item.DonationRewardList.Add(RewardItem)
                Next
            Next
        End If

        JSONResponse.setItems(Of List(Of DonateRecordWithRewardItem))(DRWRList)

    End Sub
    Private Sub historicalFileData()
        Dim donn_numero As String = _REQUEST("donn_numero")
        'Dim donn_numero As String = "1004230339"

        Dim sql As String = "select pexamen.pex_lib show_exam,
                                        decode(substr(dossex.dex_res,1,1),'*',
                                        presultat.pres_aff||replace(substr(dossex.dex_res,instr(dossex.dex_res,chr(27))),
                                        chr(27)||substr(presultat.pres_aff,instr(presultat.pres_aff,'*'),
                                        (length(presultat.pres_aff)-instr(presultat.pres_aff,':')+2)),'/'),presultat.pres_aff) show_result,
                                        to_char(dossex.dex_dtpdet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_firstdate,
                                        to_char(dossex.dex_dtddet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_lastdate,
                                        dossex.dex_nbdet show_totaltest,
                                        dossex.dex_numpdet show_firstsample,dossex.dex_numddet show_lastsample,
                                        decode(plabo_first.plabo_lib,null,'',dossex.dex_labpdet||'-'||plabo_first.plabo_lib) show_firstlabolatory,
                                        decode(plabo_last.plabo_lib,null,'',dossex.dex_labddet||'-'||plabo_last.plabo_lib) show_lastlabolatory,
                                        pexamen.pex_unitres show_unit
                                        from dossex inner join pexamen on trim(dossex.dex_exam) = trim(pexamen.pex_cd)
                                        inner join presultat on  trim(presultat.pfres_cd) = trim(pexamen.pex_famres)
                                        and nvl(trim(substr(dossex.dex_res,0,instr(dossex.dex_res,chr(27))-1)),trim(dossex.dex_res)) = trim(presultat.pres_cd)
                                        left join plabo plabo_first  on dossex.dex_labpdet = plabo_first.plabo_cd
                                        left join plabo plabo_last on dossex.dex_labddet = plabo_last.plabo_cd
                                        where dossex.donn_numero = get_hiig_donor('" & donn_numero & "')
                                        order by dex_exam"

        Dim dt As DataTable = Hbase.QueryTable(sql)
        Dim HistoricalFlieList As New List(Of HistoricalFlie)
        For Each dr As DataRow In dt.Rows
            Dim Item As New HistoricalFlie
            Item.Exams = dr("show_exam").ToString
            Item.Result = dr("show_result").ToString
            Item.DateOfFirstDet = dr("show_firstdate").ToString
            Item.DateOfLastDet = dr("show_lastdate").ToString
            Item.SamplesTested = dr("show_totaltest").ToString
            Item.FirstSample = dr("show_firstsample").ToString
            Item.LastSample = dr("show_lastsample").ToString
            Item.FirstAuthorisingLab = dr("show_firstlabolatory").ToString
            Item.LastAuthorisingLab = dr("show_lastlabolatory").ToString

            HistoricalFlieList.Add(Item)
        Next
        JSONResponse.setItems(Of List(Of HistoricalFlie))(HistoricalFlieList)

    End Sub
    Private Sub immunohaemtologyDataSet1()
        Dim donn_numero As String = _REQUEST("donn_numero")
        Dim sql As String = "select pparecr.rsx_lib,a.dex_res,pparecr.rsx_cd 
                                from pparecr left join 
                                (select * from dossex where dossex.donn_numero = get_hiig_donor('" & donn_numero & "')) a on  a.dex_exam = pparecr.rsx_cd 
                                where  ((pparecr.ppe_site = '9999') 
                                and (pparecr.ppe_masque = 'DOSSIH')) and pparecr.ppe_type = 0
                                order by pparecr.ppe_champ"
        Dim dt As DataTable = Hbase.QueryTable(sql)
        Dim ImmunohaemtologyDataSet1List As New List(Of ImmunohaemtologyDataSet1)
        For Each dr As DataRow In dt.Rows
            Dim Item As New ImmunohaemtologyDataSet1
            Item.Rsx_Lib = dr("RSX_LIB").ToString
            Item.Dex_Res = dr("DEX_RES").ToString
            Item.Rsx_Cd = dr("RSX_CD").ToString

            ImmunohaemtologyDataSet1List.Add(Item)
        Next
        JSONResponse.setItems(Of List(Of ImmunohaemtologyDataSet1))(ImmunohaemtologyDataSet1List)

    End Sub
    Private Sub immunohaemtologyDataSet2()
        Dim donn_numero As String = _REQUEST("donn_numero")
        'donn_numero = "1004230339"
        Dim sql As String = "select  pparecr.rsx_lib,presumex.rsx_type,
                                        replace(rsx_liste,chr(0),'') result_decode
                                        from pparecr inner join presumex on pparecr.rsx_cd = presumex.rsx_cd 
                                        where ((pparecr.ppe_site = '9999') and 
                                        (pparecr.ppe_masque = 'DOSSIH')) and pparecr.ppe_type = 1 
                                        order by pparecr.ppe_champ"

        Dim dt As DataTable = Hbase.QueryTable(sql)
        Dim ImmunohaemtologyDataSet2List As New List(Of ImmunohaemtologyDataSet2)

        For Each dr As DataRow In dt.Rows
            Dim Item As New ImmunohaemtologyDataSet2
            Dim ResultDecode As String = ""
            If dr("RSX_TYPE").ToString = "3" Then
                Dim Decode As String = dr("RESULT_DECODE").ToString
                Dim ResultDecodeList() As String = Decode.Split(New Char() {Chr(27)}, StringSplitOptions.RemoveEmptyEntries)

                For Each Ar As String In ResultDecodeList
                    Dim sql3 As String = "SELECT dex_res FROM DOSSEX WHERE DONN_NUMERO = '" & donn_numero & "' AND DEX_EXAM = '" & Ar & "'"
                    Dim ResultData As String = Hbase.QueryField(sql3)
                    ResultDecode += ResultData
                Next

            ElseIf dr("RSX_TYPE").ToString = "G" Then
                Dim DecodeG As String = dr("RESULT_DECODE").ToString
                Dim ResultDecodeListG() As String = DecodeG.Split(New Char() {Chr(27)}, StringSplitOptions.RemoveEmptyEntries)
                For Each ArG As String In ResultDecodeListG
                    Dim sqlG As String = "select pexamen.pex_libedit||trim(dossex.dex_res) show_result, dex_exam
                                                      from dossex inner join pexamen on trim(dossex.dex_exam) = trim(pexamen.pex_cd)
                                                      where dossex.donn_numero = '" & donn_numero & "' and dex_exam ='" & ArG & "'"
                    Dim ResultData As String = Hbase.QueryField(sqlG)
                    ResultDecode += ResultData
                Next

            ElseIf dr("RSX_TYPE").ToString = "I" Then
                Dim DecodeI As String = dr("RESULT_DECODE").ToString
                Dim ResultDecodeListI() As String = DecodeI.Split(New Char() {Chr(27)}, StringSplitOptions.RemoveEmptyEntries)
                For Each ArI As String In ResultDecodeListI
                    Dim sqlI As String = "select presultat.pres_dnageneric||pnmdp.pnmdp_cd
                                                        from dossex 
                                                        inner join pexamen on dossex.dex_exam = pexamen.pex_cd
                                                        inner join presultat on presultat.pfres_cd = pexamen.pex_famres
                                                        and presultat.pres_cd = cast(substr(dossex.dex_res,0,instr(dossex.dex_res,chr(27))-1)as char(10)) 
                                                        inner join pnmdp on ((pnmdp.pnmdp_alleles= replace(substr(dossex.dex_res,2,length(dossex.dex_res)-2),chr(27)||'*','/')) 
                                                        or (pnmdp.pnmdp_alleles=replace(replace(substr(dossex.dex_res,2,length(dossex.dex_res)-2),chr(27)||'*','/'),substr(presultat.pres_dnageneric,instr(presultat.pres_dnageneric,'*')+1,length(presultat.pres_dnageneric))||':','')))
                                                        where dossex.donn_numero = '" & donn_numero & "' and dex_exam = '" & ArI & "'"

                    Dim ResultData As String = Hbase.QueryField(sqlI)
                    ResultDecode += ResultData
                Next

            End If

            Item.Rsx_Lib = dr("RSX_LIB").ToString
            Item.Rsx_Type = dr("RSX_TYPE").ToString
            Item.Result_Decode = ResultDecode 'dr("RESULT_DECODE").ToString

            ImmunohaemtologyDataSet2List.Add(Item)
        Next
        JSONResponse.setItems(Of List(Of ImmunohaemtologyDataSet2))(ImmunohaemtologyDataSet2List)

    End Sub
    Private Sub examsData()
        Dim donn_numero As String = _REQUEST("donn_numero")
        Dim sql As String = "select donexam.donn_incr,to_char(donexam.prelx_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') lab_date,
                            donexam.prel_no,pexamen.pex_libaff,presultat.pres_aff,plabo.plabo_cd||':'||plabo.plabo_lib AS executing_lab,pcatdon.pcatd_lib,
                            decode(trim(substr(donexam.prelx_sign,1,10)),'',null,substr(donexam.prelx_sign,1,10)) test_by1,
                            decode(trim(substr(donexam.prelx_sign,11,10)),'',null,substr(donexam.prelx_sign,11,10)) test_by2,donexam.prelx_signval validate_by
                            from don inner join donexam on don.donn_numero = donexam.donn_numero and don.don_incr = donexam.donn_incr
                            inner join pcatdon on don.pcatd_cd = pcatdon.pcatd_cd
                            inner join plabo on donexam.prelx_labo = plabo.plabo_cd
                            inner join pexamen on trim(donexam.prelx_exam) = trim(pexamen.pex_cd)
                            inner join presultat on trim(pexamen.pex_famres) = trim(presultat.pfres_cd) and  trim(donexam.prelx_rqual) = trim(presultat.pres_cd)
                            where don.donn_numero = get_hiig_donor('" & donn_numero & "')
                            order by donexam.donn_incr desc,donexam.prelx_incr"

        Dim dt As DataTable = Hbase.QueryTable(sql)
        Dim ExamsDataList As New List(Of ExamsData)
        For Each dr As DataRow In dt.Rows
            Dim Item As New ExamsData
            Item.DonnIncr = dr("donn_incr").ToString
            Item.LabDate = dr("lab_date").ToString
            Item.PrelNo = dr("prel_no").ToString
            Item.PcatdLib = dr("pcatd_lib").ToString
            Item.PexLibAff = dr("pex_libaff").ToString
            Item.PresAff = dr("pres_aff").ToString
            Item.ExecutingLab = dr("executing_lab").ToString
            Item.TestBy1 = dr("test_by1").ToString
            Item.TestBy2 = dr("test_by2").ToString
            Item.TestBy3 = dr("validate_by").ToString

            ExamsDataList.Add(Item)
        Next
        JSONResponse.setItems(Of List(Of ExamsData))(ExamsDataList)

    End Sub
    Private Sub donorPostQueue()
        Dim PostQueueItem As New PostQueueSearchItem
        PostQueueItem.GoNext = "N"
        PostQueueItem.PostQueueList = New List(Of PostQueueItem)
        Dim Item As PostQueueItem
        Dim intItemPerPage As Integer = 20
        Dim intTotalPage As Integer = 1

        If Not String.IsNullOrEmpty(_REQUEST("queuenumber")) Then
            If (String.IsNullOrEmpty(_REQUEST("receipthospitalid"))) Then
                param.Add("#QUEUE_NUMBER", " and to_char(dv.queue_number) like '" & _REQUEST("queuenumber") & "' ")
            Else
                param.Add("#QUEUE_NUMBER", " and to_char(dv.order_number) like '" & _REQUEST("queuenumber") & "' ")
            End If
            If Not _REQUEST("queuenumber").ToString.Contains("%") Then
                PostQueueItem.GoNext = "Y"
            End If
        End If
        If Not String.IsNullOrEmpty(_REQUEST("donornumber")) Then
            param.Add("#DONOR_NUMBER", " and UPPER(dn.donor_number) like UPPER('" & _REQUEST("donornumber") & "') ")
            If Not _REQUEST("donornumber").ToString.Contains("%") Then
                PostQueueItem.GoNext = "Y"
            End If
        End If
        If Not String.IsNullOrEmpty(_REQUEST("nationnumber")) Then
            param.Add("#NATION_NUMBER", " and UPPER(dexc.card_number) like UPPER('" & _REQUEST("nationnumber") & "') ")
            If Not _REQUEST("nationnumber").ToString.Contains("%") Then
                PostQueueItem.GoNext = "Y"
            End If
        End If
        If Not String.IsNullOrEmpty(_REQUEST("name")) Then param.Add("#NAME", " and (UPPER(dn.name) like UPPER('" & _REQUEST("name") & "') or UPPER(dn.name_e) like UPPER('" & _REQUEST("name") & "')) ")
        If Not String.IsNullOrEmpty(_REQUEST("surname")) Then param.Add("#SURNAME", " and (UPPER(dn.surname) like UPPER('" & _REQUEST("surname") & "') or UPPER(dn.surname_e) like UPPER('" & _REQUEST("surname") & "')) ")
        If Not String.IsNullOrEmpty(_REQUEST("birthday")) Then param.Add("#BIRTHDAY", "and to_char(dn.birthday, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("birthday") & "' ")
        If Not String.IsNullOrEmpty(_REQUEST("bloodgroup")) Then param.Add("#BLOOD_GROUP", " and UPPER(rg.description) like UPPER('" & _REQUEST("bloodgroup") & "') ")
        If Not String.IsNullOrEmpty(_REQUEST("samplenumber")) Then param.Add("#SAMPLE_NUMBER", " and UPPER(DV.SAMPLE_NUMBER) like UPPER('" & _REQUEST("samplenumber") & "') ")

        If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then
            param.Add("#REPORT_DATE", "and to_char(nvl(dv.VISIT_DATE,dv.CREATE_DATE), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("reportdate") & "' ")
        End If

        If Not String.IsNullOrEmpty(_REQUEST("status")) Then param.Add("#STATUS", " and dv.status = '" & _REQUEST("status") & "' ")

        Dim sqlRecord As String = "SQL::donor\SelectVisitPostQueue"
        Dim sqlTotal As String = "SQL::donor\SelectVisitPostQueueCount"
        If (Not String.IsNullOrEmpty(_REQUEST("receipthospitalid"))) Then
            sqlRecord = "SQL::donor\SelectHospitalPostQueue"
            sqlTotal = "SQL::donor\SelectHospitalPostQueueCount"
        End If

        If Not String.IsNullOrEmpty(_REQUEST("receipthospitalid")) Then param.Add(":receipt_hospital_id", _REQUEST("receipthospitalid"))
        param.Add(":start_row", DbType.String, (intItemPerPage * _REQUEST("p")) - (intItemPerPage - 1))
        param.Add(":start_row", DbType.String, (intItemPerPage * _REQUEST("p")) - (intItemPerPage - 1))
        param.Add(":end_row", DbType.String, (intItemPerPage * _REQUEST("p")))
        param.Add("#SORT_ORDER", _REQUEST("so"))
        param.Add("#SORT_DIRECTION", _REQUEST("sd"))

        PostQueueItem.TotalPage = Math.Ceiling(CDec(Cbase.QueryField(sqlTotal, param, "0")) / CDec(intItemPerPage))

        For Each dRow As DataRow In Cbase.QueryTable(sqlRecord, param).Rows
            Item = New PostQueueItem
            Item.VisitID = dRow("visit_id").ToString()
            Item.DonorID = dRow("donor_id").ToString()
            Item.QueueNumber = dRow("QUEUE_NUMBER").ToString()
            Item.Name = dRow("name").ToString()
            Item.SampleNumber = dRow("SAMPLE_NUMBER").ToString()
            Item.Comment = dRow("COMMENT_TEXT").ToString()
            Item.RegisTime = dRow("regis_time").ToString().Replace(",", ":")
            Item.RegisStaff = dRow("regis_staff").ToString()
            Item.InterviewTime = dRow("INTERVIEW_time").ToString().Replace(",", ":")
            Item.InterviewStaff = dRow("INTERVIEW_STAFF").ToString()
            Item.CollectionTime = dRow("collection_time").ToString().Replace(",", ":")
            Item.CollectionStaff = dRow("collection_staff").ToString()
            Item.LabTime = dRow("lab_time").ToString().Replace(",", ":")
            Item.LabStaff = dRow("lab_staff").ToString()

            PostQueueItem.PostQueueList.Add(Item)
        Next

        JSONResponse.setItems(Of PostQueueSearchItem)(PostQueueItem)

    End Sub
    Private Sub visitHistory()
        Dim HistoryList As New List(Of VisitHistoryItem)
        Dim Item As VisitHistoryItem

        Dim sqlRecord As String = "
                    select dn.visit_id, dn.DONATION_NUMBER, to_char(dn.VISIT_DATE, 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as VISIT_DATE 
                    , dn.DONATION_TYPE, dn.bag, dn.site, dn.COLLECTION_POINT, dn.CREATE_STAFF
                    , dn.INTERVIEW_STAFF, dn.INTERVIEW_STATUS, dn.sample_number
                    , to_char(dn.lab_date, 'DD MON YYYY HH24,MI', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as lab_date
                    from (
                        Select dv.id as visit_id, dr.DONATION_NUMBER, nvl(DV.VISIT_DATE, dv.create_date) As VISIT_DATE, DT.DESCRIPTION As DONATION_TYPE
                        , ba.description as bag, si.code as site, cp.code as COLLECTION_POINT, crs.firstname || ' ' || crs.lastname as CREATE_STAFF
                        , ins.firstname || ' ' || ins.lastname as INTERVIEW_STAFF, dv.INTERVIEW_STATUS, dr.lab_date, dv.sample_number
                        From DONATION_VISIT dv
                        Left Join DONATION_RECORD dr on dr.DONATION_VISIT_id = dv.id
                        Left Join DONATION_TYPE dt on dt.id = dv.DONATION_TYPE_ID
                        Left Join bag ba on ba.id = dv.BAG_ID
                        Left Join site si on si.id = dv.site_ID
                        Left Join COLLECTION_POINT cp on cp.id = dv.COLLECTION_POINT_ID
                        Left Join STAFF crs on crs.id = dv.CREATE_STAFF
                        Left Join STAFF ins on ins.id = dv.INTERVIEW_STAFF
                        where dv.donor_id = '" & _REQUEST("id") & "'
                    ) dn 
                    ORDER BY dn./*#SORT_ORDER*/ /*#SORT_DIRECTION*/
                    "
        param.Add(":id", _REQUEST("id"))
        param.Add("#SORT_ORDER", _REQUEST("so"))
        param.Add("#SORT_DIRECTION", _REQUEST("sd"))

        For Each dRow As DataRow In Cbase.QueryTable(sqlRecord, param).Rows
            Item = New VisitHistoryItem
            Item.VisitID = dRow("visit_id").ToString()
            Item.Bag = dRow("bag").ToString()
            Item.CollectionPoint = dRow("COLLECTION_POINT").ToString()
            Item.CreateStaff = dRow("CREATE_STAFF").ToString()
            Item.DonationNumber = dRow("DONATION_NUMBER").ToString()
            Item.DonationType = dRow("DONATION_TYPE").ToString()
            Item.InterviewStaff = dRow("INTERVIEW_STAFF").ToString()
            Item.InterviewStatus = dRow("INTERVIEW_STATUS").ToString()
            Item.LabDate = dRow("lab_date").ToString().Replace(",", ":")
            Item.SampleNumber = dRow("sample_number").ToString()
            Item.Site = dRow("site").ToString()
            Item.VisitDate = dRow("VISIT_DATE").ToString()

            HistoryList.Add(Item)
        Next

        JSONResponse.setItems(Of List(Of VisitHistoryItem))(HistoryList)

    End Sub
    Private Sub loadSynthesisSet1()
        Dim SynthesisData As New SynthesisListData
        Dim donn_numero As String = _REQUEST("donn_numero")
        Dim sql As String = "select donate_date, dornor_type, deferral_code, dornor_rank, pressure, dmed_site, dmed_coll, dmed_refus from 
                            (
                            select 
                            to_char(don.don_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') donate_date, 
                            trim(don.pcatd_cd)||'/'||trim(don.ptypp_cd)||'/'||trim(don.putd_cd) dornor_type,
                            '' deferral_code,
                            to_char(don.don_incr) dornor_rank,
                            decode(dossmed.dmed_tmax,null,'',dossmed.dmed_tmax||'/'||dossmed.dmed_tmin) pressure, dossmed.dmed_site, dossmed.dmed_coll, dossmed.dmed_refus
                            from donneur inner join don on donneur.donn_numero = don.donn_numero
                            left join dossmed on don.prel_no = dossmed.prel_no
                            where donneur.donn_numero = '" & donn_numero & "'
                            union all
                            select to_char(cids.cids_dtcre, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') donate_date,
                            'Refused' dornor_type,
                            cids.pcids_cd deferral_code,
                            '' rank,
                            decode(dossmed.dmed_tmax,null,'',dossmed.dmed_tmax||'/'||dossmed.dmed_tmin) pressure, dossmed.dmed_site, dossmed.dmed_coll, dossmed.dmed_refus
                            from cids left join dossmed
                            on cids.donn_numero = dossmed.donn_numero and to_char(cids.cids_dtcre ,'ddmmyyyy') = to_char(dossmed.dmed_dte,'ddmmyyyy')
                            where cids.donn_numero ='" & donn_numero & "'
                            ) order by to_date(donate_date,'dd-mm-yyyy') desc"

        Dim dt As DataTable = Hbase.QueryTable(sql)
        SynthesisData.SynthesisSet1 = New List(Of SynthesisStatement1)
        SynthesisData.SynthesisSet2 = New List(Of SynthesisStatement2)

        For Each dr As DataRow In dt.Rows
            Dim Item As New SynthesisStatement1
            Item.donate_date = dr("DONATE_DATE").ToString
            Item.dornor_type = dr("DORNOR_TYPE").ToString
            Item.deferral_code = dr("DEFERRAL_CODE").ToString
            Item.dornor_rank = dr("DORNOR_RANK").ToString
            Item.pressure = dr("PRESSURE").ToString
            Item.dmed_coll = dr("DMED_COLL").ToString
            Item.dmed_refus = dr("DMED_REFUS").ToString
            Item.dmed_site = dr("DMED_SITE").ToString

            SynthesisData.SynthesisSet1.Add(Item)

            If dr("DORNOR_RANK").ToString <> "" Then
                Dim subSql As String = "select to_char(d.prelx_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') display_date,pparecr.ppe_type,pparecr.rsx_cd show_value,pparecr.rsx_lib show_label,
                                                    decode(d.exam_code,'ABODD',d.prelx_rqual||(select prelx_rqual from donexam 
                                                    where donn_numero = '" & donn_numero & "' and donn_incr = '" & dr("DORNOR_RANK").ToString & "' and trim(prelx_exam)='AGDTDM'),d.prelx_rqual) display_result
                                                    from pparecr left join 
                                                    (select decode(trim(prelx_exam),'DABO','ABODD',prelx_exam) exam_code,
                                                     prelx_rqual,prelx_date 
                                                     from donexam 
                                                     where ((donexam.donn_numero = '" & donn_numero & "') and (donexam.donn_incr = '" & dr("DORNOR_RANK").ToString & "'))) d
                                                    on trim(pparecr.rsx_cd) = trim(d.exam_code)
                                                    left join presumex on trim(pparecr.rsx_cd) = trim(presumex.rsx_cd)
                                                    where ((pparecr.ppe_site = '" & dr("DMED_SITE").ToString & "') and (pparecr.ppe_masque IN ('PRELEM','PRELVI','PRELIH')))"

                Dim ct As DataTable = Hbase.QueryTable(subSql)
                For Each cr As DataRow In ct.Rows
                    Dim ItemCol As New SynthesisStatement2
                    ItemCol.display_date = cr("DISPLAY_DATE").ToString
                    ItemCol.ppe_type = cr("PPE_TYPE").ToString
                    ItemCol.show_value = cr("SHOW_VALUE").ToString
                    ItemCol.show_label = cr("SHOW_LABEL").ToString
                    ItemCol.show_gen_label = (cr("SHOW_LABEL").ToString).Replace(" ", "-") & "-" & dr("DORNOR_RANK").ToString
                    ItemCol.display_result = cr("DISPLAY_RESULT").ToString

                    SynthesisData.SynthesisSet2.Add(ItemCol)
                Next
            End If
        Next
        JSONResponse.setItems(Of SynthesisListData)(SynthesisData)

    End Sub
    Private Sub getDonateSite()
        Dim siteCode As String = _REQUEST("siteCode")
        Dim sql As String = "select COLL_LIBELLE from collectivite where coll_cd = '" & siteCode & "'"
        Dim ResultData As String = Hbase.QueryField(sql)
        JSONResponse.setItems("{""site"" : """ & ResultData & """}")

    End Sub
    Private Sub immunohaemtologyDataSetDate()
        Dim donn_numero As String = _REQUEST("donn_numero")
        'donn_numero = "1004230339"
        Dim DateList As New ImmunohaemtologyDateData
        Dim Sql1 As String = "select pexamen.pex_lib show_exam,
                            decode(substr(dossex.dex_res,1,1),'*',
                            presultat.pres_aff||replace(substr(dossex.dex_res,instr(dossex.dex_res,chr(27))),
                            chr(27)||substr(presultat.pres_aff,instr(presultat.pres_aff,'*'),
                            (length(presultat.pres_aff)-instr(presultat.pres_aff,':')+2)),'/'),presultat.pres_aff) show_result,
                            to_char(dossex.dex_dtpdet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_firstdate,
                            to_char(dossex.dex_dtddet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_lastdate,
                            dossex.dex_nbdet show_totaltest,
                            dossex.dex_numpdet show_firstsample,dossex.dex_numddet show_lastsample,
                            decode(plabo_first.plabo_lib,null,'',dossex.dex_labpdet||'-'||plabo_first.plabo_lib) show_firstlabolatory,
                            decode(plabo_last.plabo_lib,null,'',dossex.dex_labddet||'-'||plabo_last.plabo_lib) show_lastlabolatory,
                            pexamen.pex_unitres show_unit
                            from dossex inner join pexamen on trim(dossex.dex_exam) = trim(pexamen.pex_cd)
                            inner join presultat on  trim(presultat.pfres_cd) = trim(pexamen.pex_famres)
                            and nvl(trim(substr(dossex.dex_res,0,instr(dossex.dex_res,chr(27))-1)),trim(dossex.dex_res)) = trim(presultat.pres_cd)
                            left join plabo plabo_first  on dossex.dex_labpdet = plabo_first.plabo_cd
                            left join plabo plabo_last on dossex.dex_labddet = plabo_last.plabo_cd
                            where dossex.donn_numero = get_hiig_donor('" & donn_numero & "') AND pexamen.pex_lib = 'ABO grouping'
                            order by dex_exam"
        Dim ct As DataTable = Hbase.QueryTable(Sql1)
        DateList.abod = New List(Of DateDataList)
        For Each dr As DataRow In ct.Rows
            Dim Item As New DateDataList
            Item.no = dr("SHOW_TOTALTEST").ToString
            Item.firstDate = dr("SHOW_FIRSTDATE").ToString
            Item.lastDate = dr("SHOW_LASTDATE").ToString

            DateList.abod.Add(Item)
        Next



        Dim sql2 As String = "select MIN(SHOW_FIRSTDATE) SHOW_FIRSTDATE,MAX(SHOW_LASTDATE) SHOW_LASTDATE,MAX(SHOW_TOTALTEST) SHOW_TOTALTEST FROM
                            (select pexamen.pex_lib show_exam,
                            decode(substr(dossex.dex_res,1,1),'*',
                            presultat.pres_aff||replace(substr(dossex.dex_res,instr(dossex.dex_res,chr(27))),
                            chr(27)||substr(presultat.pres_aff,instr(presultat.pres_aff,'*'),
                            (length(presultat.pres_aff)-instr(presultat.pres_aff,':')+2)),'/'),presultat.pres_aff) show_result,
                            to_char(dossex.dex_dtpdet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_firstdate,
                            to_char(dossex.dex_dtddet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_lastdate,
                            dossex.dex_nbdet show_totaltest,
                            dossex.dex_numpdet show_firstsample,dossex.dex_numddet show_lastsample,
                            decode(plabo_first.plabo_lib,null,'',dossex.dex_labpdet||'-'||plabo_first.plabo_lib) show_firstlabolatory,
                            decode(plabo_last.plabo_lib,null,'',dossex.dex_labddet||'-'||plabo_last.plabo_lib) show_lastlabolatory,
                            pexamen.pex_unitres show_unit
                            from dossex inner join pexamen on trim(dossex.dex_exam) = trim(pexamen.pex_cd)
                            inner join presultat on  trim(presultat.pfres_cd) = trim(pexamen.pex_famres)
                            and nvl(trim(substr(dossex.dex_res,0,instr(dossex.dex_res,chr(27))-1)),trim(dossex.dex_res)) = trim(presultat.pres_cd)
                            left join plabo plabo_first  on dossex.dex_labpdet = plabo_first.plabo_cd
                            left join plabo plabo_last on dossex.dex_labddet = plabo_last.plabo_cd
                            where dossex.donn_numero = get_hiig_donor('" & donn_numero & "') AND pexamen.pex_lib like 'Antigen%'
                            order by dex_exam)"
        Dim ct2 As DataTable = Hbase.QueryTable(sql2)
        DateList.extPheno = New List(Of DateDataList)
        For Each dr As DataRow In ct2.Rows
            Dim Item As New DateDataList
            Item.no = dr("SHOW_TOTALTEST").ToString
            Item.firstDate = dr("SHOW_FIRSTDATE").ToString
            Item.lastDate = dr("SHOW_LASTDATE").ToString

            DateList.extPheno.Add(Item)
        Next

        Dim sql3 As String = "select MIN(SHOW_FIRSTDATE) SHOW_FIRSTDATE,MAX(SHOW_LASTDATE) SHOW_LASTDATE,MAX(SHOW_TOTALTEST) SHOW_TOTALTEST FROM
                            (select pexamen.pex_lib show_exam,
                            decode(substr(dossex.dex_res,1,1),'*',
                            presultat.pres_aff||replace(substr(dossex.dex_res,instr(dossex.dex_res,chr(27))),
                            chr(27)||substr(presultat.pres_aff,instr(presultat.pres_aff,'*'),
                            (length(presultat.pres_aff)-instr(presultat.pres_aff,':')+2)),'/'),presultat.pres_aff) show_result,
                            to_char(dossex.dex_dtpdet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_firstdate,
                            to_char(dossex.dex_dtddet, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') show_lastdate,
                            dossex.dex_nbdet show_totaltest,
                            dossex.dex_numpdet show_firstsample,dossex.dex_numddet show_lastsample,
                            decode(plabo_first.plabo_lib,null,'',dossex.dex_labpdet||'-'||plabo_first.plabo_lib) show_firstlabolatory,
                            decode(plabo_last.plabo_lib,null,'',dossex.dex_labddet||'-'||plabo_last.plabo_lib) show_lastlabolatory,
                            pexamen.pex_unitres show_unit
                            from dossex inner join pexamen on trim(dossex.dex_exam) = trim(pexamen.pex_cd)
                            inner join presultat on  trim(presultat.pfres_cd) = trim(pexamen.pex_famres)
                            and nvl(trim(substr(dossex.dex_res,0,instr(dossex.dex_res,chr(27))-1)),trim(dossex.dex_res)) = trim(presultat.pres_cd)
                            left join plabo plabo_first  on dossex.dex_labpdet = plabo_first.plabo_cd
                            left join plabo plabo_last on dossex.dex_labddet = plabo_last.plabo_cd
                            where dossex.donn_numero = get_hiig_donor('" & donn_numero & "') AND pexamen.pex_lib like '%Antibody screen%'
                            order by dex_exam)"
        Dim ct3 As DataTable = Hbase.QueryTable(sql3)
        DateList.abScreen = New List(Of DateDataList)
        For Each dr As DataRow In ct3.Rows
            Dim Item As New DateDataList
            Item.no = dr("SHOW_TOTALTEST").ToString
            Item.firstDate = dr("SHOW_FIRSTDATE").ToString
            Item.lastDate = dr("SHOW_LASTDATE").ToString

            DateList.abScreen.Add(Item)
        Next

        JSONResponse.setItems(Of ImmunohaemtologyDateData)(DateList)

    End Sub
    Private Sub checkVisited()
        Dim strReturn As String = ""
        Dim strReturnID As String = ""
        Dim strAgeCheck As String = ""
        If Not String.IsNullOrEmpty(_REQUEST("id")) Then param.Add("#ID", " and dor.id = '" & _REQUEST("id") & "' ")
        If Not String.IsNullOrEmpty(_REQUEST("name")) Then param.Add("#NAME", " and UPPER(dor.name) = UPPER('" & _REQUEST("name") & "')  ")
        If Not String.IsNullOrEmpty(_REQUEST("surname")) Then param.Add("#SURNAME", " and UPPER(dor.surname) = UPPER('" & _REQUEST("surname") & "') ")
        If Not String.IsNullOrEmpty(_REQUEST("birthday")) Then param.Add("#BIRTHDAY", "and to_char(dor.birthday, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("birthday") & "' ")

        Dim sql As String = "select nvl(dv.queue_number,0) as visit_count, dor.id, dor.Name, dor.Surname 
                            , to_char(VISIT_DATE, 'HH24,MI') as visit_time
                            from donor dor
                            left join donation_visit dv on DV.donor_id = dor.id 
                                and to_char(dv.visit_date,'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') = '" & H2G.Login.PlanDate & "'
                            where rownum = 1 /*#ID*/ /*#NAME*/ /*#SURNAME*/ /*#BIRTHDAY*/ 
                            order by queue_number desc "

        If Not String.IsNullOrEmpty(_REQUEST("receipthospitalid")) Then
            sql = "select nvl(dv.order_number,0) as visit_count, dor.id, dor.Name, dor.Surname 
                    , to_char(VISIT_DATE, 'HH24,MI') as visit_time
                    from donation_hospital dv
                    left Join donor dor on dv.donor_id = dor.id 
                    where rownum = 1 and dv.receipt_hospital_id = '" & _REQUEST("receipthospitalid") & "' 
                    /*#ID*/ /*#NAME*/ /*#SURNAME*/ /*#BIRTHDAY*/ 
                    order by dv.order_number desc "
        End If

        Dim dt As DataTable = Cbase.QueryTable(sql, param)
        If dt.Rows.Count > 0 Then
            If dt.Rows(0)("visit_count").ToString() <> "0" Then
                If Not String.IsNullOrEmpty(_REQUEST("receipthospitalid")) Then
                    strReturn = "คุณ " & dt.Rows(0)("name").ToString() & " " & dt.Rows(0)("surname").ToString() & " ทำการลงทะเบียนไปแล้ว ลำดับที่ " & dt.Rows(0)("visit_count").ToString() & " เวลา " & dt.Rows(0)("visit_time").ToString().Replace(",", ":")
                Else
                    strReturn = "วันที่ " & H2G.Login.PlanDate & " คุณ " & dt.Rows(0)("name").ToString() & " " & dt.Rows(0)("surname").ToString() & " ทำการลงทะเบียนไปแล้ว คิวที่ " & dt.Rows(0)("visit_count").ToString() & " เวลา " & dt.Rows(0)("visit_time").ToString().Replace(",", ":")
                End If
            End If
            strReturnID = dt.Rows(0)("id").ToString()
        End If
        If strReturnID = "" Then strReturnID = _REQUEST("id")

        '### check อายุ
        Dim minAge As Integer = 0 : Dim maxAge As Integer = 0
        dt = Cbase.QueryTable("select min_age, max_age from DONATION_TYPE dt inner join DONATION_CONDITION dc on DC.DONATION_TYPE_id = dt.id where DT.id = -1")
        If dt.Rows.Count > 0 Then
            minAge = dt.Rows(0)("min_age").ToString()
            maxAge = dt.Rows(0)("max_age").ToString()
        End If
        Dim age As Integer = H2G.calAge(H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("birthday"))))
        If age < minAge OrElse age > maxAge Then strAgeCheck = "ผู้บริจาคมีอายุ " & age & " ปี ไม่อยู่ในเกณฑ์อายุ " & minAge & "-" & maxAge & " ปี กรุณาตรวจสอบ"

        If (strAgeCheck = "" And strReturnID = "") Then
            If age > 55 Then strAgeCheck = "ผู้บริจาคมีอายุ " & age & " ปี ไม่อยู่ในเกณฑ์อายุ " & minAge & "-" & maxAge & " ปี กรุณาตรวจสอบ"
        End If

        JSONResponse.setItems("{""Duplicate"" : """ & strReturn & """, ""DonorID"" : """ & strReturnID & """, ""AgeCheck"":""" & strAgeCheck & """ }")

    End Sub

    Private Function getRunningNumber(ByVal code As String, ByVal idTableDigit As String) As String
        Dim strReturn As String = ""
        Dim base As New oraDBQuery(oraDBQuery.Schema.CLARET)
        Dim dt As DataTable = base.QueryTable("Select id,prefix_from_table,format_text,code_dummy,to_table,to_column from running_number where code='" & code & "'")
        Dim nowDate As DateTime = Now.AddYears(543)
        If dt.Rows.Count > 0 Then
            Dim strFieldDigit As String = IIf(dt.Rows(0)("format_text").ToString().Contains("CODE_3DIGIT"), "CODE_3DIGIT", "CODE_2DIGIT")
            Dim strDigit As String = base.QueryField("select " & strFieldDigit & " from " & dt.Rows(0)("prefix_from_table").ToString & " where id=" & idTableDigit & "")
            If strDigit = "" Then strDigit = dt.Rows(0)("code_dummy").ToString()
            '
            Dim tempFormat As String = dt.Rows(0)("format_text").ToString()
            tempFormat = tempFormat.Replace("YYYY", nowDate.ToString("yyyy"))
            tempFormat = tempFormat.Replace("YY", nowDate.ToString("yy"))
            tempFormat = tempFormat.Replace("MM", nowDate.ToString("MM"))
            tempFormat = tempFormat.Replace("DD", nowDate.ToString("dd"))
            tempFormat = tempFormat.Replace(strFieldDigit, strDigit)
            tempFormat = tempFormat.Replace(",", "").Replace("X", "")
            Dim sqlRunning As String = "select nvl(max(" & dt.Rows(0)("to_column") & "),'') from " & dt.Rows(0)("to_table") & " where " & dt.Rows(0)("to_column") & " like '" & tempFormat & "%' "

            Dim strOldRunning As String = base.QueryField(sqlRunning)
            '### if can't find digit from target table, Use code dummy instant.
            Dim intRunningDigit As Int16 = dt.Rows(0)("format_text").ToString.Length - dt.Rows(0)("format_text").ToString.Replace("X", "").Length
            Dim intNumber As Int64 = 1
            If Not String.IsNullOrEmpty(strOldRunning) Then intNumber = CInt(Right(strOldRunning, intRunningDigit)) + 1

            strReturn = dt.Rows(0)("format_text").ToString()
            strReturn = Left(strReturn, strReturn.Length - intRunningDigit) & New String("0"c, H2G.CountCharacter(strReturn, "X"c) - intNumber.ToString.Length) & intNumber
            strReturn = strReturn.Replace("YYYY", nowDate.ToString("yyyy"))
            strReturn = strReturn.Replace("YY", nowDate.ToString("yy"))
            strReturn = strReturn.Replace("MM", nowDate.ToString("MM"))
            strReturn = strReturn.Replace("DD", nowDate.ToString("dd"))
            strReturn = strReturn.Replace(strFieldDigit, strDigit)
            strReturn = strReturn.Replace(",", "")
        End If
        Return strReturn
    End Function

    Private Sub StrickerPrint()
        sqlMain = "select * from (
	                select dor.donor_number, case when dor.gender = 'M' then tt.title_m else tt.title_f end as title
                    , dor.gender, case when dor.gender = 'M' then 'Male' else 'Female' end as full_gender
	                , dor.name, dor.surname, dor.Address, dor.Sub_District, dor.District, dor.Province, dor.Zipcode
                    , dor.Address || ' ' || dor.Sub_District || ' ' || dor.District || ' ' || dor.Province as total_address
	                , REPLACE(REPLACE(rg.description,'+',' Rh+'),'-',' Rh-') as rh_group, dr.donation_number, nvl(dr.donation_number,0)+1 as current_donation_number
	                , REPLACE(REPLACE(SUBSTR(nvl(rg.description,''),-1,1),'+',' Rh+'),'-',' Rh-') as terminal_blood
	                , REPLACE(REPLACE(nvl(rg.description,''),'+',''),'-','') as blood_group
	                , to_char(dr.donation_date, 'DD/MM/YYYY') as donation_date, to_char(DOR.birthday, 'DD/MM/YYYY') as birthday
                    , cp.code as collection_point_code
	                from donor dor 
	                left join rh_group rg on rg.id = dor.RH_Group_ID 
	                left join title tt on tt.id = dor.title_id
	                left join donation_record dr on dr.donor_id = dor.id
                    cross join collection_point cp
	                where dor.id = '" & _REQUEST("donor_id") & "' 
	                and cp.id = '" & H2G.Login.CollectionPointID & "'
	                order by dr.id desc
                ) dn
                where rownum <= 1"

        Dim strSet As String = "[]"
        Dim dt As DataTable = Cbase.QueryTable(sqlMain)
        Thread.CurrentThread.CurrentCulture = New Globalization.CultureInfo("en-US")
        Dim dateNow As DateTime = Now
        For Each dRow As DataRow In dt.Rows
            strSet = "[{" & """Point_de_collecte"":""" & dRow("collection_point_code").ToString() & """," _
                    & """Date"":""" & dateNow.ToString("dd MMMM yyyy") & """," _
                    & """Heure"":""" & dateNow.ToString("HH") & "h" & dateNow.ToString("mm") & """," _
                    & """Numero_Donneur"":""" & dRow("donor_number").ToString() & """," _
                    & """Sexe"":""" & dRow("title").ToString() & """," _
                    & """Nom"":""" & dRow("name").ToString() & """," _
                    & """Nom_Marital"":""" & """," _
                    & """Date_de_Naissance"":""" & dRow("birthday").ToString() & """," _
                    & """Prénom"":""" & dRow("surname").ToString() & """," _
                    & """Adresse"":""" & dRow("total_address").ToString() & """," _
                    & """Code_Postal"":""" & dRow("zipcode").ToString() & """," _
                    & """Ville"":""" & """," _
                    & """Code_Routage"":""" & """," _
                    & """Région"":""" & """," _
                    & """Département"":""" & """," _
                    & """Communauté_Urbaine"":""" & """," _
                    & """Téléphone_Domicile"":""" & """," _
                    & """Téléphone_Bureau"":""" & """," _
                    & """Poste"":""" & """," _
                    & """Groupe_Sanguin"":""" & dRow("rh_group").ToString() & """," _
                    & """Phénotype"":""" & """," _
                    & """Médecin_traitant"":""" & """," _
                    & """Secrétaire"":""Dhanakoses, Preawnet" & """," _
                    & """Profession"":""เอกชน" & """," _
                    & """Catégorie"":""" & """," _
                    & """Entreprise"":""" & """," _
                    & """Poids"":""60" & """," _
                    & """Taille"":""" & """," _
                    & """Libelle_collecte"":""COLLECTION POINT TEST" & """," _
                    & """CIDS"":""" & """," _
                    & """Total_dons"":""" & dRow("donation_number").ToString() & """," _
                    & """Current_dons"":""" & dRow("current_donation_number").ToString() & """," _
                    & """Dons_ext"":""" & """," _
                    & """Date_dernier_don"":""" & """," _
                    & """Type_dernier_don"":""Whole blood, CPD-A1 TB-450" & """," _
                    & """TA_dernier_don"":""" & """," _
                    & """Numero_Donneur_code_128"":""" & dRow("donor_number").ToString() & """," _
                    & """Histo_dons_1"":""" & """," _
                    & """Histo_dons_2"":""" & """," _
                    & """Histo_dons_3"":""" & """," _
                    & """Histo_dons_4"":""" & """," _
                    & """Histo_dons_5"":""" & """," _
                    & """Histo_dons_6"":""" & """," _
                    & """Histo_dons_7"":""" & """," _
                    & """Histo_dons_8"":""" & """," _
                    & """Histo_dons_9"":""" & """," _
                    & """Histo_dons_10"":""" & """," _
                    & """Code_Pays_Naiss"":""" & """," _
                    & """Nom_Pays_Naiss"":""" & """," _
                    & """Code_Depart_Naiss"":""" & """," _
                    & """Nom_Depart_Naiss"":""" & """," _
                    & """Ville_Naiss"":""TEST" & """," _
                    & """Nom_Pere"":""Preawnet" & """," _
                    & """Nom_Mere"":""Dhanakoses" & """," _
                    & """Code_Genre"":""" & dRow("gender").ToString() & """," _
                    & """Nom_Genre"":""" & dRow("full_gender").ToString() & """," _
                    & """Adresse_Compl"":""" & dRow("address").ToString() & """," _
                    & """Identifiant_1"":""1101400167938" & """," _
                    & """Identifiant_2"":""901070904" & """," _
                    & """Cplt_Code_0"":""" & """," _
                    & """Cplt_Nom_Code 0"":""" & """," _
                    & """Cplt_Code_1"":""" & """," _
                    & """Cplt_Nom_Code 1"":""" & """," _
                    & """Cplt_Code_2"":""" & """," _
                    & """Cplt_Nom_Code 2"":""" & """," _
                    & """Cplt_Code_3"":""" & """," _
                    & """Cplt_Nom_Code 3"":""" & """," _
                    & """Cplt_Code_4"":""" & """," _
                    & """Cplt_Nom_Code 4"":""" & """," _
                    & """Cplt_Code_5"":""" & """," _
                    & """Cplt_Nom_Code 5"":""" & """," _
                    & """Cplt_Code_6"":""" & """," _
                    & """Cplt_Nom_Code 6"":""" & """," _
                    & """Cplt_Code_7"":""" & """," _
                    & """Cplt_Nom_Code 7"":""" & """," _
                    & """Cplt_Code_8"":""" & """," _
                    & """Cplt_Nom_Code 8"":""" & """," _
                    & """Cplt_Code_9"":""" & """," _
                    & """Cplt_Nom_Code 9"":""" & """," _
                    & """Cplt_Valeur_0"":""" & """," _
                    & """Cplt_Valeur_1"":""" & """," _
                    & """Cplt_Valeur_2"":""" & """," _
                    & """Cplt_Valeur_3"":""" & """," _
                    & """Cplt_Valeur_4"":""" & """," _
                    & """Cplt_Valeur_5"":""" & """," _
                    & """Cplt_Valeur_6"":""" & """," _
                    & """Cplt_Valeur_7"":""" & """," _
                    & """Cplt_Valeur_8"":""" & """," _
                    & """Cplt_Valeur_9"":""" & """," _
                    & """AGD"":""" & dRow("terminal_blood").ToString() & """," _
                    & """DATED"":""" & dRow("donation_date").ToString() & """," _
                    & """GR"":""" & dRow("blood_group").ToString() & """," _
                    & """IM"":""" & """," _
                    & """NOTES"":""" & """," _
                    & """TITLE"":""" & dRow("title").ToString() & """," _
                    & """TITRE"":""" & dRow("title").ToString() & """}]"
        Next
        Dim mailResponse As New H2G.OBJResponse
        mailResponse = H2G.GenMailMerge("DONOR_CARD", strSet)

        If mailResponse.FileName = "ERROR" Then
            Throw New Exception("ระบบมีปัญหาไม่สามารถพิมพ์สติ๊กเกอร์ได้")
        End If

        JSONResponse.setItems("{""printstatus"" : ""success""}")
    End Sub

    Private Sub checkSampleNumber()
        Dim sampleNumber As String = _REQUEST("samplenumber")
        Dim sql As String = "select sample_number from donation_visit where upper(sample_number) = '" & sampleNumber & "'
                             union all
                             select sample_number from donation_hospital where sample_number <> '" & sampleNumber & "'"
        Dim ResultData As String = Cbase.QueryField(sql, "")
        JSONResponse.setItems("{""samplenumber"" : """ & ResultData & """}")
    End Sub

    Private Sub checkExtCardNumber()
        Dim donorExternalID As String = IIf(_REQUEST("donor_external_id") = "NEW", "", _REQUEST("donor_external_id"))
        Dim sql As String = "select dor.name || ' ' || dor.surname as name, ec.description, dex.id
                            from donor dor 
                            inner join donor_external_card dex on dex.donor_id = dor.id
                            inner join external_card ec on ec.id = dex.external_card_id
                            where DEX.card_number = '" & _REQUEST("nation_number") & "' and dex.external_card_id = '" & _REQUEST("external_id") & "'
                            and dex.id <> '" & donorExternalID & "' "
        Dim ResultData As String = ""
        Dim dt As DataTable = Cbase.QueryTable(sql)
        For Each dRow As DataRow In dt.Rows
            ResultData = dRow("description").ToString() & " หมายเลข " & _REQUEST("nation_number") & " ถูกใช้ไปแล้ว โดยคุณ " & dRow("name").ToString()
        Next
        JSONResponse.setItems("{""name"" : """ & ResultData & """}")
    End Sub

End Class

Public Structure DonorMainItem
    Public Donor As DTransaction
    Public ExtCard As List(Of DonorExtCardItem)
    Public Deferral As List(Of DataItem.DeferralItem)
    Public DonationType As List(Of DonationTypeItem)
    Public DonorComment As List(Of DonorCommentItem)
    Public DonationRecord As List(Of DonationRecordItem)
    Public QuestionList As List(Of DonorQuestionItem)
    Public DonorDeferral As List(Of DonorDeferralItem)
    Public DonationExam As List(Of DonationExamination)
End Structure

Public Structure SearchItem
    Public GoNext As String
    Public Duplicate As String
    Public TotalPage As String
    Public SearchList As List(Of DonorSearchItem)
End Structure

Public Structure DonorSearchItem
    Public ID As String
    Public DonorNumber As String
    Public NationNumber As String
    Public ExternalNumber As String
    Public Name As String
    Public Surname As String
    Public Birthday As String
    Public BirthdayFormat As String
    Public BloodGroup As String

End Structure

Public Structure PostQueueSearchItem
    Public GoNext As String
    Public TotalPage As String
    Public PostQueueList As List(Of PostQueueItem)
End Structure

Public Structure PostQueueItem
    Public VisitID As String
    Public DonorID As String
    Public Name As String
    Public QueueNumber As String
    Public SampleNumber As String
    Public Comment As String
    Public RegisTime As String
    Public RegisStaff As String
    Public InterviewTime As String
    Public InterviewStaff As String
    Public CollectionTime As String
    Public CollectionStaff As String
    Public LabTime As String
    Public LabStaff As String

End Structure

Public Structure DonateRecordWithRewardItem
    Public DonationDate As String
    Public DonationDateText As String
    Public DonationNumber As String
    Public DonationFrom As String
    Public DonationRewardList As List(Of RewardItem)

End Structure

Public Structure RewardItem
    Public ID As String
    Public DonationNumber As String
    Public Description As String

End Structure

Public Structure DonationRecordItem
    Public ID As String
    Public DonateDate As String
    Public DonateDateText As String
    Public DonateNumber As String
    Public DonateFrom As String
    Public DonateReward As String

End Structure

Public Structure VisitHistoryItem
    Public VisitID As String
    Public DonationNumber As String
    Public VisitDate As String
    Public DonationType As String
    Public Bag As String
    Public Site As String
    Public CollectionPoint As String
    Public CreateStaff As String
    Public InterviewStaff As String
    Public InterviewStatus As String
    Public LabDate As String
    Public SampleNumber As String

End Structure

Public Structure HistoricalFlie
    Public Exams As String
    Public Result As String
    Public DateOfFirstDet As String
    Public DateOfLastDet As String
    Public SamplesTested As String
    Public FirstSample As String
    Public LastSample As String
    Public FirstAuthorisingLab As String
    Public LastAuthorisingLab As String

End Structure

Public Structure ExamsData
    Public DonnIncr As String
    Public LabDate As String
    Public PrelNo As String
    Public PcatdLib As String
    Public PexLibAff As String
    Public PresAff As String
    Public ExecutingLab As String
    Public TestBy1 As String
    Public TestBy2 As String
    Public TestBy3 As String

End Structure

Public Structure ImmunohaemtologyDataSet1
    Public Rsx_Lib As String
    Public Dex_Res As String
    Public Rsx_Cd As String
End Structure

Public Structure ImmunohaemtologyDataSet2
    Public Rsx_Lib As String
    Public Rsx_Type As String
    Public Result_Decode As String
End Structure

Public Structure SynthesisStatement1
    Public donate_date As String
    Public dornor_type As String
    Public deferral_code As String
    Public dornor_rank As String
    Public pressure As String
    Public dmed_coll As String
    Public dmed_refus As String
    Public dmed_site As String
End Structure

Public Structure SynthesisStatement2
    Public display_date As String
    Public ppe_type As String
    Public show_value As String
    Public show_label As String
    Public show_gen_label As String
    Public display_result As String
End Structure

Public Structure SynthesisListData
    Public SynthesisSet1 As List(Of SynthesisStatement1)
    Public SynthesisSet2 As List(Of SynthesisStatement2)
End Structure

Public Structure ImmunohaemtologyDateData
    Public abod As List(Of DateDataList)
    Public extPheno As List(Of DateDataList)
    Public abScreen As List(Of DateDataList)
End Structure

Public Structure DateDataList
    Public no As String
    Public firstDate As String
    Public lastDate As String
End Structure

Public Structure DonorQuestionItem
    Public ID As String
    Public CreateStaff As String
    Public VisitID As String
    Public QuestionID As String
    Public QuestionCode As String
    Public QuestionDesc As String
    Public QuestionDescTH As String
    Public Answer As String
    Public ParentID As String
    Public Preset As String
    Public AnswerType As String

    Public Shared Function WithCollection(ByVal item As DonorQuestionItem) As SQLCollection
        Dim param As New SQLCollection()
        With item
            param.Add(":id", DbType.Int64, .ID)
            param.Add(":create_staff", DbType.Int64, .CreateStaff)
            param.Add(":donation_visit_id", DbType.Int64, .VisitID)
            param.Add(":questionnaire_question_id", DbType.Int64, .QuestionID)
            param.Add(":questionnaire_question_code", DbType.String, .QuestionCode)
            param.Add(":questionnaire_question_desc", DbType.String, .QuestionDesc)
            param.Add(":questionnaire_question_desc_th", DbType.String, .QuestionDescTH)
            param.Add(":answer", DbType.String, .Answer)
            param.Add(":parent_id", DbType.Int64, IIf(String.IsNullOrEmpty(.ParentID), Nothing, .ParentID))
        End With
        Return param
    End Function

End Structure

Public Structure DonorDeferralItem
    Public ID As String
    Public DetailID As String
    Public DonorID As String
    Public DeferralID As String
    Public VisitID As String
    Public CreateStaff As String
    Public StartDate As String
    Public EndDate As String
    Public Note As String
    Public DonationTypeID As String
    Public DeferralType As String
    Public Duration As String
    Public QuestionID As String
    Public Desc As String

    Public Shared Function WithCollection(ByVal item As DonorDeferralItem) As SQLCollection
        Dim param As New SQLCollection()
        With item
            'id, donor_id, deferral_id, create_date, create_staff, start_date
            ', note, questionnaire_question_id, donation_visit_id 
            param.Add(":id", DbType.Int64, .ID)
            param.Add(":create_staff", DbType.Int64, .CreateStaff)
            param.Add(":donor_id", DbType.Int64, .DonorID)
            param.Add(":deferral_id", DbType.Int64, .DeferralID)
            param.Add(":start_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(.StartDate)).ToString("dd-MM-yyyy"))
            param.Add(":note", DbType.String, .Note)
            param.Add(":questionnaire_question_id", DbType.Int64, IIf(String.IsNullOrEmpty(.QuestionID), Nothing, .QuestionID))
            param.Add(":donation_visit_id", DbType.Int64, .VisitID)
        End With
        Return param
    End Function

    Public Shared Function WithCollectionDetail(ByVal item As DonorDeferralItem) As SQLCollection
        Dim param As New SQLCollection()
        With item
            'id, donor_deferral_id, donation_type_id, deferral_type, duration, end_date, note
            param.Add(":id", DbType.Int64, .DetailID)
            param.Add(":donor_deferral_id", DbType.Int64, .ID)
            param.Add(":donation_type_id", DbType.Int64, .DonationTypeID)
            param.Add(":deferral_type", DbType.String, .DeferralType)
            param.Add(":duration", DbType.Int64, IIf(String.IsNullOrEmpty(.Duration), Nothing, .Duration))
            param.Add(":end_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(.EndDate)).ToString("dd-MM-yyyy"))
            param.Add(":note", DbType.String, .Note)

        End With
        Return param
    End Function

End Structure
