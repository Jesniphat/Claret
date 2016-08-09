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
                , so: $("#tbDonor").attr("sortOrder") || "SITE_ID"
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