<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="search.aspx.vb" Inherits="Claret.donor_search" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            $("#searchTab").tabs({
                active: 0,
                activate: function (event, ui) {
                    $(ui.newPanel).find("input:not(input[type=button],input[type=submit],button):visible:first").focus();
                },
            });
            $("#txtBirthday").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtBloodGroup").focus();
                },
                onClose: function () {
                    enterDatePicker($("#txtBirthday"),"close");
                },
                onEnterKey: function () {
                    enterDatePicker($("#txtBirthday"), "enter");
                },
            });
            $("#txtName").H2GNamebox(37);
            $("#txtSurname").H2GNamebox(37);
            $("#divCriteria input").enterKey(function () {
                donorSearch(true);
                return false;
            });
            $("#divPostCriteria input").enterKey(function () {
                postQueueSearch(true);
                return false;
            });
            $("#spSearch").click(function () {
                donorSearch(true);
            });
            $("#spClear").click(function () {
                $("#divCriteria input").H2GValue('');
                $("#txtDonorNumber").focus();
            });
            $("#btnNewRegis").click(function () {
                if (validation()) {
                    $("#data").removeAttr("donorID").H2GFill({ donorName: $("#txtName").H2GValue(), donorSurname: $("#txtSurname").H2GValue(), birthday: $("#txtBirthday").H2GValue() });
                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: $(this).H2GAttr("targetUrl"), method: "post", staffaction: "register" }).submit();
                }
            });
            $("#spPostSearch").click(function () {
                postQueueSearch(true);
            });
            $("#spPostClear").click(function () {
                $("#divPostCriteria input").H2GValue('');
                $("#txtPostQueue").focus();
            });
            $.extend($.fn, {
                donorSelect: function () {
                    $("#data").H2GAttr("donorID", $(this).closest("tr").H2GAttr("refID"));
                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                },
                queueSelect: function () {
                    $("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID")});
                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                },
            });

            $("#tbDonor thead button").click(function () { sortButton($(this), donorSearch); return false; });
            $("#tbPostQueue thead button").click(function () { sortButton($(this), postQueueSearch); return false; });
            $("#txtDonorNumber").focus();
        });
        function validation() {
            if ($('#txtName').val() == "") {
                $("#txtName").focus();
                notiWarning("กรุณากรอกชื่อผู้บริจาค");
                return false;
            } else if ($('#txtSurname').val() == "") {
                $("#txtSurname").focus();
                notiWarning("กรุณากรอกนามสกุลผู้บริจาค");
                return false;
            } else if ($('#txtBirthday').val() == "" || !isDate($('#txtBirthday').val(), "dd/MM/yyyy")) {
                $("#txtBirthday").focus();
                notiWarning("กรุณากรอกวันเกิดผู้บริจาค");
                return false;
            }
            return true;
        }
        function donorSearch(newSearch) {
            var dataView = $("#tbDonor > tbody");
            $(dataView).H2GValue($("#tbDonor > thead > tr.more-loading").clone().show());
            if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
                if (newSearch) { $("#tbDonor").attr("currentPage", 1) }
                $(dataView).closest("table").H2GAttr("wStatus", "working");
                $.ajax({
                    url: '../../ajaxAction/donorAction.aspx',
                    data: {
                        action: 'searchdonor'
                        , donornumber: $("#txtDonorNumber").H2GValue()
                        , nationnumber: $("#txtNationNumber").H2GValue()
                        , extnumber: $("#txtExtNumber").H2GValue()
                        , name: $("#txtName").H2GValue()
                        , surname: $("#txtSurname").H2GValue()
                        , birthday: $("#txtBirthday").H2GValue()
                        , bloodgroup: $("#txtBloodGroup").H2GValue()
                        , p: $("#tbDonor").attr("currentPage") || 1
                        , so: $("#tbDonor").attr("sortOrder") || "donor_number"
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
                                if (data.getItems.GoNext == "Y") {
                                    $.each((data.getItems.SearchList), function (index, e) {
                                        var dataRow = $("#tbDonor > thead > tr.template-data").clone();
                                        $(dataRow).attr('refID', e.ID).donorSelect();
                                    });
                                } else {
                                    $.each((data.getItems.SearchList), function (index, e) {
                                        var dataRow = $("#tbDonor > thead > tr.template-data").clone().show();
                                        $(dataRow).H2GAttr('refID', e.ID);
                                        $(dataRow).find('.td-donor-number').append(e.DonorNumber).H2GAttr("title", e.DonorNumber);
                                        $(dataRow).find('.td-nation-number').append(e.NationNumber).H2GAttr("title", e.NationNumber);
                                        $(dataRow).find('.td-ext-number').append(e.ExternalNumber).H2GAttr("title", e.ExternalNumber);
                                        $(dataRow).find('.td-name').append(e.Name).H2GAttr("title", e.Name);
                                        $(dataRow).find('.td-surname').append(e.Surname).H2GAttr("title", e.Surname);
                                        $(dataRow).find('.td-birthday').append(e.Birthday).H2GAttr("title", e.Birthday);
                                        $(dataRow).find('.td-blood-group').append(e.BloodGroup).H2GAttr("title", e.BloodGroup);
                                        $(dataView).append(dataRow);
                                    });
                                    $(dataView).closest("table").attr("totalPage", data.getItems.TotalPage)
                                }

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
                        $("#txtDonorNumber").focus();
                    }
                });    //End ajax
            }
        }
        function postQueueSearch(newSearch) {
            var dataView = $("#tbPostQueue > tbody");
            $(dataView).H2GValue($("#tbPostQueue > thead > tr.more-loading").clone().show());
            if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
                if (newSearch) { $("#tbPostQueue").attr("currentPage", 1) }
                $(dataView).closest("table").H2GAttr("wStatus", "working");
                $.ajax({
                    url: '../../ajaxAction/donorAction.aspx',
                    data: {
                        action: 'donorpostqueue'
                        , queuenumber: $("#txtPostQueue").H2GValue()
                        , donornumber: $("#txtPostDonorNumber").H2GValue()
                        , nationnumber: $("#txtPostNationNumber").H2GValue()
                        , name: $("#txtPostName").H2GValue()
                        , surname: $("#txtPostSurname").H2GValue()
                        , birthday: $("#txtPostBirthday").H2GValue()
                        , bloodgroup: $("#txtPostBloodGroup").H2GValue()
                        , samplenumber: $("#txtPostSample").H2GValue()
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
                                        $(dataRow).find('.td-interview-staff').append(e.InteviewStaff).H2GAttr("title", e.InteviewStaff);
                                        $(dataRow).find('.td-interview-time').append(e.InteviewTime).H2GAttr("title", e.InteviewTime);
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
                        genGridPage($(dataView).closest("table"), postQueueSearch);
                        $("#txtPostQueue").focus();
                    }
                });    //End ajax
            }
        }

        function genGridPage(tbData, doFunction) {
            var totalPage = ($(tbData).attr("totalPage") || "1").toNumber(); var currentPage = ($(tbData).attr("currentPage") || "1").toNumber();
            var divpage = null; var page = "";
            divpage = $(tbData).find("div.page").H2GValue("");

            var backward = currentPage == 1 ? 1 : currentPage - 1;
            var forward = currentPage < totalPage ? currentPage + 1 : totalPage;
            if (totalPage > 0) {
                $(divpage).append($("<span>", { style: "vertical-align:text-top;" }).H2GValue("หน้าที่"));
                $(divpage).append($("<button>", { page: 1 }).append($("<i>", { class: "glyphicon glyphicon-fast-backward" })).click(function () { changePage($(this), doFunction); return false; }));
                $(divpage).append($("<button>", { page: backward }).append($("<i>", { class: "glyphicon glyphicon-backward" })).click(function () { changePage($(this), doFunction); return false; }));
                $(divpage).append($("<input>", { type: "text", value: currentPage }).focusin(function () { $(this).select(); }).H2GNumberbox()
                    .change(function () {
                    if ($(this).H2GValue() != "") {
                        if (!($(this).H2GValue().toNumber() == 0 || $(this).H2GValue().toNumber() > totalPage)) {
                            changePage($(this).H2GFill({ page: $(this).H2GValue() }), doFunction);
                        } else { $(this).focus(); notiWarning("เลขหน้าไม่ถูกต้อง"); }
                    } else { $(this).focus(); notiWarning("กรุณากรอกเลขหน้าที่ต้องการ"); }
                }).select());
                $(divpage).append($("<span>", { class: "total-page", style: "vertical-align:text-top;" }).H2GValue("/" + totalPage));
                $(divpage).append($("<button>", { page: forward }).append($("<i>", { class: "glyphicon glyphicon-forward" })).click(function () { changePage($(this), doFunction); return false; }));
                $(divpage).append($("<button>", { page: totalPage }).append($("<i>", { class: "glyphicon glyphicon-fast-forward" })).click(function () { changePage($(this), doFunction); return false; }));
                if (currentPage <= 1) {
                    $(divpage).find(".glyphicon-fast-backward").closest("button").prop('disabled', true);
                    $(divpage).find(".glyphicon-backward").closest("button").prop('disabled', true);
                }
                if (currentPage == totalPage) {
                    $(divpage).find(".glyphicon-fast-forward").closest("button").prop('disabled', true);
                    $(divpage).find(".glyphicon-forward").closest("button").prop('disabled', true);
                }
            }
        }
        function enterDatePicker(dateControl, action, doFunction) {
            var doFun = doFunction || donorSearch;

            var pattern = 'dd/MM/yyyy';
            if ($(dateControl).H2GValue() != '') {
                $(dateControl).H2GValue($(dateControl).H2GValue().replace(/\W+/g, ''));
                $(dateControl).next().remove();
                if (isDate($(dateControl).H2GValue(), pattern.replace(/\W+/g, ''))) {
                    var isValue = new Date(getDateFromFormat($(dateControl).H2GValue(), pattern.replace(/\W+/g, '')));
                    $(dateControl).H2GValue(formatDate(isValue, pattern))
                    if (action == "enter") {
                        doFun(true);
                    }
                } else {
                    notiWarning("วันที่ไม่ถูกต้อง กรุณาตรวจสอบ");
                    $(dateControl).focus();
                }
            } else { doFun(true); }
        }
        function changePage(xobj, doFunction) {
            if ($(xobj).closest("table").H2GAttr("wStatus") != "working") {
                $(xobj).closest("table").H2GAttr("currentPage", $(xobj).H2GAttr("page"))
                doFunction(false);
            }
        }
        function sortButton(xobj, doFunction) {
            //ถ้าเป็นการ sort field เดิมให้ทำการเปลี่ยน direction 
            if ($(xobj).H2GAttr("sortOrder") != undefined) {
                if ($(xobj).closest("table").H2GAttr("wStatus") != "working") {
                    if ($(xobj).H2GAttr("sortOrder") == $(xobj).closest("table").H2GAttr("sortOrder")) {
                        if ($(xobj).closest("table").H2GAttr("sortDirection") == "asc") {
                            $(xobj).closest("table").H2GFill({ sortDirection: "desc" });
                            $(xobj).find(".glyphicon").removeClass("glyphicon-triangle-top").addClass("glyphicon-triangle-bottom");
                        }
                        else {
                            $(xobj).closest("table").H2GAttr("sortDirection", "asc");
                            $(xobj).find(".glyphicon").removeClass("glyphicon-triangle-bottom").addClass("glyphicon-triangle-top");
                        }
                    } else {
                        //ถ้าเป็นการ sort field ใหม่ให้ทำการเปลี่ยน field และเริ่ม direction ที่ desc
                        $(xobj).closest("table").H2GFill({ sortDirection: "desc", sortOrder: $(xobj).H2GAttr("sortOrder") });
                        //ต้องทำการย้าย direct sign ไปไว้กับหัวข้อที่เลือกใหม่ด้วย
                        $(xobj).closest("table")
                        $(xobj).closest("table").find("thead > tr > th .glyphicon").removeClass("glyphicon-triangle-top").addClass("glyphicon-triangle-bottom")
                            .appendTo($(xobj).closest("table").find("thead button[sortOrder='" + $(xobj).H2GAttr("sortOrder") + "']"));
                    }
                    doFunction(false);
                }
            }
        }
    </script>
    <style>
        #searchTab .border-box {
            background:#FFFFFF;
        }
    </style>
</asp:Content>
<asp:Content ID="ctDonorSearch" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36">
            <span>ค้นหารายชื่อผู้บริจาค</span>
        </div>
    </div>
    <div id="searchTabBox" class="row">
        <div id="searchTab">
            <ul>
                <li><a href="#regisPane" style="">Register</a></li>
                <li><a href="#postQueuePane" style="">Post Queue</a></li>
            </ul>
            <div id="regisPane">
                <div class="border-box">
                    <div id="content-one" style="padding-left:15px; padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>1. ใส่ข้อมูลผู้บริจาคเพื่อค้นหาประวัติ (ใส่ % แทนสิ่งที่ไม่ทราบเช่น นามสกุล ลิขิต% แทนการพิมพ์นามสกุลเต็มๆ)</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-6">
                                <span>เลขประจำตัวผู้บริจาค</span>
                            </div>
                            <div class="col-md-6">
                                <span>เลขประจำตัวประชาชน</span>
                            </div>
                            <div class="col-md-6">
                                <span>เลขประจำตัวอ้างอิง</span>
                            </div>
                            <div class="col-md-6">
                                <span>ชื่อ</span>
                            </div>
                            <div class="col-md-6">
                                <span>นามสกุล</span>
                            </div>
                            <div class="col-md-3">
                                <span>วันเกิด</span>
                            </div>
                            <div class="col-md-3">
                                <span>กรุ๊ปเลือด</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <div style="background-color: #CCCCCC; height: 2px;"></div>
                            </div>
                        </div>
                        <div id="divCriteria" class="row" style="padding-top: 3px; padding-bottom: 3px; padding-left:15px;">
                            <div class="col-md-6">
                                <input id="txtDonorNumber" class="form-control color-yellow" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtNationNumber" class="form-control color-yellow" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtExtNumber" class="form-control" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtName" class="form-control" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtSurname" class="form-control" type="text" />
                            </div>
                            <div class="col-md-3">
                                <input id="txtBirthday" class="form-control text-center" type="text" />
                            </div>
                            <div class="col-md-3">
                                <div class="col-md-16">
                                    <input id="txtBloodGroup" class="form-control text-center" type="text" />
                                </div>
                                <div class="col-md-20">
                                    <a title="ลบข้อมูลที่กรอก"><span id="spClear" class="glyphicon glyphicon-remove"></span></a>
                                    <a title="ค้นหา"><span id="spSearch" class="glyphicon glyphicon-search"></span></a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="content-two" style="padding-left:15px;padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>2. กรุณาตรวจสอบรายละเอียดเบื้องต้นและกด -> หากต้องการลงทะเบียน</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <div id="paging-history">
                                </div>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <table id="tbDonor" class="table table-hover table-striped" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="donor_number">
                                    <thead>
                                        <tr>
                                            <th style="width: 16.66666667%;"><button sortOrder="donor_number">เลขประจำตัวผู้บริจาค<i class="glyphicon glyphicon-triangle-bottom"></i></button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="nation_number">เลขประจำตัวประชาชน</button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="external_number">เลขประจำตัวอ้างอิง</button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="name">ชื่อ</button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="surname">นามสกุล</button>
                                            </th>
                                            <th style="width: 8.33333333%;"><button sortOrder="birthday">วันเกิด</button>
                                            </th>
                                            <th style="width: 8.33333333%;"><button sortOrder="blood_group">กรุ๊ปเลือด</button>
                                            </th>
                                        </tr>
                                        <tr class="no-transaction" style="display:none;"><td align="center" colspan="7">No transaction</td></tr>
                                        <tr class="more-loading" style="display:none;"><td align="center" colspan="7">Loading detail...</td></tr>
                                        <tr class="template-data" style="display:none;" refID="NEW">
                                            <td class="td-donor-number">
                                            </td>
                                            <td class="td-nation-number">
                                            </td>
                                            <td class="td-ext-number">
                                            </td>
                                            <td class="td-name">
                                            </td>
                                            <td class="td-surname">
                                            </td>
                                            <td class="td-birthday">
                                            </td>
                                            <td class="td-blood-group">
                                                <div class="text-right" style="padding-left: 2px; display: inline-table; float: right;">
                                                    <a class="icon"><span class="glyphicon glyphicon-arrow-right" aria-hidden="true" onclick="return $(this).donorSelect();"></span></a>
                                                </div>
                                            </td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr class="no-transaction"><td align="center" colspan="7">No transaction</td></tr>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td align="right" colspan="7">
                                                <div class="page">
                                                    <%--<span style="vertical-align:text-top;">หน้าที่</span>
                                                    <a><span class="glyphicon glyphicon-fast-backward"></span></a>
                                                    <a><span class="glyphicon glyphicon-backward"></span></a>
                                                    <input type="text" value="1" style="width: 20px; height: 20px; text-align: center;" />
                                                    <span class="total-page" style="vertical-align:text-top;">/20</span>
                                                    <a><span class="glyphicon glyphicon-forward"></span></a>
                                                    <a><span class="glyphicon glyphicon-fast-forward"></span></a>--%>
                                                </div>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>

                    </div>
                    <div id="content-three" style="padding-left:15px;padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>3. หากไม่พบข้อมูล ต้องการสร้างประวัติใหม่กรุณาระบุ ชื่อ นามสกุล วันเกิด และกดที่นี่</span>
                            </div>
                            <div class="col-md-9" style="padding-left: 15px;">
                                <input id="btnNewRegis" type="button" class="btn btn-block btn-success" targetUrl="register.aspx" value="ไม่พบข้อมูล - กดที่นี่เพื่อเพิ่มชื่อผู้บริจาคใหม่" />
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <div id="postQueuePane">
                <div class="border-box">
                    <div id="post-content-one" style="padding-left:15px; padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>1. ค้นหาผู้บริจาคเพื่อค้นหาประวัติ (ใส่ % แทนสิ่งที่ไม่ทราบเช่น นามสกุล ลิขิต% แทนการพิมพ์นามสกุลเต็มๆ)</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-2">
                                <span>คิวที่</span>
                            </div>
                            <div class="col-md-6">
                                <span>เลขประจำตัวผู้บริจาค</span>
                            </div>
                            <div class="col-md-6">
                                <span>เลขประจำตัวประชาชน</span>
                            </div>
                            <div class="col-md-6">
                                <span>ชื่อ</span>
                            </div>
                            <div class="col-md-5">
                                <span>นามสกุล</span>
                            </div>
                            <div class="col-md-3">
                                <span>วันเกิด</span>
                            </div>
                            <div class="col-md-3">
                                <span>กรุ๊ปเลือด</span>
                            </div>
                            <div class="col-md-3">
                                <span>Sample</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <div style="background-color: #CCCCCC; height: 2px;"></div>
                            </div>
                        </div>
                        <div id="divPostCriteria" class="row" style="padding-top: 3px; padding-bottom: 3px; padding-left:15px;">
                            <div class="col-md-2">
                                <input id="txtPostQueue" class="form-control color-yellow" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtPostDonorNumber" class="form-control color-yellow" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtPostNationNumber" class="form-control color-yellow" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtPostName" class="form-control" type="text" />
                            </div>
                            <div class="col-md-5">
                                <input id="txtPostSurname" class="form-control" type="text" />
                            </div>
                            <div class="col-md-3">
                                <input id="txtPostBirthday" class="form-control text-center" type="text" />
                            </div>
                            <div class="col-md-3">
                                <input id="txtPostBloodGroup" class="form-control text-center" type="text" />
                            </div>
                            <div class="col-md-3">
                                <input id="txtPostSample" class="form-control" type="text" />
                            </div>
                            <div class="col-md-2 text-center">
                                <a title="ลบข้อมูลที่กรอก"><span id="spPostClear" class="glyphicon glyphicon-remove"></span></a>
                                <a title="ค้นหา"><span id="spPostSearch" class="glyphicon glyphicon-search"></span></a>
                            </div>
                        </div>
                    </div>
                    <div id="post-content-two" style="padding-left:15px;padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>2. กด => เพื่อทำรายการให้กับผู้บริจาค</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <div id="post-paging-history">
                                </div>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <table id="tbPostQueue" class="table table-bordered" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
                                    <thead>
                                        <tr>
                                            <th class="col-md-2"><button sortOrder="QUEUE_NUMBER">คิวที่<i class="glyphicon glyphicon-triangle-bottom"></i></button>
                                            </th>
                                            <th class="col-md-7"><button sortOrder="name">ชื่อ-นามสกุล</button>
                                            </th>
                                            <th class="col-md-4"><button sortOrder="SAMPLE_NUMBER">Sample No.</button>
                                            </th>
                                            <th class="col-md-6"><button>หมายเหตุ</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>ลงทะเบียน</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>คัดกรอง</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>จัดเก็บ</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>Lab</button>
                                            </th>
                                            <th class="col-md-1"></th>
                                        </tr>
                                        <tr class="no-transaction" style="display:none;"><td align="center" colspan="13">No transaction</td></tr>
                                        <tr class="more-loading" style="display:none;"><td align="center" colspan="13">Loading detail...</td></tr>
                                        <tr class="template-data" style="display:none;" refID="NEW">
                                            <td class="td-queue text-center">
                                            </td>
                                            <td class="td-name">
                                            </td>
                                            <td class="td-sample">
                                            </td>
                                            <td class="td-remarks">
                                            </td>
                                            <td class="td-regis-staff col-md-2" style="background-color: #DBEEF3;">
                                            </td>
                                            <td class="td-regis-time col-md-2 text-center" style="background-color: #DBEEF3;">
                                            </td>
                                            <td class="td-interview-staff col-md-2" style="background-color: #FAFDD7;">
                                            </td>
                                            <td class="td-interview-time col-md-2 text-center" style="background-color: #FAFDD7;">
                                            </td>
                                            <td class="td-collection-staff col-md-2" style="background-color: #E5F5D7;">
                                            </td>
                                            <td class="td-collection-time col-md-2 text-center" style="background-color: #E5F5D7;">
                                            </td>
                                            <td class="td-lab-staff col-md-2" style="background-color: #E5E0EC;">
                                            </td>
                                            <td class="td-lab-time col-md-2 text-center" style="background-color: #E5E0EC;">
                                            </td>
                                            <td class="col-md-1">
                                                <div>
                                                    <a class="icon"><span class="glyphicon glyphicon-arrow-right" aria-hidden="true" onclick="return $(this).queueSelect();"></span></a>
                                                </div>
                                            </td>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr class="no-transaction"><td align="center" colspan="13">No transaction</td></tr>
                                    </tbody>
                                    <tfoot>
                                        <tr>
                                            <td align="right" colspan="13">
                                                <div class="page">
                                                </div>
                                            </td>
                                        </tr>
                                    </tfoot>
                                </table>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</asp:Content>
