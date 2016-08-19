function newPlanning() {
    // $("#data").H2GRemoveAttr("planID");
    
    $("#data").H2GFill({ planID: "0", planningaction: "new" });
    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "planning.aspx", method: "post" }).submit();
}

function donorSearch(newSearch) {
    // console.log("planstatus:", $("#txtPlanStatus").H2GValue(), "plantype:", $("#txtPlanType").H2GValue())
    var dataView = $("#tbDonor > tbody");
    $(dataView).H2GValue($("#tbDonor > thead > tr.more-loading").clone().show());
    if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
        if (newSearch) { $("#tbDonor").attr("currentPage", 1) }
        $(dataView).closest("table").H2GAttr("wStatus", "working");
        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: {
                action: 'searchplanning'
                , sectorcode: $("#txtSectorCode").H2GValue()
                , departmentcode: $("#txtDepartmentCode").H2GValue()
                , departmentname: $("#txtDepartmentName").H2GValue()
                , plandate: $("#txtPlanDate").H2GValue()
                , planstatus: $("#txtPlanStatus").H2GValue()
                , plantype: $("#txtPlanType").H2GValue()
                , p: $("#tbDonor").attr("currentPage") || 1
                , so: $("#tbDonor").attr("sortOrder") || "site_id"
                , sd: $("#tbDonor").attr("sortDirection") || "desc"
            },
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                $(dataView).closest("table").H2GAttr("wStatus", "error");
            },
            success: function (data) {
                $(dataView).H2GValue('');
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log("data = ", data);
                    if (data.getItems.SearchList.length > 0) {
                        $.each((data.getItems.SearchList), function (index, e) {
                            var dataRow = $("#tbDonor > thead > tr.template-data").clone().show();
                            $(dataRow).H2GAttr('refID', e.ID);
                            $(dataRow).find('.td-donor-number').append(e.DonorNumber).H2GAttr("title", e.DonorNumber);
                            $(dataRow).find('.td-nation-number').append(e.NationNumber).H2GAttr("title", e.NationNumber);
                            $(dataRow).find('.td-ext-number').append(e.ExternalNumber).H2GAttr("title", e.ExternalNumber);
                            $(dataRow).find('.td-name').append(e.Name).H2GAttr("title", e.Name);
                            $(dataRow).find('.td-surname').append(e.Surname).H2GAttr("title", e.Surname);
                            $(dataRow).find('.td-birthday').append(e.Birthday).H2GAttr("title", e.Birthday);
                            // $(dataRow).find('.td-blood-group').append(e.BloodGroup).H2GAttr("title", e.BloodGroup);
                            $(dataView).append(dataRow);
                        });
                        $(dataView).closest("table").attr("totalPage", data.getItems.TotalPage)

                    } else {
                        $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                        $(dataView).closest("table").attr("totalPage", 0)
                    }
                } else {
                    $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                    $(dataView).closest("table").attr("totalPage", 0)
                }
                $(dataView).closest("table").H2GAttr("wStatus", "done");
                genGridPage($(dataView).closest("table"), donorSearch);
                //$("#txtDonorNumber").focus();
            }
        });    //End ajax
    }
}

function getSiteCode() {
    var deferred = $.Deferred();
    $.ajax({
        url: '../../ajaxAction/planningAction.aspx',
        data: H2G.ajaxData({ action: 'getsitecodebyid', site_id_get: $("#data").attr("siteid") }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
            deferred.reject("error");
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                console.log("ss = ", data.getItems);
                //hasPlanDetailList = data.getItems;
                $("#txtSectorCode").val(data.getItems.site_id);
                deferred.resolve("ok");
            } else {
                console.log("Error = ", data.exMessage);
                deferred.reject("error");
            }
        }
    });

    return deferred.promise();
}