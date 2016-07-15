<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="register.aspx.vb" Inherits="Claret.donor_register" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .table-deferal > tbody > tr > td {
            border-bottom: 0;
        }
    </style>
    <script>
        $(function () {
            $("#txtCardNumber").enterKey(function () { $(this).addExtCard(); }).focus();
            $("#txtDonorName").H2GNamebox();
            $("#txtDonorSurName").H2GNamebox();
            $("#txtDonorNameEng").H2GNamebox();
            $("#txtDonorSurNameEng").H2GNamebox();
            $("#ddlDefferal").setDropdowList().on('change', function () {
                if ($(this).H2GValue() == 'ACTIVE') { $("#tbDefferal > thead > tr[status=INACTIVE]").hide(); } else { $("#tbDefferal > thead > tr[status=INACTIVE]").show(); }
            });
            $("#ddlVisit").setDropdowList();
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
            $("#togDeferal").toggleSlide();
            $("#togVisitInfo").toggleSlide();
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
            $("#txtStmRegisDate").setCalendar().H2GDatebox();
            $("#txtOuterDonate").H2GNumberbox();
            $("#txtMobile1").H2GPhonebox();
            $("#txtMobile2").H2GPhonebox();
            $("#txtHomeTel").H2GPhonebox();
            $("#txtTel").H2GPhonebox();
            $("#txtTelExt").H2GPhonebox();
            $("#txtLastDonateDate").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    if (selectedDate != '') { $(this).H2GAttr('donatedatetext', formatDate($(this).datepicker("getDate"),"dd MMM yyyy")); } else { $(this).H2GAttr('donatedatetext', ''); }
                    $("#spAddDonateRecord").focus();
                },
                onClose: function () {
                    enterDatePicker($("#txtLastDonateDate"), "close");
                },
                onEnterKey: function () {
                    enterDatePicker($("#txtLastDonateDate"), "enter");
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
                    console.log("selectItem");
                    var cardNumber = $('#divCardNumber div[extID="' + $("#ddlExtCard").H2GValue() + '"]').H2GAttr('cardNumber');
                    $("#txtCardNumber").H2GValue(cardNumber || '');
                },
                //closeItem: function () { console.log("closeItem"); $("#txtCardNumber").focus(); },
            }, "3");
            $("#ddlExtCard").on('autocompleteselect', function () {
                console.log($(this).H2GValue());
                console.log($('#divCardNumber div[extID="' + $(this).H2GValue() + '"]').H2GAttr('cardNumber'));
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
            if ($("#data").H2GAttr("donorID") != undefined) {
                if ($("#data").H2GAttr("visitID") != undefined) { $("#spRegisNumber").H2GAttr("visitID", $("#data").H2GAttr("visitID")); }
                showDonorData();
            } else {
                $("#txtDonorName").H2GValue($("#data").H2GAttr("donorName") || "");
                $("#txtDonorSurName").H2GValue($("#data").H2GAttr("donorSurname") || "");
                $("#txtBirthDay").H2GValue($("#data").H2GAttr("birthday") || "");
                $("#txtAge").H2GValue(H2G.calAge($("#data").H2GAttr("birthday") || "") + ' ปี');
                $("#spVisitInfo").H2GValue("วันที่ลงทะเบียน " + formatDate(H2G.today(), "dd NNN yyyy HH:mm") + " เข้าพบครั้งแรก กำลังดำเนินการบริจาคครั้งที่ 1").H2GFill({ visitDateText: formatDate(H2G.today(), "dd NNN yyyy HH:mm"), lastVisitDateText: "", currentDonateNumber: "1" });
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

            $("#labPaneTab").click(setHistoricalFileDatas);
            $("#exams-tab").click(setExamsDatas);
            $("#immunohaemtology-tab").click(setImmunohaemtologyFile);
            
            //### extend
        });

        function donorSelectDDL() {
            if ($("#ddlTitleName option").length > 1) { $("#ddlTitleName").H2GValue($("#ddlTitleName").H2GAttr("selectItem")).change(); } else {
                $("#ddlTitleName").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'titlename', gender: $("#rbtM").is(':checked') == true ? "M" : "F" } }, $("#ddlTitleName").H2GAttr("selectItem")).on('autocompleteselect', function () {
                    $("#txtDonorName").focus();
                });
            }
            if ($("#ddlCountry option").length > 1) { $("#ddlCountry").H2GValue($("#ddlCountry").H2GAttr("selectItem")).change(); } else {
                $("#ddlCountry").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'country' } }, $("#ddlCountry").H2GAttr("selectItem") || "64").on('autocompleteselect', function () {
                    $("#txtMobile1").focus();
                });
            }
            if ($("#ddlOccupation option").length > 1) { $("#ddlOccupation").H2GValue($("#ddlOccupation").H2GAttr("selectItem")).change(); } else {
                $("#ddlOccupation").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'occupation' } }, $("#ddlOccupation").H2GAttr("selectItem")).on('autocompleteselect', function () {
                    $("#ddlNationality").closest("div").focus();
                });
            }
            if ($("#ddlNationality option").length > 1) { $("#ddlNationality").H2GValue($("#ddlNationality").H2GAttr("selectItem")).change(); } else {
                $("#ddlNationality").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'nationality' } }, $("#ddlNationality").H2GAttr("selectItem") || "1").on('autocompleteselect', function () {
                    $("#ddlRace").closest("div").focus();
                });
            }
            if ($("#ddlRace option").length > 1) { $("#ddlRace").H2GValue($("#ddlRace").H2GAttr("selectItem")).change(); } else {
                $("#ddlRace").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'nationality' } }, $("#ddlRace").H2GAttr("selectItem") || "1").on('autocompleteselect', function () {
                    $("#txtAddress").focus();
                });
            }
            if ($("#ddlAssociation option").length > 1) { $("#ddlAssociation").H2GValue($("#ddlAssociation").H2GAttr("selectItem")).change(); } else {
                $("#ddlAssociation").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'association' } }, $("#ddlAssociation").H2GAttr("selectItem")).on('autocompleteselect', function () {
                    $("#txtOuterDonate").focus();
                });
            }
            $("#txtCardNumber").focus();
            
        }
        function saveDonorInfo() {
            $("#btnSave").prop("disabled", true);
            if (validation()) {
                var MasterDonor = {
                    ID: $("#spRegisNumber").H2GAttr("donorID"),
                    DonorNumber: $("#spRegisNumber").H2GValue(),
                    Gender: $("#rbtM").is(':checked') == true ? "M" : "F",
                    Name: $("#txtDonorName").H2GValue(),
                    Surname: $("#txtDonorSurName").H2GValue(),
                    NameE: $("#txtDonorNameEng").H2GValue(),
                    SurnameE: $("#txtDonorSurNameEng").H2GValue(),
                    Birthday: $("#txtBirthDay").H2GValue(),
                    TitleID: $("#ddlTitleName").H2GValue(),
                    Address: $("#txtAddress").H2GValue(),
                    SubDistrict: $("#txtSubDistrict").H2GValue(),
                    District: $("#txtDistrict").H2GValue(),
                    Province: $("#txtProvince").H2GValue(),
                    Zipcode: $("#txtZipcode").H2GValue(),
                    CountryID: $("#ddlCountry").H2GValue(),
                    OccupationID: $("#ddlOccupation").H2GValue(),
                    NationalityID: $("#ddlNationality").H2GValue(),
                    RaceID: $("#ddlRace").H2GValue(),
                    Mobile1: $("#txtMobile1").H2GValue(),
                    Mobile2: $("#txtMobile2").H2GValue(),
                    HomeTel: $("#txtHomeTel").H2GValue(),
                    OfficeTel: $("#txtTel").H2GValue(),
                    OfficeTelExt: $("#txtTelExt").H2GValue(),
                    Email: $("#txtEmail").H2GValue(),
                    AssociationID: $("#ddlAssociation").H2GValue(),
                    DonateNumberExt: $("#spRegisNumber").H2GAttr("donateNumberExt"),
                    VisitNumber: $("#spRegisNumber").H2GAttr("visitNumber"),

        //Public VisitNumber As String

                };
                var DonorVisit = {
                    ID: $("#spRegisNumber").H2GAttr("visitID"),
                    DonorID: $("#spRegisNumber").H2GAttr("donorID"),
                    QueueNumber: $("#spRegisNumber").H2GAttr("queueNum"),
                    VisitFrom: $("#spRegisNumber").H2GAttr("visitFrom"),
                    DonationTypeID: $("#spRegisNumber").H2GAttr("dTypeID"),
                    BagID: $("#spRegisNumber").H2GAttr("bagID"),
                    DonationToID: $("#spRegisNumber").H2GAttr("dToID"),
                    CollectionPlanID: $("#spRegisNumber").H2GAttr("cPlanID"),
                    CollectionPointID: $("#spRegisNumber").H2GAttr("dPointID"),
                    SiteID: $("#spRegisNumber").H2GAttr("siteID"),
                    VisitNumber: $("#spRegisNumber").H2GAttr("visitNumber"),
                    Status: $("#spStatus").H2GValue(),
                    //RefuseDefferalID: '',
                    //Comment: '',
                    //SanpleNumber: '',
                    //Weight: '',
                    //PressureMax: '',
                    //PressureMin: '',
                    //HB: '',
                    //PLT: '',
                    //HBTest: '',
                    //HeartLung: '',
                    //HospitalID: '',
                    //DepartmentID: '',
                    //ExtSampleNumber: '',
                    //ExtComment: '',
                    //Volume: '',
                    //VolumeActual: '',
                    //DonationTime: '',
                    //Duration: '',
                    //CollectionDate: '',
                    //CollectionStaff: '',
                    //RefuseReasonID1: '',
                    //RefuseReasonID2: '',
                    //RefuseReasonID3: '',
                    //PurgeDate: '',
                    //PurgeStaff: '',
                };
                var DonorComment = {
                    ID:'',
                    DornerID: '',
                    StartDate:'',
                    EndDate: '',
                    Description:'',
                };
                var DonorExtCard = [];
                var create = 0;
                $('#divCardNumber .row').each(function (i, e) {
                    DonorExtCard[create] = {
                        ID: $(e).H2GAttr('refID'),
                        DonorID: $(e).H2GAttr('donorID'),
                        ExternalCardID: $(e).H2GAttr('extID'),
                        CardNumber: $(e).H2GAttr('cardNumber'),
                    };
                    create++;
                });
                var DonorComment = [];
                create = 0;
                $('#divComment .row').each(function (i, e) {
                    DonorComment[create] = {
                        ID: $(e).H2GAttr('refID'),
                        StartDate: $(e).H2GAttr('startDate'),
                        EndDate: $(e).H2GAttr('endDate'),
                        Description: $(e).find(".dc-comment").H2GValue(),
                    };
                    create++;
                });
                var DonorRecord = [];
                create = 0;
                $('#divDonateRecord .row').each(function (i, e) {
                    DonorRecord[create] = {
                        ID: $(e).H2GAttr('refID'),
                        DonateDate: $(e).H2GAttr('donatedate'),
                        DonateNumber: $(e).H2GAttr('donatenumber'),
                        DonateFrom: $(e).H2GAttr('donatefrom'),
                        DonateReward: getReward(e),
                    };
                    create++;
                });
                DonorRecord.sort(H2G.keysrt('DonateNumber'));

                $.ajax({
                    url: '../../ajaxAction/donorAction.aspx',
                    data: H2G.ajaxData({ action: 'savedonor', md: JSON.stringify(MasterDonor), dv: JSON.stringify(DonorVisit), dec: JSON.stringify(DonorExtCard), dc: JSON.stringify(DonorComment), dr: JSON.stringify(DonorRecord) }).config,
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                        notiError("บันทึกไม่สำเร็จ");
                        $("#btnSave").prop("disabled", false);
                    },
                    success: function (data) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        if (!data.onError) {
                            $("#data").H2GAttr("donorID", data.getItems.ID);
                            $("#spRegisNumber").H2GAttr("visitID", data.getItems.VisitID)
                            notiSuccess("บันทึกสำเร็จ");
                            showDonorData();                            
                        } else { notiError("บันทึกไม่สำเร็จ"); }
                        $("#btnSave").prop("disabled", false);
                    }
                });    //End ajax
            } else {
                $("#btnSave").prop("disabled", false);
            }
        }
        function getReward(xobj) {
            var reward = '';
            // reward_id|reward_date##
            $(xobj).find(".txt-reward-date[donateRewardID='NEW']").each(function (i, e) {
                if ($(e).H2GValue() != "") {
                    reward = $(e).H2GAttr("rewardID") + "|" + $(e).H2GValue() + "##";
                }
            });
            console.log(reward);
            return reward;
        }
        function validation() {
            if ($('#divCardNumber > div').length == 0) {
                $("#txtExtNumber").focus();
                notiWarning("กรุณากรอกข้อมูลบัตรผู้บริจาคอย่างน้อย 1 ใบ");
                return false;
            } else if ($('#ddlTitleName').H2GValue() == "") {
                $("#ddlTitleName").focus();
                notiWarning("กรุณาเลือกคำนำหน้าชื่อผู้บริจาค");
                return false;
            } else if ($('#txtDonorName').H2GValue() == "") {
                $("#txtDonorName").focus();
                notiWarning("กรุณากรอกชื่อผู้บริจาค");
                return false;
            } else if ($('#txtDonorSurName').H2GValue() == "") {
                $("#txtDonorSurName").focus();
                notiWarning("กรุณากรอกนามสกุลผู้บริจาค");
                return false;
            } else if ($('#txtDonorNameEng').H2GValue() == "") {
                $("#txtDonorNameEng").focus();
                notiWarning("กรุณากรอกชื่อภาษาอังกฤษผู้บริจาค");
                return false;
            } else if ($('#txtDonorSurNameEng').H2GValue() == "") {
                $("#txtDonorSurNameEng").focus();
                notiWarning("กรุณากรอกนามสกุลภาษาอังกฤษผู้บริจาค");
                return false;
            } else if ($('#txtBirthday').H2GValue() == "") {
                $("#txtBirthday").focus();
                notiWarning("กรุณากรอกวันเกิดผู้บริจาค");
                return false;
            } else if ($('#ddlOccupation').H2GValue() == "") {
                $("#ddlOccupation").focus();
                notiWarning("กรุณาเลือกอาชีพผู้บริจาค");
                return false;
            } else if ($('#ddlNationality').H2GValue() == "") {
                $("#ddlNationality").focus();
                notiWarning("กรุณาเลือกสัญชาติผู้บริจาค");
                return false;
            } else if ($('#txtAddress').H2GValue() == "") {
                $("#txtAddress").focus();
                notiWarning("กรุณากรอกที่อยู่ผู้บริจาค");
                return false;
            } else if ($('#txtSubDistrict').H2GValue() == "") {
                $("#txtSubDistrict").focus();
                notiWarning("กรุณากรอกแขวง/ตำบลผู้บริจาค");
                return false;
            } else if ($('#txtDistrict').H2GValue() == "") {
                $("#txtDistrict").focus();
                notiWarning("กรุณากรอกเขต/อำเภอผู้บริจาค");
                return false;
            } else if ($('#txtProvince').H2GValue() == "") {
                $("#txtProvince").focus();
                notiWarning("กรุณากรอกจังหวัดผู้บริจาค");
                return false;
            } else if ($('#txtZipcode').H2GValue() == "") {
                $("#txtZipcode").focus();
                notiWarning("กรุณากรอกรหัสไปรษณีย์ผู้บริจาค");
                return false;
            } else if ($('#txtMobile1').H2GValue() == "") {
                $("#txtMobile1").focus();
                notiWarning("กรุณากรอกเบอร์โทรศัพท์มือถือผู้บริจาค");
                return false;
            } else if ($('#txtEmail').H2GValue() != "") {
                if (!H2G.IsEmail($('#txtEmail').H2GValue())) {
                    $("#txtEmail").focus();
                    notiWarning("กรุณากรอกอีเมลให้ถูกต้อง");
                    return false;
                }
            }
            return true;
        }
        function showDonorData() {
            $.ajax({
                url: '../../ajaxAction/donorAction.aspx',
                data: H2G.ajaxData({ action: 'selectregister', id: $("#data").H2GAttr("donorID"), visit_id: $("#spRegisNumber").H2GAttr("visitID") }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    $("#btnSave").prop("disabled", false);
                    console.log(s, err);
                },
                success: function (data) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (!data.onError) {
                        console.log('selectregister', data.getItems);
                        $("#spRegisNumber").H2GFill({
                            donorID: data.getItems.Donor.DonorID,
                            visitID: data.getItems.Donor.VisitID,
                            dPlanID: data.getItems.Donor.CollectionPlanID,
                            dPointID: data.getItems.Donor.CollectionPointID,
                            siteID: data.getItems.Donor.SiteID,
                            visitFrom: data.getItems.Donor.VisitFrom,
                            queueNum: data.getItems.Donor.QueueNumber,
                            dTypeID: data.getItems.Donor.DonationTypeID,
                            bagID: data.getItems.Donor.BagID,
                            dToID: data.getItems.Donor.DonationToID,
                            donateNumber: data.getItems.Donor.DonateNumber,
                            donateNumberExt: data.getItems.Donor.DonateNumberExt,
                            visitNumber: data.getItems.Donor.VisitNumber
                        });
                        
                        $("#spVisitCount").H2GValue("รวมจำนวนการเข้าพบ " + data.getItems.Donor.VisitNumber + " ครั้ง / บริจาค " + data.getItems.Donor.DonateCount + " ครั้ง");
                        $("#spVisitInfo").H2GValue("วันที่ลงทะเบียน " + data.getItems.Donor.VisitDateTimeText + " เข้าพบครั้งสุดท้ายเมื่อ " + data.getItems.Donor.LastVisitDateText + " ( " + data.getItems.Donor.DiffDate + " วัน ) กำลังดำเนินการบริจาคครั้งที่ " + data.getItems.Donor.CurrentDonateNumber)
                            .H2GFill({
                                visitDateText: data.getItems.Donor.VisitDateText,
                                lastVisitDateText: data.getItems.Donor.LastVisitDateText,
                                diffDate: data.getItems.Donor.DiffDate,
                                currentDonateNumber: data.getItems.Donor.CurrentDonateNumber
                            });
                        $("#infoTab > ul > li > a[href='#todayPane']").H2GValue(data.getItems.Donor.VisitDateText)

                        $("#spRegisNumber").H2GValue(data.getItems.Donor.DonorNumber);
                        $("#spQueue").H2GValue(data.getItems.Donor.QueueNumber==""?"-":"คิวที่ " + data.getItems.Donor.QueueNumber).H2GAttr("queueNumber",data.getItems.Donor.QueueNumber);
                        $("input:radio[name=gender]").prop("checked", false);
                        if (data.getItems.Donor.Gender == "M") { $("#rbtM").prop("checked", true); } else { $("#rbtF").prop("checked", true); }
                        $("#txtDonorName").H2GValue(data.getItems.Donor.Name);
                        $("#txtDonorSurName").H2GValue(data.getItems.Donor.Surname);
                        $("#txtDonorNameEng").H2GValue(data.getItems.Donor.NameE);
                        $("#txtDonorSurNameEng").H2GValue(data.getItems.Donor.SurnameE);
                        $("#txtBirthDay").H2GValue(data.getItems.Donor.Birthday);
                        $("#txtAge").H2GValue(data.getItems.Donor.Age);
                        $("#ddlTitleName").H2GAttr("selectItem", data.getItems.Donor.TitleID);
                        $("#txtAddress").H2GValue(data.getItems.Donor.Address);
                        $("#txtSubDistrict").H2GValue(data.getItems.Donor.SubDistrict);
                        $("#txtDistrict").H2GValue(data.getItems.Donor.District);
                        $("#txtProvince").H2GValue(data.getItems.Donor.Province);
                        $("#txtZipcode").H2GValue(data.getItems.Donor.Zipcode);
                        $("#ddlCountry").H2GAttr("selectItem", data.getItems.Donor.CountryID);
                        $("#ddlOccupation").H2GAttr("selectItem", data.getItems.Donor.OccupationID);
                        $("#ddlNationality").H2GAttr("selectItem", data.getItems.Donor.NationalityID);
                        $("#ddlRace").H2GAttr("selectItem", data.getItems.Donor.RaceID);
                        $("#txtMobile1").H2GValue(data.getItems.Donor.Mobile1);
                        $("#txtMobile2").H2GValue(data.getItems.Donor.Mobile2);
                        $("#txtHomeTel").H2GValue(data.getItems.Donor.HomeTel);
                        $("#txtTel").H2GValue(data.getItems.Donor.OfficeTel);
                        $("#txtTelExt").H2GValue(data.getItems.Donor.OfficeTelExt);
                        $("#txtEmail").H2GValue(data.getItems.Donor.Email);
                        $("#ddlAssociation").H2GAttr("selectItem", data.getItems.Donor.AssociationID);

                        //### External Card
                        $('#divCardNumber').H2GValue("");
                        $.each((data.getItems.ExtCard), function (index, e) {
                            var spExtCard = $("#divCardNumberTemp").children().clone();
                            $(spExtCard).H2GFill({ refID: e.ID, donorID: e.DonorID, extID: e.ExternalCardID, cardNumber: e.CardNumber }).find(".ext-number").H2GValue(e.CardName + " : " + e.CardNumber);
                            $('#divCardNumber').append(spExtCard);
                            if (e.ExternalCardID == "3") { $('#txtCardNumber').H2GValue(e.CardNumber) }
                        });

                        //### Deferral
                        if (data.getItems.Deferral.length > 0) {
                            var dataView = $("#tbDefferal").H2GValue('');
                            $.each((data.getItems.Deferral), function (index, e) {
                                var dataRow = $("#tbDefferal > thead > tr.template-data").clone().show();
                                if (e.Status == "INACTIVE") { dataRow.hide(); }
                                $(dataRow).H2GAttr('status', e.Status);
                                $(dataRow).find('.td-def-code').append(e.Code).H2GAttr("title", e.Code);
                                $(dataRow).find('.td-def-date').append(e.EndDate).H2GAttr("title", e.EndDate);
                                $(dataRow).find('.td-def-description').append(e.Description).H2GAttr("title", e.Description);
                                $(dataRow).find('.td-def-status').append(e.DeferralType).H2GAttr("title", e.DeferralType);
                                $(dataView).append(dataRow);
                            });
                        }

                        //### Deferral
                        $.each((data.getItems.DonationType), function (index, e) {
                            var span = $("span[donationCode=" + e.Code + "]");
                            if (span) { $(span).H2GValue('บริจาคล่าสุดเมื่อ ' + e.LastDate); }
                            if (e.Code == 'SC') { $(span).show(); $("#txtStmRegisDate").hide(); }
                        });

                        //### Donor Comment
                        $('#divComment').H2GValue("");
                        $.each((data.getItems.DonorComment), function (index, e) {
                            var spComment = $("#divCommentTemp").children().clone();
                            $(spComment).H2GAttr("refID", e.ID);
                            $(spComment).find(".dc-datecomment").H2GValue(e.StartDate + " - " + e.EndDate);
                            $(spComment).find(".dc-comment").H2GValue(e.Description);
                            $('#divComment').append(spComment);
                        });

                        //### Donation Record
                        $('#divDonateRecord').H2GValue("");
                        $.each((data.getItems.DonationRecord), function (index, e) {
                            var spRecord = $("#divDonateRecordTemp").children().clone();
                            $(spRecord).H2GFill({ refID: e.ID, donatedate: e.DonateDate, donatenumber: e.DonateNumber, donatefrom: e.DonateFrom });
                            $(spRecord).find("span.rec-text").H2GValue("ครั้งที่ " + e.DonateNumber + " บริจาควันที่ " + e.DonateDateText + (e.DonateFrom == "EXTERNAL" ? " ณ โรงพยาบาลนอกเครือข่าย" : " ณ โรงพยาบาลในเครือข่าย"));

                            //มี Reward ต้องแสดง
                            if (e.DonateReward != "") {
                                var rewardRec = e.DonateReward.split('##');
                                $.each((rewardRec), function (index, e) {
                                    if (e != "") {
                                        var rewardInfo = e.split("|");
                                        // reward_id|reward_desc|donation_reward_id|reward_date
                                        var rowReward = $("#donateRewardTemp").clone();
                                        $(rowReward).find(".lbl-check-reward").append(rewardInfo[1]).H2GFill({ rewardID: rewardInfo[0] }).find("input").prop("checked", (rewardInfo[2] == "" ? "N" : "Y").toBoolean());
                                        $(rowReward).find(".txt-reward-date").H2GFill({ rewardID: rewardInfo[0], donateRewardID: rewardInfo[2] }).H2GValue(rewardInfo[3]);

                                        if (rewardInfo[2] != "") {
                                            $(rowReward).find(".lbl-check-reward input").prop("disabled", true);
                                            $(rowReward).find(".txt-reward-date").prop("disabled", true);
                                        } else {
                                            $(rowReward).find(".lbl-check-reward input").on("change", function () { $(this).checkedReward() });
                                            $(rowReward).find(".txt-reward-date").setCalendar({
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
                                            }).H2GDatebox().H2GValue(rewardInfo[3]);
                                        }
                                        $(spRecord).append($(rowReward).children());
                                    }
                                });
                            }
                            $('#divDonateRecord').prepend(spRecord).H2GAttr("lastrecord", e.DonateNumber);
                        });

                        if (!(data.getItems.Donor.DuplicateTransaction == "0")){
                            alert("วันนี้คุณ " + data.getItems.Donor.Name + " " + data.getItems.Donor.Surname + "  ทำการลงทะเบียนไปแล้ว " + data.getItems.Donor.DuplicateTransaction + " ครั้ง");
                        }

                    } else { }
                    donorSelectDDL();
                    $("#btnSave").prop("disabled", false);
                }
            });    //End ajax
        }
        function cancelRegis(xobj) {
            $("#data").H2GAttr("donorID", "");
            $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: 'search.aspx', method: "post" }).submit();
        }

        function setHistoricalFileDatas() {
            //console.log("setHistoricalFileDatas");
            $("tr").remove(".historicalFileTableRows");
            //console.log("id = ", $("#spRegisNumber").H2GValue());
            var datas = [];

            $.ajax({
                url: '../../ajaxAction/donorAction.aspx',
                data: H2G.ajaxData({ action: 'historicalFileData', donn_numero: $("#spRegisNumber").H2GValue() }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    // console.log("Respondata = ", data.getItems);
                    if (!data.onError) {
                        datas = data.getItems;
                        for (var i = 0; i < datas.length; i++) {
                            var rows = "<tr class='historicalFileTableRows'>" +
                                            "<td><input type='text' class='text-left' readonly value='" + datas[i].Exams + "' /></td>" +
                                            "<td><input type='text' class='text-left' readonly value='" + datas[i].Result + "' /></td>" +
                                            "<td><input type='text' class='text-center' readonly value='" + datas[i].DateOfFirstDet + "' /></td>" +
                                            "<td><input type='text' class='text-center' readonly value='" + datas[i].DateOfLastDet + "' /></td>" +
                                            "<td><input type='text' class='text-center' readonly value='" + datas[i].SamplesTested + "' /></td>" +
                                            "<td><input type='text' class='text-left' readonly value='" + datas[i].FirstSample + "' /></td>" +
                                            "<td><input type='text' class='text-left' readonly value='" + datas[i].LastSample + "' /></td>" +
                                            "<td><input type='text' class='text-left' readonly value='" + datas[i].FirstAuthorisingLab + "' /></td>" +
                                            "<td><input type='text' class='text-left' readonly value='" + datas[i].LastAuthorisingLab + "' /></td>" +
                                       "</tr>";
                            $('#historicalFileTable > tbody').append(rows);
                        }
                    }
                }
            });
        }

        function setImmunohaemtologyFile() {
            console.log("setImmunohaemtologyFile");
            $.ajax({
                url: '../../ajaxAction/donorAction.aspx',
                data: H2G.ajaxData({ action: 'immunohaemtologyDataSet1', donn_numero: $("#spRegisNumber").H2GValue() }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    // console.log("Respondata exams = ", data.getItems);
                    if (!data.onError) {
                        var data = data.getItems;
                        if (data.length > 0) {
                            for (var i = 0; i < data.length; i++){
                                data[i].Rsx_Lib = data[i].Rsx_Lib.replace(" ", "_");
                                data[i].Rsx_Cd = data[i].Rsx_Cd.substring(0, 2);
                                
                                $("#" + data[i].Rsx_Lib + "_" + data[i].Rsx_Cd).val(data[i].Dex_Res);
                            }
                        }
                       // console.log(data);
                    }
                }
            });


            $.ajax({
                url: '../../ajaxAction/donorAction.aspx',
                data: H2G.ajaxData({ action: 'immunohaemtologyDataSet2', donn_numero: $("#spRegisNumber").H2GValue() }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    // console.log("Respondata exams = ", data.getItems);
                    if (!data.onError) {
                        var dataz = data.getItems;
                        if (dataz.length > 0) {
                            for (var i = 0; i < dataz.length; i++) {
                                dataz[i].Rsx_Lib = dataz[i].Rsx_Lib.replace(" ", "_");

                                $("#" + dataz[i].Rsx_Lib + "_NO").val(dataz[i].Rsx_Type);
                                $("#" + dataz[i].Rsx_Lib + "_RESULT").val(dataz[i].Result_Decode);
                            }
                        }
                    }
                }
            });
        }

        function setExamsDatas() {
            console.log("setExamsDatas");
            $("tr").remove(".exams-tab-table-row");
            var datas = [];

            $.ajax({
                url: '../../ajaxAction/donorAction.aspx',
                data: H2G.ajaxData({ action: 'examsData', donn_numero: $("#spRegisNumber").H2GValue() }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    // console.log("Respondata exams = ", data.getItems);
                    if (!data.onError) {
                        datas = data.getItems;
                        for (var i = 0; i < datas.length; i++) {
                            var rows = "<tr class='exams-tab-table-row'>" +
                                            "<td class='text-right td-number-excel'>" + datas[i].DonnIncr + "</td>" +
                                            "<td class='text-center td-date-excel'>" + datas[i].LabDate + "</td>" +
                                            "<td class='text-center td-text-excel'>" + datas[i].PrelNo + "</td>" +
                                            "<td class='text-center td-text-excel'>" + datas[i].PcatdLib + "</td>" +
                                            "<td class='text-left td-text-excel'>" + datas[i].PexLibAff + "</td>" +
                                            "<td class='text-left td-text-excel'>" + datas[i].PresAff + "</td>" +
                                            "<td class='text-left td-text-excel'>" + datas[i].ExecutingLab + "</td>" +
                                            "<td class='text-left td-text-excel'>" + datas[i].TestBy1 + "</td>" +
                                            "<td class='text-left td-text-excel'>" + datas[i].TestBy2 + "</td>" +
                                            "<td class='text-left td-text-excel'>" + datas[i].TestBy3 + "</td>" +
                                       "</tr>";
                            $('#exams-tab-table > tbody').append(rows);
                        }
                        $("#exams-tab-table").tablesorter({ dateFormat: "uk" });
                    }
                }
            });
        }
        function enterDatePicker(dateControl, action) {
            var pattern = 'dd/MM/yyyy';
            if ($(dateControl).H2GValue() != '') {
                $(dateControl).H2GValue($(dateControl).H2GValue().replace(/\W+/g, ''));
                $(dateControl).next().remove();
                if (isDate($(dateControl).H2GValue(), pattern.replace(/\W+/g, ''))) {
                    var isValue = new Date(getDateFromFormat($(dateControl).H2GValue(), pattern.replace(/\W+/g, '')));
                    $(dateControl).H2GValue(formatDate(isValue, pattern)).H2GAttr('donatedatetext', formatDate(isValue, "dd NNN yyyy"));
                    if (action == "enter") {
                        $(dateControl).addDonateRecord();
                    }
                } else {
                    notiWarning("วันที่ไม่ถูกต้อง กรุณาตรวจสอบ");
                    $(dateControl).focus();
                }
            } else {
                $(dateControl).H2GAttr('donatedatetext', '');
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div>
            <span>ค้นหารายชื่อผู้บริจาค > ลงทะเบียนผู้บริจาค</span>
        </div>
    </div>
    <div class="row">
        <div class="border-box" style="border-radius: 4px 4px 0px 0px; color: #4F7CCB; font-weight: bold;">
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
                <select id="ddlExtCard" style="width: 219px;" tabindex="1">
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
            <div id="divBloodType" class="border-box text-center" style="font-size: 66px; font-weight: bold; height: 108px;">
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
                        <select id="ddlTitleName" class="required" style="width: 142px;" tabindex="1">
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
                        <select id="ddlOccupation" class="required" style="width: 200px;" tabindex="1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>สัญชาติ</span>
                    </div>
                    <div class="col-md-6">
                        <select id="ddlNationality" class="required" style="width: 171px;" tabindex="1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>เชื้อชาติ</span>
                    </div>
                    <div class="col-md-5">
                        <select id="ddlRace" style="width: 142px;" tabindex="1">
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
                    <span>Defferal/Permanance</span>
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
                                <td align="center" colspan="4">No transaction</td>
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
                                <td align="center" colspan="4">No transaction</td>
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
                    <div class="col-md-36">แฟ้มประวัติ</div>
                </div>
            </div>
            <div id="todayPane">
                <div class="border-box">
                    <div class="col-md-36">
                        <div id="infoTabToday">
                            <ul>
                                <li><a href="#subHistoryPane" style="">ข้อมูลทั่วไป</a></li>
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
                                                            <select id="ddlCountry" class="required" style="width: 181px;" tabindex="1">
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
                                                        <select id="ddlAssociation" style="width: 363px;" tabindex="1">
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
                        </div>
                    </div>
                </div>
            </div>
            <div id="labPane">
                <div class="border-box">
                    <div class="col-md-36">ข้อมูล LAB</div>
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
                            <div class="border-box">
                                <div class="col-md-36" style="border:1px solid black">
                                    <p><label>&nbsp;&nbsp; Doner No.</label> <label id="doner-label-no">123456789</label> <label id="doner-label-name">test</label></p>
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
                                    <table class="col-md-36" id="label-set-4">
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
                                <div class="col-md-36 tableHeadDiv"><b>Donation exeminations</b></div>
                                <div class="col-md-36">
                                    <table class="table table-bordered-excel tablesorter" id="exams-tab-table">
                                        <thead>
                                            <tr>
                                                <th class="col-md-2">ครั้งที่</th>
                                                <th class="col-md-3">วันที่ตรวจสอบ</th>
                                                <th class="col-md-4">Sample no</th>
                                                <th class="col-md-4">ประเภทการบริจาค</th>
                                                <th class="col-md-4">Examination</th>
                                                <th class="col-md-4">Result</th>
                                                <th class="col-md-5">executing laboratory</th>
                                                <th class="col-md-2">Test 1</th>
                                                <th class="col-md-2">Test 2</th>
                                                <th class="col-md-2">Test 3</th>
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
