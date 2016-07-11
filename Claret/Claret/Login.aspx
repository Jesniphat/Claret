<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Login.aspx.vb" Inherits="Claret.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login</title>
    <link href="/resources/css/bootstrap.css?ver=20160107" rel="stylesheet" />
    <link href="/resources/css/bootflat.css?ver=20160107" rel="stylesheet" />
    <link href="/resources/css/jquery.fs.selecter.css?ver=20160107" rel="stylesheet" />
    <link href="/resources/jquery-ui/jquery-ui.css?ver=20160107" rel="stylesheet" />
    <link href="/resources/css/custom.css?ver=20160107" rel="stylesheet" />
    <script src="../resources/jquery/jquery.js" type="text/javascript"></script>
    <script src="../resources/jquery/bootstrap.min.js" type="text/javascript"></script>
    <script src="../resources/jquery/jquery.fs.selecter.js" type="text/javascript"></script>
    <script src="../resources/jquery-ui/jquery-ui.js" type="text/javascript"></script>
    <script src="../resources/javascript/extension.js?ver=20160116" type="text/javascript"></script>

    <style>
        .box-Info {
            webkit-box-shadow: none;
            -moz-box-shadow: none;
            box-shadow: none;
            border-radius: 4px;
            border:solid 1px gray; 
            display:inline-block; 
            background-color:white;
        }
        .box-Info .row {
            padding: 2px 0;
        }
    </style>
    <script>
        $(function () {
            $("#ddlDepartment").setDropdowListValue({ url: 'ajaxAction/masterAction.aspx', data: { action: 'collection' } });
            $("#ddlRegion").setDropdowListValue({ url: 'ajaxAction/masterAction.aspx', data: { action: 'site' } });            
            $("#txtRegion").blur(function () { $("#ddlRegion").val($("#txtRegion").val().toUpperCase()).change(); });
            $("#txtDepartment").blur(function () { $("#ddlDepartment").val($("#txtDepartment").val().toUpperCase()).change(); });
            $("#txtUser").focus();

            $("#btnLogin").click(function () {
                $("#frmLogin").attr("action", "main.aspx").submit();
            });
        });
    </script>
</head>
<body style="background-color:#F2F2F2">
    <form id="frmLogin" runat="server" method="post">
    <div>
        <div class="row" style="background-color:gray; padding:10px 0px; background: url(../../image/bg/bg-header-bar.png) repeat-x;">
            <div class="col-md-36">
                <img src="image/icon/blood-donation-24x24.png" style="margin-top: -10px;" />
                <span>Claret : ระบบบริจาคโลหิต</span>
            </div>
        </div>
    </div>
    <div id="loginBox" style="text-align:center; padding-top:100px;">
        <div id="contentLogin" class="box-Info shadow-box" style="text-align:center;align-content:center;padding:20px 40px; width:500px;">
            <div class="row">
                <div class="col-md-36">
                    <img src="image/logo/NBC-logo.png" style="width:250px;padding-bottom: 25px;" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-9 text-left">
                    <span>ชื่อผู้ใช้งาน</span>
                </div>
                <div class="col-md-24">
                    <input id="txtUser" type="text" class="form-control required" placeholder="ชื่อผู้ใช้งาน" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-9 text-left">
                    <span>รหัสผ่าน</span>
                </div>
                <div class="col-md-24">
                    <input id="txtPassword" type="password" class="form-control required" placeholder="รหัสผ่าน" />
                </div>
            </div>
            <div class="row">
                <div class="col-md-9 text-left">
                    <span>ภาค</span>
                </div>
                <div class="col-md-6" style="text-align:right;padding-right: 0;">
                    <input id="txtRegion" type="text" class="form-control required" placeholder="ภาค" />
                </div>
                <div class="col-md-18" style="padding-left: 5px;">
                    <select id="ddlRegion" class="required text-left" tabindex="-1">
                        <option value="0">Loading...</option>
                    </select>
                </div>
            </div>
            <div class="row">
                <div class="col-md-9 text-left">
                    <span>หน่วยงาน</span>
                </div>
                <div class="col-md-6" style="text-align:right;padding-right: 0;">
                    <input id="txtDepartment" type="text" class="form-control required" placeholder="หน่วยงาน" />
                </div>
                <div class="col-md-18" style="padding-left: 5px;">
                    <select id="ddlDepartment" class="required text-left" tabindex="-1">
                        <option value="0">Loading...</option>
                    </select>
                </div>
            </div>
            <div class="row">
                <div class="col-md-9" style="text-align:right;">
                </div>
                <div class="col-md-18">
                    <input id="btnLogin" type="button" class="btn btn-block" value="เข้าสู่ระบบ" />
                </div>
            </div>
        </div>
    </div>
    </form>
</body>
</html>
