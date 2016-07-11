Imports System.Data.SqlClient
Imports System.Collections.Generic

Public Class DBQuery
    Private Const _DB_USER As String = "travoxmos"
    Private Const _DB_PASS As String = "systrav"
    Private Const _DB_TIMEOUT As Integer = 30

    Public Enum Schema
        [GLOBAL]
        [MBOS]
        [HOTEL]
        [TRANSFER]
    End Enum
    Public ReadOnly Property Connected() As Boolean
        Get
            Return Not (connection Is Nothing OrElse connection.State = ConnectionState.Closed)
        End Get
    End Property

    Private StoreOutput As String
    Private DataCompany As DataRow
    Protected transection As SqlTransaction
    Protected connection As SqlConnection

    Private Enum QueryCase
        [INSERT]
        [UPDATE]
        [DELETE]
        [SELECT]
    End Enum


    ReadOnly Property ConnectionString() As String
        Get
            Return String.Format(My.Resources.ConnectionMBOS, DataCompany("database_name").ToString(), _DB_USER, _DB_PASS)
        End Get
    End Property

    Public Sub New()
        Dim BASE1 As New DataTable
        Try
            Try
                DataCompany = HttpContext.Current.Application("base1").Select("code = '" & H2G.CompanyCode.ToLower & "'")(0)
            Catch
                Using mbosConn As New SqlConnection(String.Format(My.Resources.ConnectionMBOS, "travoxmos", _DB_USER, _DB_PASS))
                    mbosConn.Open()
                    Dim mbosCommand As New SqlCommand(My.Resources.SELECT_SiteCustomer, mbosConn)
                    mbosCommand.CommandTimeout = _DB_TIMEOUT
                    Dim adapter As New SqlDataAdapter(mbosCommand)
                    adapter.Fill(BASE1)
                    mbosConn.Close()
                    DataCompany = BASE1.Select("code = '" & H2G.CompanyCode.ToLower & "'")(0)
                End Using
            End Try
        Catch
            If (BASE1 Is Nothing OrElse BASE1.Rows.Count = 0) Then
                Throw New Exception("DATABASE SERVER DOWN")
            Else
                Throw New Exception("Company code is " & H2G.CompanyCode & " not found.")
            End If
        End Try
    End Sub

    Protected Overrides Sub Finalize()
        Try
            connection.Close()
        Catch
        End Try
        MyBase.Finalize()
    End Sub

    Public Function Execute(ByVal query As String) As String
        Return Execute(query, New ParameterCollection())
    End Function

    Public Function Execute(ByVal query As String, ByVal param As ParameterCollection) As String
        Dim AfterInsertID As String = ""
        If (connection Is Nothing OrElse connection.State = ConnectionState.Closed) Then
            connection = New SqlConnection(Me.ConnectionString())
            connection.Open()
            transection = connection.BeginTransaction()
        End If
        If (Me.Connected) Then
            Dim command As SqlCommand = BuildCommands(query, connection, param)
            command.Transaction = transection
            AfterInsertID = command.ExecuteScalar()
        End If
        Return AfterInsertID
    End Function

    Public Function Apply() As Boolean
        Dim result As Boolean = False
        Try
            If (Me.Connected) Then
                transection.Commit()
                connection.Close()
                result = True
            End If
        Catch ex As Exception
            transection.Rollback()
            connection.Close()
            Throw New Exception(ex.Message())
        End Try
        Return result
    End Function

    Public Sub Rollback()
        Try
            transection.Rollback()
            connection.Close()
        Catch
        End Try
    End Sub

    Public Function QueryField(ByVal query As String) As String
        Return QueryField(query, New ParameterCollection(), "")
    End Function

    Public Function QueryField(ByVal query As String, ByVal _default As String) As String
        Return QueryField(query, New ParameterCollection(), _default)
    End Function

    Public Function QueryField(ByVal query As String, ByVal param As ParameterCollection) As String
        Return QueryField(query, param, "")
    End Function

    Public Function QueryField(ByVal query As String, ByVal param As ParameterCollection, ByVal _default As String) As String
        Dim dtQuery As DataTable = QueryTable(query, param)
        Dim result As String = _default
        If (dtQuery.Columns.Count >= 1 And dtQuery.Rows.Count >= 1) Then
            result = dtQuery.Rows(0)(0).ToString()
        End If
        Return result
    End Function

    Public Function QueryTable(ByVal query As String) As DataTable
        Return QueryTable("H2G_TableQuery", query, New ParameterCollection())
    End Function
    Public Function QueryTable(ByVal query As String, ByVal param As ParameterCollection) As DataTable
        Return QueryTable("H2G_TableQuery", query, param)
    End Function

    Public Function QueryTable(ByVal db As DB) As DataTable
        Return QueryTable(db.TableName, db.SQL, New ParameterCollection())
    End Function
    Public Function QueryTable(ByVal db As DB, ByVal param As ParameterCollection) As DataTable
        Return QueryTable(db.TableName, db.SQL, param)
    End Function

    Public Function QueryTable(ByVal table_name As String, ByVal query As String) As DataTable
        Return QueryTable(table_name, query, New ParameterCollection())
    End Function
    Public Function QueryTable(ByVal table_name As String, ByVal query As String, ByVal param As ParameterCollection) As DataTable
        Dim result As New DataTable
        Dim trans As SqlTransaction, conn As New SqlConnection(Me.ConnectionString())

        conn.Open()
        trans = conn.BeginTransaction(IsolationLevel.ReadUncommitted)
        Dim mbosCommand As SqlCommand = BuildCommands(query, conn, param)
        mbosCommand.Transaction = trans
        Dim adapter As New SqlDataAdapter(mbosCommand)
        Try
            adapter.Fill(result)
            trans.Commit()
        Catch ex As Exception
            trans.Rollback()
            Throw ex
        End Try
        conn.Close()
        result.TableName = table_name
        Return result
    End Function

    Public Function StoredParamOne(ByVal store_name As String, ByVal schema_name As Schema, ByVal param As ParameterCollection) As String
        param = StoredParam(store_name, schema_name, param)
        Dim result As String = StoreOutput
        StoreOutput = Nothing
        If (Not String.IsNullOrEmpty(result)) Then result = param.Item(result).DefaultValue.ToString()
        Return result
    End Function
    Public Function StoredParam(ByVal store_name As String, ByVal schema_type As Schema, ByVal param As ParameterCollection) As ParameterCollection
        Dim NowConnection As Boolean = False
        Dim schema_name As String = "/*[MBOS]*/"
        Dim mbosCommand As New SqlCommand
        Select Case schema_type
            Case Schema.GLOBAL : schema_name = "/*[GLOBAL]*/"
            Case Schema.HOTEL : schema_name = "/*[HOTEL]*/"
            Case Schema.MBOS : schema_name = "/*[MBOS]*/"
            Case Schema.TRANSFER : schema_name = "/*[TRANSFER]*/"
        End Select

        If (Not Me.Connected) Then
            connection = New SqlConnection(Me.ConnectionString())
            connection.Open()
            NowConnection = True
        End If
        mbosCommand = BuildCommands(schema_name & "[" & store_name.Trim() & "]", connection, param)
        Dim adapter As New SqlDataAdapter(mbosCommand)
        If (Not NowConnection) Then mbosCommand.Transaction = transection
        mbosCommand.CommandType = CommandType.StoredProcedure
        mbosCommand.Connection = connection
        mbosCommand.ExecuteNonQuery()
        If (NowConnection) Then connection.Close()

        For Each para As SqlParameter In mbosCommand.Parameters
            If (para.Direction <> ParameterDirection.Input) Then
                'If (para.Value Is DBNull.Value) Then Throw New Exception("System Stored Procedures Value Return is NULL")
                param.Item(para.ParameterName).DefaultValue = IIf(para.Value Is DBNull.Value, "", para.Value)
                param.Item(para.ParameterName).DbType = para.DbType
                StoreOutput = para.ParameterName
            End If
        Next

        Return param
    End Function

    Public Shared Function InitializeSiteCustomer() As DataTable
        Dim dtSiteCustomer As New DataTable
        Try
            Dim sConn As String = String.Format(My.Resources.ConnectionMBOS, "travoxmos", _DB_USER, _DB_PASS)
            Using mbosConn As New SqlConnection(sConn)
                mbosConn.Open()
                Dim mbosCommand As New SqlCommand(My.Resources.SELECT_SiteCustomer, mbosConn)
                mbosCommand.CommandTimeout = _DB_TIMEOUT
                Dim adapter As New SqlDataAdapter(mbosCommand)
                adapter.Fill(dtSiteCustomer)
                mbosConn.Close()
            End Using
        Catch ex As Exception
            Throw New Exception("<b>" & ex.Message & "</b>")
        End Try
        Return dtSiteCustomer
    End Function

    Private Function BuildCommands(ByVal query As String, ByVal mbosConn As SqlConnection, ByVal param As ParameterCollection) As SqlCommand
        Dim qCase As QueryCase = QueryCase.SELECT
        Try
            If (query.Contains("SQL::")) Then query = H2G.FileRead("!SQLStore\" & query.Replace("SQL::", "") & ".sql")
            If (query.ToLower().Contains("insert into") And query.ToLower().Contains("values")) Then
                qCase = QueryCase.INSERT
                query &= " SELECT @@IDENTITY"
            ElseIf (query.ToLower().Contains("update") And query.ToLower().Contains("set")) Then
                qCase = QueryCase.UPDATE
            ElseIf (query.ToLower().Contains("delete") And query.ToLower().Contains("from")) Then
                qCase = QueryCase.DELETE
            End If
        Catch
            Throw New Exception("SQL Query file", New Exception("SQL query file path is not exists."))
        End Try

        Dim mbosCommand As New SqlCommand(query, mbosConn)
        mbosCommand.CommandTimeout = _DB_TIMEOUT
        For Each para As Parameter In param
            If (para.Name.Contains("@")) Then
                If (para.Direction <> ParameterDirection.Input) Then
                    mbosCommand.Parameters.Add(para.Name, SqlDbType.NVarChar, 4000)
                Else
                    Dim paramSize As Integer = 0
                    If (para.DefaultValue IsNot Nothing) Then paramSize = para.DefaultValue.Length
                    mbosCommand.Parameters.Add(para.Name, para.DbType, paramSize)
                    mbosCommand.Parameters.Item(para.Name).Size = paramSize
                    mbosCommand.Parameters.Item(para.Name).DbType = para.DbType
                    mbosCommand.Parameters.Item(para.Name).Value = DBNull.Value
                End If
                mbosCommand.Parameters.Item(para.Name).Direction = para.Direction
                Select Case qCase
                    Case QueryCase.SELECT
                        If para.DbType = DbType.Date Or para.DbType = DbType.DateTime Or para.DbType = DbType.DateTime2 Then
                            mbosCommand.Parameters.Item(para.Name).DbType = DbType.String
                            mbosCommand.Parameters.Item(para.Name).Value = H2G.Convert(Of DateTime)(para.DefaultValue).ToString("yyyy-MM-dd HH:mm:ss")
                        ElseIf ((para.DbType = DbType.String And para.DefaultValue IsNot Nothing) Or Not String.IsNullOrEmpty(para.DefaultValue)) Then
                            mbosCommand.Parameters.Item(para.Name).Value = para.DefaultValue
                        End If
                    Case Else
                        Select Case para.DbType
                            Case DbType.String
                                If (para.DefaultValue IsNot Nothing) Then
                                    mbosCommand.Parameters.Item(para.Name).Value = para.DefaultValue
                                End If
                            Case DbType.Decimal
                                If (para.DefaultValue IsNot Nothing) Then
                                    mbosCommand.Parameters.Item(para.Name).Value = H2G.Dec(para.DefaultValue)
                                End If
                            Case DbType.Date, DbType.DateTime, DbType.DateTime2
                                mbosCommand.Parameters.Item(para.Name).Size = 18
                                mbosCommand.Parameters.Item(para.Name).DbType = DbType.String
                                If (Not String.IsNullOrEmpty(para.DefaultValue)) Then
                                    mbosCommand.Parameters.Item(para.Name).Value = H2G.Convert(Of DateTime)(para.DefaultValue).ToString("yyyy-MM-dd HH:mm:ss")
                                End If
                                query = query.Replace(para.Name, "CONVERT(DATETIME," & para.Name & ", 120)")
                            Case Else
                                If (Not String.IsNullOrEmpty(para.DefaultValue)) Then
                                    mbosCommand.Parameters.Item(para.Name).Value = para.DefaultValue
                                End If
                        End Select
                End Select
            ElseIf (query.Contains(para.Name)) Then
                query = query.Replace("/*" & para.Name & "*/", " " & para.DefaultValue & " ")
            End If
        Next
        If (query.Contains("/*[")) Then query = ChangeSchemaDatabase(query)
        mbosCommand.CommandText = query
        Return mbosCommand
    End Function
    Private Function ChangeSchemaDatabase(ByVal query As String) As String
        Dim schema As String = ".travoxmos."
        Dim arrSchema() As String = {"GLOBAL", "MBOS", "HOTEL", "TRANSFER"}
        For Each name As String In arrSchema
            If (query.Contains("/*[" & name & "]*/")) Then
                Select Case name
                    Case "GLOBAL" : schema = "travox_global" & schema
                    Case "MBOS" : schema = DataCompany("database_name").ToString & schema
                    Case Else : schema = DataCompany("database_" & name.ToLower).ToString & schema
                End Select
                query = query.Replace("/*[" & name & "]*/", " " & schema).Trim()
            End If
        Next
        Return query
    End Function

End Class

Public Class DB
    Public TableName As String
    Public SQL As String
    Public Sub New(ByVal table_name As String)
        TableName = table_name
    End Sub
    Public Sub New(ByVal table_name As String, ByVal sql_query As String)
        If (sql_query.Contains("SQL::")) Then sql_query = H2G.FileRead("!SQLStore\" & sql_query.Replace("SQL::", "") & ".sql")
        TableName = table_name
        SQL = sql_query
    End Sub
End Class