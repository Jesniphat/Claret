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
                            console.log("Plan = ", data.getItems.collection_plan[0]);
                            plan_edit_data = data.getItems.collection_plan[0];
                            $("#donateDate").val(plan_edit_data.plan_date);
                            $("#txtStartRemarakDate").val(plan_edit_data.rmstart);
                            $("#txtLastRemarakDate").val(plan_edit_data.rmend);
                            $("#txtRemark").val(plan_edit_data.remark);
                        }

                        if (data.getItems.collection_plan_detail.length > 0) {
                            console.log("Plan = ", data.getItems.collection_plan_detail);
                            plan_detail_edit_data = data.getItems.collection_plan_detail;

                            for (var i = 0; i < plan_detail_edit_data.length; i++){
                                plan_detail_list.push({
                                    collection_id: plan_detail_edit_data[i].collection_point_id,
                                    collection_name: plan_detail_edit_data[i].name,
                                    collection_code: plan_detail_edit_data[i].collection_point_code,
                                    collection_point_id: plan_detail_edit_data[i].collection_point_id,
                                    expectRegisterAmount: plan_detail_edit_data[i].target_number || "0",
                                    target_number: plan_detail_edit_data[i].target_number || "0",
                                    registerAmount: plan_detail_edit_data[i].regisdonate,
                                    expectDonationAmount: plan_detail_edit_data[i].donate_number || "0",
                                    donate_number: plan_detail_edit_data[i].donate_number || "0",
                                    donationAmount: plan_detail_edit_data[i].donate_amount,
                                    expectCdonationAmount: plan_detail_edit_data[i].refuse_number || "0",
                                    refuse_number: plan_detail_edit_data[i].refuse_number || "0",
                                    cDonationAmount: plan_detail_edit_data[i].refuse_amount
                                });
                            }
                            subDepartMentLander(plan_detail_list);
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
        if (!HaveDonation) {
            //$("#planningStatus").focus();
            $("#donateDate").focus();
        }
        var deferred = $.Deferred();
        if ($("#data").attr("planid") != "-1" && !HaveDonation) {
            if ($("#data").attr("planningaction") == "edit") {
                $("#ddlRegion").H2GAttr("selectItem", plan_edit_data.site_code);
                $("#ddlDepartment").H2GAttr("selectItem", plan_edit_data.collection_point_code);
                $("#subDepartmentName").H2GAttr("selectItem", plan_edit_data.collection_point_code);
                setDDL(true);
            } else {
                setDDL(true);
            }
        } else {
            $("#ddlRegion").H2GAttr("selectItem", plan_edit_data.site_code);
            $("#ddlDepartment").H2GAttr("selectItem", plan_edit_data.collection_point_code);
            $("#subDepartmentName").H2GAttr("selectItem", plan_edit_data.collection_point_code);
            setDDL(false);
            $("#txtRegion").prop("disabled", true);
            $("#txtDepartment").prop("disabled", true);
        }
        deferred.resolve("Ok");
        return deferred.promise();
    }

    var getHasCollectionPlanDetail = function () {
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: H2G.ajaxData({ action: 'getHasPlanDetail', planid: $("#data").attr("planid"), plandate: $("#donateDate").val() }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log("ss = ", data.getItems);
                    hasPlanDetailList = data.getItems;
                    deferred.resolve("OK");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("Error");
                }
            }
        });
        return deferred.promise();
    }

    var checkHaveDonationAmount = function () {
        var deferred = $.Deferred();
        console.log("checkHaveDonationAmount");
        for (var i = 0; i < plan_detail_list.length; i++) {
            if (plan_detail_list[i].registerAmount > 0 || plan_detail_list[i].donationAmount > 0 || plan_detail_list[i].cDonationAmount > 0) {
                $("#donateDate").prop("readonly", true);
                $("#donateDate").prop("disabled", true);
                $("#planningStatus").prop("disabled", true);
                $("#txtRegion").prop("readonly", true);
                $("#ddlRegion").prop("disabled", true);
                $("#txtDepartment").prop("readonly", true);
                $("#ddlDepartment").prop("disabled", true);
                $("#donationTime").prop("readonly", true);
                $("#donationTimeUse").prop("readonly", true);
                HaveDonation = true;
                break;
            }
        }
        deferred.resolve("OK");
        return deferred.promise();
    }

    checkMasterpland()
    .then(checkEdit)
    .then(checkHaveDonationAmount)
    .then(getHasCollectionPlanDetail)
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

        if ($("#data").attr("planningaction") == "new") {
            getDefaultSetdate($("#ddlDepartment option:selected").H2GAttr("valueID"));
        }
        
        //$("#subDepartmentName").val($("#ddlDepartment option:selected").text());
        $("#addSubDepartmentBt").attr("subdepartmentid", $("#ddlDepartment option:selected").H2GAttr("valueID"));
        $("#addSubDepartmentBt").attr("subdepartmentcode", $("#ddlDepartment").H2GValue());
        $("#subDepartmentName").parent().find("span").find("input").val($("#txtDepartment").find(":selected").text());
        //$("#").parent().find("span").find("input").val($("#").find(":selected").text());
        $("#subDepartmentName").val($("#ddlDepartment").H2GValue()).change();
        // $("#ui-datepicker-div").unblock();
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
        $("#addSubDepartmentBt").attr("subdepartmentid", $("#subDepartmentName option:selected").H2GAttr("valueID"));
        $("#addSubDepartmentBt").attr("subdepartmentcode", $("#subDepartmentName").H2GValue());
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
                if (!departMentData) {
                    console.log("none");
                    return;
                }
                //console.log(departMentData);
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

var duplicateFromServerCheck = function (departMentId) {
    var r = false;
    for (var i = 0; i < hasPlanDetailList.length; i++) {
        if (hasPlanDetailList[i].collection_point_id == departMentId) {
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
                        "<td class='col-md-8 border-lefts'>" + dataList[i].collection_name + "</td>" +
                        "<td class='col-md-4 text-center border-lefts'>" + dataList[i].expectRegisterAmount + "</td>" +
                        "<td class='col-md-4 text-center border-lefts'>" + dataList[i].registerAmount + "</td>" +
                        "<td class='col-md-4 text-center border-lefts'>" + dataList[i].expectDonationAmount + "</td>" +
                        "<td class='col-md-4 text-center border-lefts'>" + dataList[i].donationAmount + "</td>" +
                        "<td class='col-md-4 text-center border-lefts'>" + dataList[i].expectCdonationAmount + "</td>" +
                        "<td class='col-md-4 text-center border-lefts'>" + dataList[i].cDonationAmount + "</td>" +
                        "<td class='col-md-4 text-center border-lefts' style='border-right:solid 1px #ccc'>" +
                            "<button class='btn btn-icon' onclick='removeDepartMentList(" + i + ");' tabindex='15'>" +
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

    if (plan_detail_list[id].registerAmount > 0 || plan_detail_list[id].donationAmount > 0 || plan_detail_list[id].cDonationAmount > 0) {
        notiWarning("ไม่สามารถลบหน่วยงานที่มีจำนวนผู้บริจาคแล้วได้")
        return;
    }

    plan_detail_list.splice(id, 1);
    subDepartMentLander(plan_detail_list);
}

var addSubDepartment = function (data) {
    console.log("thisdata = ", $(data).attr("subdepartmentid"));

    var continue_func = chackHaveHead($(data).attr("subdepartmentid"));
    if (!continue_func) {
        notiWarning("กรุณาเพื่มหน่วยงาน " + $("#ddlDepartment option:selected").text() + " ก่อน");
        $("#subDepartmentName").val($("#ddlDepartment").H2GValue()).change();
        return;
    }

    var duplicateCurrent = duplicateCurrentCheck($(data).attr("subdepartmentid"));
    if (duplicateCurrent) {
        notiWarning("หน่วยงาน " + $("#subDepartmentName option:selected").text() + " อยู่ในรายการหน่วยงานย่อยแล้ว");
        return;
    }

    //var duplicateFromServer = duplicateFromServerCheck($(data).attr("subdepartmentid"));
    //if (duplicateFromServer) {
    //    notiWarning("หน่วยงาน " + $("#subDepartmentName option:selected").text() + " อยู่ในแผนบริจาควันที่ " + $("#donateDate").val() + " แล้ว");
    //    return;
    //}

    plan_detail_list.push({
        collection_id: $(data).attr("subdepartmentid"),
        collection_name: $("#subDepartmentName option:selected").text(),
        collection_code: $(data).attr("subdepartmentcode"),
        collection_point_id: $(data).attr("subdepartmentid"),
        expectRegisterAmount: $("#expectRegisterAmount").val() || "0",
        target_number: $("#expectRegisterAmount").val() || "0",
        registerAmount: "0",
        expectDonationAmount: $("#expectDonationAmount").val() || "0",
        donate_number: $("#expectDonationAmount").val() || "0",
        donationAmount: "0",
        expectCdonationAmount: $("#expectCdonationAmount").val() || "0",
        refuse_number: $("#expectCdonationAmount").val() || "0",
        cDonationAmount: "0"
    });

    $("#expectRegisterAmount").val("");
    $("#expectDonationAmount").val("");
    $("#expectCdonationAmount").val("");
    console.log(plan_detail_list);

    subDepartMentLander(plan_detail_list);
}


var savePlanning = function () {
    var beforSaveList = [];
    var chackActiverDuplicateData = "";
    var has = false;

    //var checkBeforSaveList = function () {
    //    var deferred = $.Deferred();
    //    $.ajax({
    //        url: '../../ajaxAction/planningAction.aspx',
    //        data: H2G.ajaxData({ action: 'getHasPlanDetail', planid: $("#data").attr("planid"), plandate: $("#donateDate").val() }).config,
    //        type: "POST",
    //        dataType: "json",
    //        error: function (xhr, s, err) {
    //            console.log(s, err);
    //            deferred.reject("error");
    //        },
    //        success: function (data) {
    //            if (!data.onError) {
    //                data.getItems = jQuery.parseJSON(data.getItems);
    //                console.log("ss = ", data.getItems, data.getItems.length);
    //                for (var i = 0; i < data.getItems.length; i++) {
    //                    beforSaveList.push(data.getItems[i].collection_point_id);
    //                }
    //                //hasPlanDetailList = data.getItems;
    //                deferred.resolve("ok");
    //            } else {
    //                console.log("Error = ", data.exMessage);
    //                deferred.reject("error");
    //            }
    //        }
    //    });

    //    return deferred.promise();

    //}

    var checkBeforSaveList = function () {
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: H2G.ajaxData({ action: 'checkduplicateactive', collection_id_check: $("#ddlDepartment option:selected").H2GAttr("valueID"), plandate: $("#donateDate").val() }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("error");
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log("ss = ", data.getItems, data.getItems.length);
                    //hasPlanDetailList = data.getItems;
                    chackActiverDuplicateData = data.getItems.ischeck;
                    deferred.resolve("ok");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("error");
                }
            }
        });

        return deferred.promise();

    }

    var checkHasSubInlist = function () {
        var deferred = $.Deferred();
        has = false;
        if (plan_detail_list.length > 0) {
            for (var i = 0; i < plan_detail_list.length; i++) {
                if (plan_detail_list[i].collection_point_id == $("#ddlDepartment option:selected").H2GAttr("valueID")) {
                    has = true;
                    break;
                }
            }
        }
        deferred.resolve("ok");
        return deferred.promise();
    }

    var save = function () {
        var deferred = $.Deferred();
        if ($("#donationTime").val() == "") {
            notiWarning("กรุณากรอกเวลารับบริจาค");
            $("#donationTime").focus();
            deferred.reject("error");
            return;
        }

        if ($("#donationTimeUse").val() == "") {
            notiWarning("กรุณากรอกเวลาสิ้นสุดรับบริจาค");
            $("#donationTimeUse").focus();
            deferred.reject("error");
            return;
        }

        if (plan_detail_list.length == 0) {
            notiWarning("กรุณาเพิ่มหน่วยงานย่อย");
            deferred.reject("error");
            return;
        }

        if (!has) {
            notiWarning("กรุณาเพื่มหน่วยงาน " + $("#ddlDepartment option:selected").text() + " ก่อน");
            $("#subDepartmentName").val($("#ddlDepartment").H2GValue()).change();
            deferred.reject("error");
            return;
        }

        if ($("#planningStatus").val() == "ACTIVE") {
            if (plan_edit_data.collection_point_id != $("#ddlDepartment option:selected").H2GAttr("valueID") && $("#data").attr("planningaction") == "edit") {
                if (chackActiverDuplicateData == "x") {
                    notiWarning("มีหน่วยงานนี้อยู่แล้ว");
                    deferred.reject("error");
                    return;
                }
            }

            if ($("#data").attr("planningaction") == "new") {
                if (chackActiverDuplicateData == "x") {
                    notiWarning("มีหน่วยงานนี้อยู่แล้ว");
                    deferred.reject("error");
                    return;
                }
            }
        }
        
        var param = {
            action: "saveplan",
            how: $("#data").attr("planningaction"),
            planid: $("#data").attr("planid"),
            plandate: $("#donateDate").val(),
            planstatus: $("#planningStatus").val(),
            site_code: $("#txtRegion").val(),
            site_id: $("#ddlRegion option:selected").H2GAttr("valueID"),
            site_name: $("#ddlRegion option:selected").text(),
            collection_code: $("#txtDepartment").val(),
            collection_id: $("#ddlDepartment option:selected").H2GAttr("valueID"),
            collection_name: $("#ddlDepartment option:selected").text(),
            collection_lacation: $("#departmentLocation").val(),
            collection_addr: $("#departmentAddr").val(),
            collection_subdistrict: $("#departmentSubDistrict").val(),
            collection_district: $("#departmentDistrict").val(),
            collection_province: $("#departmentProvince").val(),
            collection_zipcode: $("#departmentZipcode").val(),
            collection_country: $("#departmentCountry").val(),
            collection_mobile1: $("#departmentMobile1").val(),
            collection_email: $("#departmentEmail").val(),
            collection_mobile2: $("#departmentMobile2").val(),
            collection_tel: $("#departmentTel").val(),
            collection_tel_ext: $("#departmentTelMore").val(),
            collection_worktype: $("#workType").val(),
            collection_cartype: $("#carType").val(),
            collection_donatetime: $("#donationTime").val(),
            collection_donationtimeuse: $("#donationTimeUse").val(),
            collection_sumregisdonateexpect: $("#sumRegisDonateExpect").val(),
            collection_sumregisdonateamount: $("#sumRegisDonateAmount").val(),
            collection_sumcanregisdonateexpect: $("#sumCanRegisDonateExpect").val(),
            collection_sumcanregisdanateamount: $("#sumCanRegisDonateAmount").val(),
            collection_sumcantregisdonateexpect: $("#sumCantRegisDonateExpect").val(),
            collection_sumcantregisdonateamount: $("#sumCantRegisDonateAmount").val(),
            collection_type: $("#departmentType").val(),
            status: $("#planningStatus").val(),
            staffid: $("#data").attr("staffid"),
            remark: $("#txtRemark").val(),
            startremark: $("#txtStartRemarakDate").val(),
            endremark: $("#txtLastRemarakDate").val(),
            subplan_list: JSON.stringify(plan_detail_list)
        }
        console.log(param);

        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: H2G.ajaxData(param).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("error");
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log("id = ", data.getItems);
                    notiSuccess("บันทึกข้อมูลสำเร็จ");
                    _clareFunction();
                    deferred.resolve("ok");
                } else {
                    console.log("Error = ", data.exMessage);
                    notiWarning("บันทึกข้อมูลไม่สำเร็จ");
                    deferred.reject("error");
                }
            }
        });
        return deferred.promise();
    }

    checkBeforSaveList()
    .then(checkHasSubInlist)
    .then(save)
    .fail(function (err) {
        console.log(err);
    });
}

var _clareFunction = function () {
    $("#data").attr("planningaction", "new"),
    $("#data").attr("planid", "0"),
    //$("#donateDate").val(),
    $("#planningStatus").val("ACTIVE"),
    //$("#txtRegion").val(),
    //$("#ddlRegion option:selected").H2GAttr("valueID"),
    $("#ddlRegion").val("1000"),
    //$("#txtDepartment").val(),
    //$("#ddlDepartment option:selected").H2GAttr("valueID"),
    $("#ddlDepartment").val("0A0000"),
    $("#departmentLocation").val();
    $("#departmentAddr").val();
    //$("#departmentSubDistrict").val();
    //$("#departmentDistrict").val();
    //$("#departmentProvince").val();
    //$("#departmentZipcode").val();
    //$("#departmentCountry").val();
    //$("#departmentMobile1").val();
    //$("#departmentEmail").val();
    //$("#departmentMobile2").val();
    //$("#departmentTel").val();
    //$("#departmentTelMore").val();
    //$("#workType").val();
    //$("#carType").val();
    $("#donationTime").val("");
    $("#donationTimeUse").val("");
    $("#sumRegisDonateExpect").val(0);
    $("#sumRegisDonateAmount").val(0);
    $("#sumCanRegisDonateExpect").val(0);
    $("#sumCanRegisDonateAmount").val(0);
    $("#sumCantRegisDonateExpect").val(0);
    $("#sumCantRegisDonateAmount").val(0);
    //$("#departmentType").val();
    //$("#planningStatus").val();
    plan_detail_list = [];

    if ($("#data").attr("planid") != "-1") {
        $("#ddlDepartment").H2GAttr("selectItem", "0A0000");
        $("#subDepartmentName").H2GAttr("selectItem", "0A0000");
        setDDL(true);
       
    } else {
        $("#ddlDepartment").H2GAttr("selectItem", "0A0000");
        $("#subDepartmentName").H2GAttr("selectItem", "0A0000");
        setDDL(false);
        $("#txtRegion").prop("disabled", true);
        $("#txtDepartment").prop("disabled", true);
    }

    subDepartMentLander(plan_detail_list);
}

var getDefaultSetdate = function (departMentId) {
    
        var deferred = $.Deferred();
        $.ajax({
            url: '../../ajaxAction/planningAction.aspx',
            data: H2G.ajaxData({ action: 'getmaxdate', departmentid: departMentId }).config,
            type: "POST",
            dataType: "json",
            error: function (xhr, s, err) {
                console.log(s, err);
                deferred.reject("error");
            },
            success: function (data) {
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    console.log("ss = ", data.getItems.maxDate);
                    if (data.getItems.maxDate == "") {
                        var maxDate = new Date()
                        console.log((maxDate.getDate()) + "/" + maxDate.getMonth() + "/" + maxDate.getFullYear());
                        var NewMaxDate = (("0" + (maxDate.getDate())).slice(-2) + "/" + ("0" + (maxDate.getMonth() + 1)).slice(-2) + "/" + (maxDate.getFullYear() + 543));
                        $("#donateDate").val(NewMaxDate);
                    } else {
                        //console.log(data.getItems.maxDate);
                        //var maxDate = new Date(data.getItems.maxDate); //data.getItems.maxDate;
                        //console.log("มีค่า = ", maxDate);
                        var mxd = formatDate(H2G.addDays(new Date(getDateFromFormat(data.getItems.maxDate, 'dd/MM/yyyy')), 1), 'dd/MM/yyyy')
                        //console.log(mxd);
                        //console.log((maxDate.getDate() + 1) + "/" + maxDate.getMonth() + "/" + maxDate.getFullYear());
                        //var NewMaxDate = (("0" + (maxDate.getDate() + 1)).slice(-2) + "/" + ("0" + (maxDate.getMonth() + 1)).slice(-2) + "/" + (maxDate.getFullYear() + 543));
                        $("#donateDate").val(mxd);
                    }
                    deferred.resolve("ok");
                } else {
                    console.log("Error = ", data.exMessage);
                    deferred.reject("error");
                }
            }
        });

        return deferred.promise();
}