var monthNames = ["ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.",
  "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."
]; var monthNamesFull = ["มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถุนายน",
  "กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤษจิกายน", "ธันวาคม"
];
var H2G = {
    Browser: {
        Chrome : window.navigator.userAgent.indexOf('Chrome') > -1 || window.navigator.userAgent.indexOf('Firefox') > -1 ? true : false,
        IE : false
    },
    postedData: function (xobj) {
        var retValue = ''
        $(xobj).each(function () {
            $.each(this.attributes, function () {
                if (this.specified) {
                    if (!(this.name == 'name' || this.name == 'type' || this.name == 'id' || this.name == 'style')) {
                        retValue += '<input name="' + this.name + '" value="' + this.value + '" />';
                    }
                }
            });
        });
        return retValue;
    },
    ajaxData: function (setting) {
        var self = this;
        self.config = {};
        $.extend(self.config, setting);
        $("#data").each(function () {
            $.each(this.attributes, function () {
                if (this.specified) {
                    if (!(this.name == 'name' || this.name == 'type' || this.name == 'id' || this.name == 'style')) {
                        self.config[this.name] = this.value;
                    }
                }
            });
        });

        return this;
    },
    IsEmail: function(email) {
        var regex = /^([a-zA-Z0-9_\.\-\+])+\@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9]{2,4})+$/;
        if (!regex.test(email)) { return false; } else { return true; }
    },
    calAge: function (birthday) {
        var age = '';
        if (!(birthday == '' || birthday == undefined)) {
            var today = new Date(), // today date object
            birthday_val = birthday.split('/'), // input value
            birthday = new Date(birthday_val[2], birthday_val[1] - 1, birthday_val[0]); // birthday date object
            today.setFullYear(today.getFullYear() + 543);
            // calculate age
            age = (today.getMonth() == birthday.getMonth() && today.getDate() > birthday.getDate()) ?
                today.getFullYear() - birthday.getFullYear() : (today.getMonth() > birthday.getMonth()) ?
                        today.getFullYear() - birthday.getFullYear() :
                            today.getFullYear() - birthday.getFullYear() - 1;
            age = age;
            return age;
        }
    },
    dateText: function (dateIn, fullText) {
        fullText = fullText || false;
        var arMonth = fullText ? monthNamesFull : monthNames;
        if (dateIn != undefined && dateIn != "") {
            dateIn = dateIn.split('/')
            var d = new Date(dateIn[2], dateIn[1] - 1, dateIn[0]);
            return dateIn[0] + ' ' + arMonth[d.getMonth()] + ' ' + dateIn[2];
        }
        return dateIn;
    },
    jsDateDiff: function(Date1, Date2) {
        return (((Date.parse(Date2) / 1000) - Date.parse(Date1) / 1000)) / (60 * 60 * 24);
    },
    // sort on values
    srt: function (desc) {
        return function (a, b) {
            return desc ? ~~(a < b) : ~~(a > b);
        };
    },
    // sort on key values
    keysrt: function (key, desc) {
        return function (a, b) {
            return desc ? ~~(a[key] < b[key]) : ~~(a[key] > b[key]);
        }
    },
    today: function () {
        retToday = new Date();
        return new Date(retToday.setFullYear(retToday.getFullYear() + 543));
    },
}

$.extend($.fn, {
    setDropdowList: function () {
        var dclass = "";
        if ($(this).attr("class") != undefined) {
            dclass = $(this).attr("class");
        }
        $.selecter("defaults", { customClass: dclass });
        $(this).selecter();
        return this;
    },
    setDropdowListValue: function (setting, defaultSelect) {
        var self = this;
        var config = {
            url: '',
            data: {},
            type: "POST",
            dataType: "json",
        };
        $.extend(config, setting);

        $.ajax({
            url: config.url,//'../../ajaxAction/donorAction.aspx',
            data: config.data,
            type: config.type,
            dataType: config.dataType,
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                $(self).html('');//.selecter('destroy').setDropdowList();
                $("<option>", { value: "" }).html("กรุณาเลือก").appendTo(self);
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    $.each((data.getItems), function (index, e) {
                        $("<option>", { value: e.code, valueID: e.id }).html(e.name).appendTo(self);
                    });
                    $(self).setDropdowList().selecter("update");
                    if (defaultSelect != undefined) { $(self).val(defaultSelect).change(); }
                } else { $(self).setDropdowList().selecter("update"); }
            }
        });    //End ajax
        return this;
    },
    setAutoListValue: function (setting, defaultSelect) {
        var self = this;
        var config = {
            url: '',
            data: {},
            type: "POST",
            dataType: "json",
        };
        $.extend(config, setting);

        $.ajax({
            url: config.url,//'../../ajaxAction/donorAction.aspx',
            data: config.data,
            type: config.type,
            dataType: config.dataType,
            error: function (xhr, s, err) {
                console.log(s, err);
            },
            success: function (data) {
                $(self).html('');//.selecter('destroy').setDropdowList();
                //$("<option>", { value: "" }).html("กรุณาเลือก").appendTo(self);
                if (!data.onError) {
                    data.getItems = jQuery.parseJSON(data.getItems);
                    $.each((data.getItems), function (index, e) {
                        $("<option>", { value: e.code }).html(e.name).appendTo(self);
                    });
                    $(self).H2GValue(defaultSelect || "").combobox({
                        appendTo: "#mstContent",
                    });
                    $(self).parent().find("span").find("input").val($(self).find(":selected").text());
                } else {
                    $(self).combobox({
                        appendTo: "#mstContent",
                    });
                }
                $("#tog" + $(self).H2GAttr("id").replace("ddl","")).click(function () {
                    $(self).toggle();
                });
            }
        });    //End ajax
        return this;
    },
    setCalendar: function (setting) {
        var config = {
            month: 1,
            maxDate: null,
            minDate: null,
            format: 'dd/mm/yy',
            changeMonth: true,
            changeYear: true,
            showButtonPanel: false,
            yearRange: "c-20:c+20",
            onSelect: function (selectedDate, objDate) { },
            onClose: function () { },
            onEnterKey: function () { },
        };
        $.extend(config, setting);
        $(this).bind("keydown", function (e) {
            if (e.which == 13) {
                $(this).datepicker("hide");
                config.onEnterKey();
                e.preventDefault();
                return false;
            }
        }).datepicker({
            numberOfMonths: config.month,
            maxDate: config.maxDate,
            minDate: config.minDate,
            dateFormat: config.format,
            constrainInput: true,
            changeMonth: config.changeMonth,
            changeYear: config.changeYear,
            showButtonPanel: config.showButtonPanel,
            yearOffSet: 543,
            monthNames: ["มกราคม", "กุมภาพันธ์", "มีนาคม", "เมษายน", "พฤษภาคม", "มิถนายน",
            	"กรกฎาคม", "สิงหาคม", "กันยายน", "ตุลาคม", "พฤษจิกายน", "ธันวาคม"], 
            monthNamesShort: ["ม.ค.", "ก.พ.", "มี.ค.", "เม.ย.", "พ.ค.", "มิ.ย.", "ก.ค.", "ส.ค.", "ก.ย.", "ต.ค.", "พ.ย.", "ธ.ค."], 
            dayNames: ["อาทิตย์", "จันทร์", "อังคาร", "พุธ", "พฤหัสบดี", "ศุกร์", "เสาร์"], 
            dayNamesShort: ["อา.", "จ.", "อ.", "พ.", "พฤ.", "ศ.", "ส."], 
            dayNamesMin: ["อ", "จ", "อ", "พ", "พ", "ศ", "ส"], 
            yearRange: config.yearRange,
            onSelect: config.onSelect,
            onClose: config.onClose,
        });
        return this;
    },
    toggleSlide: function (setting) {
        var config = {
            id: ''
        };
        $.extend(config, setting);
        if (config.id == '') { config.id = $(this).attr("targetToggle") == undefined ? '' : $(this).attr("targetToggle") }
        $(this).click(function () {
            if ($("#" + config.id).css("display") == "none") {
                $("#" + config.id).slideDown();
                $(this).removeClass("glyphicon-menu-down").addClass("glyphicon-menu-up");
            } else {
                $("#" + config.id).slideUp();
                $(this).removeClass("glyphicon-menu-up").addClass("glyphicon-menu-down");
            }
        });
        return this;
    },
    H2GValue: function (value, e) {
        if (value != undefined && value != null) {
            switch ($(this).prop('tagName')) {
                case 'INPUT':
                    var attrType = $(this).attr('type');
                    if (attrType == 'text') {
                        var pretext = $(this).attr('pretext') || '';
                        $(this).val(value);
                        if (!H2G.Browser.Chrome && value === '') $(this).val(pretext);
                    } else if (attrType == 'radio' || attrType == 'checkbox') {
                        $(this).prop('checked', value.toBoolean());
                    }
                    break;
                case 'SELECT':
                    if (typeof (value) == 'number') $(this).prop('selectedIndex', value); else $(this).val(value);
                    $(this).change();
                    break;
                default:
                    $(this).html(value).val(value);
                    break;
            }
            return this;
        } else {
            var result = null;
            switch ($(this).prop('tagName')) {
                case 'INPUT':
                    if ($(this).attr('type') == 'text') {
                        result = ($.trim($(this).val()) == $(this).attr('pretext') || $.trim($(this).val()) == '') ? '' : $.trim($(this).val());
                    } else if ($(this).attr('type') == 'radio') {
                        result = ($(this).prop('checked') == true || $(this).attr('checked') == 'checked') ? 'Y' : 'N';
                    } else if ($(this).attr('type') == 'password') {
                        result = $(this).val();
                    }
                    break;
                case 'SELECT': result = $(this).val(); break;
                case 'SELECT': result = $(this).val(); break;
                case 'TEXTAREA': result = $.trim($(this).val()); break;
                default: result = $(this).html(); break;
            }
            return result;
        }
    },
    H2GAttr: function (name, value) {
        if (name != undefined && value == undefined) {
            return $(this).attr(name);
        } else if (value != undefined) {
            $(this).attr(name, value);
        } else {
            return $(this).attr('default-data');
        }
    },
    H2GFill: function (e, attr) {
        if (e == undefined && attr == undefined) attr = '';
        if (attr == undefined) attr = e;
        var Obj = (typeof (attr) !== 'object') ? ((attr == undefined) ? {} : { value: attr }) : attr;
        for (prop in Obj) {
            var eAttr = null, value = null;
            try {
                eAttr = $(e).attr(Obj[prop]) || $(e).find(Obj[prop]).val()
                value = (typeof (e) === 'object') ? ((eAttr != undefined) ? eAttr : (attr == e) ? Obj[prop] : '') : e;
            } catch (err) { value = (e != undefined && Obj[prop] != undefined) ? e : ''; }
            switch (prop) {
                case 'value':
                    $(this).attr('default-data', value);
                    $(this).MBOSValue(value, e);
                    break;
                default: $(this).attr(prop, value); break;
            }
        }
        return this;
    },
    H2GNumberbox: function () {
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 46 || keyCode == 13);
            var NumKey = (keyCode >= 48 && keyCode <= 57);// || (e.keyCode>=96 && e.keyCode<=105); // (Number in Keyboard) || (Numpad)
            if (!NumKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).val(''); }
        });

        return this;
    },
    H2GPhonebox: function () {
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 45 || keyCode == 35 || keyCode == 13);
            var NumKey = (keyCode >= 48 && keyCode <= 57);// || (e.keyCode>=96 && e.keyCode<=105); // (Number in Keyboard) || (Numpad)
            if (!NumKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).val(''); }
        });

        return this;
    },
    H2GThaibox: function (optionKey) {
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            console.log(keyCode);
            var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 45 || keyCode == 13);
            OtherKey = (OtherKey || keyCode == optionKey)
            var NumKey = ((keyCode >= 3585 && keyCode <= 3641) || (keyCode >= 3648 && keyCode <= 3660));
            if (!NumKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).val(''); }
        });

        return this;
    },
    H2GEnglishbox: function (optionKey) {
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            console.log(keyCode);
            var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 45 || keyCode == 13);
            OtherKey = (OtherKey || keyCode == optionKey)
            var NumKey = ((keyCode >= 65 && keyCode <= 90) || (keyCode >= 97 && keyCode <= 122));
            if (!NumKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).val(''); }
        });
        return this;
    },
    H2GNamebox: function (optionKey) {
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            console.log(keyCode);
            var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 45 || keyCode == 13);
            OtherKey = (OtherKey || keyCode == optionKey)
            var NumKey = ((keyCode >= 65 && keyCode <= 90) || (keyCode >= 97 && keyCode <= 122)
                || (keyCode >= 3585 && keyCode <= 3641) || (keyCode >= 3648 && keyCode <= 3660));
            if (!NumKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).val(''); }
        });
        return this;
    },
    H2GDatebox: function (pattern,focusOutFun) {
        // Can't use date below 01-01-1900
        $(this).data('error', false);
        if (typeof (pattern) === 'undefined') pattern = "dd/MM/yyyy";
        $(this).attr('maxlength', '10').css({ 'text-align': 'center' });
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.altKey || keyCode == 8 || keyCode == 9 || keyCode == 46);
            var DateKey = (keyCode >= 48 && keyCode <= 57) || String.fromCharCode(keyCode) === '-';// || (e.keyCode>=96 && e.keyCode<=105); // (Number in Keyboard) || (Numpad)
            if (!DateKey && !OtherKey) { return false; } //else { if ($(this).MBOSValue() === "") { $(this).css('color', _TXTCOLOR).val(''); } }
        });
        $(this).focusout(function (e) {
            if ($(this).H2GValue() !== "") {
                $(this).val($(this).val().replace(/\W+/g, ''));
                $(this).next().remove();
                if (isDate($(this).val(), pattern.replace(/\W+/g, ''))) {
                    var isValue = new Date(getDateFromFormat($(this).val(), pattern.replace(/\W+/g, '')));
                    $(this).val(formatDate(isValue, pattern));
                } else if ($.trim($(this).val()) !== "") {
                    $(this).focus();
                    notiWarning("วันที่ไม่ถูกต้องกรุณาตรวจสอบ");
                    //$(this).data('error', true).css({ 'border': _TXTBORDER_ERROR + ' solid 1px', 'color': _TXTBORDER_ERROR });
                }
                if (focusOutFun != undefined) { focusOutFun(); }
            }
        });

        $(this).focusin(function (e) {
            $(this).data('error', false);
            if ($(this).H2GValue() !== "") { $(this).val($(this).val().replace(/\W+/g, '')).select(); }
        });

        return this;
    },
    enterKey: function (fnc) {
        return this.each(function () {
            $(this).keypress(function (ev) {
                var keycode = (ev.keyCode ? ev.keyCode : ev.which);
                if (keycode == '13') {
                    fnc.call(this, ev);
                }
            })
        })
    },
});

$.extend(Number.prototype, {
    toMoney: function () {
        var n = this, c = 2, d = ".", t = ",", s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
        return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
    },
    toCRate: function () {
        var n = this, c = 5, d = ".", t = ",", s = n < 0 ? "-" : "", i = parseInt(n = Math.abs(+n || 0).toFixed(c)) + "", j = (j = i.length) > 3 ? j % 3 : 0;
        return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t) + (c ? d + Math.abs(n - i).toFixed(c).slice(2) : "");
    }
});
$.extend(String.prototype, {
    toNumber: function () { var n = this, f = n != undefined ? parseFloat(parseFloat(n.replace(/,/g, '')).toFixed(2)) : 0; return (!isNaN(f)) ? f : 0; },
    toBoolean: function () {
        var m = { 'n': false, 'N': false, 'no': false, 'NO': false, 'FALSE': false, 'y': true, 'Y': true, 'false': false, 'yes': true, 'YES': true, 'TRUE': true, 'true': true };
        return (m.hasOwnProperty(this)) ? m[this] : false;
    },
    toRate: function () { var n = this, f = n != undefined ? parseFloat(parseFloat(n.replace(/,/g, '')).toFixed(5)) : 0; return (!isNaN(f)) ? f : 0; }
});

function notiSuccess(value) { showNoti(value, "ok"); }
function notiError(value) { showNoti(value, "remove"); }
function notiInfo(value) { showNoti(value, "info"); }
function notiWarning(value) { showNoti(value, "question"); }
function showNoti(value, type) {
    var windowWidth = parseInt($(window).width());
    $("#divNoti").find(".noti-message").html(value);
    $("#divNoti").find(".sign").addClass("glyphicon-" + type + "-sign");
    $("#divNoti").addClass("noti-" + type).css({ left: parseInt(windowWidth) - ($("#divNoti").outerWidth() + 20) });
    if ($("#divNoti").css('display') == 'none') {
        $("#divNoti").slideDown(function () {
            setTimeout(function () {
                $("#divNoti").slideUp(function () {
                    $(this).removeClass("noti-" + type).find(".sign").removeClass("glyphicon-" + type + "-sign");
                });
            }, 3000);
        });
    }
}