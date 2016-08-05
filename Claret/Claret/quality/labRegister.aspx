<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="labRegister.aspx.vb" Inherits="Claret.labRegister" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        #tbExam > tbody > tr > td:last-child {
            border-top-color: transparent;
            border-right-color: transparent;
            border-bottom-color: transparent;
            background-color: white;
        }

        .setBorderTable {
            border:1px solid #ddd;
        }
    </style>
    <script type="text/javascript">
        var departmentData;
        $(function () {
            $("#txtDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtHospital").focus();
                },
            });

            $("#ddlHospital").setDropdownListValue({ url: '../ajaxAction/masterAction.aspx', data: { action: 'hospital' } }).on("change", function () {
                $("#txtHospital").H2GValue($("#ddlHospital").H2GValue());

                if ($("#txtHospital").H2GValue() == "") {
                    $("#ddlDepartment").val("").change().H2GDisable();
                    $("#txtDepartment").H2GDisable().H2GValue('').focus();
                } else {
                    var dataObj = [];
                    var dataAll = $("#ddlDepartment").data("data-ddl");
                    var create = 0;
                    if (dataAll != undefined) {
                        $.each((dataAll), function (index, e) {
                            if ($("#ddlHospital option:selected").H2GAttr("departmentID").indexOf("," + e.valueID + ",") > -1) {
                                dataObj[create] = e;
                                create++;
                            }
                        });
                    }
                    $("#ddlDepartment").setDropdownListValue({ dataObject: dataObj, enable: true });
                    $("#txtDepartment").H2GEnable().H2GValue('').focus();
                }
            });

            $("#ddlReason").setDropdownListValue({ url: '../ajaxAction/masterAction.aspx', data: { action: 'reason' } }).on("change", function () {
                $("#txtLab").focus();
            });
            $("#ddlDonationTo").setDropdownListValue({ url: '../ajaxAction/masterAction.aspx', data: { action: 'donationto' } }).on("change", function () {
                $("#txtExamCode").focus();
            });

            $("#ddlLab").setDropdownListValue({ url: '../ajaxAction/masterAction.aspx', data: { action: 'lab' } }).on("change", function () {
                $("#txtLab").H2GValue($("#ddlLab").H2GValue());
                $("#ddlDonationTo").closest("div").focus();
            });
            $("#txtHospital").enterKey(function () { $("#ddlHospital").val($("#txtHospital").val().toUpperCase()).change(); });
            $("#txtDepartment").enterKey(function () { $("#ddlDepartment").val($("#txtDepartment").val().toUpperCase()).change(); });
            $("#txtLab").enterKey(function () { $("#ddlLab").val($("#txtLab").val().toUpperCase()).change(); });

            $("#ddlExam").setAutoListValue({
                url: '../ajaxAction/masterAction.aspx', data: { action: 'examination' },
                selectItem: function () {
                    $("#txtExamCode").H2GValue($("#ddlExam").H2GValue());
                    getExamination();
                },
            });

            $("#ddlStaff").setAutoListValue({
                url: '../ajaxAction/masterAction.aspx', data: { action: 'staff' }
            });

            $("#txtExamCode").enterKey(function () { getExamination(); });
            
            $("#txtDepartment").H2GDisable();
            $("#ddlDepartment").setDropdownListValue({
                url: '../ajaxAction/masterAction.aspx',
                data: { action: 'department' },
                tempData: true,
                enable: false,
            }).on("change", function () {
                $("#txtDepartment").H2GValue($("#ddlDepartment").H2GValue());
                $("#ddlStaff").closest("div").find("input").focus();
            });
            $.extend($.fn, {
                deleteExam: function (args) {
                    if (confirm("ต้องการจะลบ " + $(this).closest("tr").find(".td-exam").html() + " ใช่หรือไม่?")) {
                        $(this).closest("tr").remove();
                    }
                },
                setDropDownArray: function(setting) {
                    var self = this;
                    var config = {
                        data: {},
                    };
                    $.extend(config, setting);

                    $(self).html('');//.selecter('destroy').setDropdownList();
                    $("<option>", { value: "" }).html("กรุณาเลือก").appendTo(self);
                    if (config.data.length>0) {
                        $.each((config.data), function (index, e) {
                            $("<option>", { value: e.code, valueID: e.id }).html(e.name).appendTo(self);
                        });
                        $(self).setDropdownList().selecter("update");
                        if (defaultSelect != undefined) { $(self).val(defaultSelect).change(); }
                    } else { $(self).setDropdownList().selecter("update"); }
                },
                regisHospital: function () {
                    if (validation()) {
                        $("#btnNewRegis").prop("disabled", true);
                        var ReceiptHospital = {
                            ID:'',
                            RegisterStaff: $("#ddlStaff option:selected").H2GAttr("valueID"),
                            RegisterDate: $("#txtDate").H2GValue(),
                            DonationToID: $("#ddlDonationTo option:selected").H2GAttr("valueID"),
                            HospitalID: $("#ddlHospital option:selected").H2GAttr("valueID"),
                            DepartmentID: $("#ddlDepartment option:selected").H2GAttr("valueID"),
                            LabID: $("#ddlLab option:selected").H2GAttr("valueID"),
                            ReasonID: $("#ddlReason option:selected").H2GAttr("valueID"),
                        };

                        var ReceiptDetail = [];
                        var count = 0;
                        $("#tbExam > tbody > tr.template-data").each(function (i, e) {
                            ReceiptDetail[count] = {
                                ID: 'NEW',
                                ExaminationGroupID: $(e).H2GAttr("groupID"),
                                ExaminationGroupCode: $(e).H2GAttr("groupCode"),
                                ExaminationGroupDesc: $(e).H2GAttr("groupDesc"),
                                ExaminationID: $(e).H2GAttr("refID"),
                                ExaminationCode: $(e).H2GAttr("examCode"),
                                ExaminationDesc: $(e).H2GAttr("desc"),
                            };
                            count++;
                        });
                        $.ajax({
                            url: '../../ajaxAction/qualityAction.aspx',
                            data: H2G.ajaxData({
                                action: 'savereceipthospital',
                                rh: JSON.stringify(ReceiptHospital),
                                rhd: JSON.stringify(ReceiptDetail),
                            }).config,
                            type: "POST",
                            dataType: "json",
                            error: function (xhr, s, err) {
                                console.log(s, err);
                                notiError("ลงทะเบียนไม่สำเร็จ");
                                $("#btnNewRegis").prop("disabled", false);
                            },
                            success: function (data) {
                                if (!data.onError) {
                                    data.getItems = jQuery.parseJSON(data.getItems);
                                    notiSuccess("ลงทะเบียนเรียบร้อย");
                                    $("#data").H2GFill({ receiptHospitalID: data.getItems.ID });
                                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "../donor/search.aspx", method: "post", staffaction: "labregister" }).submit();
                                } else { notiError("ลงทะเบียนไม่สำเร็จ"); }
                                $("#btnNewRegis").prop("disabled", false);
                            }
                        });    //End ajax

                    }
                },
            });


            $("#dateList").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                // maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    // $("#txtHospital").focus();
                    getDornorHospitalList(selectedDate);
                },
            });
            
            var hospitalListDate = $("#dateList").val();
            getDornorHospitalList(hospitalListDate);
        });

        function getExamination() {
            if ($("#txtExamCode").H2GValue() != "") {
                var dataView = $("#tbExam > tbody");
                $(dataView).closest("table").H2GAttr("wStatus", "working");
                $.ajax({
                    url: "../ajaxAction/qualityAction.aspx",
                    data: H2G.ajaxData({ 
                        action: 'getexamination',
                        excode: $("#txtExamCode").H2GValue(),
                    }).config,
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                        $(dataView).closest("table").H2GAttr("wStatus", "error");
                    },
                    success: function (data) {
                        var notiReject = "";
                        var notiInject = "";
                        if (!data.onError) {
                            data.getItems = jQuery.parseJSON(data.getItems);
                            $.each((data.getItems), function (index, e) {
                                if ($("#tbExam > tbody > tr.template-data[examCode='" + e.Code + "']").length > 0) {
                                    // 1 ถ้า exam ที่เพิ่มเข้ามาซ้ำ และไม่มีกลุ่มจะไม่เพิ่มและแจ้งซ้ำ
                                    if (e.GroupID == null) {
                                        notiReject += e.Code + ", ";
                                    } else {
                                        // 2 ถ้า exam ที่เพิ่มเข้ามาซ้ำ แต่มีกลุ่มจะเพิ่มให้และลบตัวเก่าเสมอ
                                        notiInject += e.Code + ", ";
                                        $("#tbExam > tbody > tr.template-data[examCode='" + e.Code + "']").remove();
                                        var dataRow = $("#tbExam > thead > tr.template-data").clone().show();
                                        $(dataRow).H2GFill({ refID: e.ID, examCode: e.Code, desc: e.Description, groupID: e.GroupID, groupCode: e.GroupCode, groupDesc: e.GroupDescription });
                                        $(dataRow).find('.td-exam').append(e.Code + ' : ' + e.Description).H2GAttr("title", e.Code + ' : ' + e.Description);
                                        $(dataView).append(dataRow);
                                    }
                                } else {
                                    var dataRow = $("#tbExam > thead > tr.template-data").clone().show();
                                    $(dataRow).H2GFill({ refID: e.ID, examCode: e.Code, desc: e.Description, groupID: e.GroupID, groupCode: e.GroupCode, groupDesc: e.GroupDescription });
                                    $(dataRow).find('.td-exam').append(e.Code + ' : ' + e.Description).H2GAttr("title", e.Code + ' : ' + e.Description);
                                    $(dataView).append(dataRow);
                                }
                            });

                            $("#txtExamCode").H2GValue("");
                            $("#ddlExam").closest("div").find("input").val("");
                            if (notiReject != "") { notiWarning(notiReject.substring(0, notiReject.length - 2) + " มีการเพิ่มไปแล้ว") }
                            if (notiInject != "") { notiWarning(notiInject.substring(0, notiInject.length - 2) + " ถูกแทนที่ด้วยกลุ่ม " + data.getItems[0].GroupCode) }
                        } else {
                            $("#txtExamCode").focus();
                            notiError(data.exMessage);
                        }
                        $(dataView).closest("table").H2GAttr("wStatus", "done");
                    }
                });    //End ajax
            } else {
                $("#txtExamCode").focus();
                notiWarning("กรุณากรอกหรือเลือก Examination");
            }
        }
        function validation() {
            if ($('#txtDate').val() == "") {
                $("#txtDate").focus();
                notiWarning("กรุณาวันที่ส่งตรวจ");
                return false;
            } else if ($('#ddlHospital').H2GValue() == "") {
                $("#txtHospital").focus();
                notiWarning("กรุณากรอกโรงพยาบาล/ภาคบริการโลหิต");
                return false;
            } else if ($('#ddlDepartment').H2GValue() == "") {
                $("#txtDepartment").focus();
                notiWarning("กรุณากรอกแผนก");
                return false;
            } else if (!$('#ddlStaff').H2GValue() || $('#ddlStaff').H2GValue() == "") {
                $("#ddlStaff").closest("div").find("input").focus();
                notiWarning("กรุณากรอกชื่อเจ้าหน้าที่ผู้ขอตรวจ");
                return false;
            } else if ($('#ddlReason').H2GValue() == "") {
                $("#ddReason").closest("div").focus();
                notiWarning("กรุณากรอกสาเหตุการขอตรวจ");
                return false;
            } else if ($('#ddlLab').H2GValue() == "") {
                $("#txtLab").focus();
                notiWarning("กรุณากรอก LAB EXAMINATION");
                return false;
            } else if ($('#ddlDonationTo').H2GValue() == "") {
                $("#ddlDonationTo").closest("div").focus();
                notiWarning("กรุณากรอกประเภทการบริจาค");
                return false;
            }
            return true;
        }

        function getDornorHospitalList(hospitalListDate) {
            // console.log("hospitalListDate = ", hospitalListDate);
            $.ajax({
                url: "../ajaxAction/qualityAction.aspx",
                data: H2G.ajaxData({
                    action: 'getDornorHospitalList',
                    whereDate: hospitalListDate,
                }).config,
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    if (!data.onError) {
                        $("tr").remove(".hospitalListCol");
                        data.getItems = jQuery.parseJSON(data.getItems);
                        var dataRow = data.getItems;
                        for (var i = 0; i < dataRow.length; i++) {
                            var rows = "<tr class='hospitalListCol'>" +
                                            "<td class='text-right'>" + (i + 1) + "</td>" +
                                            "<td>" + dataRow[i].name + "</td>" +
                                            "<td>" + dataRow[i].donor_amount + "</td>" +
                                            "<td>" + dataRow[i].regis_time + "</td>" +
                                            "<td>" + dataRow[i].staff + "</td>" +
                                            "<td class='text-center'>" +
                                                "<button class='btn btn-icon' onclick='gotoSearch(" + dataRow[i].id + ");' tabindex='1'>" +
                                                    "<i class='glyphicon glyphicon-circle-arrow-right'></i>" +
                                                "</button>" +
                                            "</td>" +
                                        "</tr>";
                            $('#hospitalList > tbody').append(rows);
                        }
                        
                    } else {
                        
                    }
                }
            });
        }

        function gotoSearch(id) {
            //console.log(id);
            $("#data").H2GFill({ receiptHospitalID: id});
            $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "../donor/search.aspx", method: "post", staffaction: "labregister" }).submit();
        }
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
            <div class="col-md-36">
                <span>1. กำหนดค่าเริ่มต้นของโรงพยาบาลที่จะส่งตรวจ</span>
            </div>
        </div>
        <div class="row">
            <div class="col-md-18">
                <div class="border-box" style="height:280px;">
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
                                <option value="0">กรุณาเลือก</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">ชื่อเจ้าหน้าที่ผู้ขอตรวจ</div>
                        <div class="col-md-22">
                            <select id="ddlStaff" class="required text-left" style="width:100%;">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-12 col-md-offset-1">สาเหตุการขอ</div>
                        <div class="col-md-22">
                            <select id="ddlReason" class="required text-left" style="width:100%;">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
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
                        <div class="col-md-22">
                            <select id="ddlDonationTo" class="required text-left" style="width:100%;">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
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
                        <div class="col-md-24">
                            <select id="ddlExam" class="text-left" placeholder="" style="width:388px;" tabindex="-1">
                                <option value="0">Loading...</option>
                            </select>
                        </div>
                    </div>
                    <div class="row">
                        <div class="col-md-35 col-md-offset-1" style="height: 204px; overflow-y: scroll;">
                            <table id="tbExam" class="table table-bordered table-striped" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
                                <thead>
                                    <tr class="no-transaction" style="display:none;"><td class="col-md-34" align="center">ไม่มีข้อมูล</td><td class="col-md-2"></td></tr>
                                    <tr class="more-loading" style="display:none;"><td class="col-md-34" align="center">Loading detail...</td><td class="col-md-2"></td></tr>
                                    <tr class="template-data" style="display:none;" refID="NEW">
                                        <td class="col-md-34 td-exam">
                                        </td>
                                        <td class="col-md-2">
                                            <div class="text-center">
                                                <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" onclick="return $(this).deleteExam();"></span></a>
                                            </div>
                                        </td>
                                    </tr>
                                </thead>
                                <tbody>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <div id="post-content-two" style="padding-left:15px;padding-bottom: 20px;">
        <div class="row">
            <div class="col-md-36">
                <span>2. กดปุ่มเพื่อเริ่มลงทะเบียน</span>
                <input id="btnNewRegis" type="button" class="btn btn-success" targetUrl="hospitalRegister.aspx" value="ลงทะเบียน" onclick="return $(this).regisHospital();" />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>รายการที่บันทึกไปแล้ว</span>
        </div>
    </div>
    <div class="row">
        <div class="col-md-36">
            <div style="background-color: #CCCCCC; height: 2px;"></div>
        </div>
    </div>
    <div class="row" style="margin-top:5px;">
        <div class="col-md-36" style="text-align:center;">
            รายการวันที่ <input type="text" id="dateList" value="" class="form-control required text-center" style="width:143px; display:inline;" />
        </div>
    </div>
    <div class="row" style="margin-top:5px;">
        <div class="col-md-36">
            <table class="table table-bordered" id="hospitalList">
                <thead class="table table-bordered">
                    <tr>
                        <th class="col-md-2 text-center" style="border:1px solid #ddd; padding:0px 5px 0px 5px";>ลำดับ</th>
                        <th class="col-md-17" style="border:1px solid #ddd; padding:0px 5px 0px 5px";">รายการโรงพยาบาล</th>
                        <th class="col-md-5" style="border:1px solid #ddd; padding:0px 5px 0px 5px";">จำนวนผู้บริจาค</th>
                        <th class="col-md-5" style="border:1px solid #ddd; padding:0px 5px 0px 5px";">เวลา</th>
                        <th class="col-md-5" style="border:1px solid #ddd; padding:0px 5px 0px 5px";">ผู้บันทึกข้อมูล</th>
                        <th class="col-md-2 text-center" style="border:1px solid #ddd; padding:0px 5px 0px 5px";"></th>
                    </tr>
                </thead>
                <tbody>
                    
                </tbody>
            </table>
        </div>
    </div>
</asp:Content>
