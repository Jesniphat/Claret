var innitalchack = function () {
    var checkMasterpland = function () {
        var deferred = $.Deferred();
        if ($("#data").attr("planid") == "-1") {
            $("#masterPlan").prop("checked", true);
        }
        deferred.resolve("Ok");
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
    }

    var checkDropDownDepartmentList = function () {
        var deferred = $.Deferred();
        if ($("#data").attr("planid") != "-1") {
            setDDL(true);
        } else {
            $("#ddlDepartment").H2GAttr("selectItem", '5E0001')
            setDDL(false);
            $("#txtRegion").prop("disabled", true);
            $("#txtDepartment").prop("disabled", true);
        }
        deferred.resolve("Ok");
        return deferred.promise();
    }

    checkMasterpland()
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

        $("#subDepartmentName").val($("#ddlDepartment option:selected").text());
        $("#addSubDepartmentBt").attr("subdepartmentid", $("#ddlDepartment option:selected").H2GAttr("valueID"));
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

var addSubDepartment = function (data) {
    console.log("thisdata = ", $(data).attr("subdepartmentid"));
}