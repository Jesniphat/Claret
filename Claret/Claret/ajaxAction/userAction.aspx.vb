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
                    sqlMain = "select id, code, name, surname from staff where UPPER(code) = UPPER('" & _REQUEST("user") & "') and password = '" & _REQUEST("password") & "' "
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

                    Else
                        Throw New Exception("ชื่อผู้ใช้งานหรือรหัสไม่ถูกต้อง กรุณาตรวจสอบ")
                    End If

                    JSONResponse.setItems(JSON.Serialize(Of StaffItem)(StaffItem))
            End Select

        Catch ex As Exception
            Cbase.Rollback()
            Throw ex
        Finally
            Cbase.Apply()
        End Try

        Return JSONResponse.ToJSON()
    End Function
End Class

Public Structure StaffItem
    Public ID As String
    Public Code As String
    Public Name As String
    Public Surname As String

End Structure

