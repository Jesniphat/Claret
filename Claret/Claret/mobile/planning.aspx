﻿<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="planning.aspx.vb" Inherits="Claret.planning" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .colour-pink {
            background-color: #FFF5F5;
        }
        .table > tbody > tr > td {
            padding: 7px 5px;
        }
    </style>
    <script src="../resources/javascript/page/planning.js" type="text/javascript"></script>
    <script>
        $(function () {

            $("#donateDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                // maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    // $("#txtHospital").focus();
                    //getDornorHospitalList(selectedDate);
                },
            });
            
            $("#txtDepartment").blur(function () { $("#ddlDepartment").val($("#txtDepartment").val().toUpperCase()).change(); });
            $("#txtRegion").blur(function () { $("#ddlRegion").val($("#txtRegion").val().toUpperCase()).change(); });
            
            if ($("#data").attr("planningaction") == "new") {
                setDDL(true);
            } else {
                $("#ddlDepartment").H2GAttr("selectItem", '5E0001')
                setDDL(false);
            }

        });

        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>สร้างแผนการดำเนินงาน > เพิ่มแผนงานการรับบริจาค</span>
        </div>
    </div>
    <div class="row" id="firstRowDate" style="padding-right:2px;">
        <div class="border-box">
            <div class="col-md-20">
                <div class="col-md-7">
                    <span>วันที่รับบริจาค </span>
                </div>
                <div class="col-md-15">
                    <input class="form-control required" id="donateDate" type="text" value="" />
                </div>
            </div>
            <div class="col-md-16">
                <div class="col-md-27"></div>
                <div class="col-md-3">
                    สถานะ
                </div>
                <div class="col-md-6">
                    <select id="planningStatus" class="selecte-box-custom required">
                        <option selected="selected" value="ACTIVE">ACTIVE</option>
                        <option value="INACTIVE">INACTIVE</option>
                    </select>
                </div>
            </div>
        </div>
    </div>

    <div class="row" id="seccenRow">
        <div class="col-md-20">
            <div class="row border-box" style="padding-left:8px;">
                <div class="row" style="margin-bottom:4px;">
                    <div class="col-md-29" style="border-bottom:solid 1px #cccccc"><span>ข้อมูลทั่วไป</span></div>
                    <div class="col-md-7" style="border-bottom:solid 1px #cccccc">
                        <label class="checkbox-inline" style="padding-bottom: 2px;"><input id="masterPlan" type="checkbox" value="" />แผนงานต้นแบบ</label>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>ภาค</span></div>
                    <div class="col-md-5" style="text-align:right;padding-right: 0;">
                        <input id="txtRegion" type="text" class="form-control required" placeholder="ภาค" />
                    </div>
                    <div class="col-md-17" style="padding-left: 5px;">
                        <select id="ddlRegion" class="required text-left" style="width:100%;" tabindex="-1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>รหัสหน่วย</span></div>
                    <div class="col-md-5" style="text-align:right;padding-right: 0;">
                        <input id="txtDepartment" type="text" class="form-control required" placeholder="หน่วยงาน" />
                    </div>
                    <div class="col-md-17" style="padding-left: 5px;">
                        <select id="ddlDepartment" class="required text-left" style="width:100%;" tabindex="-1">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>สถานที่ตั้ง</span></div>
                    <div class="col-md-12">
                        <input class="form-control" id="departmentLocation" type="text" value="" readonly/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>ที่อยู่</span></div>
                    <div class="col-md-29">
                        <textarea class="form-control" id="departmentAddr" readonly></textarea>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>แขวง/ตำบล</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentSubDistrict" type="text" value="" readonly/>
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>เขต/อำเภอ</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentDistrict" type="text" value="" readonly/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>จังหวัด</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentProvince" type="text" value="" readonly/>
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>รหัสไปรษณีย์</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentZipcode" type="text" value="" readonly/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>ประเทศ</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentCountry" type="text" value="" readonly/>
                    </div>
                </div>
            </div>
            <div class="row border-box" style="margin-top:2px;">
                <div class="row" style="margin-bottom:4px;">
                    <div class="col-md-36" style="border-bottom:solid 1px #cccccc"><span>ช่องทางติดต่อหน่วยงาน</span></div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>เบอร์มือถือ 1</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentMobile1" type="text" value="" readonly/>
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>Email</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentEmail" type="text" value="" readonly/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>เบอร์มือถือ 2</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentMobile2" type="text" value="" readonly/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>เบอร์ที่ทำงาน</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentTel" type="text" value="" readonly/>
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>เบอร์ต่อ</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentTelMore" type="text" value="" readonly/>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-16">
            <div class="row border-box">
                <div class="row" style="margin-bottom:4px;">
                    <div class="col-md-36" style="border-bottom:solid 1px #cccccc"><span>ประเภทของงาน</span></div>
                </div>
                <div class="row">
                    <div class="col-md-9"><span>ประเภทงาน</span></div>
                    <div class="col-md-27">
                        <%--<input class="form-control" id="workType" type="text" value="" readonly/>--%>
                        <select id="workType" class="selecte-box-custom" style="background-color: #eeeeee;" disabled>
                            <option value="" >ALL</option>
                            <option value="MOBILE SITE">MOBILE SITE</option>
                            <option value="FIXED SITE">FIXED SITE</option>
                            <option value="T">T</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-9"><span>ประหน่วยงาน</span></div>
                    <div class="col-md-27">
                        <%--<input class="form-control" id="workType" type="text" value="" readonly/>--%>
                        <select id="departmentType" class="selecte-box-custom" style="background-color: #eeeeee;" disabled>
                            <option value="" >ALL</option>
                            <option value="MOBILE SITE" selected>MOBILE SITE</option>
                            <option value="FIXED SITE">FIXED SITE</option>
                            <option value="T">T</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-9"><span>ประรถ</span></div>
                    <div class="col-md-27">
                        <%--<input class="form-control" id="workType" type="text" value="" readonly/>--%>
                        <select id="cartType" class="selecte-box-custom" style="background-color: #eeeeee;" disabled>
                            <option value="" >ALL</option>
                            <option value="MOBILE SITE">MOBILE SITE</option>
                            <option value="FIXED SITE" selected>FIXED SITE</option>
                            <option value="T">T</option>
                        </select>
                    </div>
                </div>
            </div>
            <div class="row border-box" style="margin-top:2px;">
                <div class="row" style="margin-bottom:4px;">
                    <div class="col-md-36" style="border-bottom:solid 1px #cccccc"><span>ช่วงเวลารับบริจาค</span></div>
                </div>
                <div class="row">
                    <div class="col-md-11"><span>เวลารับบริจาค</span></div>
                    <div class="col-md-7">
                        <input class="form-control required" id="donationTime" type="text" value="" />
                    </div>
                    <div class="col-md-11" style="padding-left: 32px;"><span>เวลาสิ้นสุดรับบริจาค</span></div>
                    <div class="col-md-7">
                        <input class="form-control required" id="donationTimeUse" type="text" value="" />
                    </div>
                </div>
            </div>
            <div class="row border-box" style="margin-top:2px;">
                <div class="row" style="margin-bottom:4px;">
                    <div class="col-md-36" style="border-bottom:solid 1px #cccccc; margin-bottom: 2px;"><span>แผนการดำเนินงาน</span></div>
                </div>
                <div class="row">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th class="col-md-18" style="border:1px solid #ddd; padding-left:2px;">หัวข้อแผนงาน</th>
                                <th class="col-md-9 text-center" style="border:1px solid #ddd;">จำนวนที่คาดหวัง</th>
                                <th class="col-md-9 text-center" style="border:1px solid #ddd;">จำนวนผู้บริจาค</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td>จำนวนผู้บริจารที่ลงทะเบียน</td>
                                <td><input class="form-control" id="regisDonateExpect" value="" readonly /></td>
                                <td><input class="form-control" id="regisDonateAmount" value="" readonly /></td>
                            </tr>
                            <tr>
                                <td>ผู้บริจาคที่สามารถบริจาคโลหิตได้</td>
                                <td><input class="form-control" id="canRegisDonateExpect" value="" readonly /></td>
                                <td><input class="form-control" id="canRegisDonateAmount" value="" readonly /></td>
                            </tr>
                            <tr>
                                <td>ผู้บริจาคที่ไม่สามารถบริจาคได้</td>
                                <td><input class="form-control" id="cantRegisDonateExpect" value="" readonly /></td>
                                <td><input class="form-control" id="cantRegisDonateAmount" value="" readonly /></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</asp:Content>
