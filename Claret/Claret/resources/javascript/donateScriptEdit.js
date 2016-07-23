console.log("danateScriptEdit");
//////////////////////////////////////////////////////  Virable ///////////////////////////////////////////////////////////////
var getParam = {};

var labExaminationList = [];
var labExaminationIdList = [];
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
////////////////////////////////////////////////////// function ///////////////////////////////////////////////////////////////

function checkParam() {
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

    // console.log("GetParam = ", getParam);
    if (getParam.donateAction == "edit") {
        getInitialData();
    }
}

function getInitialData() {
    $("#donerNumber").val(getParam.donorID);
}

function getDonateTypeList() {
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
            } else {
                console.log("Error = ", data.exMessage)
            }
        }
    });

}

function getDonateBagTypeList() {
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
            } else {
                console.log("Error = ", data.exMessage)
            }
        }
    });
}

function getDonateApplyList() {
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
            } else {
                console.log("Error = ", data.exMessage)
            }
        }
    });
}

function getExamination() {
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
            } else {
                console.log("Error = ", data.exMessage)
            }
        }
    });
}

function removeLabExamination(i) {
    labExaminationList.splice(i, 1);
    labExaminationIdList.splice(i, 1);
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
                            "<button class='btn btn-icon' onclick='removeLabExamination(" + i + ");' tabindex='1'>" +
                                "<i class='glyphicon glyphicon-remove'></i>" +
                            "</button>" +
                        "</td>" +
                    "</tr>";
        $('#labExaminationListTable > tbody').append(rows);
    }
}

function getProblemReason() {
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
            } else {
                console.log("Error = ", data.exMessage)
            }
        }
    });
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
                            "<button class='btn btn-icon' onclick='removeLabExamination(" + i + ");' tabindex='1'>" +
                                "<i class='glyphicon glyphicon-remove'></i>" +
                            "</button>" +
                        "</td>" +
                    "</tr>";
        $('#collectedProblemListTable > tbody').append(rows);
    }
}

function saveData() {
    console.log("ID List = ", labExaminationIdList);
    console.log("Data List = ", labExaminationList);
}