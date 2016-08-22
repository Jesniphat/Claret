(function ($) {
    $.widget("custom.combobox", {
        _create: function () {
            this.wrapper = $("<span>", { style: "padding: 0;" })
              .addClass("custom-combobox")
              .insertAfter(this.element);

            this.element.attr('combobox', 'Y').hide();
            this._createAutocomplete();
            this._createShowAllButton();
        },

        _createAutocomplete: function () {
            var selected = this.element.children(":selected"),
              value = selected.val() ? selected.text() : "";
            this.input = $("<input>", { class: this.element.attr("class"), placeholder: this.element.attr("placeholder") || "", tabindex: this.element.attr("tabindex") || "" })
              .appendTo(this.wrapper)
              .val(value)
              .attr("title", "")
              .addClass("custom-combobox-input ui-widget ui-widget-content ui-state-default ui-corner-left")
              .autocomplete({
                  delay: 0,
                  minLength: 0,
                  source: $.proxy(this, "_source")
              });

            this.input.css({ width: this.element.width() - 30 });

            this._on(this.input, {
                autocompleteselect: function (event, ui) {
                    ui.item.option.selected = true;
                    this._trigger("select", event, {
                        item: ui.item.option
                    });
                },

                autocompletechange: "_removeIfInvalid"
            });
        },

        _createShowAllButton: function () {
            var input = this.input,
              wasOpen = false;
            
            this.button = $("<a>", { class: this.element.attr("class") })
              .attr("tabIndex", -1)
              .attr("title", "Show All Items")
              .appendTo(this.wrapper)
              .button({
                  icons: {
                      primary: "ui-icon-triangle-1-s"
                  },
                  text: false
              })
              .removeClass("ui-corner-all")
              .addClass("custom-combobox-toggle ui-corner-right")
              .mousedown(function () {
                  wasOpen = input.autocomplete("widget").is(":visible");
              })
              .click(function () {
                  input.focus();

                  // Close if already visible
                  if (wasOpen) {
                      return;
                  }

                  // Pass empty string as value to search for, displaying all results
                  input.autocomplete("search", "");
              });
        },

        _source: function (request, response) {
            var matcher = new RegExp($.ui.autocomplete.escapeRegex(request.term), "i");
            response(this.element.children("option").map(function () {
                var text = $(this).text();
                if (this.value && (!request.term || matcher.test(text)))
                    return {
                        label: text,
                        value: text,
                        option: this
                    };
            }));
        },

        _removeIfInvalid: function (event, ui) {
            // Selected an item, nothing to do
            if (ui.item) {
                return;
            }

            // Search for a match (case-insensitive)
            var value = this.input.val(),
              valueLowerCase = value.toLowerCase(),
              valid = false;
            this.element.children("option").each(function () {
                if ($(this).text().toLowerCase() === valueLowerCase) {
                    this.selected = valid = true;
                    return false;
                }
            });

            // Found a match, nothing to do
            if (valid) {
                return;
            }

            // Remove invalid value
            this.input
              .val("")
              .attr("notiWarning", 'ไม่มี ' + value + ' ในตัวเลือก');
            this.element.val("");
            notiWarning(this.input.attr("notiWarning"));
            this.input.autocomplete("instance").term = "";
            this.input.focus();
        },
        disable: function () {
            this.input.prop('disabled',true);
            this.button.button({ disabled: true }).prop("disabled", true);
            this.input.autocomplete("disable");
        },
        enable: function() {
            this.input.prop('disabled',false);
            this.button.button({ disabled: false }).prop("disabled", false);
            this.input.autocomplete("enable");
        },
        setvalue: function (value) {
            this.element.val(value);

            var selected = this.element.children(":selected"),
                    value = selected.val() ? selected.text() : "";
            this.input.val(value);
        },
        _destroy: function () {
            this.wrapper.remove();
            this.element.show();
        },
    });

})(jQuery);

(function ($) {
    $.widget("custom.kaycomplete", $.ui.autocomplete, {
        _renderMenu: function (ul, items) {
            var that = this,
                currentCategory = "";
            $.each(items, function (index, item) {
                if (item.category != currentCategory) {
                    ul.append("<li class='ui-autocomplete-category'></li>");
                    currentCategory = item.category;
                }
                that._renderItemData(ul, item);
            });
        }
    });
})(jQuery)