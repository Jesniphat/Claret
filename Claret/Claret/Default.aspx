<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Default.aspx.vb" Inherits="Claret._Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
    <%--<link href="/resources/css/bootstrap.css?ver=20160116" rel="stylesheet" />
    <link href="/resources/css/bootflat.css?ver=20160116" rel="stylesheet" />
    <link href="/resources/css/jquery.fs.selecter.css?ver=20160116" rel="stylesheet" />--%>
    <link href="/resources/jquery-ui/jquery-ui.css?ver=20160116" rel="stylesheet" />
    <link href="/resources/css/custom.css?ver=20160116" rel="stylesheet" />
    <script src="../resources/jquery/jquery.js" type="text/javascript"></script>
    <script src="../resources/jquery-ui/jquery-ui.js" type="text/javascript"></script>
    <script src="../resources/javascript/jquery-date.js?ver=20160116" type="text/javascript"></script>
    <%--<script src="../resources/jquery/bootstrap.min.js" type="text/javascript"></script>
    <script src="../resources/jquery/jquery.fs.selecter.js" type="text/javascript"></script>--%>
    <script src="../resources/jquery/combobox.js" type="text/javascript"></script>
    <script src="../resources/javascript/extension.js?ver=20160116" type="text/javascript"></script>
    <script src="../resources/angular/angular.js" type="text/javascript"></script>
    <script>
        $(function () {
            $("#btnTest").button();
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
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
    </form>
</body>
</html>
