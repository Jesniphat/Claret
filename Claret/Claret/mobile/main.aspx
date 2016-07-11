<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="main.aspx.vb" Inherits="Claret.mobile_main" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            $("#btnTest").button();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-12">
            <span>หน้าหลัก (หน่วยเคลื่อนที่)</span>
        </div>
        <input type="button" id="btnTest" value="Test CSS Button" />
        <input type="button" id="btnTest2" value="Test CSS Button 2" />
        <div class="ui-widget">
            <select id="ddlTest">
                <option>aaaaaaa</option>
                <option>abbbbbb</option>
                <option>abccccc</option>
                <option>abcdddd</option>
                <option>abcdeee</option>
            </select>
        </div>

    </div>  
</asp:Content>
