<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="Donate.aspx.vb" Inherits="Claret.Donate" %>
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
            
            $("#donateStatus").setDropdownList();
            $("#donateDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                maxDate: "0",
                minDate: new Date(),
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) { $("#txtDonorComment").focus(); },
            }).prop({disabled:true});

            $("#btnIssue").click(linkToCollection);
            $("#spSearch").click(function () {
                donateSearch(true);
            });
            donateSearch(true);

            $.extend($.fn, {
                queueSelect: function () {
                    var param = {
                        donateAction: "edit",
                        donateType: $("#donateType").val(),
                        donateBagType: $("#donateBagType").val(),
                        donateApply: $("#donateApply").val(),
                        donateDate: $("#donateDate").val(),
                        donateStatus: $("#donateStatus").val()
                    };
                    $("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID") });
                    $('<form>').append(H2G.postedData($("#data").H2GFill(param))).H2GFill({ action: "Collection.aspx", method: "post" }).submit();
                },
            });
        })
    </script>
    <style>
        #donateTab .border-box {
            background:#FFFFFF;
        }
    </style>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div>
            <span>บริจาค</span>
        </div>
    </div>
    <div id="donateTabBox" class="row">
        <div id="donateTab">
            <ul>
                <li><a href="#donatePane" style="">Donate</a></li>
                <%--<li><a href="#postQueuePane" style="">Post Queue</a></li>--%>
            </ul>
            <div id="donatePane">
                <div class="border-box">
                    <div class="border-box">
                        <p><label>กำหนดประเภทของการรับบริจาคที่กำลังจะดำเนินงาน</label></p>
                        <div class="col-md-36">
                            <div class="col-md-4 text-right setPaddingRight">ประเภทการบริจาค</div>
                            <div class="col-md-7">
                                <select id="donateType">
                                </select>
                            </div>
                            <div class="col-md-4 text-right setPaddingRight">ประเภทถุง</div>
                            <div class="col-md-7">
                                <select id="donateBagType">
                                </select>
                            </div>
                            <div class="col-md-4 text-right setPaddingRight">การนำไปใช้งาน</div>
                            <div class="col-md-7">
                                <select id="donateApply">
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
                                    <option value="WAIT INTEVEIW">WAIT INTEVEIW</option>
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
                                    <span>1. ค้นหาขผู้บริจาคหรือเลือกทำรายการจากคิวในขั้นตอนที่ 2</span>
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
                                    <input id="txtPostSample" class="form-control text-center" type="text" />
                                </div>
                                <div class="col-md-2">
                                    <div class="col-md-36">
                                        <a title="ลบข้อมูลที่กรอก"><span id="spClear" class="glyphicon glyphicon-remove"></span></a>
                                        <a title="ค้นหา"><span id="spSearch" class="glyphicon glyphicon-search"></span></a>
                                    </div>
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
            <%--<div id="postQueuePane">
                <h2>XXXMM</h2>
            </div>--%>
        </div>
    </div>
</asp:Content>
