Imports System.IO

Namespace Extensions
    Public Class Logfile
        Dim MessageString As StringBuilder
        Dim LogWrite As String
        Dim LongTime As Long
        Dim LogCurrent As Long
        Dim EnabledWriteLog As Boolean = True
        Dim Stream As Boolean = True

        Public Sub New(ByVal filename As String)
            Me.New(filename, True)
        End Sub
        Public Sub New(ByVal filename As String, ByVal enable As Boolean)
            Dim code As String = "GLOBAL"
            EnabledWriteLog = IIf(Not H2G.DEBUG, enable, False)
            If (EnabledWriteLog) Then
                Try
                    code = H2G.CompanyCode()
                Catch
                End Try
                Dim folder As String = H2G.Path & "Temp\Log\" & code & "\"
                LongTime = 0
                If (Not Directory.Exists(folder)) Then Directory.CreateDirectory(folder)
                Do
                    LogWrite = folder & H2G.Timestamp.ToString() & "#" & filename & ".txt"
                Loop Until (Not File.Exists(LogWrite))
                Dim sf As StreamWriter = File.CreateText(LogWrite)
                sf.Close()
                LogCurrent = CLng(DateTime.UtcNow.TimeOfDay().TotalMilliseconds)
            End If
        End Sub
        Public Sub New()
            LogCurrent = CLng(DateTime.UtcNow.TimeOfDay().TotalMilliseconds)
            MessageString = New StringBuilder()
            Stream = False
        End Sub

        Public Sub Progress(ByVal message As String)
            If (EnabledWriteLog) Then
                Dim msTime As Long = CLng(DateTime.UtcNow.TimeOfDay().TotalMilliseconds)
                LongTime += (msTime - LogCurrent)
                Me.Log(" " & (msTime - LogCurrent) & " ms" & vbTab & "| " & message)
                LogCurrent = msTime
            End If
        End Sub
        Public Sub Message(ByVal message As String)
            If (EnabledWriteLog) Then
                Me.Log(" MSG" & vbTab & "| " & message)
                LogCurrent = CLng(DateTime.UtcNow.TimeOfDay().TotalMilliseconds)
            End If
        End Sub
        Public Sub Text(ByVal message As String)
            If (EnabledWriteLog) Then Me.Log(message)
        End Sub
        Public Sub Write(ByVal filepath As String)
            If String.IsNullOrEmpty(filepath) And EnabledWriteLog Then
                LongTime += (CLng(DateTime.UtcNow.TimeOfDay().TotalMilliseconds) - LogCurrent)
                Me.Log(Math.Round((LongTime / 1000), 1) & " s" & vbTab & "| Total Time in Function")
            Else
                If (Not H2G.DEBUG) Then H2G.FileWrite(filepath, MessageString.ToString())
            End If
        End Sub
        Public Sub Write()
            Me.Write(Nothing)
        End Sub
        Private Sub Log(ByVal message As String)
            Me.Log(message, True)
        End Sub
        Private Sub Log(ByVal message As String, ByVal newline As Boolean)
            If (EnabledWriteLog) Then
                If (Stream) Then
                    File.AppendAllText(LogWrite, "H2G::" & message & IIf(newline, vbCrLf, ""))
                Else
                    If (newline) Then MessageString.AppendLine(message) Else MessageString.Append(message)
                End If
            End If
        End Sub

        Public Overrides Function ToString() As String
            Return MessageString.ToString()
        End Function
        Public Function ToHTML() As String
            LongTime += (CLng(DateTime.UtcNow.TimeOfDay().TotalMilliseconds) - LogCurrent)
            Me.Log(Math.Round((LongTime / 1000), 2).ToString() & " s" & vbTab & "| Finish Function")

            Dim MsgDump As New StringBuilder()
            Dim htmlTag As String = "<span style=\""display:inline-table;width:60px;text-align:right;\"">{0}</span>{1}"
            For Each tag As Match In Regex.Matches(MessageString.ToString(), "((\d+|\d+.\d+).(ms|s))(.+)?")
                MsgDump.AppendFormat(htmlTag, tag.Groups(1).Value, tag.Groups(4).Value)
                MsgDump.AppendLine()
            Next
            Return Regex.Replace(Regex.Replace(MsgDump.ToString(), "(\r|\r\n|\n)+", "<br>"), "\s+", " ")
        End Function
    End Class
End Namespace
