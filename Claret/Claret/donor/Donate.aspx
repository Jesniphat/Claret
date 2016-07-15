<%@ Page Title="" Language="vb" AutoEventWireup="false" MasterPageFile="~/MasterPage.Master" CodeBehind="Donate.aspx.vb" Inherits="Claret.Donate" %>
<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link href="../resources/css/donateStyle.css" rel="stylesheet" />
    <script src="../resources/javascript/donateScript.js" type="text/javascript"></script>
    <script>
        console.log("Donate")
        $(function () {
            $("#donateTab").tabs({
                active: 0
            });
            $("#donateType").setDropdowList();
            $("#donateBagType").setDropdowList();
            $("#donateApply").setDropdowList();
            $("#donateStatus").setDropdowList();
            $("#donateDate").H2GValue(formatDate(H2G.today(), "dd/MM/yyyy")).H2GDatebox().setCalendar({
                maxDate: "+10y",
                // minDate: new Date(),
                yearRange: "c-100:c+0",
                onSelect: function (selectedDate, objDate) { $("#txtDonorComment").focus(); },
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
                <li><a href="#donatePane" style="">Donete</a></li>
                <li><a href="#postQueuePane" style="">Post Queue</a></li>
            </ul>
            <div id="donatePane">
                <div class="border-box">
                    <div class="border-box">
                        <p><label>กำหนดประเภทของการรับบริจาคที่กำลังจะดำเนินงาน</label></p>
                        <div class="col-md-36">
                            <div class="col-md-4 text-right setPaddingRight">ประเภทการบริจาค</div>
                            <div class="col-md-7">
                                <select id="donateType">
                                    <option value="0">น้องเอ้ย...</option>
                                    <option value="1">ทนไม่ไหวแล้ว...</option>
                                </select>
                            </div>
                            <div class="col-md-4 text-right setPaddingRight">ประเภทถุง</div>
                            <div class="col-md-7">
                                <select id="donateBagType">
                                    <option value="0">น้องเอ้ย...</option>
                                    <option value="1">ทนไม่ไหวแล้ว...</option>
                                </select>
                            </div>
                            <div class="col-md-4 text-right setPaddingRight">การนำไปใช้งาน</div>
                            <div class="col-md-7">
                                <select id="donateApply">
                                    <option value="0">น้องเอ้ย...</option>
                                    <option value="1">ทนไม่ไหวแล้ว...</option>
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
                                <input type="text" id="donateDate" class="col-md-36 form-control" value="" />
                            </div>
                            <div class="col-md-2 text-right setPaddingRight">สถานะ</div>
                            <div class="col-md-9">
                                <select id="donateStatus">
                                    <option value="0">น้องเอ้ย...</option>
                                    <option value="1">ทนไม่ไหวแล้ว...</option>
                                </select>
                            </div>
                            <div class="col-md-8"></div>
                        </div>
                    </div>
                </div>
            </div>
            <div id="postQueuePane">
                <h2>XXXMM</h2>
            </div>
        </div>
    </div>
</asp:Content>
