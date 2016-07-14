Imports H2GEngine
Imports H2GEngine.DataItem
Public Class donorAction
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
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
        Dim Hbase As New oraDBQuery(oraDBQuery.Schema.HEMATOS)
        Dim sqlMain As String = ""
        Try
            Select Case _REQUEST("action")
                Case "savedonor"
                    Dim DonorItem As DonorItem = JSON.Deserialize(Of DonorItem)(_REQUEST("md"))
                    If String.IsNullOrEmpty(DonorItem.ID) Then
                        DonorItem.DonorNumber = Me.getRunningNumber("DONORID", H2G.Login.SiteID)
                        DonorItem.ID = Cbase.QueryField(H2G.nextVal("DONOR"))
                        Cbase.Execute("SQL::donor/InsertMasterDonor", DonorItem.WithCollection(DonorItem))
                    Else
                        Cbase.Execute("SQL::donor/UpdateMasterDonor", DonorItem.WithCollection(DonorItem))
                    End If

                    Dim DVisitItem As DonationVisitItem = JSON.Deserialize(Of DonationVisitItem)(_REQUEST("dv"))
                    If String.IsNullOrEmpty(DVisitItem.ID) Then
                        DVisitItem.ID = Cbase.QueryField(H2G.nextVal("DONATION_VISIT"))
                        DVisitItem.DonorID = DonorItem.ID
                        DVisitItem.QueueNumber = Cbase.QueryField("select nvl(max(queue_number),0)+1 from donation_visit where create_date between to_date('" & Today.ToString("ddMMyyyy") & "','ddMMyyyy') and to_date('" & Today.AddDays(1).ToString("ddMMyyyy") & "','ddMMyyyy') ")
                        DVisitItem.VisitNumber = Cbase.QueryField("select nvl(max(visit_number),0)+1 from donation_visit where donor_id = " & DonorItem.ID & " ")

                        Cbase.Execute("SQL::donor/InsertDonationVisit", DonationVisitItem.WithCollection(DVisitItem))
                    Else
                        'base.Execute("SQL::donor/UpdateMasterDonor", DonorItem.WithCollection(DonorItem))
                    End If
                    DonorItem.VisitID = DVisitItem.ID

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
                                        Cbase.Execute("insert into donation_record (id, create_date, create_staff, donor_id, donation_record_id, reward_id, reward_date) 
                                        values(:id, sysdate, :create_staff, :donor_id, :donation_record_id, :reward_id, :reward_date)", paramDReward)

                                    End If
                                Next
                            End If
                        ElseIf (item.ID.Contains("D#")) Then

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

                    Cbase.Apply()

                    JSONResponse.setItems(JSON.Serialize(Of DonorItem)(DonorItem))
                    'Response.Write(JSONResponse.ToJSON())
                Case "selectregister"
                    Dim DonorMainItem As New DonorMainItem

                    '### DonorItem
                    param.Add(":id", DbType.Int64, _REQUEST("id"))
                    param.Add(":visit_id", DbType.Int64, _REQUEST("visit_id"))
                    sqlMain = "SQL::donor\SelectMasterDonorVisit"
                    For Each dRow As DataRow In Cbase.QueryTable(sqlMain, param).Rows
                        DonorMainItem.Donor = DTransaction.WithItems(New DTransaction, dRow)
                    Next
                    DonorMainItem.Donor.DuplicateTransaction = 0
                    If String.IsNullOrEmpty(_REQUEST("visit_id")) Then
                        DonorMainItem.Donor.DuplicateTransaction = Cbase.QueryField("select nvl(count(id),0) from donation_visit where donor_id = '" & _REQUEST("id") & "' and to_char(create_date,'yyyyMMdd') = to_char(sysdate,'yyyyMMdd') ", "0")
                    End If

                    '### DonorItem
                    DonorMainItem.ExtCard = New List(Of DonorExtCardItem)
                    For Each dRow As DataRow In Cbase.QueryTable("
                        select dexc.id, dexc.donor_id, dexc.external_card_id, dexc.card_number, ec.description 
                        from donor_external_card dexc
                        inner join external_card ec on ec.id = dexc.external_card_id where dexc.donor_id = :id", param).Rows
                        DonorMainItem.ExtCard.Add(DonorExtCardItem.WithItems(New DonorExtCardItem, dRow))
                    Next

                    '### DeferralItem
                    DonorMainItem.Deferral = New List(Of DonorDeferralItem)
                    For Each dRow As DataRow In Cbase.QueryTable("
                        select deferal_code as deferal_code, end_date, description, deferral_type, status from (
                            select f.code as deferal_code, f.description, DDF.DEFERRAL_TYPE
                            , to_char(DDF.END_DATE, 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as END_DATE
                            , CASE WHEN DDF.END_DATE < SYSDATE THEN 'INACTIVE' ELSE 'ACTIVE' END as status
                            from DONOR_DEFERRAL df
                            inner join DONOR_DEFERRAL_DETAIL ddf on DDF.DONOR_DEFERRAL_ID = DF.id
                            inner join DEFERRAL f on f.id = df.deferral_id
                            where df.DONOR_ID = :id 
                        ) tmp order by status, end_date", param).Rows
                        DonorMainItem.Deferral.Add(DonorDeferralItem.WithItems(New DonorDeferralItem, dRow))
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
                        select dr.id as record_id, DR.DONATION_FROM, DR.DONATION_DATE, DR.DONATION_NUMBER
                        , to_char(DR.DONATION_DATE, 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as DONATION_DATE_TEXT 
                        from donation_record dr 
                        where DR.DONOR_ID = :id ", param).Rows
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

                    JSONResponse.setItems(JSON.Serialize(Of DonorMainItem)(DonorMainItem))
                    'Response.Write(JSONResponse.ToJSON())
                Case "searchdonor"
                    Dim SearchItem As New SearchItem
                    SearchItem.GoNext = "N"
                    SearchItem.SearchList = New List(Of DonorSearchItem)
                    Dim DonorSearchItem As DonorSearchItem
                    Dim intItemPerPage As Integer = 5
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

                    If (Not String.IsNullOrEmpty(_REQUEST("donornumber")) OrElse Not String.IsNullOrEmpty(_REQUEST("nationnumber"))) Then
                        sqlRecord = String.Format(sqlRecord, sql1, "", "")
                        sqlTotal = String.Format(sqlTotal, sql1, "", "")
                    ElseIf (Not String.IsNullOrEmpty(_REQUEST("extnumber"))) Then
                        sqlRecord = String.Format(sqlRecord, sql2, "", "")
                        sqlTotal = String.Format(sqlTotal, sql2, "", "")
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

                        SearchItem.SearchList.Add(DonorSearchItem)
                    Next

                    JSONResponse.setItems(JSON.Serialize(Of SearchItem)(SearchItem))
                    'Response.Write(JSONResponse.ToJSON())
                Case "getdonatereward"
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

                    JSONResponse.setItems(JSON.Serialize(Of List(Of DonateRecordWithRewardItem))(DRWRList))
                    'Response.Write(JSONResponse.ToJSON())

                Case "historicalFileData"
                    'Dim donn_numero As String = _REQUEST("donn_numero")
                    Dim donn_numero As String = "1004230339"

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
                                        where dossex.donn_numero = '" & donn_numero & "'
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
                    JSONResponse.setItems(JSON.Serialize(Of List(Of HistoricalFlie))(HistoricalFlieList))
                    'Response.Write(JSONResponse.ToJSON())

                Case "immunohaemtologyDataSet1"
                    Dim donn_numero As String = _REQUEST("donn_numero")
                    Dim sql As String = "select pparecr.rsx_lib,a.dex_res,pparecr.rsx_cd 
                                        from pparecr left join 
                                        (select * from dossex where dossex.donn_numero = '1004230339' ) a on  a.dex_exam = pparecr.rsx_cd 
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
                    JSONResponse.setItems(JSON.Serialize(Of List(Of ImmunohaemtologyDataSet1))(ImmunohaemtologyDataSet1List))
                    'Response.Write(JSONResponse.ToJSON())

                Case "immunohaemtologyDataSet2"
                    Dim donn_numero As String = _REQUEST("donn_numero")
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
                        Item.Rsx_Lib = dr("RSX_LIB").ToString
                        Item.Rsx_Type = dr("RSX_TYPE").ToString
                        Item.Result_Decode = dr("RESULT_DECODE").ToString

                        ImmunohaemtologyDataSet2List.Add(Item)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of ImmunohaemtologyDataSet2))(ImmunohaemtologyDataSet2List))
                    'Response.Write(JSONResponse.ToJSON())

                Case "examsData"
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
                                        where don.donn_numero = '1004230339'
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
                    JSONResponse.setItems(JSON.Serialize(Of List(Of ExamsData))(ExamsDataList))
                    'Response.Write(JSONResponse.ToJSON())

                Case "donorpostqueue"
                    Dim PostQueueItem As New PostQueueSearchItem
                    PostQueueItem.GoNext = "N"
                    PostQueueItem.PostQueueList = New List(Of PostQueueItem)
                    Dim Item As PostQueueItem
                    Dim intItemPerPage As Integer = 5
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

                    Dim sqlRecord As String = "SELECT DN.rn as row_num, dn.id, dn.donor_number, dn.ext_id, dn.nation_number, dn.external_number, dn.name, dn.surname
			                    , dn.blood_group, to_char(dn.birthday , 'DD MON YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as birthday 
                                FROM (
                                    SELECT ROWNUM AS rn, dn.* 
                                        FROM (
                                            SELECT dn.* 
                                                FROM (
									                    select DV.id as visit_id, DN.id as donor_id, DV.QUEUE_NUMBER, DN.name || ' '  || DN.SURNAME as name
                                                        , DV.SAMPLE_NUMBER, DV.COMMENT_TEXT, to_char(nvl(DV.VISIT_DATE,dv.create_date),'HH24:mm') as regis_time
                                                        , DV.CREATE_STAFF as regis_staff, to_char(dv.INTEVIEW_DATE,'HH24,mm') as INTEVIEW_time, dv.INTEVIEW_STAFF
                                                        , '' as collection_time, '' as collection_staff, '' as lab_time, '' as lab_staff
                                                        from DONATION_VISIT dv
                                                        inner join donor dn on DN.id = DV.DONOR_ID
                                                        left join donor_external_card dexc on dexc.donor_id = dn.id and dexc.external_card_id = 3 
                                                        left join external_card ec on ec.id = dexc.external_card_id
                                                        left join rh_group rg on rg.id = dn.rh_group_id
                                                        where 1=1 /*#QUEUE_NUMBER*/ /*#DONOR_NUMBER*/ /*#NATION_NUMBER*/ /*#NAME*/ /*#SURNAME*/ 
                                                        /*#BIRTHDAY*/ /*#BLOOD_GROUP*/ 
									                ) dn
                                            ORDER BY dn./*#SORT_ORDER*/ /*#SORT_DIRECTION*/
                                            ) dn
                                    ) dn
                                WHERE rn BETWEEN :start_row AND :end_row "

                    Dim sqlTotal As String = "SELECT count(id) from ( select DV.id as visit_id
                                                        from DONATION_VISIT dv
                                                        inner join donor dn on DN.id = DV.DONOR_ID
                                                        left join donor_external_card dexc on dexc.donor_id = dn.id and dexc.external_card_id = 3 
                                                        left join external_card ec on ec.id = dexc.external_card_id
                                                        left join rh_group rg on rg.id = dn.rh_group_id
                                                        where 1=1 /*#QUEUE_NUMBER*/ /*#DONOR_NUMBER*/ /*#NATION_NUMBER*/ /*#NAME*/ /*#SURNAME*/ 
                                                        /*#BIRTHDAY*/ /*#BLOOD_GROUP*/  ) dn"


                    param.Add(":start_row", DbType.String, (intItemPerPage * _REQUEST("p")) - (intItemPerPage - 1))
                    param.Add(":end_row", DbType.String, (intItemPerPage * _REQUEST("p")))
                    param.Add("#SORT_ORDER", _REQUEST("so"))
                    param.Add("#SORT_DIRECTION", _REQUEST("sd"))

                    PostQueueItem.TotalPage = Math.Ceiling(CDec(Cbase.QueryField(sqlTotal, param)) / CDec(intItemPerPage))

                    For Each dRow As DataRow In Cbase.QueryTable(sqlRecord, param).Rows
                        Item = New PostQueueItem
                        Item.VisitID = dRow("visit_id")
                        Item.DonorID = dRow("donor_id")
                        Item.QueueNumber = dRow("QUEUE_NUMBER")
                        Item.Name = dRow("name")
                        Item.SampleNumber = dRow("SAMPLE_NUMBER")
                        Item.Comment = dRow("COMMENT_TEXT")
                        Item.RegisTime = dRow("regis_time")
                        Item.RegisStaff = dRow("regis_staff")
                        Item.InteviewTime = dRow("INTEVIEW_time")
                        Item.InteviewStaff = dRow("INTEVIEW_STAFF")
                        Item.CollectionTime = dRow("collection_time")
                        Item.CollectionStaff = dRow("collection_staff")
                        Item.LabTime = dRow("lab_time")
                        Item.LabStaff = dRow("lab_staff")

                        PostQueueItem.PostQueueList.Add(Item)
                    Next

                    JSONResponse.setItems(JSON.Serialize(Of PostQueueSearchItem)(PostQueueItem))

            End Select

        Catch ex As Exception
            Cbase.Rollback()
            Throw ex
        Finally
            Cbase.Apply()
        End Try

        Return JSONResponse.ToJSON()
    End Function

    Private Function getRunningNumber(ByVal code As String, ByVal idTableDigit As String) As String
        Dim strReturn As String = ""
        Dim base As New oraDBQuery(oraDBQuery.Schema.CLARET)
        Dim dt As DataTable = base.QueryTable("Select id,prefix_from_table,format_text,code_dummy,to_table,to_column from running_number where code='" & code & "'")
        If dt.Rows.Count > 0 Then
            Dim sqlRunning As String = "select nvl(max(" & dt.Rows(0)("to_column") & "),'') from " & dt.Rows(0)("to_table") & " "

            Dim strOldRunning As String = base.QueryField(sqlRunning)
            Dim strFieldDigit As String = IIf(dt.Rows(0)("format_text").ToString().Contains("CODE_3DIGIT"), "CODE_3DIGIT", "CODE_2DIGIT")
            Dim strDigit As String = base.QueryField("select " & strFieldDigit & " from " & dt.Rows(0)("prefix_from_table").ToString & " where id=" & idTableDigit & "")
            '### if can't find digit from target table, Use code dummy instant.
            If strDigit = "" Then strDigit = dt.Rows(0)("code_dummy").ToString()
            Dim intRunningDigit As Int16 = dt.Rows(0)("format_text").ToString.Length - dt.Rows(0)("format_text").ToString.Replace("X", "").Length
            Dim intNumber As Int64 = 1
            If Not String.IsNullOrEmpty(strOldRunning) Then intNumber = CInt(Right(strOldRunning, intRunningDigit)) + 1

            strReturn = dt.Rows(0)("format_text").ToString()
            strReturn = Left(strReturn, strReturn.Length - intRunningDigit) & New String("0"c, H2G.CountCharacter(strReturn, "X"c) - intNumber.ToString.Length) & intNumber

            Dim nowDate As DateTime = Now.AddYears(543)
            strReturn = strReturn.Replace("YYYY", nowDate.ToString("yyyy"))
            strReturn = strReturn.Replace("YY", nowDate.ToString("yy"))
            strReturn = strReturn.Replace("MM", nowDate.ToString("MM"))
            strReturn = strReturn.Replace("DD", nowDate.ToString("dd"))
            strReturn = strReturn.Replace(strFieldDigit, strDigit)
            strReturn = strReturn.Replace(",", "")
        End If
        Return strReturn
    End Function

End Class

Public Structure DonorMainItem
    Public Donor As DTransaction
    Public ExtCard As List(Of DonorExtCardItem)
    Public Deferral As List(Of DonorDeferralItem)
    Public DonationType As List(Of DonationTypeItem)
    Public DonorComment As List(Of DonorCommentItem)
    Public DonationRecord As List(Of DonationRecordItem)
End Structure

Public Structure SearchItem
    Public GoNext As String
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
    Public InteviewTime As String
    Public InteviewStaff As String
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
