<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="WebForm1.aspx.vb" Inherits="Claret.WebForm1" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title></title>
    <link href="/resources/css/bootstrap.css?ver=20160116" rel="stylesheet" />
    <link href="/resources/css/bootflat.css?ver=20160116" rel="stylesheet" />
    <link href="/resources/css/jquery.fs.selecter.css?ver=20160116" rel="stylesheet" />
    <link href="/resources/jquery-ui/jquery-ui.css?ver=20160116" rel="stylesheet" />
    <link href="/resources/css/custom.css?ver=20160116" rel="stylesheet" />
    <script src="../resources/jquery/jquery.js" type="text/javascript"></script>
    <script src="../resources/jquery-ui/jquery-ui.js" type="text/javascript"></script>
    <script src="../resources/jquery/bootstrap.min.js" type="text/javascript"></script>
    <script src="../resources/jquery/jquery.fs.selecter.js" type="text/javascript"></script>
    <script src="../resources/javascript/extension.js?ver=20160116" type="text/javascript"></script>
    <script>        
        $(function () {
            $("#txtBirthDate").datepicker({
                numberOfMonths: 1,
                dateFormat: 'dd-mm-yy',
                constrainInput: true
            });
        });

    </script>
</head>
<body>
    <form id="form1" runat="server">
    <div>
        <input id="txtBirthDate" type="text" />
    </div>
    </form>
</body>
</html>
