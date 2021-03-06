﻿<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="register.aspx.vb" Inherits="Claret.donor_register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table-deferal > tbody > tr > td {
            border-bottom: 0;
        }
        #tbDefInterview > tbody > tr > td:last-child {
            border-top-color: transparent;
            border-right-color: transparent;
            border-bottom-color: transparent;
            background-color: white;
        }
        #tbDefInterview > tbody > tr > td:first-child {
            border-right-color: transparent;
        }
        #tbExam > tbody > tr > td:last-child {
            border-top-color: transparent;
            border-right-color: transparent;
            border-bottom-color: transparent;
            background-color: white;
        }

        .set-label-font {
            font-weight:normal;
        }
    </style>
    <script src="../resources/javascript/page/registerScript.js?ver=20160205" type="text/javascript"></script>
    <script>
        $(function () {
            lookupControl();
            if ($("#data").attr("lmenu") == "lmenuEditDonorRegis") {
                $("#btnSticker").css("display", "none");
                $("#btnSaveOnlyDonor").css("display", "none");
            }
            $("#txtCardNumber").blur(function () { $(this).addExtCard(); });
            //    .on("blur", function () {
            //    $("#txtCardNumber").addExtCard();
            //}).focus();
            $("#ddlDefferal").setAutoList({
                selectItem: function () {
                    if ($(this).H2GValue() == 'ACTIVE') { $("#tbDeferral > thead > tr[status=INACTIVE]").hide(); }
                    else { $("#tbDeferral > thead > tr[status=INACTIVE]").show(); }
                },
            }).H2GValue("ACTIVE");
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
            $("#txtBirthDay").H2GDatebox({ allowFutureDate: false }).blur(function () {
                console.log($(this).H2GValue());
                var pattern = 'dd/MM/yyyy';
                if ($(this).H2GValue() != '') {
                    $(this).H2GValue($(this).H2GValue().replace(/\W+/g, ''));
                    $(this).next().remove();
                    if (isDate($(this).H2GValue(), pattern.replace(/\W+/g, ''))) {
                        var isValue = new Date(getDateFromFormat($(this).H2GValue(), pattern.replace(/\W+/g, '')));
                        $(this).H2GValue(formatDate(isValue, pattern));
                    }
                    $("#txtAge").H2GValue(H2G.calAge($(this).H2GValue()) + ' ปี');
                    if (H2G.calAge($(this).H2GValue()) > 59) {
                        $("#txtAge").css("font-weight", "bold");
                    } else {
                        $("#txtAge").css("font-weight", "normal");
                    }
                } else {
                    $("#txtAge").H2GValue('');
                }
            });
            $("#txtLastDonateDate").H2GDatebox({ allowFutureDate: false }).blur(function () {
                if ($(this).H2GValue() != '') {
                    if (isDate($(this).val().replace(/\W+/g, ''), 'ddMMyyyy')) {
                        var isValue = new Date(getDateFromFormat($(this).val().replace(/\W+/g, ''), 'ddMMyyyy'));
                        $(this).H2GAttr('donatedatetext', formatDate(isValue, "dd NNN yyyy"));
                        //enterDatePickerDonateRecord($(this), "enter");
                    }
                }
                else { $(this).H2GAttr('donatedatetext', ''); }
                //$("#spAddDonateRecord").focus();
            });
            //    .setCalendar({
            //    maxDate: new Date(),
            //    minDate: "-100y",
            //    yearRange: "c-100:c+70",
            //    onSelect: function (selectedDate, objDate) {
            //        if (selectedDate != '') { $(this).H2GAttr('donatedatetext', formatDate($(this).datepicker("getDate"),"dd MMM yyyy")); } else { $(this).H2GAttr('donatedatetext', ''); }
            //        $("#spAddDonateRecord").focus();
            //    },
            //    onClose: function () {
            //        enterDatePickerDonateRecord($("#txtLastDonateDate"), "close");
            //    },
            //    onEnterKey: function () {
            //        enterDatePickerDonateRecord($("#txtLastDonateDate"), "enter");
            //    },
            //});
            $("#txtCommentDateForm").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
            $("#txtCommentDateTo").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox({ allowPastDate: false }).setCalendar({
                maxDate: "+100y",
                minDate: new Date(),
                yearRange: "c-50:c+50",
                onSelect: function (selectedDate, objDate) { $("#txtDonorComment").focus(); },
            });
            //$("#txtDonorComment").blur(function () { $(this).addComment(); });
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
                defaultSelect: '3',
                selectItem: function () {
                    var cardNumber = $('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]').H2GAttr('cardNumber');
                    $("#txtCardNumber").H2GValue(cardNumber || '').H2GFill({ maxlen: $("#ddlExtCard option:selected").H2GAttr("maxLength"), minlen:  $("#ddlExtCard option:selected").H2GAttr("minLength")});
                },
            });
            //$("#ddlExtCard").on('autocompleteselect', function () {
            //    //var cardNumber = $('#divCardNumber div[extID="' + $(this).H2GValue() + '"]').H2GAttr('cardNumber');
            //    //$("#txtCardNumber").H2GValue(cardNumber || '').focus();
            //});
            $("input:radio[name=gender]").change(function (e) {
                $("#ddlTitleName").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'titlename', gender: $("#rbtM").is(':checked') == true ? "M" : "F" } });
            });
            $("#txtDefDateFrom").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
            
            $("#btnSave").click(function () {
                gotoRegister = true;
                if ($("#data").attr("lmenu") == "lmenuEditDonorRegis") {
                    if (validation()) {
                        saveDonorInfo(false);
                    }
                } else {
                    checkBeforSave(); 
                }
                               
            });
            $("#btnSaveOnlyDonor").click(function () {
                //if (true) {
                //    if (validation()) {
                //        saveDonorInfo(false);
                //    }
                //}
                checkBeforSave();
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
                        donatehospitalid: $("#data").H2GAttr("visitID"),
                    },
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                    },
                    success: function (data) {
                        if (!data.onError) {
                            data.getItems = jQuery.parseJSON(data.getItems);
                            $("#divReceiptHospital").show();
                            $("#spReceiptHospital").H2GValue(data.getItems.HospitalName + " รายการที่ " + data.getItems.QueueCount + "/" + data.getItems.QueueTotal);
                        }
                    }
                });    //End ajax
            }

            if ($("#data").H2GAttr("donorID") != undefined) {
                //# Edit
                if ($("#data").H2GAttr("visitID") != undefined) { $("#spRegisNumber").H2GAttr("visitID", $("#data").H2GAttr("visitID")); }
                showDonorData();
            } else {
                //# New
                $("#txtDonorName").H2GValue($("#data").H2GAttr("donorName") || "");
                $("#txtDonorSurName").H2GValue($("#data").H2GAttr("donorSurname") || "");
                $("#txtBirthDay").H2GValue($("#data").H2GAttr("birthday") || "");
                $("#txtAge").H2GValue(H2G.calAge($("#data").H2GAttr("birthday") || "") + ' ปี');
                $("#spVisitInfo").H2GValue("วันที่ลงทะเบียน " + formatDate(new Date(getDateFromFormat($("#data").H2GAttr("plan_date"), "dd/mm/yyyy")), "dd NNN yyyy HH:mm") + " เข้าพบครั้งแรก กำลังดำเนินการบริจาคครั้งที่ 1").H2GFill({
                    visitDateText: formatDate(new Date(getDateFromFormat($("#data").H2GAttr("plan_date"), "dd/mm/yyyy")), "dd NNN yyyy HH:mm"),
                    lastVisitDateText: "",
                    currentDonateNumber: "1",
                    visitDate: formatDate(new Date(getDateFromFormat($("#data").H2GAttr("plan_date"), "dd/mm/yyyy")), "dd-MM-yyyy HH:mm")
                });
                $("#infoTab > ul > li > a[href='#todayPane']").H2GValue("2.2) " + formatDate(new Date(getDateFromFormat($("#data").H2GAttr("plan_date"), "dd/mm/yyyy")), "dd NNN yyyy"))
                $("#spVisitCount").H2GValue("รวมจำนวนการเข้าพบ 0 ครั้ง / บริจาค 0 ครั้ง");
                donorSelectDDL();
                lookupTabQuestionaire();
                showVisitHistory();
            }

            $.extend($.fn, {
                addExtCard: function (args) {
                    var self = this;
                    if ($(self).H2GValue() != "") {
                        if (isUpdateExtNumber(self)) {
                            H2GOpenPopupBox({
                                header: "กรุณาตรวจสอบ",
                                detail: "คุณต้องการจะแก้ไขเลขที่บัตร " + $("#ddlExtCard option:selected").text() + " ใช่หรือไม่",
                                isAlert: false,
                                confirmFunction: function () { addExtCardMain($(self)); },
                                cancelFunction: function () { $(self).H2GValue(""); },
                            });
                        } else {
                            addExtCardMain(self);
                        }
                    } else {
                        //$("#rbtM").focus();
                    }
                },
                deleteExtCard: function (args) {
                    var extID = $(this).closest("div.row").H2GAttr("extID");
                    var refID = $(this).closest("div.row").H2GAttr("refID");
                    H2GOpenPopupBox({
                        header: "ลบรายการ",
                        detail: "ต้องการจะลบ " + $(this).closest("div.row").find(".ext-number").H2GValue() + " ใช่หรือไม่?",
                        isAlert: false,
                        confirmFunction: function () {
                            console.log("confirmFunction", $(this), $("#divCardNumber .row[refID=NEW][extID=" + extID + "]"));
                            if ($("#divCardNumber .row[refID=NEW][extID=" + extID + "]").length > 0) {
                                $("#divCardNumber .row[refID=NEW][extID=" + extID + "]").remove();
                            } else {
                                $("#divCardNumber .row[refID=" + refID + "]").hide().H2GFill({ refID: "D#" + refID, cardNumber: "" });
                            }
                            $("#txtCardNumber").focus();
                        }
                    });
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
                    var self = $(this);
                    H2GOpenPopupBox({
                        header: "กรุณาตรวจสอบ",
                        detail: "ต้องการจะลบความเห็น" + " " + $(this).closest("div.row").find(".dc-datecomment").H2GValue() + " " + "ใช่หรือไม่?",
                        isAlert: false,
                        confirmFunction: function () {
                            //addExtCardMain($(self));
                            self.closest("div.row").remove();
                        },
                        cancelFunction: function () {
                            //$(self).H2GValue("");
                            //self.closest("div.row").hide().H2GAttr("refID", "D#" + $(this).closest("div.row").H2GAttr("refID"));
                            return;
                        },
                    });
                },
                addDonateRecord: function (args) {
                    console.log("addDonateRecord");
                    if ($("#txtOuterDonate").H2GValue() != "" && $("#txtLastDonateDate").H2GValue() != "") {
                        if ($("#txtOuterDonate").H2GAttr("wStatus") != "working") {
                            $("#txtOuterDonate").H2GAttr("wStatus", "working");
                            $.ajax({
                                url: "../../ajaxAction/donorAction.aspx",
                                data: H2G.ajaxData({ 
                                    action: 'checkinsertreward',
                                    donor_id: $("#data").H2GAttr("donorID"),
                                    donatedate: $("#txtLastDonateDate").H2GValue(),
                                    donation_number: $("#txtOuterDonate").H2GValue(),
                                    reward_list: $('#divDonateRecord').H2GAttr("rewardList") || "",
                                }).config,
                                type: "POST",
                                dataType: "json",
                                error: function (xhr, s, err) {
                                    console.log(s, err);
                                    $("#txtOuterDonate").H2GAttr("wStatus", "error");
                                },
                                success: function (data) {
                                    if (!data.onError) {
                                        data.getItems = jQuery.parseJSON(data.getItems);
                                        console.log(data.getItems);
                                        if (data.getItems.msg == "") {
                                            var rowRecord = $("#divDonateRecordTemp").children().clone();
                                            $(rowRecord).H2GFill({
                                                donatedate: $("#txtLastDonateDate").H2GValue(),
                                                donatenumber: data.getItems.DonationNumber,
                                                donatefrom: data.getItems.DonationFrom,
                                                associationID: $("#ddlExtAsso").H2GValue(),
                                            });
                                            $(rowRecord).find("span.rec-text").H2GValue("ครั้งที่ " + data.getItems.DonationNumber + " บริจาควันที่ "
                                                + $("#txtLastDonateDate").H2GAttr("donatedatetext") + " ณ "
                                                + $("#ddlExtAsso option:selected").text().replace($("#ddlExtAsso option:selected").H2GAttr("valueID") + " ", ""));
                                            
                                            // for each reward 
                                            $.each((data.getItems.DonationRewardList), function (indexr, er) {
                                                if ($('#divDonateRecord').H2GAttr("rewardList").indexOf("," + er.ID + ",") == -1) {
                                                    var rowReward = $("#donateRewardTemp").clone();
                                                    $(rowReward).find(".lbl-check-reward").append(er.Description).H2GAttr('rewardID', er.ID);
                                                    $(rowReward).find(".lbl-check-reward input").on("change", function () { $(this).checkedReward() });
                                                    $(rowReward).find(".txt-reward-date").H2GFill({ rewardID: er.ID }).setCalendar({
                                                        maxDate: new Date(),
                                                        minDate: "-20y",
                                                        yearRange: "c-20:c+0",
                                                        onSelect: function (selectedDate, objDate) {
                                                            if (selectedDate != '') {
                                                                $(this).closest("div.row").find(".lbl-check-reward[rewardID='"
                                                                    + $(this).H2GAttr("rewardID") + "'] input").prop("checked", true);
                                                            }
                                                        },
                                                        onClose: function () {
                                                            if ($(this).H2GValue() == '') {
                                                                $(this).closest("div.row").find(".lbl-check-reward[rewardID='"
                                                                    + $(this).H2GAttr("rewardID") + "'] input").prop("checked", false);
                                                            } else {
                                                                $(this).closest("div.row").find(".lbl-check-reward[rewardID='"
                                                                    + $(this).H2GAttr("rewardID") + "'] input").prop("checked", true);
                                                            }
                                                        },
                                                    }).H2GDatebox({ allowFutureDate: false });
                                                    $(rowRecord).append($(rowReward).children());
                                                    $('#divDonateRecord').H2GAttr("rewardList", $('#divDonateRecord').H2GAttr("rewardList") + "," + er.ID + ",");
                                                }
                                            });
                                            $('#divDonateRecord').prepend(rowRecord).H2GAttr("lastrecord", data.getItems.DonationNumber);


                                            $("#spRegisNumber").H2GFill({ donateNumberExt: $("#txtOuterDonate").H2GValue().toNumber() + $("#spRegisNumber").H2GAttr("donateNumberExt").toNumber() });

                                            $("#spVisitCount").H2GValue("รวมจำนวนการเข้าพบ " + $("#spRegisNumber").H2GAttr("visitNumber") + " ครั้ง / บริจาค " + ($("#spRegisNumber").H2GAttr("donateNumber").toNumber() + $("#spRegisNumber").H2GAttr("donateNumberExt").toNumber()) + "(" + $("#spRegisNumber").H2GAttr("donateNumber") + "+" + $("#spRegisNumber").H2GAttr("donateNumberExt") + ") ครั้ง");

                                            $("#spVisitInfo").H2GValue("");
                                            $("#spVisitInfo").append("วันที่ลงทะเบียน " + $("#spVisitInfo").H2GAttr("visitDateText"));
                                            if ($("#spVisitInfo").H2GAttr("lastVisitDateText") != "") {
                                                $("#spVisitInfo").append(" เข้าพบครั้งสุดท้ายเมื่อ " + $("#spVisitInfo").H2GAttr("lastVisitDateText") + " ( " + $("#spVisitInfo").H2GAttr("diffDate") + " วัน )");
                                            } else {
                                                $("#spVisitInfo").append(" เข้าพบครั้งแรก");
                                            }

                                            $("#spVisitInfo").H2GFill({ currentdonatenumber: ($("#spVisitInfo").H2GAttr("currentDonateNumber").toNumber() + $("#txtOuterDonate").H2GValue().toNumber()) }).append(" กำลังดำเนินการบริจาคครั้งที่ " + $("#spVisitInfo").H2GAttr("currentDonateNumber"));

                                            // รันปุ่มลบใหม่
                                            $('#divDonateRecord > div:visible a.icon').hide();
                                            $.each(($('#divDonateRecord > div:visible')), function (index, e) {
                                                if ($(e).H2GAttr("donatefrom") == "EXTERNAL") { $(e).find("a.icon").show(); }
                                                return false;
                                            });
                                            $("#txtOuterDonate").H2GValue(""); $("#txtLastDonateDate").H2GValue(""); $("#ddlExtAsso").H2GValue("");
                                        } else {
                                            $("#txtOuterDonate").focus();
                                            notiWarning(data.getItems.msg);
                                        }
                                    }
                                    $("#txtOuterDonate").H2GAttr("wStatus", "done");
                                }
                            });    //End ajax
                        }
                    } else {
                        var warning = "";
                        if ($("#txtOuterDonate").H2GValue() == "") { warning = "กรุณากรอกครั้งที่บริจาค"; $("#txtOuterDonate").focus(); }
                        else if ($("#txtLastDonateDate").H2GValue() == "") { warning = "กรุณากรอกวันที่บริจาค"; $("#txtLastDonateDate").focus(); }
                        notiWarning(warning);
                    }
                },
                deleteDonateRecord: function (args) {
                    //var rewardList = $('#divDonateRecord').H2GAttr("rewardList") || "";
                    //.H2GAttr("rewardID")
                    $.each(($(this).closest("div.row").find("input.txt-reward-date")), function (index, e) {
                        $('#divDonateRecord').H2GAttr("rewardList", $('#divDonateRecord').H2GAttr("rewardList").replace("," + $(e).H2GAttr("rewardID") + ",", ""));
                    });

                    if ($(this).closest("div.row").H2GAttr("refID") == "NEW") {
                        $(this).closest("div.row").remove();
                    } else {
                        $(this).closest("div.row").hide().H2GAttr("refID", "D#" + $(this).closest("div.row").H2GAttr("refID"));
                    }
                    // ต้องคำนวน DonateNumberExt ใหม่โดยจะลดลง 1 ทุกครั้ง
                    var DonateNumber = $("#spRegisNumber").H2GAttr("donateNumber") || "0";
                    var DonateNumberExt = $("#spRegisNumber").H2GAttr("donateNumberExt") || "0";
                    if (DonateNumberExt != "0") { DonateNumberExt = (DonateNumberExt.toNumber() - 1) + ""; }
                    $("#spVisitCount").H2GValue("รวมจำนวนการเข้าพบ " + $("#spRegisNumber").H2GAttr("visitNumber") + " ครั้ง / บริจาค " + (DonateNumberExt.toNumber() + DonateNumber.toNumber()) + "(" + $("#spRegisNumber").H2GAttr("donateNumber") + "+" + DonateNumberExt + ") ครั้ง");
                    $("#spRegisNumber").H2GAttr("donateNumberExt", DonateNumberExt);
                    
                    $("#spVisitInfo").H2GValue("วันที่ลงทะเบียน " + $("#spVisitInfo").H2GAttr("visitDateText") + " เข้าพบครั้งสุดท้ายเมื่อ " + $("#spVisitInfo").H2GAttr("lastVisitDateText") + " ( " + $("#spVisitInfo").H2GAttr("diffDate") + " วัน ) กำลังดำเนินการบริจาคครั้งที่ " + (DonateNumberExt.toNumber() + DonateNumber.toNumber() + 1))
                        .H2GFill({ currentDonateNumber: (DonateNumberExt.toNumber() + DonateNumber.toNumber() + 1) });
                    // last record จะลดลง 1 เสมอ
                    var lastRecord = $('#divDonateRecord').H2GAttr("lastrecord") || "0";
                    $('#divDonateRecord').H2GFill({ lastrecord: lastRecord.toNumber() - 1 });
                    // รันปุ่มลบใหม่
                    $.each(($('#divDonateRecord > div:visible')), function (index, e) {
                        if ($(e).H2GAttr("donatefrom") == "EXTERNAL") { $(e).find("a.icon").show(); }
                        return false;
                    });
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
                deleteExam: function (args) {
                    if ($(this).closest("tr").H2GAttr("refID") == "NEW") {
                        $(this).closest("tr").remove();
                    } else {
                        if (confirm("ต้องการจะลบ " + $(this).closest("tr").find(".td-exam").html() + " ใช่หรือไม่?")) {
                            $(this).closest("tr").hide().H2GAttr("refID", "D#" + $(this).closest("tr").H2GAttr("refID"));
                        }
                    }
                },
                latinNameChange: function (args) {
                    if ($(this).is(':checked')) {
                        $("#txtDonorNameEng").H2GEnable().focus();
                        $("#txtDonorSurNameEng").H2GEnable();
                    } else {
                        $("#txtDonorNameEng").H2GDisable();
                        $("#txtDonorSurNameEng").H2GDisable();
                    }
                },
                addDeferral: function (args) {
                    if (deferralValidation()) {
                        var dataRow = $("#tbDefInterview > thead > tr.template-data").clone().show();
                        $(dataRow).H2GFill({
                            defID: $("#ddlITVDeferral option:selected").H2GAttr("valueID"),
                            defType: $("#ddlDeferralType").H2GValue(),
                            defDuration: $("#txtDuration").H2GValue(),
                            defStartDate: $("#txtDefDateFrom").H2GValue(),
                            defEndDate: $("#txtDefDateTo").H2GValue(),
                            defRemarks: $("#txtDefRemarks").H2GValue(),
                        });
                        $(dataRow).find('.td-description').append($("#ddlITVDeferral option:selected").H2GAttr("desc")).H2GAttr("title", $("#ddlITVDeferral option:selected").H2GAttr("desc"));                        
                        $(dataRow).find('.td-enddate').append('วันที่สิ้นสุด ' + formatDate(new Date(getDateFromFormat($('#txtDefDateTo').H2GValue(), 'dd/mm/yyyy')), "dd NNN yyyy")).H2GAttr("title", 'วันที่สิ้นสุด ' + formatDate(new Date(getDateFromFormat($('#txtDefDateTo').H2GValue(), 'dd/mm/yyyy')), "dd NNN yyyy"));
                        $("#tbDefInterview > tbody").append(dataRow);
                        
                        $("#txtDefCode").H2GValue("");
                        $("#ddlITVDeferral").closest("div").find("input").H2GValue("");
                        $("#txtDuration").H2GValue("");
                        $("#txtDefDateTo").H2GValue("");
                        $("#txtDefRemarks").H2GValue("");
                    }
                },
                deleteDeferral: function (args) {
                    if ($(this).closest("tr").H2GAttr("refID") == "NEW") {
                        $(this).closest("tr").remove();
                    } else {
                        if (confirm("ต้องการจะลบ " + $(this).closest("tr").find(".td-description").html() + " ใช่หรือไม่?")) {
                            $(this).closest("tr").hide().H2GAttr("refID", "D#" + $(this).closest("tr").H2GAttr("refID"));
                        }
                    }
                },
                selectHistoryDonate: function (args) {
                    $("#data").H2GAttr("visitID", $(this).closest("tr").H2GAttr("refID"));
                    $("#spRegisNumber").H2GAttr("visitID", $(this).closest("tr").H2GAttr("refID"));
                    showDonorData();
                    $("#infoTab").tabs("option", "active", 1);
                },
                checkSampleNo: function() {
                    var popup = $(this).closest("div #divBarcodeTemplete");
                    $(popup).find("#txt").H2GValue();
                    $(popup).find("#txt").H2GValue();
                },
                changeQuestLanguage: function () {
                    self = this;
                    var questContent = $("#tbQuestionnaire > tbody > tr");
                    $.each((questContent), function (index, e) {
                        if ($(self).H2GValue() == "English") {
                            $(e).find(".td-question > span").H2GValue($(e).H2GAttr("questdesc"));
                        } else {
                            $(e).find(".td-question > span").H2GValue($(e).H2GAttr("questdescth"));
                        }
                    });
                },
                stickerPrint: function () {
                    $("#btnSticker").H2GDisable();
                    $.ajax({
                        url: '../ajaxAction/donorAction.aspx', data: { action: 'stickerprint', donor_id: $("#data").H2GAttr("donorid") }, type: "POST", dataType: "json",
                        error: function (xhr, s, err) { console.log(s, err); $("#btnSticker").H2GEnable(); },
                        success: function (data) {
                            if (!data.onError) {
                                data.getItems = jQuery.parseJSON(data.getItems);
                                console.log(data);
                            } else { notiError(data.exMessage); }
                            $("#btnSticker").H2GEnable();
                        }
                    });    //End ajax
                },
                checkPhoneNumber: function () {
                    var self = this;
                    if ($(self).H2GValue() != "") {
                        if (checkMaxLength($(self))) {
                            if (checkMinLength($(self))) {

                            } else {
                                notiWarning("กรุณากรอกหมายเลขโทรศัพท์ " + $(self).H2GAttr("minlen") + " หลัก");
                                $(self).focus();
                            }
                        } else {
                            notiWarning("กรุณากรอกหมายเลขโทรศัพท์ " + $(self).H2GAttr("maxlen") + " หลัก");
                            $(self).focus();
                        }
                    }
                },
            });

            //### extend

            $("#synthesisLink").click(loadSynthesisLink);

            $("#chackType").change(function () {
                selecterTable(this);
            });

            // menu control
            if ($("#data").H2GAttr("lmenu") == "lmenuDonorRegis" || $("#data").H2GAttr("lmenu") == "lmenuEditDonorRegis") {
                $("#infoTabToday").tabs("option", "disabled", [1,2]);
                $(".claret-page-header span").H2GValue("ลงทะเบียนผู้บริจาค");
            } else if ($("#data").H2GAttr("lmenu") == "lmenuInterview") {
                $("#infoTabToday").tabs("option", "active", [2]);
                $(".claret-page-header span").H2GValue("คัดกรองผู้บริจาค");
            } else if ($("#data").H2GAttr("lmenu") == "lmenuDonate") {
                $("#infoTabToday").tabs("option", "disabled", [2]);
                $(".claret-page-header span").H2GValue("เจาะเก็บ");
            } else if ($("#data").H2GAttr("lmenu") == "lmenuHistoryReport") {
                //$("#infoTabToday").tabs("option", "disabled", [1]);
                $(".claret-page-header span").H2GValue("รายงานย้อนหลัง");
            } else if ($("#data").H2GAttr("lmenu") == "lmenulabRegis") {
                $(".claret-page-header span").H2GValue("ลงทะเบียนขอตรวจ Lab");
                $(".mandatory-interview").hide();
            }

            $("#btnSticker").click(function () { $(this).stickerPrint(); })

            $("#txtZipcode").keydown(function (e) {
                if ($.inArray(e.keyCode, [46, 8, 9, 27, 13, 110]) !== -1 ||
                    (e.keyCode === 65 && (e.ctrlKey === true || e.metaKey === true)) ||
                    (e.keyCode >= 35 && e.keyCode <= 40)) {
                    return;
                }
                if ((e.shiftKey || (e.keyCode < 48 || e.keyCode > 57)) && (e.keyCode < 96 || e.keyCode > 105)) {
                    e.preventDefault();
                }
            });
            
        });
        function checkMinLength(xobj) {
            if ($(xobj).H2GAttr("minlen") == "") {
                return true;
            } else if (parseInt($(xobj).H2GAttr("minlen")) > $(xobj).H2GValue().length) {
                return false;
            } 
            return true;
        }
        function checkMaxLength(xobj) {
            if ($(xobj).H2GAttr("maxlen") == "") {
                return true;
            } else if (parseInt($(xobj).H2GAttr("maxlen")) < $(xobj).H2GValue().length) {
                return false;
            } 
            return true;
        }
        function checkNationOnlyNumber(xobj) {
            if ($("#ddlExtCard").H2GValue() == '3') {
                if (isNaN($(xobj).H2GValue())) {
                    return false;
                } 
            }
            return true;
        }
        function isUpdateExtNumber(xobj) {
            if ($('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]').length > 0) {
                if ($(xobj).H2GValue() != $('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]').H2GAttr("cardNumber")) {
                    return true;
                }
            }
            return false;
        }
        function lookupTabQuestionaire() {
            $("#txtExamCode").enterKey(function () { getExamination($(this).H2GValue()); });
            $("#ddlExam").setAutoListValue({
                url: '../ajaxAction/masterAction.aspx', data: { action: 'examination' },
                selectItem: function () {
                    $("#txtExamCode").H2GValue($("#ddlExam").H2GValue());
                    getExamination($("#txtExamCode").H2GValue());
                },
            });

            if ($("#spStatus").H2GValue() == "WAIT INTERVIEW") {
                $("#ddlITVDonationType").H2GAttr("selectItem", $("#data").H2GAttr("donationTypeID") || "");
                $("#ddlITVBag").H2GAttr("selectItem", $("#data").H2GAttr("bagID") || "");
                $("#ddlITVDonationTo").H2GAttr("selectItem", $("#data").H2GAttr("donationToID") || "");
            }

            if ($("#ddlITVDonationType option").length > 1) { $("#ddlITVDonationType").H2GValue($("#ddlITVDonationType").H2GAttr("selectItem")).change(); } else {
                $("#ddlITVDonationType").setAutoListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'donationtype' },
                    defaultSelect: $("#ddlITVDonationType").H2GAttr("selectItem"),
                    tempData: true,
                    selectItem: function () {
                        setDeferralData($("#ddlITVDonationType option:selected").H2GAttr("valueID"));
                    },
                });
            }
            if ($("#ddlITVBag option").length > 1) { $("#ddlITVBag").H2GValue($("#ddlITVBag").H2GAttr("selectItem")).change(); } else {
                $("#ddlITVBag").setAutoListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'bag' },
                    defaultSelect: $("#ddlITVBag").H2GAttr("selectItem"),
                    tempData: true,
                    selectItem: function () {
                        //setDeferralData($("#ddlITVDonationType option:selected").H2GAttr("valueID"));
                    },
                });
            }
            if ($("#ddlITVDonationTo option").length > 1) { $("#ddlITVDonationTo").H2GValue($("#ddlITVDonationTo").H2GAttr("selectItem")).change(); } else {
                $("#ddlITVDonationTo").setAutoListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'donationto' },
                    tempData: true,
                    defaultSelect: $("#ddlITVDonationTo").H2GAttr("selectItem"),
                });
            }
            
            $.ajax({
                url: '../../ajaxAction/masterAction.aspx',
                data: {
                    action: 'deferral',
                    gender: $("#rbtM").is(':checked') == true ? "M" : "F",
                },
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    if (!data.onError) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        $("#ddlITVDeferral").data("data-ddl",data.getItems)
                        setDeferralData($("#ddlITVDonationType").H2GAttr("selectItem"));
                    }
                }
            });

            $.ajax({
                url: '../../ajaxAction/masterAction.aspx',
                data: {
                    action: 'questionnaire',
                },
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    if (!data.onError) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        $("#tbQuestionnaire").data("data-questionnaire", data.getItems.QuestionItem)
                        $("#tbQuestionnaire").data("data-answer", data.getItems.AnswerItem)
                        // initial question
                        if ($("#tbQuestionnaire > tbody > tr").length == 0) {
                            genQuestion('3');
                        }
                    }
                }
            });
            
            $("#txtDefCode").enterKey(function () {
                $("#ddlITVDeferral").combobox("setvalue", $("#txtDefCode").H2GValue().toUpperCase()).change();
                if ($("#ddlITVDeferral").H2GValue() == null) {
                    $("#txtDuration").H2GValue("");
                    $("#txtDefDateTo").H2GValue("");
                    $("#ddlDeferralType").H2GValue("DEFINITIVE");
                    $("#txtDefRemarks").H2GValue("");
                } else {
                    $("#txtDefCode").H2GValue($("#ddlITVDeferral").H2GValue());
                    $("#ddlDeferralType").H2GValue($("#ddlITVDeferral option:selected").H2GAttr("deferralType")).change()
                    var duration = $("#ddlITVDeferral option:selected").H2GAttr("duration");
                    $("#txtDuration").H2GValue(duration);

                    if (duration == "") { $("#txtDefDateTo").H2GValue("31/12/2899"); }
                    else { $("#txtDefDateTo").H2GValue(H2G.addDays(H2G.today(), duration)); }
                }
            });
            $("#txtDefRemarks").enterKey(function () {
                addDeferral();
            });
            $("#spAddDeferral").click(function () { $(this).addDeferral(); });

        }
        function getExamination(examCode, questID) {
            if (examCode != "") {
                questID = questID || "";
                var dataView = $("#tbExam > tbody");
                if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
                    $(dataView).closest("table").H2GAttr("wStatus", "working");
                    $.ajax({
                        url: "../ajaxAction/qualityAction.aspx",
                        data: H2G.ajaxData({
                            action: 'getexamination',
                            excode: examCode,
                        }).config,
                        type: "POST",
                        dataType: "json",
                        error: function (xhr, s, err) {
                            console.log(s, err);
                            $(dataView).closest("table").H2GAttr("wStatus", "error");
                        },
                        success: function (data) {
                            var notiReject = "";
                            var notiInject = "";
                            if (!data.onError) {
                                data.getItems = jQuery.parseJSON(data.getItems);
                                $.each((data.getItems), function (index, e) {
                                    if ($("#tbExam > tbody > tr.template-data[examCode='" + e.Code + "']").length > 0) {
                                        // 1 ถ้า exam ที่เพิ่มเข้ามาซ้ำ และไม่มีกลุ่มจะไม่เพิ่มและแจ้งซ้ำ
                                        if (e.GroupID == null) {
                                            notiReject += e.Code + ", ";
                                        } else {
                                            // 2 ถ้า exam ที่เพิ่มเข้ามาซ้ำ แต่มีกลุ่มจะเพิ่มให้และลบตัวเก่าเสมอ
                                            notiInject += e.Code + ", ";
                                            $("#tbExam > tbody > tr.template-data[examCode='" + e.Code + "']").remove();
                                            var dataRow = $("#tbExam > thead > tr.template-data").clone().show();
                                            $(dataRow).H2GFill({
                                                examID: e.ID,
                                                examCode: e.Code,
                                                examDesc: e.Description,
                                                groupID: e.GroupID,
                                                groupCode: e.GroupCode,
                                                groupDesc: e.GroupDescription,
                                                questID: questID
                                            });
                                            $(dataRow).find('.td-exam').append(e.Code + ' : ' + e.Description).H2GAttr("title", e.Code + ' : ' + e.Description);
                                            if (questID != "") { $(dataRow).find('.glyphicon-remove').closest("a").hide(); }
                                            $(dataView).append(dataRow);
                                        }
                                    } else {
                                        var dataRow = $("#tbExam > thead > tr.template-data").clone().show();
                                        $(dataRow).H2GFill({
                                            examID: e.ID,
                                            examCode: e.Code,
                                            examDesc: e.Description,
                                            groupID: e.GroupID,
                                            groupCode: e.GroupCode,
                                            groupDesc: e.GroupDescription,
                                            questID: questID
                                        });
                                        $(dataRow).find('.td-exam').append(e.Code + ' : ' + e.Description).H2GAttr("title", e.Code + ' : ' + e.Description);
                                        if (questID != "") { $(dataRow).find('.glyphicon-remove').closest("a").hide(); }
                                        $(dataView).append(dataRow);
                                    }
                                });

                                $("#txtExamCode").H2GValue("");
                                $("#ddlExam").closest("div").find("input").H2GValue("");
                                if (notiReject != "") { notiWarning(notiReject.substring(0, notiReject.length - 2) + " มีการเพิ่มไปแล้ว") }
                                if (notiInject != "") { notiWarning(notiInject.substring(0, notiInject.length - 2) + " ถูกแทนที่ด้วยกลุ่ม " + data.getItems[0].GroupCode) }
                            } else {
                                $("#txtExamCode").focus();
                                notiError(data.exMessage);
                            }
                            $(dataView).closest("table").H2GAttr("wStatus", "done");
                        }
                    });    //End ajax
                } else {
                    setTimeout(function () { getExamination(examCode, questID); }, 1000);
                }
            } else {
                $("#txtExamCode").focus();
                notiWarning("กรุณากรอกหรือเลือก Examination");
            }
        }
        function deferralValidation() {
            if ($("#ddlITVDeferral").H2GValue() == null) {
                $("#txtDefCode").focus();
                notiWarning("กรุณากรอกเหตุผลที่งดบริจาคโลหิต");
                return false;
            } else if ($('#txtDefDateTo').H2GValue() == "") {
                $("#txtDefDateTo").focus();
                notiWarning("กรุณากรอกวันที่สิ้นสุด");
                return false;
            }
            return true;
        }
        function setDeferralData(donationTypeID) {
            var dataObj = [];
            var dataAll = $("#ddlITVDeferral").data("data-ddl");
            var create = 0;
            if (dataAll != undefined) {
                $.each((dataAll), function (index, e) {
                    if (donationTypeID == e.donationID) {
                        dataObj[create] = e;
                        create++;
                    }
                });
            }
            if ($("#ddlITVDeferral").next().length > 0) { $("#ddlITVDeferral").combobox("destroy"); }
            $("#ddlITVDeferral").setAutoListValue({
                dataObject: dataObj,
                selectItem: function () {
                    $("#txtDefCode").H2GValue($("#ddlITVDeferral").H2GValue());
                    $("#ddlDeferralType").H2GValue($("#ddlITVDeferral option:selected").H2GAttr("deferralType")).change()
                    var duration = $("#ddlITVDeferral option:selected").H2GAttr("duration");
                    $("#txtDuration").H2GValue(duration);

                    if (duration == "") { $("#txtDefDateTo").H2GValue("31/12/2899"); }
                    else { $("#txtDefDateTo").H2GValue(formatDate(H2G.addDays(H2G.today(), duration), "dd/MM/yyyy")); }
                    
                },
            });
        }
        function genQuestion(questID, fromQuestion) {
            var QID = questID || ""
            if (QID != "") {
                var QID = QID.split(",");
                var QuestData = $("#tbQuestionnaire").data("data-questionnaire")
                $.each((QuestData), function (indexr, er) {
                    $.each((QID), function (index, e) {
                        if (e == er.QuestionID) {
                            var dataRow = $("#tbQuestionnaire > thead > tr.template-data").clone().show();                     
                            $(dataRow).H2GFill({
                                questID: er.QuestionID,
                                questCode: er.Code,
                                questRequired: er.Required,
                                questAnswerType: er.AnswerType,
                                questPreset: er.Preset,
                                fromQuestion: fromQuestion,
                                questDesc: er.Description,
                                questDescTH: er.DescriptionTH,
                            });

                            if ($("#ddlQuestLanguage").H2GValue() == "English") { $(dataRow).find(".td-question span").H2GValue(er.Description); }
                            else { $(dataRow).find(".td-question span").H2GValue(er.DescriptionTH); }

                            if (er.AnswerType == "PRESET") {
                                var selectPreset = $(dataRow).find(".td-answer select").show();
                                var preset = er.Preset.split(",");
                                preset.sort();
                                $("<option>", { value: '', text: 'กรุณาเลือก' }).appendTo(selectPreset);
                                $.each((preset), function (indexs, es) {
                                    $("<option>", { value: es, text: es }).appendTo(selectPreset);
                                });
                                $(selectPreset).setAutoList({
                                    //ให้เอาคำตอบไปหาคำถามต่อไป
                                    selectItem: function () {
                                        selectNextQuestion($(this).closest("tr").H2GAttr("questID"), $(this).H2GValue());
                                    }
                                });
                                if (er.QuestionID == "60") {
                                    $(selectPreset).H2GValue("N");
                                }else if (er.QuestionID == "43"){
                                    $(selectPreset).H2GValue("WB");
                                }
                                //$(selectPreset).setDropdownList().H2GValue(e.Answer).change().on('change', function () {
                                //    //ให้เอาคำตอบไปหาคำถามต่อไป
                                //    selectNextQuestion($(this).closest("tr").H2GAttr("questID"), $(this).H2GValue());
                                //});
                            } else {
                                $(dataRow).find(".td-answer input").show();
                                if (er.AnswerType == "DATE") {
                                    $(dataRow).find(".td-answer input").setCalendar({
                                        maxDate: "+100y",
                                        minDate: "-100y",
                                        yearRange: "c-50:c+50",
                                    });
                                }
                            }
                            //$(dataRow).insertAfter($("#tbQuestionnaire > tbody > tr[questid=" + fromQuestion + "]"))
                            $("#tbQuestionnaire > tbody").append(dataRow);
                            return false;
                        }
                    });
                });
            }
        }
        function selectNextQuestion(questID, presetAnswer) {
            var AnswerData = $("#tbQuestionnaire").data("data-answer");
            deleteQuestion(questID);
            $.each((AnswerData), function (index, e) {
                if (e.QuestionID == questID && e.Code == presetAnswer) {
                    //ก่อนสร้างคำถามถัดไปให้ทำการลบคำถามเก่าก่อน
                    if (e.ToQuestID != "") {
                        genQuestion(e.ToQuestID, e.QuestionID);
                    }
                    if (e.DeferralID != "") {
                        // เพิ่ม deferral ตามคำตอบ
                        addDefByQuestion(e.DeferralID, e.QuestionID);
                    }
                    if (e.GroupExamID != "" || e.ExamID != "") {
                        // เพิ่ม Examination ตามคำตอบ
                        addExamByQuestion(e.GroupExamID + "," + e.ExamID, e.QuestionID);
                    }
                }
            });
        }
        function deleteQuestion(questID) {
            var questDelete = $("#tbQuestionnaire > tbody tr[fromQuestion=" + questID + "]");
            deleteDefByQuestion(questID);
            deleteExamByQuestion(questID);
            $.each((questDelete), function (index, e) {
                deleteQuestion($(e).H2GAttr("questID"));
                if ($(e).H2GAttr("refID") == "NEW") {
                    $(e).remove();
                } else {
                    $(e).hide().H2GAttr("refID", "D#" + $(e).H2GAttr("refID").replace('D#', ''));
                }
            });
        }
        function addDefByQuestion(defID, questID) {
            defID = defID || "";
            if (defID != "") {
                var dataAll = $("#ddlITVDeferral").data("data-ddl");
                defID = defID.split(",");
                if (dataAll != undefined) {
                    $.each((defID), function (index, e) {
                        $.each((dataAll), function (indexr, er) {
                            if (e == er.valueID) {
                                var duration = er.duration;
                                if (er.duration == "") { duration = "31/12/2899"; }
                                else { duration = formatDate(H2G.addDays(H2G.today(), duration), "dd/MM/yyyy"); }
                                
                                var dataRow = $("#tbDefInterview > thead > tr.template-data").clone().show();
                                $(dataRow).H2GFill({
                                    defID: er.valueID,
                                    defType: er.deferralType,
                                    defDuration: er.duration,
                                    defStartDate: $("#txtDefDateFrom").H2GValue(),
                                    defEndDate: duration,
                                    defRemarks: "Questionnaire",
                                    questID: questID,
                                });

                                $(dataRow).find('.td-description').append(er.desc).H2GAttr("title", er.desc);
                                $(dataRow).find('.td-enddate').append('วันที่สิ้นสุด ' + formatDate(new Date(getDateFromFormat(duration, 'dd/mm/yyyy')), "dd NNN yyyy")).H2GAttr("title", 'วันที่สิ้นสุด ' + formatDate(new Date(getDateFromFormat(duration, 'dd/mm/yyyy')), "dd NNN yyyy"));
                                $(dataRow).find('.glyphicon-remove').closest("a").hide();
                                $("#tbDefInterview > tbody").append(dataRow);
                                return false;
                            }
                        });
                    });

                }
            }         
        }
        function deleteDefByQuestion(questID) {
            var questDelete = $("#tbDefInterview > tbody tr[questID=" + questID + "]");
            $.each((questDelete), function (index, e) {
                if ($(e).H2GAttr("refID") == "NEW") {
                    $(e).remove();
                } else {
                    $(e).hide().H2GAttr("refID", "D#" + $(e).H2GAttr("refID").replace('D#', ''));
                }
            });
        }
        function addExamByQuestion(examID, questID) {
            examID = examID || "";
            if (examID != "") {
                examID = examID.split(",");
                $.each((examID), function (index, e) {
                    if (e != "") {
                        getExamination(e, questID);
                    }
                });
            }
        }
        function deleteExamByQuestion(questID) {
            var questDelete = $("#tbExam > tbody tr[questID=" + questID + "]");
            $.each((questDelete), function (index, e) {
                if ($(e).H2GAttr("refID") == "NEW") {
                    $(e).remove();
                } else {
                    $(e).hide().H2GAttr("refID", "D#" + $(e).H2GAttr("refID").replace('D#', ''));
                }
            });
        }
        function addExtCardMain(self) {
            if (checkMaxLength($(self))) {
                if (checkMinLength($(self))) {
                    if (checkNationOnlyNumber($(self))) {
                        $.ajax({
                            url: '../ajaxAction/donorAction.aspx', data: {
                                action: 'checkextcardnumber',
                                nation_number: $(self).H2GValue(),
                                external_id: $("#ddlExtCard").H2GValue(),
                                donor_external_id: $('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]').H2GAttr("refID")
                            }
                            , type: "POST", dataType: "json",
                            error: function (xhr, s, err) { console.log(s, err); },
                            success: function (data) {
                                if (!data.onError) {
                                    data.getItems = jQuery.parseJSON(data.getItems);
                                    if (data.getItems.name == "") {
                                        var extCard = $('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]');
                                        if (extCard.length > 0) {
                                            $(extCard).show().H2GFill({
                                                cardNumber: $(self).H2GValue(),
                                                refID: $(extCard).H2GAttr("refID").replace("D#", "")
                                            }).find(".ext-number").H2GValue($("#ddlExtCard :selected").text() + " : "
                                                + $(self).H2GValue()).H2GAttr("cardNumber", $(self).H2GValue());
                                        } else {
                                            var spExtCard = $("#divCardNumberTemp").children().clone();
                                            $(spExtCard).H2GFill({
                                                extID: $("#ddlExtCard").H2GValue(),
                                                cardNumber: $(self).H2GValue()
                                            }).find(".ext-number").H2GValue($("#ddlExtCard :selected").text() + " : " + $(self).H2GValue());
                                            $('#divCardNumber').append(spExtCard);
                                        }
                                        $(self).H2GValue('');
                                    } else {
                                        notiWarning(data.getItems.name);
                                        $(self).focus();
                                    }
                                } else { notiError(data.exMessage); }
                            }
                        });    //End ajax
                    } else {
                        notiWarning("เลขบัตรไม่ถูกต้องกรุณาตรวจสอบ");
                        $(self).focus();
                    }
                } else {
                    notiWarning("กรุณากรอกเลขบัตรอย่างน้อย " + $(self).H2GAttr("minlen") + " ตัวอักษร");
                    $(self).focus();
                }
            } else {
                notiWarning("กรุณากรอกเลขบัตรไม่เกิน " + $(self).H2GAttr("minlen") + " ตัวอักษร");
                $(self).focus();
            }
        }
        function setBagData(donationTypeID) {
            var dataObj = [];
            var dataAll = $("#ddlITVBag").data("data-ddl");
            var create = 0;
            if (dataAll != undefined) {
                $.each((dataAll), function (index, e) {
                    if (donationTypeID == e.donationID) {
                        dataObj[create] = e;
                        create++;
                    }
                });
            }
            if ($("#ddlITVDeferral").next().length > 0) { $("#ddlITVDeferral").combobox("destroy"); }
            $("#ddlITVDeferral").setAutoListValue({
                dataObject: dataObj,
                selectItem: function () {
                    $("#txtDefCode").H2GValue($("#ddlITVDeferral").H2GValue());
                    $("#ddlDeferralType").H2GValue($("#ddlITVDeferral option:selected").H2GAttr("deferralType")).change()
                    var duration = $("#ddlITVDeferral option:selected").H2GAttr("duration");
                    $("#txtDuration").H2GValue(duration);

                    if (duration == "") { $("#txtDefDateTo").H2GValue("31/12/2899"); }
                    else { $("#txtDefDateTo").H2GValue(formatDate(H2G.addDays(H2G.today(), duration), "dd/MM/yyyy")); }

                },
            });
        }
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
                <span id="spRegisNumber" visitID dPlanID dPointID siteID="1" visitFrom="HOSPITAL" queueNum dTypeID bagID dToID donateNumberExt="0" donateNumber="0" visitNumber="0" SampleNumber></span>
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
                <input id="txtCardNumber" type="text" class="form-control" tabindex="1" minlen="13" maxlen="13" />
            </div>
            <div class="col-md-2">
                <button id="spInsertExtCard" class="btn btn-icon" onclick="return false;" tabindex="-1">
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
                    <div class="col-md-12 text-right">
                        <label style="cursor: pointer; font-weight: normal; margin-bottom: 0px;">
                            <input id="chbLatinName" name="latinName" type="checkbox" tabindex="-1" onchange="return $(this).latinNameChange();" />Latin Name</label>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>Name</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorNameEng" type="text" class="form-control" tabindex="1" />
                    </div>
                    <div class="col-md-2 text-center">
                        <span>Surname</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorSurNameEng" type="text" class="form-control" tabindex="1" />
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
                    <select id="ddlDefferal" style="width:200px;">
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
                    <table id="tbDeferral" class="table table-hover table-striped table-deferal">
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
                <li><a href="#historyPane" style="">1) แฟ้มประวัติ</a></li>
                <li><a href="#todayPane" style="">2) 12 ก.ย. 2559</a></li>
                <li id="labPaneTab"><a href="#labPane" style="">3) ข้อมูล LAB</a></li>
                <li><a href="#ProductionPane" style="">4) ข้อมูล PRODUCTION</a></li>
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
                                                    <span class="glyphicon glyphicon-arrow-right" aria-hidden="true" onclick="return $(this).selectHistoryDonate();"></span>
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
                                <li><a href="#subHistoryPane" style="">2.1) ข้อมูลทั่วไป</a></li>
                                <li><a href="#synthesis" style="" id="synthesisLink">2.2) Synthesis</a></li>
                                <li><a href="#subInterview" style="">2.3) คัดกรอง</a></li>
                            </ul>
                            <div id="subHistoryPane">
                                <div class="border-box">
                                    <div class="col-md-18">
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="col-md-10">
                                                        รับบริจาคสำหรับหน่วยงาน
                                                    </div>
                                                    <div class="col-md-26">
                                                        <select id="ddlCollectionPoint" style="width: 398px;" placeholder="กรุณาเลือก" tabindex="3">
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
                                                        <span>ที่อยู่ปัจจุบัน</span>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">ที่อยู่</div>
                                                        <div class="col-md-28">
                                                            <textarea id="txtAddress" class="form-control" style="height:58px;resize: none;" tabindex="1">
                                                            </textarea>
                                                        </div>
                                                    </div>
                                                    <%--<div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">แขวง/ตำบล</div>
                                                        <div class="col-md-12">
                                                            <input id="txtSubDistrict" type="text" class="form-control required" tabindex="1" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">เขต/อำเภอ</div>
                                                        <div class="col-md-11">
                                                            <input id="txtDistrict" type="text" class="form-control required" tabindex="1" />
                                                        </div>
                                                    </div>--%>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">จังหวัด</div>
                                                        <div class="col-md-12">
                                                            <input id="txtProvince" type="text" class="form-control" tabindex="1" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">รหัสไปรษณีย์</div>
                                                        <div class="col-md-11">
                                                            <input id="txtZipcode" type="text" class="form-control" tabindex="1" onInput="checkLength()" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5"><span>ประเทศ</span></div>
                                                        <div class="col-md-12">
                                                            <select id="ddlCountry" class="required1" style="width: 185px;" placeholder="กรุณาเลือก" tabindex="1">
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
                                                            <input id="txtMobile1" type="text" class="form-control" maxlen="10" minlen="10" tabindex="2" />
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
                                                            <input id="txtMobile2" type="text" class="form-control" maxlen="10" minlen="10" tabindex="2" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์บ้าน</div>
                                                        <div class="col-md-12">
                                                            <input id="txtHomeTel" type="text" class="form-control" maxlen="10" minlen="10" tabindex="2" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์ที่ทำงาน</div>
                                                        <div class="col-md-12">
                                                            <input id="txtTel" type="text" class="form-control" maxlen="10" minlen="10" tabindex="2" />
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
                                                        <select id="ddlAssociation" class="required" style="width: 368px;" placeholder="กรุณาเลือก" tabindex="1">
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
                                                        <div class="col-md-12">
                                                            <input id="txtLastDonateDate" type="text" class="form-control text-center" tabindex="3" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-2">
                                                            ที่
                                                        </div>
                                                        <div class="col-md-32">
                                                            <select id="ddlExtAsso" style="width: 490px;" placeholder="กรุณาเลือก" tabindex="3">
                                                                <option value="0">Loading...</option>
                                                            </select>
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
                                                            <select id="ddlVisit" style="width:135px;">
                                                                <option value="แสดงทั้งหมด">แสดงทั้งหมด</option>
                                                                <option value="แสดงค้างรับ">แสดงค้างรับ</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row" style="margin-left: 15px;">
                                                        <div class="col-md-36">
                                                            <div id="divDonateRecord" style="overflow-x: hidden; overflow-y: scroll; height: 217px;" donateNumberExt="0" donateNumber="0" rewardList="">
                                                            </div>
                                                            <div id="divDonateRecordTemp" style="display:none;">
                                                                <div refID="NEW" class="row outpadding">
                                                                    <div class="col-md-33">
                                                                        <span class="rec-text"></span>
                                                                    </div>
                                                                    <div class="col-md-3 text-center">
                                                                        <a class="icon" style="display:none;"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="$(this).deleteDonateRecord();"></span></a>
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
                                                                <div class="col-md-12" style="padding-left: 8px; padding-right: 14px; padding-bottom: 2px;">
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
                            <div id="subInterview">
                                <div class="border-box">
                                    <div class="col-md-21 mandatory-interview">
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="row" style="border-top: solid 1px #CCCCCC; border-left: solid 1px #CCCCCC; border-right: solid 1px #CCCCCC; margin: 0; background-color:#DBEEF3;">
                                                    <div class="col-md-14 text-left" style="padding-left:5px;">
                                                        Questionnaire NBC
                                                    </div>
                                                    <div class="col-md-14 text-right">
                                                        
                                                    </div>
                                                    <div class="col-md-6 col-md-offset-1" style="padding-right: 5px; padding-left: 9px;">
                                                        <select id="ddlQuestLanguage" style="width:98px;">
                                                            <option value="English">English</option>
                                                            <option value="Thai">Thai</option>
                                                        </select>
                                                    </div>
                                                </div>
                                                <div class="border-box" style="padding:0; height:375px;overflow-y:scroll;overflow-x:hidden;">
                                                    <table id="tbQuestionnaire" class="table table-hover table-striped">
                                                        <thead style="display:none;">
                                                            <tr class="no-transaction" style="display: none;">
                                                                <td align="center" colspan="3">ไม่พบข้อมูล</td>
                                                            </tr>
                                                            <tr class="more-loading" style="display: none;">
                                                                <td align="center" colspan="3">Loading detail...</td>
                                                            </tr>
                                                            <tr class="template-data" style="display: none;" refID="NEW">
                                                                <td class="td-number col-md-1">
                                                                    <span></span>
                                                                </td>
                                                                <td class="td-question col-md-29">
                                                                    <span></span>
                                                                </td>
                                                                <td class="td-answer col-md-6">
                                                                    <input type="text" class="form-control" style="display:none;" />
                                                                    <select class="ddl-answer" style="display:none; width:98px;" placeholder="กรุณากรอก">
                                                                    </select>
                                                                </td>
                                                            </tr>
                                                        </thead>
                                                        <tbody>
                                                        </tbody>
                                                        <tfoot>
                                                            <tr>
                                                                <td colspan="3" style="border-top:solid 1px #cccccc;border-bottom:none;"></td>
                                                            </tr>
                                                        </tfoot>
                                                    </table>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-15 mandatory-interview">
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="row">
                                                        <div class="col-md-36">
                                                            <span style="font-weight:bold;">ตรวจสุขภาพเบื้องต้น</span>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-6 text-right">
                                                            <span>น้ำหนัก (kg)</span>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <input id="txtWeight" type="text" class="form-control required text-right" maxlength="3" />
                                                        </div>
                                                        <div class="col-md-2"></div>
                                                        <div class="col-md-4 text-center">
                                                            <span id="spLastWeight"></span>
                                                        </div>
                                                        <div class="col-md-9 text-center">
                                                            <span id="spLastDateWeight"></span>
                                                        </div>
                                                        <div class="col-md-6 text-right">
                                                            <span>อัตราชีพจร</span>
                                                        </div>
                                                        <div class="col-md-5 text-right">
                                                            <input id="txtHeartRate" type="text" class="form-control text-right text-uppercase" maxlength="3" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-6 text-right">
                                                            <span>ความดัน</span>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <input id="txtPresureMax" type="text" class="form-control required text-right" placeholder="สูงสุด" maxlength="3" />
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <span>/</span>
                                                        </div>
                                                        <div class="col-md-4">
                                                            <input id="txtPresureMin" type="text" class="form-control required text-right" placeholder="ต่ำสุด" maxlength="3" />
                                                        </div>
                                                        <div class="col-md-15 text-right">
                                                            <span>การตรวจหัวใจและปอด</span>
                                                        </div>
                                                        <div class="col-md-5 text-right">
                                                            <input id="txtHeartLung" type="text" class="form-control text-uppercase" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="row">
                                                        <div class="col-md-36">
                                                            <span style="font-weight:bold;">ตรวจความเข้มโลหิต</span>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-11 text-right">
                                                            <span>Hb Test</span>
                                                        </div>
                                                        <div class="col-md-6">
                                                            <select id="ddlHbTest" class="required text-center" style="width:75px;">
                                                                <option value="N">N</option>
                                                                <option value="P">P</option>
                                                                <option value="Y">Y</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <span>Hb</span>
                                                        </div>
                                                        <div class="col-md-6 text-right">
                                                            <input id="txtHb" type="text" class="form-control text-center required" maxlength="4" />
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <span>Plt</span>
                                                        </div>
                                                        <div class="col-md-6 text-right">
                                                            <input id="txtPlt" type="text" class="form-control" />
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="row">
                                                        <div class="col-md-36">
                                                            <span style="font-weight:bold;">ผลการตรวจคัดกรอง</span>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-16 col-md-offset-11">
                                                            <select id="ddlITVResult" class="required" style="width:200px;" placeholder="กรุณาเลือก">
                                                                <option value="">กรุณาเลือก</option>
                                                                <option value="DONATION">DONATION</option>
                                                                <option value="SAMPLE">SAMPLE</option>
                                                                <option value="REFUSED">REFUSED</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box">
                                                    <div class="row">
                                                        <div class="col-md-36">
                                                            <span style="font-weight:bold;">รายละเอียดการบริจาค</span>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-11 text-right">
                                                            <span>ประเภทการบริจาค</span>
                                                        </div>                                                        
                                                        <div class="col-md-25">
                                                            <select id="ddlITVDonationType" class="text-left required" style="width:318px;" placeholder="กรุณาเลือก">
                                                                <option value="0">Loading...</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-11 text-right">
                                                            <span>ประเภทถุง</span>
                                                        </div>                                                        
                                                        <div class="col-md-25">
                                                            <select id="ddlITVBag" class="text-left required" style="width:318px;" placeholder="กรุณาเลือก">
                                                                <option value="0">Loading...</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-11 text-right">
                                                            <span>การนำไปใช้งาน</span>
                                                        </div>                                                        
                                                        <div class="col-md-25">
                                                            <select id="ddlITVDonationTo" class="text-left required" style="width:318px;" placeholder="กรุณาเลือก">
                                                                <option value="0">Loading...</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    <div class="col-md-21">
                                        <div class="row">
                                            <div class="col-md-36">
                                                <div class="border-box" style="height:279px;">
                                                    <div class="row">
                                                        <div class="col-md-36">
                                                            <span style="font-weight:bold;">เหตุผลที่งดบริจาคโลหิต</span>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-5 col-md-offset-1"><input id="txtDefCode" type="text" class="form-control" /></div>
                                                        <div class="col-md-27">
                                                            <select id="ddlITVDeferral" class="text-left" style="width:484px;" tabindex="-1">
                                                                <option value="0">Loading...</option>
                                                            </select>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-5 col-md-offset-1">
                                                            <span>ประเภท</span>
                                                        </div>
                                                        <div class="col-md-11">
                                                            <select id="ddlDeferralType" style="width:198px;">
                                                                <option value="DEFINITIVE">DEFINITIVE</option>
                                                                <option value="UNDETERMINATED">UNDETERMINATED</option>
                                                                <option value="TEMPORARY">TEMPORARY</option>
                                                            </select>
                                                        </div>
                                                        <div class="col-md-5">
                                                            <span>ระยะเวลา(วัน)</span>
                                                        </div>
                                                        <div class="col-md-11">
                                                            <input id="txtDuration" type="text" class="form-control" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-5 col-md-offset-1">
                                                            <span>วันที่เริ่ม</span>
                                                        </div>
                                                        <div class="col-md-11">
                                                            <input id="txtDefDateFrom" type="text" class="form-control text-center" disabled />
                                                        </div>
                                                        <div class="col-md-5 text-center">
                                                            <span>วันที่สิ้นสุด</span>
                                                        </div>
                                                        <div class="col-md-11">
                                                            <input id="txtDefDateTo" type="text" class="form-control text-center" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-5 col-md-offset-1">
                                                            <span>หมายเหตุ</span>
                                                        </div>
                                                        <div class="col-md-27">
                                                            <input id="txtDefRemarks" type="text" class="form-control" />
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <button id="spAddDeferral" class="btn btn-icon" style="padding: 0;" onclick="return false;">
                                                                <i class="glyphicon glyphicon-circle-arrow-down" style="vertical-align: text-top;"></i>
                                                            </button>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-35 col-md-offset-1" style="height: 88px; overflow-y: scroll;">
                                                            <table id="tbDefInterview" class="table table-bordered table-striped" totalPage="1" 
                                                                currentPage="1" sortDirection="desc" sortOrder="queue_number">
                                                                <thead>
                                                                    <tr class="no-transaction" style="display:none;">
                                                                        <td class="col-md-34" align="center">ไม่มีข้อมูล</td>
                                                                        <td class="col-md-2"></td></tr>
                                                                    <tr class="more-loading" style="display:none;">
                                                                        <td class="col-md-34" align="center">Loading detail...</td>
                                                                        <td class="col-md-2"></td></tr>
                                                                    <tr class="template-data" style="display:none;" refID="NEW">
                                                                        <td class="col-md-23 td-description">
                                                                        </td>
                                                                        <td class="col-md-11 td-enddate">
                                                                        </td>
                                                                        <td class="col-md-2">
                                                                            <div class="text-center">
                                                                                <a class="icon">
                                                                                    <span class="glyphicon glyphicon-remove" aria-hidden="true" 
                                                                                        onclick="return $(this).deleteDeferral();"></span></a>
                                                                            </div>
                                                                        </td>
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
                                    <div class="col-md-15">
                                        <div class="border-box">
                                            <div class="row">
                                                <div class="col-md-35 col-md-offset-1" style="font-weight:bold;">LAB EXAMINATION</div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-7 col-md-offset-1"><input id="txtExamCode" type="text" class="form-control" /></div>
                                                <div class="col-md-26">
                                                    <select id="ddlExam" class="text-left" placeholder="" style="width:336px;" tabindex="-1">
                                                        <option value="0">Loading...</option>
                                                    </select>
                                                </div>
                                            </div>
                                            <div class="row">
                                                <div class="col-md-35 col-md-offset-1" style="height: 204px; overflow-y: scroll;">
                                                    <table id="tbExam" class="table table-bordered table-striped" totalPage="1" currentPage="1" 
                                                        sortDirection="desc" sortOrder="queue_number">
                                                        <thead>
                                                            <tr class="no-transaction" style="display:none;">
                                                                <td class="col-md-34" align="center">ไม่มีข้อมูล</td>
                                                                <td class="col-md-2"></td></tr>
                                                            <tr class="more-loading" style="display:none;">
                                                                <td class="col-md-34" align="center">Loading detail...</td>
                                                                <td class="col-md-2"></td></tr>
                                                            <tr class="template-data" style="display:none;" refID="NEW">
                                                                <td class="col-md-34 td-exam">
                                                                </td>
                                                                <td class="col-md-2">
                                                                    <div class="text-center">
                                                                        <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" 
                                                                            onclick="return $(this).deleteExam();"></span></a>
                                                                    </div>
                                                                </td>
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
                                                    <thead style="color:gray">
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-12" colspan="6">บริจาคครั้งแรกเมื่อ <span class="firstDonateWhen"></span> ที่ <span class="firstDonateAt"></span></th>
                                                            <th class="col-md-2" colspan="1">Pheno</th>
                                                            <th class="col-md-22" colspan="16" style="text-align:left;"><span class="phenoValue">C+E+</span></th>
                                                        </tr>
                                                        <tr style="font-size: 16px; height:28px;">
                                                            <th class="col-md-12" colspan="6">บริจาคครั้งสุดท้ายเมื่อ <span class="lastDonateWhen"></span> ที่ <span class="lastDonateAt"></span></th>
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
                                                            <th class="col-md-2">Lipemic</th>
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
                                                    <thead style="color:gray">
                                                        <tr style="font-size: 14px; height:28px;">
                                                            <th style="width:25%" colspan="6">บริจาคครั้งแรกเมื่อ <span class="firstDonateWhen"></span> ที่ <span class="firstDonateAt"></span></th>
                                                            <th style="width:3.7%" colspan="1">Pheno</th>
                                                            <th style="width:59.5%; text-align:left;" colspan="16"><span class="phenoValue">C+E+</span></th>
                                                        </tr>
                                                        <tr style="font-size: 14px; height:28px;">
                                                            <th style="width:25%" colspan="6">บริจาคครั้งสุดท้ายเมื่อ <span class="lastDonateWhen"></span> ที่ <span class="lastDonateAt"></span></th>
                                                            <th style="width:3.7%; font-size:10px;"><span class="ABOD">ABO group</span></th>
                                                            <th style="width:3.7%; font-size:10px;"><span class="ABOD2">ABO group</span></th>
                                                            <th style="width:3.7%"><span class="ABO_group_val">O</span></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                        </tr>
                                                        <tr style="font-size: 14px; height:28px;">
                                                            <th style="width:3.7%">วันที่</th>
                                                            <th style="width:3.7%">ประเภท</th>
                                                            <th style="width:3.7%">บริจาคที่</th>
                                                            <th style="width:5.1%">เหตุผลงดบริจาค</th>
                                                            <th style="width:3.7%">ครั้งที่</th>
                                                            <th style="width:3.7%">ความดัน</th>
                                                            <th style="width:3.7%">ALAT</th>
                                                            <th style="width:3.7%">WB</th>
                                                            <th style="width:3.7%">Anti-HCV</th>
                                                            <th style="width:3.7%">Malaria</th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                            <th style="width:3.7%"> &nbsp; &nbsp; &nbsp; &nbsp; </th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>

                                                    </tbody>
                                                </table>

                                                <table class="table table-bordered-excel" id="synthesisImmunohematology" style="display:none;">
                                                    <thead style="color:gray">
                                                        <tr style="font-size: 14px; height:28px;">
                                                            <th style="width:25%" colspan="6">บริจาคครั้งแรกเมื่อ <span class="firstDonateWhen"></span> ที่ <span class="firstDonateAt"></span></th>
                                                            <th style="width:3.7%" colspan="1">Pheno</th>
                                                            <th style="width:59.5%; text-align:left;" colspan="16"><span class="phenoValue">C+E+</span></th>
                                                        </tr>
                                                        <tr style="font-size: 14px; height:28px;">
                                                            <th style="width:25%" colspan="6">บริจาคครั้งสุดท้ายเมื่อ <span class="lastDonateWhen"></span> ที่ <span class="lastDonateAt"></span></th>
                                                            <th style="width:3.7%"><span class="ABOD">AB</span></th>
                                                            <th style="width:3.7%"><span class="zx">AB</span></th>
                                                            <th style="width:3.7%"><span class="ddf">+</span></th>
                                                            <th style="width:3.7%"><span class="po"></span></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                        </tr>
                                                        <tr style="font-size: 14px; height:28px;">
                                                            <th style="width:3.7%">วันที่</th>
                                                            <th style="width:3.7%">ประเภท</th>
                                                            <th style="width:3.7%">บริจาคที่</th>
                                                            <th style="width:5.1%">เหตุผลงดบริจาค</th>
                                                            <th style="width:3.7%">ครั้งที่</th>
                                                            <th style="width:3.7%">ความดัน</th>
                                                            <th style="width:3.7%">ABO group</th>
                                                            <th style="width:3.7%">ABO group</th>
                                                            <th style="width:3.7%">C</th>
                                                            <th style="width:3.7%">c</th>
                                                            <th style="width:3.7%">E</th>
                                                            <th style="width:3.7%">e</th>
                                                            <th style="width:3.7%">K</th>
                                                            <th style="width:3.7%">Ab Sc</th>
                                                            <th style="width:3.7%">H-AB</th>
                                                            <th style="width:3.7%">Hem A</th>
                                                            <th style="width:3.7%">Hb</th>
                                                            <th style="width:3.7%">BW</th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
                                                            <th style="width:3.7%"></th>
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
                            <li><a href="#historicalFile" style="">3.1) Historical File</a></li>
                            <li><a href="#immunohaemtologyFile" id="immunohaemtology-tab" style="">3.2) Immunohematology File</a></li>
                            <li><a href="#exams" id="exams-tab" style="">3.3) Exams</a></li>
                        </ul>
                        <div id="historicalFile">
                            <div class="border-box">
                                <div class="col-md-36">
                                    <table class="table table-bordered-excel tablesorter" id="historicalFileTable">
                                        <thead style="color:gray">
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
                                <div class="col-md-36" style="border:1px solid #ccc">
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
                                    <label class="set-label set-label-font" style="color:#000000">&nbsp;&nbsp;Antigens</label>
                                    <table class="col-md-36" id="label-set-2">
                                        <tr>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Rh_AG">Rh</label><input type="text" class="col-md-34 long-label4" id="Rh_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_C_AG">Ag C</label><input type="text" class="col-md-34 long-label4" id="Ag_C_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_c_AG">Ag c</label><input type="text" class="col-md-34 long-label4" id="Ag_c_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_E_AG">Ag E</label><input type="text" class="col-md-34 long-label4" id="Ag_E_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_e_AG">Ag e</label><input type="text" class="col-md-34 long-label4" id="Ag_e_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_K_AG">Ag K</label><input type="text" class="col-md-34 long-label4" id="Ag_K_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Mia_AG">Ag Mia</label><input type="text" class="col-md-34 long-label4" id="Ag_Mia_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Mur_AG">Ag Mur</label><input type="text" class="col-md-34 long-label4" id="Ag_Mur_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Dia_AG">Ag Dia</label><input type="text" class="col-md-34 long-label4" id="Ag_Dia_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Dib_AG">Ag Dib</label><input type="text" class="col-md-34 long-label4" id="Ag_Dib_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Xga_AG">Ag Xga</label><input type="text" class="col-md-34 long-label4" id="Ag_Xga_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Tja_AG">Ag Tja</label><input type="text" class="col-md-34 long-label4" id="Ag_Tja_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Jsa_AG">Ag Jsa</label><input type="text" class="col-md-34 long-label4" id="Ag_Jsa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Jsb_AG">Ag Jsb</label><input type="text" class="col-md-34 long-label4" id="Ag_Jsb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Lwa_AG">Ag Lwa</label><input type="text" class="col-md-34 long-label4" id="Ag_Lwa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_U_AG">Ag U</label><input type="text" class="col-md-34 long-label4" id="Ag_U_AG" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Fya_AG">Fya</label><input type="text" class="col-md-34 long-label4" id="Fya_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Fyb_AG">Fyb</label><input type="text" class="col-md-34 long-label4" id="Fyb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Jka_AG">Jka</label><input type="text" class="col-md-34 long-label4" id="Jka_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Jkb_AG">Jkb</label><input type="text" class="col-md-34 long-label4" id="Jkb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="M_AG">M</label><input type="text" class="col-md-34 long-label4" id="M_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="N_AG">N</label><input type="text" class="col-md-34 long-label4" id="N_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="S_AG">S</label><input type="text" class="col-md-34 long-label4" id="S_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="s_AG">s</label><input type="text" class="col-md-34 long-label4" id="s_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Lea_AG">Lea</label><input type="text" class="col-md-34 long-label4" id="Lea_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Leb_AG">Leb</label><input type="text" class="col-md-34 long-label4" id="Leb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Anti-Vel_AG">Anti-Vel</label><input type="text" class="col-md-34 long-label4" id="Anti-Vel_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Doa_AG">Ag Doa</label><input type="text" class="col-md-34 long-label4" id="Ag_Doa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Dob_AG">Ag Dob</label><input type="text" class="col-md-34 long-label4" id="Ag_Dob_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Coa_AG">Ag Coa</label><input type="text" class="col-md-34 long-label4" id="Ag_Coa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_Cob_AG">Ag Cob</label><input type="text" class="col-md-34 long-label4" id="Ag_Cob_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Mga_AG">Mga</label><input type="text" class="col-md-34 long-label4" id="Mga_AG" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Cw_AG">Cw</label><input type="text" class="col-md-34 long-label4" id="Cw_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Lua_AG">Lua</label><input type="text" class="col-md-34 long-label4" id="Lua_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Lub_AG">Lub</label><input type="text" class="col-md-34 long-label4" id="Lub_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Kpa_AG">Kpa</label><input type="text" class="col-md-34 long-label4" id="Kpa_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Kpb_AG">Kpb</label><input type="text" class="col-md-34 long-label4" id="Kpb_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="P1_AG">P1</label><input type="text" class="col-md-34 long-label4" id="P1_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="k_AG">k</label><input type="text" class="col-md-34 long-label4" id="k_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Ag_H_AG">Ag H</label><input type="text" class="col-md-34 long-label4" id="Ag_H_AG" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="41">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="41" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="42">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="42" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="43">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="43" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="44">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="44" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="45">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="45" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="46">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="46" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="47">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="47" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="48">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="48" value="" /></td>
                                        </tr>
                                    </table>
                                    <br />
                                    <label class="set-label set-label-font">&nbsp;&nbsp;Antibodies</label>
                                    <table class="col-md-36" id="label-set-3">
                                        <tr>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="D_A1">D</label><input type="text" class="col-md-34 long-label4" id="D_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="C_A1">C</label><input type="text" class="col-md-34 long-label4" id="C_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="c_A1">c</label><input type="text" class="col-md-34 long-label4" id="c_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="E_A1">E</label><input type="text" class="col-md-34 long-label4" id="E_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="e_A1">e</label><input type="text" class="col-md-34 long-label4" id="e_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="K_A1">K</label><input type="text" class="col-md-34 long-label4" id="K_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="55">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="55" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="56">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="56" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="57">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="57" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="58">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="58" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="59">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="59" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="60">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="60" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="61">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="61" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="62">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="62" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="63">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="63" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="64">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="64" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Fya_A1">Fya</label><input type="text" class="col-md-34 long-label4" id="Fya_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Fyb_A1">Fyb</label><input type="text" class="col-md-34 long-label4" id="Fyb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Jka_A1">Jka</label><input type="text" class="col-md-34 long-label4" id="Jka_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Jkb_A1">Jkb</label><input type="text" class="col-md-34 long-label4" id="Jkb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="M_A1">M</label><input type="text" class="col-md-34 long-label4" id="M_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="N_A1">N</label><input type="text" class="col-md-34 long-label4" id="N_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="S_A1">S</label><input type="text" class="col-md-34 long-label4" id="S_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="s_A1">s</label><input type="text" class="col-md-34 long-label4" id="s_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Lea_A1">Lea</label><input type="text" class="col-md-34 long-label4" id="Lea_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Leb_A1">Leb</label><input type="text" class="col-md-34 long-label4" id="Leb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Jsa_A1">Jsa</label><input type="text" class="col-md-34 long-label4" id="Jsa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Jsb_A1">Jsb</label><input type="text" class="col-md-34 long-label4" id="Jsa_A2" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Lwa_A1">Lwa</label><input type="text" class="col-md-34 long-label4" id="Lwa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="U_A1">U</label><input type="text" class="col-md-34 long-label4" id="U_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Pk_A1">Pk</label><input type="text" class="col-md-34 long-label4" id="Pk_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Mia_A1">Mia</label><input type="text" class="col-md-34 long-label4" id="Mia_A1" value="" /></td>
                                        </tr>
                                        <tr>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Cw_A1">Cw</label><input type="text" class="col-md-34 long-label4" id="Cw_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Lua_A1">Lua</label><input type="text" class="col-md-34 long-label4" id="Lua_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Lub_A1">Lub</label><input type="text" class="col-md-34 long-label4" id="Lub_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Kpa_A1">Kpa</label><input type="text" class="col-md-34 long-label4" id="Kpa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Kpb_A1">Kpb</label><input type="text" class="col-md-34 long-label4" id="Kpb_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="P1_A1">P1</label><input type="text" class="col-md-34 long-label4" id="P1_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="k_A1">k</label><input type="text" class="col-md-34 long-label4" id="k_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Vel_A1">Vel</label><input type="text" class="col-md-34 long-label4" id="Vel_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="TJA_A1">TJA</label><input type="text" class="col-md-34 long-label4" id="TJA_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Doa_A1">Doa</label><input type="text" class="col-md-34 long-label4" id="Doa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Dob_A1">Dob</label><input type="text" class="col-md-34 long-label4" id="Dob_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Coa_A1">Coa</label><input type="text" class="col-md-34 long-label4" id="Coa_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Cob_A1">Cob</label><input type="text" class="col-md-34 long-label4" id="Cob_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="H_A1">H</label><input type="text" class="col-md-34 long-label4" id="H_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="Mga_A1">Mga</label><input type="text" class="col-md-34 long-label4" id="Mga_A1" value="" /></td>
                                            <td class="col-md-2"><label class="set-label set-label-font" for="78">&nbsp;</label><input type="text" class="col-md-34 long-label4" id="78" value="" /></td>
                                        </tr>
                                    </table>
                                    <br />
                                    <label class="set-label set-label-font">&nbsp;&nbsp;HLA</label>
                                    <table class="col-md-36" id="label-set-4" style="margin-bottom:10px;">
                                        <tr>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="HLA-Ax_RESULT">HLA-Ax</label><input type="text" class="col-md-35 long-label2" id="HLA-Ax_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="HLA-Ay_RESULT">HLA-Ay</label><input type="text" class="col-md-35 long-label2" id="HLA-Ay_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="HLA-Bx_RESULT">HLA-Bx</label><input type="text" class="col-md-35 long-label2" id="HLA-Bx_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="HLA-By_RESULT">HLA-By</label><input type="text" class="col-md-35 long-label2" id="HLA-By_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="HLA-DRB1x_RESULT">HLA-DRB1x</label><input type="text" class="col-md-35 long-label2" id="HLA-DRB1x_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="HLA-DRB1y_RESULT">HLA-DRB1y</label><input type="text" class="col-md-35 long-label2" id="HLA-DRB1y_RESULT" value="" /></td>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="xx">&nbsp;</label><input type="text" class="col-md-35 long-label2" id="xx" value="" /></td>
                                            <td class="col-md-4"><label class="set-label set-label-font" for="xyx">&nbsp;</label><input type="text" class="col-md-35 long-label2" id="xyx" value="" /></td>
                                        </tr>
                                    </table>
                                    <br />
                                </div>
                            </div>
                            
                        </div>
                        <div id="exams">
                            <div class="border-box">
                                <div class="col-md-36" style="color:gray; padding-right:2px;">
                                    <div class="border-box" style="text-align:center; background-color: #F2F2F2; height:28px; padding:0px;"><b>Donation examinations</b></div>
                                </div>
                                <div class="col-md-36">
                                    <table class="table table-bordered-excel tablesorter" id="exams-tab-table">
                                        <thead style="color:gray">
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
                    <button id="spAddComment" class="btn btn-icon" onclick="return false;" tabindex="-1">
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
            <input id="btnSaveOnlyDonor" type="button" class="btn btn-success btn-block" value="บันทึก" tabindex="-1" />
        </div>
        <div class="col-md-19"></div>
        <div class="col-md-3">
            <input id="btnCancel" type="button" class="btn btn-block" value="ย้อนกลับ" tabindex="-1" style="display:none;" />
        </div>
        <div class="col-md-5">
            <input id="btnSave" type="button" class="btn btn-success btn-block" value="บันทึกและกลับสู่เมนูหลัก" tabindex="1" />
        </div>
    </div>
    <div style="display: none;">
    <input id="data" runat="server" /></div>
    <div id="divBarcodeContainer" style="display:none;">
        <div id="divBarcodeTemplete" style="display: inline-block;">
            <div class="newouterborder" style="background-color: #F4F4F4;">
                <div class="popheader row" style="padding: 5px 0px;">
                    <div class="popupheader col-md-36">ทำการสแกนบาร์โค้ด</div>
                </div>
                <div class="popupbody" style="width:300px;">
                    <div class="row">
                        <div class="col-md-10"><span>รหัสผู้บริจาค</span></div>
                        <div class="col-md-26"><input id="txtScanDonorNumber" type="text" class="form-control required" maxlength="10" /></div>
                    </div>
                    <div class="row">
                        <div class="col-md-10"><span>Sample No</span></div>
                        <div class="col-md-26"><input id="txtScanSampleNumber" type="text" class="form-control required" maxlength="11" /></div>
                    </div>
                    <div class="row">
                        <div class="col-md-6 col-md-offset-24 text-right">
                            <input type="button" value="ตกลง" class="btn btn-block btn-success" onclick="return checkKeySample($('#txtScanSampleNumber'));" onkeypress="$(this).enterKey( checkKeySample($('#txtScanSampleNumber')) );" />
                        </div>
                        <div class="col-md-6 text-right">
                            <input type="button" value="ยกเลิก" class="btn btn-block" onclick="$('#btnSave').prop('disabled', false); return closePopup();" />
                        </div>
                    </div>
                </div>
                <div class="popfooter" style="text-align: right;">
                </div>
            </div>
        </div>
    </div>
    <div id="divAgeContainer" style="display:none;">
            <div id="divAgeTemplete" style="display: inline-block;">
                <div class="newouterborder" style="background-color: #F4F4F4;">
                    <div class="popheader row text-left" style="padding: 5px 0px;">
                        <div id="popupheader" class="popupheader col-md-36">กรุณาตรวจสอบ</div>
                    </div>
                    <div class="popupbody text-left" style="width:300px;">
                        <div class="row">
                            <div class="col-md-36"><span id="spAgeWarning"></span></div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 col-md-offset-24 text-right">
                                <input type="button" value="ตกลง" class="btn btn-block btn-success" onclick="return preSaveDonor();" />
                            </div>
                            <div class="col-md-6 text-right">
                                <input type="button" value="ยกเลิก" class="btn btn-block" onclick="$('#btnSave').prop('disabled', false); return closePopup();" />
                            </div>
                        </div>
                    </div>
                    <div class="popfooter" style="text-align: right;">
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
