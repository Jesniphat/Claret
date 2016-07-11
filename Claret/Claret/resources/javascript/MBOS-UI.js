var _TXTCOLOR = '#000000';
var _TXTCOLOR_FOCIN = '#CFCFCF';
var _TXTCOLOR_FOCOUT = '#C0C0C0';
var _TXTBORDER_FOCIN = '#63952E';
var _TXTBORDER_FOCOUT = '#C0C0C0';
var _TXTBORDER_ERROR = '#E02020';
var _TXTCOLOR_HIGHLIGHT = '#C7C7C7';

$.extend($.fn, {
    MBOSDatebox: function (pattern) {
        // Can't use date below 01-01-1900
        $(this).data('error', false);
        if (typeof (pattern) === 'undefined') pattern = "dd-MM-yyyy";
        $(this).attr('maxlength', '10').css({ 'text-align': 'center', 'color': (!MBOS.Browser.Chrome) ? _TXTCOLOR_FOCOUT : _TXTCOLOR });
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.altKey || keyCode == 8 || keyCode == 9 || keyCode == 46);
            var DateKey = (keyCode >= 48 && keyCode <= 57) || String.fromCharCode(keyCode) === '-';// || (e.keyCode>=96 && e.keyCode<=105); // (Number in Keyboard) || (Numpad)
            if (!DateKey && !OtherKey) { return false; } else { if ($(this).MBOSValue() === "") { $(this).css('color', _TXTCOLOR).val(''); } }
        });
        $(this).focusout(function (e) {
            if ($(this).MBOSValue() !== "") {
                $(this).val($(this).val().replace(/\W+/g, ''));
                $(this).next().remove();
                if (isDate($(this).val(), pattern.replace(/\W+/g, ''))) {
                    var isValue = new Date(getDateFromFormat($(this).val(), pattern.replace(/\W+/g, '')));
                    $(this).val(formatDate(isValue, pattern));
                } else if ($.trim($(this).val()) !== "") {
                    $(this).data('error', true).css({ 'border': _TXTBORDER_ERROR + ' solid 1px', 'color': _TXTBORDER_ERROR });
                }
            }
        });

        $(this).focusin(function (e) {
            $(this).data('error', false);
            if ($(this).MBOSValue() !== "") { $(this).val($(this).val().replace(/\W+/g, '')); }
        });

        $(this).MBOSInput();
        return this;
    },
    MBOSTimebox: function () {
        // Can't use date below 01-01-1900
        $(this).data('error', false);
        if (typeof (pattern) === 'undefined') pattern = "HH:mm";
        $(this).attr('maxlength', '5').css({ 'text-align': 'center', 'color': (!MBOS.Browser.Chrome) ? _TXTCOLOR_FOCOUT : _TXTCOLOR });
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.altKey || keyCode == 8 || keyCode == 9 || keyCode == 46);
            var DateKey = (keyCode >= 48 && keyCode <= 57) || String.fromCharCode(keyCode) === '-';// || (e.keyCode>=96 && e.keyCode<=105); // (Number in Keyboard) || (Numpad)
            if (!DateKey && !OtherKey) { return false; } else { if ($(this).MBOSValue() === "") { $(this).css('color', _TXTCOLOR).val(''); } }
        });
        $(this).focusout(function (e) {
            if ($(this).MBOSValue() !== "") {
                $(this).val($(this).val().replace(/\W+/g, ''));
                $(this).next().remove();
                if (isDate($(this).val(), pattern.replace(/\W+/g, ''))) {
                    var isValue = new Date(getDateFromFormat($(this).val(), pattern.replace(/\W+/g, '')));
                    $(this).val(formatDate(isValue, pattern));
                } else if ($.trim($(this).val()) !== "") {
                    $(this).data('error', true).css({ 'border': _TXTBORDER_ERROR + ' solid 1px', 'color': _TXTBORDER_ERROR });
                }
            }
        });

        $(this).focusin(function (e) {
            $(this).data('error', false);
            if ($(this).MBOSValue() !== "") { $(this).val($(this).val().replace(/\W+/g, '')); }
        });

        $(this).MBOSInput();
        return this;
    },
    MBOSMoneybox: function () {
        $(this).MBOSInput('right').css('text-align', 'right');

        $(this).val($(this).MBOSNumber());
        $(this).bind({
            keypress: function (e) {
                var keyCode = e.keyCode || e.which;
                var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
                var MinusKey = $(this)[0].selectionStart == 0 && $(this)[0].selectionEnd == 0;
                var OtherKey = (e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 46 || (MinusKey && keyCode == 45));
                var MoneyKey = (keyCode >= 48 && keyCode <= 57) || keyCode == 46;// || (e.keyCode>=96 && e.keyCode<=105); // (Number in Keyboard) || (Numpad)
                if (!MoneyKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).css('color', _TXTCOLOR).val(''); }
            },
            focusin: function (e) { $(this).val($(this).val().replace(/,/g, '')); },
            focusout: function (e) { $(this).val($(this).MBOSNumber()); }
        });

        return this;
    },
    MBOSCurrencybox: function () {
        $(this).MBOSInput('right').css('text-align', 'right');

        $(this).val($(this).MBOSCRate());
        $(this).bind({
            keypress: function (e) {
                var keyCode = e.keyCode || e.which;
                var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
                var MinusKey = $(this)[0].selectionStart == 0 && $(this)[0].selectionEnd == 0;
                var OtherKey = (e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 46 || (MinusKey && keyCode == 45));
                var MoneyKey = (keyCode >= 48 && keyCode <= 57) || keyCode == 46;
                if (!MoneyKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).css('color', _TXTCOLOR).val(''); }
            },
            focusin: function (e) { $(this).val($(this).val().replace(/,/g, '')); },
            focusout: function (e) { $(this).val($(this).MBOSCRate()); }
        });

        return this;
    },
    MBOSNumberbox: function () {
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 46);
            var NumKey = (keyCode >= 48 && keyCode <= 57);// || (e.keyCode>=96 && e.keyCode<=105); // (Number in Keyboard) || (Numpad)
            if (!NumKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).css('color', _TXTCOLOR).val(''); }
        });

        $(this).MBOSInput();
        return this;
    },
    MBOSStringbox: function () {
        $(this).keypress(function (e) {
            var keyCode = e.keyCode || e.which;
            var ValueNullKey = ($.trim($(this).val()) === $(this).attr('pretext')) || ($.trim($(this).val()) === "");
            var OtherKey = ((e.ctrlKey && keyCode != 86) || e.ctrlKey || e.altKey || keyCode == 8 || keyCode == 46);
            var StrKey = (keyCode >= 65 && keyCode <= 90) || (keyCode >= 97 && keyCode <= 122);// (Number in Keyboard) || (Numpad)
            if (!StrKey && !OtherKey) { return false; } else { if (ValueNullKey) $(this).css('color', _TXTCOLOR).val(''); }
        });

        $(this).MBOSInput();
        return this;
    },
    MBOSTextbox: function () {
        $(this).keypress(function (e) { if ($(this).MBOSValue() === '') $(this).css('color', _TXTCOLOR).val(''); });
        $(this).MBOSInput();
        return this;
    },
    MBOSUploadfile: function (events) {
        var w = $(this).outerWidth() + 'px', h = $(this).outerHeight() + 'px';
        var InputFile = $(this).css({ 'position': 'absolute', 'top': '0px', 'left': '0px', 'background-color': 'transparent' });
        var e = {
            Panel: InputFile.parent(),
            PanelButton: $('<div>', { 'id': InputFile.attr('id'), 'class': 'MBOSfileinput-button' }).css({ 'width': w, 'height': h }),
            PanelText: $('<span>', { 'class': 'MBOSfileinput-text fileinput-button' }).css({ 'width': w, 'height': h }).html('<span style="padding:' + parseInt((parseInt(h)-20)/2) + 'px;">' + InputFile.val() + '</span>'),
            PanelInput: $('<input>', { 'id': 'MBOSInputFile', 'name': 'MBOSInputFile', 'type': 'file' }),
            ProgressBlock: $('<div>', { 'class': 'MBOSfileinput-block' }).css({ 'width': w, 'height': h }),
            ProgressBar: $('<div>', { 'class': 'MBOSfileinput-bar' }).css({ 'width': '0px', 'height': h })
        }
        InputFile.remove();
        e.ProgressBar.appendTo(e.ProgressBlock);
        e.PanelText.append(e.PanelInput);
        e.PanelButton.append(e.ProgressBlock);
        e.PanelButton.append(e.PanelText);
        e.PanelButton.appendTo(e.Panel);

        e.PanelText.data('text', InputFile.val());
        e.PanelInput.fileupload({
            url: MBOS.Path() + events.url,
            dataType: 'json',
            formData: events.formData,
            maxFileSize: 1048576,
            send: function () {
                e.PanelInput.attr('disabled','disabled');
                e.ProgressBlock.css('background-color', '#e5e5e5'); //#6a717a
                e.ProgressBar.css({ 'width': '0px', 'background-color': '#80b745' });
                e.PanelText.children().first().html('0%');
                if (events.send != undefined) events.send();
            },
            done: function (element, data) {
                e.PanelInput.removeAttr('disabled');
                var span = e.PanelText.children().first();
                span.Reset = function () {
                    e.ProgressBlock.css('background-color', '#6a717a');
                    e.ProgressBar.css({ 'width': '0px', 'background-color': '#80b745' });
                    e.PanelText.children().first().html(e.PanelText.data('text'));
                }
                span.Fail = function(){ e.ProgressBar.css({ 'width': '100%', 'background-color': '#a51b1b' }); }
                span.Success = function(){ e.ProgressBar.css({ 'width': '100%', 'background-color': '#6a717a' }) }

                span.html('DONE');
                if (events.done != undefined) events.done(span, data._response.result);
            },
            progressall: function (element, data) {
                e.PanelInput.removeAttr('disabled');
                var progress = parseInt(data.loaded / data.total * 100, 10);
                e.ProgressBar.css('width', progress + '%')
                e.PanelText.children().first().html(progress + '%');
                
                if (progress == NaN) e.PanelText.children().first().html('ERROR');
                if (events.progressall != undefined) events.progressall(e.PanelText.children().first(), data);
            },
            fail: function () {
                e.PanelText.children().first().html('ERROR');
                e.ProgressBar.css({ 'width': '100%', 'background-color': '#a51b1b' });
                if (events.fail != undefined) events.fail(e.PanelText.children().first());
            }
        });
    },
    MBOSDropdown: function (setting) {
        var current = this;
        var Config = {
            url: typeof (setting) == 'string' ? setting : null,
            eValue: null,
            sql: null,
            lock: null,
            data: {},
            view: 10,
            height: 15,
            pendding: 2,
            margin: 2,
            reload: false,
            keypress: false,
            icon: true,
            selected: null,
            options: [],
            click: undefined, /* FUNCTION (data) { }*/
            over: undefined /* FUNCTION (data) { }*/
        }

        if (typeof (setting) == 'object') $.extend(Config, setting);
        if (typeof ($(this).data('sended')) === 'undefined') {

            var parent = $(this).parent(), id = $(this).attr('id');
            var AutoBox = $('<div>', { 'id': id + '_AutoComplate' }), InputBox = $('<div>', { 'class': 'input' }), DropdownBox = $('<div>', { 'class': id + '_MBOSDropdown' });
            var PanelDropdown = $('<div>', { 'class': 'MBOSList' }), ListDropdown = $('<div>', { 'class': id + '_MBOSList droplist' });

            var constConfig = {
                icon: function (x, y) {
                    var url = (Config.icon) ? ($(current).attr('disabled') == undefined) ? "#FFF url('//mos.travox.com/Resources/images/ui-dropdown.png') [#X#]px [#Y#]px no-repeat" : "#F9F9F9 none" : "#FFF none";
                    return url.replace('[#X#]', x).replace('[#Y#]', y);
                },
                preload: function (x, y) {
                    var url = (Config.icon) ? "#FFF url('//mos.travox.com/Resources/images/dialog/preload_mini2.gif') [#X#]px [#Y#]px no-repeat" : "#FFF none";
                    return url.replace('[#X#]', x).replace('[#Y#]', y);
                }
            }
            
            $(this).data({ 'sended': true, 'selected': false, 'stoped': false });
            $(parent).html(AutoBox.html(InputBox.append($(this)).append(DropdownBox)));

            if (!Config.keypress) $(current).val(Config.selected != null ? Config.selected : '');
            if (!Config.keypress) $(current).prop('readonly', true);
            
            function DefaultCSSPanelDropdown(){
                $(current).css({
                    'border': 'none',
                    'outline': 'none',
                    'padding': '0px',
                    'margin': '0px',
                    'cursor': Config.keypress ? 'text' : ($(current).attr('disabled') == undefined) ? 'pointer' : 'default',
                    'background': constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress ? 3 : -45))
                });
                
                AutoBox.css({ 'padding': Config.pendding + 'px', 'cursor': (Config.keypress) ? 'text' : 'pointer', 'display': 'inline-block' });
                AutoBox.css({ 'width': $(current).outerWidth() + (Config.icon ? 2 : 6), 'height': $(current).outerHeight() + (Config.icon ? 2 : 6) })
                InputBox.css({ 'border': _TXTBORDER_FOCOUT + ' solid 1px', 'position': 'absolute', 'z-index': 0 });

                DropdownBox.css({
                    'display': 'none',
                    'background-color': '#F7F7F7',
                    'width': $(current).outerWidth() + (Config.icon ? 0 : 4),
                    'height': '0px',
                    'cursor': 'default',
                    'overflow-y': 'hidden'
                });

                var data = [];
                setTimeout(function(){ 
                    InputBox.data('error', false);
                    $(current).data({ 'sended': true, 'stoped': false, 'text': Config.selected });
                    DropdownBox.empty();
                    $(current).data('last', Config.options.length);
                    PanelDropdown.css({
                        'text-align': 'left',
                        'height': Config.height,
                        'padding': (Config.pendding) + 'px ' + '0px ' + (Config.pendding) + 'px ' + (Config.pendding + 3) + 'px',
                        'overflow': 'hidden'
                    });
                    
                    for (var i = 0; i < Config.options.length; i++) { data[i] = { Title: Config.options[i], Value: Config.options[i] }; }
                    FillDataDropdown([ data ]);
                    if (Config.keypress) $(current).keydown(); else $(current).val(Config.selected != null ? Config.selected : '');
                    $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress ? 3 : -45)));
                    DropdownBox.css({ 'width': $(current).outerWidth() });
                }, 1);
            }
               
            function FillDataDropdown(data) {
                if (data[0].length != 0) {
                    $.each((data[1] || data[0]), function (index, e) {
                        var highlight = '<span style="background-color:' + _TXTCOLOR_HIGHLIGHT + ';">$&</span>';
                        var value = (Config.keypress ? data[0][index].Title.replace(new RegExp($(current).val(), 'gi'), highlight) : data[0][index].Title);
                        DropdownBox.append(PanelDropdown.html(value).attr('title', data[0][index].Title).clone().data('result', e)
                                   .addClass(Config.selected != null && Config.selected == data[0][index].Title ? 'MBOSListSelected' : '').on('click', function () {
                                       DropdownBox.data('click', true);
                                       $(current).data({ 'selected': true, 'ARROWEvent': false, 'value': data[0][index].Title });
                                        
                                       if (Config.keypress || typeof (Config.click) == 'function') Config.click(e, current); else $(current).val(data[0][index].Title);
                                   }).on('mouseover', function () {
                                       if (typeof (Config.over) == 'function') Config.over(this, e);
                                   })).css({
                                       'overflow-y': (Config.view < DropdownBox.children().length ? 'scroll' : 'hidden'),
                                       'height': PanelDropdownHeight * (Config.view > data[0].length && DropdownBox.children().length < Config.view ? data[0].length : Config.view)
                                   });
                    });
                }
            }


            function CloseAutoComplatePanel() {
                if ((DropdownBox.data('passed') || DropdownBox.data('click')) && $(current).data('sended')) {
                    DropdownBox.animate({ height: 0, 'margin-top': '0px' }, Config.keypress ? 100 : 0, function () {
                        $(this).css({ 'display': 'none' });
                        if (!InputBox.data('error')) {
                            $(current).parent().css({ 'border': _TXTBORDER_FOCOUT + ' solid 1px', 'z-index': 0 });
                            $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress) ? 3 : -45));
                        }
                    });
                    if (!InputBox.data('error')) $(current).parent().css({ 'z-index': 0 });
                }
                DropdownBox.data({ 'passed': true, 'click': false });
            }

            function RunAutoComplate() {
                if($(current).data('MBOSAjax') != undefined) $(current).data('MBOSAjax').abort();
                $(current).data({ 'last': 0, 'page': 1 });
                $(current).css('background', constConfig.preload($(current).outerWidth() - 16, 2));
                /* CASE MEMBER TRF */
                setting.data = setting.data || {};
                if (setting.data.selector != undefined) {
                    setting.data.selected = '';
                    $(setting.data.selector || {}).each(function (i, e) { setting.data.selected += ',' + $(e).val(); });
                }
                /* CASE MEMBER TRF */
                if (typeof (setting) == 'object') $.extend(Config, setting);
                if(Config.options.length == 0) {
                    $(current).MBOSAjax({
                        url: Config.url,
                        data: $.extend({
                            values: Config.keypress ? $(current).val() : "", values2: (Config.eValue != null) ? Config.eValue.val() : "",
                            sql: Config.sql, s: 1, f: (Config.view + 3)
                        }, Config.data),
                        error: function (state, err, s) {
                            if (s !== 'abort') InputBox.data('error', true).css({ 'border': _TXTBORDER_ERROR + ' solid 1px' });
                        },
                        success: function (data) {
                            InputBox.data('error', false);
                            $(current).data({ 'sended': true, 'stoped': false, 'text': $(current).val() });
                            DropdownBox.empty();
                            if (typeof (data.error) === "undefined") {
                                if (data[0].length != 0) {
                                    $(current).data('last', data[0].length);
                                    PanelDropdown.css('text-align', 'left');
                                    FillDataDropdown(data);
                                    if (Config.keypress) $(current).keydown(); else $(current).val(Config.selected != null ? Config.selected : '');
                                    $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress) ? -20 : -68));
                                } else {
                                    InputBox.data('error', true);
                                    $(current).css('background', '#FFF none');
                                    InputBox.css({ 'border': _TXTBORDER_ERROR + ' solid 1px' });
                                    DropdownBox.animate({ 'height': 0, 'margin-top': '0px' }, 0, function () { $(this).css({ 'display': 'none' }) });
                                }
                            } else {
                                InputBox.data('error', true);
                                $(current).css('background', '#FFF none');
                                InputBox.css({ 'border': _TXTBORDER_ERROR + ' solid 1px' });
                                DropdownBox.append(PanelDropdown.html(data.error).css({ 'text-align': 'left', 'height': 110 }).clone());
                            }
                        }
                    });
                }
                $(current).data({ 'text': $(current).val(), 'sended': false });
                PanelDropdown.css({
                    'height': Config.height,
                    'padding': (Config.pendding) + 'px ' + '0px ' + (Config.pendding) + 'px ' + (Config.pendding + 3) + 'px',
                    'overflow': 'hidden'
                });
                //if (DropdownBox.html() !== 'NONE') DropdownBox.html(Config.icon?"Loading...":"...").css('text-align', Config.icon?'center':'left');
                if (DropdownBox.html() !== '' && Config.icon) {
                    $(current).data({ 'sended': false, 'page': $(current).data('page') + 1 });
                }
            }

            var PanelDropdownHeight = Config.height + (Config.pendding * 2), DropdowHeight = PanelDropdownHeight * 1;

            DropdownBox.bind('keyup keydown', function () { return false; })
            $(this).keyup(function (e) {
                if ($(current).data('allow') && $(current).data('text') !== $(current).val()) $(this).keypress();
            });

            $(this).keydown(function (e) {
                DropdowHeight = PanelDropdownHeight * (Config.view > DropdownBox.children().length ? DropdownBox.children().length : Config.view);
                var keyCode = e.keyCode || e.which;
                var Key = { UP: false, DOWN: false };
                var NumView = parseInt(DropdowHeight / PanelDropdownHeight);
                switch (keyCode) {
                    case 13: // ENTER KEY
                    case 9: // TAB KEY
                        var getSelected = false;
                        DropdownBox.children().each(function (i, e) {
                            if ($(e).hasClass('MBOSListSelected')) {
                                getSelected = true;
                                if (Config.keypress || typeof (Config.click) == 'function') Config.click($(e).data('result')); else $(current).val($(e).html());
                                return false;
                            }
                        });

                        if (!getSelected) {
                            var getFirst = DropdownBox.children().first().addClass('MBOSListSelected');
                            if (Config.keypress || typeof (Config.click) == 'function') Config.click(getFirst.data('result')); else $(current).val($(getFirst).html());
                        }
                        if (Config.keypress) $(current).css('background-image', "none");
                        CloseAutoComplatePanel();
                        break;
                    case 38: // UP ARROW Key
                        if (!$(current).data('selected') && !$(current).data('ARROWEvent')) {
                            DropdownBox.scrollTop((DropdownBox.children().length - 2 - NumView) * PanelDropdownHeight);
                            DropdownBox.children().last().prev().prev().addClass('MBOSListSelected');
                        }
                        $(current).data('ARROWEvent', true);
                    case 40: // DOWN ARROW Key
                        if (!$(current).data('selected') && !$(current).data('ARROWEvent')) {
                            DropdownBox.children().first().addClass('MBOSListSelected');
                        }
                        $(current).data('ARROWEvent', true);

                        Key.UP = keyCode == 38 ? true : false;
                        Key.DOWN = keyCode == 40 ? true : false;
                        if ($(current).data('selected') && $(current).data('sended')) {
                            DropdownBox.children().each(function (i, e) {
                                if ($(e).hasClass('MBOSListSelected')) {
                                    if (Key.UP && i > 0) {
                                        $(e).removeClass('MBOSListSelected').prev().addClass('MBOSListSelected');
                                    } else if (Key.DOWN && i < (DropdownBox.children().length - 1)) {
                                        $(e).removeClass('MBOSListSelected').next().addClass('MBOSListSelected');
                                    } else if (Key.UP) {
                                        $(e).removeClass('MBOSListSelected');
                                        DropdownBox.children().last().addClass('MBOSListSelected');
                                    } else if (Key.DOWN) {
                                        $(e).removeClass('MBOSListSelected');
                                        DropdownBox.children().first().addClass('MBOSListSelected');
                                    }
                                    return false;
                                }
                            });
                        }
                    case -1: // UP&DOWN ARROW Event
                        var ResetSelected = true;
                        if ($(current).data('selected') && $(current).data('sended')) {
                            var TopIndex = Math.floor(DropdownBox.scrollTop() / PanelDropdownHeight), TotalItem = DropdownBox.children().length;
                            DropdownBox.children().each(function (i, e) {
                                if ($(e).hasClass('MBOSListSelected')) {
                                    ResetSelected = false;
                                    var RangeItem = (i - Config.view - TopIndex) + Config.view;
                                    if (RangeItem >= -1 && RangeItem <= Config.view) {
                                        if (RangeItem == Config.view && !Key.UP) {
                                            DropdownBox.scrollTop((TopIndex + 1) * PanelDropdownHeight);
                                        } else if (RangeItem == -1 && !Key.DOWN) {
                                            DropdownBox.scrollTop((TopIndex - 1) * PanelDropdownHeight);
                                        }
                                    } else if (i == (TotalItem - 1)) {
                                        DropdownBox.scrollTop((i - Config.view) * PanelDropdownHeight);
                                        $(e).removeClass('MBOSListSelected').prev().addClass('MBOSListSelected');
                                    } else {
                                        DropdownBox.scrollTop(i != 0 ? (i - (Key.DOWN ? Config.view - 1 : 0)) * PanelDropdownHeight : 0);
                                    }
                                    return false;
                                }
                            });
                        } else {
                            ResetSelected = false;
                        }
                        if (ResetSelected) DropdownBox.children().first().addClass('MBOSListSelected');
                        $(current).data('selected', true);
                        return false;
                        break;
                    default:
                        DropdownBox.css({ 'display': 'block' })
                        $(current).data('allow', (e.ctrlKey && (keyCode == 86 || keyCode == 88)) || keyCode == 8 || keyCode == 46);
                        if ($(current).data('allow') && $(current).data('text') !== $(current).val()) {
                            $(current).data('selected', false);
                        }

                        if ((DropdownBox.height() != DropdowHeight && DropdownBox.html() !== '' && !$(current).data('selected')) || !Config.keypress) {
                            DropdownBox.animate({ 'height': DropdowHeight, 'margin-top': '2px' }, Config.keypress ? 100 : 0);
                            AutoBox.css({ width: $(current).outerWidth() + 2, height: $(current).outerHeight() + 2 })
                            $(current).parent().css({ 'position': 'absolute', 'border': _TXTBORDER_FOCIN + ' solid 1px', 'z-index': 3 });
                            $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress) ? -20 : -68));
                        }
                        break;
                }
            });
            DropdownBox.scroll(function (e) {
                var percent = parseInt($(this).scrollTop() * 100 / ($(this).prop("scrollHeight") - $(this).height()));
                if (percent >= 100 && $(this).height() <= $(this).prop("scrollHeight") && $(current).data('sended') && !$(current).data('stoped')) {
                    $(current).css('background', constConfig.preload($(current).outerWidth() - 16, 2)).data({ 'sended': false, 'page': $(current).data('page') + 1 });
                    /* CASE MEMBER TRF */
                    setting.data = setting.data || {};
                    if (setting.data.selector != undefined) {
                        setting.data.selected = '';
                        $(setting.data.selector || {}).each(function (i, e) { setting.data.selected += ',' + $(e).val(); });
                    }
                    /* CASE MEMBER TRF */
                    if (typeof (setting) == 'object') $.extend(Config, setting);

                    $(current).MBOSAjax({
                        url: Config.url,
                        data: $.extend({
                            values: Config.keypress ? $(current).val() : "", values2: Config.eValue != null ? Config.eValue.val() : "", sql: Config.sql,
                            s: ($(current).data('last') * ($(current).data('page') - 1) + 1), f: ($(current).data('last') * $(current).data('page'))
                        }, Config.data),
                        error: function () { if (s !== 'abort') InputBox.data('error', true).css({ 'border': _TXTBORDER_ERROR + ' solid 1px' }); },
                        success: function (data) {
                            $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress) ? -20 : -68));
                            if (typeof (data.error) === "undefined") {
                                FillDataDropdown(data);
                                if (data[0].length == 0) $(current).data({ 'stoped': true });
                            }
                            $(current).data('sended', true);
                        }
                    });
                }
            });

            $(this).bind("keypress", function (e) {
                $(current).data({ 'selected': false, 'ARROWEvent': false });
                InputBox.css({ 'border': _TXTBORDER_FOCIN + ' solid 1px' });
                $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress) ? -20 : -68));
                if ($(current).MBOSValue() === '') $(current).css('color', _TXTCOLOR).val('');
                if ([8, 9, 13, 46].toString().indexOf(e.keyCode || e.which) == -1) setTimeout(RunAutoComplate, 1);
            });

            $(this).focusin(function (e) {
                $(current).parent().css({ 'position': 'absolute', 'z-index': 3 });
                if (!InputBox.data('error')) {
                    InputBox.css({ 'border': _TXTBORDER_FOCIN + ' solid 1px' });
                    $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress) ? -20 : -68));
                }
                if (($(this).MBOSValue() !== "" && DropdownBox.children().length > 0) || !Config.keypress) {
                    $(this).keydown();
                    if ($(current).data('selected') && !$(current).data('ARROWEvent')) {
                        DropdownBox.children().each(function (i, e) {
                            $(e).removeClass('MBOSListSelected');
                            if ($(current).val() == $(e).text()) $(e).addClass('MBOSListSelected');
                            $(e).html($(e).text());
                        });
                    }
                }
            });

            $(this).focusout(function (e) {
                if (!DropdownBox.data('passed') && !InputBox.data('error')) {
                    InputBox.css({ 'border': _TXTBORDER_FOCOUT + ' solid 1px' });
                    $(current).css('background', constConfig.icon($(current).outerWidth() - (Config.keypress ? 16 : 14), (Config.keypress) ? 3 : -45));
                }
            });
            DropdownBox.MBOSScrollLock();
            InputBox.click(function () {
                DropdownBox.data('passed', false);
                if (!Config.keypress && DropdownBox.children().length == 0 && $(current).attr('disabled') == undefined) {

                    $(current).css({
                        'background': constConfig.preload($(current).outerWidth() - 16, 2),
                        'cursor': Config.keypress ? 'text' : ($(current).attr('disabled') == undefined) ? 'pointer' : 'default'
                    }).data({ 'text': '', 'sended': true, 'selected': false });
                    $(current).data({ 'text': '', 'ARROWEvent': false, 'selected': true });
                    RunAutoComplate();
                }
            });

            $(document).click(CloseAutoComplatePanel);
            DefaultCSSPanelDropdown();
        }
        $(current).MBOSInput('left', false);
        return current;
    },
    MBOSNumber: function () {
        return (!isNaN($(this).val().toNumber()) ? $(this).val().toNumber() : 0).toMoney();
    },
    MBOSCRate: function () {
        return (!isNaN($(this).val().toRate()) ? $(this).val().toRate() : 0).toCRate();
    },
    MBOSValue: function (value, e) {
        if (value != undefined && value != null) {
            switch ($(this).prop('tagName')) {
                case 'INPUT':
                    var attrType = $(this).attr('type');
                    if (attrType == 'text') {
                        var pretext = $(this).attr('pretext') || '';
                        //$(this).css({ 'color': (pretext != '') ? _TXTCOLOR_FOCOUT : _TXTCOLOR, 'border-color': _TXTBORDER_FOCOUT });
                        $(this).val(value).css({ 'color': _TXTCOLOR }); // if (value != '')  && e != undefined
                        if (!MBOS.Browser.Chrome && value === '') $(this).val(pretext);
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
                        result = ($.trim($(this).val()) == $(this).attr('pretext') || $.trim($(this).val()) == '') ? '' : $(this).val();
                    } else if ($(this).attr('type') == 'radio') {
                        result = ($(this).prop('checked') == true || $(this).attr('checked') == 'checked') ? 'Y' : 'N';
                    }
                    break;
                case 'SELECT': result = $(this).val(); break;
                case 'TEXTAREA': result = $(this).val(); break;
                default: result = $(this).html(); break;
            }
            return result;
        }
    },
    MBOSAttr: function (name, value) {
        if (name != undefined && value == undefined) {
            return $(this).attr(name);
        } else if (value != undefined) {
            $(this).attr(name, value);
        } else {
            return $(this).attr('default-data');
        }
    },
    MBOSFill: function (e, attr) {
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
    IsMBOSNull: function () {
        var nNull = ($(this).attr('not-null') || '').toUpperCase();
        var nVal = $(this).MBOSValue();
        if ((nVal != '' && $(this).css('color') == 'rgb(224, 32, 32)') || (nVal == '' && (nNull == 'TRUE' || nNull == 'Y' || nNull == '1'))) {
            $(this).css('border-color', _TXTBORDER_ERROR);
            return true;
        } else {
            $(this).css('border-color', _TXTCOLOR_FOCOUT);
            return false;
        }
    },
    MBOSSelectRange: function (start, end) {
        return this.each(function () {
            if (this.setSelectionRange) {
                this.focus();
                this.setSelectionRange(start, end);
            } else if (this.createTextRange) {
                var range = this.createTextRange();
                range.collapse(true);
                range.moveEnd('character', end);
                range.moveStart('character', start);
                range.select();
            }
        });
    },
    MBOSScrollLock: function () {
        $(this).on('mousewheel DOMMouseScroll', function (e) {
            var scrollTo = (e.type == 'mousewheel') ? e.originalEvent.wheelDelta * -1 : (e.type == 'DOMMouseScroll') ? 40 * e.originalEvent.detail : null;
            if (scrollTo) { e.preventDefault(); $(this).scrollTop(scrollTo + $(this).scrollTop()); }
        });
    },
    MBOSInput: function (CursorLeft, InputStyle) {
        CursorLeft = (CursorLeft != undefined && CursorLeft != 'left') ? false : true;
        InputStyle = (InputStyle != undefined) ? InputStyle : true;

        var current = this;
        if (MBOS.Browser.Chrome) {
            $(this).attr('placeholder', $(this).attr('pretext'));
        } else {
            if ($(this).MBOSValue() === "") { $(this).val($(this).attr('pretext')); $(this).attr('value', $(this).attr('pretext')); }
        }
        $(this).css({
            'border': (InputStyle) ? _TXTBORDER_FOCOUT + ' solid 1px' : 'none',
            'backgound-color': (InputStyle) ? '#FFF' : 'transparent',
            'color': ($(this).MBOSValue() === "" && !MBOS.Browser.Chrome) ? _TXTCOLOR_FOCIN : _TXTCOLOR
        });

        $(this).focusin(function () {
            if (!$(this).data('error') || $(this).data('error') == undefined) {
                $(this).css({
                    'border': (InputStyle) ? _TXTBORDER_FOCIN + ' solid 1px' : 'none',
                    'backgound-color': (InputStyle) ? '#FFF' : 'transparent',
                    'color': ($(this).MBOSValue() === "" && !MBOS.Browser.Chrome) ? _TXTCOLOR_FOCIN : _TXTCOLOR
                });
            }
        });

        $(this).focusout(function () {
            if (!$(this).data('error') || $(this).data('error') == undefined) {
                $(this).css({
                    'border': (InputStyle) ? _TXTBORDER_FOCOUT + ' solid 1px' : 'none',
                    'backgound-color': (InputStyle) ? '#FFF' : 'transparent',
                    'color': ($(this).MBOSValue() == "" && !MBOS.Browser.Chrome) ? _TXTCOLOR_FOCOUT : _TXTCOLOR
                });
            }
        });

        $(this).keydown(function (e) {
            var keyCode = e.keyCode || e.which, KeepKey = [8, 9, 46, 32, 45];
            KeepKey = ((e.ctrlKey && (e.ctrlKey && keyCode != 86)) || e.altKey || KeepKey.toString().indexOf(keyCode) > -1 || (keyCode >= 35 && keyCode <= 40));
            // 8 = Backspace, 9 = Tab, 46 = Delete, 35 = Home, 36 = End, 37-40 = Arrow Key, 32 = Spacebar
            if ((e.ctrlKey && keyCode == 86) && $(this).MBOSValue() === '') $(this).val('').css({ 'color': _TXTCOLOR });
            if (KeepKey && $(this).MBOSValue() === "" && keyCode != 9) return false;
            setTimeout(function () {
                $(this).css({ 'color': ($(this).MBOSValue() === '' && !MBOS.Browser.Chrome) ? _TXTCOLOR_FOCIN : _TXTCOLOR });
                if (($.trim($(current).val()) === "")) {
                    if (!MBOS.Browser.Chrome) {
                        $(current).css('color', _TXTCOLOR_FOCOUT);
                        $(current).val($(current).attr('pretext'));
                        $(current).attr('value', $(current).attr('pretext'));
                        var position = (!CursorLeft) ? $.trim($(current).val()).length : 0;
                        $(current).MBOSSelectRange(position, position);
                    }

                    if (!KeepKey) return false;
                }
            }, 2);
        });

        $(this).bind('mousedown focusin', function () {
            if ($(this).MBOSValue() === "" && !MBOS.Browser.Chrome) {
                $(this).css('color', _TXTCOLOR_FOCIN);
                var position = (!CursorLeft) ? $.trim($(current).val()).length : 0;
                $(this).MBOSSelectRange(position, position);
                return false;
            } else {
                return true;
            }
        });

        return this;
    }
});