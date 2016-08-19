Imports H2GEngine
Imports H2GEngine.DataItem
Public Class userAction
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
                Case "selectstaff"
                    Dim StaffItem As New StaffItem
                    sqlMain = "select id, trim(code) as code, firstname as name, lastname as surname from staff where UPPER(trim(code)) = UPPER('" & _REQUEST("user") & "') and trim(pass) = '" & _REQUEST("password") & "' "
                    Dim dt As DataTable = Cbase.QueryTable(sqlMain)
                    ' Login ได้
                    If dt.Rows.Count > 0 Then
                        For Each dRow As DataRow In dt.Rows
                            StaffItem.ID = dRow("id").ToString()
                            StaffItem.Code = dRow("code").ToString()
                            StaffItem.Name = dRow("name").ToString()
                            StaffItem.Surname = dRow("surname").ToString()
                        Next

                        Dim cookie As New Response(Page, False)
                        cookie.Write("ID", StaffItem.ID)
                        cookie.Write("N", StaffItem.Name & " " & StaffItem.Surname)
                        cookie.Write("C", StaffItem.Code)
                        cookie.Write("CPID", _REQUEST("cpid"))
                        cookie.Write("SID", _REQUEST("sid"))

                        StaffItem.PlanID = Cbase.QueryField("select id as plan_id from COLLECTION_PLAN 
                                            where COLLECTION_POINT_ID = '" & _REQUEST("cpid") & "' and site_id = '" & _REQUEST("sid") & "' 
                                            and to_char(plan_date, 'DD/MM/YYYY', 'NLS_CALENDAR=''THAI BUDDHA'' NLS_DATE_LANGUAGE=THAI') = '" & _REQUEST("plandate") & "'", "0")

                        If StaffItem.PlanID <> "0" Then
                            cookie.Write("PID", StaffItem.PlanID)
                            cookie.Write("PD", _REQUEST("plandate"))
                        End If

                    Else
                        Throw New Exception("ชื่อผู้ใช้งานหรือรหัสไม่ถูกต้อง กรุณาตรวจสอบ")
                    End If

                    JSONResponse.setItems(JSON.Serialize(Of StaffItem)(StaffItem))
                Case "createplan"
                    Dim StaffItem As New StaffItem
                    StaffItem.PlanID = Cbase.QueryField(H2G.nextVal("COLLECTION_PLAN"))
                    sqlMain = "insert into COLLECTION_PLAN (ID, PLAN_DATE, CREATE_DATE, CREATE_STAFF, COLLECTION_POINT_ID, SITE_ID, TARGET_NUMBER, DONATE_NUMBER,                     REFUSE_NUMBER, STATUS, TEMPLATE, START_TIME, END_TIME)
                                select {0}, to_date('{1}','DD/MM/YYYY'), SYSDATE, {2}, cpo.ID, cpo.SITE_ID, cp.TARGET_NUMBER, cp.DONATE_NUMBER, cp.REFUSE_NUMBER
                                , 'ACTIVE', 'N', cpo.START_TIME, cpo.END_TIME
                                from COLLECTION_POINT cpo
                                cross join COLLECTION_PLAN cp
                                where CP.TEMPLATE = 'Y' and cpo.id = {3} "
                    Cbase.Execute(String.Format(sqlMain, StaffItem.PlanID, H2G.BE2AC(H2G.Convert(Of Date)(_REQUEST("plandate"))).ToString("dd/MM/yyyy"), H2G.Login.ID, _REQUEST("cpid")))

                    Dim detailID As String = Cbase.QueryField(H2G.nextVal("COLLECTION_PLAN_DETAIL"))
                    sqlMain = "insert into COLLECTION_PLAN_DETAIL (ID, COLLECTION_PLAN_ID, COLLECTION_POINT_ID, TARGET_NUMBER, DONATE_NUMBER, REFUSE_NUMBER)
                                select {0}, {1}, {2}, TARGET_NUMBER, DONATE_NUMBER, REFUSE_NUMBER
                                from COLLECTION_PLAN_DETAIL where id = -1 "
                    Cbase.Execute(String.Format(sqlMain, detailID, StaffItem.PlanID, _REQUEST("cpid")))

                    Dim cookie As New Response(Page, False)
                    cookie.Write("PID", StaffItem.PlanID)
                    cookie.Write("PD", _REQUEST("plandate"))
                    JSONResponse.setItems(JSON.Serialize(Of StaffItem)(StaffItem))
            End Select

        Catch ex As Exception
            Cbase.Rollback()
            Hbase.Rollback()
            Throw ex
        Finally
            Cbase.Apply()
            Hbase.Apply()
        End Try

        Return JSONResponse.ToJSON()
    End Function

    Private Function md5(sPassword As String) As String
        Dim x As New System.Security.Cryptography.MD5CryptoServiceProvider()
        Dim bs As Byte() = System.Text.Encoding.UTF8.GetBytes(sPassword)
        bs = x.ComputeHash(bs)
        Dim s As New System.Text.StringBuilder()
        For Each b As Byte In bs
            s.Append(b.ToString("x2").ToLower())
        Next
        Return s.ToString()
    End Function

End Class

Public Structure StaffItem
    Public ID As String
    Public Code As String
    Public Name As String
    Public Surname As String
    Public PlanID As String

End Structure

