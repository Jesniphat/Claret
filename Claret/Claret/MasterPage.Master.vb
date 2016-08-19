Imports H2GEngine
Imports System.Globalization
Imports System.Threading

Public Class MasterPage
    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Call H2G.setMasterData(Me.Page)
        Dim Cbase As New oraDBQuery(oraDBQuery.Schema.CLARET)
        Dim strUserInfo As String = ""
        Dim dt As DataTable = Cbase.QueryTable("select st.firstname || ' ' || st.lastname || ' (' || st.code || ')' as staff_name, cp.name as point_name
                                                , to_char(cp.plan_date, 'DD MONTHYYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as date_text
                                                , to_char(cp.plan_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') as plan_date
                                                from staff st 
                                                cross join (select CP.plan_date, CPT.name from COLLECTION_PLAN cp 
						                                                INNER JOIN collection_point cpt on cpt.id = cp.collection_point_id
						                                                where cp.id = '" & H2G.Login.PlanID & "') cp
                                                where st.id = '" & H2G.Login.ID & "' ")
        If dt.Rows.Count > 0 Then
            strUserInfo = "หน่วย " & dt.Rows(0)("point_name").ToString()
            strUserInfo &= " : แผน " & dt.Rows(0)("date_text").ToString()
            spCollectionPoint.InnerText = strUserInfo
            spUserName.InnerText = dt.Rows(0)("staff_name").ToString()
            data.Attributes.Add("plan_date", dt.Rows(0)("plan_date").ToString())
        End If

    End Sub

End Class