console.log("danateScriptEdit");
//////////////////////////////////////////////////////  Virable ///////////////////////////////////////////////////////////////
var getParam = {};

var labExaminationList = [];
var labExaminationIdList = [];
var labExaminationSaveList = [];

var examinationData = [];
var examinationJoinData = [];
var examinationGroupData = [];
var examinationAutoData = [];
var examinationCheckGroup = [];
var examinationCheckNoGroup = [];

var collectedProblemList = [];
var problemDataList = [];
var problemDataAuto = [];
var problemReason = { collectedProblem: "", collectedProblemReason1: "", collectedProblemReason2: "" };

var staffListData = [];

var dataSave = {};

var site_id = 0;
var exChangeList = [];
////////////////////////////////////////////////////// function ///////////////////////////////////////////////////////////////

function checkParam() {
    var deferred = $.Deferred();
    getParam = {
        donateAction: $("#data").attr("donateAction"),
        donorID: $("#data").attr("donorid"),
        visitID: $("#data").attr("visitid"),
        donateType: $("#data").attr("donatetype"),
        donateBagType: $("#data").attr("donatebagtype"),
        donateApply: $("#data").attr("donateapply"),
        donateDate: $("#data").attr("donatedate"),
        donatestatus: $("#data").attr("donatestatus")
    }
    console.log(getParam);
    deferred.resolve("Ok");
    if ($("#data").attr("donateAction") == "new") {
        $("#donerNumber").focus();
    } else if ($("#data").attr("donateAction") == "edit") {
        $("#donateType").focus();
    }
    return deferred.promise();
}

function getInitialData() {
    var deferred = $.Deferred();
    if (getParam.donateAction == "edit"){
        $.ajax({
            url: '../../ajaxAction/donateAction.aspx',
            data: H2G.ajaxData({ action: 'getInitialData' }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log("data = ", data.getItems);
                    if (data.getItems.doner.length > 0) {
                        $("#donerNumber").val(data.getItems.doner[0].donorNumber);
                        $("#donerNumber").prop("readonly", true);
                    }
                    if (data.getItems.visit.length > 0) {
                        $("#sampleNumber").val(data.getItems.visit[0].sampleNumber);
                        $("#sampleNumber").prop("readonly", true);
                        if ($("#data").attr("donatesubaction") == "b") {
                            console.log(data.getItems.visit[0].donation_type_id, "ddddddd");
                            $("#donateType").val(data.getItems.visit[0].donation_type_id);
                            $("#donateBagType").val(data.getItems.visit[0].bag_id);
                            $("#donateApply").val(data.getItems.visit[0].donation_to_id);
                        }
                    }
                    if (data.getItems.InitalData.length > 0) {
                        // console.log("sss = ", data.getItems.InitalData);
                        $("#vol").val(data.getItems.InitalData[0].volume_actual);
                        $("#startDonateDate").val(data.getItems.InitalData[0].donation_time);
                        $("#donateTimes").val(data.getItems.InitalData[0].dulation);

                        $("#donateStaff").attr("staffid", data.getItems.InitalData[0].collection_staff);
                        //console.log("staff label = ", staffListData);
                        for (var i = 0; i < staffListData.length; i++) {
                            if (staffListData[i].id == data.getItems.InitalData[0].collection_staff) {
                                $("#donateStaff").val(staffListData[i].label);
                                break;
                            }
                        }

                        var proBl = data.getItems.InitalData[0];
                        problemReason.collectedProblem = proBl.refuse_reason1_id;
                        problemReason.collectedProblemReason1 = proBl.refuse_reason2_id;
                        problemReason.collectedProblemReason2 = proBl.refuse_reason3_id;
                        for (var i = 0; i < problemDataList.length; i++) {
                            if (proBl.refuse_reason1_id == problemDataList[i].id) {
                                $("#collectedProblem").val(problemDataList[i].code + " - " + problemDataList[i].description);

                            }
                            if (proBl.refuse_reason2_id == problemDataList[i].id) {
                                $("#collectedProblemReason1").val(problemDataList[i].code + " - " + problemDataList[i].description);

                            }
                            if (proBl.refuse_reason3_id == problemDataList[i].id) {
                                $("#collectedProblemReason2").val(problemDataList[i].code + " - " + problemDataList[i].description);

                            }
                        }
                    }
                    if (data.getItems.DonationExamination.length > 0) {
                        var ExninationList = data.getItems.DonationExamination;
                        // console.log("Ex1 = ", ExninationList, " Ex2 = ", examinationData);
                        for (var i = 0; i < ExninationList.length; i++) {
                            for (var j = 0; j < examinationData.length; j++) {
                                if (ExninationList[i].examination_id == examinationData[j].id) {
                                    labExaminationList.push({ text: examinationData[j].code + " - " + examinationData[j].description });
                                    labExaminationIdList.push(ExninationList[i].examination_id);
                                    labExaminationSaveList.push({ id: ExninationList[i].examination_id, code: examinationData[j].code, description: ExninationList[i].examination_desc, group_id: ExninationList[i].examination_group_id })
                                }
                            }
                        }
                        randerAddLabExamination();
                    }
                    deferred.resolve("Ok");
                } else {
                    console.log("Error = ", data.exMessage)
                    deferred.reject("Error");
                }
            }
        });
    }

    return deferred.promise();
}

function getDonateTypeList() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getDonateTypeList' }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                $("#donateType").append($("<option value='0'>&nbsp</option>"));
                for (var i = 0; i < data.getItems.length; i++) {
                    $("#donateType").append($("<option value='" + data.getItems[i].Id + "'>" + data.getItems[i].Description + "</option>"));
                }
                $("#donateType").val(getParam.donateType);
                deferred.resolve("Ok");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("error");
            }
        }
    });
    return deferred.promise();
}

function getDonateBagTypeList() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getDonateBagTypeList' }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                $("#donateBagType").append($("<option value='0'>&nbsp</option>"));
                for (var i = 0; i < data.getItems.length; i++) {
                    $("#donateBagType").append($("<option value='" + data.getItems[i].Id + "'>" + data.getItems[i].Description + "</option>"));
                }
                $("#donateBagType").val(getParam.donateBagType);
                deferred.resolve("Ok");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("error");
            }
        }
    });
    return deferred.promise();
}

function getDonateApplyList() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getDonateApplyList' }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                $("#donateApply").append($("<option value='0'>&nbsp</option>"));
                for (var i = 0; i < data.getItems.length; i++) {
                    $("#donateApply").append($("<option value='" + data.getItems[i].Id + "'>" + data.getItems[i].Description + "</option>"));
                }
                $("#donateApply").val(getParam.donateApply);
                deferred.resolve("Ok");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("Error");
            }
        }
    });
    return deferred.promise();
}

function getExamination() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getExamination' }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                //console.log(data.getItems);
                examinationJoinData = data.getItems.examinationjoinlist;
                examinationGroupData = data.getItems.examinationgrouplist;
                examinationData = data.getItems.examinationlist;
                
                for (var i = 0; i < examinationData.length; i++) {
                    examinationAutoData.push(examinationData[i].code + " - " + examinationData[i].description);
                    examinationCheckNoGroup.push(examinationData[i].code + " - " + examinationData[i].description);
                }

                for (var j = 0; j < examinationGroupData.length; j++) {
                    examinationAutoData.push(examinationGroupData[j].code + " - " + examinationGroupData[j].description);
                    examinationCheckGroup.push(examinationGroupData[j].code + " - " + examinationGroupData[j].description);
                }
                //console.log(examinationAutoData);
                deferred.resolve("Ok");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("Error");
            }
        }
    });
    return deferred.promise();
}

function removeLabExamination(i) {
    labExaminationList.splice(i, 1);
    labExaminationIdList.splice(i, 1);
    labExaminationSaveList.splice(i, 1);
    randerAddLabExamination();
}

function addLabExamination() {
    var text = $("#labExamination").val();
    if (text == "") {
        notiWarning("กรุณากรอกข้อมูลให้ถูกต้อง");
        $("#labExamination").focus();
        return;
    }

    if (jQuery.inArray(text, examinationCheckGroup) != -1) {
        //console.log("In Group");
        setDataIngroup(text);
    } else if (jQuery.inArray(text, examinationCheckNoGroup) != -1) {
        //console.log(" No In Group");
        setDataNotInGroup(text);
    } else {
        $("#labExamination").val("");
        notiWarning("ไม่มีข้อมูลนี้");
        $("#labExamination").focus();
    }
}

function setDataNotInGroup(text) {
    var n = text.indexOf(" -");
    var code = text.substring(0, n);
    for (var i = 0; i < examinationData.length; i++) {
        if (examinationData[i].code == code) {
            var emtId = examinationData[i].id;
            var emCode = examinationData[i].code;
            var emDesc = examinationData[i].description;
        }
    }
    if (jQuery.inArray(emtId, labExaminationIdList) != -1) {
        $("#labExamination").val("");
        notiWarning("ไม่สามารถกรอกข้อมูลซ้ำได้");
        $("#labExamination").focus();
        return;
    }
    //console.log(emtId);
    labExaminationList.push({ text: text });
    labExaminationIdList.push(emtId);
    labExaminationSaveList.push({ id: emtId, code: emCode, description: emDesc, group_id: null });
    randerAddLabExamination();
    $("#labExamination").val("");
    $("#labExamination").focus();
}

function setDataIngroup(text) {
    var n = text.indexOf(" -");
    var code = text.substring(0, n);

    for (var i = 0; i < examinationGroupData.length; i++) {
        if (examinationGroupData[i].code == code) {
            var emtGpId = examinationGroupData[i].id;
        }
    }
    //console.log(emtGpId);
    for (var i = 0; i < examinationJoinData.length; i++) {
        if (examinationJoinData[i].g_id == emtGpId) {
            if (jQuery.inArray(examinationJoinData[i].e_id, labExaminationIdList) != -1) {
                continue;
            }

            labExaminationList.push({ text: examinationJoinData[i].text });
            labExaminationIdList.push(examinationJoinData[i].e_id);
            for (var j = 0; j < examinationData.length; j++) {
                if (examinationJoinData[i].e_id == examinationData[j].id) {
                    labExaminationSaveList.push({ id: examinationJoinData[i].e_id, code: examinationData[j].code, description: examinationData[j].description, group_id: emtGpId });
                }
            }
        }
    }
    randerAddLabExamination();
    $("#labExamination").val("");
    $("#labExamination").focus();
}

function randerAddLabExamination() {
    $("tr").remove(".labExaminationListTableRows");
    for (var i = 0; i < labExaminationList.length; i++) {
        // console.log("for : ", labExaminationList[i].text);
        var rows = "<tr class='labExaminationListTableRows'>" +
                        "<td class='col-md-34'>" + labExaminationList[i].text + "</td>" +
                        "<td class='col-md-1' style='border:1px solid #ffffff; background-color:#ffffff;'>" +
                            "<button class='btn btn-icon' onclick='removeLabExamination(" + i + ");'>" +
                                "<i class='glyphicon glyphicon-remove'></i>" +
                            "</button>" +
                        "</td>" +
                    "</tr>";
        $('#labExaminationListTable > tbody').append(rows);
    }
}

function getProblemReason() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getProblemReason' }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                problemDataList = data.getItems;

                for (var i = 0; i < problemDataList.length; i++) {
                    problemDataAuto.push(problemDataList[i].code + " - " + problemDataList[i].description);
                }
                //console.log(problemDataAuto);
                deferred.resolve("Ok");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("Error");
            }
        }
    });
    return deferred.promise();
}

function setIdProblem(id) {
    console.log("Tag Id = ", id);
    for (var i = 0; i < problemDataList.length; i++) {
        if ($("#" + id).val() == (problemDataList[i].code + " - " + problemDataList[i].description)) {
            if (id == "collectedProblem") {
                problemReason.collectedProblem = problemDataList[i].id;
            } else if (id == "collectedProblemReason1") {
                problemReason.collectedProblemReason1 = problemDataList[i].id;
            } else if (id == "collectedProblemReason2") {
                problemReason.collectedProblemReason2 = problemDataList[i].id;
            }
        }
    }
}

function randerAddCollectedProblem() {
    $("tr").remove(".collectedProblemListTableRows");
    for (var i = 0; i < collectedProblemList.length; i++) {
        // console.log("for : ", collectedProblemList[i].text);
        var rows = "<tr class='collectedProblemListTableRows'>" +
                        "<td class='col-md-33'>" + collectedProblemList[i].text + "</td>" +
                        "<td class='col-md-1' style='border:1px solid #ffffff; background-color:#ffffff;'>" +
                            "<button class='btn btn-icon' onclick='removeLabExamination(" + i + ");'>" +
                                "<i class='glyphicon glyphicon-remove'></i>" +
                            "</button>" +
                        "</td>" +
                    "</tr>";
        $('#collectedProblemListTable > tbody').append(rows);
    }
}

function checkDonateNum() {
    if ($("#data").attr("donateAction") == "new") {
        $.ajax({
            url: '../../ajaxAction/donateAction.aspx',
            data: H2G.ajaxData({ action: 'checkDonateNum', donateNumber: $("#donerNumber").val() }).config,
            type: "POST",
            dataType: "json",
            beforeSend: function(){
                //$('body').block();
            },
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (data.getItems.length == 0) {
                        //$("#donerNumber").focus();
                        getParam.donorID = "0";
                        getParam.visitID = "0";
                        if ($("#donerNumber").val() != "") {
                            notiWarning("ไม่พบเลขผู้บริจาคนี้");
                        }
                        $("#donerNumber").val("");
                        $("#sampleNumber").val("");
                    } else {
                        getParam.donorID = data.getItems[0].donorId;
                        $("#data").attr("donorid", data.getItems[0].donorId);
                        $("#sampleNumber").focus();
                        //notiSuccess("พบเลขผู้บริจาคนี้");
                    }
                    //$('body').unblock();
                    //console.log(problemDataAuto);
                } else {
                    console.log("Error = ", data.exMessage)
                    //$('body').unblock();
                }
            }
        });
    }
}

function checkValidDonateNum() {
    if ($("#donerNumber").val() == "") {
        $("#donerNumber").focus();
        notiWarning("กรุณากรอกเลขผู้บริจาคก่อน");
    } else if (getParam.donorID == "0") {
        //console.log("dddd");
        //$("#donerNumber").focus();
        notiWarning("ไม่พบเลขผู้บริจาคนี้");
    }
}

function checkSampleNumber() {
    if (($("#data").attr("donateAction") == "new") && $("#donerNumber").val() != "" && getParam.donorID != "0") {
        $.ajax({
            url: '../../ajaxAction/donateAction.aspx',
            data: H2G.ajaxData({ action: 'checkSampleNumber', sampleNumber: $("#sampleNumber").val(), donateNumber: $("#donerNumber").val() }).config,
            type: "POST",
            dataType: "json",
            beforeSend: function () {
                //$('body').block();
            },
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (data.getItems.length == 0) {
                        //$("#sampleNumber").focus();
                        getParam.visitID = "0";
                        notiWarning("ไม่พบเลข Sample Number นี้");
                        $("#sampleNumber").val("");
                    } else {
                        getParam.visitID = data.getItems[0].visitId;
                        $("#data").attr("visitid", data.getItems[0].visitId);
                        //notiSuccess("พบเลข Sample Number นี้");
                    }
                    //$('body').unblock();
                    //console.log(problemDataAuto);
                } else {
                    console.log("Error = ", data.exMessage)
                    //$('body').unblock();
                }
            }
        });
    }
}

function saveData() {
    if ($("#donerNumber").val() == "") {
        //alert("กรุณากรอกเลขที่ผู้บริจาค");
        notiWarning("กรุณากรอกเลขที่ผู้บริจาค");
        $("#donerNumber").focus();
        return;
    }
    if ($("#sampleNumber").val() == "") {
        //alert("กรุณากรอก Sample Number");
        notiWarning("กรุณากรอก Sample Number");
        $("#sampleNumber").focus();
        return;
    }
    if ($("#donateType").val() == "0") {
        //alert("กรุณาเลือกประเภทการบริจาค");
        notiWarning("กรุณาเลือกประเภทการบริจาค");
        $("#donateType").focus();
        return;
    }
    if ($("#donateBagType").val() == "0") {
        //alert("กรุณาเลือกประเภทถุง");
        notiWarning("กรุณาเลือกประเภทถุง");
        $("#donateBagType").focus();
        return;
    }
    if ($("#donateApply").val() == "0") {
        //alert("กรุณาเลือกประเภทการใช้งาน");
        notiWarning("กรุณาเลือกประเภทการใช้งาน");
        $("#donateApply").focus();
        return;
    }
    if ($("#vol").val() == "") {
        //alert("กรุณากรอก Valumn");
        notiWarning("กรุณากรอก Valumn");
        $("#vol").focus();
        return;
    }
    if ($("#startDonateDate").val() == "" || $("#startDonateDate").val() == "0000-00-00") {
        //alert("กรุณาเลือกวันที่บริจาค");
        notiWarning("กรุณาเลือกวันที่บริจาค");
        $("#startDonateDate").focus();
        return;
    }
    if ($("#donateTimes").val() == "" || $("#donateTimes").val() == "0000-00-00") {
        //alert("กรุณากรอกระยะเวลาบริการ");
        notiWarning("กรุณากรอกระยะเวลาบริการ");
        $("#donateTimes").focus();
        return;
    }
    if ($("#donateStaff").val() == "") {
        //alert("กรุณากรอกผู้จัดเก็บ");
        notiWarning("กรุณากรอกผู้จัดเก็บ");
        $("#donateStaff").focus();
        return;
    }
    if (labExaminationSaveList == 0 || labExaminationSaveList == "") {
        //alert("กรุณาเลือก LAB EXAMINATION");
        notiWarning("กรุณาเลือก LAB EXAMINATION");
        $("#labExamination").focus();
        return;
    }
    if (problemReason.collectedProblem == 0 || problemReason.collectedProblem == "") {
        problemReason.collectedProblem = 0;
        //alert("กรุณากรอกปัญหาในการจัดเก็บ");
        //$("#collectedProblem").focus();
        //return;
    }
    if (problemReason.collectedProblemReason1 == 0 || problemReason.collectedProblemReason1 == "") {
        problemReason.collectedProblemReason1 = 0;
        //alert("กรุณากรอกเหตุผลปัญหาในการจัดเก็บ 1");
        //$("#collectedProblemReason1").focus();
        //return;
    }
    if (problemReason.collectedProblemReason2 == 0 || problemReason.collectedProblemReason2 == "") {
        problemReason.collectedProblemReason2 = 0;
        //alert("กรุณากรอกเหตุผลปัญหาในการจัดเก็บ 2");
        //$("#collectedProblemReason2").focus();
        //return;
    }
    var saveData = {
        action: 'saveDonate',
        donateAction: getParam.donateAction,
        donateTypeId: $("#donateType").val(),
        donateBagTypeId: $("#donateBagType").val(),
        donateApplyId: $("#donateApply").val(),
        prescribedVol: $("#prescribedVol").val(),
        volumnActual: $("#vol").val(),
        donationTime: $("#data").attr("donatedate") + " " + $("#startDonateDate").val() + ":00",
        duration: $("#data").attr("donatedate") + " " + $("#donateTimes").val() + ":00",
        // collection_staff: $("#donateStaff").val(),
        collection_staff: $("#donateStaff").attr("staffid"),
        refuse_reason1_id: problemReason.collectedProblem,
        refuse_reason2_id: problemReason.collectedProblemReason1,
        refuse_reason3_id: problemReason.collectedProblemReason2,
        labExaminationSaveList: JSON.stringify(labExaminationSaveList)
    }
    console.log("data = ", saveData);
    
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData( saveData ).config,
        type: "POST",
        dataType: "json",
        beforeSend: function () {
           // $('body').block();
        },
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
               // $('body').unblock();
                notiSuccess("บันทึกข้อมูลสำเร็จ");
                hl7Generator($("#data").attr("donorid"), $("#data").attr("visitid"), $("#donerNumber").val(), $("#sampleNumber").val());
                resetData();
                randerAddLabExamination();
            } else {
                console.log("Error = ", data.exMessage);
              //  $('body').unblock();
                notiWarning("บันทึกข้อมูลไม่สำเร็จ");
            }
        }
    });
}

function resetData() {
    var deferred = $.Deferred();
    $("#donateType").val("0");
    $("#donateBagType").val("0");
    $("#donateApply").val("0");
    $("#prescribedVol").val("");
    $("#vol").val("");
    $("#startDonateDate").val("");
    $("#donateTimes").val("");
    $("#donateStaff").val("");
    $("#donateStaff").attr("staffid", "0");

    $("#donerNumber").val("");
    $("#sampleNumber").val("");
    $("#donerNumber").prop("readonly", false);
    $("#sampleNumber").prop("readonly", false);

    $("#collectedProblem").val("");
    $("#collectedProblemReason1").val("");
    $("#collectedProblemReason2").val("");

    labExaminationList = [];
    labExaminationIdList = [];
    labExaminationSaveList = [];

    $("#data").attr("donateAction", "new");
    $("#data").attr("donorid", "0");
    $("#data").attr("visitid", "0");
    $("#data").attr("donatetype", "0");
    $("#data").attr("donatebagtype", "0");
    $("#data").attr("donateapply", "0");
    // $("#data").attr("donatedate", "");
    $("#data").attr("donatestatus", "WAIT COLLECTION");
    deferred.resolve("OK");
    return deferred.promise();
}

function getDonationList() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getDonationList', visit_date: $("#data").H2GAttr("plan_date") }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                console.log(data.getItems);
                if (data.getItems.length > 0) {
                    $("tr").remove(".no-transactionDonate");
                } else {
                    $("tr").remove(".no-transactionDonate");
                    $('#donate-table > tbody').append("<tr class='no-transactionDonate'><td align='center' colspan='9'>ไม่พบข้อมูล</td></tr>");
                }
                for (var i = 0; i < data.getItems.length; i++) {
                    var rows = "<tr class='donate-table-rows'>" +
                                    "<td class='col-md-5'><input value = '" + data.getItems[i].sample_number + "' /></td>" +
                                    "<td class='col-md-5'><input value = '" + data.getItems[i].dornor_number + "' /></td>" +
                                    "<td class='col-md-5'><input value = '" + data.getItems[i].type_des + "' /></td>" +
                                    "<td class='col-md-5'><input value = '" + data.getItems[i].bag_des + "' /></td>" +
                                    "<td class='col-md-5'><input value = '" + data.getItems[i].apply_des + "' /></td>" +
                                    "<td class='col-md-3'><input value = '" + data.getItems[i].volume_actual + "' /></td>" +
                                    "<td class='col-md-3'><input value = '" + data.getItems[i].donation_time + "' /></td>" +
                                    "<td class='col-md-3'><input value = '" + data.getItems[i].duration + "' /></td>" +
                                    "<td class='col-md-3'>" +
                                        "<button class='btn btn-icon' onclick='goEditIt(" + data.getItems[i].visit_id + ", " + data.getItems[i].donor_id + ");'>" +
                                            "<i class='glyphicon glyphicon-circle-arrow-up'></i>" +
                                        "</button>" +
                                    "</td>" +
                                "</tr>";
                    $('#donate-table > tbody').append(rows);
                }
                deferred.resolve("OK");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("Error");

                $("tr").remove(".no-transactionDonate");
                $('#donate-table > tbody').append("<tr class='no-transactionDonate'><td align='center' colspan='9'>ไม่พบข้อมูล</td></tr>");
            }
            $("#donate-table").tablesorter({ dateFormat: "uk" });
        }
    });
    return deferred.promise();
}

function setForEditList() {
    var deferred = $.Deferred();
    $("#data").attr("donateAction", "edit");
    $("#data").attr("donorid", donorId);
    $("#data").attr("visitid", visitId);
    deferred.resolve("OK");
    return deferred.promise();
}

function goEditIt(visitId, donorId) {
    resetData()
    .then(function () {
        var deferred = $.Deferred();
        $("#data").attr("donateAction", "edit");
        $("#data").attr("donatesubaction", "b");
        $("#data").attr("donorid", donorId);
        $("#data").attr("visitid", visitId);
        deferred.resolve("OK");
        return deferred.promise();
    })
    .then(checkParam)
    .then(getInitialData)
    .fail(function (err) {
        console.log(err);
    });
}

function clareData() {
    console.log("clareData");
    resetData();

    randerAddLabExamination();
}

function getStaffAutocomplete() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData({ action: 'getStaffAutocomplete' }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
            deferred.reject("Error = " + err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                // console.log(data.getItems);
                staffListData = data.getItems;
                deferred.resolve("Ok");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("Error = " + data.exMessage);
            }
        }
    });
    return deferred.promise();
}

function setKeyComplete() {
    var deferred = $.Deferred();
    $.widget("custom.kaycomplete", $.ui.autocomplete, {
        _renderMenu: function (ul, items) {
            var that = this,
                currentCategory = "";
            $.each(items, function (index, item) {
                if (item.category != currentCategory) {
                    ul.append("<li class='ui-autocomplete-category'></li>");
                    currentCategory = item.category;
                }
                that._renderItemData(ul, item);
            });
        }
    });

    $("#donateStaff").kaycomplete({
        source: staffListData,
        select: function (event, ui) {
            console.log("ui = ", ui);
            $("#donateStaff").val(ui.item.label);
            $("#donateStaff").attr("staffid", ui.item.id);
        }
    });

    $("#donateStaff").blur(function(){
        var isCheck = checkDuplicatIt(staffListData, $("#donateStaff").val(), $("#donateStaff").attr("staffid"));
        if(!isCheck){
            notiWarning("ไม่มีชื่อพนักงานนี้");
            $("#donateStaff").val("");
            $("#donateStaff").attr("staffid", "0");
        }
    });

    var checkDuplicatIt = function(data,label,key){
        //console.log("data = ", data, label, key );
        var check = false;
        for (var i = 0; i < data.length; i++){
            if (label == data[i].label && key == data[i].id) {
                //console.log("1");
                check = true;
                break;
            } else if (label == data[i].label && key != data[i].id) {
                //console.log("2");
                // $('#re').val(data[i].id);
                $("#donateStaff").attr("staffid", data[i].id);
                check = true;
                break;
            }
        }
        return check;
    }
}

function saveDatatest() {
    console.log("start = ", $("#data").attr("donatedate") + " " + $("#startDonateDate").val());
    console.log("start = ", $("#data").attr("donatedate") + " " + $("#donateTimes").val());
}

function hl7Generator(donorid, visitid, donorno, sample_no) {

    console.log("paramiter = ", donorid, visitid, donorid);

    var getSiteId = function () {
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/donateAction.aspx',
            data: H2G.ajaxData({ action: 'getsiteidhl7', donor_id: donorid, visit_id: visitid }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("error = " + err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log(data.getItems);
                    site_id = data.getItems.site_id;
                    deferred.resolve("ok");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("error = " + data.exMessage);
                }
            }
        });
        return deferred.promise();
    }

    var getExchangeList = function () {
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/donateAction.aspx',
            data: H2G.ajaxData({ action: 'getexchangelist', site_id: site_id }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("error = " + err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log(data.getItems);
                    exChangeList = data.getItems;
                    deferred.resolve("ok");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("error = " + data.exMessage);
                }
            }
        });
        return deferred.promise();
    }

    var hl7Generat = function () {
        var deferred = $.Deferred();
        for (var i = 0; i < exChangeList.length; i++) {
            $.ajax({
                url: '../../ajaxAction/donateAction.aspx',
                data: H2G.ajaxData({
                    action: 'hl7generator',
                    exchange_id: exChangeList[i].exchange_id,
                    donor_no: donorno,
                    sample_no: sample_no,
                    donor_id: donorid,
                    visit_id: visitid
                }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                    deferred.reject("error = " + err);
                },
                success: function (data) {
                    if (!data.onError) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        console.log(data.getItems);
                        notiSuccess("บันทึกแฟ้ม HL7 เรียบร้อยแล้ว");
                    } else {
                        console.log("Error = ", data.exMessage);
                        deferred.reject("error = " + data.exMessage);
                    }
                }
            });
        }
        deferred.resolve("ok");
        return deferred.promise();
    }

    getSiteId()
    .then(getExchangeList)
    .then(hl7Generat)
    .fail(function (err) {
        console.log(err);
    });
}