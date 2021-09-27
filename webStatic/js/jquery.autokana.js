// Generated by CoffeeScript 1.4.0
(function() {
  var AutoKana, global;

  global = Function('return this')();

  AutoKana = (function() {

    AutoKana.prototype.kana_extraction_pattern = new RegExp('[^ 　ぁあ-んー]', 'g');

    AutoKana.prototype.kana_compacting_pattern = new RegExp('[ぁぃぅぇぉっゃゅょ]', 'g');

    function AutoKana(element1, element2) {
      var defaultOptions;
      if (!element1.match(/^#/)) {
        element1 = '#' + element1;
      }
      if (!element2.match(/^#/)) {
        element2 = '#' + element2;
      }
      this.elName = $(element1);
      this.elKana = $(element2);
      defaultOptions = {
        build: true,
        katakana: false
      };
      this.options = $.extend(defaultOptions, arguments[2] || {});
      this.active = true;
      this._stateClear();
      this._build();
    }

    AutoKana.prototype.start = function() {
      this.active = true;
    };

    AutoKana.prototype.stop = function() {
      this.active = false;
    };

    AutoKana.prototype.toggle = function(event) {
      var el, ev;
      ev = event || window.event;
      if (event) {
        el = Event.element(event);
        if (el.checked) {
          this.active = true;
        } else {
          this.active = false;
        }
      } else {
        this.active = !this.active;
      }
    };

    AutoKana.prototype._addEvents = function() {
      var _this = this;
      this.elName.on('blur', function() {
        return _this._eventBlur(_this);
      });
      this.elName.on('focus', function() {
        return _this._eventFocus(_this);
      });
      this.elName.on('keydown', function() {
        return _this._eventKeyDown(_this);
      });
    };

    AutoKana.prototype._build = function() {
      if (this.options.build) {
        this._addEvents();
      }
    };

    AutoKana.prototype._checkConvert = function(new_values) {
      var tmp_values;
      if (!this.flagConvert) {
        if (Math.abs(this.values.length - new_values.length) > 1) {
          tmp_values = new_values.join('').replace(this.kana_compacting_pattern, '').split('');
          if (Math.abs(this.values.length - tmp_values.length) > 1) {
            this._stateConvert();
          }
        } else {
          if (this.values.length === this.input.length && this.values.join('') !== this.input) {
            this._stateConvert();
          }
        }
      }
    };

    AutoKana.prototype._checkValue = function() {
      var new_input, new_values;
      new_input = this.elName.val();
      if (new_input === '') {
        this._stateClear();
        this._setKana();
      } else {
        new_input = this._removeString(new_input);
        if (this.input === new_input) {
          return;
        } else {
          this.input = new_input;
          if (!this.flagConvert) {
            new_values = new_input.replace(this.kana_extraction_pattern, '').split('');
            this._checkConvert(new_values);
            this._setKana(new_values);
          }
        }
      }
    };

    AutoKana.prototype._clearInterval = function() {
      clearInterval(this.timer);
    };

    AutoKana.prototype._eventBlur = function(t) {
      t._clearInterval();
    };

    AutoKana.prototype._eventFocus = function(t) {
      t._stateInput();
      t._setInterval();
    };

    AutoKana.prototype._eventKeyDown = function(t) {
      if (t.flagConvert) {
        t._stateInput();
      }
    };

    AutoKana.prototype._isHiragana = function(char) {
      return (char >= 12353 && char <= 12435) || char === 12445 || char === 12446;
    };

    AutoKana.prototype._removeString = function(new_input) {
      var i, ignoreArray, inputArray, _i, _ref;
      if (new_input.match(this.ignoreString)) {
        return new_input.replace(this.ignoreString, '');
      } else {
        ignoreArray = this.ignoreString.split('');
        inputArray = new_input.split('');
        for (i = _i = 0, _ref = ignoreArray.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (ignoreArray[i] === inputArray[i]) {
            inputArray[i] = '';
          }
        }
        return inputArray.join('');
      }
    };

    AutoKana.prototype._setInterval = function() {
      var _this = this;
      this.timer = setInterval(function() {
        return _this._checkValue();
      }, 30);
    };

    AutoKana.prototype._setKana = function(new_values) {
      if (!this.flagConvert) {
        if (new_values) {
          this.values = new_values;
        }
        if (this.active) {
          this.elKana.val(this._toKatakana(this.baseKana + this.values.join('')));
        }
      }
    };

    AutoKana.prototype._stateClear = function() {
      this.baseKana = '';
      this.flagConvert = false;
      this.ignoreString = '';
      this.input = '';
      this.values = [];
    };

    AutoKana.prototype._stateInput = function() {
      this.baseKana = this.elKana.val();
      this.flagConvert = false;
      this.ignoreString = this.elName.val();
    };

    AutoKana.prototype._stateConvert = function() {
      this.baseKana = this.baseKana + this.values.join('');
      this.flagConvert = true;
      this.values = [];
    };

    AutoKana.prototype._toKatakana = function(src) {
      var c, i, str, _i, _ref;
      if (this.options.katakana) {
        str = new String;
        for (i = _i = 0, _ref = src.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          c = src.charCodeAt(i);
          if (this._isHiragana(c)) {
            str += String.fromCharCode(c + 96);
          } else {
            str += src.charAt(i);
          }
        }
        return str;
      } else {
        return src;
      }
    };

    return AutoKana;

  })();

  global.AutoKana = AutoKana;

}).call(this);
