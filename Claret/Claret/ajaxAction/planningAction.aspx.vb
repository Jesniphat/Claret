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
            Case "getdepartmentdata"
                Call GetDepartmentData()
            Case "getcountry"
                Call GetCountry()
            Case "getdepartmenttypeList"
                Call GetCollectionCategory()
            Case "getplanbyid"
                Call GetPlanById()
            Case "getsubcollectionedit"
                Call GetSubCollectionEdit()
            Case "getHasPlanDetail"
                Call GetHasPlanDetail()
            Case "saveplan"
                Call SavePlanning()
            Case "getmaxdate"
                Call GetMaxDate()
            Case "checkduplicateactive"
                Call CheckDuplicateActive()
            Case "getsitecodebyid"
                Call getsitecodebyid()

        End Select

    End Sub

    Private Sub SearchPlanning()
        Try
            'Dim PostQueueItem As New PostQueueSearchItem
            'PostQueueItem.GoNext = "N"
            'PostQueueItem.PostQueueList = New List(Of PostQueueItem)
            'Dim Item As PostQueueItem
            'Dim intItemPerPage As Integer = 20
            'Dim intTotalPage As Integer = 1

            Dim SearchItem As New SearchItem
            SearchItem.GoNext = "N"
            SearchItem.Duplicate = ""
            SearchItem.SearchList = New List(Of DonorSearchItem)
            Dim DonorSearchItem As DonorSearchItem
            Dim intItemPerPage As Integer = 20
            Dim intTotalPage As Integer = 1

            If Not String.IsNullOrEmpty(_REQUEST("sectorcode")) Then param.Add("#SITE_ID", " and (UPPER(s.CODE) like UPPER('" & _REQUEST("sectorcode") & "')) ")
            If Not String.IsNullOrEmpty(_REQUEST("departmentcode")) Then param.Add("#COLLECTION_POINT_ID", " and (UPPER(cpo.CODE) like UPPER('" & _REQUEST("departmentcode") & "')) ")
            If Not String.IsNullOrEmpty(_REQUEST("plandate")) Then param.Add("#PLAN_DATE", "and to_char(cp.PLAN_DATE, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("plandate") & "' ")
            If Not String.IsNullOrEmpty(_REQUEST("departmentname")) Then param.Add("#NAME", " and UPPER(cpo.NAME) like UPPER('" & _REQUEST("departmentname") & "') ")
            'If Not String.IsNullOrEmpty(_REQUEST("samplenumber")) Then param.Add("#BLOOD_GROUP", " and UPPER(rg.description) like UPPER('" & _REQUEST("bloodgroup") & "') ")
            'If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", " and nvl(dv.VISIT_DATE,dv.CREATE_DATE) between to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy') and to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy')+1 ")

            'If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", "and to_char(nvl(dv.VISIT_DATE,dv.CREATE_DATE), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("reportdate") & "' ")

            If Not String.IsNullOrEmpty(_REQUEST("planstatus")) Then param.Add("#STATUS", " and cp.STATUS = '" & _REQUEST("planstatus") & "' ")
            If Not String.IsNullOrEmpty(_REQUEST("plantype")) Then param.Add("#COLLECTION_TYPE", " and cpo.COLLECTION_TYPE = '" & _REQUEST("plantype") & "' ")

            Dim sqlRecord As String = "SELECT DN.rn as row_num, dn.* 
                                FROM (
                                    SELECT ROWNUM AS rn, dn.* 
                                        FROM (
                                            SELECT dn.* 
                                                FROM (
									                    select cp.ID, s.CODE AS SITE_CODE, cp.SITE_ID, cp.COLLECTION_POINT_ID, cpo.CODE AS COLLECTION_POINT_CODE, cpo.NAME, to_char(nvl(cp.PLAN_DATE,nvl(cp.PLAN_DATE,sysdate)), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') AS PLAN_DATE, cp.STATUS, cpo.COLLECTION_TYPE 
                                                        from COLLECTION_PLAN cp 
                                                        INNER JOIN SITE s ON cp.SITE_ID = s.ID
                                                        LEFT JOIN COLLECTION_POINT cpo on cp.COLLECTION_POINT_ID = cpo.ID
                                                        where 1=1 /*#SITE_ID*/ /*#STATUS*/ /*#COLLECTION_TYPE*/ 
                                                        /*#COLLECTION_POINT_ID*/ /*#PLAN_DATE*/ /*#NAME*/  
									                ) dn
                                            ORDER BY dn./*#SORT_ORDER*/ /*#SORT_DIRECTION*/
                                            ) dn
                                    ) dn
                                WHERE rn BETWEEN :start_row AND :end_row "

            Dim sqlTotal As String = "SELECT nvl(count(COLLECTION_POINT_ID),0) from ( select cp.SITE_ID, cp.COLLECTION_POINT_ID, cpo.CODE AS COLLECTION_POINT_CODE, cpo.NAME, cp.PLAN_DATE, cp.STATUS, cpo.COLLECTION_TYPE 
                                                        from COLLECTION_PLAN cp 
                                                        INNER JOIN SITE s ON cp.SITE_ID = s.ID 
                                                        LEFT JOIN COLLECTION_POINT cpo on cp.COLLECTION_POINT_ID = cpo.ID
                                                        where 1=1 /*#SITE_ID*/ /*#STATUS*/ /*#COLLECTION_TYPE*/ 
                                                        /*#COLLECTION_POINT_ID*/ /*#PLAN_DATE*/ /*#NAME*/ ) dn"


            param.Add(":start_row", DbType.String, (intItemPerPage * _REQUEST("p")) - (intItemPerPage - 1))
            param.Add(":end_row", DbType.String, (intItemPerPage * _REQUEST("p")))
            param.Add("#SORT_ORDER", _REQUEST("so"))
            param.Add("#SORT_DIRECTION", _REQUEST("sd"))

            SearchItem.TotalPage = Math.Ceiling(CDec(Cbase.QueryField(sqlTotal, param, "0")) / CDec(intItemPerPage))

            For Each dRow As DataRow In Cbase.QueryTable(sqlRecord, param).Rows
                DonorSearchItem = New DonorSearchItem
                DonorSearchItem.ID = dRow("id").ToString()
                DonorSearchItem.DonorNumber = dRow("SITE_CODE").ToString()
                DonorSearchItem.NationNumber = dRow("COLLECTION_POINT_CODE").ToString()
                DonorSearchItem.ExternalNumber = dRow("NAME").ToString()
                DonorSearchItem.Name = dRow("PLAN_DATE").ToString()
                DonorSearchItem.Surname = dRow("STATUS").ToString()
                DonorSearchItem.Birthday = dRow("COLLECTION_TYPE").ToString()
                'DonorSearchItem.BloodGroup = dRow("Blood_Group").ToString()

                SearchItem.SearchList.Add(DonorSearchItem)
            Next

            'JSONResponse.setItems(JSON.Serialize(Of SearchItem)(SearchItem))
            JSONResponse.setItems(Of SearchItem)(SearchItem)
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try

    End Sub

    Private Sub GetDepartmentData()
        Try
            Dim sql As String = "SELECT * FROM Collection_Point WHERE ID = '" & _REQUEST("departmentid") & "'"
            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim collectionPointDataList = New List(Of Collection_Point)
            For Each dr As DataRow In dt.Rows
                Dim Item As New Collection_Point
                Item.id = dr("ID").ToString
                Item.Location = dr("LOCATION").ToString
                Item.Address = dr("ADDRESS").ToString
                Item.Sub_District = dr("SUB_DISTRICT").ToString
                Item.District = dr("DISTRICT").ToString
                Item.Province = dr("PROVINCE").ToString
                Item.Country_ID = dr("COUNTRY_ID").ToString
                Item.Mobile_1 = dr("MOBILE_1").ToString
                Item.Mobile_2 = dr("Mobile_2").ToString
                Item.Tel = dr("TEL").ToString
                Item.Tel_Ext = dr("TEL_EXT").ToString
                Item.Email = dr("EMAIL").ToString
                Item.Collection_Type = dr("COLLECTION_TYPE").ToString
                Item.Collection_Category_ID = dr("COLLECTION_CATEGORY_ID").ToString
                Item.Collection_Mode = dr("COLLECTION_MODE").ToString
                Item.Start_Time = dr("START_TIME").ToString
                Item.End_Time = dr("END_TIME").ToString
                Item.Zipcode = dr("ZIPCODE").ToString

                collectionPointDataList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of Collection_Point))(collectionPointDataList))
            Response.Write(JSONResponse.ToJSON())

        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetCountry()
        Try
            Dim sql As String = "SELECT * FROM Country "
            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim countryList = New List(Of CountryList)
            For Each dr As DataRow In dt.Rows
                Dim Item As New CountryList
                Item.id = dr("ID").ToString
                Item.name = dr("DESCRIPTION").ToString
                Item.hiig_code = dr("HIIG_CODE").ToString

                countryList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of CountryList))(countryList))
            Response.Write(JSONResponse.ToJSON())

        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetCollectionCategory()
        Try
            Dim sql As String = "SELECT * FROM Collection_Category "
            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim collectionCategoryList = New List(Of Collection_Category)
            For Each dr As DataRow In dt.Rows
                Dim Item As New Collection_Category
                Item.id = dr("ID").ToString
                Item.code = dr("CODE").ToString
                Item.description = dr("DESCRIPTION").ToString
                Item.hiig_code = dr("HIIG_CODE").ToString

                collectionCategoryList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of Collection_Category))(collectionCategoryList))
            Response.Write(JSONResponse.ToJSON())

        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetPlanById()
        Try
            Dim planId As String = _REQUEST("planid")
            Dim getPlan As String = "SELECT c.*, cp.*, cp.CODE as COLLECTION_POINT_CODE, s.code As SITE_CODE,
                                     to_char(nvl(c.PLAN_DATE,nvl(c.PLAN_DATE,sysdate)), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as PLANDATE, 
                                     to_char(nvl(cpc.START_DATE,nvl(cpc.START_DATE,sysdate)), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as RMSTART, 
                                     to_char(nvl(cpc.END_DATE,nvl(cpc.END_DATE,sysdate)), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') AS RMEND, 
                                     cpc.COMMENT_TEXT 
                                     FROM collection_plan c 
                                     inner join collection_point cp on c.COLLECTION_POINT_ID = cp.ID 
                                     inner join site s on c.site_id = s.id 
                                     left join Collection_Plan_Comment cpc ON c.ID = cpc.COLLECTION_PLAN_ID 
                                     WHERE c.ID = '" & planId & "'"
            'CODE as COLLECTION_POINT_CODE, s.code As SITE_CODE, cp.NAME, cp.LACATION, cp.ADDRESS, cp.PROVINCE,
            '                         cp.ZIPCODE, cp.COUNTRY_ID, cp.TEL, cp.FAX, cp.EMAIL, cp.WEBSITE,

            Dim getPlanDetail As String = "SELECT D.ID, D.COLLECTION_PLAN_ID, D.COLLECTION_POINT_ID, D.TARGET_NUMBER, D.INVITE_NUMBER, D.DONATE_NUMBER, D.REFUSE_NUMBER, 
                                           CP.CODE AS COLLECTION_POINT_CODE, CP.NAME, NVL(COUNT(DV.ID),0) AS REGISAMT , NVL(SUM(decode(interview_status,'DONATION',1,0)),0) AS DONATEAMT, 
                                           NVL(SUM(decode(interview_status,'REFUSED',1,0)),0) AS REFUSEAMT 
                                           FROM COLLECTION_PLAN_DETAIL D INNER JOIN COLLECTION_POINT CP ON D.COLLECTION_POINT_ID = CP.ID 
                                           LEFT JOIN DONATION_VISIT DV ON D.COLLECTION_PLAN_ID = DV.COLLECTION_PLAN_ID AND D.COLLECTION_POINT_ID = DV.COLLECTION_POINT_ID 
                                           WHERE D.COLLECTION_PLAN_ID = '" & planId & "' " &
                                          "GROUP BY D.ID, D.COLLECTION_PLAN_ID, D.COLLECTION_POINT_ID, D.TARGET_NUMBER, D.INVITE_NUMBER, D.DONATE_NUMBER, D.REFUSE_NUMBER, 
                                           CP.CODE, CP.NAME "
            Dim GetEditData As New Getcollection_Edit_Data

            Dim dtPlan As DataTable = Cbase.QueryTable(getPlan)
            GetEditData.collection_plan = New List(Of Collection_Plan)
            For Each dr As DataRow In dtPlan.Rows
                Dim Item As New Collection_Plan
                Item.id = dr("ID").ToString
                Item.plan_date = dr("PLANDATE").ToString
                Item.create_date = dr("CREATE_DATE").ToString
                Item.create_staff = dr("CREATE_STAFF").ToString
                Item.collection_point_id = dr("COLLECTION_POINT_ID").ToString
                Item.name = dr("NAME").ToString
                Item.location = dr("LOCATION").ToString
                Item.address = dr("ADDRESS").ToString
                Item.province = dr("PROVINCE").ToString
                Item.zipcode = dr("ZIPCODE").ToString
                Item.country_id = dr("COUNTRY_ID").ToString
                Item.tel = dr("TEL").ToString
                Item.fax = dr("FAX").ToString
                Item.email = dr("EMAIL").ToString
                Item.website = dr("WEBSITE").ToString
                Item.association_id = dr("ASSOCIATION_ID").ToString
                Item.collection_type = dr("COLLECTION_TYPE").ToString
                Item.collection_category_id = dr("COLLECTION_CATEGORY_ID").ToString
                Item.collection_mode = dr("COLLECTION_MODE").ToString
                Item.site_id = dr("SITE_ID").ToString
                Item.target_number = dr("TARGET_NUMBER").ToString
                Item.invite_number = dr("INVITE_NUMBER").ToString
                Item.donate_number = dr("DONATE_NUMBER").ToString
                Item.refuse_number = dr("REFUSE_NUMBER").ToString
                Item.status = dr("STATUS").ToString
                Item.template = dr("TEMPLATE").ToString
                Item.sub_district = dr("SUB_DISTRICT").ToString
                Item.district = dr("DISTRICT").ToString
                Item.mobile_1 = dr("MOBILE_1").ToString
                Item.mobile_2 = dr("MOBILE_2").ToString
                Item.tel_ext = dr("TEL_EXT").ToString
                Item.start_time = dr("START_TIME").ToString
                Item.end_time = dr("END_TIME").ToString
                Item.collection_point_code = dr("COLLECTION_POINT_CODE").ToString
                Item.site_code = dr("SITE_CODE").ToString
                Item.rmstart = dr("RMSTART").ToString
                Item.rmend = dr("RMEND").ToString
                Item.remark = dr("COMMENT_TEXT").ToString

                GetEditData.collection_plan.Add(Item)
            Next

            Dim dtPlanDetail As DataTable = Cbase.QueryTable(getPlanDetail)
            GetEditData.collection_plan_detail = New List(Of Collection_Plan_Detail)
            For Each dr As DataRow In dtPlanDetail.Rows
                Dim Item As New Collection_Plan_Detail
                Item.id = dr("ID").ToString
                Item.collection_plan_id = dr("COLLECTION_PLAN_ID").ToString
                Item.collection_point_id = dr("COLLECTION_POINT_ID").ToString
                Item.target_number = dr("TARGET_NUMBER").ToString
                Item.invite_number = dr("INVITE_NUMBER").ToString
                Item.donate_number = dr("DONATE_NUMBER").ToString
                Item.refuse_number = dr("REFUSE_NUMBER").ToString
                Item.collection_point_code = dr("COLLECTION_POINT_CODE").ToString
                Item.name = dr("NAME").ToString
                Item.regisdonate = dr("REGISAMT").ToString
                Item.donate_amount = dr("DONATEAMT").ToString
                Item.refuse_amount = dr("REFUSEAMT").ToString

                GetEditData.collection_plan_detail.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of Getcollection_Edit_Data)(GetEditData))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetSubCollectionEdit()
        Try
            Dim sql As String = "select * from Collection_Point "
            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim subCollectionPointDataList = New List(Of Sub_Collection_Point)
            For Each dr As DataRow In dt.Rows
                Dim Item As New Sub_Collection_Point
                Item.id = dr("ID").ToString
                Item.label = dr("NAME").ToString
                Item.code = dr("CODE").ToString
                Item.name = dr("NAME").ToString

                subCollectionPointDataList.Add(Item)
            Next

            JSONResponse.setItems(JSON.Serialize(Of List(Of Sub_Collection_Point))(subCollectionPointDataList))
            Response.Write(JSONResponse.ToJSON())

        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetHasPlanDetail()
        Try
            Dim sql As String = "SELECT CPD.*, CP.PLAN_DATE from COLLECTION_PLAN CP INNER JOIN COLLECTION_PLAN_DETAIL CPD ON CP.ID = CPD.COLLECTION_PLAN_ID
                                 WHERE CP.STATUS = 'ACTIVE' AND to_char(CP.PLAN_DATE, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("plandate") & "' "
            Dim dt As DataTable = Cbase.QueryTable(sql)
            Dim HasPlanDataList = New List(Of HasChack)
            For Each dr As DataRow In dt.Rows
                Dim Item As New HasChack
                Item.id = dr("ID").ToString
                Item.collection_plan_id = dr("COLLECTION_PLAN_ID").ToString
                Item.collection_point_id = dr("COLLECTION_POINT_ID").ToString
                Item.plan_date = dr("PLAN_DATE").ToString

                HasPlanDataList.Add(Item)
            Next
            JSONResponse.setItems(JSON.Serialize(Of List(Of HasChack))(HasPlanDataList))
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub SavePlanning()
        Try
            Dim insertplan As String = ""
            Dim planid As String = "0"
            If _REQUEST("how") = "new" Then
                planid = Cbase.QueryField(H2G.nextVal("collection_plan"))

                param.Add(":id", DbType.Int64, planid)
                'param.Add(":plan_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("plandate"))).ToString("dd-MM-yyyy"))
                'param.Add(":create_date", DbType.Date, )
                param.Add(":create_staff", DbType.Int64, _REQUEST("staffid"))
                param.Add(":site_id", DbType.Int64, _REQUEST("site_id"))
                param.Add(":collection_point_id", DbType.Int64, _REQUEST("collection_id"))
                'param.Add(":name", DbType.String, _REQUEST("collection_name"))
                'param.Add(":location", DbType.String, _REQUEST("collection_lacation"))
                'param.Add(":address", DbType.String, _REQUEST("collection_addr"))
                'param.Add(":province", DbType.String, _REQUEST("collection_province"))
                'param.Add(":zipcode", DbType.String, _REQUEST("collection_zipcode"))
                'param.Add(":country_id", DbType.Int64, _REQUEST("collection_country"))
                'param.Add(":tel", DbType.String, _REQUEST("collection_tel"))
                'param.Add(":fax", DbType.String, "")
                'param.Add(":email", DbType.String, _REQUEST("collection_email"))
                'param.Add(":website", DbType.String, "")
                'param.Add(":template", DbType.String, "")
                param.Add(":start_time", DbType.String, _REQUEST("collection_donatetime"))
                param.Add(":end_time", DbType.String, _REQUEST("collection_donationtimeuse"))
                'param.Add(":association_id", DbType.String, "")
                'param.Add(":collection_type", DbType.String, _REQUEST("collection_worktype"))
                'param.Add(":collection_category_id", DbType.Int64, _REQUEST("collection_type"))
                'param.Add(":collection_mode", DbType.String, _REQUEST("collection_cartype"))
                param.Add(":target_number", DbType.Int64, _REQUEST("collection_sumregisdonateexpect"))
                param.Add(":invite_number", DbType.Int64, "")
                param.Add(":donate_number", DbType.Int64, _REQUEST("collection_sumcanregisdonateexpect"))
                param.Add(":refuse_number", DbType.Int64, _REQUEST("collection_sumcantregisdonateexpect"))
                param.Add(":status", DbType.String, _REQUEST("status"))
                param.Add(":staff_id", DbType.Int64, _REQUEST("staffid"))

                'insertplan = "INSERT INTO collection_plan (ID, PLAN_DATE, CREATE_DATE, CREATE_STAFF, SITE_ID, COLLECTION_POINT_ID, NAME, LOCATION,
                '              ADDRESS, PROVINCE, ZIPCODE, COUNTRY_ID, TEL, FAX, EMAIL, WEBSITE, TEMPLATE, START_TIME, END_TIME, ASSOCIATION_ID,
                '              COLLECTION_TYPE, COLLECTION_CATEGORY_ID, COLLECTION_MODE, TARGET_NUMBER, INVITE_NUMBER, DONATE_NUMBER, REFUSE_NUMBER,
                '              STATUS) VALUES (:id, :plan_date, SYSDATE, :create_staff, :site_id, :collection_point_id, :name, :location, 
                '              :address, :province, :zipcode, :country_id, :tel, :fax, :email, :website, :template, :start_time, :end_time, :association_id, 
                '              :collection_type, :collection_category_id, :collection_mode, :target_number, :invite_number, :donate_number, :refuse_number, :status)"

                insertplan = "INSERT INTO collection_plan (ID, PLAN_DATE, CREATE_DATE, CREATE_STAFF, SITE_ID, COLLECTION_POINT_ID,
                              START_TIME, END_TIME, TARGET_NUMBER, INVITE_NUMBER, DONATE_NUMBER, REFUSE_NUMBER,
                              STATUS, UPDATE_DATE, UPDATE_STAFF) VALUES (:id, to_date('" & H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("plandate"))).ToString("dd-MM-yyyy") & "','DD-MM-YYYY'), SYSDATE, :create_staff, :site_id, :collection_point_id, 
                              :start_time, :end_time, :target_number, :invite_number, :donate_number, 
                              :refuse_number, :status, SYSDATE, :staff_id)"

                Cbase.Execute(insertplan, param)

                Dim remarkid As String = Cbase.QueryField(H2G.nextVal("Collection_Plan_Comment"))
                Dim remarkSql As String = "INSERT INTO Collection_Plan_Comment (ID, CREATE_DATE, CREATE_STAFF, COLLECTION_PLAN_ID, START_DATE, END_DATE, COMMENT_TEXT) " &
                              "VALUES ('" & remarkid & "', SYSDATE, " &
                              "'" & _REQUEST("staffid") & "', '" & planid & "', to_date('" & H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("startremark"))).ToString("dd-MM-yyyy") & "','DD-MM-YYYY'), " &
                              "to_date('" & H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("endremark"))).ToString("dd-MM-yyyy") & "','DD-MM-YYYY'), '" & _REQUEST("remark") & "')"
                Cbase.Execute(remarkSql)

                Dim DRecordList As List(Of Collection_Plan_Detail) = JSON.Deserialize(Of List(Of Collection_Plan_Detail))(_REQUEST("subplan_list"))
                For Each item In DRecordList
                    Dim cpdid As String = Cbase.QueryField(H2G.nextVal("collection_plan_detail"))
                    Dim paramDRecord As New SQLCollection

                    paramDRecord.Add(":id", DbType.Int64, cpdid)
                    paramDRecord.Add(":collection_plan_id", DbType.Int64, planid)
                    paramDRecord.Add(":collection_point_id", DbType.Int64, item.collection_point_id)
                    paramDRecord.Add(":target_number", DbType.Int64, item.target_number)
                    paramDRecord.Add(":invite_number", DbType.Int64, 0)
                    paramDRecord.Add(":donate_number", DbType.Int64, item.donate_number)
                    paramDRecord.Add(":refuse_number", DbType.Int64, item.refuse_number)

                    Cbase.Execute("INSERT INTO collection_plan_detail (""ID"", ""COLLECTION_PLAN_ID"", ""COLLECTION_POINT_ID"", ""TARGET_NUMBER"", ""INVITE_NUMBER"", ""DONATE_NUMBER"", ""REFUSE_NUMBER"") 
                                   VALUES (:id, :collection_plan_id, :collection_point_id, :target_number, :invite_number, :donate_number, :refuse_number)", paramDRecord)
                Next

            ElseIf _REQUEST("how") = "edit" Then
                param.Add(":id", DbType.Int64, _REQUEST("planid"))
                param.Add(":plan_date", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("plandate"))).ToString("dd-MM-yyyy"))
                'param.Add(":create_date", DbType.Date, )
                param.Add(":create_staff", DbType.Int64, _REQUEST("staffid"))
                param.Add(":site_id", DbType.Int64, _REQUEST("site_id"))
                param.Add(":collection_point_id", DbType.Int64, _REQUEST("collection_id"))
                'param.Add(":name", DbType.String, _REQUEST("collection_name"))
                'param.Add(":location", DbType.String, _REQUEST("collection_lacation"))
                'param.Add(":address", DbType.String, _REQUEST("collection_addr"))
                'param.Add(":province", DbType.String, _REQUEST("collection_province"))
                'param.Add(":zipcode", DbType.String, _REQUEST("collection_zipcode"))
                'param.Add(":country_id", DbType.Int64, _REQUEST("collection_country"))
                'param.Add(":tel", DbType.String, _REQUEST("collection_tel"))
                'param.Add(":fax", DbType.String, "")
                'param.Add(":email", DbType.String, _REQUEST("collection_email"))
                'param.Add(":website", DbType.String, "")
                'param.Add(":template", DbType.String, "")
                param.Add(":start_time", DbType.String, _REQUEST("collection_donatetime"))
                param.Add(":end_time", DbType.String, _REQUEST("collection_donationtimeuse"))
                'param.Add(":association_id", DbType.String, "")
                'param.Add(":collection_type", DbType.String, _REQUEST("collection_worktype"))
                'param.Add(":collection_category_id", DbType.Int64, _REQUEST("collection_type"))
                'param.Add(":collection_mode", DbType.String, _REQUEST("collection_cartype"))
                param.Add(":target_number", DbType.Int64, _REQUEST("collection_sumregisdonateexpect"))
                param.Add(":invite_number", DbType.Int64, "")
                param.Add(":donate_number", DbType.Int64, _REQUEST("collection_sumcanregisdonateexpect"))
                param.Add(":refuse_number", DbType.Int64, _REQUEST("collection_sumcantregisdonateexpect"))
                param.Add(":status", DbType.String, _REQUEST("status"))
                param.Add(":staff_id", DbType.Int64, _REQUEST("staffid"))

                insertplan = "UPDATE collection_plan SET " &
                             "PLAN_DATE = :plan_date, CREATE_DATE = SYSDATE, CREATE_STAFF = :create_staff, SITE_ID = :site_id, " &
                             "COLLECTION_POINT_ID = :collection_point_id,  START_TIME = :start_time, END_TIME = :end_time, " &
                             "TARGET_NUMBER = :target_number, INVITE_NUMBER = :invite_number, DONATE_NUMBER = :donate_number, " &
                             "REFUSE_NUMBER = :refuse_number, UPDATE_DATE = SYSDATE, UPDATE_STAFF = :staff_id, " &
                             "STATUS = :status WHERE ID = :id"
                Cbase.Execute(insertplan, param)

                Dim remarkSqlUpdate As String = "UPDATE Collection_Plan_Comment SET CREATE_STAFF = '" & _REQUEST("staffid") & "', " &
                                          "START_DATE = to_date('" & H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("startremark"))).ToString("dd-MM-yyyy") & "','DD-MM-YYYY'), " &
                                          "END_DATE = to_date('" & H2G.BE2AC(H2G.Convert(Of DateTime)(_REQUEST("endremark"))).ToString("dd-MM-yyyy") & "','DD-MM-YYYY'), " &
                                          "COMMENT_TEXT = '" & _REQUEST("remark") & "' WHERE COLLECTION_PLAN_ID = '" & _REQUEST("planid") & "'"

                Cbase.Execute(remarkSqlUpdate)

                Cbase.Execute("DELETE FROM collection_plan_detail WHERE COLLECTION_PLAN_ID = '" & _REQUEST("planid") & "'")

                Dim DRecordList As List(Of Collection_Plan_Detail) = JSON.Deserialize(Of List(Of Collection_Plan_Detail))(_REQUEST("subplan_list"))
                For Each item In DRecordList
                    Dim cpdid As String = Cbase.QueryField(H2G.nextVal("collection_plan_detail"))
                    Dim paramDRecord As New SQLCollection

                    paramDRecord.Add(":id", DbType.Int64, cpdid)
                    paramDRecord.Add(":collection_plan_id", DbType.Int64, _REQUEST("planid"))
                    paramDRecord.Add(":collection_point_id", DbType.Int64, item.collection_point_id)
                    paramDRecord.Add(":target_number", DbType.Int64, item.target_number)
                    paramDRecord.Add(":invite_number", DbType.Int64, 0)
                    paramDRecord.Add(":donate_number", DbType.Int64, item.donate_number)
                    paramDRecord.Add(":refuse_number", DbType.Int64, item.refuse_number)

                    Cbase.Execute("INSERT INTO collection_plan_detail (""ID"", ""COLLECTION_PLAN_ID"", ""COLLECTION_POINT_ID"", ""TARGET_NUMBER"", ""INVITE_NUMBER"", ""DONATE_NUMBER"", ""REFUSE_NUMBER"") 
                                   VALUES (:id, :collection_plan_id, :collection_point_id, :target_number, :invite_number, :donate_number, :refuse_number)", paramDRecord)
                Next
            End If

            Cbase.Apply()
            JSONResponse.setItems("{""plan_id"" : """ & planid & """ }")
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Cbase.Rollback()
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub GetMaxDate()
        Try
            Dim sql As String = "select to_char(MAX(plan_date), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as dx from COLLECTION_PLAN where status = 'ACTIVE' and collection_point_id = '" & _REQUEST("departmentid") & "'"
            'Dim sql As String = "select MAX(plan_date) from COLLECTION_PLAN where status = 'ACTIVE' and collection_point_id = '" & _REQUEST("departmentid") & "'"
            Dim maxDate As String = Cbase.QueryField(sql)

            JSONResponse.setItems("{""maxDate"" : """ & maxDate & """ }")
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub CheckDuplicateActive()
        Try
            Dim isCheck As String = "x"
            Dim Data As String = Cbase.QueryField("SELECT ID FROM COLLECTION_PLAN WHERE STATUS = 'ACTIVE' AND COLLECTION_POINT_ID = '" & _REQUEST("collection_id_check") & "' " &
                                                  "AND to_char(PLAN_DATE, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("plandate") & "' ")
            If Data <> "" Then
                isCheck = "x"
            Else
                isCheck = "y"
            End If

            JSONResponse.setItems("{""ischeck"" : """ & isCheck & """ }")
            Response.Write(JSONResponse.ToJSON())
        Catch ex As Exception
            Response.Write(New CallbackException(ex).ToJSON())
        End Try
    End Sub

    Private Sub getsitecodebyid()
        Try
            Dim site_id As String = Cbase.QueryField("SELECT CODE FROM SITE WHERE ID = '" & _REQUEST("site_id_get") & "'")
            JSONResponse.setItems("{""site_id"" : """ & site_id & """ }")
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


Public Structure PlanningLis
    Public id As String
End Structure

Public Structure Collection_Point
    Public id As String
    Public Location As String
    Public Address As String
    Public Sub_District As String
    Public District As String
    Public Province As String
    Public Country_ID As String
    Public Mobile_1 As String
    Public Mobile_2 As String
    Public Tel As String
    Public Tel_Ext As String
    Public Email As String
    Public Collection_Type As String
    Public Collection_Category_ID As String
    Public Collection_Mode As String
    Public Start_Time As String
    Public End_Time As String
    Public Zipcode As String
End Structure

Public Structure CountryList
    Public id As String
    Public name As String
    Public hiig_code As String
End Structure

Public Structure Collection_Category
    Public id As String
    Public code As String
    Public description As String
    Public hiig_code As String
End Structure '

Public Structure Collection_Plan_Detail
    Public id As String
    Public collection_plan_id As String
    Public collection_point_id As String
    Public target_number As String
    Public invite_number As String
    Public donate_number As String
    Public refuse_number As String
    Public collection_point_code As String
    Public name As String
    Public regisdonate As String
    Public donate_amount As String
    Public refuse_amount As String
End Structure

Public Structure Collection_Plan
    Public id As String
    Public plan_date As String
    Public create_date As String
    Public create_staff As String
    Public collection_point_id As String
    Public name As String
    Public location As String
    Public address As String
    Public province As String
    Public zipcode As String
    Public country_id As String
    Public tel As String
    Public fax As String
    Public email As String
    Public website As String
    Public association_id As String
    Public collection_type As String
    Public collection_category_id As String
    Public collection_mode As String
    Public site_id As String
    Public target_number As String
    Public invite_number As String
    Public donate_number As String
    Public refuse_number As String
    Public status As String
    Public template As String
    Public sub_district As String
    Public district As String
    Public mobile_1 As String
    Public mobile_2 As String
    Public tel_ext As String
    Public start_time As String
    Public end_time As String
    Public collection_point_code As String
    Public site_code As String
    Public rmstart As String
    Public rmend As String
    Public remark As String
End Structure

Public Structure Getcollection_Edit_Data
    Public collection_plan As List(Of Collection_Plan)
    Public collection_plan_detail As List(Of Collection_Plan_Detail)
End Structure

Public Structure Sub_Collection_Point
    Public id As String
    Public label As String
    Public name As String
    Public code As String
End Structure

Public Structure HasChack
    Public id As String
    Public collection_plan_id As String
    Public collection_point_id As String
    Public target_number As String
    Public invite_number As String
    Public donate_number As String
    Public refuse_number As String
    Public plan_date As String
End Structure