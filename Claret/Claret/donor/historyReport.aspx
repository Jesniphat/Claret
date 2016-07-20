<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="historyReport.aspx.vb" Inherits="Claret.donor_historyReport" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            $("#txtReportDate").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-30:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtPostQueue").focus();
                },
            });
            
            $("#ddlStatus").setDropdowList();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>รายงานย้อนหลัง</span>
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
                        <option>WAIT INTEVEIW</option>
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
</asp:Content>
