var setDDL = function(checkEnabled) {
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
        console.log($("#ddlDepartment option:selected").H2GAttr("valueID"), "Code = ", $("#ddlDepartment").H2GValue());
        // get addrass
    });
}