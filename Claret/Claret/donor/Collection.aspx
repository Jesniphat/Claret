<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="Collection.aspx.vb" Inherits="Claret.Collection" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../resources/css/donateStyle.css" rel="stylesheet" />
    <script src="../resources/javascript/donateScriptEdit.js" type="text/javascript"></script>
    <script>
        $(function () {
            var x = $("#data").attr("donateAction");
            console.log("x : ", x)

            $("#donateType").setDropdowList();
            $("#bagType").setDropdowList();
            $("#useType").setDropdowList();
            $("#collectedProblem").setDropdowList();
            $("#collectedProblemReason1").setDropdowList();
            $("#collectedProblemReason2").setDropdowList();

            $("#addLabExamination").click(addLabExamination);
            
            randerAddLabExamination();
            randerAddCollectedProblem();
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
                    <input class="col-md-36 form-control required" id="donerNumber" type="text" value=""/>
                </div>
                <div class="col-md-3 text-left" style="padding-left:18px;">Sample No</div>
                <div class="col-md-7">
                    <input class="col-md-36 form-control required" id="sampleNumber" type="text" value=""/>
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
                        <select id="donateType" class="required">
                            <option value="0">ทดสอบ...</option>
                            <option value="1">ทดสอบ2...</option>
                        </select>
                    </div>
                    <div class="col-md-8 text-left" style="float:left;">&nbsp;</div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">ประเภทถุง</div>
                    <div class="col-md-14" style="padding-left:9px; max-width:232px; width:100%;">
                        <select id="bagType" class="required">
                            <option value="0">ทดสอบ...</option>
                            <option value="1">ทดสอบ2...</option>
                        </select>
                    </div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">ประเภทการใช้งาน</div>
                    <div class="col-md-14" style="padding-left:9px; max-width:232px; width:100%;">
                        <select id="useType" class="required">
                            <option value="0">ทดสอบ...</option>
                            <option value="1">ทดสอบ2...</option>
                        </select>
                    </div>
                </div>
            </div>
        </div>
        <div class="col-md-19">
            <div class="border-box">
                <div class="row">
                    <div class="col-md-8 text-left">Prescribed Volumn</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control" id="prescribedVol" type="text" value=""/></div>
                    <div class="col-md-8 text-left">Volumn</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control required" id="vol" type="text" value=""/></div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">วันที่เริ่มบริจาค</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control required" id="startDonateDate" type="text" value=""/></div>
                    <div class="col-md-8 text-left">ระยะเวลาที่บริจาค</div>
                    <div class="col-md-9 text-left"><input class="col-md-9 form-control required" id="donateTimes" type="text" value=""/></div>
                </div>
                <div class="row">
                    <div class="col-md-8 text-left">ผู้เจาะเก็บ</div>
                    <div class="col-md-15 text-left"><input class="col-md-15 form-control required" id="donateStaff" type="text" value=""/></div>
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
                                <td class="col-md-34"><input class="form-control" id="labExamination" style="border:none;" value="" /></td>
                                <td class="col-md-1" style="border:1px solid #ffffff;">
                                    <button id="addLabExamination" class="btn btn-icon" onclick="return false;" tabindex="1">
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
                    <div class="col-md-11" style="padding-left: 6px;">ปัญหาในหารเจาะเก็บ</div>
                    <div class="col-md-11" style="padding-left: 8px;">สาเหตุ 1</div>
                    <div class="col-md-11" style="padding-left: 10px;">สาเหตุ 2</div>
                </div>
                <div class="row">
                    <table class="table table-bordered" style="margin-bottom:5px;">
                        <tbody>
                            <tr>
                                <td class="col-md-11" style="border:1px solid #ffffff; padding: 0px;">
                                    <select id="collectedProblem">
                                        <option value="0">ทดสอบ...</option>
                                        <option value="1">ทดสอบ2...</option>
                                    </select>
                                </td>
                                <td class="col-md-11" style="border:1px solid #ffffff; padding: 0px;">
                                    <select id="collectedProblemReason1">
                                        <option value="0">ทดสอบ...</option>
                                        <option value="1">ทดสอบ2...</option>
                                    </select>
                                </td>
                                <td class="col-md-11" style="border:1px solid #ffffff; padding: 0px;">
                                    <select id="collectedProblemReason2">
                                        <option value="0">ทดสอบ...</option>
                                        <option value="1">ทดสอบ2...</option>
                                    </select>
                                </td>
                                <td class="col-md-1" style="border:1px solid #ffffff;">
                                    <button id="addCollectedProblem" class="btn btn-icon" onclick="return false;" tabindex="1">
                                        <i class="glyphicon glyphicon-circle-arrow-down"></i>
                                    </button>
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
    <div class="row">
        <div class="col-md-36">
            <div class="col-md-30">&nbsp;</div>
            <div class="col-md-3"><input id="btnCancel" type="button" class="btn btn-block" value="ยกเลิก" tabindex="-1" /></div>
            <div class="col-md-3"><input id="btnSave" type="button" class="btn btn-success btn-block" value="บันทึก" tabindex="1" /></div>
        </div>
    </div>
    
</asp:Content>
