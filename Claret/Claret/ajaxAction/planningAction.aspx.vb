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

            If Not String.IsNullOrEmpty(_REQUEST("sectorcode")) Then param.Add("#SITE_ID", " and (UPPER(cp.SITE_ID) like UPPER('" & _REQUEST("sectorcode") & "')) ")
            If Not String.IsNullOrEmpty(_REQUEST("departmentcode")) Then param.Add("#COLLECTION_POINT_ID", " and (UPPER(cp.COLLECTION_POINT_ID) like UPPER('" & _REQUEST("departmentcode") & "')) ")
            If Not String.IsNullOrEmpty(_REQUEST("plandate")) Then param.Add("#PLAN_DATE", "and to_char(cp.PLAN_DATE, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("plandate") & "' ")
            If Not String.IsNullOrEmpty(_REQUEST("departmentname")) Then param.Add("#NAME", " and UPPER(cpo.NAME) like UPPER('" & _REQUEST("departmentname") & "') ")
            'If Not String.IsNullOrEmpty(_REQUEST("samplenumber")) Then param.Add("#BLOOD_GROUP", " and UPPER(rg.description) like UPPER('" & _REQUEST("bloodgroup") & "') ")
            'If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", " and nvl(dv.VISIT_DATE,dv.CREATE_DATE) between to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy') and to_date('" & _REQUEST("reportdate").Replace("/", "") & "','ddMMyyyy')+1 ")

            'If Not String.IsNullOrEmpty(_REQUEST("reportdate")) Then param.Add("#REPORT_DATE", "and to_char(nvl(dv.VISIT_DATE,dv.CREATE_DATE), 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI')='" & _REQUEST("reportdate") & "' ")

            If Not String.IsNullOrEmpty(_REQUEST("planstatus")) Then param.Add("#STATUS", " and cp.STATUS = '" & _REQUEST("planstatus") & "' ")
            If Not String.IsNullOrEmpty(_REQUEST("plantype")) Then param.Add("#COLLECTION_TYPE", " and cp.COLLECTION_TYPE = '" & _REQUEST("plantype") & "' ")

            Dim sqlRecord As String = "SELECT DN.rn as row_num, dn.* 
                                FROM (
                                    SELECT ROWNUM AS rn, dn.* 
                                        FROM (
                                            SELECT dn.* 
                                                FROM (
									                    select cp.ID, cp.SITE_ID, cp.COLLECTION_POINT_ID, cpo.NAME, cp.PLAN_DATE, cp.STATUS, cp.COLLECTION_TYPE from COLLECTION_PLAN cp 
                                                        LEFT JOIN COLLECTION_POINT cpo on cp.COLLECTION_POINT_ID = cpo.ID
                                                        where 1=1 /*#SITE_ID*/ /*#STATUS*/ /*#COLLECTION_TYPE*/ 
                                                        /*#COLLECTION_POINT_ID*/ /*#PLAN_DATE*/ /*#NAME*/  
									                ) dn
                                            ORDER BY dn./*#SORT_ORDER*/ /*#SORT_DIRECTION*/
                                            ) dn
                                    ) dn
                                WHERE rn BETWEEN :start_row AND :end_row "

            Dim sqlTotal As String = "SELECT nvl(count(COLLECTION_POINT_ID),0) from ( select cp.SITE_ID, cp.COLLECTION_POINT_ID, cpo.NAME, cp.PLAN_DATE, cp.STATUS, cp.COLLECTION_TYPE from COLLECTION_PLAN cp 
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
                DonorSearchItem.DonorNumber = dRow("SITE_ID").ToString()
                DonorSearchItem.NationNumber = dRow("COLLECTION_POINT_ID").ToString()
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
            Dim getPlan As String = "SELECT c.*, cp.CODE as COLLECTION_POINT_CODE FROM collection_plan c inner join collection_point cp on c.COLLECTION_POINT_ID = cp.ID WHERE c.ID = '" & planId & "'"
            Dim getPlanDetail As String = "SELECT D.ID, D.COLLECTION_PLAN_ID, D.COLLECTION_POINT_ID, D.TARGET_NUMBER, D.INVITE_NUMBER, D.DONATE_NUMBER, D.REFUSE_NUMBER, 
                                           CP.CODE AS COLLECTION_POINT_CODE, CP.NAME, SUM(DV.ID) AS REGISDONATE 
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
                Item.plan_date = dr("PLAN_DATE").ToString
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
                Item.regisdonate = dr("REGISDONATE").ToString

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