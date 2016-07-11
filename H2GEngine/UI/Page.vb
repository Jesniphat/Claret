Namespace UI
    Public Class Page
        Inherits System.Web.UI.Page

        Private Const SessionTimeExpire As Integer = 3600 ' Time Second 
        Private RequestValues As New NameValueCollection()

        Public Property _REQUEST() As NameValueCollection
            Get
                Return RequestValues
            End Get
            Set(ByVal value As NameValueCollection)
                RequestValues = value
            End Set
        End Property

        Protected Overrides Sub InitializeCulture()
            If (H2G.DEBUG) Then Response.AddHeader("Access-Control-Allow-Origin", "*")
            'Response.AddHeader("X-UA-Compatible", "IE=8")
            'Response.AddHeader("p3p", "CP=""IDC DSP COR ADM DEVi TAIi PSA PSD IVAi IVDi CONi HIS OUR IND CNT""")
            'Response.AddHeader("Pragma", "NO-CACHE")
            'Response.Buffer = True
            'Response.CacheControl = "NO-CACHE"
            'Response.Expires = -1
            Me.UICulture = "en-US"
            Me.Culture = "en-US"
        End Sub

        Private Sub Load_Initialize(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
            Try
                For Each key As String In Request.Form.Keys
                    RequestValues.Add(key, Request.Form(key))
                Next
                For Each key As String In Request.QueryString.Keys
                    RequestValues.Add(key, Request.QueryString(key))
                Next
            Catch
                Throw New Exception("Page load Initialize", New Exception("Request GET and POST data is key Contains"))
            End Try
            Select Case Request.Form("callback")
                Case "JSON" : Me.Page_JSON(sender, e)
                Case Else : Me.Page_HTML(sender, e)
            End Select

        End Sub

        Protected Sub Page_HTML(ByVal sender As Object, ByVal e As System.EventArgs)

        End Sub

        Protected Sub Page_JSON(ByVal sender As Object, ByVal e As System.EventArgs)

        End Sub

        Protected Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Error
            'Dim err As New ErrorMessage()
            'err.title = JSON.FixString(Server.GetLastError.Message)
            'err.message = JSON.FixString(Server.GetLastError.StackTrace)
            'err.line = JSON.FixString(IO.Path.GetFileName(Request.ServerVariables("SCRIPT_NAME")))
            'Response.Write(JSON.Serialize(Of ErrorMessage)(err))
            'Response.End()
            'Extensions.GlobalTravox.LogErrorMessage("H2GEngine.Extensions.GlobalTravox.LogErrorMessage >>> " & err.message)
        End Sub

    End Class
End Namespace

Public Structure CallbackObject
    Public param As Object
    Public isSuccess As Boolean
    Public exMessage As String
    Public getItem As String
End Structure
