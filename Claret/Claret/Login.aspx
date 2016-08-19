<%@ Page Language="vb" AutoEventWireup="false" CodeBehind="Login.aspx.vb" Inherits="Claret.Login" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Login</title>
    <link href="/resources/css/bootstrap.css?ver=20160129" rel="stylesheet" />
    <link href="/resources/css/bootflat.css?ver=20160129" rel="stylesheet" />
    <link href="/resources/css/claret-font-icon.css?ver=20160129" rel="stylesheet" />
    <link href="/resources/css/jquery.fs.selecter.css?ver=20160129" rel="stylesheet" />
    <link href="/resources/jquery-ui/jquery-ui.css?ver=20160129" rel="stylesheet" />
    <link href="/resources/css/custom.css?ver=20160129" rel="stylesheet" />
    <link href="/resources/css/table-excel.css" rel="stylesheet" />
    <link href="/resources/css/bootstrap-select.css" rel="stylesheet" />
    <script src="../resources/jquery/jquery.js" type="text/javascript"></script>
    <script src="../resources/jquery-ui/jquery-ui.js" type="text/javascript"></script>
    <script src="../resources/javascript/jquery-date.js?ver=20160129" type="text/javascript"></script>
    <script src="../resources/jquery/bootstrap.js?ver=20160129" type="text/javascript"></script>
    <script src="../resources/jquery/jquery.fs.selecter.js" type="text/javascript"></script>
    <script src="../resources/javascript/extension.js?ver=20160129" type="text/javascript"></script>
    <script src="../resources/javascript/bootstrap-select.js" type="text/javascript"></script>
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
                /* Popup css */
        .outerborder {
                    -moz-box-shadow: 0 0 5px 5px #7c7c7c;
                    -webkit-box-shadow: 0 0 5px 5px #7c7c7c;
                    box-shadow: 0 0 5px 5px #7c7c7c;
                    -moz-border-radius: 8px;
                    -webkit-border-radius: 8px;
                    border-radius: 8px;
                    padding: 5px 15px;
                }
                .mpopup_btnclose {
                    cursor: pointer;
                    float: right;
                    display: inline-block;
                }
                    .mpopup_btnclose a {
                        color: #676767;
                        font-weight: 700;
                        text-decoration: none;
                        white-space: nowrap;
                    }
                        .mpopup_btnclose a:hover {
                            color: #676767 !important;
                            text-decoration: underline;
                        }
                        .mpopup_btnclose a span.sprite_sec {
                            background-position: -58px -1330px;
                            width: 21px;
                            height: 21px;
                            margin-left: 5px;
                            vertical-align: middle;
                            display: inline-block;
                            cursor: pointer;
                        }
                        .mpopup_btnclose a:hover span.sprite_sec {
                            background-position: -82px -1330px;
                        }
        .popheader {
            text-align: center;
            font-size: x-large;
            font-weight: bold;
        }
        .popbody {
            -moz-border-radius: 8px;
	        -webkit-border-radius: 8px;
	        border-radius: 8px;
	        border: solid 1px #CECECE;
        }

        /* Popup css */
        .newouterborder {
            padding: 5px 15px;
        }
        .newpopbody {
	        border: solid 1px #CECECE;
        }
    </style>
    <script>
        $(function () {
            $.ajax({
                url: '../ajaxAction/masterAction.aspx', data: { action: 'logincontent' }, type: "POST", dataType: "json",
                error: function (xhr, s, err) { console.log(s, err); },
                success: function (data) {
                    if (!data.onError) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        $("#ddlRegion").on("change", function () {
                            $("#txtRegion").H2GValue($("#ddlRegion").H2GValue());
                        }).setDropdownListValue({ dataObject: data.getItems.SiteList, defaultSelect: "1000" });
                        $("#ddlDepartment").on("change", function () {
                            $("#txtDepartment").H2GValue($("#ddlDepartment").H2GValue());
                        }).setDropdownListValue({ dataObject: data.getItems.CollectionList, defaultSelect: "0A0000" });
                    } else { notiError(data.exMessage); }
                }
            });    //End ajax
            
            $("#txtRegion").blur(function () { $("#ddlRegion").val($("#txtRegion").val().toUpperCase()).change(); });
            $("#txtDepartment").blur(function () { $("#ddlDepartment").val($("#txtDepartment").val().toUpperCase()).change(); });

            $("#btnLogin").click(function () { login(); });

            $("#txtUser").enterKey(function () { login(); }).focus();
            $("#txtPassword").enterKey(function () { login(); });
            $("#txtDate").H2GDatebox().prop('readonly', true).setCalendar({
                maxDate: new Date(),
                minDate: "-30d",
                yearRange: "c-10:c+10",
            }).H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
            
            $(window).resize(function () {
                setWorkDesk();
            });

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
                        , plandate: $("#txtDate").H2GValue()
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
                                
                            $("#data").H2GFill({ staffID: data.getItems.ID, siteID: $("#ddlRegion option:selected").H2GAttr("valueID"), collectionPointID: $("#ddlDepartment option:selected").H2GAttr("valueID"), tmenu: "tmenuDonor", lmenu: "lmenuDonorRegis" });
                            if (data.getItems.PlanID == "0") {
                                openPopup($("#divPlanContainer"));
                            } else {
                                $("#data").H2GFill({ collectionPlanID: data.getItems.PlanID });
                                $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "donor/search.aspx", method: "post" }).submit();
                            }
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
                } else if ($("#txtDate").H2GValue() == "") {
                    $("#txtDate").focus();
                    notiWarning("กรุณากรอกวันที่");
                    return false;
                }
            } else {
                return false;
            }
            return true;           
        }
        function setWorkDesk() {
            var setLeft = (parseInt($(window).width()) - parseInt($("#divDialog").width())) / 2;
            var setTop = (parseInt($(window).height()) - parseInt($("#divDialog").height())) / 2;
            setTop = setTop > 250 ? 250 : setTop;
            $("#divDialog").css({ top: setTop });

            $("#divFrame").css({ width: parseInt($(window).width()), height: parseInt($(window).height()) });
            $("#divBG").css({ width: parseInt($(window).width()), height: parseInt($(window).height()) });

            if (parseInt($("#divContent").height()) - parseInt($(window).height()) < 0) {
                $("#divContent").css({ top: (parseInt($(window).height()) - parseInt($("#divContent").height())) / 2 });
            } else {
                $("#divContent").css({ top: 0 });
            }
        }
        function openPopup(container) {
            setWorkDesk();
            $('html').css("overflow-y", "hidden");
            $("#divFrame").css({ height: $(window).height(), width: $(window).width() }).fadeIn();
            $("#divBG").css({ height: $(document).height(), width: $(document).width() }).fadeIn();
            $("#divContent").append($(container).children()).H2GFill({ containerID: $(container).H2GAttr("id") }).find("input:not(input[type=button],input[type=submit],button):visible:first").focus();
        }
        function closePopup() {
            $("#divFrame").fadeOut();
            $("#divBG").fadeOut();
            //$('html').css("overflow-y", "scroll");
            $("#" + $("#divContent").H2GAttr("containerID")).append($("#divContent").children());
        }
        function autoCreatePlan() {
            $("#divPlanTemplete input[type=button]").prop('disabled', true);
            $.ajax({
                url: '../ajaxAction/userAction.aspx',
                data: {
                    action: 'createplan'
                    , user: $("#txtUser").H2GValue()
                    , password: $("#txtPassword").H2GValue()
                    , sid: $("#ddlRegion option:selected").H2GAttr("valueID")
                    , cpid: $("#ddlDepartment option:selected").H2GAttr("valueID")
                    , plandate: $("#txtDate").H2GValue()
                },
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                    notiError(data.exMessage);
                    $("#divPlanTemplete input[type=button]").prop('disabled', false);
                },
                success: function (data) {
                    if (!data.onError) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        if (data.getItems.PlanID != "") {
                            $("#data").H2GFill({ collectionPlanID: data.getItems.PlanID });
                            $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "donor/search.aspx", method: "post" }).submit();
                        }
                    } else {
                        notiError(data.exMessage);
                    }
                    $("#divPlanTemplete input[type=button]").prop('disabled', false);
                }
            });    //End ajax
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
                        <input id="txtRegion" type="text" class="form-control required" placeholder="ภาค" />
                    </div>
                    <div class="col-md-18" style="padding-left: 5px;">
                        <select id="ddlRegion" class="required text-left" style="width:100%;" tabindex="-1">
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
                        <select id="ddlDepartment" class="required text-left" style="width:100%;" tabindex="-1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-9 text-left">
                        <span>วันที่</span>
                    </div>
                    <div class="col-md-18">
                        <input id="txtDate" type="text" class="form-control required text-center" />
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
        <div id="divBG" style="opacity: 0.2; top: 0px; position: fixed; z-index: 100; overflow-y: auto; height: 402px; width: 1366px; background-color: gray; display:none;">
        </div>
        <div id="divFrame" style="display: none;z-index: 102;position: fixed;overflow-y: scroll;top:0; display: none; text-align:center;">
            <div id="divDialog" style="position: relative; border: #7c7c7c solid 1px; background-color: #F4F4F4;display: inline-block; box-shadow: 1px 3px 3px #ccd1d9;">
                <div id="divContent" style="top: 0px; z-index: 0; border-radius: 4px 4px 4px 4px;">
                </div>
            </div>
        </div>
        <div id="divPlanContainer" style="display:none;">
            <div id="divPlanTemplete" style="display: inline-block;">
                <div class="newouterborder" style="background-color: #F4F4F4;">
                    <div class="popheader row text-left" style="padding: 5px 0px;">
                        <div class="popupheader col-md-33">สร้างแผนงานอัตโนมัติ</div>
                        <div class="col-md-3 text-center" style="float:right;">
                            <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" title="close" onclick="return closePopup();"></span></a>
                        </div>
                    </div>
                    <div class="popupbody text-left" style="width:300px;">
                        <div class="row">
                            <div class="col-md-36"><span>ไม่พบแผนงานในระบบ</span></div>
                            <div class="col-md-36"><span>ต้องการสร้างแผนงานใหม่หรือไม่</span></div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 col-md-offset-24 text-right">
                                <input type="button" value="สร้าง" class="btn btn-block btn-success" onclick="return autoCreatePlan();" />
                            </div>
                            <div class="col-md-6 text-right">
                                <input type="button" value="ยกเลิก" class="btn btn-block" onclick="return closePopup();" />
                            </div>
                        </div>
                    </div>
                    <div class="popfooter" style="text-align: right;">
                    </div>
                </div>
            </div>
        </div>
    </form>
</body>
</html>
