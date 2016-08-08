<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="planningInfo.aspx.vb" Inherits="Claret.planning_info" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            $("#btnTest").button();
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>แผนการดำเนินงาน</span>
        </div>
    </div>
    <div class="row" id="planningBox">
        <div class="row">
            <div class="col-md-5">
                <span><b>1. เพิ่มแผนรับบริจาคใหม่</b></span>
            </div>
            <div class="col-md-5">
                <input id="btnPlan" type="button" class="btn btn-success btn-block" value="เพิ่มแผนงานรับบริจาคใหม่" />
            </div>
        </div>
        <br />
        <div class="row">
            <div class="col-md-5">
                <span><b>2. ค้นหาแผนงานเก่า</b></span>
            </div>
        </div>
        <div class="row" style="padding-left: 15px;">
            <div class="col-md-5">
                <span>รหัสภาค</span>
            </div>
            <div class="col-md-5">
                <span>รหัสหน่วย</span>
            </div>
            <div class="col-md-11">
                <span>ชื่อหน่วย</span>
            </div>
            <div class="col-md-5">
                <span>แผนงานวันที่</span>
            </div>
            <div class="col-md-5">
                <span>สถานะ</span>
            </div>
            <div class="col-md-3">
                <span>ประเภทงาน</span>
            </div>
        </div>
        <div class="row" style="padding-left: 15px;">
            <div class="col-md-36">
                <div style="background-color: #CCCCCC; height: 2px;"></div>
            </div>
        </div>
        <div id="divCriteria" class="row" style="padding-top: 3px; padding-bottom: 3px; padding-left:15px;">
            <div class="col-md-5">
                <input id="txtSectorCode" class="form-control color-yellow" type="text" />
            </div>
            <div class="col-md-5">
                <input id="txtDepartmentCode" class="form-control color-yellow" type="text" />
            </div>
            <div class="col-md-11">
                <input id="txtDepartmentName" class="form-control" type="text" />
            </div>
            <div class="col-md-5">
                <input id="txtPlanDate" class="form-control" type="text" />
            </div>
            <div class="col-md-5">
                <input id="txtPlanStatus" class="form-control" type="text" />
            </div>
            <div class="col-md-3">
                <input id="txtPlanType" class="form-control text-center" type="text" />
            </div>
            <div class="col-md-2">
                <div class="col-md-36">
                    <a title="ลบข้อมูลที่กรอก"><span id="spClear" class="glyphicon glyphicon-remove"></span></a>
                    <a title="ค้นหา"><span id="spSearch" class="glyphicon glyphicon-search"></span></a>
                </div>
            </div>
        </div>
        <div class="row">
            <div class="col-md-36">
                <span><b>3. กรุณาเลือกแผนการดำเนินงาน</b></span>
            </div>
        </div>

        <div class="row" style="padding-left: 15px;">
            <div class="col-md-36">
                <table id="tbDonor" class="table table-hover table-striped" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="donor_number">
                    <thead>
                        <tr>
                            <th class="col-md-5">
                                <button sortOrder="donor_number">
                                    <span>รหัสภาค<i class="glyphicon glyphicon-triangle-bottom"></i></span>
                                </button>
                            </th>
                            <th class="col-md-5">
                                <button sortOrder="nation_number">
                                    <span>รหัสหน่วย</span>
                                </button>
                            </th>
                            <th class="col-md-11">
                                <button sortOrder="external_number">
                                    <span>ชื่อหน่วย</span>
                                </button>
                            </th>
                            <th class="col-md-5">
                                <button sortOrder="name">
                                    <span>แผนงานวันที่</span>
                                </button>
                            </th>
                            <th class="col-md-5">
                                <button sortOrder="surname">
                                    <span>สถานะ</span>
                                </button>
                            </th>
                            <th class="col-md-3">
                                <button sortOrder="birthday">
                                    <span>ประเภทงาน</span>
                                </button>
                            </th>
                            <th class="col-md-2"></th>
                        </tr>
                        <tr class="no-transaction" style="display:none;"><td align="center" colspan="7">ไม่พบข้อมูล</td></tr>
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
                        <tr class="no-transaction"><td align="center" colspan="7">ไม่พบข้อมูล</td></tr>
                    </tbody>
                    <tfoot>
                        <tr>
                            <td align="right" colspan="7">
                                <div class="page">
                                </div>
                            </td>
                        </tr>
                    </tfoot>
                </table>
            </div>
        </div>

    </div>
</asp:Content>
