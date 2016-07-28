﻿Imports H2GEngine
Public Class masterAction
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        'Call H2G.setMasterData(Me.Page)
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
        Try
            Select Case _REQUEST("action")
                Case "site"
                    Dim countryList As New List(Of KeyCodeItem)
                    Dim CountryItem As KeyCodeItem
                    Dim dt As DataTable = Cbase.QueryTable("select id, code, name from site where 1=1 order by name ")

                    For Each dr As DataRow In dt.Rows()
                        CountryItem = New KeyCodeItem
                        CountryItem.id = dr("id").ToString()
                        CountryItem.code = dr("code").ToString()
                        CountryItem.name = dr("name").ToString()
                        countryList.Add(CountryItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(countryList))
                Case "collection"
                    Dim countryList As New List(Of KeyCodeItem)
                    Dim CountryItem As KeyCodeItem
                    Dim dt As DataTable = Cbase.QueryTable("select id, code, name from collection_point order by name ")

                    For Each dr As DataRow In dt.Rows()
                        CountryItem = New KeyCodeItem
                        CountryItem.id = dr("id").ToString()
                        CountryItem.code = dr("code").ToString()
                        CountryItem.name = dr("name").ToString()
                        countryList.Add(CountryItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(countryList))
                Case "country"
                    Dim countryList As New List(Of KeyCodeItem)
                    Dim CountryItem As KeyCodeItem
                    If Not String.IsNullOrEmpty(_REQUEST("countryid")) Then param.Add("#id", "and id = '" & _REQUEST("countryid") & "'")
                    If Not String.IsNullOrEmpty(_REQUEST("countryCode")) Then param.Add("#id", "and h2g_code = '" & _REQUEST("countryCode") & "'")
                    If Not String.IsNullOrEmpty(_REQUEST("countryName")) Then param.Add("#id", "and description = '" & _REQUEST("countryName") & "'")
                    Dim dt As DataTable = Cbase.QueryTable("select id, hiig_code, description from country where 1=1 /*#id*/ /*#code*/ /*#name*/ order by description ")

                    For Each dr As DataRow In dt.Rows()
                        CountryItem = New KeyCodeItem
                        CountryItem.id = dr("id").ToString()
                        CountryItem.code = dr("id").ToString()
                        CountryItem.name = dr("description").ToString()
                        countryList.Add(CountryItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(countryList))
                Case "externalcard"
                    Dim DataList As New List(Of ExCardItem)
                    Dim DataItem As ExCardItem
                    Dim dt As DataTable = Cbase.QueryTable("select id, hiig_code, description, card_type from external_card where 1=1 order by description ")

                    For Each dr As DataRow In dt.Rows()
                        DataItem = New ExCardItem
                        DataItem.id = dr("id").ToString()
                        DataItem.code = dr("id").ToString()
                        DataItem.name = dr("description").ToString()
                        DataItem.cardType = dr("card_type").ToString()
                        DataList.Add(DataItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of ExCardItem))(DataList))
                Case "titlename"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, hiig_code, title_m as title_name from title where title_m is not null order by title_m"
                    If _REQUEST("gender") = "F" Then sql = "select id, hiig_code, title_f as title_name from title where title_m is not null order by title_f"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    For Each dr As DataRow In dt.Rows()
                        DataItem = New KeyCodeItem
                        DataItem.id = dr("id").ToString()
                        DataItem.code = dr("id").ToString()
                        DataItem.name = dr("title_name").ToString()
                        DataList.Add(DataItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "occupation"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, hiig_code, description from occupation order by description"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    For Each dr As DataRow In dt.Rows()
                        DataItem = New KeyCodeItem
                        DataItem.id = dr("id").ToString()
                        DataItem.code = dr("id").ToString()
                        DataItem.name = dr("description").ToString()
                        DataList.Add(DataItem)
                    Next
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "nationality"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, description from nationality order by description"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.id = dr("id").ToString()
                            DataItem.code = dr("id").ToString()
                            DataItem.name = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Nationality has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "association"
                    Dim DataList As New List(Of ExCardItem)
                    Dim DataItem As ExCardItem
                    Dim sql As String = "select id, code, code || ' ' || name as name from association where name is not null order by name"
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New ExCardItem
                            DataItem.id = dr("id").ToString()
                            DataItem.code = dr("id").ToString()
                            DataItem.name = dr("name").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Association has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of ExCardItem))(DataList))
                Case "hospital"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, code, name from hospital ORDER BY name "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.id = dr("id").ToString()
                            DataItem.code = dr("code").ToString()
                            DataItem.name = dr("name").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Hospital has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "lab"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select id, code, description from lab ORDER BY code "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.id = dr("id").ToString()
                            DataItem.code = dr("code").ToString()
                            DataItem.name = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Hospital has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
                Case "examination"
                    Dim DataList As New List(Of KeyCodeItem)
                    Dim DataItem As KeyCodeItem
                    Dim sql As String = "select * from (
                                            select id, description, 'E' as exam_type from EXAMINATION 
                                            union ALL
                                            select id, description, 'G' as exam_type from EXAMINATION_GROUP 
                                         ) dn order by description "
                    Dim dt As DataTable = Cbase.QueryTable(sql)

                    If dt.Rows.Count > 0 Then
                        For Each dr As DataRow In dt.Rows()
                            DataItem = New KeyCodeItem
                            DataItem.id = dr("exam_type").ToString()
                            DataItem.code = dr("id").ToString()
                            DataItem.name = dr("description").ToString()
                            DataList.Add(DataItem)
                        Next
                    Else
                        Throw New Exception("No data found.", New Exception("Examination has no record"))
                    End If
                    JSONResponse.setItems(JSON.Serialize(Of List(Of KeyCodeItem))(DataList))
            End Select

        Catch ex As Exception
            Throw ex
        End Try
        Return JSONResponse.ToJSON()
    End Function
End Class

Public Structure KeyCodeItem
    Public id As String
    Public name As String
    Public code As String

End Structure
Public Structure ExCardItem
    Public id As String
    Public name As String
    Public code As String
    Public cardType As String

End Structure