/* Array prototype patch for less than IE 8. */
(function () {
	"use strict";
	Array.prototype.indexOf = Array.prototype.indexOf || function (tgt, idx) {
		idx = idx || 0;
		while (idx < this.length) {
			if (this[idx] === tgt) {
				return idx;
			} else {
				idx += 1;
			}
		}
		return -1;
	};
	Array.prototype.map = Array.prototype.map || function(callback, thisArg) {
		var T, A, k;
		if (this == null) {
			throw new TypeError("this is null or not defined");
		}
		var O = Object(this);
		var len = O.length >>> 0;
		if ({}.toString.call(callback) != "[object Function]") {
			throw new TypeError(callback + " is not a function");
		}
		if (thisArg) {
			T = thisArg;
		}
		A = new Array(len);
		k = 0;
		while(k < len) {
			var kValue, mappedValue;
			if (k in O) {
				kValue = O[ k ];
				mappedValue = callback.call(T, kValue, k, O);
				A[ k ] = mappedValue;
			}
			k++;
		}
		return A;
	};
	Array.prototype.filter = Array.prototype.filter || function(fun) {
		if (this == null) throw new TypeError();
		var t = Object(this),
		len = t.length >>> 0;
		if (typeof fun != "function") throw new TypeError();
		var res = [],
		thisp = arguments[1];
		var i;
		for (i = 0; i < len; i++) {
			if (i in t) {
				var val = t[i];
				if (fun.call(thisp, val, i, t)) res.push(val);
			}
		}
		return res;
	};
}).call(this);