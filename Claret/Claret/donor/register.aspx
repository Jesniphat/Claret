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
            $("#txtDonorName").H2GThaibox();
            $("#txtDonorSurName").H2GThaibox();
            $("#txtDonorNameEng").H2GEnglishbox();
            $("#txtDonorSurNameEng").H2GEnglishbox();
            $("#ddlDefferal").setDropdowList().on('change', function () {
                if ($(this).H2GValue() == 'ACTIVE') { $("#tbDefferal > thead > tr[status=INACTIVE]").hide(); } else { $("#tbDefferal > thead > tr[status=INACTIVE]").show(); }
            });
            $("#ddlVisit").setDropdowList();
            $("#infoTabToday").tabs({ active: 2 });
            $("#infoTab").tabs();
            $("#togDeferal").toggleSlide();
            $("#labTab").tabs();
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
                    $("#ddlOccupation").closest("div").focus();
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
                    var pattern = 'dd/MM/yyyy';
                    if ($(this).H2GValue() != '') {
                        $(this).H2GValue($(this).H2GValue().replace(/\W+/g, ''));
                        $(this).next().remove();
                        if (isDate($(this).H2GValue(), pattern.replace(/\W+/g, ''))) {
                            var isValue = new Date(getDateFromFormat($(this).H2GValue(), pattern.replace(/\W+/g, '')));
                            $(this).H2GValue(formatDate(isValue, pattern)).H2GAttr('donatedatetext', formatDate(isValue, "dd NNN yyyy"));
                        }
                    } else {
                        $(this).H2GAttr('donatedatetext', '');
                    }
                }
            });
            $("#txtCommentDateForm").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
            $("#txtCommentDateTo").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                maxDate: "+10y",
                minDate: new Date(),
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) { $("#txtDonorComment").focus(); },
                onClose: function () { $("#txtDonorComment").focus(); },
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

            $("#ddlExtCard").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'externalcard' } }, "3").on('change', function () { $("#txtCardNumber").focus(); });
            $("input:radio[name=gender]").change(function (e) {
                $("#ddlTitleName").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'titlename', gender: $("#rbtM").is(':checked') == true ? "M" : "F" } });
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
                                            $(rowReward).find(".txt-reward-date").setCalendar({
                                                maxDate: new Date(),
                                                minDate: "-20y",
                                                yearRange: "c-20:c+0",
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
            });

            $("#labPaneTab").click(setHistoricalFileDatas);
            $("#exams-tab").click(setExamsDatas);
            
            //### extend
        });

        function donorSelectDDL() {
            if ($("#ddlTitleName option").length > 1) { $("#ddlTitleName").H2GValue($("#ddlTitleName").H2GAttr("selectItem")).change(); } else {
                $("#ddlTitleName").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'titlename', gender: $("#rbtM").is(':checked') == true ? "M" : "F" } }, $("#ddlTitleName").H2GAttr("selectItem")).on('change', function () {
                    $("#txtDonorName").focus();
                });
            }
            if ($("#ddlCountry option").length > 1) { $("#ddlCountry").H2GValue($("#ddlCountry").H2GAttr("selectItem")).change(); } else {
                $("#ddlCountry").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'country' } }, $("#ddlCountry").H2GAttr("selectItem") == undefined ? "64" : $("#ddlCountry").H2GAttr("selectItem")).on('change', function () {
                    $("#txtMobile1").focus();
                });
            }
            if ($("#ddlOccupation option").length > 1) { $("#ddlOccupation").H2GValue($("#ddlOccupation").H2GAttr("selectItem")).change(); } else {
                $("#ddlOccupation").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'occupation' } }, $("#ddlOccupation").H2GAttr("selectItem")).on('change', function () {
                    $("#ddlNationality").closest("div").focus();
                });
            }
            if ($("#ddlNationality option").length > 1) { $("#ddlNationality").H2GValue($("#ddlNationality").H2GAttr("selectItem")).change(); } else {
                $("#ddlNationality").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'nationality' } }, $("#ddlNationality").H2GAttr("selectItem")).on('change', function () {
                    $("#ddlRace").closest("div").focus();
                });
            }
            if ($("#ddlRace option").length > 1) { $("#ddlRace").H2GValue($("#ddlRace").H2GAttr("selectItem")).change(); } else {
                $("#ddlRace").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'nationality' } }, $("#ddlRace").H2GAttr("selectItem")).on('change', function () {
                    $("#txtAddress").focus();
                });
            }
            //if ($("#ddlAssociation option").length > 1) { $("#ddlAssociation").H2GValue($("#ddlAssociation").H2GAttr("selectItem")).change(); } else {
            //    $("#ddlAssociation").setDropdowListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'association' } }, $("#ddlAssociation").H2GAttr("selectItem")).on('change', function () {
            //        $("#txtOuterDonate").focus();
            //    });
            //}
            $("#txtCardNumber").focus();


            if ($("#ddlAssociation option").length > 1) { $("#ddlAssociation").H2GValue($("#ddlAssociation").H2GAttr("selectItem")).change(); } else {
                $("#ddlAssociation").setAutoListValue({ url: '../../ajaxAction/masterAction.aspx', data: { action: 'association' } }, $("#ddlAssociation").H2GAttr("selectItem")).on('change', function () {
                    $("#txtOuterDonate").focus();
                });
            }



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
                console.log($('#divCardNumber .row'));
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
                            console.log(data.getItems);
                            $("#data").H2GAttr("donorID", data.getItems.ID);
                            $("#spRegisNumber").H2GAttr("visitID", data.getItems.VisitID)
                            notiSuccess("บันทึกสำเร็จ");
                            showDonorData();                            
                        } else { notiError("บันทึกไม่สำเร็จ"); }
                    }
                });    //End ajax
            } else {
                $("#btnSave").prop("disabled", false);
            }
        }
        function getReward(xobj) {
            var reward = '';
            if ($(xobj).find(".lbl-check-reward").H2GAttr("rewardID") != undefined) {
                reward = "ID:" + $(xobj).find(".lbl-check-reward").H2GAttr("rewardID");
                reward = reward + "|DATE:" + $(xobj).find(".txt-reward-date").H2GValue();
            }
            console.log(reward);
            return reward;
        }
        function validation() {
            if ($('#divCardNumber span').length == 0) {
                $("#txtExtNumber").focus();
                notiWarning("กรุณากรอกข้อมูลบัตรผู้บริจากอย่างน้อย 1 ใบ");
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
                                            "<td><input type='text' class='text-left' value='" + datas[i].Exams + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].Result + "' /></td>" +
                                            "<td><input type='text' class='text-center' value='" + datas[i].DateOfFirstDet + "' /></td>" +
                                            "<td><input type='text' class='text-center' value='" + datas[i].DateOfLastDet + "' /></td>" +
                                            "<td><input type='text' class='text-center' value='" + datas[i].SamplesTested + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].FirstSample + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].LastSample + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].FirstAuthorisingLab + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].LastAuthorisingLab + "' /></td>" +
                                       "</tr>";
                            $('#historicalFileTable > tbody').append(rows);
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
                     console.log("Respondata exams = ", data.getItems);
                    if (!data.onError) {
                        datas = data.getItems;
                        for (var i = 0; i < datas.length; i++) {
                            var rows = "<tr class='exams-tab-table-row'>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].DonnIncr + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].LabDate + "' /></td>" +
                                            "<td><input type='text' class='text-center' value='" + datas[i].PrelNo + "' /></td>" +
                                            "<td><input type='text' class='text-center' value='" + datas[i].PcatdLib + "' /></td>" +
                                            "<td><input type='text' class='text-center' value='" + datas[i].PexLibAff + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].PresAff + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].ExecutingLab + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].TestBy1 + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].TestBy2 + "' /></td>" +
                                            "<td><input type='text' class='text-left' value='" + datas[i].TestBy3 + "' /></td>" +
                                       "</tr>";
                            $('#exams-tab-table > tbody').append(rows);
                        }
                        $("#exams-tab-table").tablesorter();
                    }
                }
            });

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
                <select id="ddlExtCard" style="width: 100%">
                    <option value="0">Loading...</option>
                </select>
            </div>
            <div class="col-md-7">
                <input id="txtCardNumber" type="text" class="form-control" />
            </div>
            <div class="col-md-2">
                <a class="icon"><span id="spInsertExtCard" class="glyphicon glyphicon-circle-arrow-right" aria-hidden="true" style="vertical-align: sub;"></span></a>
            </div>
            <div class="col-md-19">
                <div id="divCardNumber" min-height="30" style="height: 30px; overflow: hidden;">
                </div>
                <div id="divCardNumberTemp" style="display: none;">
                    <div class="row" extid="" donorid refid="NEW" cardnumber="">
                        <div class="col-md-34 ext-number"></div>
                        <div class="col-md-2"><a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="$(this).deleteExtCard();"></span></a></div>
                    </div>
                </div>
            </div>
            <div class="col-md-1 text-right">
                <a class="icon"><span id="togCardNumber" class="glyphicon glyphicon-menu-down" aria-hidden="true"></span></a>
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
                            <input id="rbtM" name="gender" type="radio" checked="checked" />ชาย</label>
                        <label style="cursor: pointer; font-weight: normal; margin-bottom: 0px;">
                            <input id="rbtF" name="gender" type="radio" />หญิง</label>
                    </div>
                    <div class="col-md-3 text-right">
                        <span>คำนำหน้า</span>
                    </div>
                    <div class="col-md-5">
                        <select id="ddlTitleName" class="required" style="width: 100%">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>ชื่อ</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorName" type="text" class="form-control required" />
                    </div>
                    <div class="col-md-2 text-right">
                        <span>นามสกุล</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorSurName" type="text" class="form-control required" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-12">
                    </div>
                    <div class="col-md-2 text-right">
                        <span>Name</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorNameEng" type="text" class="form-control required" />
                    </div>
                    <div class="col-md-2 text-center">
                        <span>Surname</span>
                    </div>
                    <div class="col-md-10">
                        <input id="txtDonorSurNameEng" type="text" class="form-control required" />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-5">
                    </div>
                    <div class="col-md-2 text-right">
                        <span>วันเกิด</span>
                    </div>
                    <div class="col-md-3">
                        <input id="txtBirthDay" type="text" class="form-control required text-center" />
                    </div>
                    <div class="col-md-2">
                        <input id="txtAge" type="text" class="form-control text-center" disabled />
                    </div>
                    <div class="col-md-2 text-right">
                        <span>อาชีพ</span>
                    </div>
                    <div class="col-md-7">
                        <select id="ddlOccupation" class="required" style="width: 100%">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>สัญชาติ</span>
                    </div>
                    <div class="col-md-6">
                        <select id="ddlNationality" class="required" style="width: 100%">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                    <div class="col-md-2 text-right">
                        <span>เชื้อชาติ</span>
                    </div>
                    <div class="col-md-5">
                        <select id="ddlRace" style="width: 100%">
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
                        <input id="txtStmRegisDate" type="text" class="form-control" />
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
                                                            <textarea id="txtAddress" class="form-control required" style="height:58px;"></textarea>
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">แขวง/ตำบล</div>
                                                        <div class="col-md-12">
                                                            <input id="txtSubDistrict" type="text" class="form-control required" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">เขต/อำเภอ</div>
                                                        <div class="col-md-11">
                                                            <input id="txtDistrict" type="text" class="form-control required" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">จังหวัด</div>
                                                        <div class="col-md-12">
                                                            <input id="txtProvince" type="text" class="form-control required" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">รหัสไปรษณีย์</div>
                                                        <div class="col-md-11">
                                                            <input id="txtZipcode" type="text" class="form-control required" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5"><span>ประเทศ</span></div>
                                                        <div class="col-md-12">
                                                            <select id="ddlCountry" class="required" style="width: 100%">
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
                                                            <input id="txtMobile1" type="text" class="form-control required" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">Email</div>
                                                        <div class="col-md-11">
                                                            <input id="txtEmail" type="text" class="form-control" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์มือถือ 2</div>
                                                        <div class="col-md-12">
                                                            <input id="txtMobile2" type="text" class="form-control" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์บ้าน</div>
                                                        <div class="col-md-12">
                                                            <input id="txtHomeTel" type="text" class="form-control" />
                                                        </div>
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-3"></div>
                                                        <div class="col-md-5">เบอร์ที่ทำงาน</div>
                                                        <div class="col-md-12">
                                                            <input id="txtTel" type="text" class="form-control" />
                                                        </div>
                                                        <div class="col-md-5" style="padding-left: 5px;">เบอร์ต่อ</div>
                                                        <div class="col-md-11">
                                                            <input id="txtTelExt" type="text" class="form-control" />
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
                                                        <select id="ddlAssociation" style="width: 100%">
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
                                                        เพิ่มจำนวนการบริจาคจากภายนอก
                                                    </div>
                                                    <div class="row">
                                                        <div class="col-md-7">
                                                            จำนวนครั้งที่บริจาค
                                                        </div>
                                                        <div class="col-md-9">
                                                            <input id="txtOuterDonate" type="text" class="form-control text-center" />
                                                        </div>
                                                        <div class="col-md-8 text-center">
                                                            วันที่บริจาคครั้งล่าสุด
                                                        </div>
                                                        <div class="col-md-10">
                                                            <input id="txtLastDonateDate" type="text" class="form-control text-center" />
                                                        </div>
                                                        <div class="col-md-2 text-center">
                                                            <a class="icon">
                                                                <span id="spAddDonateRecord" class="glyphicon glyphicon-circle-arrow-down" aria-hidden="true" style="vertical-align: sub;"></span>
                                                            </a>
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
                                                                        <input type="checkbox" style="margin-right: 10px;" /></label>
                                                                </div>
                                                                <div class="col-md-2"><span>เมื่อ</span></div>
                                                                <div class="col-md-12" style="padding-left: 8px; padding-right: 14px;">
                                                                    <input type="text" class="txt-reward-date form-control text-center" />
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
                            <li><a href="#immunohaemtologyFile" style="">Immunohaemtology File</a></li>
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
                            <h1>Immunohaemtology File</h1>
                        </div>
                        <div id="exams">
                            <div class="border-box">
                                <div class="col-md-36">
                                    <table class="table table-bordered-excel" id="exams-tab-table">
                                        <thead>
                                            <tr><th class="col-md-36" colspan="10">Donation exeminations</th></tr>
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
                    <input id="txtCommentDateTo" type="text" class="form-control text-center" />
                </div>
                <div class="col-md-2 text-center">
                    หมายเหตุ
                </div>
                <div class="col-md-23">
                    <input id="txtDonorComment" type="text" class="form-control" />
                </div>
                <div class="col-md-1 text-center">
                    <a class="icon">
                        <span id="spAddComment" class="glyphicon glyphicon-circle-arrow-down" aria-hidden="true" style="vertical-align: sub;"></span>
                    </a>
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
            <input id="btnCard" type="button" class="btn btn-primary btn-block" value="พิมพ์บัตร" />
        </div>
        <div class="col-md-3">
            <input id="btnSticker" type="button" class="btn btn-primary btn-block" value="พิมพ์สติ๊กเกอร์" />
        </div>
        <div class="col-md-3">
            <input id="btnHistory" type="button" class="btn btn-success btn-block" value="บันทึกประวัติ" />
        </div>
        <div class="col-md-21"></div>
        <div class="col-md-3">
            <input id="btnCancel" type="button" class="btn btn-block" value="ยกเลิก" />
        </div>
        <div class="col-md-3">
            <input id="btnSave" type="button" class="btn btn-success btn-block" value="ลงทะเบียน" />
        </div>
    </div>
    <div style="display: none;">
        <input id="data" runat="server" /></div>
</asp:Content>
