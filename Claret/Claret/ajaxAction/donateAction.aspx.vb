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
			                    , dn.regis_staff, dn.INTEVIEW_time, dn.INTEVIEW_STAFF, dn.collection_time, dn.collection_staff, dn.lab_time, dn.lab_staff
                                FROM (
                                    SELECT ROWNUM AS rn, dn.* 
                                        FROM (
                                            SELECT dn.* 
                                                FROM (
									                    select DV.id as visit_id, DN.id as donor_id, DV.QUEUE_NUMBER, DN.name || ' '  || DN.SURNAME as name
                                                        , DV.SAMPLE_NUMBER, DV.COMMENT_TEXT, to_char(nvl(DV.VISIT_DATE,dv.create_date),'HH24,MI') as regis_time
                                                        , st.code as regis_staff, to_char(dv.INTEVIEW_DATE,'HH24,MI') as INTEVIEW_time, dv.INTEVIEW_STAFF
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
                Item.InteviewTime = dRow("INTEVIEW_time").ToString().Replace(",", ":")
                Item.InteviewStaff = dRow("INTEVIEW_STAFF").ToString()
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

