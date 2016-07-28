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
            SiteID: $("#spRegisNumber").H2GAttr("siteID") || $("#data").H2GAttr("siteid"),
            VisitNumber: $("#spRegisNumber").H2GAttr("visitNumber"),
            Status: $("#spStatus").H2GValue(),
            VisitDate: $("#spVisitInfo").H2GAttr("visitDate"),
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
            ID: '',
            DornerID: '',
            StartDate: '',
            EndDate: '',
            Description: '',
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
                        currentDonateNumber: data.getItems.Donor.CurrentDonateNumber,
                        visitDate: data.getItems.Donor.VisitDate
                    });
                $("#infoTab > ul > li > a[href='#todayPane']").H2GValue(data.getItems.Donor.VisitDateText)

                $("#spRegisNumber").H2GValue(data.getItems.Donor.DonorNumber);
                $("#spQueue").H2GValue(data.getItems.Donor.QueueNumber == "" ? "-" : "คิวที่ " + data.getItems.Donor.QueueNumber).H2GAttr("queueNumber", data.getItems.Donor.QueueNumber);
                $("#spStatus").H2GValue(data.getItems.Donor.Status);
                $("input:radio[name=gender]").prop("checked", false);
                if (data.getItems.Donor.Gender == "M") { $("#rbtM").prop("checked", true); } else { $("#rbtF").prop("checked", true); }
                $("#divBloodType").H2GValue(data.getItems.Donor.RHGroup);
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

                if (!(data.getItems.Donor.DuplicateTransaction == "0")) {
                    alert("วันนี้คุณ " + data.getItems.Donor.Name + " " + data.getItems.Donor.Surname + "  ทำการลงทะเบียนไปแล้ว " + data.getItems.Donor.DuplicateTransaction + " ครั้ง");
                }
                if ($("#spRegisNumber").H2GAttr("visitID") != undefined) { $("#btnSave").H2GValue("บันทึก"); }

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
                    for (var i = 0; i < data.length; i++) {
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
            // console.log("xxxx = ", data);
            data.getItems = jQuery.parseJSON(data.getItems);
            // console.log("Respondata exams = ", data.getItems);
            if (!data.onError) {
                datas = data.getItems;
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