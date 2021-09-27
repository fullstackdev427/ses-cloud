function genFilterQuery () {
	var queryObj = {};
	var tgtAttrName;
	$("[id^=query_]").each(function(idx, el) {
		if (el.id) {
			tgtAttrName = el.id.replace("query_", "");
			if (el.localName === "input" && el.type === "checkbox") {
				queryObj[tgtAttrName] = el.checked;
			} else {
				if (el.value !== "" && el.value !== "すべて") {
					queryObj[tgtAttrName] = tgtAttrName.indexOf("flg_") == 0 || tgtAttrName.indexOf("is_") == 0 ? Boolean(Number(el.value)) : el.value;
				}
			}
		}
	});
	return queryObj;
}

function genOrderQuery() {
	return {};
}

function deleteItems () {
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_client_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_worker_selected_cb_", "")));
		}
	});
	c4s.hdlClickDeleteItem("worker", id_list, true);
}

function selectAllItems () {
	var targets = $("input[type=checkbox][id^=iter_worker_selected_cb_]");
	targets.each(function (idx, el) {
		el.checked = true;
	});
}

// [begin] functions for modal.
function overwriteScheduleForEdit(obj, dateStr) {
	var tmpDtArr;
	if (!obj) {
		$("#input_schedule_title").replaceWith($("<h4 id='input_schedule_title'>スケジュール登録</h4>"));
		$("#input_0_id").val("");
		$("#input_0_dt_scheduled_date").val(dateStr);
		$("#input_0_dt_scheduled_hh")[0].selectedIndex = 0;
		$("#input_0_dt_scheduled_mm")[0].selectedIndex = 0;
		$("#input_0_title").val("");
		$("#input_0_note").val("");
	} else {
		tmpDtArr = obj.dt_scheduled.split(" ");
		$("#input_schedule_title").replaceWith($("<h4 id='input_schedule_title'>スケジュール更新</h4>"));
		$("#input_0_id").val(obj.id);
		$("#input_0_dt_scheduled_date").val(tmpDtArr[0]);
		$("#input_0_dt_scheduled_hh").val(tmpDtArr[1].split(":")[0]);
		$("#input_0_dt_scheduled_mm").val(tmpDtArr[1].split(":")[1]);
		$("#input_0_title").val(obj.title);
		$("#input_0_note").val(obj.note);
	}
	$("#input_schedule_container")[0].style.display = "block";
}

function genScheduleValue() {
	var reqObj = {};
	var textSymbols = [
		["id", "#input_0_id", Number, null],
		["title", "#input_0_title", String],
		["note", "#input_0_note", String],
	];
	var checkSymbols = [];
	var comboSymbols = [];
	var i;
	var tgtVal;
	for (i = 0; i < textSymbols.length; i++) {
		tgtVal = $(textSymbols[i][1]).val();
		if (tgtVal) {
			reqObj[textSymbols[i][0]] = textSymbols[i][2](tgtVal);
		} else if (textSymbols[i].length == 4) {
			reqObj[textSymbols[i][0]] = textSymbols[i][3];
		}
	}
	for (i = 0; i < checkSymbols.length; i++) {
		tgtVal = $(checkSymbols[i][1])[0].checked;
		reqObj[checkSymbols[i][0]] = tgtVal;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		tgtVal = $(comboSymbols[i][1]).val();
		reqObj[comboSymbols[i][0]] = tgtVal;
	}
	var schedule_dt = $("#input_0_dt_scheduled_date").val();
	schedule_dt += " " + $("#input_0_dt_scheduled_hh").val();
	schedule_dt += ":" + $("#input_0_dt_scheduled_mm").val() + ":00";
	reqObj.dt_scheduled = schedule_dt;
	return reqObj;
}

function updateObj() {
	var reqBody = genScheduleValue();
	reqBody.id = Number($("#input_0_id").val());
	c4s.invokeApi_ex({
		location: "misc.updateSchedule",
		body: reqBody,
		onSuccess: function (data) {
			alert("1件更新しました");
			c4s.invokeApi_ex({
				location: "misc.scheduleTop",
				body: env.recentQuery,
				pageMove: true,
			});
		},
		onError: function (data) {
			alert("更新に失敗しました");
		},
	});
}

function createObj() {
	var reqObj = genScheduleValue();
	c4s.invokeApi_ex({
		location: "misc.createSchedule",
		body: reqObj,
		onSuccess: function (data) {
			alert("1件登録しました");
			c4s.invokeApi_ex({
				location: "misc.scheduleTop",
				body: env.recentQuery,
				pageMove: true,
			});
		},
		onError: function (data) {
			alert("登録に失敗しました");
		},
	});
}
// [end] functions for modal.

// [begin] page jump functions.
function jumpToSchedulePage(distance) {
	c4s.invokeApi_ex({
		location: "misc.scheduleTop",
		body: {week: distance + (env.recentQuery.week != undefined ? env.recentQuery.week : 0)},
		pageMove: true,
	});
}
// [end] page jump functions.

// [begin] onload function.
if (env.recentQuery.id) {
	overwriteWorkerModalForEdit(env.recentQuery.id);
}

$("tr[id^=account_schedule_]").each(function (idx, el) {
	if (el.id === "account_schedule_" + env.userInfo.id) {
		el.style.display = "table-row";
	} else {
		el.style.display = "none";
	}
});

$("#queue_acl_filter").on("change", function(evt) {
	var accId = $("#queue_acl_filter").val().split("_")[4];
	if (accId === "group") {
		$("#week-control")[0].style.display = "none";
		$("#group_header")[0].style.display = "table-row";
		$("#account_header")[0].style.display = "none";
		$("#input_schedule_container")[0].style.display = "none";
	} else {
		$("#week-control")[0].style.display = "block";
		$("#group_header")[0].style.display = "none";
		$("#account_header")[0].style.display = "table-row";
	}
	$("tr[id^=account_schedule_]").each(function (idx, el) {
		if (el.id === "account_schedule_" + accId) {
			$(el).css("display", "table-row");
		} else {
			$(el).css("display", "none");
		}
	});
});

$("#input_0_dt_scheduled_date").datepicker({
	weekStart: 1,
	viewMode: "dates",
	language: "ja",
	autoclose: true,
	changeYear: true,
	changeMonth: true,
	dateFormat: "yyyy/mm/dd",
});

$(document).ready(function () {
	c4s.invokeApi_ex({
		location: "misc.enumSchedules",
		body: env.recentQuery,
		onSuccess: function (data) {
			var tmp = {};
			var i;
			for (i = 0;i < data.data.length; i++) {
				tmp[data.data[i].id] = data.data[i];
			}
			env.data = env.data || {};
			env.data.schedules = tmp;
		},
	});
});
// [end] onload function.