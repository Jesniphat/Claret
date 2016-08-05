<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="historyReport.aspx.vb" Inherits="Claret.donor_historyReport" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            $.extend($.fn, {
                queueSelect: function () {
                    $("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID") });
                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                },
            });
            $("#txtReportDate").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-30:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtPostQueue").focus();
                },
            });
            $("#txtPostBirthday").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtPostBloodGroup").focus();
                },
            });
            $("#divPostCriteria input").enterKey(function () {
                postQueueSearch(true);
                return false;
            });
            $("#spPostSearch").click(function () {
                postQueueSearch(true);
            });
            $("#spPostClear").click(function () {
                $("#divPostCriteria input").H2GValue('');
                $("#txtPostQueue").focus();
            });
            
            $("#ddlStatus").setDropdownList();
            $("#txtReportDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy"));
            //postQueueSearch(true);

            // menu control
            if ($("#data").H2GAttr("lmenu") == "lmenuHistoryReport") {
                $(".claret-page-header span").H2GValue("รายงานย้อนหลัง");
                $("#txtPostQueue").focus();

            } else if ($("#data").H2GAttr("lmenu") == "lmenuInterview") {
                $(".claret-page-header span").H2GValue("คัดกรอง");
                $(".collection-page-header").show();
                $("#ddlITVDonationType").setDropdownListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'donationtype' },
                }).on('change', function () {
                    $("#ddlITVBag").closest("div").focus();
                });
                $("#ddlITVBag").setDropdownListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'bag' },
                }).on('change', function () {
                    $("#ddlITVDonationTo").closest("div").focus();
                });
                $("#ddlITVDonationTo").setDropdownListValue({
                    url: '../../ajaxAction/masterAction.aspx',
                    data: { action: 'donationto' },
                }).on('change', function () {
                    $("#txtPostQueue").focus();
                });
                $("#ddlStatus").H2GValue("WAIT INTERVIEW").change().H2GDisable();
                $("#txtReportDate").H2GDisable();
                $("#ddlITVDonationType").closest("div").focus();
            }
        });
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
                        , reportdate: $("#txtReportDate").H2GValue()
                        , status: $("#ddlStatus").H2GValue()
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
                                        $(dataRow).find('.td-interview-staff').append(e.InterviewStaff).H2GAttr("title", e.InterviewStaff);
                                        $(dataRow).find('.td-interview-time').append(e.InterviewTime).H2GAttr("title", e.InterviewTime);
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

                        $(dataView).closest("table").find("thead button").click(function () { sortButton($(this), postQueueSearch); return false; });
                        genGridPage($(dataView).closest("table"), postQueueSearch);
                        $("#txtPostQueue").focus();
                    }
                });    //End ajax
            }
        }
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>รายงานย้อนหลัง</span>
        </div>
    </div>
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
                <div class="col-md-7">
                    <select id="ddlITVDonationType" class="text-left" style="width:100%;">
                        <option value="0">Loading...</option>
                    </select>
                </div>
                <div class="col-md-3 text-right">
                    <span>ประเภทถุง</span>
                </div>                                                        
                <div class="col-md-7">
                    <select id="ddlITVBag" class="text-left" style="width:100%;">
                        <option value="0">Loading...</option>
                    </select>
                </div>
                <div class="col-md-4 text-right">
                    <span>การนำไปใช้งาน</span>
                </div>                                                        
                <div class="col-md-7">
                    <select id="ddlITVDonationTo" class="text-left" style="width:100%;">
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
                    <select id="ddlStatus">
                        <option value="" selected="selected">ALL</option>
                        <option>WAIT INTERVIEW</option>
                        <option>WAIT COLLECTION</option>
                        <option>WAIT RESULT</option>
                        <option>FINISH</option>
                        <option>CANCEL</option>
                    </select>
                </div>
            </div>
            <div id="post-content-one" class="col-md-36" style="padding-left:15px; padding-bottom: 20px;">
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
            <div id="post-content-two" class="col-md-36" style="padding-left:15px;padding-bottom: 20px;">
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
</asp:Content>
