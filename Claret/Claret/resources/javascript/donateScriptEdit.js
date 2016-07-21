console.log("danateScriptEdit");
//////////////////////////////////////////////////////  Virable ///////////////////////////////////////////////////////////////
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