var gotoRegister = false;
function lookupControl() {
    $("#txtCardNumber").H2GFocus();
    //$("#txtDonorName").H2GNamebox();
    //$("#txtDonorSurName").H2GNamebox();
    $("#txtDonorNameEng").H2GDisable();//.H2GNamebox()
    $("#txtDonorSurNameEng").H2GDisable();//.H2GNamebox()
    $("#ddlVisit").setAutoList({ selectItem: function () { $(this).changeQuestLanguage(); }, }).H2GValue("ACTIVE");
    $("#togDeferal").toggleSlide();
    $("#togVisitInfo").toggleSlide();
    $("#txtStmRegisDate").setCalendar().H2GDatebox();
    $("#txtOuterDonate").H2GNumberbox();
    //$("#txtMobile1").H2GPhonebox();
    //$("#txtMobile2").H2GPhonebox();
    //$("#txtHomeTel").H2GPhonebox();
    //$("#txtTel").H2GPhonebox();
    //$("#txtTelExt").H2GPhonebox();

    $("#labPaneTab").click(setHistoricalFileDatas);
    $("#exams-tab").click(setExamsDatas);
    $("#immunohaemtology-tab").click(setImmunohaemtologyFile);

    //### Tab คัดกรอง
    $("#ddlQuestLanguage").setAutoList({ selectItem: function () { $(this).changeQuestLanguage(); }, }).H2GValue("English");
    $("#ddlDeferralType").setAutoList();
    $("#ddlITVResult").setAutoList();
    $("#ddlHbTest").setAutoList();
    $("#txtWeight").H2GNumberbox();
    $("#txtHeartRate").H2GNumberbox();
    $("#txtPresureMin").H2GNumberbox();
    $("#txtPresureMax").H2GNumberbox();
    $("#txtDuration").H2GNumberbox();
    $("#txtHeartLung").H2GEnglishbox();
    $("#txtHb").H2GNumberbox();

    $("#txtDefDateTo").H2GDatebox({ allowPastDate: false }).setCalendar({
        maxDate: "+100y",
        minDate: new Date(),
        yearRange: "c50:c+50",
        onSelect: function (selectedDate, objDate) { $("#txtDefRemarks").H2GFocus(); },
    });
    $("#txtMobile1").blur(function () { $(this).checkPhoneNumber(); });
}
function donorSelectDDL() {
    if ($("#ddlTitleName option").length > 1) { $("#ddlTitleName").H2GValue($("#ddlTitleName").H2GAttr("selectItem")); } else {
        $("#ddlTitleName").setAutoListValue({
            url: '../../ajaxAction/masterAction.aspx',
            data: { action: 'titlename', gender: $("#rbtM").is(':checked') == true ? "M" : "F" },
            defaultSelect: $("#ddlTitleName").H2GAttr("selectItem"),
        }).on('autocompleteselect', function () {
            $("#txtDonorName").H2GFocus();
        });
    }
    if ($("#ddlCountry option").length > 1) { $("#ddlCountry").H2GValue($("#ddlCountry").H2GAttr("selectItem")); } else {
        $("#ddlCountry").setAutoListValue({
            url: '../../ajaxAction/masterAction.aspx',
            data: { action: 'country' },
            defaultSelect: $("#ddlCountry").H2GAttr("selectItem") || "64",
        }).on('autocompleteselect', function () {
            $("#txtMobile1").H2GFocus();
        });
    }
    if ($("#ddlOccupation option").length > 1) { $("#ddlOccupation").H2GValue($("#ddlOccupation").H2GAttr("selectItem")); } else {
        $("#ddlOccupation").setAutoListValue({
            url: '../../ajaxAction/masterAction.aspx',
            data: { action: 'occupation' },
            defaultSelect: $("#ddlOccupation").H2GAttr("selectItem") || "1",
        }).on('autocompleteselect', function () {
            $("#ddlNationality").closest("div").H2GFocus();
        });
    }
    if ($("#ddlNationality option").length > 1) { $("#ddlNationality").H2GValue($("#ddlNationality").H2GAttr("selectItem")); } else {
        $("#ddlNationality").setAutoListValue({
            url: '../../ajaxAction/masterAction.aspx',
            data: { action: 'nationality' },
            defaultSelect: $("#ddlNationality").H2GAttr("selectItem") || "1",
        }).on('autocompleteselect', function () {
            $("#ddlRace").closest("div").H2GFocus();
        });
    }
    if ($("#ddlRace option").length > 1) { $("#ddlRace").H2GValue($("#ddlRace").H2GAttr("selectItem")); } else {
        $("#ddlRace").setAutoListValue({
            url: '../../ajaxAction/masterAction.aspx',
            data: { action: 'nationality' },
            defaultSelect: $("#ddlRace").H2GAttr("selectItem") || "1",
        });
    }
    if ($("#ddlAssociation option").length > 1) { $("#ddlAssociation").H2GValue($("#ddlAssociation").H2GAttr("selectItem")).H2GDisable(); } else {
        $("#ddlAssociation").setAutoListValue({
            url: '../../ajaxAction/masterAction.aspx',
            data: { action: 'association' },
            defaultSelect: $("#ddlAssociation").H2GAttr("selectItem"),
            enable: ($("#ddlAssociation").H2GAttr("selectItem") == "" || $("#ddlAssociation").H2GAttr("selectItem") == undefined) ? true : false,
        });
    }
    if ($("#ddlCollectionPoint option").length > 1) { $("#ddlCollectionPoint").H2GValue($("#ddlCollectionPoint").H2GAttr("selectItem")); } else {
        $("#ddlCollectionPoint").setAutoListValue({
            url: '../../ajaxAction/masterAction.aspx',
            data: { action: 'forcollection', siteID: $("#spRegisNumber").H2GAttr("siteID") || $("#data").H2GAttr("siteID") },
            defaultSelect: $("#ddlCollectionPoint").H2GAttr("selectItem") || $("#data").H2GAttr("collectionpointid"),
        });
    }
}
function checkBeforSave() {
    $("#btnSave").prop("disabled", true);
    if (validation()) {
        //ตรวจสอบอายุอยู่ในช่วงที่จะบริจาคได้
        var ageWarning = checkAgeDonor();
        if (ageWarning == "") {
            preSaveDonor();
        } else {
            //$("#popupheader").H2GValue("กรุณาตรวจสอบ");
            //$("#spAgeWarning").H2GValue(ageWarning);
            //openPopup($("#divAgeContainer"));
            H2GOpenPopupBox({
                header: "กรุณาตรวจสอบ",
                detail: ageWarning,
                confirmFunction: function () { $('#btnSave').prop('disabled', false); }
            });
        }
    } else {
        $("#btnSave").prop("disabled", false);
    }
}
function preSaveDonor() {
    // ถ้าสถานะเป็น WAIT INTERVIEW และมาจากเมนู คัดกรอง หากยังไม่มี Sample No ให้เปิด popup ให้กรอกเลขผู้บริจาคและ Sample No
    if ($("#spStatus").H2GValue() == "WAIT INTERVIEW" && $("#data").H2GAttr("lmenu") == "lmenuInterview" && $("#spRegisNumber").H2GAttr("sampleNumber") == "") {
        openPopup($("#divBarcodeContainer"));
        $("#divContent").find("#txtScanDonorNumber").enterKey(function () {
            if ($("#divContent").find("#txtScanDonorNumber").H2GValue() != $("#spRegisNumber").H2GValue()) {
                notiWarning("รหัสผู้บริจาคไม่ถูกต้อง กรุณาตรวจสอบ");
                $("#divContent").find("#txtScanDonorNumber").H2GValue("").H2GFocus();
            } else {
                $("#divContent").find("#txtScanSampleNumber").H2GFocus();
            }
        });
        $("#spRegisNumber").H2GAttr("backToSearch", "Y");
    } else {
        $("#spRegisNumber").H2GRemoveAttr("backToSearch");
        saveDonorInfo();
        closePopup();
    }
}
function checkAgeDonor() {
    var DonationType = $("#ddlITVDonationType").H2GValue() || "-1";
    var maxAge = 70; var minAge = 17; var age = H2G.calAge($("#txtBirthDay").H2GValue()); var strAgeCheck = "";
    var dataAll = $("#ddlITVDonationType").data("data-ddl");
    if (dataAll != undefined) {
        for (i = 0; i < dataAll.length; i++) {
            if (DonationType == dataAll[i].valueID) {
                maxAge = dataAll[i].maxAge;
                minAge = dataAll[i].minAge;
                break;
            }
        }
    }
    if (age < minAge || age > maxAge) {
        strAgeCheck = "ผู้บริจาคมีอายุ " + age + " ปี ไม่อยู่ในเกณฑ์อายุ " + minAge + "-" + maxAge + " ปี กรุณาตรวจสอบ"
    }
    return strAgeCheck;
}
function checkKeySample(xobj) {
    if ($(xobj).H2GValue() != "") {
        $.ajax({
            url: '../ajaxAction/donorAction.aspx', data: { action: 'checksamplenumber', samplenumber: $(xobj).H2GValue() }, type: "POST", dataType: "json",
            error: function (xhr, s, err) { console.log(s, err); },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (data.getItems.samplenumber == "") {
                        $("#spRegisNumber").H2GAttr("sampleNumber", $(xobj).H2GValue());
                        saveDonorInfo();
                    } else {
                        notiWarning("รายการ Sample Number นี้ถูกใช้ไปแล้ว");
                    }
                } else { notiError(data.exMessage); }
            }
        });    //End ajax
    } else {
        notiWarning("กรุณากรอก Sample Number");
    }
}
function saveDonorInfo(notOnlyDonor) {
    $("#btnSave").prop("disabled", true);
    $("#btnSaveOnlyDonor").prop("disabled", true);
    var MasterDonor = {
        ID: $("#spRegisNumber").H2GAttr("donorID"),
        DonorNumber: $("#spRegisNumber").H2GValue(),
        Gender: $("#rbtM").is(':checked') == true ? "M" : "F",
        Name: $("#txtDonorName").H2GValue(),
        Surname: $("#txtDonorSurName").H2GValue(),
        NameE: $("#txtDonorNameEng").H2GValue(),
        SurnameE: $("#txtDonorSurNameEng").H2GValue(),
        Birthday: $("#txtBirthDay").H2GValue(),
        TitleID: $("#ddlTitleName").H2GValue()||"",
        Address: $("#txtAddress").H2GValue(),
        SubDistrict: "", //$("#txtSubDistrict").H2GValue(),
        District: "",//$("#txtDistrict").H2GValue(),
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
        notOnlyDonor: notOnlyDonor == undefined ? true : notOnlyDonor,
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
        CollectionPointID: $("#spRegisNumber").H2GAttr("dPointID") || $("#data").H2GAttr("collectionpointid"),
        ForCollectionPointID: $("#ddlCollectionPoint").H2GValue() || $("#data").H2GAttr("collectionpointid"),
        SiteID: $("#spRegisNumber").H2GAttr("siteID") || $("#data").H2GAttr("siteid"),
        VisitNumber: $("#spRegisNumber").H2GAttr("visitNumber"),
        VisitDate: $("#spVisitInfo").H2GAttr("visitDate"),
        Weight: $("#txtWeight").H2GValue(),
        PressureMax: $("#txtPresureMax").H2GValue(),
        PressureMin: $("#txtPresureMin").H2GValue(),
        DonationTypeID: $("#ddlITVDonationType").H2GValue() || "",
        BagID: $("#ddlITVBag").H2GValue() || "",
        DonationToID: $("#ddlITVDonationTo").H2GValue() || "",
        HB: $("#txtHb").H2GValue(),
        PLT: $("#txtPlt").H2GValue(),
        HBTest: $("#ddlHbTest").H2GValue() || "",
        HeartLung: $("#txtHeartLung").H2GValue().toUpperCase(),
        HeartRate: $("#txtHeartRate").H2GValue(),
        InterviewStatus: $("#ddlITVResult").H2GValue() || "",
        Status: checkGetStatusForDonation(),
        SampleNumber: $("#spRegisNumber").H2GAttr("sampleNumber"),
    };
    var DonorHospital = {
        ID: "",
        ReceiptHospitalID: "",
        VisitDate: $("#spVisitInfo").H2GAttr("visitDate"),
    };
    if ($("#data").H2GAttr("receiptHospitalID")) {
        DonorHospital.ID = $("#spRegisNumber").H2GAttr("visitID");
        DonorHospital.ReceiptHospitalID = $("#data").H2GAttr("receiptHospitalID");
    }
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
    DonorRecord.sort(H2G.keysrt('ID'));

    var DonorQuestionItem = [];
    var DonorDeferralItem = [];
    var DonationExamination = [];
    // ถ้าไม่ใช่ลงทะเบียนให้เก็บ Questionnaire, Deferral และ Examination
    if ($("#data").H2GAttr("lmenu") != "lmenuDonorRegis" && $("#data").H2GAttr("lmenu") != "lmenuEditDonorRegis") {
        create = 0;
        $('#tbQuestionnaire > tbody > tr').each(function (i, e) {
            DonorQuestionItem[create] = {
                ID: $(e).H2GAttr('refID'),
                QuestionID: $(e).H2GAttr('questID'),
                QuestionCode: $(e).H2GAttr('questCode'),
                QuestionDesc: $(e).H2GAttr('questDesc'),
                QuestionDescTH: $(e).H2GAttr('questDescTH'),
                Answer: $(e).H2GAttr('questAnswerType') == "PRESET" ? $(e).find(".td-answer select").H2GValue() : $(e).find(".td-answer input").H2GValue(),
                ParentID: $(e).H2GAttr('fromQuestion'),
            };
            create++;
        });
        create = 0;
        $('#tbDefInterview > tbody > tr').each(function (i, e) {
            DonorDeferralItem[create] = {
                ID: $(e).H2GAttr('refID'),
                DetailID: $(e).H2GAttr('detailID'),
                DeferralID: $(e).H2GAttr('defID'),
                StartDate: $(e).H2GAttr("defStartDate"),
                EndDate: $(e).H2GAttr('defEndDate'),
                Note: $(e).H2GAttr('defRemarks'),
                DonationTypeID: $("#ddlITVDonationType").H2GValue(),
                DeferralType: $(e).H2GAttr('defType'),
                Duration: $(e).H2GAttr('defDuration'),
                QuestionID: $(e).H2GAttr('questID'),
            };
            create++;
        });
        create = 0;
        $('#tbExam > tbody > tr').each(function (i, e) {
            DonationExamination[create] = {
                id: $(e).H2GAttr('refID'),
                examination_group_id: $(e).H2GAttr('groupID'),
                examination_group_desc: $(e).H2GAttr('groupDesc'),
                examination_id: $(e).H2GAttr("examID"),
                examination_desc: $(e).H2GAttr('examDesc'),
                question_id: $(e).H2GAttr('questID'),
            };
            create++;
        });
    }
    $.ajax({
        url: '../../ajaxAction/donorAction.aspx',
        data: H2G.ajaxData({
            action: 'savedonor',
            md: JSON.stringify(MasterDonor),
            dv: JSON.stringify(DonorVisit),
            dec: JSON.stringify(DonorExtCard),
            dc: JSON.stringify(DonorComment),
            dr: JSON.stringify(DonorRecord),
            dh: JSON.stringify(DonorHospital),
            dq: JSON.stringify(DonorQuestionItem),
            dd: JSON.stringify(DonorDeferralItem),
            de: JSON.stringify(DonationExamination),
            receipthospitalid: $("#data").H2GAttr("receiptHospitalID"),
        }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
            notiError("บันทึกไม่สำเร็จ : " + err);
            $("#btnSave").prop("disabled", false);
            $("#btnSaveOnlyDonor").prop("disabled", false);
        },
        success: function (data) {
            data.getItems = jQuery.parseJSON(data.getItems);
            if (!data.onError) {
                $("#data").H2GAttr("donorID", data.getItems.ID);
                $("#spRegisNumber").H2GAttr("visitID", data.getItems.VisitID)
                notiSuccess("บันทึกสำเร็จ");
                if ($("#spRegisNumber").H2GAttr("backToSearch") == "Y" || gotoRegister == true ) {
                    cancelRegis(this);
                } else {
                    showDonorData();
                }
            } else { notiError("บันทึกไม่สำเร็จ : " + data.exMessage); }
            $("#btnSave").prop("disabled", false);
            $("#btnSaveOnlyDonor").prop("disabled", false);
        }
    });    //End ajax
}

function checkGetStatusForDonation() {
    var thisMenu = $("#data").H2GAttr("lmenu");
    var thisStatus = $("#spStatus").H2GValue();
    if (thisMenu == "lmenuDonorRegis" && thisStatus == "REGISTER") {
        thisStatus = "WAIT INTERVIEW"
    } else if (thisMenu == "lmenuInterview" && thisStatus == "WAIT INTERVIEW") {
        thisStatus = "WAIT COLLECTION"
    } else if (thisMenu == "lmenulabRegis" && thisStatus == "WAIT INTERVIEW") {
        thisStatus = "WAIT RESULT"
    }
    return thisStatus;
}
function getReward(xobj) {
    var reward = '';
    // reward_id|reward_date##
    $(xobj).find(".txt-reward-date[donateRewardID='NEW']").each(function (i, e) {
        if ($(e).H2GValue() != "") {
            reward = reward + $(e).H2GAttr("rewardID") + "|" + $(e).H2GValue() + "##";
        }
    });
    return reward;
}
function validation() {
    if ($('#ddlTitleName').H2GValue() == "") {
        $("#ddlTitleName").closest("div").find("input").H2GFocus();
        notiWarning("กรุณาเลือกคำนำหน้าชื่อผู้บริจาค");
        return false;
    } else if ($('#txtDonorName').H2GValue() == "") {
        $("#txtDonorName").H2GFocus();
        notiWarning("กรุณากรอกชื่อผู้บริจาค");
        return false;
    } else if ($('#txtDonorSurName').H2GValue() == "") {
        $("#txtDonorSurName").H2GFocus();
        notiWarning("กรุณากรอกนามสกุลผู้บริจาค");
        return false;
        //} else if ($('#txtDonorNameEng').H2GValue() == "") {
        //    $("#txtDonorNameEng").H2GFocus();
        //    notiWarning("กรุณากรอกชื่อภาษาอังกฤษผู้บริจาค");
        //    return false;
        //} else if ($('#txtDonorSurNameEng').H2GValue() == "") {
        //    $("#txtDonorSurNameEng").H2GFocus();
        //    notiWarning("กรุณากรอกนามสกุลภาษาอังกฤษผู้บริจาค");
        //    return false;
    } else if ($('#txtBirthday').H2GValue() == "") {
        $("#txtBirthday").H2GFocus();
        notiWarning("กรุณากรอกวันเกิดผู้บริจาค");
        return false;
    } else if ($('#ddlOccupation').H2GValue() == "") {
        $("#ddlOccupation").closest("div").find("input").H2GFocus();
        notiWarning("กรุณาเลือกอาชีพผู้บริจาค");
        return false;
    } else if ($('#ddlNationality').H2GValue() == "") {
        $("#ddlNationality").closest("div").find("input").H2GFocus();
        notiWarning("กรุณาเลือกสัญชาติผู้บริจาค");
        return false;
    }
    //else if ($('#txtAddress').H2GValue() == "") {
    //    //$("#infoTabToday").tabs("option", "active", [0]);
    //    //$("#txtAddress").H2GFocus();
    //    //notiWarning("กรุณากรอกที่อยู่ผู้บริจาค");
    //    //return false;
    //}
    //else if ($('#txtSubDistrict').H2GValue() == "") {
    //    //$("#infoTabToday").tabs("option", "active", [0]);
    //    //$("#txtSubDistrict").H2GFocus();
    //    //notiWarning("กรุณากรอกแขวง/ตำบลผู้บริจาค");
    //    //return false;
    //}
    //else if ($('#txtDistrict').H2GValue() == "") {
    //    //$("#infoTabToday").tabs("option", "active", [0]);
    //    //$("#txtDistrict").H2GFocus();
    //    //notiWarning("กรุณากรอกเขต/อำเภอผู้บริจาค");
    //    //return false;
    //}
    //else if ($('#txtProvince').H2GValue() == "") {
    //    //$("#infoTabToday").tabs("option", "active", [0]);
    //    //$("#txtProvince").H2GFocus();
    //    //notiWarning("กรุณากรอกจังหวัดผู้บริจาค");
    //    //return false;
    //}
    //else if ($('#txtZipcode').H2GValue() == "") {
    //    //$("#infoTabToday").tabs("option", "active", [0]);
    //    //$("#txtZipcode").H2GFocus();
    //    //notiWarning("กรุณากรอกรหัสไปรษณีย์ผู้บริจาค");
    //    return false;
    //}
    else if ($('#ddlCountry').H2GValue() == "") {
        $("#infoTabToday").tabs("option", "active", [0]);
        $("#ddlCountry").closest("div").find("input").H2GFocus();
        notiWarning("กรุณาเลือกประเทศผู้บริจาค");
        return false;
    //} else if ($('#txtMobile1').H2GValue() == "") {
    //    $("#infoTabToday").tabs("option", "active", [0]);
    //    $("#txtMobile1").H2GFocus();
    //    notiWarning("กรุณากรอกเบอร์โทรศัพท์มือถือผู้บริจาค");
    //    return false;
    } else if (checkEmail()) {
        $("#infoTabToday").tabs("option", "active", [0]);
        $("#txtEmail").H2GFocus();
        notiWarning("กรุณากรอกอีเมลให้ถูกต้อง");
        return false;
    } else if ($('#ddlAssociation').H2GValue() == "") {
        $("#infoTabToday").tabs("option", "active", [0]);
        $("#ddlAssociation").closest("div").find("input").H2GFocus();
        notiWarning("กรุณากรอกรหัสเชื่อมโยงโรงพยาบาลในเครือ");
        return false;
    } else if (interviewValidation()) {
        // ไม่ผ่านการตรวจสอบ tab คัดกรอง
        $("#infoTabToday").tabs("option", "active", 2);
        return false;
    }

    return true;
}
function checkEmail() {
    if ($('#txtEmail').H2GValue() != "") {
        if (!H2G.IsEmail($('#txtEmail').H2GValue())) {
            return true;
        }
    }
}
function interviewValidation() {
    // ตรวจสอบการกรอกข้อมูล
    if ($("#data").H2GAttr("lmenu") == "lmenuInterview") {
        if (notAllAnswer()) {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#tbQuestionnaire > tbody > tr select:first").closest("div").H2GFocus();
            notiWarning("กรุณาตอบคำถามให้ครบทุกข้อ");
            return true;
        } else if ($("#txtWeight").H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#txtWeight").H2GFocus()
            notiWarning("กรุณากรอกน้ำหนัก");
            return true;
        //} else if ($("#txtHeartRate").H2GValue() == "") {
        //    $("#infoTabToday").tabs("option", "active", [2]);
        //    $("#txtHeartRate").H2GFocus()
        //    notiWarning("กรุณากรอกอัตราชีพจร");
        //    return true;
        } else if ($("#txtPresureMax").H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#txtPresureMax").H2GFocus()
            notiWarning("กรุณากรอกความดันสูงสุด");
            return true;
        } else if ($("#txtPresureMin").H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#txtPresureMin").H2GFocus()
            notiWarning("กรุณากรอกความดันต่ำสุด");
            return true;
        } else if ($('#ddlHbTest').H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#ddlHbTest").closest("div").H2GFocus();
            notiWarning("กรุณาเลือก Hb Test");
            return true;
        } else if ($('#ddlHbTest').H2GValue() == "P" && $("#spRegisNumber").H2GAttr("visitnumber") == "1" && $("#txtHeartLung").H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#txtHeartLung").H2GFocus();
            notiWarning("กรุณาเลือกกรอกการตรวจหัวใจและปอด");
            return true;
        } else if ($("#txtHb").H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#txtHb").H2GFocus()
            notiWarning("กรุณากรอก Hb");
            return true;
        } else if ($('#ddlITVResult').H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#ddlITVResult").closest("div").H2GFocus();
            notiWarning("กรุณาเลือกผลการตรวจคัดกรอง");
            return true;
        } else if ($('#ddlITVDonationType').H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#ddlITVDonationType").closest("div").H2GFocus();
            notiWarning("กรุณาเลือกประเภทการบริจาค");
            return true;
        } else if ($('#ddlITVBag').H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#ddlITVBag").closest("div").H2GFocus();
            notiWarning("กรุณาเลือกประเภทถุง");
            return true;
        } else if ($('#ddlITVDonationTo').H2GValue() == "") {
            $("#infoTabToday").tabs("option", "active", [2]);
            $("#ddlITVDonationTo").closest("div").H2GFocus();
            notiWarning("กรุณาเลือกการนำไปใช้งาน");
            return true;
        }
    }
    return false;
}
function notAllAnswer() {
    var quest = $("#tbQuestionnaire > tbody > tr:visible");
    var notanswer = false;
    $.each((quest), function (index, e) {
        if ($(e).find("input").H2GValue() == "" && ($(e).find("select").H2GValue() == "")) {
            notanswer = true;
            return false; // brake loop
        }
    });
    return notanswer;
}
function showDonorData() {
    $.ajax({
        url: '../../ajaxAction/donorAction.aspx',
        data: H2G.ajaxData({
            action: 'selectregister',
            id: $("#data").H2GAttr("donorID"),
            visit_id: $("#spRegisNumber").H2GAttr("visitID"), 
            donationhospitalid: $("#data").H2GAttr("receiptHospitalID") ? $("#spRegisNumber").H2GAttr("visitID") : "",
            receipthospitalid: $("#data").H2GAttr("receiptHospitalID"),
        }).config,
        type: "POST",
        dataType: "json",
        beforeSend: function () {
            //$('#tbVisitHistory > tbody').block();
        },
        error: function (xhr, s, err) {
            //$('#tbVisitHistory > tbody').unblock();
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
                    visitNumber: data.getItems.Donor.VisitNumber,
                    sampleNumber: data.getItems.Donor.SampleNumber,
                    donateCount: data.getItems.Donor.DonateCount,
                });

                $("#spVisitCount").H2GValue("รวมจำนวนการเข้าพบ " + data.getItems.Donor.VisitNumber + " ครั้ง / บริจาค " + data.getItems.Donor.DonateCount + "(" + data.getItems.Donor.DonateNumber + "+" + data.getItems.Donor.DonateNumberExt + ") ครั้ง");
                $("#spVisitInfo").H2GValue("วันที่ลงทะเบียน " + data.getItems.Donor.VisitDateTimeText + " เข้าพบครั้งสุดท้ายเมื่อ " + data.getItems.Donor.LastVisitDateText + " ( " + data.getItems.Donor.DiffDate + " วัน ) กำลังดำเนินการบริจาคครั้งที่ " + data.getItems.Donor.CurrentDonateNumber)
                    .H2GFill({
                        visitDateText: data.getItems.Donor.VisitDateText,
                        lastVisitDateText: data.getItems.Donor.LastVisitDateText,
                        diffDate: data.getItems.Donor.DiffDate,
                        currentDonateNumber: data.getItems.Donor.CurrentDonateNumber,
                        visitDate: data.getItems.Donor.VisitDate
                    });

                $("#infoTab > ul > li > a[href='#todayPane']").H2GValue("2) " + data.getItems.Donor.VisitDateText)

                $("#spRegisNumber").H2GValue(data.getItems.Donor.DonorNumber);
                $("#spQueue").H2GValue(data.getItems.Donor.QueueNumber == "" ? "-" : "คิวที่ " + data.getItems.Donor.QueueNumber).H2GAttr("queueNumber", data.getItems.Donor.QueueNumber);
                if ($("#data").H2GAttr("receiptHospitalID")) { $("#spQueue").H2GValue($("#spQueue").H2GValue().replace("คิวที่", "ลำดับที่"));}
                $("#spStatus").H2GValue(data.getItems.Donor.Status);
                //if (data.getItems.Donor.Status == "REGISTER") { $("#btnSave").val("ลงทะเบียน"); } else { $("#btnSave").val("บันทึก"); }

                $("input:radio[name=gender]").prop("checked", false);
                if (data.getItems.Donor.Gender == "M") { $("#rbtM").prop("checked", true); } else { $("#rbtF").prop("checked", true); }
                $("#divBloodType").H2GValue(data.getItems.Donor.RHGroup);
                $("#txtDonorName").H2GValue(data.getItems.Donor.Name);
                $("#txtDonorSurName").H2GValue(data.getItems.Donor.Surname);
                if (data.getItems.Donor.NameE == "" && data.getItems.Donor.SurnameE == "") {
                    $("#txtDonorNameEng").H2GDisable();
                    $("#txtDonorSurNameEng").H2GDisable();
                    $("#chbLatinName").prop("checked",false);
                } else {
                    $("#txtDonorNameEng").H2GEnable();
                    $("#txtDonorSurNameEng").H2GEnable();
                    $("#chbLatinName").prop("checked", true);
                }
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
                $("#ddlCollectionPoint").H2GAttr("selectItem", data.getItems.Donor.ForCollectionPointID);
                $("#ddlAssociation").H2GAttr("selectItem", data.getItems.Donor.AssociationID);

                //### Tab คัดกรอง
                if (data.getItems.Donor.LastWeight != "") { $("#spLastWeight").H2GValue(data.getItems.Donor.LastWeight + " kg"); }
                if (data.getItems.Donor.LastVisit != "") { $("#spLastDateWeight").H2GValue("เมื่อ " + data.getItems.Donor.LastVisit); }
                $("#txtWeight").H2GValue(data.getItems.Donor.Weight);
                $("#txtPresureMax").H2GValue(data.getItems.Donor.PressureMax);
                $("#txtPresureMin").H2GValue(data.getItems.Donor.PressureMin);
                $("#txtHb").H2GValue(data.getItems.Donor.HB);
                $("#txtPlt").H2GValue(data.getItems.Donor.PLT);
                $("#txtHeartLung").H2GValue(data.getItems.Donor.HeartLung);
                $("#txtHeartRate").H2GValue(data.getItems.Donor.HeartRate);
                $("#ddlITVDonationType").H2GAttr("selectItem", data.getItems.Donor.DonationTypeID);
                $("#ddlITVBag").H2GAttr("selectItem", data.getItems.Donor.BagID);
                $("#ddlITVDonationTo").H2GAttr("selectItem", data.getItems.Donor.DonationToID);
                $("#ddlHbTest").H2GValue(data.getItems.Donor.HBTest);
                $("#ddlITVResult").H2GValue(data.getItems.Donor.InterviewStatus);
                
                //### External Card
                $('#divCardNumber').H2GValue("");
                $.each((data.getItems.ExtCard), function (index, e) {
                    var spExtCard = $("#divCardNumberTemp").children().clone();
                    $(spExtCard).H2GFill({ refID: e.ID, donorID: e.DonorID, extID: e.ExternalCardID, cardNumber: e.CardNumber }).find(".ext-number").H2GValue(e.CardName + " : " + e.CardNumber);
                    $('#divCardNumber').append(spExtCard);
                    //if (e.ExternalCardID == "3") { $('#txtCardNumber').H2GValue(e.CardNumber) }
                });

                //### Deferral
                if (data.getItems.Deferral.length > 0) {
                    var dataView = $("#tbDeferral > tbody").H2GValue('');
                    $.each((data.getItems.Deferral), function (index, e) {
                        var dataRow = $("#tbDeferral > thead > tr.template-data").clone().show();
                        if (e.Status == "INACTIVE") { dataRow.hide(); }
                        $(dataRow).H2GAttr('status', e.Status);
                        $(dataRow).find('.td-def-code').append(e.Code).H2GAttr("title", e.Code);
                        $(dataRow).find('.td-def-date').append(e.EndDate).H2GAttr("title", e.EndDate);
                        $(dataRow).find('.td-def-description').append(e.Description).H2GAttr("title", e.Description);
                        $(dataRow).find('.td-def-status').append(e.DeferralType).H2GAttr("title", e.DeferralType);
                        $(dataView).append(dataRow);
                    });
                }

                //### Visit Info
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
                $('#divDonateRecord').H2GRemoveAttr("rewardList").H2GValue("");
                var candelete = true;
                data.getItems.DonationRecord.sort(H2G.keysrt('DonateNumber', true));
                $.each((data.getItems.DonationRecord), function (index, e) {
                    var spRecord = $("#divDonateRecordTemp").children().clone();
                    $(spRecord).H2GFill({ refID: e.ID, donatedate: e.DonateDate, donatenumber: e.DonateNumber, donatefrom: e.DonateFrom });
                    $(spRecord).find("span.rec-text").H2GValue("ครั้งที่ " + e.DonateNumber + " บริจาควันที่ " + e.DonateDateText + (e.DonateFrom == "EXTERNAL" ? " ณ โรงพยาบาลนอกเครือข่าย" : " ณ โรงพยาบาลในเครือข่าย"));
                    //มี Reward ต้องแสดง
                    if (e.DonateReward != "") {
                        var rewardRec = e.DonateReward.split('##');
                        $.each((rewardRec), function (indexr, er) {
                            if (er != "") {
                                var rewardInfo = er.split("|");
                                // reward_id|reward_desc|donation_reward_id|reward_date
                                var rewardList = $('#divDonateRecord').H2GAttr("rewardList") || '';
                                if (rewardList.indexOf("," + rewardInfo[0] + ",") == -1) {
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
                                        }).H2GDatebox({ allowFutureDate: false }).H2GValue(rewardInfo[3]);
                                    }
                                    $(spRecord).append($(rowReward).children());
                                    $('#divDonateRecord').H2GAttr("rewardList", rewardList + "," + rewardInfo[0] + ",")
                                }
                            }
                        });
                    }
                    if (e.DonateFrom == "INTERNAL" && candelete) { candelete = false; }
                    if (candelete) { $(spRecord).find("a.icon").show(); candelete = false; }
                    $('#divDonateRecord').append(spRecord).H2GAttr("lastrecord", data.getItems.Donor.DonateCount);
                });
                
                //### Donation Question
                $('#tbQuestionnaire > tbody').H2GValue("");
                $.each((data.getItems.QuestionList), function (index, e) {
                    var dataRow = $("#tbQuestionnaire > thead > tr.template-data").clone().show();
                    $(dataRow).H2GFill({
                        refID: e.ID,
                        questID: e.QuestionID,
                        questCode: e.QuestionCode,
                        questAnswerType: e.AnswerType,
                        questPreset: e.Preset,
                        fromQuestion: e.ParentID,
                        questDesc: e.QuestionDesc,
                        questDescTH: e.QuestionDescTH,
                    });
                    if ($('#ddlQuestLanguage').H2GValue() == "English") { $(dataRow).find(".td-question span").H2GValue(e.QuestionDesc); }
                    else { $(dataRow).find(".td-question span").H2GValue(e.QuestionDescTH); }
                    if (e.AnswerType == "PRESET") {
                        var selectPreset = $(dataRow).find(".td-answer select").show();
                        var preset = e.Preset.split(",");
                        preset.sort();
                        $("<option>", { value: '', text: 'กรุณาเลือก' }).appendTo(selectPreset);
                        $.each((preset), function (indexs, es) {
                            $("<option>", { value: es, text: es }).appendTo(selectPreset);
                        });
                        //$(selectPreset).setDropdownList().H2GValue(e.Answer).change().on('change', function () {
                        //    //ให้เอาคำตอบไปหาคำถามต่อไป
                        //    selectNextQuestion($(this).closest("tr").H2GAttr("questID"), $(this).H2GValue());
                        //});
                        $(selectPreset).setAutoList({
                            //ให้เอาคำตอบไปหาคำถามต่อไป
                            selectItem: function () {
                                selectNextQuestion($(this).closest("tr").H2GAttr("questID"), $(this).H2GValue());
                            }
                        }).H2GValue(e.Answer);
                    } else {
                        $(dataRow).find(".td-answer input").show().H2GValue(e.Answer);
                        if (e.AnswerType == "DATE") {
                            $(dataRow).find(".td-answer input").setCalendar({
                                maxDate: "+100y",
                                minDate: "-100y",
                                yearRange: "c-50:c+50",
                            });
                        }
                    }
                    $("#tbQuestionnaire > tbody").append(dataRow);
                });

                //### Donor Deferral
                $('#tbDefInterview > tbody').H2GValue("");
                $.each((data.getItems.DonorDeferral), function (index, er) {
                    var dataRow = $("#tbDefInterview > thead > tr.template-data").clone().show();
                    $(dataRow).H2GFill({
                        refID: er.ID,
                        detailID: er.DetailID,
                        defID: er.DeferralID,
                        defType: er.DeferralType,
                        defDuration: er.Duration,
                        defStartDate: er.StartDate,
                        defEndDate: er.EndDate,
                        defRemarks: er.Note,
                        questID: er.QuestionID,
                    });
                    
                    $(dataRow).find('.td-description').append(er.Desc).H2GAttr("title", er.Desc);
                    $(dataRow).find('.td-enddate').append('วันที่สิ้นสุด ' + formatDate(new Date(getDateFromFormat(er.EndDate, 'dd/mm/yyyy')), "dd NNN yyyy")).H2GAttr("title", 'วันที่สิ้นสุด ' + formatDate(new Date(getDateFromFormat(er.EndDate, 'dd/mm/yyyy')), "dd NNN yyyy"));
                    if (er.QuestionID != "") {
                        $(dataRow).find('.glyphicon-remove').closest("a").hide();
                    }
                    $("#tbDefInterview > tbody").append(dataRow);
                });

                //### Donation Examination
                $('#tbExam > tbody').H2GValue("");
                $.each((data.getItems.DonationExam), function (index, e) {
                    var dataRow = $("#tbExam > thead > tr.template-data").clone().show();
                    $(dataRow).H2GFill({
                        refID: e.id,
                        examID: e.examination_id,
                        examCode: e.examination_code,
                        desc: e.examination_desc,
                        groupID: e.examination_group_id,
                        groupCode: e.examination_group_code,
                        groupDesc: e.examination_group_desc,
                        questID: e.question_id,
                    });
                    $(dataRow).find('.td-exam').append(e.examination_code + ' : ' + e.examination_desc).H2GAttr("title", e.examination_code + ' : ' + e.examination_desc);
                    if (e.question_id != "") {
                        $(dataRow).find('.glyphicon-remove').closest("a").hide();
                    }
                    $("#tbExam > tbody").append(dataRow);
                });
                
                if ($("#spRegisNumber").H2GAttr("visitID") != undefined) { $("#btnSave").H2GValue("บันทึก"); }
                $("#txtCardNumber").H2GFocus();
            } else { }
            donorSelectDDL();
            lookupTabQuestionaire();
            showVisitHistory();
            //$('#tbVisitHistory > tbody').unblock();
            $("#btnSave").prop("disabled", false);
        }
    });    //End ajax
}
function cancelRegis(xobj) {
    $("#data").H2GRemoveAttr("donorID,visitID");
    var target = "search.aspx";
    if ($("#data").H2GAttr("lmenu") == "lmenuInterview" || $("#data").H2GAttr("lmenu") == "lmenuHistoryReport") { target = "historyReport.aspx" }
    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: target, method: "post" }).submit();
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
        beforeSend: function () {
            //$('body').block();
        },
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            data.getItems = jQuery.parseJSON(data.getItems);
            // console.log("Respondata = ", data.getItems);
            if (!data.onError) {
                datas = data.getItems;
                if (datas.length > 0) {
                    $("tr").remove(".no-transactionHistoricalFile");
                } else {
                    $("tr").remove(".no-transactionHistoricalFile");
                    $('#historicalFileTable > tbody').append("<tr class='no-transactionHistoricalFile'><td align='center' colspan='9'>ไม่พบข้อมูล</td></tr>");
                }
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
                $("#historicalFileTable").tablesorter({ dateFormat: "uk" });
            }
            //$('body').unblock();
        }
    });
}

function setImmunohaemtologyFile() {
    function getSet1() {
        //console.log("do set1");
        var deferred = $.Deferred();

        //$('#blockImmunohaemtologyFile').block({
        //    centerX: false,
        //    centerY: false
        //});

        $.ajax({
            url: '../../ajaxAction/donorAction.aspx',
            data: H2G.ajaxData({ action: 'immunohaemtologyDataSet1', donn_numero: $("#spRegisNumber").H2GValue() }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("Can't grt set 1");
            },
            success: function (data) {
                data.getItems = jQuery.parseJSON(data.getItems);
                //console.log("Respondata exams = ", data.getItems);
                if (!data.onError) {
                    var data = data.getItems;
                    if (data.length > 0) {
                        for (var i = 0; i < data.length; i++) {
                            data[i].Rsx_Lib = data[i].Rsx_Lib.replace(" ", "_");
                            data[i].Rsx_Cd = data[i].Rsx_Cd.substring(0, 2);

                            $("#" + data[i].Rsx_Lib + "_" + data[i].Rsx_Cd).val(data[i].Dex_Res);
                        }
                    }
                    deferred.resolve("Ok");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("Can't grt set 1");
                }
            }
        });
        return deferred.promise();
    }
        
    function getSet2() {
        //console.log("do set2");
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/donorAction.aspx',
            data: H2G.ajaxData({ action: 'immunohaemtologyDataSet2', donn_numero: $("#spRegisNumber").H2GValue() }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                //$('#blockImmunohaemtologyFile').unblock();
                deferred.reject("Can't grt set 2");
            },
            success: function (data) {
                data.getItems = jQuery.parseJSON(data.getItems);
                // console.log("Respondata exams = ", data.getItems);
                if (!data.onError) {
                    var dataz = data.getItems;
                    if (dataz.length > 0) {
                        for (var i = 0; i < dataz.length; i++) {
                            dataz[i].Rsx_Lib = dataz[i].Rsx_Lib.replace(" ", "_");

                            $("#" + dataz[i].Rsx_Lib + "_RESULT").val(dataz[i].Result_Decode);
                        }
                        deferred.resolve("Ok");
                    } else {
                        console.log("Error = ", data.exMessage);
                        deferred.reject("Can't grt set 2");
                    }
                }
                //$('#blockImmunohaemtologyFile').unblock();
            }
        });
        return deferred.promise();
    }

    function getDateData() {
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/donorAction.aspx',
            data: H2G.ajaxData({ action: 'immunohaemtologyDataSetDate', donn_numero: $("#spRegisNumber").H2GValue() }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("Error getDateData");
            },
            success: function (data) {
                data.getItems = jQuery.parseJSON(data.getItems);
                if (!data.onError) {
                    var dataz = data.getItems;
                    if (dataz.abod.length > 0) {
                        $("#ABOD_NO").val(dataz.abod[0].no);
                        $("#ABOD_FIRST_DATE").val(dataz.abod[0].firstDate);
                        $("#ABOD_LAST_DATE").val(dataz.abod[0].lastDate);
                    }

                    if (dataz.extPheno.length > 0) {
                        $("#Ext_Pheno_NO").val(dataz.extPheno[0].no);
                        $("#Ext_Pheno_FIRST_DATE").val(dataz.extPheno[0].firstDate);
                        $("#Ext_Pheno_LAST_DATE").val(dataz.extPheno[0].lastDate);
                    }

                    if (dataz.extPheno.length > 0) {
                        $("#Ab_Screen_NO").val(dataz.abScreen[0].no);
                        $("#Ab_Screen_FIRST_DATE").val(dataz.abScreen[0].firstDate);
                        $("#Ab_Screen_LAST_DATE").val(dataz.abScreen[0].lastDate);
                    }
                    console.log("sdcg = ", dataz);
                    deferred.resolve("Ok");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("Error getDateData");
                }
            }
        });
        return deferred.promise();
    }

    getSet1()
    .then(getSet2)
    .done(getDateData)
    .fail(function (err) {
        console.log(err);
    });

}

function setExamsDatas() {
    $("tr").remove(".exams-tab-table-row");
    var datas = [];

    $.ajax({
        url: '../../ajaxAction/donorAction.aspx',
        data: H2G.ajaxData({ action: 'examsData', donn_numero: $("#spRegisNumber").H2GValue() }).config,
        type: "POST",
        dataType: "json",
        beforeSend: function () {
            //$('body').block();
        },
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            // console.log("xxxx = ", data);
            data.getItems = jQuery.parseJSON(data.getItems);
            // console.log("Respondata exams = ", data.getItems);
            if (!data.onError) {
                datas = data.getItems;
                if (datas.length > 0) {
                    $("tr").remove(".no-transactionExams");
                } else {
                    $("tr").remove(".no-transactionExams");
                    $('#exams-tab-table > tbody').append("<tr class='no-transactionExams'><td align='center' colspan='10'>ไม่พบข้อมูล</td></tr>");
                }
                for (var i = 0; i < datas.length; i++) {
                    var rows = "<tr class='exams-tab-table-row'>" +
                                    "<td class='text-right td-number-excel'>" + datas[i].DonnIncr + "</td>" +
                                    "<td class='text-center td-date-excel'>" + datas[i].LabDate + "</td>" +
                                    "<td class='text-center td-text-excel'>" + datas[i].PrelNo + "</td>" +
                                    "<td class='text-left td-text-excel'>" + datas[i].PexLibAff + "</td>" +
                                    "<td class='text-left td-text-excel'>" + datas[i].PresAff + "</td>" +
                                    "<td class='text-left td-text-excel'>" + datas[i].TestBy1 + "</td>" +
                                    "<td class='text-left td-text-excel'>" + datas[i].TestBy2 + "</td>" +
                                    "<td class='text-left td-text-excel'>" + datas[i].TestBy3 + "</td>" +
                                    "<td class='text-left td-text-excel'>" + datas[i].ExecutingLab + "</td>" +
                                    "<td class='text-center td-text-excel'>" + datas[i].PcatdLib + "</td>" +
                                "</tr>";
                    $('#exams-tab-table > tbody').append(rows);
                }
                $("#exams-tab-table").tablesorter({ dateFormat: "uk" });
            }
            //$('body').unblock();
        }
    });
}
function enterDatePickerDonateRecord(dateControl, action) {
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
            $(dateControl).H2GFocus();
        }
    } else {
        $(dateControl).H2GAttr('donatedatetext', '');
    }
}
function showVisitHistory() {
    var dataView = $("#tbVisitHistory > tbody");
    $(dataView).H2GValue($("#tbVisitHistory > thead > tr.more-loading").clone().show());
    if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
        $(dataView).closest("table").H2GAttr("wStatus", "working");
        $.ajax({
            url: '../../ajaxAction/donorAction.aspx',
            data: H2G.ajaxData({
                action: 'visithistory'
                , id: $("#data").H2GAttr("donorID")
                , so: $("#tbVisitHistory").attr("sortOrder") || "visit_date"
                , sd: $("#tbVisitHistory").attr("sortDirection") || "desc"
            }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                $(dataView).H2GValue($("#tbVisitHistory > thead > tr.no-transaction").clone().show());
                $(dataView).closest("table").H2GAttr("wStatus", "error");
            },
            success: function (data) {
                $(dataView).H2GValue('');
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    //### Visit History
                    if (data.getItems.length > 0) {
                        $.each((data.getItems), function (index, e) {
                            var dataRow = $("#tbVisitHistory > thead > tr.template-data").clone().show();
                            $(dataRow).H2GFill({ refID: e.VisitID });
                            $(dataRow).find('.txt-donate-number').H2GValue(e.DonationNumber).H2GAttr("title", e.DonationNumber);
                            $(dataRow).find('.txt-visit-date').H2GValue(e.VisitDate).H2GAttr("title", e.VisitDate);
                            $(dataRow).find('.txt-donate-type').H2GValue(e.DonationType).H2GAttr("title", e.DonationType);
                            $(dataRow).find('.txt-bag-type').H2GValue(e.Bag).H2GAttr("title", e.Bag);
                            $(dataRow).find('.txt-site').H2GValue(e.Site).H2GAttr("title", e.Site);
                            $(dataRow).find('.txt-collection-point').H2GValue(e.CollectionPoint).H2GAttr("title", e.CollectionPoint);
                            $(dataRow).find('.txt-regis-by').H2GValue(e.CreateStaff).H2GAttr("title", e.CreateStaff);
                            $(dataRow).find('.txt-collection-by').H2GValue(e.InterviewStaff).H2GAttr("title", e.InterviewStaff);
                            $(dataRow).find('.txt-collection-result').H2GValue(e.InterviewStatus).H2GAttr("title", e.InterviewStatus);
                            $(dataRow).find('.txt-lab-date').H2GValue(e.LabDate).H2GAttr("title", e.LabDate);
                            $(dataRow).find('.txt-sample-number').H2GValue(e.SampleNumber).H2GAttr("title", e.SampleNumber);

                            $(dataView).append(dataRow);
                        });
                    } else {
                        $(dataView).H2GValue($("#tbVisitHistory > thead > tr.no-transaction").clone().show());
                    }
                } else {
                    $(dataView).H2GValue($("#tbVisitHistory > thead > tr.no-transaction").clone().show());
                }
                $("#tbVisitHistory thead button").click(function () { sortButton($(this), showVisitHistory); return false; });
                $(dataView).closest("table").H2GAttr("wStatus", "done");
            }
        });    //End ajax
    }
}

function loadSynthesisLink() {
    // console.log("Yessss");
    $.ajax({
        url: '../../ajaxAction/donorAction.aspx',
        data: H2G.ajaxData({ action: 'loadSynthesisSet1',donn_numero: $("#spRegisNumber").H2GValue() }).config,
        type: "POST",
        dataType: "json",
        beforeSend: function () {
           // $('body').block();
        },
        error: function (xhr, s, err) {
            console.log(s, err);
           // $('body').unblock();
        },
        success: function (data) {
            if (!data.onError) {
                $("tr").remove(".synthesisStandard-row");
                $("tr").remove(".synthesisVirology-row");
                $("tr").remove(".synthesisImmunohematology-row");
                data.getItems = jQuery.parseJSON(data.getItems);
                datas = data.getItems.SynthesisSet1;
                console.log("xxxx = ", datas);
                
                if (datas.length > 0) {
                    $("tr").remove(".no-transactionSynthesisStandard");
                    $("tr").remove(".no-transactionSynthesisVirology");
                    $("tr").remove(".no-transactionSynthesisImmunohematology");

                    var siteSet = []

                    for (var i = 0; i < datas.length; i++) {
                        if (datas[i].dornor_type != "Refused") {
                            siteSet.push(datas[i]);
                        }
                        var rows = "<tr class='synthesisStandard-row'>" +
                                        "<td class='text-center td-date-excel date-" + datas[i].dornor_rank + "'>" + datas[i].donate_date + "</td>" +
                                        "<td class='text-center td-text-excel type-" + datas[i].dornor_rank + "'>" + datas[i].dornor_type + "</td>" +
                                        "<td class='text-center td-text-excel donateat-" + datas[i].dornor_rank + "'>" + datas[i].dmed_coll + "</td>" +
                                        "<td class='text-left td-text-excel cantdonate-" + datas[i].dornor_rank + "'>" + datas[i].dmed_refus + "</td>" +
                                        "<td class='text-left td-text-excel rank-" + datas[i].dornor_rank + "'>" + datas[i].dornor_rank + "</td>" +
                                        "<td class='text-left td-text-excel pressure-" + datas[i].dornor_rank + "'>" + datas[i].pressure + "</td>" +
                                        "<td class='text-left td-text-excel ABOD-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel DAT-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel DATF-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Anti-HBs-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Lipemic-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel DAbsp-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel HBsAg-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Anti-HCV-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Syph-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel COMNAT-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Albumin-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Protein-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Ag-C-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Ag-c-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Ag-E-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Ag-e-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Ag-K-" + datas[i].dornor_rank + "'></td>" +
                                    "</tr>";
                        // console.log("Row = ", rows);
                        $('#synthesisStandard > tbody').append(rows);



                        var rows2 = "<tr class='synthesisVirology-row'>" +
                                        "<td class='text-center td-date-excel date-" + datas[i].dornor_rank + "'>" + datas[i].donate_date + "</td>" +
                                        "<td class='text-center td-text-excel type-" + datas[i].dornor_rank + "'>" + datas[i].dornor_type + "</td>" +
                                        "<td class='text-center td-text-excel donateat-" + datas[i].dornor_rank + "'>" + datas[i].dmed_coll + "</td>" +
                                        "<td class='text-left td-text-excel cantdonate-" + datas[i].dornor_rank + "'>" + datas[i].dmed_refus + "</td>" +
                                        "<td class='text-left td-text-excel rank-" + datas[i].dornor_rank + "'>" + datas[i].dornor_rank + "</td>" +
                                        "<td class='text-left td-text-excel pressure-" + datas[i].dornor_rank + "'>" + datas[i].pressure + "</td>" +
                                        "<td class='text-left td-text-excel ALAT-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel WB-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Anti-HCV-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Malaria-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                    "</tr>";
                        // console.log("Row = ", rows);
                        $('#synthesisVirology > tbody').append(rows2);


                        var rows3 = "<tr class='synthesisImmunohematology-row'>" +
                                        "<td class='text-center td-date-excel date-" + datas[i].dornor_rank + "'>" + datas[i].donate_date + "</td>" +
                                        "<td class='text-center td-text-excel type-" + datas[i].dornor_rank + "'>" + datas[i].dornor_type + "</td>" +
                                        "<td class='text-center td-text-excel donateat-" + datas[i].dornor_rank + "'>" + datas[i].dmed_coll + "</td>" +
                                        "<td class='text-left td-text-excel cantdonate-" + datas[i].dornor_rank + "'>" + datas[i].dmed_refus + "</td>" +
                                        "<td class='text-left td-text-excel rank-" + datas[i].dornor_rank + "'>" + datas[i].dornor_rank + "</td>" +
                                        "<td class='text-left td-text-excel pressure-" + datas[i].dornor_rank + "'>" + datas[i].pressure + "</td>" +
                                        "<td class='text-left td-text-excel ABO-group-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel ABO-group-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel C-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel c-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel E-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel e-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel K-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Ab-Sc-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel H-AB-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Hem-A-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel Hb-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel BW-" + datas[i].dornor_rank + "'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                        "<td class='text-left td-text-excel'></td>" +
                                    "</tr>";

                        $('#synthesisImmunohematology > tbody').append(rows3);
                    }
                    // $(".E-4").text("test");
                    displaySynthesisColData(data.getItems.SynthesisSet2);
                    siteAnddateSet(siteSet);
                } else {
                    $("tr").remove(".no-transactionSynthesisStandard");
                    $('#synthesisStandard > tbody').append("<tr class='no-transactionSynthesisStandard'><td align='center' colspan='23'>ไม่พบข้อมูล</td></tr>");

                    $("tr").remove(".no-transactionSynthesisVirology");
                    $('#synthesisVirology > tbody').append("<tr class='no-transactionSynthesisVirology'><td align='center' colspan='23'>ไม่พบข้อมูล</td></tr>");

                    $("tr").remove(".no-transactionSynthesisImmunohematology");
                    $('#synthesisImmunohematology > tbody').append("<tr class='no-transactionSynthesisImmunohematology'><td align='center' colspan='23'>ไม่พบข้อมูล</td></tr>");
                }
                
            }
            //$('body').unblock();
        }
    });
}

function displaySynthesisColData(datas) {
    // console.log("displaySynthesisColData = ", datas);
    for (var i = 0; i < datas.length; i++) {
        $("." + datas[i].show_gen_label).text(datas[i].display_result);
    }
}

function siteAnddateSet(data) {
    console.log("siteAnddateSet = ", data);
    var lastIndexdate = data.length - 1;
    $(".firstDonateWhen").text(data[lastIndexdate].donate_date);
    $(".lastDonateWhen").text(data[0].donate_date);

    // data[lastIndexdate].dmed_coll = '0A0000';
    if (data[lastIndexdate].dmed_coll != "") {
        $.ajax({
            url: '../../ajaxAction/donorAction.aspx',
            data: H2G.ajaxData({ action: 'getDonateSite', siteCode: data[lastIndexdate].dmed_coll }).config,
            type: "POST",
            dataType: "json",
            beforeSend: function () {
                //$('body').block();
            },
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                data.getItems = jQuery.parseJSON(data.getItems);
                if (!data.onError) {
                    $(".firstDonateAt").text(data.getItems.site)
                }
                //$('body').unblock();
            }
        });
    }


    if (data[0].dmed_coll != "") {
        $.ajax({
            url: '../../ajaxAction/donorAction.aspx',
            data: H2G.ajaxData({ action: 'getDonateSite', siteCode: data[0].dmed_coll }).config,
            type: "POST",
            dataType: "json",
            beforeSend: function () {
                //$('body').block();
            },
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                data.getItems = jQuery.parseJSON(data.getItems);
                if (!data.onError) {
                    $(".lastDonateAt").text(data.getItems.site)
                }
                //$('body').unblock();
            }
        });
    }
}

function selecterTable(even){
    // console.log("Select Table = ", $("#chackType").val());
    if ($("#chackType").val() == "standard") {
        $("#synthesisStandard").css({ "display": "block" });
        $("#synthesisVirology").css({ "display": "none" });
        $("#synthesisImmunohematology").css({ "display": "none" });
    } else if ($("#chackType").val() == "virology") {
        $("#synthesisStandard").css({ "display": "none" });
        $("#synthesisVirology").css({ "display": "block" });
        $("#synthesisImmunohematology").css({ "display": "none" });
    } else if ($("#chackType").val() == "immunohematology") {
        $("#synthesisStandard").css({ "display": "none" });
        $("#synthesisVirology").css({ "display": "none" });
        $("#synthesisImmunohematology").css({ "display": "block" });
    }
}

function stickerPrint() {
    $.ajax({
        url: '../../ajaxAction/donorAction.aspx',
        data: H2G.ajaxData({ action: 'stickerprint' }).config,
        type: "POST",
        dataType: "json",
        //beforeSend: function () {
        //    $('body').block();
        //},
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            data.getItems = jQuery.parseJSON(data.getItems);
            if (!data.onError) {
                console.log("success = ", data.getItems);
            }
        }
    });
}

function check(e, value) {
    //Check Charater
    var unicode = e.charCode ? e.charCode : e.keyCode;
    if (value.indexOf(".") != -1) if (unicode == 46) return false;
    if (unicode != 8) if ((unicode < 48 || unicode > 57) && unicode != 46) return false;
}
function checkLength() {
    var fieldLength = document.getElementById('txtZipcode').value.length;
    //Suppose u want 4 number of character
    if (fieldLength <= 5) {
        return true;
    }
    else {
        var str = document.getElementById('txtZipcode').value;
        str = str.substring(0, str.length - 1);
        document.getElementById('txtZipcode').value = str;
    }
}