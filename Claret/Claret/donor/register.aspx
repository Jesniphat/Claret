<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="register.aspx.vb" Inherits="Claret.donor_register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table-deferal > tbody > tr > td {
            border-bottom: 0;
        }
    </style>
    <script src="../resources/javascript/page/registerScript.js?var=20160101" type="text/javascript"></script>
    <script>
        $(function () {
            lookupControl();
            $("#txtCardNumber").enterKey(function () { $(this).addExtCard(); }).focus();
            $("#ddlDefferal").setDropdownList().on('change', function () {
                if ($(this).H2GValue() == 'ACTIVE') { $("#tbDefferal > thead > tr[status=INACTIVE]").hide(); }
                else { $("#tbDefferal > thead > tr[status=INACTIVE]").show(); }
            });
            $("#infoTab").tabs({
                active: 1,
                activate: function (event, ui) {
                    if ($(ui.newPanel).find("textarea:visible:first").length > 0) {
                        $(ui.newPanel).find("textarea:visible:first").focus();
                    } else {
                        $(ui.newPanel).find("input:not(input[type=button],input[type=submit],button):visible:first").focus();
                    }
                },
            });
            $("#infoTabToday").tabs({
                activate: function (event, ui) {
                    $(ui.newPanel).find("input:not(input[type=button],input[type=submit],button):visible:first").focus();
                },
            });
            $("#labTab").tabs({
                activate: function (event, ui) {
                    $(ui.newPanel).find("input:not(input[type=button],input[type=submit],button):visible:first").focus();
                },
            });
            $("#txtBirthDay").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    if (selectedDate != '') { $("#txtAge").H2GValue(H2G.calAge(selectedDate) + ' ปี'); } else { $("#txtAge").H2GValue(''); }
                    $("#ddlOccupation").closest("div").focus();
                },
                onClose: function () {
                    var pattern = 'dd/MM/yyyy';
                    if ($(this).H2GValue() != '') {
                        $(this).H2GValue($(this).H2GValue().replace(/\W+/g, ''));
                        $(this).next().remove();
                        if (isDate($(this).H2GValue(), pattern.replace(/\W+/g, ''))) {
                            var isValue = new Date(getDateFromFormat($(this).H2GValue(), pattern.replace(/\W+/g, '')));
                            $(this).H2GValue(formatDate(isValue, pattern));
                        }
                        $("#txtAge").H2GValue(H2G.calAge($(this).H2GValue()) + ' ปี');
                    } else {
                        $("#txtAge").H2GValue('');
                    }
                },
            });
            $("#txtLastDonateDate").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    if (selectedDate != '') { $(this).H2GAttr('donatedatetext', formatDate($(this).datepicker("getDate"),"dd MMM yyyy")); } else { $(this).H2GAttr('donatedatetext', ''); }
                    $("#spAddDonateRecord").focus();
                },
                onClose: function () {
                    enterDatePickerDonateRecord($("#txtLastDonateDate"), "close");
                },
                onEnterKey: function () {
                    enterDatePickerDonateRecord($("#txtLastDonateDate"), "enter");
                },
            });
            $("#txtCommentDateForm").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
            $("#txtCommentDateTo").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                maxDate: "+10y",
                minDate: new Date(),
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) { $("#txtDonorComment").focus(); },
            });
            $("#txtDonorComment").enterKey(function () { $(this).addComment(); }).focus();
            $("#togCardNumber").click(function () {
                if (parseInt($("#divCardNumber").H2GAttr("min-height")) < parseInt($("#divCardNumber").height())) {
                    $("#divCardNumber").css({ height: 30 });
                    $(this).removeClass("glyphicon-menu-up").addClass("glyphicon-menu-down");
                } else {
                    $("#divCardNumber").css({ height: "" });
                    $(this).removeClass("glyphicon-menu-down").addClass("glyphicon-menu-up");
                }
            });
            $("#ddlExtCard").setAutoListValue({
                url: '../../ajaxAction/masterAction.aspx',
                data: { action: 'externalcard' },
                selectItem: function () {
                    var cardNumber = $('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]').H2GAttr('cardNumber');
                    $("#txtCardNumber").H2GValue(cardNumber || '');
                },
            }, "3");
            $("#ddlExtCard").on('autocompleteselect', function () {
                var cardNumber = $('#divCardNumber div[extID="' + $(this).H2GValue() + '"]').H2GAttr('cardNumber');
                $("#txtCardNumber").H2GValue(cardNumber || '').focus();
            });
            $("input:radio[name=gender]").change(function (e) {
                $("#ddlTitleName").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'titlename', gender: $("#rbtM").is(':checked') == true ? "M" : "F" } });
            });
            $("#btnSave").click(function () {
                saveDonorInfo();
            });
            $("#btnCancel").click(function () {
                cancelRegis(this);
            });
            $("#spInsertExtCard").click(function () {
                $("#txtCardNumber").addExtCard();
            })
            $("#spAddComment").click(function () {
                $("#txtDonorComment").addComment();
            })
            $("#spAddDonateRecord").click(function () {
                $("#txtOuterDonate").addDonateRecord();
            })

            //#### Default donor info from id
            if ($("#data").H2GAttr("receiptHospitalID")) {
                $.ajax({
                    url: '../../ajaxAction/qualityAction.aspx',
                    data: {
                        action: 'getreceipthospital',
                        receipthospitalid: $("#data").H2GAttr("receiptHospitalID"),
                    },
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                    },
                    success: function (data) {
                        if (!data.onError) {
                            data.getItems = jQuery.parseJSON(data.getItems);
                            console.log(data.getItems);
                            $("#divReceiptHospital").show();
                            $("#spReceiptHospital").H2GValue(data.getItems.HospitalName + " รายการที่ " + data.getItems.QueueCount + "/" + data.getItems.QueueCount);
                        }
                    }
                });    //End ajax
            }
            if ($("#data").H2GAttr("donorID") != undefined) {
                if ($("#data").H2GAttr("visitID") != undefined) { $("#spRegisNumber").H2GAttr("visitID", $("#data").H2GAttr("visitID")); }
                showDonorData();
            } else {
                $("#txtDonorName").H2GValue($("#data").H2GAttr("donorName") || "");
                $("#txtDonorSurName").H2GValue($("#data").H2GAttr("donorSurname") || "");
                $("#txtBirthDay").H2GValue($("#data").H2GAttr("birthday") || "");
                $("#txtAge").H2GValue(H2G.calAge($("#data").H2GAttr("birthday") || "") + ' ปี');
                $("#spVisitInfo").H2GValue("วันที่ลงทะเบียน " + formatDate(H2G.today(), "dd NNN yyyy HH:mm") + " เข้าพบครั้งแรก กำลังดำเนินการบริจาคครั้งที่ 1").H2GFill({
                    visitDateText: formatDate(H2G.today(), "dd NNN yyyy HH:mm"),
                    lastVisitDateText: "",
                    currentDonateNumber: "1",
                    visitDate: formatDate(H2G.today(), "dd-MM-yyyy HH:mm")
                });
                $("#infoTab > ul > li > a[href='#todayPane']").H2GValue(formatDate(H2G.today(), "dd NNN yyyy"))
                $("#spVisitCount").H2GValue("รวมจำนวนการเข้าพบ 0 ครั้ง / บริจาค 0 ครั้ง");
                donorSelectDDL();
            }

            $.extend($.fn, {
                addExtCard: function (args) {
                    if ($(this).H2GValue() != "") {
                        var extCard = $('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]');
                        if (extCard.length>0) {
                            $(extCard).find(".ext-number").H2GValue($("#ddlExtCard :selected").text() + " : " + $(this).H2GValue()).H2GAttr("cardNumber", $(this).H2GValue());
                        } else {
                            var spExtCard = $("#divCardNumberTemp").children().clone();
                            $(spExtCard).H2GFill({ extID: $("#ddlExtCard").H2GValue(), cardNumber: $(this).H2GValue() }).find(".ext-number").H2GValue($("#ddlExtCard :selected").text() + " : " + $(this).H2GValue());
                            $('#divCardNumber').append(spExtCard);
                        }
                        $(this).H2GValue('');
                    } else {
                        notiWarning("กรุณากรอกเลขบัตร");
                        $(this).focus();
                    }
                },
                deleteExtCard: function (args) {
                    if (confirm("ต้องการจะลบ " + $(this).closest("div.row").find(".ext-number").H2GValue() + " ใช่หรือไม่?")) {
                        if ($(this).closest("div.row").H2GAttr("refID") == "NEW") {
                            $(this).closest("div.row").remove();
                        } else {
                            $(this).closest("div.row").hide().H2GAttr("refID", "D#" + $(this).closest("div.row").H2GAttr("refID"));
                        }
                    }
                },
                addComment: function (args) {
                    if ($("#txtCommentDateTo").H2GValue() != "" && $(this).H2GValue() != "") {
                        var spComment = $("#divCommentTemp").children().clone();
                        $(spComment).H2GAttr({ startDate: $("#txtCommentDateForm").H2GValue(), endDate: $("#txtCommentDateTo").H2GValue() });
                        $(spComment).find(".dc-datecomment").H2GValue(H2G.dateText($("#txtCommentDateForm").H2GValue()) + " - " + H2G.dateText($("#txtCommentDateTo").H2GValue()));
                        $(spComment).find(".dc-comment").H2GValue($(this).H2GValue());
                        $('#divComment').prepend(spComment);
                        $(this).H2GValue('');
                    } else {
                        var warning = "";
                        if ($("#txtCommentDateTo").H2GValue() == "") { warning = "กรุณากรอกวันที่สิ้นสุด"; $("#txtCommentDateTo").focus(); }
                        else { warning = "กรุณากรอกความเห็น"; $(this).focus(); };
                        notiWarning(warning);
                    }
                },
                deleteComment: function (args) {
                    if (confirm("ต้องการจะลบความเห็น" + $(this).closest("div.row").find(".dc-datecomment").H2GValue() + "ใช่หรือไม่?")) {
                        if ($(this).closest("div.row").H2GAttr("refID") == "NEW") {
                            $(this).closest("div.row").remove();
                        } else {
                            $(this).closest("div.row").hide().H2GAttr("refID", "D#" + $(this).closest("div.row").H2GAttr("refID"));
                        }
                    }
                },
                addDonateRecord: function (args) {
                    if ($("#txtOuterDonate").H2GValue() != "" && $("#txtLastDonateDate").H2GValue() != "") {
                        $.ajax({
                            url: "../../ajaxAction/donorAction.aspx",
                            data: H2G.ajaxData({ 
                                action: 'getdonatereward',
                                id: $("#data").H2GAttr("donorID"),
                                donatedate: $("#txtLastDonateDate").H2GValue(),
                                donatenumber: $("#txtOuterDonate").H2GValue(),
                                lastrecord: $("#divDonateRecord").H2GAttr("lastrecord") ? $("#divDonateRecord").H2GAttr("lastrecord") : 0
                            }).config,
                            type: "POST",
                            dataType: "json",
                            error: function (xhr, s, err) {
                                console.log(s, err);
                            },
                            success: function (data) {
                                if (!data.onError) {
                                    data.getItems = jQuery.parseJSON(data.getItems);                                    
                                    $.each((data.getItems), function (index, e) {
                                        var rowRecord = $("#divDonateRecordTemp").children().clone();
                                        $(rowRecord).H2GAttr({ donatedate: $("#txtLastDonateDate").H2GValue(), donatenumber: e.DonationNumber, donatefrom: e.DonationFrom });
                                        $(rowRecord).find("span.rec-text").H2GValue("ครั้งที่ " + e.DonationNumber + " บริจาควันที่ " + $("#txtLastDonateDate").H2GAttr("donatedatetext") + " ณ โรงพยาบาลนอกเครือข่าย");
                                        
                                        // for each reward 
                                        $.each((e.DonationRewardList), function (indexr, er) {
                                            var rowReward = $("#donateRewardTemp").clone();
                                            $(rowReward).find(".lbl-check-reward").append(er.Description).H2GAttr('rewardID', er.ID);
                                            $(rowReward).find(".lbl-check-reward input").on("change", function () { $(this).checkedReward() });
                                            $(rowReward).find(".txt-reward-date").H2GFill({ rewardID: er.ID }).setCalendar({
                                                maxDate: new Date(),
                                                minDate: "-20y",
                                                yearRange: "c-20:c+0",
                                                onSelect: function (selectedDate, objDate) {
                                                    if (selectedDate != '') {
                                                        $(this).closest("div.row").find(".lbl-check-reward[rewardID='" + $(this).H2GAttr("rewardID") + "'] input").prop("checked", true);
                                                    }
                                                },
                                                onClose: function () {
                                                    if ($(this).H2GValue() == '') {
                                                        $(this).closest("div.row").find(".lbl-check-reward[rewardID='" + $(this).H2GAttr("rewardID") + "'] input").prop("checked", false);
                                                    } else {
                                                        $(this).closest("div.row").find(".lbl-check-reward[rewardID='" + $(this).H2GAttr("rewardID") + "'] input").prop("checked", true);
                                                    }
                                                },
                                            }).H2GDatebox();
                                            $(rowRecord).append($(rowReward).children());
                                        });

                                        $('#divDonateRecord').prepend(rowRecord).H2GAttr("lastrecord", e.DonationNumber);
                                    });
                                    $("#spRegisNumber").H2GAttr({ donateNumberExt: $("#txtOuterDonate").H2GValue().toNumber() + $("#spRegisNumber").H2GAttr("donateNumberExt").toNumber() });

                                    $("#spVisitCount").H2GValue("รวมจำนวนการเข้าพบ " + $("#spRegisNumber").H2GAttr("visitNumber") + " ครั้ง / บริจาค " + ($("#spRegisNumber").H2GAttr("donateNumber").toNumber() + $("#spRegisNumber").H2GAttr("donateNumberExt").toNumber()) + " ครั้ง");

                                    $("#spVisitInfo").H2GValue("");
                                    $("#spVisitInfo").append("วันที่ลงทะเบียน " + $("#spVisitInfo").H2GAttr("visitDateText"));
                                    if ($("#spVisitInfo").H2GAttr("lastVisitDateText") != "") {
                                        $("#spVisitInfo").append(" เข้าพบครั้งสุดท้ายเมื่อ " + $("#spVisitInfo").H2GAttr("lastVisitDateText") + " ( " + $("#spVisitInfo").H2GAttr("diffDate") + " วัน )");
                                    } else {
                                        $("#spVisitInfo").append(" เข้าพบครั้งแรก");
                                    }

                                    $("#spVisitInfo").append(" กำลังดำเนินการบริจาคครั้งที่ " + ($("#spVisitInfo").H2GAttr("currentDonateNumber").toNumber() + $("#txtOuterDonate").H2GValue().toNumber()));

                                    $("#txtOuterDonate").H2GValue(""); $("#txtLastDonateDate").H2GValue("");
                                } 
                            }
                        });    //End ajax
                    } else {
                        var warning = "";
                        if ($("#txtOuterDonate").H2GValue() == "") { warning = "กรุณากรอกจำนวนครั้งที่บริจาค"; $("#txtOuterDonate").focus(); }
                        else if ($("#txtLastDonateDate").H2GValue() == "") { warning = "กรุณากรอกวันที่บริจาค"; $("#txtLastDonateDate").focus(); }
                        notiWarning(warning);
                    }
                },
                deleteDonateRecord: function (args) {
                    if ($(this).closest("div.row").H2GAttr("refID") == "NEW") {
                        $(this).closest("div.row").remove();
                    } else {
                        $(this).closest("div.row").hide().H2GAttr("refID", "D#" + $(this).closest("div.row").H2GAttr("refID"));
                    }
                },
                checkedReward: function (args) {
                    if ($(this).is(":checked")) {
                        if ($(this).closest("div.row").find("input.txt-reward-date[rewardID='" + $(this).closest("label").H2GAttr("rewardID") + "']").H2GValue() == "") {
                            $(this).closest("div.row").find("input.txt-reward-date[rewardID='" + $(this).closest("label").H2GAttr("rewardID") + "']").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
                        }
                    } else {
                        $(this).closest("div.row").find("input.txt-reward-date[rewardID='" + $(this).closest("label").H2GAttr("rewardID") + "']").H2GValue("");
                    }
                },
            });

            showVisitHistory();
            //### extend

            $("#chackType").change(function () {
                selecterTable(this);
            });
        });

    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div id="divReceiptHospital" class="row" style="display:none; margin-top: 5px;">
        <div class="col-md-36">
            <div class=" text-center border-box" style="background-color:#E5E0EC;">
                <span id="spReceiptHospital" style="font-weight: bold;">โรงพยาบาลเชียงรายประชานุเคราะห์ รายการที่ 0/0</span>
            </div>
        </div>
    </div>
    <div class="claret-page-header row">
        <div>
            <span>ค้นหารายชื่อผู้บริจาค > ลงทะเบียนผู้บริจาค</span>
        </div>
    </div>
    <div class="row">
        <div class="border-box blue" style="border-radius: 4px 4px 0px 0px; font-weight: bold;">
            <div class="col-md-27">
                <span id="spQueue">-</span>/ เลขประจำตัวผู้บริจาค :
                <span id="spRegisNumber" visitID dPlanID dPointID siteID="1" visitFrom="HOSPITAL" queueNum dTypeID bagID dToID donateNumberExt="0" donateNumber="0" visitNumber="0"></span>
            </div>
            <div class="col-md-9 text-right">
                <span>สถานะ</span>
                <span id="spStatus">REGISTER</span>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="border-box">
            <div class="col-md-7">
                <select id="ddlExtCard" style="width: 100%;" placeholder="กรุณาเลือก" tabindex="1">
                    <option value="0">Loading...</option>
                </select>
            </div>
            <div class="col-md-7">
                <input id="txtCardNumber" type="text" class="form-control" tabindex="1" />
            </div>
            <div class="col-md-2">
                <button id="spInsertExtCard" class="btn btn-icon" onclick="return false;" tabindex="1">
                    <i class="glyphicon glyphicon-circle-arrow-right"></i>
                </button>
            </div>
            <div class="col-md-19">
                <div id="divCardNumber" min-height="30" style="overflow: hidden;">
                </div>
                <div id="divCardNumberTemp" style="display: none;">
                    <div class="row" extid="" donorid refid="NEW" cardnumber="">
                        <div class="col-md-34 ext-number"></div>
                        <div class="col-md-2">
                            <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="$(this).deleteExtCard();"></span></a>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-1 text-right">
                <a class="icon"><span id="togCardNumber" class="glyphicon glyphicon-menu-up" aria-hidden="true"></span></a>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-3 col-shift-left">
            <div id="divBloodType" class="border-box text-center blue" style="font-size: 66px; font-weight: bold; height: 108px;">
            </div>
        </div>
        <div class="col-md-33">
            <div class="border-box">
                <div class="row">
                    <div class="col-md-4">
                        <span>เพศ</span>
                        <label style="cursor: pointer; font-weight: normal; margin-bottom: 0px;">
                            <input id="rbtM" name="gender" type="radio" checked="checked" tabindex="1" />ชาย</label>
                        <label style="cursor: pointer; font-weight: normal; margin-bottom: 0px;">
                            <input id="rbtF" name="gender" type="radio" tabindex="1" />หญิง</label>
                    </div>
                    <div class="col-md-3 text-right">
                        <span>คำนำหน้า</span>
                    </div>
                    <div class="col-md-5">
                        <select id="ddlTitleName" class="required" style="width: 100%;" placeholder="กรุณาเลือก" tabindex="1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>ชื่อ</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorName" type="text" class="form-control required" tabindex="1" />
                    </div>
                    <div class="col-md-2 text-right">
                        <span>นามสกุล</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorSurName" type="text" class="form-control required" tabindex="1" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                    </div>
                    <div class="col-md-2 text-right">
                        <span>Name</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorNameEng" type="text" class="form-control required" tabindex="1" />
                    </div>
                    <div class="col-md-2 text-center">
                        <span>Surname</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorSurNameEng" type="text" class="form-control required" tabindex="1" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-5">
                    </div>
                    <div class="col-md-2 text-right">
                        <span>วันเกิด</span>
                    </div>
                    <div class="col-md-3">
                        <input id="txtBirthDay" type="text" class="form-control required text-center" tabindex="1" />
                    </div>
                    <div class="col-md-2">
                        <input id="txtAge" type="text" class="form-control text-center" disabled />
                    </div>
                    <div class="col-md-2 text-right">
                        <span>อาชีพ</span>
                    </div>
                    <div class="col-md-7">
                        <select id="ddlOccupation" class="required" style="width: 100%;" placeholder="กรุณาเลือก" tabindex="1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>สัญชาติ</span>
                    </div>
                    <div class="col-md-6">
                        <select id="ddlNationality" class="required" style="width: 100%;" placeholder="กรุณาเลือก" tabindex="1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>เชื้อชาติ</span>
                    </div>
                    <div class="col-md-5">
                        <select id="ddlRace" style="width: 100%;" placeholder="กรุณาเลือก" tabindex="1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="border-box">
            <div class="row">
                <div class="col-md-5">
                    <span>Defferal/Permanence</span>
                </div>
                <div class="col-md-3">
                    <select id="ddlDefferal">
                        <option value="ACTIVE">ACTIVE</option>
                        <option value="ALL">ALL</option>
                    </select>
                </div>
                <div class="col-md-25">
                </div>
                <div class="col-md-3 text-right" style="padding-left: 2px;">
                    <a class="icon"><span id="togDeferal" targettoggle="divDeferal" class="glyphicon glyphicon-menu-down" aria-hidden="true"></span></a>
                </div>
                <div id="divDeferal" class="col-md-36" style="padding-top: 10px; display: none;">
                    <table id="tbDefferal" class="table table-hover table-striped table-deferal">
                        <thead>
                            <tr>
                                <th style="width: 10%;">รหัสอ้างอิง
                                </th>
                                <th style="width: 10%;">วันที่สิ้นสุด
                                </th>
                                <th style="width: 65%;">เหตุผลการงดบริจาค
                                </th>
                                <th style="width: 15%;">ระยะเวลา
                                </th>
                            </tr>
                            <tr class="no-transaction" style="display: none;">
                                <td align="center" colspan="4">ไม่พบข้อมูล</td>
                            </tr>
                            <tr class="more-loading" style="display: none;">
                                <td align="center" colspan="4">Loading detail...</td>
                            </tr>
                            <tr class="template-data" style="display: none;">
                                <td class="td-def-code"></td>
                                <td class="td-def-date"></td>
                                <td class="td-def-description"></td>
                                <td class="td-def-status"></td>
                            </tr>
                        </thead>
                        <tbody>
                            <tr class="no-transaction">
                                <td align="center" colspan="4">ไม่พบข้อมูล</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="border-box" style="background-color: #F2F2F2;">
            <div class="col-md-36 text-center">
                <span id="spVisitInfo">วันที่ลงทะเบียน เข้าพบครั้งแรก กำลังดำเนินการบริจาคครั้งที่ 1</span>
                <div class="text-right" style="padding-left: 2px; display: inline-table; float: right;">
                    <a class="icon"><span id="togVisitInfo" targettoggle="divVisitInfo" class="glyphicon glyphicon-menu-down" aria-hidden="true"></span></a>
                </div>
            </div>
        </div>
    </div>
    <div class="row" style="margin-bottom: 15px;">
        <div id="divVisitInfo" style="display: none;">
            <div class="col-md-12 col-shift-left">
                <div class="border-box" style="background-color: #F2F2F2;">
                    <div class="col-md-18">
                        <span>Whole blood</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spWholeblood" donationCode="WB">-</span>
                    </div>
                    <div class="col-md-18">
                        <span>STM Registration</span>
                    </div>
                    <div class="col-md-18 text-right">
                        <input id="txtStmRegisDate" type="text" class="form-control" tabindex="-1" />
                        <span id="spStmRegisDate" style="display:none;" donationCode="SC">-</span>
                    </div>
                    <div class="col-md-18">
                        <span>STM Donation</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spStmDonation" donationCode="">-</span>
                    </div>
                </div>
            </div>
            <div class="col-md-12">
                <div class="border-box" style="background-color: #F2F2F2;">
                    <div class="col-md-18">
                        <span>Red Cell aph</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spRedCell" donationCode="RA">-</span>
                    </div>
                    <div class="col-md-18">
                        <span>Plasma aph</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spPlasma" donationCode="PR">-</span>
                    </div>
                    <div class="col-md-18">
                        <span>Platelets aph</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spPlatelets" donationCode="PL">-</span>
                    </div>
                </div>
            </div>
            <div class="col-md-12 col-shift-right">
                <div class="border-box" style="background-color: #F2F2F2;">
                    <div class="col-md-18">
                        <span>Granulocyte aph</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spGranulocyte" donationCode="GR">-</span>
                    </div>
                    <div class="col-md-18">
                        <span>Cord blood</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spCordBlood" donationCode="">-</span>
                    </div>
                    <div class="col-md-18">
                        <span>Rare blood</span>
                    </div>
                    <div class="col-md-18 text-center">
                        <span id="spRareBlood" donationCode="">-</span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="regisTabBox" class="row">
        <div id="infoTab">
            <ul>
                <li><a href="#historyPane" style="">แฟ้มประวัติ</a></li>
                <li><a href="#todayPane" style="">12 ก.ย. 2559</a></li>
                <li id="labPaneTab"><a href="#labPane" style="">ข้อมูล LAB</a></li>
                <li><a href="#ProductionPane" style="">ข้อมูล PRODUCTION</a></li>
            </ul>
            <div id="historyPane">
                <div class="border-box">
                        <div class="col-md-36">
                            <table id="tbVisitHistory" class="table table-bordered-excel" style="font-size:18px;">
                                <thead>
                                    <tr>
                                        <th class="col-md-2 text-center"><button sortOrder="donation_number">ครั้งที่</button>
                                        </th>
                                        <th class="col-md-3 text-center"><button sortOrder="visit_date">วันลงทะเบียน<i class="glyphicon glyphicon-triangle-bottom"></i></button>
                                        </th>
                                        <th class="col-md-4"><button sortOrder="donation_type">ประเภทการบริจาค</button>
                                        </th>
                                        <th class="col-md-3"><button sortOrder="bag">ประเภทถุง</button>
                                        </th>
                                        <th class="col-md-2 text-center"><button sortOrder="site">ภาค</button>
                                        </th>
                                        <th class="col-md-2 text-center"><button sortOrder="collection_point">หน่วย</button>
                                        </th>
                                        <th class="col-md-4"><button sortOrder="create_staff">ลงทะเบียนโดย</button>
                                        </th>
                                        <th class="col-md-4"><button sortOrder="interview_staff">คัดกรองโดย</button>
                                        </th>
                                        <th class="col-md-4"><button sortOrder="interview_status">ผลการคัดกรอง</button>
                                        </th>
                                        <th class="col-md-4 text-center"><button sortOrder="lab_date">Date of lab</button>
                                        </th>
                                        <th class="col-md-3 text-center"><button sortOrder="sample_number">Sample No</button>
                                        </th>
                                        <th class="col-md-1"></th>
                                    </tr>
                                    <tr class="no-transaction" style="display:none;"><td align="center" colspan="12">ไม่พบข้อมูล</td></tr>
                                    <tr class="more-loading" style="display:none;"><td align="center" colspan="12">Loading detail...</td></tr>
                                    <tr class="template-data" style="display:none;" refID="NEW">
                                        <td><input type="text" class="txt-donate-number text-center" readonly value="" /></td>
                                        <td><input type="text" class="txt-visit-date text-center" readonly value="" /></td>
                                        <td><input type="text" class="txt-donate-type text-left" readonly value="" /></td>
                                        <td><input type="text" class="txt-bag-type text-left" readonly value="" /></td>
                                        <td><input type="text" class="txt-site text-center" readonly value="" /></td>
                                        <td><input type="text" class="txt-collection-point text-center" readonly value="" /></td>
                                        <td><input type="text" class="txt-regis-by text-left" readonly value="" /></td>
                                        <td><input type="text" class="txt-collection-by text-left" readonly value="" /></td>
                                        <td><input type="text" class="txt-collection-result text-left" readonly value="" /></td>
                                        <td><input type="text" class="txt-lab-date text-center" readonly value="" /></td>
                                        <td><input type="text" class="txt-sample-number text-center" readonly value="" /></td>
                                        <td class="text-center">
                                            <div>
                                                <a class="icon">
                                                    <span class="glyphicon glyphicon-arrow-right" aria-hidden="true" onclick="return false;"></span>
                                                </a>
                                            </div>
                                        </td>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="no-transaction"><td align="center" colspan="12">ไม่พบข้อมูล</td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
            </div>
            <div id="todayPane">
                <div class="border-box">
                    <div class="col-md-36">
                        <div id="infoTabToday">
                            <ul>
                                <li><a href="#subHistoryPane" style="">ข้อมูลทั่วไป</a></li>
                                <li><a href="#synthesis" style="">Synthesis</a></li>
                            </ul>
                            <div id="subHistoryPane">
                                <div class="border-box">
                                    <div class="col-md-18">
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="col-md-36">
                                                        <span>ที่อยู่ปัจจุบัน</span>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">ที่อยู่</div>
                                                        <div class="col-md-28">
                                                            <textarea id="txtAddress" class="form-control required" style="height:58px;" tabindex="1"></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">แขวง/ตำบล</div>
                                                        <div class="col-md-12">
                                                            <input id="txtSubDistrict" type="text" class="form-control required" tabindex="1" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">เขต/อำเภอ</div>
                                                        <div class="col-md-11">
                                                            <input id="txtDistrict" type="text" class="form-control required" tabindex="1" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">จังหวัด</div>
                                                        <div class="col-md-12">
                                                            <input id="txtProvince" type="text" class="form-control required" tabindex="1" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">รหัสไปรษณีย์</div>
                                                        <div class="col-md-11">
                                                            <input id="txtZipcode" type="text" class="form-control required" tabindex="1" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5"><span>ประเทศ</span></div>
                                                        <div class="col-md-12">
                                                            <select id="ddlCountry" class="required" style="width: 100%;" placeholder="กรุณาเลือก" tabindex="1">
                                                                <option value="0">Loading...</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="col-md-36">
                                                        <span>ช่องทางการติดต่อสื่อสาร</span>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์มือถือ 1</div>
                                                        <div class="col-md-12">
                                                            <input id="txtMobile1" type="text" class="form-control required" tabindex="1" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">Email</div>
                                                        <div class="col-md-11">
                                                            <input id="txtEmail" type="text" class="form-control" tabindex="2" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์มือถือ 2</div>
                                                        <div class="col-md-12">
                                                            <input id="txtMobile2" type="text" class="form-control" tabindex="2" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์บ้าน</div>
                                                        <div class="col-md-12">
                                                            <input id="txtHomeTel" type="text" class="form-control" tabindex="2" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์ที่ทำงาน</div>
                                                        <div class="col-md-12">
                                                            <input id="txtTel" type="text" class="form-control" tabindex="2" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">เบอร์ต่อ</div>
                                                        <div class="col-md-11">
                                                            <input id="txtTelExt" type="text" class="form-control" tabindex="2" />
                                                        </div>
                                                    </div>

                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-18">
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="col-md-12">
                                                        รหัสเชื่อมโยงโรงพยาบาลในเครือ
                                                    </div>
                                                    <div class="col-md-24">
                                                        <select id="ddlAssociation" style="width: 100%;" placeholder="กรุณาเลือก" tabindex="3">
                                                            <option value="0">Loading...</option>
                                                        </select>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="col-md-36">
                                                        เพิ่มจำนวนการบริจาคจาคภายนอก
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-7">
                                                            จำนวนครั้งที่บริจาค
                                                        </div>
                                                        <div class="col-md-9">
                                                            <input id="txtOuterDonate" type="text" class="form-control text-center" tabindex="3" />
                                                        </div>
                                                        <div class="col-md-8 text-center">
                                                            วันที่บริจาคครั้งล่าสุด
                                                        </div>
                                                        <div class="col-md-10">
                                                            <input id="txtLastDonateDate" type="text" class="form-control text-center" tabindex="3" />
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <button id="spAddDonateRecord" class="btn btn-icon" onclick="return false;" tabindex="3">
                                                                <i class="glyphicon glyphicon-circle-arrow-down" style="vertical-align: text-top;"></i>
                                                            </button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="row">
                                                        <div class="col-md-24">
                                                            <span id="spVisitCount">รวมจำนวนการเข้าพบ 0 ครั้ง / บริจาค 0 ครั้ง</span>
                                                        </div>
                                                        <div class="col-md-10">
                                                            <select id="ddlVisit">
                                                                <option value="แสดงทั้งหมด">แสดงทั้งหมด</option>
                                                                <option value="แสดงค้างรับ">แสดงค้างรับ</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row" style="margin-left: 15px;">
                                                        <div class="col-md-36">
                                                            <div id="divDonateRecord" style="overflow-x: hidden; overflow-y: scroll; height: 205px;" donateNumberExt="0" donateNumber="0">
                                                            </div>
                                                            <div id="divDonateRecordTemp" style="display:none;">
                                                                <div refID="NEW" class="row outpadding">
                                                                    <div class="col-md-33">
                                                                        <span class="rec-text"></span>
                                                                    </div>
                                                                    <div class="col-md-3 text-center">
                                                                        <a class="icon" style="display:none;"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="$(this).deleteRecord();"></span></a>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                            <div id="donateRewardTemp" style="display:none;">
                                                                <div class="col-md-4"></div>
                                                                <div class="col-md-18">
                                                                    <label class="lbl-check-reward" style="cursor: pointer; font-weight: normal; margin-bottom: 0px;">
                                                                        <input type="checkbox" style="margin-right: 10px;" tabindex="3" /></label>
                                                                </div>
                                                                <div class="col-md-2"><span>เมื่อ</span></div>
                                                                <div class="col-md-12" style="padding-left: 8px; padding-right: 14px;">
                                                                    <input type="text" class="txt-reward-date form-control text-center" tabindex="3" donateRewardID="NEW" />
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                            <div id="synthesis">
                                <div class="border-box">
                                    <div class="col-md-36">
                                        <div class="border-box">
                                            <div class="row">
                                                <div class="col-md-4"><span>ประเภทการตรวจ</span></div>
                                                <div class="col-md-7">
                                                    <select id="chackType" class="selecte-box-custom" style="font-family: 'TH Sarabun New';">
                                                        <option style="font-family: 'TH Sarabun New';" value="standard">Standard</option>
                                                        <option style="font-family: 'TH Sarabun New';" value="virology">Virology</option>
                                                        <option style="font-family: 'TH Sarabun New';" value="immunohematology">Immunohematology</option>
                                                    </select>
                                                </div>
                                            </div>

                                            <div class="row">
                                                <table class="table table-bordered-excel" id="synthesisStandard" style="display:block;">
                                                    <thead>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-12" colspan="6"><span class="firstDonateTime">xxx</span></th>
                                                            <th class="col-md-2" colspan="1">Pheno</th>
                                                            <th class="col-md-22" colspan="16" style="text-align:left;"><span class="phenoValue">C+E+</span></th>
                                                        </tr>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-12" colspan="6"><span class="lastDonateTime">xxx</span></th>
                                                            <th class="col-md-2"><span class="ABOD"></span></th>
                                                            <th class="col-md-1"><span class="DAT_val"></span></th>
                                                            <th class="col-md-1"><span class="DATF_val"></span></th>
                                                            <th class="col-md-2"><span class="Anti_HBs_val"></span></th>
                                                            <th class="col-md-2"><span class="Upemic_val"></span></th>
                                                            <th class="col-md-1"><span class="Dabsp_val"></span></th>
                                                            <th class="col-md-1"><span class="HBsAg_val"></span></th>
                                                            <th class="col-md-2"><span class="Anti_HCV_val"></span></th>
                                                            <th class="col-md-1"><span class="Syph_val"></span></th>
                                                            <th class="col-md-2"><span class="COMNAT_val"></span></th>
                                                            <th class="col-md-2"><span class="ALBUMIN_val"></span></th>
                                                            <th class="col-md-2"><span class="PROTEIN_val"></span></th>
                                                            <th class="col-md-1"><span class="Ag_C_val"></span></th>
                                                            <th class="col-md-1"><span class="Ag_c_val"></span></th>
                                                            <th class="col-md-1"><span class="Ag_E_val"></span></th>
                                                            <th class="col-md-1"><span class="Ag_e_val"></span></th>
                                                            <th class="col-md-1"><span class="Ag_K_val"></span></th>
                                                        </tr>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-2">วันที่</th>
                                                            <th class="col-md-2">ประเภท</th>
                                                            <th class="col-md-2">บริจาคที่</th>
                                                            <th class="col-md-3">เหตุผลงดบริจาค</th>
                                                            <th class="col-md-1">ครั้งที่</th>
                                                            <th class="col-md-2">ความดัน</th>
                                                            <th class="col-md-2">ABOD</th>
                                                            <th class="col-md-1">DAT</th>
                                                            <th class="col-md-1">DATF</th>
                                                            <th class="col-md-2">Anti HBs</th>
                                                            <th class="col-md-2">Upemic</th>
                                                            <th class="col-md-1">Dabsp</th>
                                                            <th class="col-md-1">HBsAg</th>
                                                            <th class="col-md-2">Anti HCV</th>
                                                            <th class="col-md-1">Syph</th>
                                                            <th class="col-md-2">COMNAT</th>
                                                            <th class="col-md-2">ALBUMIN</th>
                                                            <th class="col-md-2">PROTEIN</th>
                                                            <th class="col-md-1">Ag C</th>
                                                            <th class="col-md-1">Ag c</th>
                                                            <th class="col-md-1">Ag E</th>
                                                            <th class="col-md-1">Ag e</th>
                                                            <th class="col-md-1">Ag K</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>

                                                <table class="table table-bordered-excel" id="synthesisVirology" style="display:none;">
                                                    <thead>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-14" colspan="6"><span class="firstDonateTime">xxx</span></th>
                                                            <th class="col-md-2" colspan="1">Pheno</th>
                                                            <th class="col-md-20" colspan="16" style="text-align:left;"><span class="phenoValue">C+E+</span></th>
                                                        </tr>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-14" colspan="6"><span class="lastDonateTime">xxx</span></th>
                                                            <th class="col-md-2"><span class="ABOD"></span></th>
                                                            <th class="col-md-2">ABO group</th>
                                                            <th class="col-md-2">ABO group</th>
                                                            <th class="col-md-2"><span class="ABO_group_val">O</span></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                            <th class="col-md-1"></th>
                                                        </tr>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-2">วันที่</th>
                                                            <th class="col-md-2">ประเภท</th>
                                                            <th class="col-md-3">บริจาคที่</th>
                                                            <th class="col-md-3">เหตุผลงดบริจาค</th>
                                                            <th class="col-md-2">ครั้งที่</th>
                                                            <th class="col-md-2">ความดัน</th>
                                                            <th class="col-md-2">ALAT</th>
                                                            <th class="col-md-2">WB</th>
                                                            <th class="col-md-2">Anti-HCV</th>
                                                            <th class="col-md-2">Malaria</th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th class="col-md-1"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>

                                                <table class="table table-bordered-excel" id="synthesisImmunohematology" style="display:none;">
                                                    <thead>
                                                        <%--<tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-14" colspan="6"><span class="firstDonateTime">xxx</span></th>
                                                            <th class="col-md-2" colspan="1">Pheno</th>
                                                            <th class="col-md-20" colspan="16" style="text-align:left;"><span class="phenoValue">C+E+</span></th>
                                                        </tr>--%>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th style="width:31%" colspan="6"><span class="lastDonateTime">xxx</span></th>
                                                            <th style="width:5.5%"><span class="ABOD">AB</span></th>
                                                            <th style="width:5.5%"><span class="zx">AB</span></th>
                                                            <th style="width:3.1%"><span class="ddf">+</span></th>
                                                            <th style="width:3.1%"><span class="po"></span></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                        </tr>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th style="width:5%">วันที่</th>
                                                            <th style="width:5%">ประเภท</th>
                                                            <th style="width:5%">บริจาคที่</th>
                                                            <th style="width:6%">เหตุผลงดบริจาค</th>
                                                            <th style="width:5%">ครั้งที่</th>
                                                            <th style="width:5%">ความดัน</th>
                                                            <th style="width:5.5%">ABO group</th>
                                                            <th style="width:5.5%">ABO group</th>
                                                            <th style="width:3.1%">C</th>
                                                            <th style="width:3.1%">c</th>
                                                            <th style="width:3.1%">E</th>
                                                            <th style="width:3.1%">e</th>
                                                            <th style="width:3.1%">K</th>
                                                            <th style="width:3.1%">Ab Sc</th>
                                                            <th style="width:3.1%">H-AB</th>
                                                            <th style="width:3.1%">Hem A</th>
                                                            <th style="width:3.1%">Hb</th>
                                                            <th style="width:3.1%">BW</th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                            <th style="width:3.1%"></th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>

                                            </div>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="labPane">
                <div class="border-box">
                    <div id="labTab">
                        <ul>
                            <li><a href="#historicalFile" style="">Historical File</a></li>
                            <li><a href="#immunohaemtologyFile" id="immunohaemtology-tab" style="">Immunohaemtology File</a></li>
                            <li><a href="#exams" id="exams-tab" style="">Exams</a></li>
                        </ul>
                        <div id="historicalFile">
                            <div class="border-box">
                                <div class="col-md-36">
                                    <table class="table table-bordered-excel" id="historicalFileTable">
                                        <thead>
                                            <tr>
                                                <th class="col-md-8">Exams</th>
                                                <th class="col-md-3">Result</th>
                                                <th class="col-md-3">First date</th>
                                                <th class="col-md-3">Last date</th>
                                                <th class="col-md-4">Samples tested</th>
                                                <th class="col-md-3">First Sample</th>
                                                <th class="col-md-3">Last Sample</th>
                                                <th class="col-md-4">First authtirising lab</th>
                                                <th class="col-md-4">Last authtirising lab</th>
                                            </tr>
                                        </thead>
                                        <tbody>

                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                        <div id="immunohaemtologyFile">
                            <div class="border-box" id="blockImmunohaemtologyFile">
                                <div class="col-md-36" style="border:1px solid black">
                                    <%--<p><label>&nbsp;&nbsp; Doner No.</label> <label id="doner-label-no">123456789</label> <label id="doner-label-name">test</label></p>--%>
                                    <table class="col-md-36" id="label-set-1">
                                        <tr>
                                            <td class="col-md-5" style="padding-left: 1px">Exams</td>
                                            <td class="col-md-9" style="padding-left: 27px">Result</td>
                                            <td class="col-md-3" style="padding-left: 27px">No.</td>
                                            <td class="col-md-9" style="padding-left: 27px">Date of first det.</td>
                                            <td class="col-md-9" style="padding-left: 27px">Date of last det.</td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-5">ABOD</td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="ABOD_RESULT" value="" /></td>
                                            <td class="col-md-3"><input type="text" class="col-md-32 long-label3" id="ABOD_NO" value="" /></td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="ABOD_FIRST_DATE" value="" /></td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="ABOD_LAST_DATE" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-5">Ext Pheno</td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="Ext_Pheno_RESULT" value="" /></td>
                                            <td class="col-md-3"><input type="text" class="col-md-32 long-label3" id="Ext_Pheno_NO" value="" /></td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="Ext_Pheno_FIRST_DATE" value="" /></td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="Ext_Pheno_LAST_DATE" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-5">Ab Screen</td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="Ab_Screen_DA" value="" /></td>
                                            <td class="col-md-3"><input type="text" class="col-md-32 long-label3" id="Ab_Screen_NO" value="" /></td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="Ab_Screen_FIRST_DATE" value="" /></td>
                                            <td class="col-md-9"><input type="text" class="col-md-32 long-label1" id="Ab_Screen_LAST_DATE" value="" /></td>
                                        </tr>
                                    </table>
                                    <br />
                                    <label class="set-label">&nbsp;&nbsp;Antigens</label>
                                    <table class="col-md-36" id="label-set-2">
                                        <tr>
                                            <td class="col-md-2"><label class="set-label" for="Rh_AG">Rh</label><input type="text" class="col-md-34 long-label4" id="Rh_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_C_AG">Ag C</label><input type="text" class="col-md-34 long-label4" id="Ag_C_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_c_AG">Ag c</label><input type="text" class="col-md-34 long-label4" id="Ag_c_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_E_AG">Ag E</label><input type="text" class="col-md-34 long-label4" id="Ag_E_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_e_AG">Ag e</label><input type="text" class="col-md-34 long-label4" id="Ag_e_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_K_AG">Ag K</label><input type="text" class="col-md-34 long-label4" id="Ag_K_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Mia_AG">Ag Mia</label><input type="text" class="col-md-34 long-label4" id="Ag_Mia_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Mur_AG">Ag Mur</label><input type="text" class="col-md-34 long-label4" id="Ag_Mur_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Dia_AG">Ag Dia</label><input type="text" class="col-md-34 long-label4" id="Ag_Dia_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Dib_AG">Ag Dib</label><input type="text" class="col-md-34 long-label4" id="Ag_Dib_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Xga_AG">Ag Xga</label><input type="text" class="col-md-34 long-label4" id="Ag_Xga_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Tja_AG">Ag Tja</label><input type="text" class="col-md-34 long-label4" id="Ag_Tja_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Jsa_AG">Ag Jsa</label><input type="text" class="col-md-34 long-label4" id="Ag_Jsa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Jsb_AG">Ag Jsb</label><input type="text" class="col-md-34 long-label4" id="Ag_Jsb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Lwa_AG">Ag Lwa</label><input type="text" class="col-md-34 long-label4" id="Ag_Lwa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_U_AG">Ag U</label><input type="text" class="col-md-34 long-label4" id="Ag_U_AG" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label" for="Fya_AG">Fya</label><input type="text" class="col-md-34 long-label4" id="Fya_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Fyb_AG">Fyb</label><input type="text" class="col-md-34 long-label4" id="Fyb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Jka_AG">Jka</label><input type="text" class="col-md-34 long-label4" id="Jka_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Jkb_AG">Jkb</label><input type="text" class="col-md-34 long-label4" id="Jkb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="M_AG">M</label><input type="text" class="col-md-34 long-label4" id="M_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="N_AG">N</label><input type="text" class="col-md-34 long-label4" id="N_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="S_AG">S</label><input type="text" class="col-md-34 long-label4" id="S_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="s_AG">s</label><input type="text" class="col-md-34 long-label4" id="s_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Lea_AG">Lea</label><input type="text" class="col-md-34 long-label4" id="Lea_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Leb_AG">Leb</label><input type="text" class="col-md-34 long-label4" id="Leb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Anti-Vel_AG">Anti-Vel</label><input type="text" class="col-md-34 long-label4" id="Anti-Vel_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Doa_AG">Ag Doa</label><input type="text" class="col-md-34 long-label4" id="Ag_Doa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Dob_AG">Ag Dob</label><input type="text" class="col-md-34 long-label4" id="Ag_Dob_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Coa_AG">Ag Coa</label><input type="text" class="col-md-34 long-label4" id="Ag_Coa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_Cob_AG">Ag Cob</label><input type="text" class="col-md-34 long-label4" id="Ag_Cob_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Mga_AG">Mga</label><input type="text" class="col-md-34 long-label4" id="Mga_AG" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label" for="Cw_AG">Cw</label><input type="text" class="col-md-34 long-label4" id="Cw_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Lua_AG">Lua</label><input type="text" class="col-md-34 long-label4" id="Lua_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Lub_AG">Lub</label><input type="text" class="col-md-34 long-label4" id="Lub_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Kpa_AG">Kpa</label><input type="text" class="col-md-34 long-label4" id="Kpa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Kpb_AG">Kpb</label><input type="text" class="col-md-34 long-label4" id="Kpb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="P1_AG">P1</label><input type="text" class="col-md-34 long-label4" id="P1_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="k_AG">k</label><input type="text" class="col-md-34 long-label4" id="k_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Ag_H_AG">Ag H</label><input type="text" class="col-md-34 long-label4" id="Ag_H_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="41">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="41" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="42">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="42" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="43">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="43" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="44">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="44" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="45">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="45" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="46">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="46" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="47">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="47" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="48">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="48" value="" /></td>
                                        </tr>
                                    </table>
                                    <br />
                                    <label class="set-label">&nbsp;&nbsp;Antibodies</label>
                                    <table class="col-md-36" id="label-set-3">
                                        <tr>
                                            <td class="col-md-2"><label class="set-label" for="D_A1">D</label><input type="text" class="col-md-34 long-label4" id="D_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="C_A1">C</label><input type="text" class="col-md-34 long-label4" id="C_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="c_A1">c</label><input type="text" class="col-md-34 long-label4" id="c_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="E_A1">E</label><input type="text" class="col-md-34 long-label4" id="E_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="e_A1">e</label><input type="text" class="col-md-34 long-label4" id="e_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="K_A1">K</label><input type="text" class="col-md-34 long-label4" id="K_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="55">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="55" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="56">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="56" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="57">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="57" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="58">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="58" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="59">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="59" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="60">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="60" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="61">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="61" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="62">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="62" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="63">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="63" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="64">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="64" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label" for="Fya_A1">Fya</label><input type="text" class="col-md-34 long-label4" id="Fya_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Fyb_A1">Fyb</label><input type="text" class="col-md-34 long-label4" id="Fyb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Jka_A1">Jka</label><input type="text" class="col-md-34 long-label4" id="Jka_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Jkb_A1">Jkb</label><input type="text" class="col-md-34 long-label4" id="Jkb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="M_A1">M</label><input type="text" class="col-md-34 long-label4" id="M_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="N_A1">N</label><input type="text" class="col-md-34 long-label4" id="N_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="S_A1">S</label><input type="text" class="col-md-34 long-label4" id="S_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="s_A1">s</label><input type="text" class="col-md-34 long-label4" id="s_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Lea_A1">Lea</label><input type="text" class="col-md-34 long-label4" id="Lea_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Leb_A1">Leb</label><input type="text" class="col-md-34 long-label4" id="Leb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Jsa_A1">Jsa</label><input type="text" class="col-md-34 long-label4" id="Jsa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Jsb_A1">Jsb</label><input type="text" class="col-md-34 long-label4" id="Jsa_A2" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Lwa_A1">Lwa</label><input type="text" class="col-md-34 long-label4" id="Lwa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="U_A1">U</label><input type="text" class="col-md-34 long-label4" id="U_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Pk_A1">Pk</label><input type="text" class="col-md-34 long-label4" id="Pk_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Mia_A1">Mia</label><input type="text" class="col-md-34 long-label4" id="Mia_A1" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label" for="Cw_A1">Cw</label><input type="text" class="col-md-34 long-label4" id="Cw_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Lua_A1">Lua</label><input type="text" class="col-md-34 long-label4" id="Lua_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Lub_A1">Lub</label><input type="text" class="col-md-34 long-label4" id="Lub_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Kpa_A1">Kpa</label><input type="text" class="col-md-34 long-label4" id="Kpa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Kpb_A1">Kpb</label><input type="text" class="col-md-34 long-label4" id="Kpb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="P1_A1">P1</label><input type="text" class="col-md-34 long-label4" id="P1_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="k_A1">k</label><input type="text" class="col-md-34 long-label4" id="k_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Vel_A1">Vel</label><input type="text" class="col-md-34 long-label4" id="Vel_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="TJA_A1">TJA</label><input type="text" class="col-md-34 long-label4" id="TJA_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Doa_A1">Doa</label><input type="text" class="col-md-34 long-label4" id="Doa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Dob_A1">Dob</label><input type="text" class="col-md-34 long-label4" id="Dob_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Coa_A1">Coa</label><input type="text" class="col-md-34 long-label4" id="Coa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Cob_A1">Cob</label><input type="text" class="col-md-34 long-label4" id="Cob_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="H_A1">H</label><input type="text" class="col-md-34 long-label4" id="H_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="Mga_A1">Mga</label><input type="text" class="col-md-34 long-label4" id="Mga_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label" for="78">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="78" value="" /></td>
                                        </tr>
                                    </table>
                                    <br />
                                    <label class="set-label">&nbsp;&nbsp;HLA</label>
                                    <table class="col-md-36" id="label-set-4" style="margin-bottom:10px;">
                                        <tr>
                                            <td class="col-md-4"><label class="set-label" for="HLA-Ax_RESULT">HLA-Ax</label><input type="text" class="col-md-35 long-label2" id="HLA-Ax_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label" for="HLA-Ay_RESULT">HLA-Ay</label><input type="text" class="col-md-35 long-label2" id="HLA-Ay_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label" for="HLA-Bx_RESULT">HLA-Bx</label><input type="text" class="col-md-35 long-label2" id="HLA-Bx_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label" for="HLA-By_RESULT">HLA-By</label><input type="text" class="col-md-35 long-label2" id="HLA-By_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label" for="HLA-DRB1x_RESULT">HLA-DRB1x</label><input type="text" class="col-md-35 long-label2" id="HLA-DRB1x_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label" for="HLA-DRB1y_RESULT">HLA-DRB1y</label><input type="text" class="col-md-35 long-label2" id="HLA-DRB1y_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label" for="xx">&nbsp;</label><input type="text" class="col-md-35 long-label2" id="xx" value="" /></td>
                                            <td class="col-md-4"><label class="set-label" for="xyx">&nbsp;</label><input type="text" class="col-md-35 long-label2" id="xyx" value="" /></td>
                                        </tr>
                                    </table>
                                    <br />
                                </div>
                            </div>
                            
                        </div>
                        <div id="exams">
                            <div class="border-box">
                                <div class="col-md-36 tableHeadDiv"><b>Donation examinations</b></div>
                                <div class="col-md-36">
                                    <table class="table table-bordered-excel tablesorter" id="exams-tab-table">
                                        <thead>
                                            <tr>
                                                <th class="col-md-2">ครั้งที่</th>
                                                <th class="col-md-3">วันที่ตรวจสอบ</th>
                                                <th class="col-md-3">Sample no</th>
                                                <th class="col-md-3">Examination</th>
                                                <th class="col-md-3">Result</th>
                                                <th class="col-md-3">Input 1</th>
                                                <th class="col-md-3">Input 2</th>
                                                <th class="col-md-4">Validation by</th>
                                                <th class="col-md-4">Ext. Lab</th>
                                                <th class="col-md-4">ประเภทผู้บริจาค</th>
                                            </tr>
                                        </thead>
                                        <tbody>

                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="ProductionPane">
                <div class="border-box">
                    <div class="col-md-36">ข้อมูล PRODUCTION</div>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="border-box" style="margin-bottom: 5px;">
            <div class="row" style="margin-bottom: 15px;">
                <div class="col-md-2">
                    วันที่เริ่ม
                </div>
                <div class="col-md-3">
                    <input id="txtCommentDateForm" type="text" class="form-control text-center" disabled="disabled" />
                </div>
                <div class="col-md-2 text-center">
                    วันที่สิ้นสุด
                </div>
                <div class="col-md-3">
                    <input id="txtCommentDateTo" type="text" class="form-control text-center" tabindex="4" />
                </div>
                <div class="col-md-2 text-center">
                    หมายเหตุ
                </div>
                <div class="col-md-23">
                    <input id="txtDonorComment" type="text" class="form-control"  tabindex="4" />
                </div>
                <div class="col-md-1 text-center">
                    <button id="spAddComment" class="btn btn-icon" onclick="return false;" tabindex="4">
                        <i class="glyphicon glyphicon-circle-arrow-down"></i>
                    </button>
                </div>
            </div>
            <div class="row">
                <div id="divComment" class="col-md-36">
                </div>
                <div id="divCommentTemp" style="display:none;">
                    <div class="row outpadding" refID="NEW">
                        <div class="col-md-6"><span class="dc-datecomment"></span></div>
                        <div class="col-md-29"><span class="dc-comment"></span></div>
                        <div class="col-md-1 text-center">
                            <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="$(this).deleteComment();"></span></a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div class="row" style="margin-bottom: 20px;">
        <div class="col-md-3">
            <input id="btnCard" type="button" class="btn btn-primary btn-block" value="พิมพ์บัตร" tabindex="-1" />
        </div>
        <div class="col-md-3">
            <input id="btnSticker" type="button" class="btn btn-primary btn-block" value="พิมพ์สติ๊กเกอร์" tabindex="-1" />
        </div>
        <div class="col-md-3">
            <input id="btnHistory" type="button" class="btn btn-success btn-block" value="บันทึกประวัติ" tabindex="-1" />
        </div>
        <div class="col-md-21"></div>
        <div class="col-md-3">
            <input id="btnCancel" type="button" class="btn btn-block" value="ยกเลิก" tabindex="-1" />
        </div>
        <div class="col-md-3">
            <input id="btnSave" type="button" class="btn btn-success btn-block" value="ลงทะเบียน" tabindex="1" />
        </div>
    </div>
    <div style="display: none;">
        <input id="data" runat="server" /></div>
</asp:Content>
