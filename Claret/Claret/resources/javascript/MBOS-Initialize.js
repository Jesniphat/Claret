$.extend(window, {
    CallbackException : function(m1, m2) {
        this.onError = m1.onError || true;
        this.exTitle = m1.exTitle || ((m2!=undefined) ? m1 : undefined) || "ERROR";
        this.exMessage = m1.exMessage || m2 || m1 || "";
        this.getItems = m1.getItems || {};
        if(m1.getItems != undefined) this.getItems = jQuery.parseJSON(this.getItems);
        this.toString = function(){ return this.exTitle + ' >>> ' + this.exMessage; }
    },
    Performance : function(funcName) {
        var EnablePerformance = performance != undefined && MBOS.Browser.Chrome;
        var BeginTime = 0.0, ElapsedTime = 0.0, FinishTime = 0.0;
        var func_name = funcName || "Performance"
        this.Start = function(){
            if(EnablePerformance) {
                var time = new Date().getHours() + ':' + new Date().getMinutes() + ':' + new Date().getSeconds();
                BeginTime = performance.now();
                ElapsedTime = BeginTime;
                log(func_name + "() Performance >>> Starting on " + time);
            }
        }
        this.Check = function(msg){
            if(EnablePerformance) {
                var now = performance.now();
                log((msg == undefined ? func_name + "() elapsed time is" : msg) + "\n\r", (now - ElapsedTime), "ms");
                ElapsedTime = now;
            }
        }
        this.Stop = function(msg){
            if(EnablePerformance) {
               var time = new Date().getHours() + ':' + new Date().getMinutes() + ':' + new Date().getSeconds();
               var now = performance.now();
               FinishTime = now;
               log((msg == undefined ? func_name + "() elapsedtime is" : msg) + "\n\r", (now - ElapsedTime) , "ms (" + ((FinishTime - BeginTime) / 1000).toFixed(2) + " s)");
                log(func_name + "() Performance >>> Stoped on " + time);
               ElapsedTime = performance.now();
            }
        }
        this.toString = function(){ return  func_name + "() elapsedtime is " + ((FinishTime - BeginTime) / 1000).toFixed(2) + " s"; }
    },
//    alert : function(title, msg, cancel) {
//        if(title instanceof CallbackException) {
//            
//        } else {
//            
//        }
//    },
//    confirm : function(title, msg, yes, no) {
//        
//    },
    log : function(msg1, msg2, msg3, msg4, msg5) {
        if(console != undefined) {
            if(msg2 == undefined) { console.log(msg1); }
            else if(msg3 == undefined) { console.log(msg1, msg2); }
            else if(msg4 == undefined) { console.log(msg1, msg2, msg3); }
            else if(msg5 == undefined) { console.log(msg1, msg2, msg3, msg4); }
            else if(msg5 != undefined) { console.log(msg1, msg2, msg3, msg4, msg5); }
        }
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
var MBOS = {
    DEBUG: function () {
        return (location.hostname==='localhost') ?  true : false;
    },
    Browser: {
        Chrome : window.navigator.userAgent.indexOf('Chrome') > -1 || window.navigator.userAgent.indexOf('Firefox') > -1 ? true : false,
        IE : false
    },
    Timestamp : parseInt((new Date().getTime() / 1000)),
    Storage: function(key, setValue) {
        var getValue = null;
        try {
            if(typeof(setValue) === 'undefined') {
                getValue = window.localStorage.getItem(MBOS.Cookie('COMPANY_ACCESS')+'>'+key);
            } else {
                window.localStorage.setItem(MBOS.Cookie('COMPANY_ACCESS')+'>'+key, setValue.toString());
            }
        } catch (e) { /* Browser not support localStorage function. */ }
        return getValue;
    },
    StorageClear: function(key){
        try {
            if(key == undefined) {
                $.each(window.localStorage, function(key,value){ window.localStorage.removeItem(key); }); 
            } else {
                localStorage.removeItem(key);
            }
        } catch (e) { /* Browser not support localStorage function. */ }
    },
    Path: function(){
        var local = window.location.href.toLowerCase(), test = (local.indexOf("/mos_demo/") > -1) ? "mos_demo" : "mos_v2";
        if (local.indexOf(test + "/account/") > -1) {
            local = "/" + test + "/account/";
        } else if (local.indexOf(test + "/operation/") > -1) {
            local = "/" + test + "/operation/";
        }
        return local;
    },
    Popup: function (url, target) {
        var d = new Date(), onHandler = 'onHandlerWindows_' + (d.getTime() / 1000), typeDownload = false, jWin = $(parent.window)
        var w = Math.round((screen.width || jWin.width()) * 0.86, 0), h = Math.round((screen.height || jWin.height()) * 0.82, 0);
        var x = +Math.round(((screen.width || jWin.width()) - w) / 2, 0), y = Math.round(((screen.height || jWin.height()) - h) / 2, 0);
        var f = $('<form>', {
            "id": "onHandler",
            "name": "onHandler",
            "method": (typeof (url) === "object") ? 'post' : 'get',
            "target": (target == undefined) ? onHandler : target
        });

        if (typeof (url) === "object") {
            $.each(url, function (key, value) { f.append($('<input name="' + key + '" id="' + key + '" type="hidden" value="' + value + '"/>')); });
            url = url.url;
        }
        var win;
        typeDownload = (/[.]/.exec(url)) ? /(.pdf|.html|.asp|.aspx)/.exec("." + /[^?]+/.exec(/[^.]+$/.exec(url))) ? false : true : false;
        f.attr('action', (url.indexOf('http://') > -1) ? url : MBOS.Path() + url);
        f.appendTo(document.body).submit(function () {
            var handler = (target == undefined) ? (onHandler == undefined) ? "onHandlerWindows" : onHandler : target;
            try {
                if (typeDownload) {
                    win = $('<iframe name="' +handler+'" id="' +handler+'" width="0" height="0" src="" frameborder="0"></iframe>');
                    win.appendTo(document.body);
                    setTimeout(function(){ win.remove(); }, 30000);
                } else {
                    if (target == undefined) {
                        win = window.open('about:blank', handler, 'toolbar=0,scrollbars=0,location=0,statusbar=0,menubar=0,resizable=1', true);
                        win.moveTo(x, y);
                        win.resizeTo(w, h);
                        win.document.title = "Please wait..."
                    }
                }
            } catch (err) { log(err); /*FIXED IE BROWSER*/ }
        }).submit().focus();

    },
    Cookie: function(k,v){
        if (typeof(v)=='undefined') {
            var c = document.cookie.split(';'), f = false; k += '=';
            for (i in c) { if (c[i].indexOf(k) > -1) { n = $.trim(c[i]).replace(k, ''); f = true; break; } }
            return (f) ? n : '';
        } else if (typeof(k)!='undefined' && k!='' && k!=null) {
            /*var d = new Date(), n = d.toString();*/
            document.cookie = k+"="+v+";path=/;"
        }
    },
    InitPermission: function(){
            
    }
}
$.extend($.fn, {
    MBOSCurrentMonthYear: function () {
        var today = new Date();
        var mm = today.getMonth() + 1;
        if (mm < 10) mm = '0' + mm;
        $(this).val(mm + '-' + today.getFullYear());
        return this;
    },
    MBOSCurrentDate: function () {
        var today = new Date();
        var dd = today.getDate();
        var mm = (today.getMonth() + 1);
        if (dd < 10) dd = '0' + dd;
        if (mm < 10) mm = '0' + mm;
        $(this).val(dd + '-' + mm + '-' + today.getFullYear());
        return this;
    },
    MBOSDateFirst: function (m) {
        var today = new Date();
        var mm = (today.getMonth() + 1) + (m || 0);
        if (mm < 10) mm = '0' + mm;
        $(this).val('01-' + mm + '-' + today.getFullYear());
        return this;
    },
    MBOSDateLast: function (m) {
        var today = new Date();
        var dd = new Date(today.getFullYear(), (today.getMonth() + 1) + (m || 0), 0);
        var mm = (today.getMonth() + 1) + (m || 0);
        if (mm < 10) mm = '0' + mm;
        $(this).val(dd.getDate() + '-' + mm + '-' + today.getFullYear());
        return this;
    },
    MBOSAjax: function (type, setting) {
        var e = this;
        var local = window.location;
        if (setting == undefined) { 
            setting = type; 
            type = 'JSON'; 
        }

        setting.when = setting.when || false; 
        if (typeof setting.url == 'undefined') {
            $(e).MBOSDialog('preload');
            setting.url = MBOS.Path().replace(/account|operation/g, "report_viewer") + "Default.aspx"
            type = 'JSON';
            if (local.href.indexOf("localhost") > -1) {
                setting.url = local.protocol + "//localhost:8026/Default.aspx";
                type = 'JSONP';
            }
        } else {
            setting.url = MBOS.Path() + setting.url;
        }

        $(this).data('MBOSAjax', $.ajax({
            type: 'POST', dataType: type,
            url: setting.url,
            data: setting.data,
            error: function (xhr, s, err) {
                if (setting.error != undefined) {
                    setting.error(xhr, s, err);
                } else if (setting.success == undefined && setting.error == undefined && setting.when == false) {
                    $(e).MBOSDialog('preload', { Param: "", exMessage: err, exTitle: "EXPORT" });
                }
            },
            success: function (data) {
                if (setting.success != undefined) {
                    setting.success(data);
                } else if (setting.success == undefined && setting.error == undefined && setting.when == false) {
                    try { if (type.toUpperCase() == 'JSONP') data = $.parseJSON(data); } catch (err) { data.param = ""; data.exMessage = data; }
                    if(data.getItems != undefined && data.getItems != "[]") data.param = data.getItems;
                    $(e).MBOSDialog('popup', data);
                }
                
                if(typeof setting.afterSuccess === "function") setting.afterSuccess(data);
            }
        }));
        return this;
    },
    MBOSDialog: function (setting, message) {
        var current = this;
        var path = MBOS.Path();
        var e = {
            Background: $(this).attr('id') + "_background",
            Frame: $(this).attr('id') + "_dialogframe",
            Content: $(this).attr('id') + "_dialogcontent",
            Close: $(this).attr('id') + "_dialogclose",
            Preload: $(this).attr('id') + "_dialogpreload",
            Process: $(this).attr('id') + "_dialogprocess",
            Title: $(this).attr('id') + "_processtitle",
            Description: $(this).attr('id') + "_processdescription",
            Confirm: $(this).attr('id') + "_actionconfirm",
            Cancel: $(this).attr('id') + "_actioncancel",
            Action: $(this).attr('id') + "_processaction",
            Main: $(this).attr('id') + "_dialog"
        }

        function ElementsFixed(e) {
            return (e == undefined) ? {
                Background: $('#' + $(current).attr('id') + "_background"), Frame: $('#' + $(current).attr('id') + "_dialogframe"),
                Content: $('#' + $(current).attr('id') + "_dialogcontent"), Close: $('#' + $(current).attr('id') + "_dialogclose"),
                Preload: $('#' + $(current).attr('id') + "_dialogpreload"), Process: $('#' + $(current).attr('id') + "_dialogprocess"),
                Title: $('#' + $(current).attr('id') + "_processtitle"), Description: $('#' + $(current).attr('id') + "_processdescription"),
                Confirm: $('#' + $(current).attr('id') + "_actionconfirm"), Cancel: $('#' + $(current).attr('id') + "_actioncancel"),
                Action: $('#' + $(current).attr('id') + "_processaction"), Main: $('#' + $(current).attr('id') + "_dialog")
            } : e;
        }

        if (typeof (setting) === "string") {
            e.Background = $('#' + e.Background);
            e.Frame = $('#' + e.Frame);
            e.Content = $('#' + e.Content);
            e.Close = $('#' + e.Close);
            e.Preload = $('#' + e.Preload);
            e.Process = $('#' + e.Process);
            e.Title = $('#' + e.Title);
            e.Description = $('#' + e.Description);
            e.Confirm = $('#' + e.Confirm);
            e.Cancel = $('#' + e.Cancel);
            e.Action = $('#' + e.Action);
            e.Main = $('#' + e.Main);
        }
        
        $(current).data('popup', function (setting, delay) {
            var Data = {
                color: "#f47735", background: "#232323", border: "", title: "ALERT BOX", beforetitle: "", aftertitle: "",
                description: "Message alert", icon: "", confirm: "", cancel: "",
                confirmHandler: function () { },
                cancelHandler: null,
                Close: function () {
                    if ($(current).data('MBOSAjax') != undefined) $(current).data('MBOSAjax').abort();
                    if (e.Frame.css('display') == 'block' || $(current).data('config').url === '') {
                        e.Process.fadeOut(200, function () { e.Frame.css({ 'z-index': 102 }); });
                        if ($(current).data('config').url === '') {
                            e.Background.fadeOut(100);
                            $('#MBOSEngineFrame').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'scroll');
                            $(document.body, 'html').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'scroll');
                        }
                    }
                }
            }
            var icon = {
                preload: path + 'img/dialog_preload.gif',
                success: path + 'img/dialog_icon_success.gif'
            }
            if (typeof (setting) == "object") $.extend(Data, setting);
            e.Frame.css({ 'z-index': 100 });

            e.Process.css({
                'background-color': Data.background,
                'background-image': (Data.icon == 'preload') ? 'url(\'' + icon.preload + '\')' : 'none',
                'background-repeat': 'no-repeat',
                'background-position': (($(window).outerWidth() / 2) - (e.Title.outerWidth() / 2) - 52) + 'px ' + ((e.Process.outerWidth() - e.Process.width()) / 2 + 5) + 'px',
                'border-top': ((Data.border != '') ? Data.border : 'transparent') + ' solid 4px',
                'border-bottom': ((Data.border != '') ? Data.border : 'transparent') + ' solid 4px'
            });
            e.Title.html('<span id="beforetext">' + Data.beforetitle + '</span><span id="titletext">' + Data.title + '</span><span id="aftertext">' + Data.aftertitle + '</span>');
            e.Title.find('#titletext').css({ 'color': (Data.color == Data.background) ? '#FFF' : Data.color });
            if (Data.description !== '') e.Description.html(Data.description); else e.Description.hide(0);

            e.Confirm.css('visibility', 'hidden');
            if (Data.confirm !== '' && Data.confirm !== null && Data.confirm !== undefined) {
                e.Confirm.css('visibility', 'visible');
                e.Confirm.unbind('click').click(function () {
                    if (Data.confirmHandler == null) { Data.Close(); } else { Data.confirmHandler(); }
                });
                e.Confirm.css({ 'background-color': Data.color }).html(Data.confirm);
                e.Confirm.hover(function () {
                    $(this).css({ 'background-color': '#FFF', 'color': Data.color });
                }, function () {
                    $(this).css({ 'background-color': Data.color, 'color': '#FFF' });
                });
            }

            e.Cancel.css('visibility', 'hidden');
            if (Data.cancel !== '' && Data.cancel !== null && Data.cancel !== undefined) {
                e.Cancel.css('visibility', 'visible');
                e.Cancel.unbind('click').click(function () {
                    if (Data.cancelHandler == null) { Data.Close(); } else { Data.cancelHandler(); }
                });
                e.Cancel.html(Data.cancel);
                e.Cancel.hover(function () { $(this).css({ 'color': Data.background }); }, function () { $(this).css({ 'color': '#FFF' }); });
            }
            
            
            if (typeof $(current).data('config') !== 'undefined') {
                if ($(current).data('config').url === '') {
                    $('#MBOSEngineFrame').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'hidden');
                    $(document.body, 'html').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'hidden');
                    e.Background.width($(window).width()).height($(window).height()).css('opacity', 0.06).fadeIn(100);
                }
                e.Process.delay((delay != undefined) ? delay : 0).fadeIn(200);
                $(window).resize();
            }

        });
        
        
        if (setting === 'opening') {
            $(current).data({ 'opening': true, 'opened': false });
            // if($(current).data('reload')) {   || MBOS.DEBUG
                e.Preload.fadeIn(0);
                e.Close.fadeOut(0);
                e.Content.empty();
                $('.message_preload_mini').html("PLEASE WAIT...");
            // }
            e.Content.fadeOut(0);
            $('#MBOSEngineFrame').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'hidden');
            $(document.body, 'html').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'hidden');
            e.Background.fadeOut(0);
            e.Background.width($(window).width()).height($(window).height()).css('opacity', 0.06);
            e.Frame.width($(window).width()).height($(window).height()).fadeIn(0);
            // Fixed Mobile Position
            e.Frame.css('position', (window.navigator.userAgent.indexOf("Windows")>-1)?'fixed':'absulute');
            e.Main.css({
                'border-left': '#63952e solid 4px',
                'border-right': '#63952e solid 4px',
                'left': ($(window).width() / 2) - (($(current).data('config').width + 8) / 2),
                'width': $(current).data('config').width,
                'height': $(window).height(),
                'display': ''
            }).fadeOut(0);
            e.Background.fadeIn(100, function () {
                e.Main.fadeIn(200, function () { $(window).resize(); });
            });
        } else if (setting === 'open') {
            /*if($(current).data('reload')) {  || MBOS.DEBUG */
                $(current).data('reload', false);
                $('.message_preload_mini').html("PLEASE WAIT...");
                $(current).data('MBOSAjax', $.ajax({
                    type: 'POST', dataType: 'HTML',
                    url: path + $(current).data('config').url,
                    data: $(current).data('config').data,
                    error: function (xhr, s, err) {
                        e.Main.css({ 'border-left': '#CB3232 solid 4px', 'border-right': '#CB3232 solid 4px' });
                        e.Content.empty().fadeIn(0);
                        e.Content.html("<b>" + err.name + "</b><br>" + err.message);
                        e.Content.append("<p>" + (err.stack || "").replace(/\n/g, "<br>").replace(/ /g, "&nbsp;") + "</p>");
                        $(current).data({ 'opening': false, 'opened': true });
                        $(window).resize();
                    },
                    success: function (data) {
                        var e = ElementsFixed(e);
                        e.Close.fadeIn(0);
                        e.Preload.fadeOut(0);
                        try {
                            try {
                                var err = $.parseJSON(data.replace(/\n/g, "").replace(/\r/g, "<br>").replace(/\\/g, "\\\\"));
                                if (err.exMessage != undefined) {
                                    e.Main.css({ 'border-left': '#CB3232 solid 4px', 'border-right': '#CB3232 solid 4px' });
                                    data = "<b>" + err.exFile + "</b><br>" + err.exMessage + "<p>" + err.exSource + "</p>";
                                }
                            } catch (er) { }
                            e.Content.html(data).fadeIn(200, function () { $(window).resize(); });
                        } catch (err) {
                            e.Main.css({ 'border-left': '#CB3232 solid 4px', 'border-right': '#CB3232 solid 4px' });
                            e.Content.empty().fadeIn(0);
                            if (err.message == 'Could not complete the operation due to error 80020101.') {
                                err.message = err.message + "<br>Please use \' Or \" in name in javascript Array key.";
                            }
                            e.Content.html("<b>" + err.name + "</b><br>" + err.message);
                            e.Content.append("<p>" + (err.stack || "").replace(/\n/g, "<br>").replace(/ /g, "&nbsp;") + "</p>");
                        }
                        $(current).data({ 'opening': false, 'opened': true });
                        $(window).resize();
                    }
                }));
            /*} else {
                var e = ElementsFixed(e);
                e.Content.fadeIn(200, function () { $(window).resize(); });
                $(current).data({ 'opening': false, 'opened': true });
                $(window).resize();
            } */
        } else if (setting === 'close') {
            if ($(current).data('opened') && !$(current).data('opening')) {
                e.Main.fadeOut(200, function () {
                    //vague.unblur();
                    $('#MBOSEngineFrame').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'scroll');
                    $(document.body, 'html').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'scroll');
                    e.Frame.fadeOut(200);
                    e.Process.fadeOut(200);
                    e.Background.fadeOut(200);
                });
            }
            $(current).data('opened', true);
        } else if (setting === 'preload') {
            var ObjData = {
                color: "#56bd12", background: "#232323", border: "",
                title: message != undefined ? (message.exTitle != undefined ? " " + message.exTitle : " EXPORT") : "EXPORT",
                aftertitle: " REPORT VIEWER", beforetitle: "", icon: (message == undefined) ? 'preload' : '',
                description: (message != undefined ? (message.exMessage == 'abort' ? "You has cancel the process." : message.exMessage) : "PLEASE WAIT..."), cancel: "Close",
                cancelHandler: function () {
                    this.Close();
                    e.Main.fadeIn(200);
                }
            }
            if ($(current).data('popup') != undefined) $(current).data('popup')(ObjData, 200);
            $(window).resize();
        } else if (setting === 'clear') {
            if (e.Frame.css('display') == 'block' || $(current).data('config').url === '') {
                e.Process.fadeOut(200, function () { e.Frame.css({ 'z-index': 102 }); });
                if ($(current).data('config').url === '') {
                    e.Background.fadeOut(100);
                    $('#MBOSEngineFrame').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'scroll');
                    $(document.body, 'html').css((MBOS.Browser.Chrome) ? 'overflow-y' : 'overflow', 'scroll');
                }
            }
        } else if (setting === 'popup') {
            if (typeof (message) === "object" && message.param != "") {
                var ObjData = {
                    color: "#f47735", background: "#232323", border: "",
                    title: message.title==undefined?"EXPORT ":message.title, beforetitle: "", aftertitle: message.title==undefined?" REPORT VIEWER":message.aftertitle,
                    description: (message.exMessage!= "" && message.exMessage!=null ) ? message.exMessage : (message.description!= "" && message.description!=null) ? message.description : "Success, If you want open report again click open.", 
                    confirm: (message.confirm==undefined && (message.exMessage=="" || message.exMessage==null))?"Open":message.confirm, 
                    cancel: (message.cancel==undefined)?"Close":message.cancel,
                    confirmHandler: function () {
                        try {
                            if (message.param !== "" && typeof (message.param) !== "undefined") { 
                                MBOS.Popup(message.param); 
                            } else { 
                                MBOS.Popup(message);
                            }
                            $(current).data({ 'opening': false });
                            e.Main.fadeIn(200);
                        } catch (err) {
                            $(current).MBOSDialog('preload', { Param: "", exMessage: err.message, exTitle: "ERROR" });
                        }
                    },
                    cancelHandler: function () {
                        e.Main.fadeIn(200);
                        $(current).data({ 'opening': false });
                        this.Close();
                    }
                }
                ObjData.confirmHandler();
                $(current).data('popup')(ObjData, 200);
            } else {
                $(current).MBOSDialog('preload', message);
            }
        } else if (setting === 'error') {
            var Data = {
                color: "#b51717", background: "#b51717", border: "",
                title: "Name", beforetitle: "Exception :: ", aftertitle: "",
                description: "Exception description", cancel: "Close"
            }
            if (typeof (message) == 'object') $.extend(Data, message);
            $(current).data('popup')(Data);
        } else if (setting === 'alert') {
            var Data = {
                color: "#f47735", background: "#232323", border: "",
                title: (message.ex == undefined) ? message.title.toUpperCase() : message.ex.exTitle.toUpperCase(), 
                beforetitle: (message.beforetitle == undefined) ? "": message.beforetitle, 
                aftertitle: (message.aftertitle == undefined) ? "": message.aftertitle, 
                description: (message.ex == undefined) ? message.description : message.ex.exMessage, 
                confirm: "", cancel: "Close"
            }

            if (typeof (message) == "function") Data.confirmHandler = message;
            $(current).data('popup')(Data);

        } else if (setting === 'confirm') {
            var Data = {
                color: "#f47735", background: "#232323", border: "",
                title: "Confirm ", beforetitle: "", aftertitle: "",
                description: "Do you want continus?", confirm: "OK", cancel: "Cancel"
            }

            if (typeof (message) == "object") Data = message;
            if (typeof (message) == "function") Data.confirmHandler = message;
            $(current).data('popup')(Data);
        } else if (setting === 'info' && typeof (message) == "object") {
            $(current).data({ 'opening': false });
            e.Process.fadeIn(200);
        } else if ($(current).length > 0) {
            $(current).data({ 'reload': true, 'config': { url: '', width: 500, closeHandler: null } });
            $.extend($(current).data('config'), setting);
            $('#' + e.Background).remove();
            $('#' + e.Process).remove();
            $('#' + e.Frame).remove();

            e.Background = $('<div>', { "id": e.Background, "class": "DialogBackground" });
            e.Frame = $('<div>', { "id": e.Frame, "class": "DialogFrame" });
            e.Main = $('<div>', { "id": e.Main, "class": "Dialog" });
            e.Content = $('<div>', { "id": e.Content, "class": "DialogContent" });
            e.Close = $('<div>', { "id": e.Close, "class": "DialogClose" });
            e.Preload = $('<div>', { "id": e.Preload, "class": "DialogPreload" });
            e.Process = $('<div>', { "id": e.Process, "class": "DialogProcess" });
            e.Title = $('<div>', { "id": e.Title, "class": "DialogTitle" });
            e.Description = $('<div>', { "id": e.Description, "class": "DialogDescription" });
            e.Confirm = $('<span>', { "id": e.Confirm, "class": "DialogConfirm" });
            e.Cancel = $('<span>', { "id": e.Cancel, "class": "DialogCancel" });
            e.Action = $('<div>', { "id": e.Action, "class": "DialogAction" });

            e.Background.appendTo(document.body);
            e.Frame.appendTo(document.body);
            e.Process.appendTo(document.body);

            e.Action.append(e.Confirm);
            e.Action.append(e.Cancel);
            e.Process.html('<center></center>');
            e.Process.children().append(e.Title);
            e.Process.children().append(e.Description);
            e.Process.children().append(e.Action);

            e.Main.append(e.Close.html('CLOSE'));
            e.Main.append(e.Content);
            e.Main.append(e.Preload.html('<div class="message_preload_mini">PLEASE WAIT...</div>'));
            e.Main.appendTo(e.Frame);

            

            // EVENT e.Main
            e.Frame.bind('mousewheel DOMMouseScroll', function (e) {
                var scrollTo = null;
                if (e.type == 'mousewheel') { scrollTo = (e.originalEvent.wheelDelta * -1); }
                else if (e.type == 'DOMMouseScroll') { scrollTo = 40 * e.originalEvent.detail; }
                if (scrollTo) $(this).scrollTop(scrollTo + $(this).scrollTop());
            });

            $(current).click(function () {
                var handler = $(current).data('config').openHandler;
                if (handler != undefined && typeof (handler) == 'function') {
                    handler();
                } else {
                    $(current).MBOSDialog('opening').MBOSDialog('open');
                }
            });
            
            e.Main.click(function () { $(current).data('opened', false); });
            
            e.Close.click(function () {
                var handler = $(current).data('config').closeHandler;
                if (typeof ($(current).data('config').closeHandler) == 'function' && $(current).data('opened') && !$(current).data('opening')) handler({ onClose: true }); else $(current).MBOSDialog('close');
            });

            e.Frame.click(function () {
                var handler = $(current).data('config').closeHandler;
                if (typeof ($(current).data('config').closeHandler) == 'function' && $(current).data('opened') && !$(current).data('opening')) handler({ onClose: false }); else $(current).MBOSDialog('close');
            });

            //dialogProcess.click(function(){ $(current).data('opened',false); });

            $(window).bind('resize', function () {
                //alert('w:'+$(window).height()+' > d:'+$('.DialogContent').height());
                var hDialog = ($(window).height() > (e.Content.outerHeight())) ? $(window).height() : '';
                e.Main.css({ 'left': ($(window).width() / 2) - (($(current).data('config').width + 8) / 2), 'width': $(current).data('config').width, 'height': hDialog })
                e.Process.css({
                    'top': ($(window).height() / 2) - (e.Process.outerHeight(true) / 2) - 30,
                    'width': ($(window).width() - (e.Process.outerWidth(true) - e.Process.width()))
                });
                e.Frame.width($(window).width()).height($(window).height());
                e.Background.width($(window).width()).height($(window).height());
            });
        }
        return this;
    },
    MBOSScrollLock: function () {
        $(this).bind('mousewheel DOMMouseScroll', function (e) {
            var scrollTo = null;
            if (e.type == 'mousewheel') { scrollTo = (e.originalEvent.wheelDelta * -1); }
            else if (e.type == 'DOMMouseScroll') { scrollTo = 40 * e.originalEvent.detail; }
            if (scrollTo) { e.preventDefault(); $(this).scrollTop(scrollTo + $(this).scrollTop()); }
        });
    },
    setDropdowList: function () {
        var dclass = "";
        if ($(this).attr("class") != undefined) {
            dclass = $(this).attr("class");
        }
        $.selecter("defaults", { customClass: dclass });
        $(this).selecter();
        return this;
    },
    toggleSlide: function (setting) {
        var config = {
            id: ''
        }
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
    }
});

var H2G = {
    postedData: function (xobj) {
        var retValue = ''
        $(xobj).each(function () {
            $.each(this.attributes, function () {
                // this.attributes is not a plain object, but an array
                // of attribute nodes, which contain both the name and value
                if (this.specified) {
                    if (!(this.name == 'name' || this.name == 'type' || this.name == 'id' || this.name == 'style')) {
                        retValue += '<input name="' + this.name + '" value="' + this.value + '" />';
                    }
                }
            });
        });
        return retValue;
    }
}