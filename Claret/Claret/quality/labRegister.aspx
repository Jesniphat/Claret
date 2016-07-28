<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="labRegister.aspx.vb" Inherits="Claret.labRegister" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        #tbExam > tbody > tr > td:last-child {
            border-top-color: transparent;
            border-right-color: transparent;
            border-bottom-color: transparent;
            background-color: white;
        }
    </style>
    <script type="text/javascript">
        //$("td:last-child").css({ border: "none" })
        $(function () {
            $("#ddlHospital").setDropdowListValue({ url: '../ajaxAction/masterAction.aspx', data: { action: 'hospital' } }).on("change", function () {
                $("#txtHospital").H2GValue($("#ddlHospital").H2GValue());
            });
            $("#ddlLab").setDropdowListValue({ url: '../ajaxAction/masterAction.aspx', data: { action: 'lab' } }).on("change", function () {
                $("#txtLab").H2GValue($("#ddlLab").H2GValue());
            });
            $("#txtHospital").blur(function () { $("#ddlHospital").val($("#txtHospital").val().toUpperCase()).change(); });
            $("#txtLab").blur(function () { $("#ddlLab").val($("#txtLab").val().toUpperCase()).change(); });

            $("#ddlExam").setAutoListValue({ url: '../ajaxAction/masterAction.aspx', data: { action: 'examination' } }).on('autocompleteselect',
                function () {
                    $("#txtMobile1").focus();
                });
        });
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>ลงทะเบียนขอตรวจ LAB</span>
        </div>
    </div>
    <div id="content-one" style="padding-left:15px; padding-bottom: 20px;">
        <div class="row">
            <div class="col-md-18">
                <div class="border-box">
                    <div class="row"><div class="col-md-35 col-md-offset-1">ข้อมูลทั่วไป</div></div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">วันที่ส่งตรวจ</div>
                        <div class="col-md-10"><input id="txtDate" type="text" class="form-control required text-center" /></div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">โรงพยาบาล/ภาคบริการโลหิต</div>
                        <div class="col-md-5"><input id="txtHospital" type="text" class="form-control required" /></div>
                        <div class="col-md-17">
                            <select id="ddlHospital" class="required text-left" style="width:100%;" tabindex="-1">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">แผนก</div>
                        <div class="col-md-5"><input id="txtDepartment" type="text" class="form-control required" /></div>
                        <div class="col-md-17">
                            <select id="ddlDepartment" class="required text-left" style="width:100%;" tabindex="-1">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">ชื่อเจ้าหน้าที่ผู้ขอตรวจ</div>
                        <div class="col-md-22"><input id="txtStaff" type="text" class="form-control required" /></div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">สาเหตุการขอ</div>
                        <div class="col-md-22"><input id="txtReason" type="text" class="form-control required" /></div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">ทำ LAB EXAMINATION  ที่</div>
                        <div class="col-md-5"><input id="txtLab" type="text" class="form-control required" /></div>
                        <div class="col-md-17">
                            <select id="ddlLab" class="required text-left" style="width:100%;" tabindex="-1">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">ประเภทการบริจาค</div>
                        <div class="col-md-22"><input id="txtDonationTo" type="text" class="form-control required" /></div>
                    </div>
                </div>
            </div>
            <div class="col-md-18">
                <div class="border-box">
                    <div class="row">
                        <div class="col-md-35 col-md-offset-1">LAB EXAMINATION</div>
                    </div>
                    <div class="row">
                        <div class="col-md-9 col-md-offset-1"><input id="txtExamCode" type="text" class="form-control" /></div>
                        <div class="col-md-23">
                            <select id="ddlExam" class="text-left" style="width:100%;" tabindex="-1">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-34 col-md-offset-1">
                            <table id="tbExam" class="table table-bordered table-striped" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
                                <thead>
                                    <tr class="no-transaction" style="display:none;"><td align="center" colspan="13">ไม่พบข้อมูล</td></tr>
                                    <tr class="more-loading" style="display:none;"><td align="center" colspan="13">Loading detail...</td></tr>
                                    <tr class="template-data" style="display:none;" refID="NEW">
                                        <td class="col-md-34 td-exam">
                                        </td>
                                        <td class="col-md-2">
                                            <div class="text-center">
                                                <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="return false;"></span></a>
                                            </div>
                                        </td>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr class="no-transaction">
                                        <td class="col-md-34 td-exam">Lymphocyte Crossmatch Conclusion (peak)</td>
                                        <td class="col-md-2">
                                            <div class="text-center">
                                                <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="return false;"></span></a>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr class="no-transaction">
                                        <td class="col-md-34 td-exam">Molecular size distribution (monomer) 3</td>
                                        <td class="col-md-2">
                                            <div class="text-center">
                                                <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="return false;"></span></a>
                                            </div>
                                        </td>
                                    </tr>
                                    <tr class="no-transaction">
                                        <td class="col-md-34 td-exam">HIV/HCV/HBV NAT for QC (COMNAT + NATR)</td>
                                        <td class="col-md-2">
                                            <div class="text-center">
                                                <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="return false;"></span></a>
                                            </div>
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
