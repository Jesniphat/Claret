﻿<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="Donate.aspx.vb" Inherits="Claret.Donate" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../resources/css/donateStyle.css" rel="stylesheet" />
    <script src="../resources/javascript/page/donateScript.js" type="text/javascript"></script>
    <script>
        $(function () {
            $("#donateTab").tabs({
                active: 0
            });
            getDonateTypeList();
            getDonateBagTypeList();
            getDonateApplyList();

            $("#ddlBloodGroup").setAutoList();
            $("#ddlPostBloodGroup").setAutoList();

            $("#confirmCancelDonateWaitCallection").dialog({
                autoOpen: false,
                buttons: {
                    OK: function () {
                        cancelDonateWaitCollection(cancelDonorId, cancelVisitId);
                        $(this).dialog("close");
                    },
                    CANCEL: function () {
                        // clareData();
                        $(this).dialog("close");
                    }
                },
                title: "Warning"
            });

            $("#confirmCancelDonateWaitResult").dialog({
                autoOpen: false,
                buttons: {
                    OK: function () {
                        cancelDonateWaitResult(cancelDonorId, cancelVisitId);
                        $(this).dialog("close");
                    },
                    CANCEL: function () {
                        // clareData();
                        $(this).dialog("close");
                    }
                },
                title: "Warning"
            });

            $("#donateStatus").setDropdownList();
            $("#donateDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                maxDate: "0",
                minDate: new Date(),
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) { $("#txtDonorComment").focus(); },
            }).prop({disabled:true});
            $("#spQueueHeader").H2GValue("คิวประจำวันที่ " + formatDate(new Date(getDateFromFormat($("#data").H2GAttr("plan_date"), "dd/mm/yyyy")), " dd MMM พ.ศ. yyyy"));
            $("#btnIssue").click(linkToCollection);
            $("#spSearch").click(function () {
                donateSearch(true);
            });
            $("#spClear").click(function () {
                $("#divCriteria input").H2GValue('');
                $("#txtPostQueue").focus();
                donateSearch(true);
            });
            $("#spPostSearch").click(function () {
                postQueueSearch(true);
            });
            $("#spPostClear").click(function () {
                $("#divPostCriteria input").H2GValue('');
                $("#txtQueue").focus();
                postQueueSearch(true);
            });
            $("#divPostCriteria input").enterKey(function () {
                postQueueSearch(true);
                return false;
            });
            $("#divCriteria input").enterKey(function () {
                donateSearch(true);
                return false;
            });

            //$("#txtName").H2GNamebox(37);
            //$("#txtSurname").H2GNamebox(37);
            $("#txtBirthday").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtBloodGroup").focus();
                },
            });
            $("#txtPostBirthday").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtBloodGroup").focus();
                },
            });

            donateSearch(true);
            postQueueSearch(true);

            $.extend($.fn, {
                queueSelect: function () {
                    var param = {
                        donateAction: "edit",
                        donatesubaction: "a",
                        donateType: $("#donateType").val() || "0",
                        donateBagType: $("#donateBagType").val() || "0",
                        donateApply: $("#donateApply").val() || "0",
                        donateDate: $("#donateDate").val(),
                        donateStatus: $("#donateStatus").val()
                    };
                    $("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID") });
                    $('<form>').append(H2G.postedData($("#data").H2GFill(param))).H2GFill({ action: "Collection.aspx", method: "post" }).submit();
                },
                postQueueSelect: function () {
                    var param = {
                        donateAction: "edit",
                        donatesubaction: "b",
                        donateType: $("#donateType").val() || "0",
                        donateBagType: $("#donateBagType").val() || "0",
                        donateApply: $("#donateApply").val() || "0",
                        donateDate: $("#donateDate").val(),
                        donateStatus: $("#donateStatus").val()
                    };
                    $("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID") });
                    $('<form>').append(H2G.postedData($("#data").H2GFill(param))).H2GFill({ action: "Collection.aspx", method: "post" }).submit();
                    //$("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID") });
                    //$('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                },
                queueSelectCancel: function () {
                    console.log("Cancel = ", $(this).closest("tr").H2GAttr("donorID"), " = ", $(this).closest("tr").H2GAttr("refID"));
                    cancelDonorId = $(this).closest("tr").H2GAttr("donorID");
                    cancelVisitId = $(this).closest("tr").H2GAttr("refID");
                    // cancelDonateWaitCollection($(this).closest("tr").H2GAttr("donorID"), $(this).closest("tr").H2GAttr("refID"));
                    $("#confirmCancelDonateWaitCallection").dialog("open");
                },
                postQueueSelectCancel: function () {
                    console.log("Cancel WaitResult = ", $(this).closest("tr").H2GAttr("donorID"), " = ", $(this).closest("tr").H2GAttr("refID"));
                    cancelDonorId = $(this).closest("tr").H2GAttr("donorID");
                    cancelVisitId = $(this).closest("tr").H2GAttr("refID");
                    // cancelDonateWaitResult($(this).closest("tr").H2GAttr("donorID"), $(this).closest("tr").H2GAttr("refID"));
                    $("#confirmCancelDonateWaitResult").dialog("open");
                }
            });
        })
        function postQueueSearch(newSearch) {
            var dataView = $("#tbQueue > tbody");
            $(dataView).H2GValue($("#tbQueue > thead > tr.more-loading").clone().show());
            if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
                if (newSearch) { $("#tbQueue").attr("currentPage", 1) }
                $(dataView).closest("table").H2GAttr("wStatus", "working");
                $.ajax({
                    //url: '../../ajaxAction/donorAction.aspx',
                    url: '../../ajaxAction/donateAction.aspx',
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
                        , reportdate: $("#data").H2GAttr("plan_date") //formatDate(H2G.today(), "dd/MM/yyyy") //$("#txtReportDate").H2GValue()
                        , status: "WAIT RESULT"
                        , receipthospitalid: ""
                        , p: $("#tbQueue").attr("currentPage") || 1
                        , so: $("#tbQueue").attr("sortOrder") || "queue_number"
                        , sd: $("#tbQueue").attr("sortDirection") || "desc"                        
                    },
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                        $(dataView).H2GValue($("#tbQueue > thead > tr.no-transaction").clone().show());
                        $(dataView).closest("table").H2GAttr("wStatus", "error");
                    },
                    success: function (data) {
                        $(dataView).H2GValue('');
                        if (!data.onError) {
                            data.getItems = jQuery.parseJSON(data.getItems);
                            if (data.getItems.PostQueueList.length > 0) {
                                if (data.getItems.GoNext == "Y") {
                                    $.each((data.getItems.PostQueueList), function (index, e) {
                                        var dataRow = $("#tbQueue > thead > tr.template-data").clone();
                                        $(dataRow).H2GFill({ refID: e.VisitID, donorID: e.DonorID }).queueSelect();
                                    });
                                } else {
                                    $.each((data.getItems.PostQueueList), function (index, e) {
                                        var dataRow = $("#tbQueue > thead > tr.template-data").clone().show();
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
                                $(dataView).H2GValue($("#tbQueue > thead > tr.no-transaction").clone().show());
                                $(dataView).closest("table").attr("totalPage", 0)
                            }
                        } else {
                            $(dataView).H2GValue($("#tbQueue > thead > tr.no-transaction").clone().show());
                            $(dataView).closest("table").attr("totalPage", 0)
                        }
                        $(dataView).closest("table").H2GAttr("wStatus", "done");
                        genGridPage($(dataView).closest("table"), postQueueSearch);
                        $("#txtQueue").focus();
                    }
                });    //End ajax
            }
        }
    </script>
    <style>
        #donateTab .border-box {
            background:#FFFFFF;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>บริจาค</span>
        </div>
    </div>
    <div id="donateTabBox" class="row">
        <div id="donateTab">
            <ul>
                <li><a href="#donatePane" style="">Donate</a></li>
                <li><a href="#postQueuePane" style="">Post Queue</a></li>
            </ul>
            <div id="donatePane">
                <div class="border-box">
                    <div class="border-box">
                        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
                         <span>กำหนดประเภทของการรับบริจาคที่กำลังจะดำเนินงาน</span>
                        </div>
                        <div class="col-md-36">
                            <div class="col-md-4 text-right setPaddingRight">ประเภทการบริจาค</div>
                            <div class="col-md-7">
                                <select id="donateType" class="selecte-box-custom">

                                </select>
                            </div>
                            <div class="col-md-4 text-right setPaddingRight">ประเภทถุง</div>
                            <div class="col-md-7">
                                <select id="donateBagType" class="selecte-box-custom">

                                </select>
                            </div>
                            <div class="col-md-4 text-right setPaddingRight">การนำไปใช้งาน</div>
                            <div class="col-md-7">
                                <select id="donateApply" class="selecte-box-custom">

                                </select>
                            </div>
                            <div class="col-md-3"><input id="btnIssue" type="button" class="btn btn-success btn-block" value="ดำเนินการ" /></div>
                        </div>
                    </div>
                    <div class="border-box" style="margin-top:10px">
                        <div class="col-md-36">
                            <div class="col-md-8"></div>
                            <div class="col-md-4 text-right setPaddingRight">รายการวันที่</div>
                            <div class="col-md-5">
                                <input type="text" id="donateDate" class="col-md-36 form-control" value="" readonly/>
                            </div>
                            <div class="col-md-2 text-right setPaddingRight">สถานะ</div>
                            <div class="col-md-9">
                                <select id="donateStatus" disabled>
                                    <option value="REGISTER">REGISTER</option>
                                    <option value="WAIT INTERVEIW">WAIT INTERVEIW</option>
                                    <option value="WAIT COLLECTION" selected>WAIT COLLECTION</option>
                                    <option value="WAIT RESULT">WAIT RESULT</option>
                                    <option value="FINISH">FINISH</option>
                                    <option value="CANCEL">CANCEL</option>
                                </select>
                            </div>
                            <div class="col-md-8"></div>
                        </div>
                    </div>
                    <div class="border-box">
                        <div id="content-one" style="padding-left:15px; padding-bottom: 20px;">
                            <div class="row">
                                <div class="col-md-36">
                                    <span>1. ค้นหาผู้บริจาคหรือเลือกทำรายการจากคิวในขั้นตอนที่ 2</span>
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
                                    <span>Sample No</span>
                                </div>
                                <%--<div class="col-md-2">
                                
                                </div>--%>
                            </div>
                            <div class="row" style="padding-left: 15px;">
                                <div class="col-md-36">
                                    <div style="background-color: #CCCCCC; height: 2px;"></div>
                                </div>
                            </div>
                            <div id="divCriteria" class="row" style="padding-top: 3px; padding-bottom: 3px; padding-left:15px;">
                                <div class="col-md-2">
                                    <input id="txtPostQueue" class="form-control color-yellow" type="text" tabindex="1" />
                                </div>
                                <div class="col-md-6">
                                    <input id="txtPostDonorNumber" class="form-control color-yellow" type="text" tabindex="2" />
                                </div>
                                <div class="col-md-6">
                                    <input id="txtPostNationNumber" class="form-control color-yellow" type="text" tabindex="3" />
                                </div>
                                <div class="col-md-6">
                                    <input id="txtPostName" class="form-control" type="text" tabindex="4" />
                                </div>
                                <div class="col-md-5">
                                    <input id="txtPostSurname" class="form-control" type="text" tabindex="5" />
                                </div>
                                <div class="col-md-3">
                                    <input id="txtPostBirthday" class="form-control text-center" type="text" tabindex="6" />
                                </div>
                                <div class="col-md-3">
                                    <select id="ddlPostBloodGroup" style="width:90px;" tabindex="7">
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
                                    <input id="txtPostSample" class="form-control text-center color-yellow" type="text" tabindex="8" />
                                </div>
                                <div class="col-md-2">
                                    <div class="col-md-36">
                                        <a title="ลบข้อมูลที่กรอก" tabindex="9"><span id="spClear" class="glyphicon glyphicon-remove"></span></a>
                                        <a title="ค้นหา" tabindex="10"><span id="spSearch" class="glyphicon glyphicon-search"></span></a>
                                    </div>
                                </div>
                            </div>
                        </div>
                        <div id="content-two" style="padding-left:15px;padding-bottom: 20px;">
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
                                    <table id="tbPostQueue" class="table table-bordered" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
                                        <thead>
                                            <tr>
                                                <th class="col-md-2"><button sortOrder="QUEUE_NUMBER">คิวที่<i class="glyphicon glyphicon-triangle-bottom"></i></button>
                                                </th>
                                                <th class="col-md-7"><button sortOrder="name">ชื่อ-นามสกุล</button>
                                                </th>
                                                <th class="col-md-4"><button sortOrder="SAMPLE_NUMBER">Sample No.</button>
                                                </th>
                                                <th class="col-md-5"><button>หมายเหตุ</button>
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
                                                <td class="col-md-2">
                                                    <div>
                                                        <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="return $(this).queueSelectCancel();"></span></a>
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
                                <input id="txtQueue" class="form-control color-yellow" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtDonorNumber" class="form-control color-yellow" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtNationNumber" class="form-control color-yellow" type="text" />
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
                                <select id="ddlBloodGroup" style="width:90px;" tabindex="7">
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
                                <input id="txtSample" class="form-control color-yellow" type="text" />
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
                                <table id="tbQueue" class="table table-bordered table-dis-input" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
                                    <thead>
                                        <tr>
                                            <th class="col-md-2"><button sortOrder="QUEUE_NUMBER">คิวที่<i class="glyphicon glyphicon-triangle-bottom"></i></button>
                                            </th>
                                            <th class="col-md-7"><button sortOrder="name">ชื่อ-นามสกุล</button>
                                            </th>
                                            <th class="col-md-4"><button sortOrder="SAMPLE_NUMBER">Sample No.</button>
                                            </th>
                                            <th class="col-md-5"><button>หมายเหตุ</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>ลงทะเบียน</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>คัดกรอง</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>จัดเก็บ</button>
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
                                            <td class="col-md-2">
                                                <div>
                                                    <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="return $(this).postQueueSelectCancel();"></span></a>
                                                    <a class="icon"><span class="glyphicon glyphicon-arrow-right" aria-hidden="true" onclick="return $(this).postQueueSelect();"></span></a>
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

    <div id="confirmCancelDonateWaitCallection" title="">ต้องการยกเลิกรายการบริจาคนี้ใช่หรือไม่</div>
    <div id="confirmCancelDonateWaitResult" title="">ต้องการยกเลิกรายการบริจาคนี้ใช่หรือไม่</div>
</asp:Content>
