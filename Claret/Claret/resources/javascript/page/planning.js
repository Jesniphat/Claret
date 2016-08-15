var innitalchack = function () {
    var checkMasterpland = function () {
        var deferred = $.Deferred();
        if ($("#data").attr("planid") == "-1") {
            $("#masterPlan").prop("checked", true);
        }
        deferred.resolve("Ok");
        return deferred.promise();
    }

    var getSubDepartment = function () {
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: H2G.ajaxData({ action: 'getsubcollectionedit' }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("Error");
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (data.getItems.length > 0) {
                        // console.log("sub = ", data.getItems);
                        subDepartmentList = data.getItems
                    }
                    deferred.resolve("OK");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("Error");
                }
            }
        });
        return deferred.promise();
    }

    var checkEdit = function () {
        var deferred = $.Deferred();
        if ($("#data").attr("planningaction") == "edit") {
            $.ajax({
                url: '../../ajaxAction/planningAction.aspx',
                data: H2G.ajaxData({ action: 'getplanbyid', planid: $("#data").attr("planid") }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                    deferred.reject("Error");
                },
                success: function (data) {
                    if (!data.onError) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        if (data.getItems.collection_plan.length > 0) {
                            // console.log("Plan = ", data.getItems.collection_plan[0]);
                            plan_edit_data = data.getItems.collection_plan[0];
                        }

                        if (data.getItems.collection_plan_detail.length > 0) {
                            // console.log("Plan = ", data.getItems.collection_plan_detail[0]);
                            plan_detail_edit_data = data.getItems.collection_plan_detail;
                        }
                        deferred.resolve("OK");
                    } else {
                        console.log("Error = ", data.exMessage);
                        deferred.reject("Error");
                    }
                }
            });
        } else {
            deferred.resolve("OK");
        }
        return deferred.promise();
    }

    var getCountryList = function () {
        var deferred = $.Deferred();;
        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: H2G.ajaxData({ action: 'getcountry' }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (data.getItems.length > 0) {
                        for (var i = 0; i < data.getItems.length; i++) {
                            $("#departmentCountry").append($("<option value='" + data.getItems[i].id + "'>" + data.getItems[i].name + "</option>"));
                        }
                    }
                    deferred.resolve("OK");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("Error");
                }
            }
        });
        return deferred.promise();
    }

    var getDepartmentTypeList = function () {
        var deferred = $.Deferred();;
        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: H2G.ajaxData({ action: 'getdepartmenttypeList' }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    if (data.getItems.length > 0) {
                        for (var i = 0; i < data.getItems.length; i++) {
                            $("#departmentType").append($("<option value='" + data.getItems[i].id + "'>" + data.getItems[i].description + "</option>"));
                        }
                    }
                    deferred.resolve("OK");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("Error");
                }
            }
        });
        return deferred.promise();
    }

    var checkDropDownDepartmentList = function () {
        var deferred = $.Deferred();
        if ($("#data").attr("planid") != "-1") {
            if ($("#data").attr("planningaction") == "edit") {
                $("#ddlDepartment").H2GAttr("selectItem", plan_edit_data.collection_point_code);
                $("#subDepartmentName").H2GAttr("selectItem", plan_edit_data.collection_point_code);
                setDDL(true);
            } else {
                setDDL(true);
            }
        } else {
            $("#ddlDepartment").H2GAttr("selectItem", plan_edit_data.collection_point_code);
            $("#subDepartmentName").H2GAttr("selectItem", plan_edit_data.collection_point_code);
            setDDL(false);
            $("#txtRegion").prop("disabled", true);
            $("#txtDepartment").prop("disabled", true);
        }
        deferred.resolve("Ok");
        return deferred.promise();
    }


    checkMasterpland()
    // .then(getSubDepartment)
    .then(checkEdit)
    .then(getCountryList)
    .then(getDepartmentTypeList)
    .then(checkDropDownDepartmentList)
    .fail(function (err) {
        console.log(err);
    });
}

var setDDL = function (checkEnabled) {
    $("#ddlRegion").setDropdownListValue({
        url: '../ajaxAction/masterAction.aspx',
        data: { action: 'site' },
        enable: checkEnabled,
        defaultSelect: $("#ddlRegion").H2GAttr("selectItem") || "1000"
    }).on("change", function () {
        $("#txtRegion").H2GValue($("#ddlRegion").H2GValue());
    });

    $("#ddlDepartment").setDropdownListValue({
        url: '../ajaxAction/masterAction.aspx',
        data: { action: 'collection' },
        enable: checkEnabled,
        defaultSelect: $("#ddlDepartment").H2GAttr("selectItem") || "0A0000"
    }).on("change", function () {
        $("#txtDepartment").H2GValue($("#ddlDepartment").H2GValue());
        console.log($("#ddlDepartment option:selected").H2GAttr("valueID"), "Code = ", $("#ddlDepartment").H2GValue(), $("#ddlDepartment option:selected").text());
        
        getDepartmentData($("#ddlDepartment option:selected").H2GAttr("valueID"));

        //$("#subDepartmentName").val($("#ddlDepartment option:selected").text());
        $("#addSubDepartmentBt").attr("subdepartmentid", $("#ddlDepartment option:selected").H2GAttr("valueID"));
        $("#addSubDepartmentBt").attr("subdepartmentcode", $("#ddlDepartment").H2GValue());
        $("#subDepartmentName").parent().find("span").find("input").val($("#txtDepartment").find(":selected").text());
        //$("#").parent().find("span").find("input").val($("#").find(":selected").text());
        $("#subDepartmentName").val($("#ddlDepartment").H2GValue()).change();
    });


    $("#subDepartmentName").setAutoListValue({
        url: '../ajaxAction/masterAction.aspx',
        data: { action: 'collection' },
        defaultSelect: $("#subDepartmentName").H2GAttr("selectItem") || "0A0000",
        selectItem: function () {
            $("#addSubDepartmentBt").attr("subdepartmentid", $("#subDepartmentName option:selected").H2GAttr("valueID"));
            $("#addSubDepartmentBt").attr("subdepartmentcode", $("#subDepartmentName").H2GValue());
        },
    }).on('change', function () {
        $("#subDepartmentName").parent().find("span").find("input").val($("#subDepartmentName").find(":selected").text());
    });
}

var getDepartmentData = function (id) {

    $.ajax({
        url: '../../ajaxAction/planningAction.aspx',
        data: H2G.ajaxData({ action: 'getdepartmentdata', departmentid: id }).config,
        type: "POST",
        dataType: "json",
        error: function (xhr, s, err) {
            console.log(s, err);
        },
        success: function (data) {
            if (!data.onError) {
                data.getItems = jQuery.parseJSON(data.getItems);
                var departMentData = data.getItems[0];
                // console.log(departMentData);
                $("#departmentLocation").val(departMentData.Location);
                $("#departmentAddr").val(departMentData.Address);
                $("#departmentSubDistrict").val(departMentData.Sub_District);
                $("#departmentDistrict").val(departMentData.District);
                $("#departmentProvince").val(departMentData.Province);
                $("#departmentZipcode").val(departMentData.Zipcode);
                $("#departmentCountry").val(departMentData.Country_ID);
                $("#departmentMobile1").val(departMentData.Mobile_1);
                $("#departmentEmail").val(departMentData.Email);
                $("#departmentMobile2").val(departMentData.Mobile_2);
                $("#departmentTel").val(departMentData.Tel);
                $("#departmentTelMore").val(departMentData.Tel_Ext);
                $("#workType").val(departMentData.Collection_Type);
                $("#departmentType").val(departMentData.Collection_Category_ID);
                $("#carType").val(departMentData.Collection_Mode);
                $("#donationTime").val(departMentData.Start_Time);
                $("#donationTimeUse").val(departMentData.End_Time);
                
            } else {
                console.log("Error = ", data.exMessage);
            }
        }
    });

}

var chackHaveHead = function (departMentId) {
    var r = false;
    if (departMentId == $("#ddlDepartment option:selected").H2GAttr("valueID")) {
        r = true;
    } else {
        for (var i = 0; i < plan_detail_list.length; i++) {
            if (plan_detail_list[i].collection_id == $("#ddlDepartment option:selected").H2GAttr("valueID")) {
                r = true;
                break;
            }
        }
    }

    return r;
}

var duplicateCurrentCheck = function (departMentId) {
    var r = false;
    for (var i = 0; i < plan_detail_list.length; i++) {
        if (plan_detail_list[i].collection_id == departMentId) {
            r = true;
            break;
        }
    }
    return r;
}

var subDepartMentLander = function (dataList) {
    $("tr").remove(".departMentListTableRow");

    sumExpectRegisterAmount = 0;
    sumRegisterAmount = 0;
    sumExpectDonationAmount = 0;
    sumDonationAmount = 0;
    sumExpectCdonationAmount = 0;
    sumCdonationAmount = 0;

    if (dataList.length > 0) {
        for (var i = 0; i < dataList.length; i++) {
            var rows = "<tr class='departMentListTableRow'>" +
                        "<td class='col-md-8'>" + dataList[i].collection_name + "</td>" +
                        "<td class='col-md-4 text-center'>" + dataList[i].expectRegisterAmount + "</td>" +
                        "<td class='col-md-4 text-center'>" + dataList[i].registerAmount + "</td>" +
                        "<td class='col-md-4 text-center'>" + dataList[i].expectDonationAmount + "</td>" +
                        "<td class='col-md-4 text-center'>" + dataList[i].donationAmount + "</td>" +
                        "<td class='col-md-4 text-center'>" + dataList[i].expectCdonationAmount + "</td>" +
                        "<td class='col-md-4 text-center'>" + dataList[i].cDonationAmount + "</td>" +
                        "<td class='col-md-4 text-center'>" +
                            "<button class='btn btn-icon' onclick='removeDepartMentList(" + i + ");' tabindex='1'>" +
                                "<i class='glyphicon glyphicon-remove'></i>" +
                            "</button>" +
                        "</td>" +
                    "</tr>";
            $('#departMentListTable > tbody').append(rows);

            sumExpectRegisterAmount += parseInt(dataList[i].expectRegisterAmount);
            sumRegisterAmount += parseInt(dataList[i].registerAmount);
            sumExpectDonationAmount += parseInt(dataList[i].expectDonationAmount);
            sumDonationAmount += parseInt(dataList[i].donationAmount);
            sumExpectCdonationAmount += parseInt(dataList[i].expectCdonationAmount);
            sumCdonationAmount += parseInt(dataList[i].cDonationAmount);

        }
    }

    $("#sumRegisDonateExpect").val(sumExpectRegisterAmount);
    $("#sumRegisDonateAmount").val(sumRegisterAmount);
    $("#sumCanRegisDonateExpect").val(sumExpectDonationAmount);
    $("#sumCanRegisDonateAmount").val(sumDonationAmount);
    $("#sumCantRegisDonateExpect").val(sumExpectCdonationAmount);
    $("#sumCantRegisDonateAmount").val(sumCdonationAmount);
}

var removeDepartMentList = function (id) {
    console.log(id);
    plan_detail_list.splice(id, 1);
    subDepartMentLander(plan_detail_list);
}

var addSubDepartment = function (data) {
    console.log("thisdata = ", $(data).attr("subdepartmentid"));

    var continue_func = chackHaveHead($(data).attr("subdepartmentid"));
    if (!continue_func) {
        notiWarning("กรุณาเลือกข้อมูลให้ถูกต้อง");
        return;
    }

    var duplicateCurrent = duplicateCurrentCheck($(data).attr("subdepartmentid"));
    if (duplicateCurrent) {
        notiWarning("หน่วยงาน " + $("#subDepartmentName option:selected").text() + " อยู่ในรายการหน่วยงานย่อยแล้ว");
        return;
    }

    plan_detail_list.push({
        collection_id: $(data).attr("subdepartmentid"),
        collection_name: $("#subDepartmentName option:selected").text(),
        collection_code: $(data).attr("subdepartmentcode"),
        expectRegisterAmount: $("#expectRegisterAmount").val() || "0",
        registerAmount: "0",
        expectDonationAmount: $("#expectDonationAmount").val() || "0",
        donationAmount: "0",
        expectCdonationAmount: $("#expectCdonationAmount").val() || "0",
        cDonationAmount: "0"
    });

    console.log(plan_detail_list);

    subDepartMentLander(plan_detail_list);
}