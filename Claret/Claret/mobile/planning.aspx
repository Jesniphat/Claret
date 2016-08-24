<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="planning.aspx.vb" Inherits="Claret.planning" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .colour-pink {
            background-color: #FFF5F5;
        }
        .table > tbody > tr > td {
            padding: 7px 5px;
        }
        .border-top-left {
            border-top: solid 1px #ccc;
            border-left: solid 1px #ccc;
        }
        .out-padding-top-botton {
            padding-top: 0px;
            padding-bottom: 0px;
        }
        .border-lefts {
            border-left: solid 1px #ccc;
        }
    </style>
    <script src="../resources/javascript/page/planning.js" type="text/javascript"></script>
    <script>
        var subDepartmentList = [];
        var plan_edit_data = {};
        var plan_detail_edit_data = [];
        var plan_detail_list = [];
        var sumExpectRegisterAmount = 0;
        var sumRegisterAmount = 0;
        var sumExpectDonationAmount = 0;
        var sumDonationAmount = 0;
        var sumExpectCdonationAmount = 0;
        var sumCdonationAmount = 0;
        var hasPlanDetailList = [];
        var HaveDonation = false;
        $(function () {
            //$("#ui-datepicker-div").block();
            $("#donateDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                // maxDate: new Date(),
                //minDate: "-1d",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    // $("#txtHospital").focus();
                    //getDornorHospitalList(selectedDate);
                    //if ($("#data").attr("donateaction") == "edit") {
                    //    _clareFunction()
                    //}
                },
            });

            $("#txtStartRemarakDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                // maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    // $("#txtHospital").focus();
                    //getDornorHospitalList(selectedDate);
                },
            });

            $("#txtLastRemarakDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                // maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    // $("#txtHospital").focus();
                    //getDornorHospitalList(selectedDate);
                },
            });

            innitalchack();
            
            $("#txtDepartment").blur(function () { $("#ddlDepartment").val($("#txtDepartment").val().toUpperCase()).change(); });
            $("#txtRegion").blur(function () { $("#ddlRegion").val($("#txtRegion").val().toUpperCase()).change(); });

            //$("#addSubDepartmentBt").click()
            $.mask.definitions['2'] = '[012]';
            $.mask.definitions['3'] = '[0123456789]';
            $.mask.definitions['5'] = '[012345]';
            $.mask.definitions['9'] = '[0123456789]';
            $("#donationTime").mask("23:59");
            $("#donationTimeUse").mask("23:59");

            $("#save").click(savePlanning);

            //$("#donateDate").focus();

        });

        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>แผนการดำเนินงาน > ข้อมูลแผนการดำเนินงาน</span>
        </div>
    </div>
    <div class="row" id="firstRowDate" style="padding-right:2px;">
        <div class="border-box">
            <div class="col-md-20">
                <div class="col-md-7">
                    <span>วันที่รับบริจาค </span>
                </div>
                <div class="col-md-15">
                    <input class="form-control required" id="donateDate" type="text" value="" tabindex="1" />
                </div>
            </div>
            <div class="col-md-16">
                <div class="col-md-27"></div>
                <div class="col-md-3">
                    สถานะ
                </div>
                <div class="col-md-6">
                    <select id="planningStatus" class="selecte-box-custom required" tabindex="2">
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
                        <label class="checkbox-inline" style="padding-bottom: 2px;"><input id="masterPlan" type="checkbox" disabled />แผนงานต้นแบบ</label>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>ภาค</span></div>
                    <div class="col-md-5" style="text-align:right;padding-right: 0;">
                        <input id="txtRegion" type="text" class="form-control required" placeholder="ภาค" tabindex="3" />
                    </div>
                    <div class="col-md-17" style="padding-left: 5px;">
                        <select id="ddlRegion" class="required text-left" style="width:100%;" tabindex="4">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>รหัสหน่วย</span></div>
                    <div class="col-md-5" style="text-align:right;padding-right: 0;">
                        <input id="txtDepartment" type="text" class="form-control required" placeholder="หน่วยงาน" tabindex="5" />
                    </div>
                    <div class="col-md-17" style="padding-left: 5px;">
                        <select id="ddlDepartment" class="required text-left" style="width:100%;" tabindex="6">
                            <option value="0">Loading...</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>สถานที่ตั้ง</span></div>
                    <div class="col-md-12">
                        <input class="form-control" id="departmentLocation" type="text" value="" readonly disabled/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>ที่อยู่</span></div>
                    <div class="col-md-29">
                        <textarea class="form-control" id="departmentAddr" readonly disabled></textarea>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>แขวง/ตำบล</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentSubDistrict" type="text" value="" readonly disabled />
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>เขต/อำเภอ</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentDistrict" type="text" value="" readonly disabled />
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>จังหวัด</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentProvince" type="text" value="" readonly disabled />
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>รหัสไปรษณีย์</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentZipcode" type="text" value="" readonly disabled/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>ประเทศ</span></div>
                    <div class="col-md-11">
                        <%--<input class="form-control" id="departmentCountry" type="text" value="" readonly/>--%>
                        <select id="departmentCountry" class="selecte-box-custom" style="background-color: #eeeeee;" disabled>
                            
                        </select>
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
                        <input class="form-control" id="departmentMobile1" type="text" value="" readonly disabled/>
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>Email</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentEmail" type="text" value="" readonly disabled/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>เบอร์มือถือ 2</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentMobile2" type="text" value="" readonly disabled/>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-7"><span>เบอร์ที่ทำงาน</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentTel" type="text" value="" readonly disabled/>
                    </div>
                    <div class="col-md-7" style="padding-left: 32px;"><span>เบอร์ต่อ</span></div>
                    <div class="col-md-11">
                        <input class="form-control" id="departmentTelMore" type="text" value="" readonly disabled/>
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
                        <input class="form-control" id="workType" type="text" value="" readonly disabled/>
                        <%--<select id="workType" class="selecte-box-custom" style="background-color: #eeeeee;" disabled>
                            <option value="" >ALL</option>
                            <option value="MOBILE SITE">MOBILE SITE</option>
                            <option value="FIXED SITE">FIXED SITE</option>
                            <option value="T">T</option>
                        </select>--%>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-9"><span>ประหน่วยงาน</span></div>
                    <div class="col-md-27">
                        <%--<input class="form-control" id="workType" type="text" value="" readonly/>--%>
                        <select id="departmentType" class="selecte-box-custom" style="background-color: #eeeeee;" disabled>
                            <%--<option value="" >ALL</option>
                            <option value="MOBILE SITE" selected>MOBILE SITE</option>
                            <option value="FIXED SITE">FIXED SITE</option>
                            <option value="T">T</option>--%>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-9"><span>ประเภทรถ</span></div>
                    <div class="col-md-27">
                        <input class="form-control" id="carType" type="text" value="" readonly disabled />
                        <%--<select id="cartType" class="selecte-box-custom" style="background-color: #eeeeee;" disabled>
                            <option value="" >ALL</option>
                            <option value="MOBILE SITE">MOBILE SITE</option>
                            <option value="FIXED SITE" selected>FIXED SITE</option>
                            <option value="T">T</option>
                        </select>--%>
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
                        <input class="form-control required" id="donationTime" type="text" tabindex="7" />
                    </div>
                    <div class="col-md-11" style="padding-left: 32px;"><span>เวลาสิ้นสุดรับบริจาค</span></div>
                    <div class="col-md-7">
                        <input class="form-control required" id="donationTimeUse" type="text" tabindex="8" />
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
                                <td>จำนวนผู้บริจาคที่ลงทะเบียน</td>
                                <td><input class="form-control" id="sumRegisDonateExpect" value="0" readonly disabled /></td>
                                <td><input class="form-control" id="sumRegisDonateAmount" value="0" readonly disabled /></td>
                            </tr>
                            <tr>
                                <td>ผู้บริจาคที่สามารถบริจาคโลหิตได้</td>
                                <td><input class="form-control" id="sumCanRegisDonateExpect" value="0" readonly disabled /></td>
                                <td><input class="form-control" id="sumCanRegisDonateAmount" value="0" readonly disabled /></td>
                            </tr>
                            <tr>
                                <td>ผู้บริจาคที่ไม่สามารถบริจาคได้</td>
                                <td><input class="form-control" id="sumCantRegisDonateExpect" value="0" readonly disabled /></td>
                                <td><input class="form-control" id="sumCantRegisDonateAmount" value="0" readonly disabled /></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="row" id="tableLow" style="padding-right:2px;">
        <div class="border-box">
            <div class="row">
                <div class="col-md-36" style="border-bottom:1px solid #ccc">
                    <span>หน่วยงานย่อย</span>
                </div>
            </div>
            <div class="row" style="padding-top:2px; padding-bottom:0px; margin-right: 0px;">
                <div class="col-md-8 text-left border-top-left">
                    ชื่อหน่วยงานย่อย
                </div>
                <div class="col-md-8 text-center border-top-left">
                    จำนวนผู้บริจาคที่ลงทะเบียน
                </div>
                <div class="col-md-8 text-center border-top-left">
                    ผู้บริจาคที่สามารถบริจาคโลหิตได้
                </div>
                <div class="col-md-8 text-center border-top-left">
                    ผู้บริจาคที่ไม่สามารถบริจาคโลหิตได้
                </div>
                <div class="col-md-4 text-center border-top-left" style="border-right:solid 1px #ccc">
                    &nbsp;
                </div>
            </div>
            <div class="row out-padding-top-botton" style="margin-right: 0px;">
                <div class="col-md-8 border-top-left">&nbsp;</div>
                <div class="col-md-4 text-center border-top-left">จำนวนที่คาดหวัง</div>
                <div class="col-md-4 text-center border-top-left">ผู้บริจาค</div>
                <div class="col-md-4 text-center border-top-left">จำนวนที่คาดหวัง</div>
                <div class="col-md-4 text-center border-top-left">ผู้บริจาค</div>
                <div class="col-md-4 text-center border-top-left">จำนวนที่คาดหวัง</div>
                <div class="col-md-4 text-center border-top-left">ผู้บริจาค</div>
                <div class="col-md-4 text-center border-top-left" style="border-right:solid 1px #ccc">&nbsp;</div>
            </div>
            <div class="row out-padding-top-botton" style="margin-right: 0px;">
                <div class="col-md-8 border-top-left">
                    <%--<input class="form-control" id="subDepartmentName" type="text" value="" />--%>
                    <select id="subDepartmentName" style="width:100%;" tabindex="9">
                        <option value="" >Loading...</option>
                    </select>
                </div>
                <div class="col-md-4 text-center border-top-left" style="border-bottom:solid 1px #ccc"><input class="form-control" id="expectRegisterAmount" type="number" value="" tabindex="10" /></div>
                <div class="col-md-4 text-center border-top-left" style="border-bottom:solid 1px #ccc"><input class="form-control" id="registerAmount" type="number" value="" readonly disabled /></div>
                <div class="col-md-4 text-center border-top-left" style="border-bottom:solid 1px #ccc"><input class="form-control" id="expectDonationAmount" type="number" value="" tabindex="11" /></div>
                <div class="col-md-4 text-center border-top-left" style="border-bottom:solid 1px #ccc"><input class="form-control" id="donationAmount" type="number" value="" readonly disabled /></div>
                <div class="col-md-4 text-center border-top-left" style="border-bottom:solid 1px #ccc"><input class="form-control" id="expectCdonationAmount" type="number" value="" tabindex="12" /></div>
                <div class="col-md-4 text-center border-top-left" style="border-bottom:solid 1px #ccc"><input class="form-control" id="cDonationAmount" type="number" value="" readonly disabled /></div>
                <div class="col-md-4 text-center border-top-left" style="border-right:1px solid #ccc; border-bottom:solid 1px #ccc">
                    <button class='btn btn-icon' id="addSubDepartmentBt" subdepartmentid="0" subdepartmentcode="" onclick='addSubDepartment(this);' tabindex='13'>
                        <i class='glyphicon glyphicon-circle-arrow-down'></i>
                    </button>
                </div>
            </div>
            <div class="row" style="padding-bottom:10px; padding-top: 0px;">
                <table class="table table-striped" id="departMentListTable" style="border-bottom:1px solid #ccc">
                    <tbody>
                       <%-- <tr>
                            <td class="col-md-8">John</td>
                            <td class="col-md-4 text-center">Doe</td>
                            <td class="col-md-4 text-center">10</td>
                            <td class="col-md-4 text-center">10</td>
                            <td class="col-md-4 text-center">10</td>
                            <td class="col-md-4 text-center">10</td>
                            <td class="col-md-4 text-center">10</td>
                            <td class="col-md-4 text-center">
                                <button class='btn btn-icon' tabindex='1'>
                                    <i class="glyphicon glyphicon-remove"></i>
                                </button>
                            </td>
                        </tr>--%>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <div class="row" id="lastRow" style="padding-right:2px;">
        <div class="border-box">
            <div class="row">
                <div class="col-md-3"><span>วันที่เริ่มต้น</span></div>
                <div class="col-md-4"><input class="form-control" id="txtStartRemarakDate" type="text" value="" readonly disabled /></div>
                <div class="col-md-3"><span>วันที่สิ้นสุด</span></div>
                <div class="col-md-4"><input class="form-control" id="txtLastRemarakDate" type="text" value="" tabindex="14" /></div>
                <div class="col-md-3"><span>หมายเหตุ</span></div>
                <div class="col-md-15"><input class="form-control" id="txtRemark" type="text" value="" tabindex="15" /></div>
                <div class="col-md-4 text-center">
                    <%--<button class='btn btn-icon' onclick='' tabindex='16'>
                        <i class='glyphicon glyphicon-circle-arrow-down'></i>
                    </button>--%>
                </div>
            </div>
        </div>
    </div>
    <div class="row" id="buttonRow" style="padding-right:2px; margin-bottom:20px;">
        <div class="col-md-8">
            <input id="emport" type="button" class="btn btn-primary btn-block" value="คลิกที่นี่เพื่อนำเข้าข้อมูลจาก telecar" onclick="" />
        </div>
        <div class="col-md-20"> </div>
        <div class="col-md-4">
            <input id="cancel" type="button" class="btn btn-default btn-block" value="ยกเลิก" onclick="_clareFunction()" tabindex="17" />
        </div>
        <div class="col-md-4">
            <input id="save" type="button" class="btn btn-success btn-block" value="บันทึก" onclick="" tabindex="18" />
        </div>
    </div>
</asp:Content>
