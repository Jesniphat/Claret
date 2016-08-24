<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="search.aspx.vb" Inherits="Claret.donor_search" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <script>
        $(function () {
            //$("#spQueueHeader").H2GValue("คิวประจำวันที่ " + formatDate(H2G.today(), " dd MMM พ.ศ. yyyy")).H2GAttr("reportDate", formatDate(H2G.today(), "dd/MM/yyyy"));
            $("#spQueueHeader").H2GValue("คิวประจำวันที่ " + formatDate(new Date(getDateFromFormat($("#data").H2GAttr("plan_date"), "dd/mm/yyyy")), " dd MMM พ.ศ. yyyy"));
            if (!($("#data").H2GAttr("receiptHospitalID") == undefined || $("#data").H2GAttr("receiptHospitalID") == "")) { $("#spQueueHeader").hide(); }
            $("#searchTab").tabs({
                active: 0,
                activate: function (event, ui) {
                    $(ui.newPanel).find("input:not(input[type=button],input[type=submit],button):visible:first").focus();
                },
            });
            $("#txtBirthday").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtBloodGroup").focus();
                },
                onClose: function () {
                    enterDatePickerSearch($("#txtBirthday"),"close");
                },
                onEnterKey: function () {
                    enterDatePickerSearch($("#txtBirthday"), "enter");
                },
            });
            $("#txtPostBirthday").H2GDatebox().setCalendar({
                maxDate: new Date(),
                minDate: "-100y",
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) {
                    $("#txtBloodGroup").focus();
                },
            });
            //$("#txtName").H2GNamebox(37);
            //$("#txtSurname").H2GNamebox(37);
            $("#divCriteria input").enterKey(function () {
                donorSearch(true);
                return false;
            });
            $("#divPostCriteria input").enterKey(function () {
                postQueueSearch(true);
                return false;
            });
            $("#spSearch").click(function () {
                donorSearch(true);
            });
            $("#spClear").click(function () {
                $("#divCriteria input").H2GValue('');
                $("#txtDonorNumber").focus();
                $("#tbDonor > tbody").H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                $("#tbDonor > tbody").closest("table").attr("totalPage", 0)
                genGridPage($("#tbDonor"), donorSearch);
            });
            $("#btnNewRegis").click(function () {
                if ($('#txtName').H2GValue() == "") {
                    $("#txtName").focus();
                    notiWarning("กรุณากรอกชื่อผู้บริจาค");
                    return false;
                } else if ($('#txtSurname').H2GValue() == "") {
                    $("#txtSurname").focus();
                    notiWarning("กรุณากรอกนามสกุลผู้บริจาค");
                    return false;
                } else if ($('#txtBirthday').H2GValue() == "" || !isDate($('#txtBirthday').H2GValue(), "dd/MM/yyyy")) {
                    $("#txtBirthday").focus();
                    notiWarning("กรุณากรอกวันเกิดผู้บริจาค");
                    return false;
                }
                validation($('#txtName').H2GValue(), $('#txtSurname').H2GValue(), $('#txtBirthday').H2GValue(), "", true);
            });
            $("#spPostSearch").click(function () {
                postQueueSearch(true);
            });
            $("#spPostClear").click(function () {
                $("#divPostCriteria input").H2GValue('');
                $("#txtPostQueue").focus();
                postQueueSearch(true);
            });
            $.extend($.fn, {
                donorSelect: function () {
                    validation("", "", $(this).closest("tr").H2GAttr("birthday"), $(this).closest("tr").H2GAttr("refID"));
                },
                queueSelect: function () {
                    $("#data").H2GFill({ donorID: $(this).closest("tr").H2GAttr("donorID"), visitID: $(this).closest("tr").H2GAttr("refID")});
                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                },
                backToLabRegis: function () {
                    $("#data").H2GRemoveAttr("receiptHospitalID");
                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "../quality/labRegister.aspx", method: "post" }).submit();
                },
            });

            $("#tbDonor thead button").click(function () { sortButton($(this), donorSearch); return false; });
            $("#tbPostQueue thead button").click(function () { sortButton($(this), postQueueSearch); return false; });
            $("#txtDonorNumber").focus();
            if ($("#data").H2GAttr("receiptHospitalID")) {
                $.ajax({
                    url: '../../ajaxAction/qualityAction.aspx',
                    data: {
                        action: 'getreceipthospital'
                        , receipthospitalid: $("#data").H2GAttr("receiptHospitalID")
                        , issearch: "Y"
                    },
                    type: "POST",
                    dataType: "json",
                    error: function (xhr, s, err) {
                        console.log(s, err);
                    },
                    success: function (data) {
                        if (!data.onError) {
                            data.getItems = jQuery.parseJSON(data.getItems);
                            $("#divReceiptHospital").show();
                            $("#spReceiptHospital").H2GValue(data.getItems.HospitalName + " รายการที่ " + data.getItems.QueueCount + "/" + data.getItems.QueueTotal);
                            $("#spQueueHeader").H2GValue("คิวประจำวันที่ " + formatDate(new Date(getDateFromFormat(data.getItems.CreateDate, "dd/MM/yyyy")), " dd MMM พ.ศ. yyyy")).H2GAttr("reportDate", data.getItems.CreateDate);

                            postQueueSearch(true);
                        }
                    }
                });    //End ajax
            } else {
                postQueueSearch(true);
            }
            
        });
        function validation(name, surname, birthday, donorid, newRegis) {
            $.ajax({
                url: '../ajaxAction/donorAction.aspx',
                data: {
                    action: 'checkvisited'
                    , id: donorid
                    , name: name
                    , surname: surname
                    , birthday: birthday
                    , receipthospitalid: $("#data").H2GAttr("receiptHospitalID")
                },
                type: "POST",
                dataType: "json",
                error: function (xhr, s, err) {
                    console.log(s, err);
                },
                success: function (data) {
                    if (!data.onError) {
                        data.getItems = jQuery.parseJSON(data.getItems);
                        console.log(data.getItems);
                        if (data.getItems.Duplicate == "" && data.getItems.AgeCheck == "") {
                            if (data.getItems.DonorID == "") {
                                $("#data").removeAttr("donorID").removeAttr("visitID").H2GFill({ donorName: name, donorSurname: surname, birthday: birthday });
                                $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                            } else {
                                if (newRegis) {
                                    H2GOpenPopupBox({
                                        detail: "ประวัติผู้บริจาคท่านนี้มีอยู่ในระบบแล้ว<br>หากเป็นคนละท่านกัน กรุณาตั้งชื่อให้แตกต่าง",
                                        confirmFunction: function () { return closePopup(); }
                                    });
                                } else {
                                    $("#data").removeAttr("donorName").removeAttr("donorSurname").removeAttr("birthday").H2GAttr("donorID", data.getItems.DonorID);
                                    $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                                }
                            }
                        } else if (data.getItems.Duplicate != "") {
                            notiWarning(data.getItems.Duplicate);
                        } else if (data.getItems.AgeCheck != "") {
                            H2GOpenPopupBox({
                                detail: data.getItems.AgeCheck,
                                confirmFunction: function () { return closePopup(); }
                            });
                            //$("#popupheader").H2GValue("กรุณาตรวจสอบ");
                            //$("#spAgeWarning").H2GValue(data.getItems.AgeCheck);
                            //$("#divAgeContainer").H2GFill({ donorID: data.getItems.DonorID });
                            //$("#divAgeContainer input.btn-success").click(function () {
                            //    if ($('#divAgeContainer').H2GAttr("donorID") == "") {
                            //        $("#data").H2GRemoveAttr("donorID,visitID").H2GFill({ donorName: name, donorSurname: surname, birthday: birthday });
                            //        $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                            //    } else {
                            //        if (newRegis) {
                            //            H2GOpenPopupBox({
                            //                detail:"ประวัติผู้บริจาคท่านนี้มีอยู่ในระบบแล้ว หากเป็นคนละท่านกัน กรุณาตั้งชื่อให้แตกต่าง",
                            //                confirmFunction: function () { return closePopup(); }
                            //            });
                            //        } else {
                            //            $("#data").H2GRemoveAttr("donorName,donorSurname,birthday").H2GAttr("donorID", $('#divAgeContainer').H2GAttr("donorID"));
                            //            $('<form>').append(H2G.postedData($("#data"))).H2GFill({ action: "register.aspx", method: "post", staffaction: "register" }).submit();
                            //        }
                            //    }
                            //});
                            //$("#divAgeContainer").find("input.btn-block").click(function () { closePopup(); });
                            //openPopup($("#divAgeContainer"));
                        }
                    } else {
                        notiWarning(data.exMessage);
                    }
                }
            });    //End ajax

            return true;
        }
        function donorSearch(newSearch) {
            if (!($("#txtDonorNumber").H2GValue() == "" &&
                $("#txtNationNumber").H2GValue() == "" &&
                $("#txtExtNumber").H2GValue() == "" &&
                $("#txtName").H2GValue() == "" &&
                $("#txtSurname").H2GValue() == "" &&
                $("#txtBirthday").H2GValue() == "" &&
                $("#txtBloodGroup").H2GValue() == "")) {
                var dataView = $("#tbDonor > tbody");
                $(dataView).H2GValue($("#tbDonor > thead > tr.more-loading").clone().show());
                if ($(dataView).closest("table").H2GAttr("wStatus") != "working") {
                    if (newSearch) { $("#tbDonor").attr("currentPage", 1) }
                    $(dataView).closest("table").H2GAttr("wStatus", "working");
                    $.ajax({
                        url: '../../ajaxAction/donorAction.aspx',
                        data: {
                            action: 'searchdonor'
                            , donornumber: $("#txtDonorNumber").H2GValue()
                            , nationnumber: $("#txtNationNumber").H2GValue()
                            , extnumber: $("#txtExtNumber").H2GValue()
                            , name: $("#txtName").H2GValue()
                            , surname: $("#txtSurname").H2GValue()
                            , birthday: $("#txtBirthday").H2GValue()
                            , bloodgroup: $("#txtBloodGroup").H2GValue()
                            , p: $("#tbDonor").attr("currentPage") || 1
                            , so: $("#tbDonor").attr("sortOrder") || "donor_number"
                            , sd: $("#tbDonor").attr("sortDirection") || "desc"
                        },
                        type: "POST",
                        dataType: "json",
                        error: function (xhr, s, err) {
                            console.log(s, err);
                            $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                            $(dataView).closest("table").H2GAttr("wStatus", "error");
                        },
                        success: function (data) {
                            $(dataView).H2GValue('');
                            if (!data.onError) {
                                data.getItems = jQuery.parseJSON(data.getItems);
                                console.log(data.getItems);
                                if (data.getItems.SearchList.length > 0) {
                                    if (data.getItems.GoNext == "Y") {
                                        if (data.getItems.Duplicate == "") {
                                            $.each((data.getItems.SearchList), function (index, e) {
                                                var dataRow = $("#tbDonor > thead > tr.template-data").clone();
                                                $(dataRow).H2GFill({ refID: e.ID, birthday: e.BirthdayFormat }).donorSelect();
                                            });
                                        } else {
                                            notiWarning(data.getItems.Duplicate);
                                            //$.each((data.getItems.SearchList), function (index, e) {
                                            //    var dataRow = $("#tbDonor > thead > tr.template-data").clone().show();
                                            //    $(dataRow).H2GFill({ refID: e.ID, birthday: e.BirthdayFormat });
                                            //    $(dataRow).find('.td-donor-number').H2GValue(e.DonorNumber).H2GAttr("title", e.DonorNumber);
                                            //    $(dataRow).find('.td-nation-number').H2GValue(e.NationNumber).H2GAttr("title", e.NationNumber);
                                            //    $(dataRow).find('.td-ext-number').H2GValue(e.ExternalNumber).H2GAttr("title", e.ExternalNumber);
                                            //    $(dataRow).find('.td-name').H2GValue(e.Name).H2GAttr("title", e.Name);
                                            //    $(dataRow).find('.td-surname').H2GValue(e.Surname).H2GAttr("title", e.Surname);
                                            //    $(dataRow).find('.td-birthday').H2GValue(e.Birthday).H2GAttr("title", e.Birthday);
                                            //    $(dataRow).find('.td-blood-group').H2GValue(e.BloodGroup).H2GAttr("title", e.BloodGroup);
                                            //    $(dataView).append(dataRow);
                                            //});
                                            //$(dataView).closest("table").attr("totalPage", data.getItems.TotalPage)
                                            ////alert(data.getItems.Duplicate);
                                        }
                                    } else {
                                        $.each((data.getItems.SearchList), function (index, e) {
                                            var dataRow = $("#tbDonor > thead > tr.template-data").clone().show();
                                            $(dataRow).H2GFill({ refID: e.ID, birthday: e.BirthdayFormat });
                                            $(dataRow).find('.td-donor-number').H2GValue(e.DonorNumber).H2GAttr("title", e.DonorNumber);
                                            $(dataRow).find('.td-nation-number').H2GValue(e.NationNumber).H2GAttr("title", e.NationNumber);
                                            $(dataRow).find('.td-ext-number').H2GValue(e.ExternalNumber).H2GAttr("title", e.ExternalNumber);
                                            $(dataRow).find('.td-name').H2GValue(e.Name).H2GAttr("title", e.Name);
                                            $(dataRow).find('.td-surname').H2GValue(e.Surname).H2GAttr("title", e.Surname);
                                            $(dataRow).find('.td-birthday').H2GValue(e.Birthday).H2GAttr("title", e.Birthday);
                                            $(dataRow).find('.td-blood-group').append(e.BloodGroup).H2GAttr("title", e.BloodGroup);
                                            $(dataView).append(dataRow);
                                        });
                                        $(dataView).closest("table").attr("totalPage", data.getItems.TotalPage)
                                    }

                                } else {
                                    $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                                    $(dataView).closest("table").attr("totalPage", 0)
                                }
                            } else {
                                $(dataView).H2GValue($("#tbDonor > thead > tr.no-transaction").clone().show());
                                $(dataView).closest("table").attr("totalPage", 0)
                            }
                            $(dataView).closest("table").H2GAttr("wStatus", "done");
                            genGridPage($(dataView).closest("table"), donorSearch);
                            $("#txtDonorNumber").focus();
                        }
                    });    //End ajax
                }

            } else {
                notiWarning("กรุณากรอกข้อมูลที่ต้องการค้นหา อย่างน้อย 1 ช่องข้อมูล");
            }
        }
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
                        , reportdate: $("#data").H2GAttr("plan_date") //formatDate(H2G.today(), "dd/MM/yyyy") //$("#txtReportDate").H2GValue()
                        , status: $("#data").H2GAttr("receiptHospitalID") ? "WAIT RESULT" : "WAIT INTERVIEW"
                        , receipthospitalid: $("#data").H2GAttr("receiptHospitalID")
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
                                        $(dataRow).find('.td-queue').H2GValue(e.QueueNumber).H2GAttr("title", e.QueueNumber);
                                        $(dataRow).find('.td-name').H2GValue(e.Name).H2GAttr("title", e.Name);
                                        $(dataRow).find('.td-sample').H2GValue(e.SampleNumber).H2GAttr("title", e.SampleNumber);
                                        $(dataRow).find('.td-remarks').H2GValue(e.Comment).H2GAttr("title", e.Comment);
                                        $(dataRow).find('.td-regis-staff').H2GValue(e.RegisStaff).H2GAttr("title", e.RegisStaff);
                                        $(dataRow).find('.td-regis-time').H2GValue(e.RegisTime).H2GAttr("title", e.RegisTime);
                                        $(dataRow).find('.td-interview-staff').H2GValue(e.InterviewStaff).H2GAttr("title", e.InterviewStaff);
                                        $(dataRow).find('.td-interview-time').H2GValue(e.InterviewTime).H2GAttr("title", e.InterviewTime);
                                        $(dataRow).find('.td-collection-staff').H2GValue(e.CollectionStaff).H2GAttr("title", e.CollectionStaff);
                                        $(dataRow).find('.td-collection-time').H2GValue(e.CollectionTime).H2GAttr("title", e.CollectionTime);
                                        $(dataRow).find('.td-lab-staff').H2GValue(e.LabStaff).H2GAttr("title", e.LabStaff);
                                        $(dataRow).find('.td-lab-time').H2GValue(e.LabTime).H2GAttr("title", e.LabTime);
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
                        genGridPage($(dataView).closest("table"), postQueueSearch);
                        $("#txtPostQueue").focus();
                    }
                });    //End ajax
            }
        }
        function enterDatePickerSearch(dateControl, action, doFunction) {
            var doFun = doFunction || donorSearch;
            var pattern = 'dd/MM/yyyy';
            if ($(dateControl).H2GValue() != '') {
                $(dateControl).H2GValue($(dateControl).H2GValue().replace(/\W+/g, ''));
                $(dateControl).next().remove();
                if (isDate($(dateControl).H2GValue(), pattern.replace(/\W+/g, ''))) {
                    var isValue = new Date(getDateFromFormat($(dateControl).H2GValue(), pattern.replace(/\W+/g, '')));
                    $(dateControl).H2GValue(formatDate(isValue, pattern))
                    if (action == "enter") {
                        doFun(true);
                    }
                } else {
                    notiWarning("วันที่ไม่ถูกต้อง กรุณาตรวจสอบ");
                    $(dateControl).focus();
                }
            } else { doFun(true); }
        }
    </script>
    <style>
        #searchTab .border-box {
            background:#FFFFFF;
        }
    </style>
</asp:Content>
<asp:Content ID="ctDonorSearch" ContentPlaceHolderID="cphMaster" runat="server">
    <div id="divReceiptHospital" class="row" style="display:none; margin-top: 5px;">
        <div class="col-md-6">
            <div class="text-center border-box" style="background-color:#E5F5D7;">
                <button style="border: 0; background-color: transparent;" onclick="return $(this).backToLabRegis();">
                    <i class="icon-refresh" style="vertical-align: middle; font-size: 25px; color: #E77024;">
                        <span style="font-family: THSarabunNew; font-size: 20px; color: #595959; vertical-align: text-bottom; font-weight: bold;">เปลี่ยนโรงพยาบาล</span>
                    </i>
                </button>
            </div>
        </div>
        <div class="col-md-30">
            <div class=" text-center border-box" style="background-color:#E5E0EC;">
                <span id="spReceiptHospital" style="font-weight: bold;">โรงพยาบาลเชียงรายประชานุเคราะห์ รายการที่ 0/0</span>
            </div>
        </div>
    </div>
    <div class="claret-page-header row">
        <div class="col-md-36" style="font-size:larger; font-weight:bold;">
            <span>ค้นหารายชื่อผู้บริจาค</span>
        </div>
    </div>
    <div id="searchTabBox" class="row">
        <div id="searchTab">
            <ul>
                <li><a href="#regisPane" style="">Register</a></li>
                <li><a href="#postQueuePane" style="">Post Queue</a></li>
            </ul>
            <div id="regisPane">
                <div class="border-box">
                    <div id="content-one" style="padding-left:15px; padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>1. ใส่ข้อมูลผู้บริจาคเพื่อค้นหาประวัติ (ใส่ % แทนสิ่งที่ไม่ทราบเช่น นามสกุล ลิขิต% แทนการพิมพ์นามสกุลเต็มๆ)</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-6">
                                <span>เลขประจำตัวผู้บริจาค</span>
                            </div>
                            <div class="col-md-6">
                                <span>เลขประจำตัวประชาชน</span>
                            </div>
                            <div class="col-md-6">
                                <span>เลขประจำตัวอ้างอิง</span>
                            </div>
                            <div class="col-md-6">
                                <span>ชื่อ</span>
                            </div>
                            <div class="col-md-6">
                                <span>นามสกุล</span>
                            </div>
                            <div class="col-md-3">
                                <span>วันเกิด</span>
                            </div>
                            <div class="col-md-3">
                                <span>กรุ๊ปเลือด</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <div style="background-color: #CCCCCC; height: 2px;"></div>
                            </div>
                        </div>
                        <div id="divCriteria" class="row" style="padding-top: 3px; padding-bottom: 3px; padding-left:15px;">
                            <div class="col-md-6">
                                <input id="txtDonorNumber" class="form-control color-yellow" maxlength="10" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtNationNumber" class="form-control color-yellow" maxlength="13" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtExtNumber" class="form-control" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtName" class="form-control" type="text" />
                            </div>
                            <div class="col-md-6">
                                <input id="txtSurname" class="form-control" type="text" />
                            </div>
                            <div class="col-md-3">
                                <input id="txtBirthday" class="form-control text-center" type="text" />
                            </div>
                            <div class="col-md-3">
                                <div class="col-md-16">
                                    <input id="txtBloodGroup" class="form-control text-center" type="text" />
                                </div>
                                <div class="col-md-20">
                                    <a title="ลบข้อมูลที่กรอก"><span id="spClear" class="glyphicon glyphicon-remove"></span></a>
                                    <a title="ค้นหา"><span id="spSearch" class="glyphicon glyphicon-search"></span></a>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div id="content-two" style="padding-left:15px;padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>2. กรุณาตรวจสอบรายละเอียดเบื้องต้นและกด -> หากต้องการลงทะเบียน</span>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <div id="paging-history">
                                </div>
                            </div>
                        </div>
                        <div class="row" style="padding-left: 15px;">
                            <div class="col-md-36">
                                <table id="tbDonor" class="table table-hover table-striped table-dis-input" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="donor_number">
                                    <thead>
                                        <tr>
                                            <th style="width: 16.66666667%;"><button sortOrder="donor_number">เลขประจำตัวผู้บริจาค<i class="glyphicon glyphicon-triangle-bottom"></i></button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="nation_number">เลขประจำตัวประชาชน</button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="external_number">เลขประจำตัวอ้างอิง</button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="name">ชื่อ</button>
                                            </th>
                                            <th style="width: 16.66666667%;"><button sortOrder="surname">นามสกุล</button>
                                            </th>
                                            <th style="width: 8.33333333%;"><button sortOrder="birthday">วันเกิด</button>
                                            </th>
                                            <th style="width: 8.33333333%;"><button sortOrder="blood_group">กรุ๊ปเลือด</button>
                                            </th>
                                        </tr>
                                        <tr class="no-transaction" style="display:none;"><td align="center" colspan="7">ไม่พบข้อมูล</td></tr>
                                        <tr class="more-loading" style="display:none;"><td align="center" colspan="7">Loading detail...</td></tr>
                                        <tr class="template-data" style="display:none;" refID="NEW">
                                            <td class="td-donor-number">
                                            </td>
                                            <td class="td-nation-number">
                                            </td>
                                            <td>
                                                <input type="text"  class="td-ext-number" readonly />
                                            </td>
                                            <td>
                                                <input type="text" class="td-name" readonly />
                                            </td>
                                            <td>
                                                <input type="text" class="td-surname" readonly />
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
                    <div id="content-three" style="padding-left:15px;padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36">
                                <span>3. หากไม่พบข้อมูล ต้องการสร้างประวัติใหม่กรุณาระบุ ชื่อ นามสกุล วันเกิด และกดที่นี่</span>
                            </div>
                            <div class="col-md-9" style="padding-left: 15px;">
                                <input id="btnNewRegis" type="button" class="btn btn-block btn-success" targetUrl="register.aspx" value="ไม่พบข้อมูล - กดที่นี่เพื่อเพิ่มชื่อผู้บริจาคใหม่" />
                            </div>
                        </div>

                    </div>
                </div>
            </div>
            <div id="postQueuePane">
                <div class="border-box">
                    <div id="post-content-one" style="padding-left:15px; padding-bottom: 20px;">
                        <div class="row">
                            <div class="col-md-36 text-center">
                                <span id="spQueueHeader" style="font-size: larger;"></span>
                            </div>
                        </div>
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
                                <table id="tbPostQueue" class="table table-bordered table-dis-input" totalPage="1" currentPage="1" sortDirection="desc" sortOrder="queue_number">
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
                                            <th class="col-md-4" colspan="2"><button>บริจาค</button>
                                            </th>
                                            <th class="col-md-4" colspan="2"><button>Lab</button>
                                            </th>
                                            <th class="col-md-1"></th>
                                        </tr>
                                        <tr class="no-transaction" style="display:none;"><td align="center" colspan="13">ไม่พบข้อมูล</td></tr>
                                        <tr class="more-loading" style="display:none;"><td align="center" colspan="13">Loading detail...</td></tr>
                                        <tr class="template-data" style="display:none;" refID="NEW">
                                            <td class="td-queue text-center">
                                            </td>
                                            <td>
                                                <input type="text" class="td-name" readonly />
                                            </td>
                                            <td>
                                                <input type="text" class="td-sample" readonly />
                                            </td>
                                            <td>
                                                <input type="text" class="td-remarks" readonly />
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
        </div>
    </div>
    <div id="divAgeContainer" style="display:none;">
            <div id="divAgeTemplete" style="display: inline-block;">
                <div class="newouterborder" style="background-color: #F4F4F4;">
                    <div class="popheader row text-left" style="padding: 5px 0px;">
                        <div id="popupheader" class="popupheader col-md-33">กรุณาตรวจสอบ</div>
                        <div class="col-md-3 text-center" style="float:right;">
                            <a class="icon"><span class="glyphicon glyphicon-remove" aria-hidden="true" title="close" onclick="return closePopup();"></span></a>
                        </div>
                    </div>
                    <div class="popupbody text-left" style="width:300px;">
                        <div class="row">
                            <div class="col-md-36"><span id="spAgeWarning"></span></div>
                        </div>
                        <div class="row">
                            <div class="col-md-6 col-md-offset-24 text-right">
                                <input type="button" value="ตกลง" class="btn btn-block btn-success" onclick="return autoCreatePlan();" />
                            </div>
                            <div class="col-md-6 text-right">
                                <input type="button" value="ยกเลิก" class="btn btn-block" onclick="return closePopup();" />
                            </div>
                        </div>
                    </div>
                    <div class="popfooter" style="text-align: right;">
                    </div>
                </div>
            </div>
        </div>
</asp:Content>
