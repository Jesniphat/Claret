<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="historyReport.aspx.vb" Inherits="Claret.donor_historyReport" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            $("#spQueueHeader").H2GValue("คิวประจำวันที่ " + formatDate(new Date(getDateFromFormat($("#data").H2GAttr("plan_date"), "dd/mm/yyyy")), " dd MMM พ.ศ. yyyy"));
            
            $.extend($.fn, {
                queueSelect: function () {
                    $("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID") });

                    if ($("#data").H2GAttr("lmenu") == "lmenuInterview") {
                        $("#data").H2GFill({ donationTypeID: $("#ddlDonationType").H2GValue(), bagID: $("#ddlBag").H2GValue(), donationToID: $("#ddlDonationTo").H2GValue() });
                    } else {
                        //$("#data").removeAttr("donationTypeID,bagID,donationToID");
                    }

                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                },
            });
            $("#txtReportDate").blur(function () { infoSearch(true); }).H2GDatebox({ allowFutureDate: false }).setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-30:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtPostQueue").focus();
                },
            }).H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
            $("#txtQueue").H2GNumberbox();
            //$("#txtName").H2GNamebox(37);
            //$("#txtSurname").H2GNamebox(37);
            $("#txtBirthday").H2GDatebox({ allowFutureDate: false }).setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtBloodGroup").focus();
                },
            });
            $("#divInfoCriteria input.mandatory").tabKey(function () {
                if ($(this).H2GValue() != "") {
                    infoSearch(true);
                    return false;
                }
            }, true);
            $("#spSearch").click(function () {
                infoSearch(true);
            }).enterKey(function () { infoSearch(true); return false; });
            $("#spClear").click(function () {
                $("#divInfoCriteria input").H2GValue('');
                $("#txtQueue").focus();
                infoSearch(true);
            });

            $("#ddlBloodGroup").setAutoList();
            $("#ddlPostBloodGroup").setAutoList();
            $("#txtPostQueue").H2GNumberbox();
            //$("#txtPostName").H2GNamebox(37);
            //$("#txtPostSurname").H2GNamebox(37);
            $("#txtPostBirthday").H2GDatebox({ allowFutureDate: false }).setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtPostBloodGroup").focus();
                },
            });
            $("#divPostCriteria input.mandatory").tabKey(function () {
                if ($(this).H2GValue() != "") {
                    postQueueSearch(true);
                    return false;
                }
            }, true);
            $("#spPostSearch").click(function () {
                postQueueSearch(true);
            }).enterKey(function () { postQueueSearch(true); return false; });
            $("#spPostClear").click(function () {
                $("#divPostCriteria input").H2GValue('');
                $("#txtPostQueue").focus();
                postQueueSearch(true);
            });
            
            $("#ddlStatus").setAutoList({ selectItem: function () { infoSearch(true); }, }).H2GValue("ALL");

            $("#searchTab").tabs({
                active: 0,
                activate: function (event, ui) {
                    $(ui.newPanel).find("input:not(input[type=button],input[type=submit],button,.hasDatepicker):visible:first").focus();
                },
            });

            // menu control
            if ($("#data").H2GAttr("lmenu") == "lmenuHistoryReport") {
                $(".claret-page-header span").H2GValue("รายงานย้อนหลัง");
                $("#txtPostQueue").focus();
                $("#liSearch > a").H2GValue("รายงานย้อนหลัง");
                $("#liPostQueue > a").H2GValue("&nbsp");
                $("#searchTab").tabs("option", "disabled", [1]);
                $("#data").H2GRemoveAttr("donationTypeID,bagID,donationToID");

            } else if ($("#data").H2GAttr("lmenu") == "lmenuInterview") {
                $("#txtReportDate").H2GValue($("#data").H2GAttr("plan_date"));
                $(".claret-page-header span").H2GValue("คัดกรอง");
                $(".collection-page-header").show();
                $("#ddlDonationType").setAutoListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'donationtype' },
                    defaultSelect: $("#data").H2GAttr("donationTypeID"),
                });
                $("#ddlBag").setAutoListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'bag' },
                    defaultSelect: $("#data").H2GAttr("bagID"),
                });
                $("#ddlDonationTo").setAutoListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'donationto' },
                    defaultSelect: $("#data").H2GAttr("donationToID"),
                });
                $("#ddlStatus").H2GDisable();
                $("#txtReportDate").H2GDisable();
                $("#ddlDonationType").closest("div").focus();
                $("#liSearch > a").H2GValue("คัดกรอง");
                $("#liPostQueue > a").H2GValue("Post Queue");
            }
            
            infoSearch(true);
            postQueueSearch(true);
        });
        function infoSearch(newSearch) {
            var dataView = $("#tbInfo > tbody");
            $(dataView).H2GValue($("#tbInfo > thead > tr.more-loading").clone().show());
            if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
                if (newSearch) { $("#tbInfo").attr("currentPage", 1) }
                $(dataView).closest("table").H2GAttr("wStatus", "working");
                $.ajax({
                    url: '../../ajaxAction/donorAction.aspx',
                    data: {
                        action: 'donorpostqueue'
                        , queuenumber: $("#txtQueue").H2GValue()
                        , donornumber: $("#txtDonorNumber").H2GValue()
                        , nationnumber: $("#txtNationNumber").H2GValue()
                        , name: $("#txtName").H2GValue()
                        , surname: $("#txtSurname").H2GValue()
                        , birthday: $("#txtBirthday").H2GValue()
                        , bloodgroup: $("#ddlBloodGroup").H2GValue()
                        , samplenumber: $("#txtSample").H2GValue()
                        , reportdate: $("#txtReportDate").H2GValue()
                        , status: $("#ddlStatus").H2GValue() == "ALL" ? "" : $("#ddlStatus").H2GValue()
                        , p: $("#tbInfo").attr("currentPage") || 1
                        , so: $("#tbInfo").attr("sortOrder") || "queue_number"
                        , sd: $("#tbInfo").attr("sortDirection") || "desc"
                    },
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                        $(dataView).H2GValue($("#tbInfo > thead > tr.no-transaction").clone().show());
                        $(dataView).closest("table").H2GAttr("wStatus", "error");
                    },
                    success: function (data) {
                        $(dataView).H2GValue('');
                        if (!data.onError) {
                            data.getItems = jQuery.parseJSON(data.getItems);
                            if (data.getItems.PostQueueList.length > 0) {
                                if ($("#data").H2GAttr("lmenu") == "lmenuHistoryReport") { data.getItems.GoNext = "N"; }
                                if (data.getItems.GoNext == "Y") {
                                    $.each((data.getItems.PostQueueList), function (index, e) {
                                        var dataRow = $("#tbInfo > thead > tr.template-data").clone();
                                        $(dataRow).H2GFill({ refID: e.VisitID, donorID: e.DonorID }).queueSelect();
                                    });
                                } else {
                                    $.each((data.getItems.PostQueueList), function (index, e) {
                                        var dataRow = $("#tbInfo > thead > tr.template-data").clone().show();
                                        $(dataRow).H2GFill({ refID: e.VisitID, donorID: e.DonorID });
                                        $(dataRow).find('.td-queue').H2GValue(e.QueueNumber).H2GAttr("title", e.QueueNumber);
                                        $(dataRow).find('.td-name').H2GValue(e.Name).H2GAttr("title", e.Name);
                                        $(dataRow).find('.td-sample').H2GValue(e.SampleNumber).H2GAttr("title", e.SampleNumber);
                                        $(dataRow).find('.td-remarks').H2GValue(e.Comment).H2GAttr("title", e.Comment);
                                        $(dataRow).find('.td-regis-staff').H2GValue(e.RegisStaff).H2GAttr("title", e.RegisStaff);
                                        $(dataRow).find('.td-regis-time').H2GValue(e.RegisTime).H2GAttr("title", e.RegisTime);
                                        $(dataRow).find('.td-interview-staff').H2GValue(e.InterviewStaff).H2GAttr("title", e.InterviewStaff);
                                        $(dataRow).find('.td-interview-time').H2GValue(e.InterviewTime).H2GAttr("title", e.InterviewTime);
                                        $(dataRow).find('.td-collection-staff').H2GValue(e.CollectionStaff).H2GAttr("title", e.CollectionStaff);
                                        $(dataRow).find('.td-collection-time').H2GValue(e.CollectionTime).H2GAttr("title", e.CollectionTime);
                                        $(dataRow).find('.td-lab-staff').H2GValue(e.LabStaff).H2GAttr("title", e.LabStaff);
                                        $(dataRow).find('.td-lab-time').H2GValue(e.LabTime).H2GAttr("title", e.LabTime);
                                        if ($("#data").H2GAttr("lmenu") == "lmenuInterview") { $(dataRow).find(".icon-blood-bag").closest("a").hide(); }
                                        $(dataView).append(dataRow);
                                    });
                                    $(dataView).closest("table").attr("totalPage", data.getItems.TotalPage)
                                }

                            } else {
                                $(dataView).H2GValue($("#tbInfo > thead > tr.no-transaction").clone().show());
                                $(dataView).closest("table").attr("totalPage", 0)
                            }
                        } else {
                            $(dataView).H2GValue($("#tbInfo > thead > tr.no-transaction").clone().show());
                            $(dataView).closest("table").attr("totalPage", 0)
                        }
                        $(dataView).closest("table").H2GAttr("wStatus", "done");

                        $(dataView).closest("table").find("thead button").click(function () { sortButton($(this), infoSearch); return false; });
                        genGridPage($(dataView).closest("table"), infoSearch);
                        $("#txtQueue").focus();
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
                        , bloodgroup: $("#ddlPostBloodGroup").H2GValue()
                        , samplenumber: $("#txtPostSample").H2GValue()
                        , reportdate: $("#data").H2GAttr("plan_date") //formatDate(H2G.today(), "dd/MM/yyyy") //$("#txtReportDate").H2GValue()
                        , status: ""
                        , receipthospitalid: $("#data").H2GAttr("receiptHospitalID")
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
                                        $(dataRow).find('.td-queue').H2GValue(e.QueueNumber).H2GAttr("title", e.QueueNumber);
                                        $(dataRow).find('.td-name').H2GValue(e.Name).H2GAttr("title", e.Name);
                                        $(dataRow).find('.td-sample').H2GValue(e.SampleNumber).H2GAttr("title", e.SampleNumber);
                                        $(dataRow).find('.td-remarks').H2GValue(e.Comment).H2GAttr("title", e.Comment);
                                        $(dataRow).find('.td-regis-staff').H2GValue(e.RegisStaff).H2GAttr("title", e.RegisStaff);
                                        $(dataRow).find('.td-regis-time').H2GValue(e.RegisTime).H2GAttr("title", e.RegisTime);
                                        $(dataRow).find('.td-interview-staff').H2GValue(e.InterviewStaff).H2GAttr("title", e.InterviewStaff);
                                        $(dataRow).find('.td-interview-time').H2GValue(e.InterviewTime).H2GAttr("title", e.InterviewTime);
                                        $(dataRow).find('.td-collection-staff').H2GValue(e.CollectionStaff).H2GAttr("title", e.CollectionStaff);
                                        $(dataRow).find('.td-collection-time').H2GValue(e.CollectionTime).H2GAttr("title", e.CollectionTime);
                                        $(dataRow).find('.td-lab-staff').H2GValue(e.LabStaff).H2GAttr("title", e.LabStaff);
                                        $(dataRow).find('.td-lab-time').H2GValue(e.LabTime).H2GAttr("title", e.LabTime);
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
    </script>
    <style>
        #searchTab .border-box {
            background:#FFFFFF;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>รายงานย้อนหลัง</span>
        </div>
    </div>
    <div id="searchTabBox" class="row">
        <div id="searchTab">
            <ul>
                <li id="liSearch"><a href="#searchPane" style="">Register</a></li>
                <li id="liPostQueue"><a href="#postQueuePane" style="">Post Queue</a></li>
            </ul>
            <div id="searchPane">
                <div class="border-box">
                    <div class="collection-page-header row" style="display:none;">
                        <div class="border-box" style="border-radius: 4px 4px 0px 0px;">
                            <div class="row">
                                <div class="col-md-36" style="font-size:larger; font-weight:bold;">
                                    <span>กำหนดประเภทของการรับบริจาคที่กำลังจะดำเนินงาน</span>
                                </div>
                            </div>
                            <div class="row">
                                <div class="col-md-4 text-right">
                                    <span>ประเภทการบริจาค</span>
                                </div>                                                        
                                <div class="col-md-8">
                                    <select id="ddlDonationType" class="text-left" style="width:250px;">
                                        <option value="0">Loading...</option>
                                    </select>
                                </div>
                                <div class="col-md-3 text-right">
                                    <span>ประเภทถุง</span>
                                </div>                                                        
                                <div class="col-md-8">
                                    <select id="ddlBag" class="text-left" style="width:250px;">
                                        <option value="0">Loading...</option>
                                    </select>
                                </div>
                                <div class="col-md-4 text-right">
                                    <span>การนำไปใช้งาน</span>
                                </div>                                                        
                                <div class="col-md-8">
                                    <select id="ddlDonationTo" class="text-left" style="width:250px;">
                                        <option value="0">Loading...</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="row">
                        <div class="border-box" style="border-radius: 4px 4px 0px 0px;">
                            <div class="col-md-36" style="border-bottom:solid 1px #CCCCCC; padding-bottom: 5px;">
                                <div class="col-md-3 col-md-offset-11 text-right">
                                    <span>รายการวันที่</span>
                                </div>
                                <div class="col-md-3">
                                    <input id="txtReportDate" class="form-control text-center" type="text" />
                                </div>
                                <div class="col-md-2 text-center">
                                    <span>สถานะ</span>
                                </div>
                                <div class="col-md-5">
                                    <select id="ddlStatus" style="width:210px;">
                                        <option value="ALL" selected="selected">ALL</option>
                                        <option value="WAIT INTERVIEW">WAIT INTERVIEW</option>
                                        <option value="WAIT COLLECTION">WAIT COLLECTION</option>
                                        <option value="WAIT RESULT">WAIT RESULT</option>
                                        <option value="FINISH">FINISH</option>
                                        <option value="CANCEL">CANCEL</option>
                                    </select>
                                </div>
                            </div>
                            <div id="content-one" class="col-md-36" style="padding-left:15px; padding-bottom: 20px;">
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
                                <div id="divInfoCriteria" class="row" style="padding-top: 3px; padding-bottom: 3px; padding-left:15px;">
                                    <div class="col-md-2">
                                        <input id="txtQueue" class="form-control color-yellow mandatory" type="text" />
                                    </div>
                                    <div class="col-md-6">
                                        <input id="txtDonorNumber" class="form-control color-yellow mandatory" type="text" />
                                    </div>
                                    <div class="col-md-6">
                                        <input id="txtNationNumber" class="form-control color-yellow mandatory" type="text" />
                                    </div>
                                    <div class="col-md-6">
                                        <input id="txtName" class="form-control" type="text" />
                                    </div>
                                    <div class="col-md-5">
                                        <input id="txtSurname" class="form-control" type="text" />
                                    </div>
                                    <div class="col-md-3">
                                        <input id="txtBirthday" class="form-control text-center" type="text" />
                                    </div>
                                    <div class="col-md-3">
                                        <select id="ddlBloodGroup" style="width:90px;">
                                            <option>A</option>
                                            <option>A-</option>
                                            <option>A+</option>
                                            <option>AB</option>
                                            <option>AB-</option>
                                            <option>AB+</option>
                                            <option>B</option>
                                            <option>B-</option>
                                            <option>B+</option>
                                            <option>O</option>
                                            <option>O-</option>
                                            <option>O+</option>
                                        </select>
                                    </div>
                                    <div class="col-md-3">
                                        <input id="txtSample" class="form-control" type="text" />
                                    </div>
                                    <div class="col-md-2 text-center">
                                        <button id="spClear" class="btn btn-icon" onclick="return false;" style="padding: 0;" tabindex="-1">
                                            <i class="glyphicon glyphicon-remove" style="vertical-align: text-top;"></i>
                                        </button><button id="spSearch" class="btn btn-icon" onclick="return false;" style="padding: 0;">
                                            <i class="glyphicon glyphicon-search" style="vertical-align: text-top;"></i>
                                        </button>
                                    </div>
                                </div>
                            </div>
                            <div id="content-two" class="col-md-36" style="padding-left:15px;padding-bottom: 20px;">
                                <div class="row">
                                    <div class="col-md-36">
                                        <span>2. กด => เพื่อทำรายการให้กับผู้บริจาค</span>
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
                                        <table id="tbInfo" class="table table-bordered table-dis-input" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
                                            <thead>
                                                <tr>
                                                    <th class="col-md-2"><button sortOrder="QUEUE_NUMBER">คิวที่<i class="glyphicon glyphicon-triangle-bottom"></i></button>
                                                    </th>
                                                    <th class="col-md-6"><button sortOrder="name">ชื่อ-นามสกุล</button>
                                                    </th>
                                                    <th class="col-md-4"><button sortOrder="SAMPLE_NUMBER">Sample No.</button>
                                                    </th>
                                                    <th class="col-md-6"><button>หมายเหตุ</button>
                                                    </th>
                                                    <th class="col-md-4" colspan="2"><button>ลงทะเบียน</button>
                                                    </th>
                                                    <th class="col-md-4" colspan="2"><button>คัดกรอง</button>
                                                    </th>
                                                    <th class="col-md-4" colspan="2"><button>บริจาค</button>
                                                    </th>
                                                    <th class="col-md-4" colspan="2"><button>Lab</button>
                                                    </th>
                                                    <th class="col-md-2"></th>
                                                </tr>
                                                <tr class="no-transaction" style="display:none;"><td align="center" colspan="13">ไม่พบข้อมูล</td></tr>
                                                <tr class="more-loading" style="display:none;"><td align="center" colspan="13">Loading detail...</td></tr>
                                                <tr class="template-data" style="display:none;" refID="NEW">
                                                    <td class="td-queue text-center">
                                                    </td>
                                                    <td>
                                                        <input type="text" class="td-name" readonly />
                                                    </td>
                                                    <td>
                                                        <input type="text" class="td-sample" readonly />
                                                    </td>
                                                    <td>
                                                        <input type="text" class="td-remarks" readonly />
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
                                                    <td>
                                                        <div class="text-center">
                                                            <a class="icon"><span class="glyphicon glyphicon-pencil" aria-hidden="true" onclick="return $(this).queueSelect();"></span></a>
                                                            <a class="icon"><span class="icon-blood-bag" aria-hidden="true" onclick="return false;"></span></a>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                <tr class="no-transaction"><td align="center" colspan="13">ไม่พบข้อมูล</td></tr>
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
            <div id="postQueuePane">
                <div class="border-box">
                    <div id="post-content-one" style="padding-left:15px; padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36 text-center">
                                <span id="spQueueHeader" style="font-size: larger;"></span>
                            </div>
                        </div>
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
                                <input id="txtPostQueue" class="form-control color-yellow mandatory" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtPostDonorNumber" class="form-control color-yellow mandatory" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtPostNationNumber" class="form-control color-yellow mandatory" type="text" />
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
                                <select id="ddlPostBloodGroup" style="width:90px;">
                                    <option>A</option>
                                    <option>A-</option>
                                    <option>A+</option>
                                    <option>AB</option>
                                    <option>AB-</option>
                                    <option>AB+</option>
                                    <option>B</option>
                                    <option>B-</option>
                                    <option>B+</option>
                                    <option>O</option>
                                    <option>O-</option>
                                    <option>O+</option>
                                </select>
                            </div>
                            <div class="col-md-3">
                                <input id="txtPostSample" class="form-control" type="text" />
                            </div>
                            <div class="col-md-2 text-center">
                                <button id="spPostClear" class="btn btn-icon" onclick="return false;" style="padding: 0;" tabindex="-1">
                                    <i class="glyphicon glyphicon-remove" style="vertical-align: text-top;"></i>
                                </button><button id="spPostSearch" class="btn btn-icon" onclick="return false;" style="padding: 0;">
                                    <i class="glyphicon glyphicon-search" style="vertical-align: text-top;"></i>
                                </button>
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
                                <table id="tbPostQueue" class="table table-bordered table-dis-input" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
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
                                            <th class="col-md-4" colspan="2"><button>บริจาค</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>Lab</button>
                                            </th>
                                            <th class="col-md-1"></th>
                                        </tr>
                                        <tr class="no-transaction" style="display:none;"><td align="center" colspan="13">ไม่พบข้อมูล</td></tr>
                                        <tr class="more-loading" style="display:none;"><td align="center" colspan="13">Loading detail...</td></tr>
                                        <tr class="template-data" style="display:none;" refID="NEW">
                                            <td class="td-queue text-center">
                                            </td>
                                            <td>
                                                <input type="text" class="td-name" readonly />
                                            </td>
                                            <td>
                                                <input type="text" class="td-sample" readonly />
                                            </td>
                                            <td>
                                                <input type="text" class="td-remarks" readonly />
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
                                        <tr class="no-transaction"><td align="center" colspan="13">ไม่พบข้อมูล</td></tr>
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
