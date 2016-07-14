<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Login.aspx.vb" Inherits="Claret.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login</title>
    <link href="/resources/css/bootstrap.css?ver=20160118" rel="stylesheet" />
    <link href="/resources/css/bootflat.css?ver=20160118" rel="stylesheet" />
    <link href="/resources/css/jquery.fs.selecter.css?ver=20160118" rel="stylesheet" />
    <link href="/resources/jquery-ui/jquery-ui.css?ver=20160118" rel="stylesheet" />
    <link href="/resources/css/custom.css?ver=20160118" rel="stylesheet" />
    <script src="../resources/jquery/jquery.js" type="text/javascript"></script>
    <script src="../resources/jquery/bootstrap.min.js" type="text/javascript"></script>
    <script src="../resources/jquery/jquery.fs.selecter.js" type="text/javascript"></script>
    <script src="../resources/jquery-ui/jquery-ui.js" type="text/javascript"></script>
    <script src="../resources/javascript/extension.js?ver=20160118" type="text/javascript"></script>

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
            $("#ddlRegion").setDropdowListValue({ url: 'ajaxAction/masterAction.aspx', data: { action: 'site' } }, "1000").on("change", function () {
                $("#txtRegion").H2GValue($("#ddlRegion").H2GValue());
            });
            $("#ddlDepartment").setDropdowListValue({ url: 'ajaxAction/masterAction.aspx', data: { action: 'collection' } }, "0A0000").on("change", function () {
                $("#txtDepartment").H2GValue($("#ddlDepartment").H2GValue());
            });
            $("#txtRegion").blur(function () { $("#ddlRegion").val($("#txtRegion").val().toUpperCase()).change(); });
            $("#txtDepartment").blur(function () { $("#ddlDepartment").val($("#txtDepartment").val().toUpperCase()).change(); });

            $("#btnLogin").click(function () { login(); });

            $("#txtUser").enterKey(function () { login(); }).focus();
            $("#txtPassword").enterKey(function () { login(); });
        });
        function login() {
            if (validationLogin()) {
                $("#btnLogin").prop('disabled', true);
                $.ajax({
                    url: '../ajaxAction/userAction.aspx',
                    data: {
                        action: 'selectstaff'
                        , user: $("#txtUser").H2GValue()
                        , password: $("#txtPassword").H2GValue()
                        , sid: $("#ddlRegion option:selected").H2GAttr("valueID")
                        , cpid: $("#ddlDepartment option:selected").H2GAttr("valueID")
                    },
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                        notiError(data.exMessage);
                        $("#btnLogin").prop('disabled', false);
                    },
                    success: function (data) {
                        if (!data.onError) {
                            data.getItems = jQuery.parseJSON(data.getItems);
                                
                            $("#data").H2GFill({ staffID: data.getItems.ID, siteID: $("#ddlRegion option:selected").H2GAttr("valueID"), collectionPointID: $("#ddlDepartment option:selected").H2GAttr("valueID") });
                            $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "main.aspx", method: "post" }).submit();

                        } else {
                            notiError(data.exMessage);
                            $("#txtUser").focus();
                        }
                        $("#btnLogin").prop('disabled', false);
                    }
                });    //End ajax
            }
        }
        function validationLogin() {
            if (!$('#btnLogin').is(':disabled')) {
                if ($("#txtUser").H2GValue() == "") {
                    $("#txtUser").focus();
                    notiWarning("กรุณากรอกชื่อผู้ใช้งาน");
                    return false;
                } else if ($("#txtPassword").H2GValue() == "") {
                    $("#txtPassword").focus();
                    notiWarning("กรุณากรอกรหัสผ่าน");
                    return false;
                } else if ($("#txtRegion").H2GValue() == "") {
                    $("#txtRegion").focus();
                    notiWarning("กรุณากรอกภาค");
                    return false;
                } else if ($("#ddlRegion").H2GValue() == null) {
                    $("#ddlRegion").closest("div").focus();
                    notiWarning("ภาคไม่ถูกต้อง กรุณาเลือกใหม่");
                    return false;
                } else if ($("#txtDepartment").H2GValue() == "") {
                    $("#txtDepartment").focus();
                    notiWarning("กรุณากรอกหน่วยงาน");
                    return false;
                } else if ($("#ddlDepartment").H2GValue() == null) {
                    $("#ddlDepartment").closest("div").focus();
                    notiWarning("หน่วยงานไม่ถูกต้อง กรุณาเลือกใหม่");
                    return false;
                }
            } else {
                return false;
            }

            return true;           
        }
        
    </script>
</head>
<body style="background-color:#F2F2F2">
    <form id="frmLogin" runat="server" method="post">
    <input id="data" runat="server" style="display: none;" />
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
                    <input id="txtRegion" type="text" class="form-control required" placeholder="ภาค" /><%-- value="1000"--%>
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
                    <input id="txtDepartment" type="text" class="form-control required" placeholder="หน่วยงาน" /><%-- value="0A0000"--%>
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
    <div id="divNoti" class="noti" style="display:none;">
        <span class="sign glyphicon"></span><span class="noti-message">กรุณากรอกชื่อผู้บริจาก</span>
    </div>
    </form>
</body>
</html>
