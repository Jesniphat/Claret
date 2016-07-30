﻿Imports H2GEngine
Imports H2GEngine.DataItem
Public Class qualityAction
    Inherits UI.Page

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
            JSONResponse = New CallbackException(ex)
            Response.Write(JSONResponse.ToJSON())
        Finally
            Cbase.Apply()
        End Try
    End Sub

    Private Function Action()
        Select Case _REQUEST("action")
            Case "getexamination" : getExamination()
            Case "savereceipthospital" : saveReceiptHospital()
            Case "getreceipthospital" : getReceiptHospital()
            Case Else
                Dim exMsg As String = IIf(String.IsNullOrEmpty(_REQUEST("action")), "", _REQUEST("action"))
                Throw New Exception("Not found action [" & exMsg & "].", New Exception("Please check your action name"))
        End Select

        Return JSONResponse.ToJSON()
    End Function

    Private Sub getExamination()

        Dim DataList As New List(Of ExamLabItem)
        Dim DataItem As ExamLabItem
        sqlMain = "select ex.id, ex.code, ex.description as description
                    , exg.id as group_id, exg.code as group_code, exg.description as group_description
                    from EXAMINATION_GROUP exg
                    inner join EXAMINATION_GROUPING gp on gp.EXAMINATION_GROUP_id = exg.id
                    inner join EXAMINATION ex on ex.id = gp.EXAMINATION_id
                    where UPPER(exg.code) = UPPER('" & _REQUEST("excode") & "') "
        Dim dt As DataTable = Cbase.QueryTable(sqlMain)

        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows()
                DataItem = New ExamLabItem
                DataItem.ID = dr("id").ToString()
                DataItem.Code = dr("code").ToString()
                DataItem.Description = dr("description").ToString()
                DataItem.GroupID = dr("group_id").ToString()
                DataItem.GroupCode = dr("group_code").ToString()
                DataItem.GroupDescription = dr("group_description").ToString()
                DataList.Add(DataItem)
            Next
        Else
            sqlMain = "select ex.id, ex.code, ex.description as description from EXAMINATION ex where UPPER(ex.code) = UPPER('" & _REQUEST("excode") & "') "
            dt = Cbase.QueryTable(sqlMain)
            If dt.Rows.Count > 0 Then
                For Each dr As DataRow In dt.Rows()
                    DataItem = New ExamLabItem
                    DataItem.ID = dr("id").ToString()
                    DataItem.Code = dr("code").ToString()
                    DataItem.Description = dr("description").ToString()
                    DataList.Add(DataItem)
                Next
            Else
                Dim exMsg As String = IIf(String.IsNullOrEmpty(_REQUEST("excode")), "", _REQUEST("excode"))
                Throw New Exception("ไม่พบข้อมูลของ " & exMsg & "", New Exception("ไม่พบข้อมูลของ " & exMsg & ""))
            End If
        End If

        JSONResponse.setItems(Of List(Of ExamLabItem))(DataList)
    End Sub

    Private Sub saveReceiptHospital()
        Dim ReceiptItem As ReceiptHospitalItem = JSON.Deserialize(Of ReceiptHospitalItem)(_REQUEST("rh"))
        If String.IsNullOrEmpty(ReceiptItem.ID) Then
            ReceiptItem.ID = Cbase.QueryField(H2G.nextVal("RECEIPT_HOSPITAL"))
            sqlMain = "INSERT INTO RECEIPT_HOSPITAL (ID, CREATE_STAFF, CREATE_DATE, REGISTER_STAFF, REGISTER_DATE, DONATION_TO_ID, COLLECTION_POINT_ID
                        , SITE_ID, HOSPITAL_ID, DEPARTMENT_ID, LAB_ID, REASON_ID)
                        VALUES(:ID, :CREATE_STAFF, sysdate, :REGISTER_STAFF, :REGISTER_DATE, :DONATION_TO_ID, :COLLECTION_POINT_ID
                        , :SITE_ID, :HOSPITAL_ID, :DEPARTMENT_ID, :LAB_ID, :REASON_ID)"
            Cbase.Execute(sqlMain, ReceiptHospitalItem.WithCollection(ReceiptItem))
        End If

        Dim ReceiptDetailList As List(Of ReceiptHospitalDetailItem) = JSON.Deserialize(Of List(Of ReceiptHospitalDetailItem))(_REQUEST("rhd"))
        For Each item In ReceiptDetailList
            item.ID = Cbase.QueryField(H2G.nextVal("RECEIPT_HOSPITAL_DETAIL"))
            item.ReceiptHospitalID = ReceiptItem.ID
            sqlMain = "INSERT INTO RECEIPT_HOSPITAL_DETAIL
                        (ID, RECEIPT_HOSPITAL_ID, EXAMINATION_GROUP_ID, EXAMINATION_GROUP_CODE, EXAMINATION_GROUP_DESC, EXAMINATION_ID, EXAMINATION_CODE, EXAMINATION_DESC)
                        VALUES (:ID, :RECEIPT_HOSPITAL_ID, :EXAMINATION_GROUP_ID, :EXAMINATION_GROUP_DESC, :EXAMINATION_GROUP_CODE, :EXAMINATION_ID, :EXAMINATION_CODE, :EXAMINATION_DESC)"
            Cbase.Execute(sqlMain, ReceiptHospitalDetailItem.WithCollection(item))
        Next

        JSONResponse.setItems(Of ReceiptHospitalItem)(ReceiptItem)
    End Sub

    Private Sub getReceiptHospital()

        Dim DataItem As New RecHospitalHeadItem
        sqlMain = "select reh.id as receipt_id, hpt.name as hospital, 0 as queue_count
                    from RECEIPT_HOSPITAL reh 
                    inner join HOSPITAL hpt on hpt.id = reh.hospital_id
                    where reh.id = '" & _REQUEST("receipthospitalid") & "' "
        Dim dt As DataTable = Cbase.QueryTable(sqlMain)

        If dt.Rows.Count > 0 Then
            For Each dr As DataRow In dt.Rows()
                DataItem.ID = dr("receipt_id").ToString()
                DataItem.HospitalName = dr("hospital").ToString()
                DataItem.QueueCount = dr("queue_count").ToString()
            Next
        End If

        JSONResponse.setItems(Of RecHospitalHeadItem)(DataItem)
    End Sub

End Class

Public Structure ExamLabItem
    Public ID As String
    Public Code As String
    Public Description As String
    Public GroupID As String
    Public GroupCode As String
    Public GroupDescription As String

End Structure

Public Class ReceiptHospitalItem
    Public ID As String
    Public CreateStaff As String
    Public RegisterStaff As String
    Public RegisterDate As String
    Public DonationToID As String
    Public CollectionPointID As String
    Public SiteID As String
    Public HospitalID As String
    Public DepartmentID As String
    Public LabID As String
    Public ReasonID As String

    Public Shared Function WithCollection(ByVal item As ReceiptHospitalItem) As SQLCollection
        Dim param As New SQLCollection()
        With item
            param.Add(":ID", DbType.Int64, .ID)
            param.Add(":CREATE_STAFF", DbType.Int64, H2G.Login.ID)
            param.Add(":REGISTER_STAFF", DbType.Int64, .RegisterStaff)
            param.Add(":REGISTER_DATE", DbType.Date, H2G.BE2AC(H2G.Convert(Of DateTime)(.RegisterDate.Replace("/", "-"))).ToString("dd-MM-yyyy"))
            param.Add(":DONATION_TO_ID", DbType.Int64, .DonationToID)
            param.Add(":COLLECTION_POINT_ID", DbType.Int64, H2G.Login.CollectionPointID)
            param.Add(":SITE_ID", DbType.Int64, H2G.Login.SiteID)
            param.Add(":HOSPITAL_ID", DbType.Int64, .HospitalID)
            param.Add(":DEPARTMENT_ID", DbType.Int64, .DepartmentID)
            param.Add(":LAB_ID", DbType.Int64, .LabID)
            param.Add(":REASON_ID", DbType.Int64, .ReasonID)

        End With
        Return param
    End Function
End Class

Public Structure ReceiptHospitalDetailItem
    Public ID As String
    Public ReceiptHospitalID As String
    Public ExaminationGroupID As String
    Public ExaminationGroupCode As String
    Public ExaminationGroupDesc As String
    Public ExaminationID As String
    Public ExaminationCode As String
    Public ExaminationDesc As String

    Public Shared Function WithCollection(ByVal item As ReceiptHospitalDetailItem) As SQLCollection
        Dim param As New SQLCollection()
        With item
            param.Add(":ID", DbType.Int64, .ID)
            param.Add(":RECEIPT_HOSPITAL_ID", DbType.Int64, .ReceiptHospitalID)
            param.Add(":EXAMINATION_GROUP_ID", DbType.Int64, .ExaminationGroupID)
            param.Add(":EXAMINATION_GROUP_CODE", DbType.String, .ExaminationGroupCode)
            param.Add(":EXAMINATION_GROUP_DESC", DbType.String, .ExaminationGroupDesc)
            param.Add(":EXAMINATION_ID", DbType.Int64, .ExaminationID)
            param.Add(":EXAMINATION_CODE", DbType.String, .ExaminationCode)
            param.Add(":EXAMINATION_DESC", DbType.String, .ExaminationDesc)

        End With
        Return param
    End Function
End Structure

Public Structure RecHospitalHeadItem
    Public ID As String
    Public HospitalName As String
    Public QueueCount As String

End Structure