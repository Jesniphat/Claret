Imports H2GEngine

Public Class Login
    Inherits UI.Page 'System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim cookie As New Response(Page, False)
        Dim user As New User
        cookie.Write("ID", "1") ': Session("individual") = dtStaff.Rows(0)("id").ToString
        cookie.Write("N", "Sittichai Habya") ': Session("name") = dtStaff.Rows(0)("name").ToString
        cookie.Write("C", "ST") ': Session("code") = dtStaff.Rows(0)("code").ToString
        cookie.Write("CPID", "1") ': Session("hl") = dtStaff.Rows(0)("hotel_list").ToString
        cookie.Write("SID", "1") ': Session("whi") = dtStaff.Rows(0)("wholesale_id").ToString

        'user.ID = "1" 'dtStaff.Rows(0)("id").ToString
        'user.Code = "ST" 'dtStaff.Rows(0)("code").ToString
        'user.Name = "Sittichai Habya" 'dtStaff.Rows(0)("name").ToString
        'user.CollectionPointID = "1" 'dtStaff.Rows(0)("wholesale_id").ToString
        'user.SiteID = "1" 'strTemp
        'H2G.Login = user
    End Sub


End Class