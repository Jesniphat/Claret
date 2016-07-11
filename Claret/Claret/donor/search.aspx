<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="search.aspx.vb" Inherits="Claret.donor_search" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            $("#txtBirthday").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtBloodGroup").focus();
                },
                onClose: function () {
                    $("#txtBloodGroup").focus();
                    donorSearch(true);
                },
            });
            $("#spSearch").click(function () {
                donorSearch(true);
            });
            $("#divCriteria input").enterKey(function () {
                donorSearch(true);
                return false;
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
            $.extend($.fn, {
                changePage: function () {
                    if ($("#tbDonor").H2GAttr("wStatus") != "working") {
                        $("#tbDonor").H2GAttr("currentPage", $(this).H2GAttr("page"))
                        donorSearch();
                    }
                },
                sortButton: function () {
                    //ถ้าเป็นการ sort field เดิมให้ทำการเปลี่ยน direction 
                    if ($(this).H2GAttr("sortOrder") == $("#tbDonor").H2GAttr("sortOrder")) {
                        if ($("#tbDonor").H2GAttr("sortDirection") == "asc") {
                            $("#tbDonor").H2GFill({ sortDirection: "desc" });
                            $(this).find(".glyphicon").removeClass("glyphicon-triangle-top").addClass("glyphicon-triangle-bottom");
                        }
                        else {
                            $("#tbDonor").H2GAttr("sortDirection", "asc");
                            $(this).find(".glyphicon").removeClass("glyphicon-triangle-bottom").addClass("glyphicon-triangle-top");
                        }
                    } else {
                        //ถ้าเป็นการ sort field ใหม่ให้ทำการเปลี่ยน field และเริ่ม direction ที่ desc
                        $("#tbDonor").H2GFill({ sortDirection: "desc", sortOrder: $(this).H2GAttr("sortOrder") });
                        //ต้องทำการย้าย direct sign ไปไว้กับหัวข้อที่เลือกใหม่ด้วย
                        $("#tbDonor > thead > tr > th .glyphicon").removeClass("glyphicon-triangle-top").addClass("glyphicon-triangle-bottom")
                            .appendTo($("#tbDonor thead button[sortOrder='" + $(this).H2GAttr("sortOrder") + "']"));
                    }
                    donorSearch(false);
                },
                donorSelect: function () {
                    $("#data").H2GAttr("donorID", $(this).closest("tr").H2GAttr("refID"));
                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                },
            });

            $("#tbDonor thead button").click(function () { $(this).sortButton(); return false; });
            $("#txtDonorNumber").focus();
        });
        function validation() {
            if ($('#txtName').val() == "") {
                $("#txtName").focus();
                notiWarning("กรุณากรอกชื่อผู้บริจาก");
                return false;
            } else if ($('#txtSurname').val() == "") {
                $("#txtSurname").focus();
                notiWarning("กรุณากรอกนามสกุลผู้บริจาก");
                return false;
            } else if ($('#txtBirthday').val() == "") {
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
                            } else {
                                $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                                $(dataView).closest("table").attr("totalPage", 0)
                            }
                        } else {
                            $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                            $(dataView).closest("table").attr("totalPage", 0)
                        }
                        $(dataView).closest("table").H2GAttr("wStatus", "done");
                        genGridPage($(dataView).closest("table"));
                        $("#txtDonorNumber").focus();
                    }
                });    //End ajax
            }
        }
        function genGridPage(tbData) {
            var totalPage = ($(tbData).attr("totalPage") || "1").toNumber(); var currentPage = ($(tbData).attr("currentPage") || "1").toNumber();
            var divpage = null; var page = "";
            divpage = $(tbData).find("div.page").H2GValue("");
            
            var backward = currentPage == 1 ? 1 : currentPage - 1;
            var forward = currentPage < totalPage ? currentPage + 1 : totalPage;
            if (totalPage > 0) {
                $(divpage).append($("<span>", { style: "vertical-align:text-top;" }).H2GValue("หน้าที่"));
                $(divpage).append($("<button>", { page: 1 }).append($("<i>", { class: "glyphicon glyphicon-fast-backward" })).click(function () { $(this).changePage(); return false; }));
                $(divpage).append($("<button>", { page: backward }).append($("<i>", { class: "glyphicon glyphicon-backward" })).click(function () { $(this).changePage(); return false; }));
                $(divpage).append($("<input>", { type: "text", value: currentPage }).focusin(function () { $(this).select(); }).H2GNumberbox()
                    .change(function () {
                    if ($(this).H2GValue() != "") {
                        if (!($(this).H2GValue().toNumber() == 0 || $(this).H2GValue().toNumber() > totalPage)) {
                            $(this).H2GFill({ page: $(this).H2GValue() }).changePage();
                        } else { $(this).focus(); notiWarning("เลขหน้าไม่ถูกต้อง"); }
                    } else { $(this).focus(); notiWarning("กรุณากรอกเลขหน้าที่ต้องการ"); }
                }).select());
                $(divpage).append($("<span>", { class: "total-page", style: "vertical-align:text-top;" }).H2GValue("/" + totalPage));
                $(divpage).append($("<button>", { page: forward }).append($("<i>", { class: "glyphicon glyphicon-forward" })).click(function () { $(this).changePage(); return false; }));
                $(divpage).append($("<button>", { page: totalPage }).append($("<i>", { class: "glyphicon glyphicon-fast-forward" })).click(function () { $(this).changePage(); return false; }));
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

    </script>
</asp:Content>
<asp:Content ID="ctDonorSearch" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36">
            <span>ค้นหารายชื่อผู้บริจาค</span>
        </div>
    </div>
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
</asp:Content>
