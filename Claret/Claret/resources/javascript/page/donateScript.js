console.log("Donate Script")
///////////////////////////////////////////////////////////////////// Variable  ///////////////////////////////////////////////////////
var cancelDonorId = "";
var cancelVisitId = "";

///////////////////////////////////////////////////////////////////// Function  //////////////////////////////////////////////////////

function linkToCollection() {
    console.log("Link");
    var param = {
        donateAction: "new",
        donatesubaction: "a",
        donorID: "0",
        visitID: "0",
        donateType: $("#donateType").val() || "0",
        donateBagType: $("#donateBagType").val() || "0",
        donateApply: $("#donateApply").val() || "0",
        donateDate: $("#donateDate").val(),
        donateStatus: $("#donateStatus").val()
    };
    //console.log("param = ", param);
    $('<form>').append(H2G.postedData($("#data")
        .H2GFill(param)))
        .H2GFill({ action: "Collection.aspx", method: "post" })
        .submit();
}

function donateSearch(newSearch) {
    var dataView = $("#tbPostQueue > tbody");
    $(dataView).H2GValue($("#tbPostQueue > thead > tr.more-loading").clone().show());
    if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
        if (newSearch) { $("#tbPostQueue").attr("currentPage", 1) }
        $(dataView).closest("table").H2GAttr("wStatus", "working");
        $.ajax({
            url: '../../ajaxAction/donateAction.aspx',
            data: {
                action: 'donorpostqueue'
                , queuenumber: $("#txtPostQueue").H2GValue()
                , donornumber: $("#txtPostDonorNumber").H2GValue()
                , nationnumber: $("#txtPostNationNumber").H2GValue()
                , name: $("#txtPostName").H2GValue()
                , surname: $("#txtPostSurname").H2GValue()
                , birthday: $("#txtPostBirthday").H2GValue()
                , bloodgroup: $("#ddlPostBloodGroup").H2GValue()
                , samplenumber: $("#txtPostSample").H2GValue()
                , reportdate: $("#data").H2GAttr("plan_date") // formatDate(H2G.today(), "dd/MM/yyyy") //$("#txtReportDate").H2GValue()
                , status: $("#donateStatus").val()  // change here
                , p: $("#tbPostQueue").attr("currentPage") || 1
                , so: $("#tbPostQueue").attr("sortOrder") || "queue_number"
                , sd: $("#tbPostQueue").attr("sortDirection") || "desc"
            },
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                $(dataView).H2GValue($("#tbPostQueue > thead > tr.no-transaction").clone().show());
                $(dataView).closest("table").H2GAttr("wStatus", "error");
            },
            success: function (data) {
                $(dataView).H2GValue('');
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (data.getItems.PostQueueList.length > 0) {
                        if (data.getItems.GoNext == "Y") {
                            $.each((data.getItems.PostQueueList), function (index, e) {
                                var dataRow = $("#tbPostQueue > thead > tr.template-data").clone();
                                $(dataRow).H2GFill({ refID: e.VisitID, donorID: e.DonorID }).queueSelect();
                            });
                        } else {
                            $.each((data.getItems.PostQueueList), function (index, e) {
                                var dataRow = $("#tbPostQueue > thead > tr.template-data").clone().show();
                                $(dataRow).H2GFill({ refID: e.VisitID, donorID: e.DonorID });
                                $(dataRow).find('.td-queue').append(e.QueueNumber).H2GAttr("title", e.QueueNumber);
                                $(dataRow).find('.td-name').append(e.Name).H2GAttr("title", e.Name);
                                $(dataRow).find('.td-sample').append(e.SampleNumber).H2GAttr("title", e.SampleNumber);
                                $(dataRow).find('.td-remarks').append(e.Comment).H2GAttr("title", e.Comment);

                                $(dataRow).find('.td-regis-staff').append(e.RegisStaff).H2GAttr("title", e.RegisStaff);
                                $(dataRow).find('.td-regis-time').append(e.RegisTime).H2GAttr("title", e.RegisTime);
                                $(dataRow).find('.td-interview-staff').append(e.InterviewStaff).H2GAttr("title", e.InterviewStaff);
                                $(dataRow).find('.td-interview-time').append(e.InterviewTime).H2GAttr("title", e.InterviewTime);
                                $(dataRow).find('.td-collection-staff').append(e.CollectionStaff).H2GAttr("title", e.CollectionStaff);
                                $(dataRow).find('.td-collection-time').append(e.CollectionTime).H2GAttr("title", e.CollectionTime);
                                $(dataRow).find('.td-lab-staff').append(e.LabStaff).H2GAttr("title", e.LabStaff);
                                $(dataRow).find('.td-lab-time').append(e.LabTime).H2GAttr("title", e.LabTime);
                                $(dataView).append(dataRow);
                            });
                            $(dataView).closest("table").attr("totalPage", data.getItems.TotalPage)
                        }

                    } else {
                        $(dataView).H2GValue($("#tbPostQueue > thead > tr.no-transaction").clone().show());
                        $(dataView).closest("table").attr("totalPage", 0)
                    }
                } else {
                    $(dataView).H2GValue($("#tbPostQueue > thead > tr.no-transaction").clone().show());
                    $(dataView).closest("table").attr("totalPage", 0)
                }
                $(dataView).closest("table").H2GAttr("wStatus", "done");
                genGridPage($(dataView).closest("table"), donateSearch);
                $("#tbPostQueue thead button").click(function () { sortButton($(this), donateSearch); return false; });
                $("#txtPostQueue").focus();
            }
        });    //End ajax
    }
}

function getDonateTypeList() {
    var deferred = $.Deferred();
    $("#donateType").setAutoListValue({
        url: '../../ajaxAction/masterAction.aspx',
        data: { action: 'donationtype2' },
        // defaultSelect: "0", //$("#donateType").H2GAttr("selectItem") || $("#data").H2GAttr("collectionpointid"),
    }).on('autocompleteselect', function () {
        //$("#txtOuterDonate").focus();
    });

    deferred.resolve("Ok");
    return deferred.promise();
}

function getDonateBagTypeList() {
    var deferred = $.Deferred();
    $("#donateBagType").setAutoListValue({
        url: '../../ajaxAction/masterAction.aspx',
        data: { action: 'getdonatebagtypelist' },
       // defaultSelect: "0", //$("#donateType").H2GAttr("selectItem") || $("#data").H2GAttr("collectionpointid"),
    }).on('autocompleteselect', function () {
        //$("#txtOuterDonate").focus();
    });

    deferred.resolve("Ok");
    return deferred.promise();
}

function getDonateApplyList() {
    var deferred = $.Deferred();
    $("#donateApply").setAutoListValue({
        url: '../../ajaxAction/masterAction.aspx',
        data: { action: 'getdonateapplylist' },
       // defaultSelect: "0", //$("#donateType").H2GAttr("selectItem") || $("#data").H2GAttr("collectionpointid"),
    }).on('autocompleteselect', function () {
        //$("#txtOuterDonate").focus();
    });

    deferred.resolve("Ok");
    return deferred.promise();
}

function cancelDonateWaitCollection(donorId, visitId) {
    var param = {
        action: "canceldonate",
        donor_id: donorId,
        visit_id: visitId,
        status: "WAIT COLLECTION",
        staff_id: $("#data").attr("staffid"),
        cutnumber: "no"
    }
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData(param).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                console.log(data.getItems);
                donateSearch(false);
            } else {
                console.log("Error = ", data.exMessage);
            }
        }
    });
}

function cancelDonateWaitResult(donorId, visitId) {
    var param = {
        action: "canceldonate",
        donor_id: donorId,
        visit_id: visitId,
        status: "WAIT RESULT",
        staff_id: $("#data").attr("staffid"),
        cutnumber: "yes"
    }
    $.ajax({
        url: '../../ajaxAction/donateAction.aspx',
        data: H2G.ajaxData(param).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                console.log(data.getItems);
                postQueueSearch(false);
            } else {
                console.log("Error = ", data.exMessage);
            }
        }
    });
}