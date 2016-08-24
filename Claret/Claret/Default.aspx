<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Default.aspx.vb" Inherits="Claret._Default" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    
    <%--<link href="/resources/css/bootstrap.css?ver=20160203" rel="stylesheet" />
    <link href="/resources/css/bootflat.css?ver=20160203" rel="stylesheet" />
    <link href="/resources/css/jquery.fs.selecter.css?ver=20160203" rel="stylesheet" />--%>
    <link href="/resources/jquery-ui/jquery-ui.css?ver=20160203" rel="stylesheet" />
    <link href="/resources/css/custom.css?ver=20160203" rel="stylesheet" />
    <script src="../resources/jquery/jquery.js" type="text/javascript"></script>
    <script src="../resources/jquery-ui/jquery-ui.js" type="text/javascript"></script>
    <script src="../resources/javascript/jquery-date.js?ver=20160203" type="text/javascript"></script>
    <%--<script src="../resources/jquery/bootstrap.min.js" type="text/javascript"></script>
    <script src="../resources/jquery/jquery.fs.selecter.js" type="text/javascript"></script>--%>
    <script src="../resources/jquery/combobox.js" type="text/javascript"></script>
    <script src="../resources/javascript/extension.js?ver=20160116" type="text/javascript"></script>
    <script>
        $(function () {
            $("#btnTest").button();
            //$.ajax({
            //    url: '../ajaxAction/donorAction.aspx', data: { action: 'stickerprint', donor_id: 12 }, type: "POST", dataType: "json",
            //    error: function (xhr, s, err) { console.log(s, err); },
            //    success: function (data) {
            //        if (!data.exMessage == "") {
            //            $("#showSet").H2GValue(data.exMessage);
            //        } else { notiError(data.exMessage); }
            //    }
            //});    //End ajax
        });
    </script>
</head>
<body>
    <form id="form1" runat="server">
        <div id="showSet">

        </div>
    </form>
</body>
</html>
