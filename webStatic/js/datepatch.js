/***********************************************************************
 Date prototype patch for additional usage.
 @author: INTER PLUG Corp.(Hiroyuki Nakatsuka)
 @version: 0.8
 @lastUpdate: 2015-09-20
 @extended members: ('Date' indicates static / 'date' indicates dynamic)
   Date.UNIT_* family :
     Constant like properties for the parameter named 'unit' of methods
     below.
   Date.LOCALE_DAYS_ABBR :
     Property for 'format' method. It declares local abbreviated texts
     of day in form of Array. You may customize this (default is JA-jp).
   Date.LOCALE_DAYS_FULL :
     Property for 'format' method. It declares local texts of day in
     form of Array. You may customize this (default is JA-jp).
   Date.LOCALE_MONTHS_ABBR :
     Property for 'format' method. It declares local abbreviated texts
     of month in form of Array. You may customize this
     (default is JA-jp).
   Date.LOCALE_MONTHS_FULL :
     Property for 'format' method. It declares local texts of month in
     form of Array. Youmay customize this (default is JA-jp).
   Date.isInteger(value) :
     This method judges that 'value' is integer or not.
   Date.parseISO(text) :
     This function returns Date instance from ISO-8601 text.
     Timezone is not supported.
   date.getDateOfYear() :
     Get decimal number of dates from 1st date of the current year.
   date.getWeekOfYear() :
     Get decimal number of weeks from 1st date of the current year.
   date.diff(dateInstance, unit) :
     Get decimal floored number of distance between this and comparable
     'dateInstance'. One of the Date.UNIT_* variables must be set into
     'unit' argument('UNIT_YEAR' and 'UNIT_MONTH' are not supported).
   date.add(distance, unit, minus) :
     This method updates this. 'distance' is integer value between this
     and expected date. 'unit' is 'Date.UNIT_* family'. 'minus' is
     optional parameter (default is 'undefined'). This parameter applies
     direction of addition.
   date.format(template) :
     This method return text replaced with rules. More information
     is rendered in console by run 'date.format();'.
***********************************************************************/

(function () {
	"use strict";
	//[begin] Static member.
	Date.UNIT_YEAR = "year";
	Date.UNIT_MONTH = "month";
	Date.UNIT_WEEK = "week";
	Date.UNIT_DATE = "date";
	Date.UNIT_HOUR = "hour";
	Date.UNIT_MINUTE = "minute";
	Date.UNIT_SECOND = "second";
	Date.LOCALE_DAYS_ABBR = ["日", "月", "火", "水", "木", "金", "土"];
	Date.LOCALE_DAYS_FULL = ["日曜日", "月曜日", "火曜日", "水曜日", "木曜日", "金曜日", "土曜日"];
	Date.LOCALE_MONTHS_ABBR = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];
	Date.LOCALE_MONTHS_FULL = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];
	Date.isInteger = function (value) {
		return typeof(value) === "number" && value % 1 == 0;
	};
	//[end] Static member.
	//[begin] Additional getter / setter functions.
	Date.prototype.getDateOfYear = function () {
		var tmp = new Date();
		tmp.setMonth(0);
		tmp.setDate(1);
		tmp.setHours(0);
		tmp.setMinutes(0);
		tmp.setSeconds(0);
		tmp.setMilliseconds(0);
		var dateDiff = (this.getTime() - tmp.getTime()) / (86400 * 1000);
		return dateDiff - (dateDiff % 1);
	};
	Date.prototype.getWeekOfYear = function () {
		var tmp = new Date();
		tmp.setMonth(0);
		tmp.setDate(1);
		tmp.setHours(0);
		tmp.setMinutes(0);
		tmp.setSeconds(0);
		tmp.setMilliseconds(0);
		return Math.floor(this.getDateOfYear() / 7 + (tmp.getDay() < this.getDay() ? 0 : 1));
	};
	//[end] Additional getter / setter functions.
	//[begin] Additional utility functions.
	Date.prototype.diff = function (dateInstance, unit) {
		var calcDict = {};
		calcDict[Date.UNIT_WEEK] = 1000 * 86400 * 7;
		calcDict[Date.UNIT_DATE] = 1000 * 86400;
		calcDict[Date.UNIT_HOUR] = 1000 * 3600;
		calcDict[Date.UNIT_MINUTE] = 1000 * 60;
		calcDict[Date.UNIT_SECOND] = 1000;
		if (dateInstance instanceof Date && calcDict[unit]) {
				return Math.floor((dateInstance.getTime() - this.getTime()) / calcDict[unit]);
		} else {
			throw new Error("One of the parameter is illegal.");
		}
	};
	Date.prototype.add = function (distance, unit, minus) {
		if (Date.isInteger(distance) &&
			[Date.UNIT_YEAR, Date.UNIT_MONTH, Date.UNIT_WEEK, Date.UNIT_DATE, Date.UNIT_HOUR, Date.UNIT_MINUTE, Date.UNIT_SECOND].indexOf(unit) > -1) {
			var calc, fin;// calc return milli-seconds
			switch (unit) {
				case Date.UNIT_YEAR:
					fin = function (value, self) {
						self.setFullYear(minus ? self.getFullYear() - value : self.getFullYear() + value);
					};
					break;
				case Date.UNIT_MONTH:
					fin = function(value, self) {
						self.setMonth(minus ? self.getMonth() - value : self.getMonth() + value);
					};
					break;
				case Date.UNIT_WEEK:
					calc = function (value) {
						return value * 7 * 86400 * 1000;
					};
					break;
				case Date.UNIT_DATE:
					calc = function (value) {
						return value * 86400 * 1000;
					};
					break;
				case Date.UNIT_HOUR:
					calc = function (value) {
						return value * 3600 * 1000;
					};
					break;
				case Date.UNIT_MINUTE:
					calc = function (value) {
						return value * 60 * 1000;
					};
					break;
				case Date.UNIT_SECOND:
					calc = function (value) {
						return value * 1000;
					};
					break;
				default:
					break;
			}
			if (calc) {
				this.setTime(minus ? this.getTime() - calc(distance) : this.getTime() + calc(distance));
			} else if (fin) {
				fin(distance, this);
			}
		} else {
			throw new Error("One of the parameter is invalid.");
		}
	};
	Date.prototype.format = function (template) {
		if (template) {
			var rules = [
				["%Y", String(this.getFullYear())],
				["%y", String(this.getFullYear()).substring(2, 4)],
				["%m", String(this.getMonth() + 101).substring(1, 3)],
				["%d", String(this.getDate() + 100).substring(1, 3)],
				["%H", String(this.getHours() + 100).substring(1, 3)],
				["%h", String(this.getHours())],
				["%I", String(this.getHours() % 12 + 100).substring(1, 3)],
				["%i", String(this.getHours() % 12)],
				["%M", String(this.getMinutes() + 100).substring(1, 3)],
				["%S", String(this.getSeconds() + 100).substring(1, 3)],
				["%p", this.getHours() < 12 ? "AM" : "PM"],
				["%w", String(this.getDay())],
				["%U", String(this.getWeekOfYear())],
				["%a", Date.LOCALE_DAYS_ABBR[this.getDay()]],
				["%A", Date.LOCALE_DAYS_FULL[this.getDay()]],
				["%b", Date.LOCALE_MONTHS_ABBR[this.getMonth()]],
				["%B", Date.LOCALE_MONTHS_FULL[this.getMonth()]],
				["%%", "%"],
			];
			var result = String(template);
			rules.map(function (item, idx, arr) {
				result = result.replace(item[0], item[1]);
			});
			return result;
		} else {
			if (window.console && window.console.error) {
				window.console.error([
					"The parameter 'template' accepts directives below:",
					"%Y: full year. ex.) 2015",
					"%y: lower 2 digits of year. ex.) 15",
					"%m: zero supressed month. ex.) 02",
					"%d: zero supressed date of the month. ex.) 05",
					"%H: zero supressed hour of the day. ex.)05",
					"%h: hour. ex.) 5",
					"%I: zero supressed hour (12-hour clock). ex.) 05",
					"%i: hour (12-hour clock). ex.) 5",
					"%M: zero supressed minute. ex.) 09",
					"%S: zero supressed second. ex.) 08",
					"%p: 'AM' or 'PM'",
					"%w: weekday as a decimal number. ex.) 6",
					"%U: zero supressed week of the year. ex.) 00",
					"%a: locale's abbreviated weekday name defined as 'Date.LOCALE_DAYS_ABBR'.",
					"%A: locale's full weekday name defined as 'Date.LOCALE_DAYS_FULL'.",
					"%b: locale's abbreviated month name defined as 'Date.LOCALE_MONTHS_ABBR'.",
					"%B: locale's full month name defined as 'Date.LOCALE_MONTHS_FULL.",
					"%%: escaped '%'.",
					"ex.) '%Y/%m/%d %H:%M:%S' -> '2015/10/15 22:04:23'",
				].join("\n  "));
			} else {
				throw new Error("Parameter 'template' must be set.");
			}
		}
	};
	Date.parseISO = function (text) {
		var result, tmp, ymd, hms, tz, flgError, flgStandard;
		result = new Date();
		result.setTime(0);
		result.setHours(0);
		tmp = text.split("T");
		if (tmp.length == 2) {
			ymd = tmp[0];
			hms = tmp[1];
		} else {
			flgError = true;
		}
		//[begin] year / month /date
		if (!flgError && ymd) {
			(function () {
				var rules = {
					"yyyymmdd": [/^([0-9]{4})([0-9]{2})([0-9]{2})$/, ["yyyy", "mm", "dd"]],
					"yyyy/mm/dd": [/^([0-9]{4})\-([0-9]{2})\-([0-9]{2})$/, ["yyyy", "mm", "dd"]],
					"yyyy-mm": [/^([0-9]{4})\-([0-9]{2})$/, ["yyyy", "mm"]],
					"yyyy": [/^([0-9]{4})$/, ["yyyy"]],
					"yyyy-ddd": [/^([0-9]{4})\-([0-9]{3})$/, ["yyyy", "ddd"]],
					"yyyyWwwd": [/^([0-9]{4})W([0-9]{2})([1-7])$/, ["yyyy", "ww", "d"]],
					"yyyy-Www-d": [/^([0-9]{4})\-W([0-9]{2})\-([1-7])$/, ["yyyy", "ww", "d"]]
				};
				var i, j, m, val;
				flgError = true;
				for (i in rules) {
					m = ymd.match(rules[i][0]);
					if (m) {
						flgError = false;
						m.shift();
						for (j = 0; j < m.length && !flgError; j++) {
							try {
								val = Number(m[j]);
							} catch (e) {
								flgError = true;
								break;
							}
							switch (rules[i][1][j]) {
								case "yyyy":
									result.setFullYear(val);
									break;
								case "mm":
									if (val > -1 && val < 13) {
										result.setMonth(val - 1);
									} else {
										flgError = true;
									}
									break;
								case "dd":
									if (val > 0 && val < 32) {
										result.setDate(val);
									} else {
										flgError = true;
									}
									break;
								case "ddd":
									if (val > 0 && val < 367) {
										result.setHours(val * 24);
									} else {
										flgError = true;
									}
									break;
								case "ww":
									if (val > 0 && val < 52) {
										if (result.getDay() < 4) {
											val = val - 1;
										}
										result.setHours((val - 1) * 7 * 24);
									} else {
										flgError = true;
									}
									break;
								case "d":
									if (val > 0 && val < 8) {
										while (result.getDay() != 0) {
											result.add(1, Date.UNIT_DATE, true);
										}
										result.add(val, Date.UNIT_DATE);
									} else {
										flgError = true;
									}
									break;
								default:
									flgError = true;
									break;
							}
						}
						break;
					}
				}
			})();
		}
		//[end] year / month / date
		//[begin] hour / minute / second
		if (hms) {
			tz = hms.split(/Z|\+|\-/);
			if (tz.length <= 2) {
				hms = tz[0]
			} else {
				flgError = true;
			}
		}
		if (!flgError && hms) {
			(function () {
				var rules = {
					"hh:mm:ss": [/^([0-9]{2}):([0-9]{2}):([0-9]{2}([.,][0-9]+)?)$/, ["HH", "MM", "SS", "__"]],
					"hh:mm": [/^([0-9]{2}):([0-9]{2}([.,][0-9]+)?)$/, ["HH", "MM", "__"]],
					"hh": [/^([0-9]{2}([.,][0-9]+)?)$/, ["HH", "__"]],
					"hhmmss": [/^([0-9]{2})([0-9]{2})([0-9]{2})$/, ["HH", "MM", "SS"]],
					"hhmm": [/^([0-9]{2})([0-9]{2})$/, ["HH", "MM"]]
				};
				var i, j, m;
				flgError = true;
				for (i in rules) {
					m = hms.match(rules[i][0]);
					if (m) {
						m.shift();
						flgError = false;
						var val, tmp;
						for (j = 0; j < m.length && !flgError; j++) {
							try {
								if (m[j]) {
									val = Number(m[j].replace(",", "."));
								} else {
									val = null;
									continue;
								}
							} catch (e) {
								flgError = true;
								break;
							}
							switch (rules[i][1][j]) {
								case "HH":
									if (val > -1 && val < 25) {
										if (!Date.isInteger(val)) {
											tmp = val - Math.floor(val);
											val = Math.floor(val);
										}
										result.add(val, Date.UNIT_HOUR);
										if (tmp) {
											result.setTime(result.getTime() + tmp * 3600 * 1000);
										}
									} else {
										flgError = true;
									}
									break;
								case "MM":
									if (val > -1 && val < 61) {
										if (!Date.isInteger(val)) {
											tmp = val - Math.floor(val);
											val = Math.floor(val);
										}
										result.add(val, Date.UNIT_MINUTE);
										if (tmp) {
											result.setTime(result.getTime() + tmp * 60 * 1000);
										}
									} else {
										flgError = true;
									}
									break;
								case "SS":
									if (val > -1 && val < 61) {
										if (!Date.isInteger(val)) {
											tmp = val - Math.floor(val);
											val = Math.floor(val);
										}
										result.add(val, Date.UNIT_SECOND);
										if (tmp) {
											result.setTime(result.getTime() + tmp * 1000);
										}
									} else {
										flgError = true;
									}
									break;
								case "__":
									//skip.
									break;
								default:
									flgError = true;
									break;
							}
						}
						break;
					}
				}
			})();
		}
		//[end] hour / minute / second
		//[begin] timezone
		// Not implemented.
		//[end] timezone
		if (flgError) {
			throw new Error("Illegal form.");
		} else {
			return result;
		} 
	};
	//[end] Additional utility functions.
}).call(this);

/*
hh:mm:ss
hh:mm
hh
*/