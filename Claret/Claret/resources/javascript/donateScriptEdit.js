console.log("danateScriptEdit");
//////////////////////////////////////////////////////  Virable ///////////////////////////////////////////////////////////////
var getParam = {};

var labExaminationList = [
    { text: "What about 1" },
    { text: "What can I do" },
    { text: "Ok Nation" },
    { text: "Teayon" },
];

var collectedProblemList = [
    { text: "Hyona" },
    { text: "So U" },
    { text: "Dara" },
    { text: "Tiffany" },
];
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

    console.log("GetParam = ", getParam);
    getDonateTypeList();
    getDonateBagTypeList();
    getDonateApplyList();
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
                //$("#donateType").setDropdowList();
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
                //$("#donateBagType").setDropdowList();
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
                //$("#donateApply").setDropdowList();
                $("#donateApply").val(getParam.donateApply);
            } else {
                console.log("Error = ", data.exMessage)
            }
        }
    });
}

function removeLabExamination(i) {
    labExaminationList.splice(i, 1);
    randerAddLabExamination();
}

function addLabExamination() {
    if ($("#labExamination").val() == "") {
        return;
    }
    labExaminationList.push({ text: $("#labExamination").val() });
    //console.log("data = ", labExaminationList);
    randerAddLabExamination();
    $("#labExamination").val("");
}

function randerAddLabExamination() {
    $("tr").remove(".labExaminationListTableRows");
    for (var i = 0; i < labExaminationList.length; i++) {
        console.log("for : ", labExaminationList[i].text);
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

function randerAddCollectedProblem() {
    $("tr").remove(".collectedProblemListTableRows");
    for (var i = 0; i < collectedProblemList.length; i++) {
        console.log("for : ", collectedProblemList[i].text);
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