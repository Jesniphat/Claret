<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="Collection.aspx.vb" Inherits="Claret.Collection" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../resources/css/donateStyle.css" rel="stylesheet" />
    <script src="../resources/javascript/page/donateScriptEdit.js" type="text/javascript"></script>
    <script>
        $(function () {
            
            checkParam()
            .then(getDonateTypeList)
            .then(getDonateBagTypeList)
            .then(getDonateApplyList)
            .then(getExamination)
            .then(getProblemReason)
            .then(getDonationList)
            .then(getStaffAutocomplete)
            .then(setKeyComplete)
            .then(setDefaultStaff)
            .done(getInitialData)
            .fail(function (err) {
            console.log(err);
            });
            //randerAddLabExamination();

            //$("#collectedProblem").selecter();
            //$("#collectedProblemReason1").setDropdownList();
            //$("#collectedProblemReason2").setDropdownList();

            $("#donateDate").text($("#data").attr("donatedate"));

            $("#addLabExamination").click(addLabExamination);
            
            // $("#startDonateDate").timepicker();
            $("#labExamination").autocomplete({
                source: examinationAutoData,
                minLength: 0
            }).focus(function () {
                $(this).autocomplete("search");
            });
            $("#collectedProblem").autocomplete({
                source: problemDataAuto,
                minLength: 0
            }).focus(function () {
                $(this).autocomplete("search");
            });
            $("#collectedProblemReason1").autocomplete({
                source: problemDataAuto,
                minLength: 0
            }).focus(function () {
                $(this).autocomplete("search");
            });
            $("#collectedProblemReason2").autocomplete({
                source: problemDataAuto,
                minLength: 0
            }).focus(function () {
                $(this).autocomplete("search");
            });
            $("#collectedProblemReason3").autocomplete({
                source: problemDataAuto,
                minLength: 0
            }).focus(function () {
                $(this).autocomplete("search");
            });
            $("#collectedProblemReason4").autocomplete({
                source: problemDataAuto,
                minLength: 0
            }).focus(function () {
                $(this).autocomplete("search");
            });
            $("#collectedProblem").blur(function () {
                setIdProblem("collectedProblem");
            });
            $("#collectedProblemReason1").blur(function () {
                setIdProblem("collectedProblemReason1");
            });
            $("#collectedProblemReason2").blur(function () {
                setIdProblem("collectedProblemReason2");
            });
            $("#collectedProblemReason3").blur(function () {
                setIdProblem("collectedProblemReason3");
            });
            $("#collectedProblemReason4").blur(function () {
                setIdProblem("collectedProblemReason4");
            });

            $("#donerNumber").blur(checkDonateNum);
            $("#sampleNumber").keydown(checkValidDonateNum);
            $("#sampleNumber").blur(checkSampleNumber);
            $("#btnSave").click(saveData);
            //$("#btnSave").click(saveDatatest);
            $("#btnCancel").click(clareData);

            $.mask.definitions['2'] = '[012]';
            $.mask.definitions['3'] = '[0123456789]';
            $.mask.definitions['5'] = '[012345]';
            $.mask.definitions['9'] = '[0123456789]';
            $("#startDonateDate").mask("23:59");
            $("#donateTimes").mask("23:59:59");

            //$("#testx").click(function () {
            //    hl7Generator('41', '93', '9995900007', '123456789')
            //})
        });
        
    </script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="cphMaster" runat="server">
    <div class="claret-page-header row">
        <div>
            <span>เจาะเก็บ</span>
        </div>
    </div>
    <div class="row">
        <div class="col-md-36">
            <div class="border-box">
                <div class="col-md-4 text-left">เลขประจำตัวผู้บริจาค</div>
                <div class="col-md-7">
                    <input class="col-md-36 form-control required" id="donerNumber" type="text" value="" tabindex="1"/>
                </div>
                <div class="col-md-3 text-left" id="testx" style="padding-left:18px;">Sample No</div>
                <div class="col-md-7">
                    <input class="col-md-36 form-control required" id="sampleNumber" type="text" value="" tabindex="2" />
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-17">
            <div class="border-box">
                <div class="row">
                    <div class="col-md-8 text-left">ประเภทการบริจาค</div>
                    <div class="col-md-14" style="padding-left:9px; max-width:232px; width:100%;">
                        <select id="donateType" class="required selecte-box-custom" tabindex="3">
                            
                        </select>
                    </div>
                    <div class="col-md-8 text-left" style="float:left;">&nbsp;</div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">ประเภทถุง</div>
                    <div class="col-md-14" style="padding-left:9px; max-width:232px; width:100%;">
                        <select id="donateBagType" class="required selecte-box-custom" tabindex="4">
                            
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">ประเภทการใช้งาน</div>
                    <div class="col-md-14" style="padding-left:9px; max-width:232px; width:100%;">
                        <select id="donateApply" class="required selecte-box-custom" tabindex="5">
                            
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-19">
            <div class="border-box">
                <div class="row">
                    <div class="col-md-8 text-left">Prescribed Volumn</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control" id="prescribedVol" type="text" value="" readonly/></div>
                    <div class="col-md-8 text-left">Volumn</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control required" id="vol" type="text" value="" tabindex="6" /></div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">เวลาที่เริ่มบริจาค</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control required" id="startDonateDate" type="text" value="" tabindex="7" /></div>
                    <div class="col-md-8 text-left">ระยะเวลาที่บริจาค</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control required" id="donateTimes" type="text" value="" tabindex="8"/></div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">ผู้เจาะเก็บ</div>
                    <div class="col-md-15 text-left"><input class="col-md-15 form-control required" id="donateStaff" staffid="0" type="text" value="" tabindex="9"/></div>
                </div>
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-17">
            <div class="border-box">
                <div class="row">
                    <div class="col-md-36">LAB EXAMINATION</div>
                </div>
                <div class="row">
                    <table class="table table-bordered" style="margin-bottom:5px;">
                        <tbody>
                            <tr>
                                <td class="col-md-34"><input class="form-control" id="labExamination" style="border:none;" value="" tabindex="10" /></td>
                                <td class="col-md-1" style="border:1px solid #ffffff;">
                                    <button id="addLabExamination" class="btn btn-icon" onclick="return false;" tabindex="11">
                                        <i class="glyphicon glyphicon-circle-arrow-down"></i>
                                    </button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                <div class="row">
                    <table class="table table-bordered table-striped" id="labExaminationListTable">
                        <tbody>

                        </tbody>
                    </table>
                </div>
            </div>
        </div>
        <div class="col-md-19">
            <div class="border-box">
                <div class="row">
                    <div class="col-md-34" style="padding-left: 6px;">ปัญหาในหารเจาะเก็บ</div>
                    <%--<div class="col-md-11" style="padding-left: 8px;">สาเหตุ 1</div>
                    <div class="col-md-11" style="padding-left: 10px;">สาเหตุ 2</div>--%>
                </div>
                <div class="row">
                    <table class="table table-bordered" style="margin-bottom:5px;">
                        <tbody>
                            <tr>
                                <td class="col-md-34" style="border:1px solid #ffffff; padding: 0px;">
                                    <%--<select id="collectedProblem">
                                        <option value="0">ทดสอบ...</option>
                                        <option value="1">ทดสอบ2...</option>
                                    </select>--%>
                                    <input class="form-control" id="collectedProblem" value="" tabindex="12" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="row">
                    <div class="col-md-17" style="padding-left: 8px;">สาเหตุ 1</div>
                    <div class="col-md-17" style="padding-left: 20px;">สาเหตุ 2</div>
                </div>
                <div class="row">
                    <table class="table table-bordered" style="margin-bottom:5px;">
                        <tbody>
                            <tr>
                                <td class="col-md-17" style="border:1px solid #ffffff; padding: 0px;">
                                    <input class="form-control" id="collectedProblemReason1" value="" tabindex="13" />
                                </td>
                                <td class="col-md-17" style="border:1px solid #ffffff; padding: 0px;">
                                    <input class="form-control" id="collectedProblemReason2" value="" tabindex="14" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
                <div class="row">
                    <div class="col-md-17" style="padding-left: 8px;">สาเหตุ 3</div>
                    <div class="col-md-17" style="padding-left: 20px;">สาเหตุ 4</div>
                </div>
                <div class="row">
                    <table class="table table-bordered" style="margin-bottom:5px;">
                        <tbody>
                            <tr>
                                <td class="col-md-17" style="border:1px solid #ffffff; padding: 0px;">
                                    <input class="form-control" id="collectedProblemReason3" value="" tabindex="13" />
                                </td>
                                <td class="col-md-17" style="border:1px solid #ffffff; padding: 0px;">
                                    <input class="form-control" id="collectedProblemReason4" value="" tabindex="14" />
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>

                 <div class="row">
                    <table class="table table-bordered table-striped" id="collectedProblemListTable">
                        <tbody>

                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    <div class="row" style="margin-top:10px;">
        <div class="col-md-36">
            <div class="col-md-30">&nbsp;</div>
            <div class="col-md-3"><input id="btnCancel" type="button" class="btn btn-block" value="ยกเลิก" tabindex="15" /></div>
            <div class="col-md-3"><input id="btnSave" type="button" class="btn btn-success btn-block" value="บันทึก" tabindex="16" /></div>
        </div>
    </div>
    <div class="row" style="margin-top:20px;">
        <div class="col-md-36" style="padding-left:0px;">
            <div class="tableHeadDivFullDark" id="headTimeDiv">
                <b>รายการ วันที่ <span id="donateDate"></span> เจาะเก็บที่ ห้องเจาะเก็บชั้น 2<%-- - รวมเจาะเก็บ <span id="sampleCount">Sample</span>--%></b>
            </div>
        </div>
        <div class="col-md-36">
            <table class="table table-bordered-excel tablesorter" id="donate-table">
                <thead style="color:gray">
                <%--<thead style="color:#a2a2a2">--%>
                    <tr>
                        <th class="col-md-5">Sample No</th>
                        <th class="col-md-5">รหัสผู้บริจาค</th>
                        <th class="col-md-5">ประเภทการบริจาค</th>
                        <th class="col-md-5">ประเภทถุง</th>
                        <th class="col-md-5">ประเภทการใช้งาน</th>
                        <th class="col-md-3">Volumn</th>
                        <th class="col-md-3">เวลา</th>
                        <th class="col-md-3">ระยะเวลา</th>
                        <th class="col-md-2">Action</th>
                    </tr>
                </thead>
                <tbody>
                    
                </tbody>
            </table>
        </div>
    </div>
    
</asp:Content>
