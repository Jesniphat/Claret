Imports H2GEngine
Imports H2GEngine.DataItem
Public Class donateAction
    Inherits UI.Page 'System.Web.UI.Page

    Dim JSONResponse As New CallbackException()
    Dim param As New SQLCollection()
    Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
    Dim Hbase As New oraDBQuery(oraDBQuery.Schema.HEMATOS)
    Dim sqlMain As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Select Case _REQUEST("action")
            Case "getDonateTypeList"
                Call GetDonateTypeList()
            Case "getDonateBagTypeList"
                Call GetDonateBagTypeList()
            Case "getDonateApplyList"
                Call GetDonateApplyList()
            Case "donorpostqueue"
                Call Donorpostqueue()
            Case "getExamination"
                Call GetExamination()
            Case "getProblemReason"
                Call GetProblemReason()
            Case "checkDonateNum"
                Call CheckDonateNum()
            Case "checkSampleNumber"
                Call CheckSampleNumber()
            Case "getInitialData"
                Call GetInitialData()
            Case "saveDonate"
                Call DonateSaveData()
            Case "getDonationList"
                Call GetDonationList()

        End Select

    End Sub

    Private Sub GetDonateTypeList()

        Try
            Dim sql As String = "select * from Donation_type where ID > 0"

            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim DonationTypeList As New List(Of DonationType)
            For Each dr As DataRow In dt.Rows
                Dim Item As New DonationType
                Item.Id = dr("ID").ToString
                Item.Code = dr("CODE").ToString
                Item.Description = dr("DESCRIPTION").ToString
                Item.Hiig_code = dr("HIIG_CODE").ToString
                Item.Donation_group = dr("DONATION_GROUP").ToString

                DonationTypeList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of DonationType))(DonationTypeList))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
        Response.End()
    End Sub

    Private Sub GetDonateBagTypeList()
        Try
            Dim sql As String = "select * from Bag where ID > 0"

            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim DonationBagTypeList As New List(Of DonationBag)
            For Each dr As DataRow In dt.Rows
                Dim Item As New DonationBag
                Item.Id = dr("ID").ToString
                Item.Code = dr("CODE").ToString
                Item.Description = dr("DESCRIPTION").ToString
                Item.Hiig_code = dr("HIIG_CODE").ToString
                Item.Bag_type = dr("BAG_TYPE").ToString

                DonationBagTypeList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of DonationBag))(DonationBagTypeList))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetDonateApplyList()
        Try
            Dim sql As String = "select * from Donation_To where used_module like '%D,%'"

            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim DonationApplyList As New List(Of DonateApply)
            For Each dr As DataRow In dt.Rows
                Dim Item As New DonateApply
                Item.Id = dr("ID").ToString
                Item.Description = dr("DESCRIPTION").ToString
                Item.Hiig_code = dr("HIIG_CODE").ToString
                Item.Donate_type_id = dr("DONATION_TYPE_ID").ToString
                Item.Hiig_ptypp_cd = dr("HIIG_PTYPP_CD").ToString
                Item.Used_module = dr("USED_MODULE").ToString

                DonationApplyList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of DonateApply))(DonationApplyList))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub Donorpostqueue()
        Try
            Dim PostQueueItem As New PostQueueSearchItem
            PostQueueItem.GoNext = "N"
            PostQueueItem.PostQueueList = New List(Of PostQueueItem)
            Dim Item As PostQueueItem
            Dim intItemPerPage As Integer = 20
            Dim intTotalPage As Integer = 1

            If Not String.IsNullOrEmpty(_REQUEST("queuenumber")) Then
                param.Add("#QUEUE_NUMBER", " and to_char(dv.queue_number) like '" & _REQUEST("queuenumber") & "' ")
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
            If Not String.IsNullOrEmpty(_REQUEST("samplenumber")) Then param.Add("#BLOOD_GROUP", " and UPPER(rg.description) like UPPER('" & _REQUEST("bloodgroup") & "') ")
            'If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", " and nvl(dv.VISIT_DATE,dv.CREATE_DATE) between to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy') and to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy')+1 ")

            If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", "and to_char(nvl(dv.VISIT_DATE,dv.CREATE_DATE), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("reportdate") & "' ")

            If Not String.IsNullOrEmpty(_REQUEST("status")) Then param.Add("#STATUS", " and dv.status = '" & _REQUEST("status") & "' ")


            Dim sqlRecord As String = "SELECT DN.rn as row_num, dn.visit_id, dn.donor_id, dn.QUEUE_NUMBER, dn.name, dn.SAMPLE_NUMBER, dn.COMMENT_TEXT, dn.regis_time
			                    , dn.regis_staff, dn.Interview_time, dn.Interview_STAFF, dn.collection_time, dn.collection_staff, dn.lab_time, dn.lab_staff
                                FROM (
                                    SELECT ROWNUM AS rn, dn.* 
                                        FROM (
                                            SELECT dn.* 
                                                FROM (
									                    select DV.id as visit_id, DN.id as donor_id, DV.QUEUE_NUMBER, DN.name || ' '  || DN.SURNAME as name
                                                        , DV.SAMPLE_NUMBER, DV.COMMENT_TEXT, to_char(nvl(DV.VISIT_DATE,dv.create_date),'HH24,MI') as regis_time
                                                        , st.code as regis_staff, to_char(dv.Interview_DATE,'HH24,MI') as Interview_time, dv.Interview_STAFF
                                                        , '' as collection_time, '' as collection_staff, '' as lab_time, '' as lab_staff
                                                        from DONATION_VISIT dv
                                                        inner join donor dn on DN.id = DV.DONOR_ID
                                                        left join donor_external_card dexc on dexc.donor_id = dn.id and dexc.external_card_id = 3 
                                                        left join external_card ec on ec.id = dexc.external_card_id
                                                        left join rh_group rg on rg.id = dn.rh_group_id
                                                        left join staff st on st.id = dv.create_staff
                                                        where 1=1 /*#REPORT_DATE*/ /*#STATUS*/
                                                        /*#QUEUE_NUMBER*/ /*#DONOR_NUMBER*/ /*#NATION_NUMBER*/ /*#NAME*/ /*#SURNAME*/ 
                                                        /*#BIRTHDAY*/ /*#BLOOD_GROUP*/ 
									                ) dn
                                            ORDER BY dn./*#SORT_ORDER*/ /*#SORT_DIRECTION*/
                                            ) dn
                                    ) dn
                                WHERE rn BETWEEN :start_row AND :end_row "

            Dim sqlTotal As String = "SELECT nvl(count(visit_id),0) from ( select DV.id as visit_id
                                                        from DONATION_VISIT dv
                                                        inner join donor dn on DN.id = DV.DONOR_ID
                                                        left join donor_external_card dexc on dexc.donor_id = dn.id and dexc.external_card_id = 3 
                                                        left join external_card ec on ec.id = dexc.external_card_id
                                                        left join rh_group rg on rg.id = dn.rh_group_id
                                                        where 1=1 /*#REPORT_DATE*/ /*#STATUS*/
                                                        /*#QUEUE_NUMBER*/ /*#DONOR_NUMBER*/ /*#NATION_NUMBER*/ /*#NAME*/ /*#SURNAME*/ 
                                                        /*#BIRTHDAY*/ /*#BLOOD_GROUP*/  ) dn"


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
                Item.InterviewTime = dRow("Interview_time").ToString().Replace(",", ":")
                Item.InterviewStaff = dRow("Interview_STAFF").ToString()
                Item.CollectionTime = dRow("collection_time").ToString().Replace(",", ":")
                Item.CollectionStaff = dRow("collection_staff").ToString()
                Item.LabTime = dRow("lab_time").ToString().Replace(",", ":")
                Item.LabStaff = dRow("lab_staff").ToString()

                PostQueueItem.PostQueueList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of PostQueueSearchItem)(PostQueueItem))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try

    End Sub

    Private Sub GetExamination()
        Try
            Dim ExaminationSetData As New ExaminationSet

            Dim sql As String = "select * from EXAMINATION_GROUP"
            Dim dt As DataTable = Cbase.QueryTable(sql)
            ExaminationSetData.examinationgrouplist = New List(Of ExaminationGroup)
            For Each dr As DataRow In dt.Rows
                Dim Item As New ExaminationGroup
                Item.id = dr("ID").ToString
                Item.code = dr("CODE").ToString
                Item.description = dr("DESCRIPTION").ToString
                Item.hiig_code = dr("HIIG_CODE").ToString

                ExaminationSetData.examinationgrouplist.Add(Item)
            Next

            Dim sql2 As String = "select * from EXAMINATION"
            Dim dt2 As DataTable = Cbase.QueryTable(sql2)
            ExaminationSetData.examinationlist = New List(Of Examination)
            For Each dr As DataRow In dt2.Rows
                Dim Item As New Examination
                Item.id = dr("ID").ToString
                Item.code = dr("CODE").ToString
                Item.description = dr("DESCRIPTION").ToString
                Item.hiig_code = dr("HIIG_CODE").ToString

                ExaminationSetData.examinationlist.Add(Item)
            Next

            Dim sql3 As String = "select G.EXAMINATION_GROUP_ID AS G_ID,E.ID AS E_ID,E.CODE || ' - ' || E.DESCRIPTION AS TEXT,E.HIIG_CODE 
                                  from EXAMINATION_GROUPING G inner join EXAMINATION E on G.EXAMINATION_ID = E.ID"
            Dim dt3 As DataTable = Cbase.QueryTable(sql3)
            ExaminationSetData.examinationjoinlist = New List(Of ExaminationJoin)
            For Each dr As DataRow In dt3.Rows
                Dim Item As New ExaminationJoin
                Item.g_id = dr("G_ID").ToString
                Item.e_id = dr("E_ID").ToString
                Item.text = dr("TEXT").ToString
                Item.hiig_code = dr("HIIG_CODE").ToString

                ExaminationSetData.examinationjoinlist.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of ExaminationSet)(ExaminationSetData))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetProblemReason()
        Try
            Dim sql As String = "select * from Reason where hiig_table = 'MOTIFDEST'"

            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim ProblemReasonList = New List(Of ProblemReason)
            For Each dr As DataRow In dt.Rows
                Dim Item As New ProblemReason
                Item.id = dr("ID").ToString
                Item.code = dr("CODE").ToString
                Item.description = dr("DESCRIPTION").ToString
                Item.priority = dr("PRIORITY").ToString
                Item.hiig_code = dr("HIIG_CODE").ToString
                Item.hiig_table = dr("HIIG_TABLE").ToString
                Item.hiig_ppar_type = dr("HIIG_PPAR_TYPE").ToString
                Item.hiig_ppar_cd = dr("HIIG_PPAR_CD").ToString
                Item.used_module = dr("USED_MODULE").ToString

                ProblemReasonList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of ProblemReason))(ProblemReasonList))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub CheckDonateNum()
        Try
            Dim donn_number As String = _REQUEST("donateNumber")
            Dim sql As String = "select d.ID, d.DONOR_NUMBER from DONATION_VISIT dv inner join DONOR d on d.ID = dv.DONOR_ID 
                                    where dv.STATUS = 'WAIT COLLECTION' AND d.DONOR_NUMBER = '" & donn_number & "'"

            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim DonorNumber = New List(Of CheckDonorId)
            For Each dr As DataRow In dt.Rows
                Dim Item As New CheckDonorId
                Item.donorId = dr("ID").ToString
                Item.donorNumber = dr("DONOR_NUMBER").ToString

                DonorNumber.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of CheckDonorId))(DonorNumber))
            Response.Write(JSONResponse.ToJSON())

        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub CheckSampleNumber()
        Try
            Dim sample_number As String = _REQUEST("sampleNumber")
            Dim donn_number As String = _REQUEST("donateNumber")
            Dim sql As String = "select d.ID, d.DONOR_NUMBER, dv.ID AS VISIT_ID, dv.SAMPLE_NUMBER 
                                    from DONATION_VISIT dv inner join DONOR d on d.ID = dv.DONOR_ID 
                                    where dv.STATUS = 'WAIT COLLECTION' AND dv.SAMPLE_NUMBER = '" & sample_number & "' 
                                    AND d.DONOR_NUMBER = '" & donn_number & "'"

            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim SampleNumber = New List(Of CheckSampleNum)
            For Each dr As DataRow In dt.Rows
                Dim Item As New CheckSampleNum
                Item.visitId = dr("VISIT_ID").ToString
                Item.sampleNumber = dr("SAMPLE_NUMBER").ToString

                SampleNumber.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of CheckSampleNum))(SampleNumber))
            Response.Write(JSONResponse.ToJSON())

        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetInitialData()
        Try
            Dim DonorId As String = _REQUEST("donorid")
            Dim VistId As String = _REQUEST("visitid")

            Dim GetDonor As String = "select d.ID, d.DONOR_NUMBER from DONATION_VISIT dv inner join DONOR d on d.ID = dv.DONOR_ID 
                                      where d.ID = '" & DonorId & "' AND dv.ID = '" & VistId & "'"
            Dim GetVisit As String = "select d.ID, d.DONOR_NUMBER, dv.ID AS VISIT_ID, dv.SAMPLE_NUMBER 
                                      from DONATION_VISIT dv inner join DONOR d on d.ID = dv.DONOR_ID 
                                      where dv.ID = '" & VistId & "' 
                                      AND d.ID = '" & DonorId & "'"
            Dim GetInData As String = "SELECT VOLUME_ACTUAL, DONATION_TIME, DURATION, COLLECTION_STAFF, COLLECTION_DATE, 
                                       REFUSE_REASON1_ID, REFUSE_REASON2_ID, REFUSE_REASON3_ID FROM DONATION_RECORD 
                                       WHERE DONOR_ID = '" & DonorId & "' AND DONATION_VISIT_ID = '" & VistId & "' "
            Dim GetExamination As String = "select * from DONATION_EXAMINATION WHERE DONATION_VISIT_ID = '" & VistId & "'"


            Dim AllInitalDataList As New InitalDataList

            Dim dtDorner As DataTable = Cbase.QueryTable(GetDonor)
            AllInitalDataList.doner = New List(Of CheckDonorId)
            For Each dr As DataRow In dtDorner.Rows
                Dim Item As New CheckDonorId
                Item.donorId = dr("ID").ToString
                Item.donorNumber = dr("DONOR_NUMBER").ToString

                AllInitalDataList.doner.Add(Item)
            Next

            Dim dtVisit As DataTable = Cbase.QueryTable(GetVisit)
            AllInitalDataList.visit = New List(Of CheckSampleNum)
            For Each dr As DataRow In dtVisit.Rows
                Dim Item As New CheckSampleNum
                Item.visitId = dr("VISIT_ID").ToString
                Item.sampleNumber = dr("SAMPLE_NUMBER").ToString

                AllInitalDataList.visit.Add(Item)
            Next

            Dim dtInData As DataTable = Cbase.QueryTable(GetInData)
            AllInitalDataList.InitalData = New List(Of InitalData)
            For Each dr As DataRow In dtInData.Rows
                Dim Item As New InitalData
                Item.volume_actual = dr("VOLUME_ACTUAL").ToString
                Item.donation_time = dr("DONATION_TIME").ToString
                Item.dulation = dr("DURATION").ToString
                Item.collection_staff = dr("COLLECTION_STAFF").ToString
                Item.collection_date = dr("COLLECTION_DATE").ToString
                Item.refuse_reason1_id = dr("REFUSE_REASON1_ID").ToString
                Item.refuse_reason2_id = dr("REFUSE_REASON2_ID").ToString
                Item.refuse_reason3_id = dr("REFUSE_REASON3_ID").ToString

                AllInitalDataList.InitalData.Add(Item)
            Next

            Dim dtDonationExamination As DataTable = Cbase.QueryTable(GetExamination)
            AllInitalDataList.DonationExamination = New List(Of DonationExamination)
            For Each dr As DataRow In dtDonationExamination.Rows
                Dim Item As New DonationExamination
                Item.id = dr("ID").ToString
                Item.create_date = dr("CREATE_DATE").ToString
                Item.create_staff = dr("CREATE_STAFF").ToString
                Item.donation_visit_id = dr("DONATION_VISIT_ID").ToString
                Item.donation_hospital_id = dr("DONATION_HOSPITAL_ID").ToString
                Item.donation_from = dr("DONATION_FROM").ToString
                Item.examination_group_id = dr("EXAMINATION_GROUP_ID").ToString
                Item.examination_group_desc = dr("EXAMINATION_GROUP_DESC").ToString
                Item.examination_id = dr("EXAMINATION_ID").ToString
                Item.examination_desc = dr("EXAMINATION_DESC").ToString

                AllInitalDataList.DonationExamination.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of InitalDataList)(AllInitalDataList))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub DonateSaveData()
        Try
            Dim donerId As String = _REQUEST("donorid")
            Dim visitId As String = _REQUEST("visitid")
            Dim donateAction As String = _REQUEST("donateAction")
            Dim donateTypeId As String = _REQUEST("donateTypeId")
            Dim donateBagTypeId As String = _REQUEST("donateBagTypeId")
            Dim donateApplyId As String = _REQUEST("donateApplyId")
            Dim prescribedVol As String = _REQUEST("prescribedVol")
            Dim volumnActual As String = _REQUEST("volumnActual")
            Dim donationTime As String = _REQUEST("donationTime")
            Dim duration As String = _REQUEST("duration")
            Dim collectionStaff As String = _REQUEST("collection_staff")
            Dim refuseReason1Id As String = _REQUEST("refuse_reason1_id")
            Dim refuseReason2Id As String = _REQUEST("refuse_reason2_id")
            Dim refuseReason3Id As String = _REQUEST("refuse_reason3_id")

            'Dim labExaminationSaveString As String = _REQUEST("labExaminationSaveList")
            Dim labExaminationSaveList As List(Of LabExaminationLists) = JSON.Deserialize(Of List(Of LabExaminationLists))(_REQUEST("labExaminationSaveList"))

            Dim LabExaminationString As String = ""
            For Each Les As LabExaminationLists In labExaminationSaveList
                LabExaminationString += "'" & Les.id & "',"
            Next

            Dim strLabExaminationString As String = LabExaminationString.Substring(0, (LabExaminationString.Length - 1))
            Dim ExaminationDonationListSql = "SELECT el.ID AS EL_ID, el.DONATION_TYPE_ID, el.EXAMINATION_ID AS id, e.CODE, e.DESCRIPTION, el.EXAMINATION_GROUP_ID as group_id
                FROM EXAMINATION_DONATION_LIST el inner join EXAMINATION e on el.EXAMINATION_ID = e.ID 
                WHERE DONATION_TYPE_ID = '" & donateTypeId & "' AND el.NEW_DONOR_FLAG = 'A' AND el.EXAMINATION_ID not in (" & strLabExaminationString & ")"

            Dim NewExaminationList As DataTable = Cbase.QueryTable(ExaminationDonationListSql)
            For Each dr As DataRow In NewExaminationList.Rows
                Dim Item As New LabExaminationLists
                Item.id = dr("ID").ToString
                Item.code = dr("CODE").ToString
                Item.description = dr("DESCRIPTION").ToString
                Item.group_id = dr("GROUP_ID").ToString

                labExaminationSaveList.Add(Item)
            Next

            Dim UpdateDonationVisitSql As String = "UPDATE DONATION_VISIT SET " &
                                                   "DONATION_TYPE_ID = '" & donateTypeId & "', " &
                                                   "BAG_ID = '" & donateBagTypeId & "', " &
                                                   "DONATION_TO_ID = '" & donateApplyId & "', " &
                                                   "STATUS = 'WAIT RESULT' WHERE ID = '" & visitId & "' " &
                                                   "AND DONOR_ID = '" & donerId & "'"
            Cbase.Execute(UpdateDonationVisitSql)

            Dim UpdateDonationRecordSql As String = "UPDATE DONATION_RECORD SET " &
                                                    "VOLUME_ACTUAL = '" & volumnActual & "', " &
                                                    "DONATION_TIME = " & "SYSDATE" & ", " &
                                                    "DURATION = " & "SYSDATE" & ", " &
                                                    "COLLECTION_STAFF = '" & collectionStaff & "', " &
                                                    "COLLECTION_DATE = SYSDATE, " &
                                                    "REFUSE_REASON1_ID = '" & refuseReason1Id & "', " &
                                                    "REFUSE_REASON2_ID = '" & refuseReason2Id & "', " &
                                                    "REFUSE_REASON3_ID = '" & refuseReason3Id & "' " &
                                                    "WHERE DONATION_VISIT_ID = '" & visitId & "' " &
                                                    "AND DONOR_ID = '" & donerId & "' "
            Cbase.Execute(UpdateDonationRecordSql)

            Cbase.Execute("delete from DONATION_EXAMINATION where DONATION_VISIT_ID = '" & visitId & "'")

            For Each list As LabExaminationLists In labExaminationSaveList
                Dim InsertExaminationSql = "INSERT INTO DONATION_EXAMINATION (ID, CREATE_DATE, CREATE_STAFF, DONATION_VISIT_ID, donation_from, examination_group_id, " &
                                           "examination_group_desc, examination_id, examination_desc) VALUES " &
                                           "(SQ_DONATION_EXAMINATION_ID.nextval, SYSDATE, '" & collectionStaff & "', '" & visitId & "', " &
                                           "'0', '" & list.group_id & "', '0', '" & list.id & "', '" & list.description & "')"
                Cbase.Execute(InsertExaminationSql)
            Next

            Cbase.Apply()
            JSONResponse.setItems(JSON.Serialize(Of List(Of LabExaminationLists))(labExaminationSaveList))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Cbase.Rollback()
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetDonationList()
        Try
            Dim sql As String = "SELECT D.ID AS DONOR_ID,DV.ID AS VISIT_ID,D.DONOR_NUMBER,DV.SAMPLE_NUMBER,DV.DONATION_TYPE_ID,DV.BAG_ID,DV.DONATION_TO_ID, 
                                DR.VOLUME_ACTUAL,DR.DONATION_TIME,DR.DURATION,DR.COLLECTION_DATE,DR.COLLECTION_STAFF,
                                DR.REFUSE_REASON1_ID,DR.REFUSE_REASON2_ID,DR.REFUSE_REASON3_ID,
                                DT.DESCRIPTION AS TYPE_DES,G.DESCRIPTION AS BAG_DES, DTT.DESCRIPTION AS APPLY_DES 
                                FROM DONOR D INNER JOIN DONATION_VISIT DV ON D.ID = DV.DONOR_ID 
                                INNER JOIN DONATION_RECORD DR ON D.ID = DR.DONOR_ID AND DV.ID = DR.DONATION_VISIT_ID
                                INNER JOIN DONATION_TYPE DT ON DV.DONATION_TYPE_ID = DT.ID
                                INNER JOIN BAG G ON DV.BAG_ID = G.ID INNER JOIN Donation_To DTT ON DV.DONATION_TO_ID = DTT.ID
                                WHERE DV.STATUS IN ('WAIT RESULT')"
            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim DonationLists = New List(Of DonationList)
            For Each dr As DataRow In dt.Rows
                Dim Item As New DonationList
                Item.donor_id = dr("DONOR_ID").ToString
                Item.visit_id = dr("VISIT_ID").ToString
                Item.dornor_number = dr("DONOR_NUMBER").ToString
                Item.sample_number = dr("SAMPLE_NUMBER").ToString
                Item.donation_type_id = dr("DONATION_TYPE_ID").ToString
                Item.bag_id = dr("BAG_ID").ToString
                Item.donation_to_id = dr("DONATION_TO_ID").ToString
                Item.volume_actual = dr("VOLUME_ACTUAL").ToString
                Item.donation_time = dr("DONATION_TIME").ToString
                Item.duration = dr("DURATION").ToString
                Item.collection_date = dr("COLLECTION_DATE").ToString
                Item.collection_staff = dr("COLLECTION_STAFF").ToString
                Item.refuse_reason1_id = dr("REFUSE_REASON1_ID").ToString
                Item.refuse_reason2_id = dr("REFUSE_REASON2_ID").ToString
                Item.refuse_reason3_id = dr("REFUSE_REASON3_ID").ToString
                Item.type_des = dr("TYPE_DES").ToString
                Item.bag_des = dr("BAG_DES").ToString
                Item.apply_des = dr("APPLY_DES").ToString

                DonationLists.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of DonationList))(DonationLists))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub
End Class

Public Structure DonationType
    Public Id As String
    Public Code As String
    Public Description As String
    Public Hiig_code As String
    Public Donation_group As String
End Structure

Public Structure DonationBag
    Public Id As String
    Public Code As String
    Public Description As String
    Public Hiig_code As String
    Public Bag_type As String
End Structure

Public Structure DonateApply
    Public Id As String
    Public Description As String
    Public Hiig_code As String
    Public Donate_type_id As String
    Public Hiig_ptypp_cd As String
    Public Used_module As String
End Structure

Public Structure ExaminationSet
    Public examinationgrouplist As List(Of ExaminationGroup)
    Public examinationlist As List(Of Examination)
    Public examinationjoinlist As List(Of ExaminationJoin)
End Structure

Public Structure Examination
    Public id As String
    Public code As String
    Public description As String
    Public hiig_code As String
End Structure

Public Structure ExaminationGroup
    Public id As String
    Public code As String
    Public description As String
    Public hiig_code As String
End Structure

Public Structure ExaminationJoin
    Public g_id As String
    Public e_id As String
    Public text As String
    Public hiig_code As String
End Structure

Public Structure ProblemReason
    Public id As String
    Public code As String
    Public description As String
    Public priority As String
    Public hiig_code As String
    Public hiig_table As String
    Public hiig_ppar_type As String
    Public hiig_ppar_cd As String
    Public used_module As String
End Structure

Public Structure CheckDonorId
    Public donorId As String
    Public donorNumber As String
End Structure

Public Structure CheckSampleNum
    Public visitId As String
    Public sampleNumber As String
End Structure

Public Structure InitalData
    Public volume_actual As String
    Public donation_time As String
    Public dulation As String
    Public collection_staff As String
    Public collection_date As String
    Public refuse_reason1_id As String
    Public refuse_reason2_id As String
    Public refuse_reason3_id As String
End Structure

Public Class DonationExamination
    Public id As String
    Public create_date As String
    Public create_staff As String
    Public donation_visit_id As String
    Public donation_hospital_id As String
    Public donation_from As String
    Public examination_group_id As String
    Public examination_group_desc As String
    Public examination_id As String
    Public examination_desc As String
    Public question_id As String
    Public examination_group_code As String
    Public examination_code As String

    Public Shared Function WithCollection(ByVal item As DonationExamination) As SQLCollection
        Dim param As New SQLCollection()
        With item
            'id, create_date, create_staff, donation_visit_id, donation_hospital_id, donation_form
            ', examination_group_id, examination_group_desc, examination_id, examination_desc, questionnaire_question_id
            param.Add(":id", DbType.Int64, .id)
            param.Add(":create_staff", DbType.Int64, .create_staff)
            param.Add(":donation_visit_id", DbType.Int64, IIf(String.IsNullOrEmpty(.donation_visit_id), Nothing, .donation_visit_id))
            param.Add(":donation_hospital_id", DbType.Int64, IIf(String.IsNullOrEmpty(.donation_hospital_id), Nothing, .donation_hospital_id))
            param.Add(":donation_form", DbType.String, .donation_from)
            param.Add(":examination_group_id", DbType.Int64, IIf(String.IsNullOrEmpty(.examination_group_id), Nothing, .examination_group_id))
            param.Add(":examination_group_desc", DbType.String, .examination_group_desc)
            param.Add(":examination_id", DbType.Int64, .examination_id)
            param.Add(":examination_desc", DbType.String, .examination_desc)
            param.Add(":questionnaire_question_id", DbType.Int64, IIf(String.IsNullOrEmpty(.question_id), Nothing, .question_id))

        End With
        Return param
    End Function
End Class

Public Structure InitalDataList
    Public doner As List(Of CheckDonorId)
    Public visit As List(Of CheckSampleNum)
    Public InitalData As List(Of InitalData)
    Public DonationExamination As List(Of DonationExamination)
End Structure

Public Structure LabExaminationLists
    Public id As String
    Public code As String
    Public description As String
    Public group_id As String
End Structure

Public Structure DonationList
    Public donor_id As String
    Public visit_id As String
    Public dornor_number As String
    Public sample_number As String
    Public donation_type_id As String
    Public bag_id As String
    Public donation_to_id As String
    Public volume_actual As String
    Public donation_time As String
    Public duration As String
    Public collection_date As String
    Public collection_staff As String
    Public refuse_reason1_id As String
    Public refuse_reason2_id As String
    Public refuse_reason3_id As String
    Public type_des As String
    Public bag_des As String
    Public apply_des As String
End Structure