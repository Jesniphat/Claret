Imports H2GEngine
Imports H2GEngine.DataItem

Public Class planningAction
    Inherits UI.Page 'System.Web.UI.Page

    Dim JSONResponse As New CallbackException()
    Dim param As New SQLCollection()
    Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
    Dim Hbase As New oraDBQuery(oraDBQuery.Schema.HEMATOS)
    Dim sqlMain As String = ""
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Select Case _REQUEST("action")
            Case "searchplanning"
                Call SearchPlanning()

        End Select

    End Sub

    Private Sub SearchPlanning()
        Try
            Dim PostQueueItem As New PostQueueSearchItem
            PostQueueItem.GoNext = "N"
            PostQueueItem.PostQueueList = New List(Of PostQueueItem)
            Dim Item As PostQueueItem
            Dim intItemPerPage As Integer = 20
            Dim intTotalPage As Integer = 1

            If Not String.IsNullOrEmpty(_REQUEST("sectorcode")) Then param.Add("#SITE_ID", " and (UPPER(dn.SITE_ID) like UPPER('" & _REQUEST("sectorcode") & "')) ")
            If Not String.IsNullOrEmpty(_REQUEST("departmentcode")) Then param.Add("#COLLECTION_POINT_ID", " and (UPPER(dn.COLLECTION_POINT_ID) like UPPER('" & _REQUEST("departmentcode") & "')) ")
            If Not String.IsNullOrEmpty(_REQUEST("plandate")) Then param.Add("#PLAN_DATE", "and to_char(dn.PLAN_DATE, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("plandate") & "' ")
            If Not String.IsNullOrEmpty(_REQUEST("departmentname")) Then param.Add("#NAME", " and UPPER(dn.NAME) like UPPER('" & _REQUEST("departmentname") & "') ")
            'If Not String.IsNullOrEmpty(_REQUEST("samplenumber")) Then param.Add("#BLOOD_GROUP", " and UPPER(rg.description) like UPPER('" & _REQUEST("bloodgroup") & "') ")
            'If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", " and nvl(dv.VISIT_DATE,dv.CREATE_DATE) between to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy') and to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy')+1 ")

            'If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", "and to_char(nvl(dv.VISIT_DATE,dv.CREATE_DATE), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("reportdate") & "' ")

            If Not String.IsNullOrEmpty(_REQUEST("txtPlanStatus")) Then param.Add("#STATUS", " and dn.STATUS = '" & _REQUEST("txtPlanStatus") & "' ")
            If Not String.IsNullOrEmpty(_REQUEST("txtPlanType")) Then param.Add("#COLLECTION_TYPE", " and dn.COLLECTION_TYPE = '" & _REQUEST("txtPlanType") & "' ")

            Dim sqlRecord As String = "SELECT DN.rn as row_num, * 
                                FROM (
                                    SELECT ROWNUM AS rn, dn.* 
                                        FROM (
                                            SELECT dn.* 
                                                FROM (
									                    select cp.SITE_ID, cp.COLLECTION_POINT_ID, cpo.NAME, cp.PLAN_DATE, cp.STATUS, cp.COLLECTION_TYPE from COLLECTION_PLAN cp 
                                                        LEFT JOIN COLLECTION_POINT cpo on cp.COLLECTION_POINT_ID = cpo.ID
                                                        where 1=1 /*#SITE_ID*/ /*#STATUS*/
                                                        /*#COLLECTION_POINT_ID*/ /*#PLAN_DATE*/ /*#NAME*/ /*COLLECTION_TYPE*/ 
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


End Class

Public Structure DonationTypexx
    Public Id As String
    Public Code As String
    Public Description As String
    Public Hiig_code As String
    Public Donation_group As String
End Structure