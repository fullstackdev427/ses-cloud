/* Initial. */
// [begin] Support handler for preparation modal.
/*
c4s.invokeApi_ex({
	location: "client.enumClients",
	body: {},
	async : true,
	onSuccess: function (res) {
		env.data.clients = res.data;
		$("#input_1_client_name").autocomplete({
			source: env.data.clients.map(function (val, idx, arr) {
				return {label: val.name, id: val.id};
			}),
			select: function (evt, item) {
				window.console ? window.console.log(item) : null;
				if (item.item) {
					$("#input_1_client_id").val(item.item.id);
				} else {
					$("#input_1_client_id").val(null);
				}
			},
		});
	},
});
*/
// [end] Support handler for preparation modal.

$(document).ready(function() {
	env = env || {};
	env.data = env.data || {};
	env.ak_client = new AutoKana("new_client_name", "new_client_kana", {katakana: true});
	$("#new_client_name").on("blur", function (evt) {
		$("#new_client_kana").val($("#new_client_kana").val().replace("カブシキガイシャ", "").replace("ユウゲンガイシャ", "").replace("ゴウドウガイシャ", ""));
	});

	// [begin] Common modal handlers.
	$("#edit_engineer_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_project_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_engineer_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	$("#edit_preparation_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	$("#edit_project_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	env.ak_client = new AutoKana("m_client_name", "m_client_kana", {katakana: true});
	env.ak_worker = new AutoKana("ms_worker_name", "ms_worker_kana", {katakana: true});
	$("#m_client_name").on("blur", function (evt) {
		$("#m_client_kana").val($("#m_client_kana").val().replace("カブシキガイシャ", "").replace("ユウゲンガイシャ", "").replace("ゴウドウガイシャ", ""));
	});
	$("#edit_client_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_branch_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_contact_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_worker_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_client_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	$("#edit_contact_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	// [end] Common modal handlers.
	// [begin] Support handler for engineer modal.
	$("#m_engineer_birth").datepicker({
		weekStart: 1,
		language: "ja",
		autoclose: true,
		changeYear: true,
		changeMonth: true,
		dateFormat: "yyyy/mm/dd",
	});
	$("#m_engineer_birth").datepicker("setDate", "-30y");
	$("#m_engineer_birth").on("hide", function() {
		updateAge();
	});
	env.ak_client = new AutoKana("m_engineer_name", "m_engineer_kana", {katakana: true});
	// [end] Support handler for engineer modal.
	// [begin] Support handler for project modal.
	// written on template.
	// [end] Support handler for project modal.
});

/* Home interaction functions. */

var skill_id_list;
var skill_level_list;

//[begin] Functions for engineer modal.
function hdlClickNewEngineerObj () {
	c4s.clearValidate({
			"client_id": "m_engineer_client_id",
			"client_name": "m_engineer_client_name",
			"name": "m_engineer_name",
			"kana": "m_engineer_kana",
			"visible_name": "m_engineer_visible_name",
			"tel": "m_engineer_tel",
			"mail1": "m_engineer_mail1",
			"mail2": "m_engineer_mail2",
			"birth": "m_engineer_birth",
			"gender": "m_engineer_gender_container",
			"state_work": "m_engineer_state_work",
			"age": "m_engineer_age",
			"fee": "m_engineer_fee",
			"station": "m_engineer_station",
			"skill": "m_engineer_skill",
			"note": "m_engineer_note",
			"internal_note": "m_engineer_internal_note",
			"charging_user_id": "m_engineer_charging_user_id",
			"employer": "m_engineer_employer",
			"operation_begin": "m_engineer_operation_begin",
			// "addr_vip": "m_engineer_addr_vip",
			// "addr1": "m_engineer_addr1",
			// "addr2": "m_engineer_addr2",
		});
	// [begin] Clear fields.
	var textSymbols = [
		"#m_engineer_client_id",
		"#m_engineer_client_name",
		"#m_engineer_name",
		"#m_engineer_kana",
		"#m_engineer_visible_name",
		"#m_engineer_tel",
		"#m_engineer_mail1",
		"#m_engineer_mail2",
		"#m_engineer_birth",
		"#m_engineer_age",
		"#m_engineer_fee",
		"#m_engineer_station",
		"#m_engineer_state_work",
		"#m_engineer_employer",
		/*
		"#m_engineer_dt_assignable",
		*/
		"#m_engineer_note",
		"#m_engineer_internal_note",
		"#attachment_id_0",
		"#attachment_label_0",
		"#m_engineer_skill",
		"#m_engineer_operation_begin",
		"#m_engineer_station_cd",
		"#m_engineer_station_pref_cd",
		"#m_engineer_station_line_cd",
		"#m_engineer_station_lon",
		"#m_engineer_station_lat",
		// "#m_engineer_addr_vip",
		// "#m_engineer_addr1",
		// "#m_engineer_addr2",
	];
	var checkSymbols = [
		"#m_engineer_flg_caution",
		"#m_engineer_flg_registered",
		"#m_engineer_flg_assignable",
		"#m_engineer_flg_public",
		"#m_engineer_web_public",
		"#m_engineer_flg_careful",
	];
	var comboSymbols = [
		"#m_engineer_contract",
	];
	var radioSymbols = [
		"[name=m_engineer_gender_grp]",
	];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		$(textSymbols[i]).val(null);
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = false;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$("#m_engineer_id").val(null);
	$("#m_engineer_flg_registered")[0].checked = true;
	$("#m_engineer_flg_assignable")[0].checked = true;
	$("#m_engineer_flg_public")[0].checked = false;
	$("#m_engineer_web_public")[0].checked = false;
	$("#m_engineer_flg_careful")[0].checked = false;
	$("#m_engineer_charging_user_id").val(env.userInfo.id);
	$('[name="m_engineer_skill_level[]"]').each(function (idx, el) {
		el.selectedIndex = 0;
	});
	$('[name="m_engineer_skill[]"]').each(function (idx, el) {
		el.checked = false;
	});
	viewSelectedEngineerSkill();
	$('[name="m_engineer_occupation[]"]').each(function (idx, el) {
		el.checked = false;
	});
	// [end] Clear fields.
	setEngineerMenuItem(0, 0, null, null);
	$("#es").val(0);
	$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>新規要員登録</span>"));
	deleteEngineerAttachment(0);
	$("#edit_engineer_modal").modal("show");
	$('#m_engineer_client_id').select2({allowClear: true});
	$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),PHP(1年～2年)</span>");
	$('#m_skill_sort')[0].checked = false
	skill_id_list = '';
	skill_level_list = [];
}

function overwriteModalForEditEngineer(objId) {
	c4s.clearValidate({
		"client_id": "m_engineer_client_id",
		"client_name": "m_engineer_client_name",
		"name": "m_engineer_name",
		"kana": "m_engineer_kana",
		"visible_name": "m_engineer_visible_name",
		"tel": "m_engineer_tel",
		"mail1": "m_engineer_mail1",
		"mail2": "m_engineer_mail2",
		"birth": "m_engineer_birth",
		"age": "m_engineer_age",
		"gender": "m_engineer_gender_container",
		"state_work": "m_engineer_state_work",
		"fee": "m_engineer_fee",
		"station": "m_engineer_station",
		"skill": "m_engineer_skill",
		"note": "m_engineer_note",
		"internal_note": "m_engineer_internal_note",
		"charging_user_id": "m_engineer_charging_user_id",
		"employer": "m_engineer_employer",
		"operation_begin": "m_engineer_operation_begin",
		// "addr_vip": "m_engineer_addr_vip",
		// "addr1": "m_engineer_addr1",
		// "addr2": "m_engineer_addr2",

	});
	var textSymbols = [
		["id", "#m_engineer_id"],
		["client_name", "#m_engineer_client_name"],
		["name", "#m_engineer_name"],
		["kana", "#m_engineer_kana"],
		["visible_name", "#m_engineer_visible_name"],
		["tel", "#m_engineer_tel"],
		["mail1", "#m_engineer_mail1"],
		["mail2", "#m_engineer_mail2"],
		["age", "#m_engineer_age"],
		["fee_comma", "#m_engineer_fee"],
		["station", "#m_engineer_station"],
		["note", "#m_engineer_note"],
		//["internal_note", "#m_engineer_internal_note"],
		["skill", "#m_engineer_skill"],
		["state_work", "#m_engineer_state_work"],
		["employer", "#m_engineer_employer"],
		["operation_begin", "#m_engineer_operation_begin"],
		["station_cd", "#m_engineer_station_cd"],
		["station_pref_cd", "#m_engineer_station_pref_cd"],
		["station_line_cd", "#m_engineer_station_line_cd"],
		["station_lon", "#m_engineer_station_lon"],
		["station_lat", "#m_engineer_station_lat"],
		// ["addr_vip", "#m_engineer_addr_vip"],
		// ["addr1", "#m_engineer_addr1"],
		// ["addr2", "#m_engineer_addr2"],

	];
	var datepickerSymbols = [
		["birth", "#m_engineer_birth"],
	];
	var checkSymbols = [
		["flg_caution", "#m_engineer_flg_caution"],
		["flg_registered", "#m_engineer_flg_registered"],
		["flg_assignable", "#m_engineer_flg_assignable"],
		["flg_public", "#m_engineer_flg_public"],
		//["web_public", "#m_engineer_web_public"],
		["flg_careful", "#m_engineer_flg_careful"],
	];
	var comboSymbols = [
		["contract", "#m_engineer_contract"],
		["client_id", "#m_engineer_client_id"],
	];
	var radioSymbols = [
		["gender", "[name=m_engineer_gender_grp]"],
	];
	$('#m_skill_sort').prop('checked', false); alert(objId);
	c4s.invokeApi("engineer.enumEngineers", {id: Number(objId)}, function (data) {
		env.recentAjaxResult = data;
		if (data && data.status && data.data
			&& data.status.code == 0
			&& data.data instanceof Array && data.data[0]) {
			var i;
			var tmpEl;
			var tgtData = data.data[0];
			for (i = 0; i < textSymbols.length; i++) {
				if (tgtData[textSymbols[i][0]]) {
					$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]];
				} else {
					$(textSymbols[i][1]).val("");
				}
			}
			for (i = 0; i < datepickerSymbols.length; i++) {
				if (tgtData[datepickerSymbols[i][0]]) {
					$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
				} else {
					$(datepickerSymbols[i][1]).val(null);
				}
			}
			for (i = 0; i < checkSymbols.length; i++) {
				$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
			}
			for (i = 0; i < comboSymbols.length; i++) {
				$(comboSymbols[i][1])[0].selectedIndex = 0;
				$(comboSymbols[i][1])[0].value = tgtData[comboSymbols[i][0]];
			}
			for (i = 0; i < radioSymbols.length; i++) {
				$(radioSymbols[i][1]).each(function (idx, el) {
					if (el.value === tgtData[radioSymbols[i][0]]) {
						el.checked = true;
					}
				});
			}
			if (tgtData.charging_user && tgtData.charging_user.id) {
				$("#m_engineer_charging_user_id").val(tgtData.charging_user.id);
			}
			$("input[type=checkbox][id^=m_engineer_skill_]").each(function (idx, el) {
				if (tgtSkillDict[el.id.replace("m_engineer_skill_", "")]) {
					el.checked = true;
				} else {
					el.checked = false;
				}
			})
			$('[name="m_engineer_skill[]"]').each(function (idx, el) {
				el.checked = false;
			});
			$('[name="m_engineer_skill_level[]"]').each(function (idx, el) {
				el.selectedIndex = 0;
			});
			$('[name="m_engineer_skill_level[]"]').addClass("hidden");
			$('[name="m_engineer_occupation[]"]').each(function (idx, el) {
				el.checked = false;
			});

			if(tgtData.skill_id_list){
				skill_id_list = tgtData.skill_id_list;
				skill_level_list = tgtData.skill_level_list;
				$('[name="m_engineer_skill[]"]').each(function (index) {
                    var setval = $(this).val();
                    var skillArr = tgtData.skill_id_list.split(",");
                    if (skillArr.indexOf(setval) >= 0) {
							$(this).val([setval]);
							$('#m_engineer_skill_level_' + setval).removeClass("hidden");
							tgtData.skill_level_list.forEach(function(e, i, a) {
								if(setval == e["skill_id"]){
									$("#m_engineer_skill_level_" + setval).val(e["level"]);
								}
							})
                    }
                });
			}
			viewSelectedEngineerSkill();
			if(tgtData.occupation_id_list){
				$('[name="m_engineer_occupation[]"]').each(function (index) {
                    var setval = $(this).val();
                    var occupationArr = tgtData.occupation_id_list.split(",");
                    if (occupationArr.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
			}
			!tgtData.age ? updateAge() : void(0);
			$("#attachment_id_0").val(tgtData.attachement && tgtData.attachement['id'] ? tgtData.attachement.id : null);
			var fileInputEl = $("#attachment_file_0");
			var fileIdEl = $("#attachment_id_0");
			var labelEl = $("#attachment_label_0");
			var commitBtnEl = $("#attachment_btn_commit_0");
			var deleteBtnEl = $("#attachment_btn_delete_0");
			if (tgtData.attachement) {
				var atmtObj = tgtData.attachement;
				fileInputEl.val(null);
				fileIdEl.val(atmtObj.id);
				fileInputEl.css("display", "none");
				labelEl.html(atmtObj.name + "&nbsp;(<span class='mono'>" + atmtObj.size + "bytes</span>)");
				labelEl.css("display", "inline");
				commitBtnEl.css("display", "inline");
				deleteBtnEl.css("display", "inline");
				$(".input-file-message").addClass("hidden");
			} else {
				fileInputEl.val(null);
				fileInputEl.css("display", "inline");
				fileIdEl.val(null);
				labelEl.html("");
				labelEl.css("display", "none");
				commitBtnEl.css("display", "none");
				deleteBtnEl.css("display", "none");
			}
			if (tgtData.dt_created) {
				$("#m_engineer_dt_created").text(tgtData.dt_created.substr(0, 10));
				$("#m_engineer_dt_created").parent().css("display", "block");
			}
			if(tgtData.station_pref_cd && tgtData.station_line_cd && tgtData.station_cd){
				$("#es").val(tgtData.station_pref_cd);
				setEngineerMenuItem(0, tgtData.station_pref_cd, tgtData.station_line_cd, tgtData.station_cd);
				setEngineerMenuItem(1, tgtData.station_line_cd, tgtData.station_line_cd, tgtData.station_cd);
			}
			$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>要員編集</span>"));
			$("#edit_engineer_modal").modal("show");
			$('#m_engineer_client_id').select2({allowClear: true});
		}
	});
}

function updateAge() {
	var tmpDtStr = $("#m_engineer_birth").val();
	var tmpYYYY = tmpDtStr ? tmpDtStr.split("/")[0] : null;
	var tmpMM = tmpDtStr ? tmpDtStr.split("/")[1] : null;
	var tmpDD = tmpDtStr ? tmpDtStr.split("/")[2] : null;

	if (tmpYYYY && tmpMM && tmpDD) {
		var now = new Date();
		var ageDate = new Date(tmpYYYY, tmpMM, tmpDD);
		var age = now.getFullYear() - Number(tmpYYYY);
		if(haveBirthday(ageDate)){
			age = age - 1;
		}
		$("#m_engineer_age").val(age);
	} else {
		void(0);
	}
}

function haveBirthday(date) {
	var now = new Date();
	var month1 = now.getMonth() + 1;
	var day1 = now.getDate();

	var month2= date.getMonth();
	var day2 = date.getDate();

	if (month1 == month2) {
		return day1 < day2;
	}
	else {
		return month1 < month2;
	}
}

function commitNewEngineerObj() {
	var reqObj = genCommitValueOfEngineer();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.engineer,
		{
			"client_id": "m_engineer_client_id",
			"client_name": "m_engineer_client_name",
			"name": "m_engineer_name",
			"kana": "m_engineer_kana",
			"visible_name": "m_engineer_visible_name",
			"tel": "m_engineer_tel",
			"mail1": "m_engineer_mail1",
			"mail2": "m_engineer_mail2",
			"age": "m_engineer_age",
			"birth": "m_engineer_birth",
			"gender": "m_engineer_gender_container",
			"state_work": "m_engineer_state_work",
			"fee": "m_engineer_fee",
			"station": "m_engineer_station",
			"skill": "m_engineer_skill",
			"note": "m_engineer_note",
			"internal_note": "m_engineer_internal_note",
			"charging_user_id": "m_engineer_charging_user_id",
			"employer": "m_engineer_employer",
			"operation_begin": "m_engineer_operation_begin",
			// "addr_vip": "m_engineer_addr_vip",
			// "addr1": "m_engineer_addr1",
			// "addr2": "m_engineer_addr2",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	c4s.invokeApi_ex({
		location: "engineer.createEngineer",
		body: reqObj,
		onSuccess: function(data) {
			alert("1件登録しました。");
			var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
			var onSuccessFunc = function () {
				$("#edit_engineer_modal").data("commitCompleted", true);
				$("#edit_engineer_modal").modal("hide");
			}
			if(flg_public_update){
				updateAccountFlgPublic(onSuccessFunc);
			}else{
				onSuccessFunc();
			}
		},
		onError: function(data) {
			alert("登録に失敗しました。（" + data.status.description + "）");
		},
	});
}

function updateEngineerObj () {
	var oldObj = env.recentAjaxResult.data[0];
	var newObj = genCommitValueOfEngineer();
	var reqObj = {};
	var i;
	for (i in newObj) {
		if (oldObj[i] !== undefined && newObj[i] != oldObj[i]) {
			reqObj[i] = newObj[i];
		}
	}
	if (newObj.charging_user_id) {
		reqObj.charging_user_id = newObj.charging_user_id;
	}
	reqObj.id = Number($("#m_engineer_id").val());

	if(newObj.skill_id_list){
		reqObj.skill_id_list = newObj.skill_id_list;
		reqObj.skill_level_list = newObj.skill_level_list;
	}
	if(newObj.occupation_id_list){
		reqObj.occupation_id_list = newObj.occupation_id_list;
	}
	reqObj.client_id = newObj.client_id;
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.engineer,
		{
			"client_id": "m_engineer_client_id",
			"client_name": "m_engineer_client_name",
			"name": "m_engineer_name",
			"kana": "m_engineer_kana",
			"visible_name": "m_engineer_visible_name",
			"tel": "m_engineer_tel",
			"mail1": "m_engineer_mail1",
			"mail2": "m_engineer_mail2",
			"birth": "m_engineer_birth",
			"age": "m_engineer_age",
			"gender": "m_engineer_gender_container",
			"state_work": "m_engineer_state_work",
			"fee": "m_engineer_fee",
			"station": "m_engineer_station",
			"skill": "m_engineer_skill",
			"note": "m_engineer_note",
			"internal_note": "m_engineer_internal_note",
			"employer": "m_engineer_employer",
			"operation_begin": "m_engineer_operation_begin",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	c4s.invokeApi_ex({
		location: "engineer.updateEngineer",
		body: reqObj,
		onSuccess: function(data) {
			alert("1件更新しました。");
			var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
			var onSuccessFunc = function () {
				$("#edit_engineer_modal").data("commitCompleted", true);
				$("#edit_engineer_modal").modal("hide");
			}
			if(flg_public_update){
				updateAccountFlgPublic(onSuccessFunc);
			}else{
				onSuccessFunc();
			}
		},
		onError: function(data) {
			alert("更新に失敗しました。（" + data.status.description + "）")
		},
	});
}

function deleteEngineerAttachment(loop_idx) {
	var fileInputEl = $("#attachment_file_" + loop_idx);
	var fileIdEl = $("#attachment_id_" + loop_idx);
	var labelEl = $("#attachment_label_" + loop_idx);
	var commitBtnEl = $("#attachment_btn_commit_" + loop_idx);
	var deleteBtnEl = $("#attachment_btn_delete_" + loop_idx);
	fileInputEl.val(null);
	fileInputEl.css("display", "inline");
	fileIdEl.val(null);
	labelEl.html("");
	labelEl.css("display", "none");
	commitBtnEl.css("display", "none");
	deleteBtnEl.css("display", "none");
	$(".input-file-message").removeClass("hidden");
}

function uploadFileEngineer(loop_idx) {
	var fileInputEl = $("#attachment_file_" + loop_idx);
	var fileIdEl = $("#attachment_id_" + loop_idx);
	var labelEl = $("#attachment_label_" + loop_idx);
	var commitBtnEl = $("#attachment_btn_commit_" + loop_idx);
	var deleteBtnEl = $("#attachment_btn_delete_" + loop_idx);
	if (window.FormData) {
		var fd = new FormData();
		var fi = fileInputEl[0];
		if (fi.files.length) {
			fd.append("attachement", fi.files[0]);
			fd.append("json", JSON.stringify({
				login_id: env.login_id,
				credential: env.credential,
			}));
			$.ajax({
				url: "/" + env.prefix + "/api/file.upload/json",
				type: "POST",
				data: fd,
				processData: false,
				contentType: false,
				dataType: 'json',
				success: function (data) {
					if (data && data.data && data.data.id && data.status.code == 0) {
						fileIdEl.val(data.data.id);
						labelEl.html(data.data.filename + "&nbsp;(<span class='mono'>" + data.data.size + "bytes</span>)");
						labelEl.css("display", "inline");
						fileInputEl.css("display", "none");
						commitBtnEl.css("display", "inline");
						deleteBtnEl.css("display", "inline");
					} else if (data && data.status.code == 13 && data.data && data.data.size && data.data.limit) {
						window.alert(data.status.description + "制限値が" + data.data.limit + "bytesのところ、アップロードしようとしたサイズは" + data.data.size + "bytesでした（" + String((data.data.size / data.data.limit - 1) * 100).split(".")[0] + "％超過）。");
					} else if (data && data.status.code) {
						window.alert(data.status.description);
						fileInputEl.val(null);
						fileIdEl.val(null);
					} else {
						window.console ? console.log("file upload error.") : void(0);
					}
				},
				error: function (data) {

				}
			});
		}
	} else {
		alert("FormDataに非対応のWebブラウザです。Webブラウザのバージョンを最新に保ってください。");
	}
}

function genCommitValueOfEngineer() {
	var reqObj = {};

    reqObj.fee = formatForCalc($("#m_engineer_fee").val());

	var textSymbols = [
		["#m_engineer_client_id", Number],
		["#m_engineer_client_name", String],
		["#m_engineer_name", String],
		["#m_engineer_kana", String],
		["#m_engineer_visible_name", String],
		["#m_engineer_tel", String],
		["#m_engineer_mail1", String],
		["#m_engineer_mail2", String],
		["#m_engineer_age", Number],
		["#m_engineer_station", String],
		["#m_engineer_note", String],
		["#m_engineer_internal_note", String],
		["#attachment_id_0", Number],
		["#m_engineer_skill", String],
		["#m_engineer_state_work", String],
		["#m_engineer_employer", String],
		["#m_engineer_operation_begin", String],
		["#m_engineer_station_cd", String],
		["#m_engineer_station_pref_cd", String],
		["#m_engineer_station_line_cd", String],
		["#m_engineer_station_lon", Number],
		["#m_engineer_station_lat", Number],
		// ["#m_engineer_addr_vip", String],
		// ["#m_engineer_addr1", String],
		// ["#m_engineer_addr2", String],
	];
	var datepickerSymbols = [
		["#m_engineer_birth", String],
	];
	var checkSymbols = [
		["#m_engineer_flg_caution", Boolean],
		["#m_engineer_flg_registered", Boolean],
		["#m_engineer_flg_assignable", Boolean],
		["#m_engineer_flg_public", Boolean],
		["#m_engineer_web_public", Boolean],
		["#m_engineer_flg_careful", Boolean],
	];
	var comboSymbols = [
		["#m_engineer_contract", String],
		["#m_engineer_charging_user_id", Number],
	];
	var radioSymbols = [
		["[name=m_engineer_gender_grp]:checked", String],
	];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = textSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = datepickerSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_engineer_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	if (reqObj.attachment_id_0) {
		reqObj.attachement = reqObj.attachment_id_0;
		delete reqObj.attachment_id_0;
	} else {
		reqObj.attachement = null;
	}
	reqObj.skill_level_list = [];
	reqObj.skill_id_list = $('[name="m_engineer_skill[]"]:checked').map(function(){
		var skill_id = $(this).val();
		var skill_level = $("#m_engineer_skill_level_" + skill_id).val();
		if(skill_level != ""){
			reqObj.skill_level_list.push({"id": skill_id, "level":skill_level});
		}
  		return skill_id;
	}).get();
	if(reqObj.skill_id_list.length == 0){
		delete　reqObj.skill_id_list;
	}

	reqObj.occupation_id_list = $('[name="m_engineer_occupation[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.occupation_id_list.length == 0){
		delete　reqObj.occupation_id_list;
	}

	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}

	return reqObj;
}
//[end] Functions for engineer modal.

//[begin] Functions for preparation(engineer) modal.
function hdlEditPreparation(engineerId) {
	//[begin] Prepare data.
	if (!env.data.engineer) {
		c4s.invokeApi_ex({
			location: "engineer.enumEngineers",
			body: {},
			onSuccess: function (res) {
				env.data.engineers = res.data;
			},
		});
	}
	//[end] Prepare data.
	//[begin] Clear fields.
	c4s.clearValidate({
		"client_name": "input_1_client_name",
		"time": "input_1_time",
		"progress": "input_1_progress",
		"note": "input_1_note",
	});
	$("#input_1_engineer_id").val(engineerId);
	$("#input_1_id").val(null);
	$("#input_1_client_id").val(null);
	$("#input_1_client_name").val(null);
	$("#input_1_time").val(null);
	$("#input_1_progress").val(null);
	$("#input_1_note").val(null);
	//[end] Clear fields.
	//[begin] Render history.
	var i;
	var tmp, ctmp;
	var tbody, tr, td;
	tbody = $("#edit_preparation_modal tbody");
	tbody.html("");
	var source = env.data.engineers.filter(function (val, idx, arr){
		return val.id == engineerId;
	});
	source = source.length > 0 ? source[0].preparations : [];
	for (i = 0; i < source.length; i++) {
		tmp = source[i];
		if (tmp.client_id && !tmp.client_name) {
			ctmp = env.data.clients_compact.filter(function (val, idx, arr) {
				return tmp.client_id == val.id;
			})[0];
		}
		tr = $("<tr id='iter_preparation_" + tmp.id + "'></tr>");
		tr.data("object", tmp);
		if ((tmp.client_id && ctmp) || tmp.client_name) {
			td = $("<td class='center'><span class='glyphicon glyphicon-pencil text-success pseudo-link-cursor' onclick='overwritePreparationForUpdate($(\"#iter_preparation_" + tmp.id + "\").data(\"object\"));'></span></td>");
		} else {
			td = $("<td class='center'></td>");
		}
		tr.append(td);
		td = $("<td></td>");
		if (tmp.client_id && !tmp.client_name) {
			if (ctmp) {
				td.append($("<span class='pseudo-link' onclick=''>" + ctmp.name + "</span>"));
			} else {
				td.append($("<span class='' onclick=''>（削除済み取引先）</span>"));
			}
		} else {
			td.html(tmp.client_name);
		}
		tr.append(td);
		td = $("<td>" + tmp.time + "</td>");
		tr.append(td);
		td = $("<td>" + tmp.progress + "</td>");
		tr.append(td);
		td = $("<td>" + tmp.note + "</td>");
		tr.append(td);
		td = $("<td class='center'><span class='glyphicon glyphicon-trash text-danger pseudo-link-cursor' onclick='c4s.hdlClickDeleteItem(\"preparation\", " + tmp.id + ", true);'></span></td>");
		tr.append(td);
		tbody.append(tr);
	}
	if (source.length == 0) {
		tbody.append($("<tr id='iter_preparation_0'><td colspan='6'>有効なデータがありません</td></tr>"))
	}
	//[end] Render history.
	$("#edit_preparation_modal").modal("show");
}
function overwritePreparationForUpdate(prepObj) {
	c4s.clearValidate({
		"client_name": "input_1_client_name",
		"time": "input_1_time",
		"progress": "input_1_progress",
		"note": "input_1_note",
	});
	if (prepObj) {
		$("#input_1_id").val(prepObj.id);
		$("#input_1_client_id").val(prepObj.client_id);
		$("#input_1_client_name").val(prepObj.client_name || env.data.clients.filter(function (val) { return val.id == prepObj.client_id ;})[0].name);
		$("#input_1_time").val(prepObj.time);
		$("#input_1_progress").val(prepObj.progress);
		$("#input_1_note").val(prepObj.note);
	}
}
function commitPreparation() {
	var reqObj = {};
	reqObj.id = $("#input_1_id").val() || null;
	reqObj.engineer_id = Number($("#input_1_engineer_id").val());
	reqObj.client_id = $("#input_1_client_id").val() || null;
	reqObj.client_name = $("#input_1_client_name").val();
	reqObj.time = $("#input_1_time").val();
	reqObj.progress = $("#input_1_progress").val();
	reqObj.note = $("#input_1_note").val();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.preparation,
		{
			"client_name": "input_1_client_name",
			"time": "input_1_time",
			"progress": "input_1_progress",
			"note": "input_1_note",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	if (reqObj.client_id) {
		delete reqObj.client_name;
	}
	var i, flgPass;
	for (i in reqObj) {
		if (reqObj[i] && i !== "engineer_id" && i !== "id") {
			flgPass = true;
			break;
		}
	}
	if (!flgPass) {
		alert("入力を修正してください");
		return;
	}
	if (!reqObj.id) {
		delete reqObj.id;
	}
	c4s.invokeApi_ex({
		location: reqObj.id ? "engineer.updatePreparation": "engineer.createPreparation",
		body: reqObj,
		onSuccess: function (res) {
			alert(reqObj.id ? "1件更新しました。" : "1件登録しました。");
			$("#edit_preparation_modal").data("commitCompleted", true);
			c4s.invokeApi_ex({
				location: "engineer.enumEngineers",
				body: {},
				onSuccess: function (cres) {
					env.data.engineers = cres.data;
					hdlEditPreparation(reqObj.engineer_id);
				},
			});
		},
	});
}
//[end] Functions for preparation(engineer) modal.

var project_skill_id_list;
var project_skill_level_list;

//[begin] Functions for project modal.
function hdlClickNewProjectObj () {
	c4s.clearValidate({
		"id": "m_project_id",
		"client_id": "m_project_client_id",
		"client_name": "m_project_client_name",
		"title": "m_project_title",
		"term": "m_project_term",
		"term_begin": "m_project_term_begin",
		"term_end": "m_project_term_end",
		"age_from": "m_project_age_from",
		"age_to": "m_project_age_to",
		"fee_inbound": "m_project_fee_inbound",
		"fee_outbound": "m_project_fee_outbound",
		"expense": "m_project_expense",
		"process": "m_project_process",
		"interview": "m_project_interview_container",
		"station": "m_project_station_container",
		"scheme": "m_project_scheme_container",
		"skill_needs": "m_project_skill_needs",
		"skill_recommends": "m_project_skill_recommends",
		"rank_id" : "m_project_rank_id_container",
	});
	// [begin] Clear fields.
	var textSymbols = [
		"#m_project_id",
		"#m_project_client_name",
		"#m_project_client_id",
		"#m_project_fee_inbound",
		"#m_project_fee_outbound",
		"#m_project_expense",
		"#m_project_title",
		"#m_project_process",
		["#m_project_interview", 1],
		"#m_project_station",
		"#m_project_note",
		"#m_project_internal_note",
		"#m_project_term",
		"#m_project_term_begin",
		"#m_project_term_end",
		["#m_project_age_from", 22],
		["#m_project_age_to", 65],
		"#m_project_skill_needs",
		"#m_project_skill_recommends",
		"#m_project_station_cd",
		"#m_project_station_pref_cd",
		"#m_project_station_line_cd",
		"#m_project_station_lon",
		"#m_project_station_lat",
	];
	var checkSymbols = [
		"#m_project_flg_shared",
	];
	var notCheckSymbols = [
		"#m_project_flg_public",
		"#m_project_web_public",
	];
	var comboSymbols = [];
	var radioSymbols = [
		"[name=m_project_rank_grp]",
	];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		if (textSymbols[i] instanceof Array) {
			$(textSymbols[i][0])[0].value = textSymbols[i][1];
		} else {
			$(textSymbols[i])[0].value = "";
		}
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = true;
	}
	for (i = 0; i < notCheckSymbols.length; i++) {
		if ($(notCheckSymbols[i]).length > 0) {
			$(notCheckSymbols[i])[0].checked = false;
		}
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$('[name="m_project_skill[]"]').each(function (idx, el) {
		el.checked = false;
	});
	$('[name="m_project_skill_level[]"]').each(function (idx, el) {
		el.selectedIndex = 0;
	});
	viewSelectedProjectSkill();
	$('[name="m_project_occupation[]"]').each(function (idx, el) {
		el.checked = false;
	});
	$("#m_project_scheme").val(null);
	$("#m_project_charging_user_id").val(env.userProfile.user.id);
	// [end] Clear fields.

	$("#m_project_scheme").val("エンド");

	setProjectMenuItem(0, 0, null, null);
	$("#ps").val(0);

	$("#m_project_worker_container").addClass("hidden");
	$("#edit_project_modal_title").html("新規案件登録");
	$("#edit_project_modal").modal("show");
	$('#m_project_client_id').select2();
	$('#m_project_skill_sort')[0].checked = false
	project_skill_id_list = '';
	project_skill_level_list = [];
}

function overwriteModalForEditProject(objId) {
	c4s.clearValidate({
		"id": "m_project_id",
		"client_id": "m_project_client_id",
		"client_name": "m_project_client_name",
		"title": "m_project_title",
		"term": "m_project_term",
		"term_begin": "m_project_term_begin",
		"term_end": "m_project_term_end",
		"age_from": "m_project_age_from",
		"age_to": "m_project_age_to",
		"fee_inbound": "m_project_fee_inbound",
		"fee_outbound": "m_project_fee_outbound",
		"expense": "m_project_expense",
		"process": "m_project_process",
		"interview": "m_project_interview_container",
		"station": "m_project_station_container",
		"scheme": "m_project_scheme_container",
		"skill_needs": "m_project_skill_needs",
		"skill_recommends": "m_project_skill_recommends",
		"rank_id": "m_project_rank_container",
	});
	var textSymbols = [
		["id", "#m_project_id"],
		["client_name", "#m_project_client_name"],
		["fee_inbound_comma", "#m_project_fee_inbound"],
		["fee_outbound_comma", "#m_project_fee_outbound"],
		["expense", "#m_project_expense"],
		["title", "#m_project_title"],
		["process", "#m_project_process"],
		["interview", "#m_project_interview"],
		["station", "#m_project_station"],
		["note", "#m_project_note"],
		["internal_note", "#m_project_internal_note"],
		["term", "#m_project_term"],
		["term_begin", "#m_project_term_begin"],
		["term_end", "#m_project_term_end"],
		["age_from", "#m_project_age_from"],
		["age_to", "#m_project_age_to"],
		["skill_needs", "#m_project_skill_needs"],
		["skill_recommends", "#m_project_skill_recommends"],
		["station_cd", "#m_project_station_cd"],
		["station_pref_cd", "#m_project_station_pref_cd"],
		["station_line_cd", "#m_project_station_line_cd"],
		["station_lon", "#m_project_station_lon"],
		["station_lat", "#m_project_station_lat"],
	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["flg_shared", "#m_project_flg_shared"],
		["flg_public", "#m_project_flg_public"],
		["web_public", "#m_project_web_public"],
	];
	var comboSymbols = [
		["scheme", "#m_project_scheme"],
		["charging_user_id", "#m_project_charging_user_id"],
	];
	var radioSymbols = [
		["rank_id", "[name=m_project_rank_grp]"],
	];
	c4s.invokeApi("project.enumProjects", {id: Number(objId)}, function (data) {
		env.recentAjaxResult = data;
		if (data && data.status && data.data
			&& data.status.code == 0
			&& data.data instanceof Array && data.data[0]) {
			var i;
			var tmpEl;
			var tgtData = data.data[0];
			tgtData.client_id = tgtData.client && tgtData.client.id || null;
			tgtData.charging_user_id = tgtData.charging_user.id;
			try{
				for (i = 0; i < textSymbols.length; i++) {
					$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
				}
			}catch(error) {
				console.log(i + textSymbols[i][1]);
			}
			
			for (i = 0; i < datepickerSymbols.length; i++) {
				if (tgtData[datepickerSymbols[i][0]]) {
					$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
				} else {
					$(datepickerSymbols[i][1]).val(null);
				}
			}
			for (i = 0; i < checkSymbols.length; i++) {
				$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
			}
			for (i = 0; i < comboSymbols.length; i++) {
				$(comboSymbols[i][1])[0].selectedIndex = 0;
				$(comboSymbols[i][1] + " option").each(function (idx, el) {
					if (String(tgtData[comboSymbols[i][0]]) == el.value) {
						el.selected = true;
					}
				});
			}

			for (i = 0; i < radioSymbols.length; i++) {
				$(radioSymbols[i][1]).each(function (idx, el) {
					if (el.value == tgtData[radioSymbols[i][0]]) {
						el.checked = true;
					}
				});
			}
			if (tgtData.client_id) {
				$("#m_project_client_id").val(tgtData.client_id);
				$("#m_project_client_name").val(tgtData.client.name);
			}
			if (tgtData.dt_created) {
				$("#m_project_dt_created").text(tgtData.dt_created.substr(0, 10));
				$("#m_project_dt_created").parent().css("display", "block");
			}
			$('[name="m_project_skill[]"]').each(function (idx, el) {
				el.checked = false;
			});
			$('[name="m_project_skill_level[]"]').each(function (idx, el) {
				el.selectedIndex = 0;
			});
			$('[name="m_project_skill_level[]"]').addClass("hidden");
			$('[name="m_project_occupation[]"]').each(function (idx, el) {
				el.checked = false;
			});
			if(tgtData.skill_id_list){
				project_skill_id_list = tgtData.skill_id_list
				project_skill_level_list = tgtData.skill_level_list;
				$('[name="m_project_skill[]"]').each(function (index) {
                    var setval = $(this).val();
                    var skillArr = tgtData.skill_id_list.split(",");
                    if (skillArr.indexOf(setval) >= 0) {
						$(this).val([setval]);
						$('#m_project_skill_level_' + setval).removeClass("hidden");
						tgtData.skill_level_list.forEach(function(e, i, a) {
							if(setval == e["skill_id"]){
								$("#m_project_skill_level_" + setval).val(e["level"]);
							}
						})
                    }
                });
			}
			viewSelectedProjectSkill();
			if(tgtData.occupation_id_list){
				$('[name="m_project_occupation[]"]').each(function (index) {
                    var setval = $(this).val();
                    var occupationArr = tgtData.occupation_id_list.split(",");
                    if (occupationArr.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
			}
			if(tgtData.station_pref_cd && tgtData.station_line_cd && tgtData.station_cd){
				$("#ps").val(tgtData.station_pref_cd);
				setProjectMenuItem(0, tgtData.station_pref_cd, tgtData.station_line_cd, tgtData.station_cd);
				setProjectMenuItem(1, tgtData.station_line_cd, tgtData.station_line_cd, tgtData.station_cd);
			}
			$("#m_project_flg_foreign").val(tgtData.flg_foreign);
			$("#m_project_worker_container").removeClass("hidden");
			$("#edit_project_modal_title").html("案件編集");
			$("#edit_project_modal").modal("show");
			getRelatedEngineer(tgtData.id);
			$('#m_project_client_id').select2();
		}
	});
}

function genCommitValueOfProject() {
	var reqObj = {};
	if ($("#m_project_id").val()) {
		reqObj.id = Number($("#m_project_id").val());
	}

    reqObj.fee_inbound = formatForCalc($("#m_project_fee_inbound").val());
    reqObj.fee_outbound = formatForCalc($("#m_project_fee_outbound").val());

	var textSymbols = [
		["#m_project_client_name", String],
		["#m_project_expense", String],
		["#m_project_title", String],
		["#m_project_process", String],
		["#m_project_interview", Number],
		["#m_project_station", String],
		["#m_project_note", String],
		["#m_project_internal_note", String],
		["#m_project_term", String],
		["#m_project_term_begin", String],
		["#m_project_term_end", String],
		["#m_project_age_from", Number],
		["#m_project_age_to", Number],
		["#m_project_skill_needs", String],
		["#m_project_skill_recommends", String],
		["#m_project_station_cd", String],
		["#m_project_station_pref_cd", String],
		["#m_project_station_line_cd", String],
		["#m_project_station_lon", Number],
		["#m_project_station_lat", Number],

	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["#m_project_flg_shared", Boolean],
		["#m_project_flg_public", Boolean],
		["#m_project_web_public", Boolean],
	];
	var comboSymbols = [
		["#m_project_client_id", Number],
		["#m_project_scheme", String],
		["#m_project_charging_user_id", Number],
	];
	var radioSymbols = [
		["[name=m_project_rank_grp]:checked", Number],
	];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_project_", "")] = textSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("m_project_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		if (tmpEl.length > 0) {
			reqObj[tmpEl.attr("id").replace("m_project_", "")] = checkSymbols[i][1](tmpEl[0].checked);
		}
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_project_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_project_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	if(reqObj.rank){
		reqObj.rank_id = reqObj.rank;
		delete reqObj.rank;
	}
	if(reqObj.client_id == 0){
			reqObj.client_id = null;
	}
	if (reqObj.client_id) {
		delete reqObj.client_name;
	}
	if (reqObj.charging_user_id == 0) {
		reqObj.charging_user_id = null;
	}

	reqObj.skill_level_list = [];
	reqObj.needs = $('[name="m_project_skill[]"]:checked').map(function(){
  		var skill_id = $(this).val();
  		var skill_level = $("#m_project_skill_level_" + skill_id).val();
		if(skill_level != ""){
			reqObj.skill_level_list.push({"id": skill_id, "level":skill_level});
		}
		return skill_id;
	}).get();
	if(reqObj.needs.length == 0){
		delete　reqObj.needs;
	}

	reqObj.occupations = $('[name="m_project_occupation[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.occupations.length == 0){
		delete　reqObj.occupations;
	}

	reqObj.flg_foreign = $('#m_project_flg_foreign').val();

	env.debugOut(reqObj);
	return reqObj;
}

function commitProjectObject(updateFlg) {
	var reqObj = genCommitValueOfProject();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.project,
		{
			"id": "m_project_id",
			"client_id": "m_project_client_id",
			"client_name": "m_project_client_name",
			"title": "m_project_title",
			"term": "m_project_term",
			"term_begin": "m_project_term_begin",
			"term_end": "m_project_term_end",
			"age_from": "m_project_age_from",
			"age_to": "m_project_age_to",
			"fee_inbound": "m_project_fee_inbound",
			"fee_outbound": "m_project_fee_outbound",
			"expense": "m_project_expense",
			"process": "m_project_process",
			"interview": "m_project_interview_container",
			"station": "m_project_station_container",
			"scheme": "m_project_scheme_container",
			"skill_needs": "m_project_skill_needs",
			"skill_recommends": "m_project_skill_recommends",
			"rank_id": "m_project_rank_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	if(validateCondition(reqObj)){
		return;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "project.updateProject" : "project.createProject",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1件更新しました。" : "1件登録しました。");
			var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
			var onSuccessFunc = function () {
				$("#edit_project_modal").data("commitCompleted", true);
				$("#edit_project_modal").modal("hide");
			}
			if(flg_public_update){
				updateAccountFlgPublic(onSuccessFunc);
			}else{
				onSuccessFunc();
			}
		},
		onError: function (data) {
			alert((updateFlg ? "更新" : "登録") + "に失敗しました（" + data.status.description + "）");
		}
	});
}
//[end] Functions for project modal.

//[begin] Functions for client modal.
function triggerMailOnClientModal(workerIdArr) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	reqObj.type_recipient = "forWorker";
	reqObj.recipients = {engineers: [], workers: []};
	if (workerIdArr) {
		reqObj.recipients.workers = workerIdArr;
	} else {
		$("[id^=iter_mailto_worker_]").each(function (idx, el, arr) {
			if (el.checked) {
				reqObj.recipients.workers.push(Number(el.id.replace("iter_mailto_worker_", "")));
			}
		});
	}
	if (reqObj.recipients.workers.length == 0) {
		alert("対象データを選択してください。");
	} else {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: reqObj,
			pageMove: true,
			newPage: true,
		});
		$("#edit_client_modal").modal("hide");
	}
}

function searchZip2Addr(zipCode, destinationId, alertId) {
	var code = zipCode.replace("-", "");
	if(code.match ( /[^0-9]+/ )){
		alert("半角数値(0〜9)と半角のハイフン(-)のみ利用できます");
		return;
	}
	var destEl = $(destinationId);
	var alertEl = $(alertId);
	if (code && destEl.length > 0) {
		c4s.invokeApi_ex({
			location: "zip.search",
			body: {code: code},
			onSuccess: function (res) {
				if (res.data.addr1) {
					destEl.val(res.data.addr1);
					alertEl.html("");
				} else {
					alertEl.html("該当する住所はありませんでした（" + zipCode + "）");
				}
			},
			onError: function (res) {
				alertEl.html("検索でエラーが発生しました");
			}
		});
	}
}

function hdlClickNewClientObj () {
	c4s.clearValidate({
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip_container",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	// [begin] Clear fields.
	$("#m_client_addr1_alert").html("");
	var textSymbols = [
		"#m_client_id",
		"#m_client_name",
		"#m_client_kana",
		"#m_client_addr_vip",
		"#m_client_addr1",
		"#m_client_addr2",
		"#m_client_tel",
		"#m_client_fax",
		"#m_client_site",
		"#m_client_note",
	];
	var checkSymbols = [
		"#m_client_type_presentation_0",
		"#m_client_type_presentation_1",
	];
	var comboSymbols = [
		"#m_client_type_dealing",
		"#m_client_charging_worker1",
		"#m_client_charging_worker2",
	];
	var radioSymbols = [];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		if (textSymbols[i] instanceof Array) {
			$(textSymbols[i][0])[0].value = textSymbols[i][1];
		} else {
			$(textSymbols[i])[0].value = "";
		}
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = false;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$("#m_client_charging_worker1").val(env.userProfile.user.id);
	// [end] Clear fields.
	// [begin] Disable table containers.
	$("#m_client_branch_container").css("display", "none");
	$("#m_client_worker_container").css("display", "none");
	// [end] Disable table containers.
	$("#edit_client_modal_title").replaceWith($("<span id='edit_client_modal_title'>新規取引先登録</span>"));
	$("#m_client_type_dealing")[0].selectedIndex = 1;
	$("#edit_client_modal").modal("show");
}

function overwriteClientModalForEdit(objId) {
	c4s.clearValidate({
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	$("#m_client_addr1_alert").html("");
	// objId is client id.
	var textSymbols = [
		["id", "#m_client_id"],
		["name", "#m_client_name"],
		["kana", "#m_client_kana"],
		["addr_vip", "#m_client_addr_vip"],
		["addr1", "#m_client_addr1"],
		["addr2", "#m_client_addr2"],
		["tel", "#m_client_tel"],
		["fax", "#m_client_fax"],
		["site", "#m_client_site"],
		["note", "#m_client_note"],
	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["type_presentation_0", "#m_client_type_presentation_0"],
		["type_presentation_1", "#m_client_type_presentation_1"],
	];
	var comboSymbols = [
		["type_dealing", "#m_client_type_dealing"],
		["charging_worker_1_id", "#m_client_charging_worker1"],
		["charging_worker_2_id", "#m_client_charging_worker2"],
	];
	var radioSymbols = [];
	c4s.invokeApi("client.enumClients", {id: Number(objId)}, function (data) {
		// [begin] Enable table containers.
		$("#m_client_branch_container").css("display", "inline");
		$("#m_client_worker_container").css("display", "inline");
		// [end] Enable table containers.
		env.recentAjaxResult = data;
		if (data && data.status && data.data
			&& data.status.code == 0
			&& data.data instanceof Array && data.data[0]) {
			var i;
			var tmpEl;
			var tgtData = data.data[0];
			tgtData.site = (tgtData.site == "" || tgtData.site == "null" || !tgtData.site) ? "" : tgtData.site;
			tgtData.type_presentation_0 = tgtData.type_presentation && tgtData.type_presentation.join("").indexOf("案件") > -1 ? true : false;
			tgtData.type_presentation_1 = tgtData.type_presentation && tgtData.type_presentation.join("").indexOf("人材") > -1 ? true : false;
			tgtData.charging_worker_1_id = tgtData.charging_worker1 ? tgtData.charging_worker1.id : null;
			tgtData.charging_worker_2_id = tgtData.charging_worker2 ? tgtData.charging_worker2.id : null;
			for (i = 0; i < textSymbols.length; i++) {
				$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
			}
			for (i = 0; i < datepickerSymbols.length; i++) {
				$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
			}
			for (i = 0; i < checkSymbols.length; i++) {
				$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
			}
			for (i = 0; i < comboSymbols.length; i++) {
				$(comboSymbols[i][1])[0].selectedIndex = 0;
				$(comboSymbols[i][1] + " option").each(function (idx, el) {
					if (String(tgtData[comboSymbols[i][0]]) == el.value) {
						el.selected = true;
					}
				});
			}

			for (i = 0; i < radioSymbols.length; i++) {
				$(radioSymbols[i][1]).each(function (idx, el) {
					if (el.value === tgtData[radioSymbols[i][0]]) {
						el.checked = true;
					}
				});
			}
			// [begin] Fetch branches.
			c4s.invokeApi_ex({
				location: "client.enumBranches",
				body: {client_id: objId},
				onSuccess: function(codata) {
					$("#m_client_branch_table tbody tr").remove();
					if (codata && codata.data && codata.data instanceof Array && codata.data.length > 0) {
						var i;
						for (i = 0; i < codata.data.length; i++) {
							var tmpTr = $("<tr></tr>");
							tmpTr.appendTo("#m_client_branch_table tbody");
							// 操作
							$("<td class='center'><span class='glyphicon glyphicon-pencil text-success pseudo-link-cursor' title='編集' onclick='overwriteBranchModalForEdit(" + objId + ", " + codata.data[i].id + ");'></span></td>").appendTo(tmpTr);
							// 支店名
							$("<td></td>").text(codata.data[i].name).appendTo(tmpTr);
							// 住所
							$("<td></td>").text("〒" + codata.data[i].addr_vip + " " + codata.data[i].addr1 + " " + codata.data[i].addr2).appendTo(tmpTr);
							// Map
							if (env.limit.LMT_ACT_MAP) {
								if ((env.limit.LMT_CALL_MAP_EXTERN_M > env.mapLimit) || (env.limit.LMT_CALL_MAP_EXTERN_M == 0)) {
									var mapData = {
										target_id: codata.data[i].id,
										target_type: 'branch',
										name: codata.data[i].name,
										addr1: codata.data[i].addr1,
										addr2: codata.data[i].addr2,
										tel: codata.data[i].tel,
										modalId: 'edit_client_modal',
										isFloodLMT: false,
										current: env.current
									};
									for (var key in mapData){
										mapData[key] = typeof(mapData[key]) === "string" ? mapData[key].replace('"',"") : mapData[key];
									}
									var tmpTd = $("<td></td>").attr("class","center").css("width","35px");
									var tmpSpan = $("<span></span>").attr("class","glyphicon glyphicon-globe text-success pseudo-link-cursor").bind("click", function (option) { return function () { c4s.openMap(option); }; }(mapData));
									tmpSpan.appendTo(tmpTd);
									tmpTd.appendTo(tmpTr);
								} else {
									var tmpTd = $("<td></td>").attr("class","center").css("width","35px");
									var tmpSpan = $("<span></span>").attr("class","glyphicon glyphicon-globe text-muted pseudo-link-cursor").bind("click", function () { return function () { c4s.openMap({isFloodLMT: true}); }; }());
									tmpSpan.appendTo(tmpTd);
									tmpTd.appendTo(tmpTr);
								}
							}
							// 電話番号/FAX番号
							$("<td class='center'>" +
								(
									codata.data[i].tel && codata.data[i].tel !== "" ? ("<span class='glyphicon glyphicon-phone-alt'></span>&nbsp;<a href='tel:" + codata.data[i].tel.replace(/-/g, "") + "'>" + codata.data[i].tel + "</a>") : ""
								) +
								(
									codata.data[i].fax && codata.data[i].fax !== "" ? ("<br/><span class='glyphicon glyphicon-print'></span>&nbsp;" + codata.data[i].fax) : ""
								) +
								"</td>").appendTo(tmpTr);
						}
					} else {
						$("#m_client_branch_container")[0].style.display = "none";
					}
				},
			});
			// [end] Fetch branches.
			// [begin] Fetch workers.
			$("#m_client_worker_table tbody tr").remove();
			$("#m_client_worker_container")[0].style.display = "none";
			c4s.invokeApi_ex({
				location: "client.enumWorkers",
				body: {client_id: objId},
				onSuccess: function(codata) {
					if (codata && codata.data && codata.data instanceof Array && codata.data.length > 0) {
						var i;
						for (i = 0; i < codata.data.length; i++) {
							var tmpTr = $("<tr id='iter_worker_sm_" + codata.data[i].id + "'/>");
							tmpTr.appendTo("#m_client_worker_table tbody");
							// チェックボックス
							if ((codata.data[i].mail1 || codata.data[i].mail2) && codata.data[i].flg_sendmail) {
								$("<td class='center'><input type='checkbox' id='iter_mailto_worker_" + codata.data[i].id + "'/></td>").appendTo(tmpTr);
							} else {
								$("<td></td>").appendTo(tmpTr);
							}
							// 担当者名
							$("<td><img src='/img/icon/key_man.jpg' title='キーマン'" +
								(
									codata.data[i].flg_keyperson ? "" : " style='visibility: hidden;'"
								) + "/>&nbsp;<span class='pseudo-link' onclick='overwriteWorkerModalForEdit(" + codata.data[i].id + ");'>" +
								codata.data[i].name + "</span></td>").appendTo(tmpTr);
							// 電話番号
							$("<td class='center'>" +
								(
									codata.data[i].tel && codata.data[i].tel !== "" ? ("<a href='tel:" + codata.data[i].tel.replace(/-/g, "") + "'>" + codata.data[i].tel + "</a>") : ""
								) +
								"</td>").appendTo(tmpTr);
							// メールアドレス
							$("<td class=''>" +
								(
									codata.data[i].mail1 ? (
										env.limit.LMT_ACT_MAIL ? ("&nbsp;<span onclick='triggerMailOnClientModal([" + codata.data[i].id + "]);'><span class='glyphicon glyphicon-envelope text-warning pseudo-link-cursor'></span>&nbsp;<span class='pseudo-link'>" + codata.data[i].mail1 + "</span></span>") : ("&nbsp;" + codata.data[i].mail1)
									) : ""
								) +
								"</td>").appendTo(tmpTr);
							// 自社担当営業
							// if (codata.data[i].charging_user.login_id && codata.data[i].charging_user.user_name) {
							// 	$("<td class='center'><span class='pseudo-link-cursor' title='" + codata.data[i].charging_user.login_id + "'>" + codata.data[i].charging_user.user_name + "</span></td>").appendTo(tmpTr);
							// } else {
							// 	$("<td></td>").appendTo(tmpTr);
							// }
							// 削除ボタン
							$("<td class='center'><span class='glyphicon glyphicon-trash text-danger pseudo-link-cursor' title='削除' onclick='c4s.hdlClickDeleteItem(\"worker_sm\", " + codata.data[i].id + ", true); c4s.hdlClickDeleteItem(\"worker\", " + codata.data[i].id + ", true);'></span></td>").appendTo(tmpTr);
						}
						$("#m_client_worker_container")[0].style.display = "block";
					} else {
						$("#m_client_worker_container")[0].style.display = "none";
					}
				},
			});
			// [end] Fetch workers.
			$("#edit_client_modal_title").replaceWith($("<span id='edit_client_modal_title'>取引先編集</span>"));
			$("#edit_client_modal").modal("show");
		}
	});
}

function genCommitValueOfClient () {
	var reqObj = {};
	var textSymbols = [
		["#m_client_id", Number],
		["#m_client_name", String, ""],
		["#m_client_kana", String, ""],
		["#m_client_addr_vip", String, ""],
		["#m_client_addr1", String, ""],
		["#m_client_addr2", String, ""],
		["#m_client_tel", String, ""],
		["#m_client_fax", String, ""],
		["#m_client_site", String, ""],
		["#m_client_note", String, ""],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [
		["#m_client_type_dealing", String],
		["#m_client_charging_worker1", Number],
		["#m_client_charging_worker2", Number],
	];
	var radioSymbols = [];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		if (tmpEl.val()) {
			reqObj[tmpEl.attr("id").replace("m_client_", "")] = textSymbols[i][1](tmpEl.val());
		} else if (tmpEl.val() === "" && textSymbols[i].length == 3) {
			reqObj[tmpEl.attr("id").replace("m_client_", "")] = textSymbols[i][1](textSymbols[i][2]);
		}
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("m_client_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_client_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_client_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_client_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	// [begin] Variable filters.
	reqObj.charging_worker1 = reqObj.charging_worker1 || null;
	reqObj.charging_worker2 = reqObj.charging_worker2 || null;
	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}
	reqObj.type_presentation = [];
	$("[id^=m_client_type_presentation_]").each(function (idx, el) {
		if (el.checked) {
			reqObj.type_presentation.push(el.value);
		}
	});
	// [end] Variable filters.
	env.debugOut(reqObj);
	return reqObj;
}

function commitClient(updateFlg) {
	var reqObj = genCommitValueOfClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return false;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "client.updateClient" : "client.createClient",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1件更新しました。" : "1件登録しました。");
			var tmpBody = {};
			var i;
			for(i in env.recentQuery) {
				if (i !== "id") {
					tmpBody[i] = env.recentQuery[i];
				}
			}
			$("#edit_client_modal").data("commitCompleted", true);
			$("#edit_client_modal").modal("hide");
		},
		onError: function (data) {
			alert(updateFlg ? "更新に失敗しました。" : "登録に失敗しました。");
		}
	});
}

function hdlClickAddWorkerBtn(workerId) {
	var reqObj = genCommitValueOfClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip_container",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return false;
	}
	c4s.invokeApi_ex({
		location: workerId ? "client.updateClient" : "client.createClient",
		body: reqObj,
		onSuccess: function (res) {
			$("#ms_client_id").val(res.data.id);
			$("#ms_worker_id").val(workerId);
			overwriteWorkerModalForEdit();
		},
	});
}

function hdlClickAddBranchBtn(updateFlg) {
	var reqObj = genCommitValueOfClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip_container",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return false;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "client.updateClient" : "client.createClient",
		body: reqObj,
		onSuccess: function (res) {
			$("#m_client_id").val(res.data.id);
			overwriteBranchModalForEdit(res.data.id);
		},
	});
}

function hdlClickAddMoreWorkerBtn(workerId) {
	var reqObj = genCommitValueOfWorker();
	if (!workerId) {
		delete reqObj.id;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.worker,
		{
			"id": "ms_worker_id",
			"client_id": "ms_worker_client_id",
			"name": "ms_worker_name",
			"kana": "ms_worker_kana",
			"section": "ms_worker_section",
			"title": "ms_worker_title",
			"tel": "ms_worker_tel",
			"tel2": "ms_worker_tel2",
			"mail1": "ms_worker_mail1",
			"mail2": "ms_worker_mail2",
			"flg_keyperson": "ms_worker_misc_container",
			"flg_sendmail": "ms_worker_misc_container",
			"recipient_priority": "ms_worker_misc_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	if (workerId) {
		c4s.invokeApi_ex({
			location: "client.updateWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1件更新しました");
				overwriteClientModalForEdit(reqObj.client_id);
				overwriteWorkerModalForEdit();
			},
			onError: function (data) {
				alert("更新に失敗しました");
			},
		});
	} else {
		c4s.invokeApi_ex({
			location: "client.createWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1件登録しました");
				overwriteClientModalForEdit(reqObj.client_id);
				overwriteWorkerModalForEdit();
			},
			onError: function (data) {
				alert("登録に失敗しました");
			},
		});
	}
}

function overwriteBranchModalForEdit(clientId, branchId) {
	c4s.clearValidate({
		"id": "m_branch_id",
		"client_id": "m_branch_client_id",
		"name": "m_branch_name",
		"addr_vip": "m_branch_addr_vip",
		"addr1": "m_branch_addr1",
		"addr2": "m_branch_addr2",
		"tel": "m_branch_tel",
		"fax": "m_branch_fax",
	});
	var textSymbols = [
		["id", "#m_branch_id"],
		["client_id", "#m_branch_client_id"],
		["client_name", "#m_branch_client_name"],
		["name", "#m_branch_name"],
		["addr_vip", "#m_branch_addr_vip"],
		["addr1", "#m_branch_addr1"],
		["addr2", "#m_branch_addr2"],
		["tel", "#m_branch_tel"],
		["fax", "#m_branch_fax"],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [

	];
	var radioSymbols = [];
	var tgtData;
	var i;
	if (branchId) {
		c4s.invokeApi_ex({
			location: "client.enumBranches",
			body: {client_id: clientId},
			onSuccess: function (data) {
				if (data && data.data && data.data instanceof Array && data.data.length > 0) {
					var tgtData = data.data.filter(function (val, idx, arr){ return val.id == branchId; })[0];
					for (i = 0; i < textSymbols.length; i++) {
						$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
					}
					for (i = 0; i < datepickerSymbols.length; i++) {
						$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
					}
					for (i = 0; i < checkSymbols.length; i++) {
						$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
					}
					for (i = 0; i < comboSymbols.length; i++) {
						$(comboSymbols[i][1] + " option").each(function (idx, el) {
							if (String(tgtData[comboSymbols[i][0]]) == el.value) {
								el.selected = true;
							}
						});
					}

					for (i = 0; i < radioSymbols.length; i++) {
						$(radioSymbols[i][1]).each(function (idx, el) {
							if (el.value === tgtData[radioSymbols[i][0]]) {
								el.checked = true;
							}
						});
					}
					$("#edit_branch_modal_title").replaceWith($("<span id='edit_branch_modal_title'>取引先支店編集</span>"));
					$("#edit_branch_modal").modal("show");
				}
			},
		});
	} else {
		var i;
		tgtData = {
			client_id: clientId,
			client_name: $("#m_client_name").val(),
		};
		for (i = 0; i < textSymbols.length; i++) {
			$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
		}
		for (i = 0; i < datepickerSymbols.length; i++) {
			$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
		}
		for (i = 0; i < checkSymbols.length; i++) {
			$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
		}
		for (i = 0; i < comboSymbols.length; i++) {
			$(comboSymbols[i][1] + " option").each(function (idx, el) {
				if (String(tgtData[comboSymbols[i][0]]) == el.value) {
					el.selected = true;
				}
			});
		}

		for (i = 0; i < radioSymbols.length; i++) {
			$(radioSymbols[i][1]).each(function (idx, el) {
				if (el.value === tgtData[radioSymbols[i][0]]) {
					el.checked = true;
				}
			});
		}
		$("#m_branch_addr1_alert").html("");
		$("#m_branch_client_id").val($("#m_client_id").val());
		$("#edit_branch_modal_title").replaceWith($("<span id='edit_branch_modal_title'>取引先支店新規追加</span>"));
		$("#edit_branch_modal").modal("show");
	}
}

function genCommitValueOfBranch () {
	var reqObj = {};
	var textSymbols = [
		["#m_branch_id", Number],
		["#m_branch_client_id", Number],
		["#m_branch_name", String],
		["#m_branch_addr_vip", String],
		["#m_branch_addr1", String],
		["#m_branch_addr2", String, ""],
		["#m_branch_tel", String, ""],
		["#m_branch_fax", String, ""],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [];
	var radioSymbols = [];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_branch_", "")] = textSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("m_branch_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_branch_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_branch_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_branch_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	// [begin] Variable filters.
	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}
	// [end] Variable filters.
	env.debugOut(reqObj);
	return reqObj;
}

function commitBranch(updateFlg) {
	var reqObj = genCommitValueOfBranch();
	if (!updateFlg) {
		delete reqObj.id;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.branch,
		{
			"id": "m_branch_id",
			"client_id": "m_branch_client_id",
			"name": "m_branch_name",
			"addr_vip": "m_branch_addr_vip",
			"addr1": "m_branch_addr1",
			"addr2": "m_branch_addr2",
			"tel": "m_branch_tel",
			"fax": "m_branch_fax",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "client.updateBranch" : "client.createBranch",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1件更新しました。" : "1件登録しました。");
			$("#edit_client_modal").data("commitCompleted", true);
			$("#edit_branch_modal").modal("hide");
			$("#edit_client_modal").modal("hide");
		},
		onError: function (data) {
			alert(updateFlg ? "更新に失敗しました。" : "登録に失敗しました。");
		}
	});
}

function overwriteWorkerModalForEdit(workerId) {
	workerId = Number(workerId);
	c4s.clearValidate({
			"id": "ms_worker_id",
			"client_id": "ms_worker_client_id",
			"name": "ms_worker_name",
			"kana": "ms_worker_kana",
			"section": "ms_worker_section",
			"title": "ms_worker_title",
			"tel": "ms_worker_tel",
			"tel2": "ms_worker_tel2",
			"mail1": "ms_worker_mail1",
			"mail2": "ms_worker_mail2",
			"flg_keyperson": "ms_worker_misc_container",
			"flg_sendmail": "ms_worker_misc_container",
			"recipient_priority": "ms_worker_misc_container",
		});
	// objId is client id.
	var textSymbols = [
		["id", "#ms_worker_id"],
		["name", "#ms_worker_name"],
		["kana", "#ms_worker_kana"],
		["client_name", "#ms_worker_client_name"],
		["client_id", "#ms_worker_client_id"],
		["section", "#ms_worker_section"],
		["title", "#ms_worker_title"],
		["tel", "#ms_worker_tel"],
		["tel2", "#ms_worker_tel2"],
		["mail1", "#ms_worker_mail1"],
		["mail2", "#ms_worker_mail2"],
		["note", "#ms_worker_note"],
		["recipient_priority", "#ms_worker_recipient_priority", 5],
	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["flg_keyperson", "#ms_worker_flg_keyperson", false],
		["flg_sendmail", "#ms_worker_flg_sendmail", true],
	];
	var comboSymbols = [];
	var radioSymbols = [];
	var i;
	var tgtData;
	$("#ms_worker_id").val(workerId);
	if (workerId) {
		c4s.invokeApi_ex({
			location: "client.enumWorkers",
			body: {id: workerId},
			onSuccess: function (res) {
				tgtData = res.data[0];
				for (i = 0; i < textSymbols.length; i++) {
					$(textSymbols[i][1]).val(tgtData[textSymbols[i][0]]);
				}
				for (i = 0; i < checkSymbols.length; i++) {
					$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
				}
				$("#ms_client_id").val(tgtData.client_id);
				$("#ms_worker_client_name").val(tgtData.client_name);
/*
				//変更点[106]
                if($("#m_client_tel").val() == ""){
                        var i,cid = Number($("#m_client_id").val());
                        for(i = 0; i < env.data.clients.length; i++){
                                if(env.data.clients[i]['id']  == cid){
                                        $("#ms_worker_tel2").val(env.data.clients[i]['tel']);
                                        break;
                                }
                        }
                }else{
                        $("#ms_worker_tel2").val($("#m_client_tel").val());
                }
*/
				$("#ms_worker_id").val(tgtData.id);
				$("#ms_worker_recipient_priority").val(tgtData.recipient_priority);
				$("#edit_worker_modal_title").replaceWith($("<span id='edit_worker_modal_title'>取引先担当者編集</span>"));
				$("#edit_worker_modal").modal("show");
			},
		});
	} else {
		for (i = 0; i < textSymbols.length; i++) {
			$(textSymbols[i][1]).val("");
		}
		for (i = 0; i < checkSymbols.length; i++) {
			$(checkSymbols[i][1])[0].checked = checkSymbols[i][2];
		}
		for (i = 0; i < comboSymbols.length; i++) {
			$(comboSymbols[i][1] + " option").each(function (idx, el) {
				if (el.value === env.login_id) {
					el.selected = true;
				} else {
					el.selected = false;
				}
			});
		}
		$("#ms_worker_client_id").val($("#m_client_id").val());
		$("#ms_client_id").val(null);
		$("#ms_worker_client_name").val($("#m_client_name").val());
		/*
		//変更点
		$("ms_worker_tel2").val(tgtData.tel);
		*/
		$("#ms_worker_tel2").val($("#ms_worker_tel2").val() || $("#m_client_tel").val());
		$("#ms_worker_recipient_priority").val(5);
		$("#edit_worker_modal_title").replaceWith($("<span id='edit_worker_modal_title'>新規取引先担当者</span>"));
		$("#edit_worker_modal").modal("show");
	}
}

function genCommitValueOfWorker () {
	var reqObj = {};
	var textSymbols = [
		["id", "#ms_worker_id", Number, null],
		["name", "#ms_worker_name", String],
		["kana", "#ms_worker_kana", String],
		["section", "#ms_worker_section", String, ""],
		["title", "#ms_worker_title", String, ""],
		["tel", "#ms_worker_tel", String, ""],
		["tel2", "#ms_worker_tel2", String, ""],
		["mail1", "#ms_worker_mail1", String, ""],
		["mail2", "#ms_worker_mail2", String, ""],
		["note", "#ms_worker_note", String],
		["client_id", "#ms_worker_client_id", Number],
		["recipient_priority", "#ms_worker_recipient_priority", Number, 5],
	];
	var checkSymbols = [
		["flg_keyperson", "#ms_worker_flg_keyperson", false],
		["flg_sendmail", "#ms_worker_flg_sendmail", true],
	];
	var i;
	var tgtVal;
	for (i = 0; i < textSymbols.length; i++) {
		tgtVal = $(textSymbols[i][1]).val();
		reqObj[textSymbols[i][0]] = textSymbols[i][2](tgtVal);
	}
	for (i = 0; i < checkSymbols.length; i++) {
		tgtVal = $(checkSymbols[i][1])[0].checked;
		reqObj[checkSymbols[i][0]] = tgtVal;
	}
	return reqObj;
}

function commitWorkerObj (workerId) {
	var reqObj = genCommitValueOfWorker();
	if (!workerId) {
		delete reqObj.id;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.worker,
		{
			"id": "ms_worker_id",
			"client_id": "ms_worker_client_id",
			"name": "ms_worker_name",
			"kana": "ms_worker_kana",
			"section": "ms_worker_section",
			"title": "ms_worker_title",
			"tel": "ms_worker_tel",
			"tel2": "ms_worker_tel2",
			"mail1": "ms_worker_mail1",
			"mail2": "ms_worker_mail2",
			"flg_keyperson": "ms_worker_misc_container",
			"flg_sendmail": "ms_worker_misc_container",
			"recipient_priority": "ms_worker_misc_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	if (workerId) {
		c4s.invokeApi_ex({
			location: "client.updateWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1件更新しました");
				$("#edit_client_modal").data("commitCompleted", true);
				$("#edit_worker_modal").modal("hide");
				overwriteClientModalForEdit(reqObj.client_id);
			},
			onError: function (data) {
				alert("更新に失敗しました");
			},
		});
	} else {
		c4s.invokeApi_ex({
			location: "client.createWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1件登録しました");
				$("#edit_client_modal").data("commitCompleted", true);
				$("#edit_worker_modal").modal("hide");
				overwriteClientModalForEdit(reqObj.client_id);
			},
			onError: function (data) {
				alert("登録に失敗しました");
			},
		});
	}
}
//[end] Functions for client modal.

//[begin] Functions for contact modal.
function overwriteContactModalForEdit(clientId, clientName) {
	$("#m_contact_client_id").val(clientId);
	$("#m_contact_client_name").val(clientName);
	$("#m_contact_history tr").remove();
	$("#edit_contact_modal_title").replaceWith("<span id='edit_contact_modal_title'>コンタクト：" + clientName + "</span>");
	var reqBody = {
		client_id_list: [clientId],
	};
	if ($("#m_contact_query_subject").val() !== "" && $("#m_contact_query_subject").val() !== "すべて") {
		reqBody.subject = $("#m_contact_query_subject").val();
	}
	var renderNote = function (jqNode, rawNote) {
		var err, noteObj, noteTxt;
		try {
			noteObj = JSON.parse(rawNote);
		} catch (err) {
			noteTxt = rawNote;
		}
		jqNode.text(noteObj && noteObj.message ? noteObj.message : noteTxt);
		jqNode.append($("<span style='display : none;'></span>").text(noteObj && noteObj.request_id ? noteObj.request_id : "none"));
		return jqNode;
	};
	c4s.invokeApi_ex({
		location: "client.enumContacts",
		body: reqBody,
		onSuccess: function (data) {
			if (data && data.data && data.data[clientId]) {
				var tgtData = data.data[clientId];
				var tgtBody = $("#m_contact_history");
				var i, tgtItem;
				var tmpTr, tmpTd;
				for(i = 0; i < tgtData.length; i++) {
					tgtItem = tgtData[i];
					tmpTr = $("<tr/>");
					tmpTr.appendTo(tgtBody);
					tmpTr[0].id = "iter_contact_" + tgtItem.id;
					$("<td class='center'>" + tgtItem.dt_created + "</td>").appendTo(tmpTr);
					$("<td class='center'>" + tgtItem.subject + "</td>").appendTo(tmpTr);
					renderNote($("<td></td>"), tgtItem.note).appendTo(tmpTr);
					$("<td class='center' title='" + tgtItem.creator.login_id + "'>" + tgtItem.creator.name + "</td>").appendTo(tmpTr);
					$("<td class=\"center\"><span class=\"glyphicon glyphicon-trash text-danger pseudo-link-cursor\" title=\"削除\" onclick=\"c4s.hdlClickDeleteItem('contact', " + tgtItem.id + ", true); $('#edit_contact_modal').data('commitCompleted', true);\"></span></td>").appendTo(tmpTr);
				}
			}
			$("#m_contact_client_id").val(Number(clientId));
			$("#edit_contact_modal").modal("show");
		},
	});
}

function genContactObj() {
	var reqObj = {};
	reqObj.subject = $("#m_contact_subject").val();
	reqObj.note = $("#m_contact_note").val();
	return reqObj;
}

function createContactObj(clientId) {
	var reqBody = genContactObj();
	reqBody.client_id = clientId;
	c4s.invokeApi_ex({
		location: "client.createContact",
		body: reqBody,
		onSuccess: function (data) {
			$("#m_contact_query_subject")[0].selectedIndex = 0;
			overwriteContactModalForEdit(clientId, $("#m_contact_client_name").val());
			$("#edit_contact_modal").data("commitCompleted", true);
		},
	});
}
//[end] Functions for contact modal.

//[begin] Functions for negotiation modal.
function overwriteNegotiationModalForEdit(objId) {
	c4s.clearValidate({
		"name": "m_negotiation_name",
		"client_name": "m_negotiation_client_name",
		"note": "m_negotiation_note",
		"charging_user_id": "m_negotiation_charging_user_id",
		});
	var textSymbols = [
		["id", "#m_negotiation_id"],
		["client_id", "#m_negotiation_client_id"],
		["client_name", "#m_negotiation_client_name"],
		["name", "#m_negotiation_name"],
		["note", "#m_negotiation_note"],
		["dt_negotiation", "#m_negotiation_dt_negotiation"],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [
		["charging_user_id", "#m_negotiation_charging_user_id"],
		["status", "#m_negotiation_status"],
		["business_type", "#m_negotiation_business_type"],
		["phase", "#m_negotiation_phase_0"],
		["phase", "#m_negotiation_phase_1"],
	];
	var radioSymbols = [];
	c4s.invokeApi("negotiation.enumNegotiations", {id: Number(objId)}, function (data) {
		env.recentAjaxResult = data;
		if (data && data.status && data.data
			&& data.status.code == 0
			&& data.data instanceof Array && data.data[0]) {
			var i;
			var tmpEl;
			var tgtData = data.data[0];
			tgtData.client_id = tgtData.client && tgtData.client.id || null;
			tgtData.client_name = tgtData.client_name ||
				(tgtData.client_name == null && tgtData.client && tgtData.client.id ? tgtData.client.name: null);
			tgtData.charging_user_id = tgtData.charging_user.id;
			for (i = 0; i < textSymbols.length; i++) {
				$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
			}
			for (i = 0; i < checkSymbols.length; i++) {
				$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
			}
			for (i = 0; i < comboSymbols.length; i++) {
				$(comboSymbols[i][1])[0].selectedIndex = 0;
				$(comboSymbols[i][1] + " option").each(function (idx, el) {
					if (String(tgtData[comboSymbols[i][0]]) == el.value) {
						el.selected = true;
					}
				});
				$(comboSymbols[i][1]).trigger("change");
			}

			for (i = 0; i < radioSymbols.length; i++) {
				$(radioSymbols[i][1]).each(function (idx, el) {
					if (el.value === tgtData[radioSymbols[i][0]]) {
						el.checked = true;
					}
				});
			}
			$("#m_negotiation_id").val(objId);
			$("#edit_negotiation_modal_title").replaceWith($("<span id='edit_negotiation_modal_title'>商談編集</span>"));
			$("#edit_negotiation_modal").modal("show");
		}
	});
}

function genCommitValueOfNegotiation() {
	var reqObj = {};
	reqObj.dt_negotiation = $("#m_negotiation_dt_negotiation").val();
	if ($("#m_negotiation_client_id").val()) {
		reqObj.client_id = Number($("#m_negotiation_client_id").val());
	} else {
		reqObj.client_name = $("#m_negotiation_client_name").val();
	}
	reqObj.name = $("#m_negotiation_name").val();
	reqObj.charging_user_id = Number($("#m_negotiation_charging_user_id").val());
	reqObj.status = $("#m_negotiation_status").val();
	reqObj.business_type = $("#m_negotiation_business_type").val();
	reqObj.phase = $((function(type) {
		if (type === "SES") {
			return "#m_negotiation_phase_0";
		} else if (type === "受託") {
			return "#m_negotiation_phase_1";
		}
	})(reqObj.business_type)).val();
	reqObj.note = $("#m_negotiation_note").val();
	return reqObj;
}

function commitNegotiation(updateFlg) {
	var reqObj = genCommitValueOfNegotiation();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.negotiation,
		{
			"name": "m_negotiation_name",
			"client_name": "m_negotiation_client_name",
			"note": "m_negotiation_note",
			"charging_user_id": "m_negotiation_charging_user_id",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return;
	}
	if (updateFlg) {
		reqObj.id = Number($("#m_negotiation_id").val());
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "negotiation.updateNegotiation" : "negotiation.createNegotiation",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1件更新しました。" : "1件登録しました。");
			$("#edit_negotiation_modal").data("commitCompleted", true);
			$("#edit_negotiation_modal").modal("hide");
		},
		onError: function (data) {
			alert(updateFlg ? "更新に失敗しました。" : "登録に失敗しました。");
		}
	});
}
//[end] Functions for negotiation modal.

//[begin] Mailing functions.
function openMailFormOfEngineer(engineerId) {
	var reqObj = {};
	reqObj.type_recipient = "forWorker";
	reqObj.recipients = [];
	reqObj.engineers = [engineerId];
	c4s.invokeApi_ex({
		location: "mail.createMail",
		body: reqObj,
		pageMove: true,
		newPage: true,
	});
}

function openMailFormOfProject() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	reqObj.type_recipient = "forWorker";
	reqObj.recipients = [];
	reqObj.projects = [];
	$("input[id^=iter_project_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			reqObj.projects.push(Number(el.id.replace("iter_project_selected_cb_", "")));
		}
	});
	if (reqObj.projects.length > 0) {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: reqObj,
			pageMove: true,
			newPage: true,
		});
	} else {
		alert("対象データを選択してください。");
	}
}

function openReminderFormOfEngineer() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	reqObj.type_recipient = "forMember";
	reqObj.projects = [];
	reqObj.engineers = [];
	$("input[id^=iter_engineer_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			reqObj.engineers.push(Number(el.id.replace("iter_engineer_selected_cb_", "")));
		}
	});
	if (reqObj.engineers.length > 0) {
		c4s.invokeApi_ex({
			location: "mail.createReminder",
			body: reqObj,
			pageMove: true,
			newPage: true,
		});
	} else {
		alert("対象データを選択してください。");
	}
}

function openReminerFormOfProject() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	reqObj.type_recipient = "forMember";
	reqObj.projects = [];
	reqObj.engineers = [];
	$("input[id^=iter_project_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			reqObj.projects.push(Number(el.id.replace("iter_project_selected_cb_", "")));
		}
	});
	if (reqObj.projects.length > 0) {
		c4s.invokeApi_ex({
			location: "mail.createReminder",
			body: reqObj,
			pageMove: true,
			newPage: true,
		});
	} else {
		alert("対象データを選択してください。");
	}
}
//[end] Mailing functions.

//[begin] Button actions.
function deleteItems(dataType) {
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_" + dataType + "_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_" + dataType + "_selected_cb_", "")));
		}
	});
	if (id_list.length > 0) {
		c4s.hdlClickDeleteItem(dataType, id_list, true);
		return true;
	} else {
		alert("対象データを選択してください。");
	}
}

function hdlClickShareProjectToggle(projectId, currentFlg) {
	var reqObj = {};
	reqObj.id = projectId;
	reqObj.flg_shared = currentFlg ? false : true;
	reqObj.update_data_only = true;
	if (confirm((reqObj.flg_shared ? "公開" : "非公開") + "状態に変更しますか？")) {
		c4s.invokeApi_ex({
			location: "project.updateProject",
			body: reqObj,
			onSuccess: function (res) {
				c4s.invokeApi_ex({
					location: env.current,
					body: {
						word : env.recentQuery.word || ""
					},
					pageMove: true,
				});
			},
		});
	}
}

function hdlClickPublicProjectToggle(projectId, currentFlg) {
	var reqObj = {};
	reqObj.word = env.recentQuery.word || "";
	reqObj.id = projectId;
	reqObj.flg_public = currentFlg ? false : true;
	reqObj.update_data_only = true;
	if (confirm((reqObj.flg_public ? "公開" : "非公開") + "状態に変更しますか？")) {
		c4s.invokeApi_ex({
			location: "project.updateProject",
			body: reqObj,
			onSuccess: function (res) {
				var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
                var onSuccessFunc = function () {
					c4s.invokeApi_ex({
						location: env.current,
						body: {
							word : env.recentQuery.word || ""
							},
						pageMove: true,
					});
                };
                if(flg_public_update){
					updateAccountFlgPublic(onSuccessFunc);
				}else{
					onSuccessFunc();
				}
			},
		});
	}
}

function hdlClickPublicEngineerToggle(engineerId, currentFlg) {
	var reqObj = {};
	reqObj.word = env.recentQuery.word || "";
	reqObj.id = engineerId;
	reqObj.flg_public = currentFlg ? false : true;
	reqObj.update_data_only = true;
	if (confirm((reqObj.flg_public ? "公開" : "非公開") + "状態に変更しますか？")) {
		c4s.invokeApi_ex({
			location: "engineer.updateEngineer",
			body: reqObj,
			onSuccess: function (res) {
				var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
                var onSuccessFunc = function () {
					c4s.invokeApi_ex({
						location: env.current,
						body: {
							word : env.recentQuery.word || ""
							},
						pageMove: true,
					});
                };
                if(flg_public_update){
					updateAccountFlgPublic(onSuccessFunc);
				}else{
					onSuccessFunc();
				}
			},
		});
	}
}


function triggerMailOnWorker(idList) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	idList = idList || [];
	$("input[id^=iter_worker_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			idList.push(Number(el.id.replace("iter_worker_selected_cb_", "")));
		}
	});
	if ( idList.length > 0 ) {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: {
				type_recipient: "forWorker",
				recipients: {workers: idList, engineers: []},
			},
			pageMove: true,
			newPage: true,
		});
	} else {
		alert("対象データを選択してください。");
	}
}
//[end] Button actions.



function editProjectSkillCondition(){
	$('#edit_project_skill_condition_modal').modal('show');
}

function viewSelectedProjectSkill() {
	$('[name="m_project_skill_level[]"]').addClass("hidden");
	selectedSkill = $('[name="m_project_skill[]"]:checked').map(function(){
		var targetId = '#m_project_skill_level_' + $(this).val();
		$(targetId).removeClass("hidden");
		var skillLabel = $("#skill_" + $(this).val()).text();
		var skillLevelLabel = $(targetId + " option:selected").text();
		if(skillLevelLabel !== "----"){
			skillLabel += "(" + skillLevelLabel + ")";
		}
  		return skillLabel;
	}).get();
	var viewCount = 5;
	var selectedSkill2 = [];
	if(selectedSkill.length > viewCount){
		for(var i=0; i < viewCount; i++){
			selectedSkill2.push(selectedSkill[i]);
		}
		selectedSkill2.push("...");
	}else{
		selectedSkill2 = selectedSkill;
	}

	if(selectedSkill2.length > 0){
		$("#m_project_skill_container").html(selectedSkill2.join(','));
	}else{
		$("#m_project_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),Oracle,Spring</span>");
	}
}

function editEngineerSkillCondition(){
	$('#edit_engineer_skill_condition_modal').modal('show');
}

function viewSelectedEngineerSkill() {
	$('[name="m_engineer_skill_level[]"]').addClass("hidden");
	selectedSkill = $('[name="m_engineer_skill[]"]:checked').map(function(){
		var targetId = '#m_engineer_skill_level_' + $(this).val();
		$(targetId).removeClass("hidden");
		var skillLabel = $("#skill_" + $(this).val()).text();
		var skillLevelLabel = $(targetId + " option:selected").text();
		if(skillLevelLabel !== "----"){
			skillLabel += "(" + skillLevelLabel + ")";
		}
  		return skillLabel;
	}).get();
	var viewCount = 5;
	var selectedSkill2 = [];
	if(selectedSkill.length > viewCount){
		for(var i=0; i < viewCount; i++){
			selectedSkill2.push(selectedSkill[i]);
		}
		selectedSkill2.push("...");
	}else{
		selectedSkill2 = selectedSkill;
	}

	if(selectedSkill2.length > 0){
		$("#m_engineer_skill_container").html(selectedSkill2.join(','));
	}else{
		$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),PHP(1年～2年)</span>");
	}
}

function triggerSearchProject(engineerId) {

	if (engineerId) {

		c4s.invokeApi_ex({
			location: "matching.project",
			body: {
				engineer_id: engineerId
			},
			pageMove: true
		});

	} else {
		return false;
	}
}


function triggerSearchEngineer(projectId) {

	if(!projectId){
		projectId = $("#m_project_id").val();
		if(projectId){
			projectId = parseInt(projectId);
		}
	}

	if (projectId && projectId != "") {

		c4s.invokeApi_ex({
			location: "matching.engineer",
			body: {
				project_id: projectId,
			},
			pageMove: true
		});


	} else {
		return false;
	}
}


function deleteRelatedEngineer(engineer_id, project_id){

	if (confirm("担当から外してよろしいですか？")) {

		var reqObj = {
			login_id: env.login_id,
			credential: env.credential,
			prefix: env.prefix,
			selected_engineer_id: engineer_id,
			selected_project_id: project_id,
		};

		c4s.invokeApi_ex({
			location: "matching.disconnectEngineerFromProject",
			body: reqObj,
			onSuccess: function (data) {
				alert("１件削除しました。");
				getRelatedEngineer(project_id);

			}
        });
    }

}

function getRelatedEngineer(project_id) {

	var reqObj = {
			login_id: env.login_id,
			credential: env.credential,
			prefix: env.prefix,
			id: project_id,
		};

	c4s.invokeApi_ex({
		location: "engineer.enumEngineersRelatedProject",
		body: reqObj,
		onSuccess: function (data) {

			var str = "";
			for(var idx = 0; idx < data.data.length; idx++) {
				// タグを作成
				str += "<tr><td class=\"center\">" + data.data[idx].name + "</td><td class=\"center\">" + data.data[idx].tel
					+ "</td><td class=\"center\">" + data.data[idx].mail1 + "</td><td class=\"center\">"
					+ "<span class=\"pseudo-link-cursor glyphicon glyphicon-trash text-danger\" alt=\"削除\" title=\"削除\""
                    + "onclick=\"deleteRelatedEngineer(" + data.data[idx].id + "," + project_id + ");\"></span>"
					+ "</td></tr>";
			}
			if(str == ""){
				str = "<tr><td colspan=\"4\">誰もアサインされていません。</td></tr>";
			}
			$("#assign_engineer_list").html(str);
		},
	});
}



function editProjectStationCondition(){
	$('#edit_project_station_condition_modal').modal('show');
}

var xml = {};
function setProjectMenuItem(type, code, selected_line, selected_station) {

    var s = document.getElementsByTagName("head")[0].appendChild(document.createElement("script"));
    s.type = "text/javascript";
    s.charset = "utf-8";


    if (type == 0) {
    	$('#ps0 > option').remove();
		$('#ps1 > option').remove();
		$('#ps1').append($('<option>').html("----").val(0));

        if (code == 0) {
			$('#ps0').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/p/" + code + ".json";
        }
    } else if(type == 1) {
        $('#ps1 > option').remove();
        if (code == 0) {
			$('#ps1').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/l/" + code + ".json";
        }
    } else{
    	s.src = "http://www.ekidata.jp/api/s/" + code + ".json";
	}
    xml.onload = function (data) {
        var line = data["line"];
        var station_l = data["station_l"];
        var station = data["station"];

        if (line != null) {
			$('#ps0').append($('<option>').html("----").val(0));
            for (i = 0; i < line.length; i++) {
                ii = i + 1;
                var op_line_name = line[i].line_name;
                var op_line_cd = line[i].line_cd;
                var op_obj = $('<option>').html(op_line_name).val(op_line_cd);
                if(selected_line && op_line_cd == selected_line){
                	op_obj.prop('selected', true);
				}
                $('#ps0').append(op_obj);
            }
        }
        if (station_l != null) {
			$('#ps1').append($('<option>').html("----").val(0));
            for (i = 0; i < station_l.length; i++) {
                ii = i + 1;
                var op_station_name = station_l[i].station_name;
                var op_station_cd = station_l[i].station_cd;
                var op_obj = $('<option>').html(op_station_name).val(op_station_cd);
                if(selected_station && op_station_cd == selected_station){
                	op_obj.prop('selected', true);
				}
                $('#ps1').append(op_obj);
            }
        }
        if(station != null){
        	var station_info = station[0];
        	$("#m_project_station_cd").val(station_info.station_cd);
        	$("#m_project_station_pref_cd").val(station_info.pref_cd);
        	$("#m_project_station_line_cd").val(station_info.line_cd);
        	$("#m_project_station_lon").val(station_info.lon);
        	$("#m_project_station_lat").val(station_info.lat);
        	$("#m_project_station").val(station_info.station_name);

		}
    }
}

function editEngineerStationCondition(){
	$('#edit_engineer_station_condition_modal').modal('show');
}

function setEngineerMenuItem(type, code, selected_line, selected_station) {

    var s = document.getElementsByTagName("head")[0].appendChild(document.createElement("script"));
    s.type = "text/javascript";
    s.charset = "utf-8";


    if (type == 0) {
    	$('#es0 > option').remove();
		$('#es1 > option').remove();
		$('#es1').append($('<option>').html("----").val(0));

        if (code == 0) {
			$('#es0').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/p/" + code + ".json";
        }
    } else if(type == 1) {
        $('#es1 > option').remove();
        if (code == 0) {
			$('#es1').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/l/" + code + ".json";
        }
    } else{
    	s.src = "http://www.ekidata.jp/api/s/" + code + ".json";
	}
    xml.onload = function (data) {
        var line = data["line"];
        var station_l = data["station_l"];
        var station = data["station"];

        if (line != null) {
			$('#es0').append($('<option>').html("----").val(0));
            for (i = 0; i < line.length; i++) {
                ii = i + 1;
                var op_line_name = line[i].line_name;
                var op_line_cd = line[i].line_cd;
                var op_obj = $('<option>').html(op_line_name).val(op_line_cd);
                if(selected_line && op_line_cd == selected_line){
                	op_obj.prop('selected', true);
				}
                $('#es0').append(op_obj);
            }
        }
        if (station_l != null) {
			$('#es1').append($('<option>').html("----").val(0));
            for (i = 0; i < station_l.length; i++) {
                ii = i + 1;
                var op_station_name = station_l[i].station_name;
                var op_station_cd = station_l[i].station_cd;
                var op_obj = $('<option>').html(op_station_name).val(op_station_cd);
                if(selected_station && op_station_cd == selected_station){
                	op_obj.prop('selected', true);
				}
                $('#es1').append(op_obj);
            }
        }
        if(station != null){
        	var station_info = station[0];
        	$("#m_engineer_station_cd").val(station_info.station_cd);
            $("#m_engineer_station_pref_cd").val(station_info.pref_cd);
            $("#m_engineer_station_line_cd").val(station_info.line_cd);
            $("#m_engineer_station_lon").val(station_info.lon);
            $("#m_engineer_station_lat").val(station_info.lat);
            $("#m_engineer_station").val(station_info.station_name);
		}
    }
}


$("#m_project_term_begin, #m_project_term_end, #m_engineer_operation_begin").datepicker({
	weekStart: 1,
	viewMode: "dates",
	language: "ja",
	autoclose: true,
	changeYear: true,
	changeMonth: true,
	dateFormat: "yyyy/mm/dd",
})

function validateCondition(reqObj){

	$("#m_project_term_begin").parent().parent().parent().parent().removeClass("has-error");
	$("#m_project_term_end").parent().parent().parent().parent().removeClass("has-error");
	if(reqObj.term_begin && reqObj.term_end){
		if(reqObj.term_begin > reqObj.term_end){
			alert("期間の終了日付は開始日付をより後の日にしてください");
			$("#m_project_term_end").focus();
			$("#m_project_term_begin").parent().parent().parent().parent().addClass("has-error");
			$("#m_project_term_end").parent().parent().parent().parent().addClass("has-error");
			return true;
		}
	}

	$("#m_project_age_from").parent().parent().parent().parent().removeClass("has-error");
	$("#m_project_age_to").parent().parent().parent().parent().removeClass("has-error");
	if(reqObj.age_from && reqObj.age_to){
		if(Number(reqObj.age_from) > Number(reqObj.age_to)){
			alert("年齢の最大値は最小値をより大きくしてください");
			$("#m_project_age_to").focus();
			$("#m_project_age_from").parent().parent().parent().parent().addClass("has-error");
			$("#m_project_age_to").parent().parent().parent().parent().addClass("has-error");
			return true;
		}
	}

	return false;
}

function showAddNewClientModal(mode) {

	c4s.clearValidate({
		"name": "new_client_name",
		"kana": "new_client_kana",
		"addr_vip": "new_client_addr_vip_container",
		"addr1": "new_client_addr1",
		"addr2": "new_client_addr2",
		"tel": "new_client_tel",
		"fax": "new_client_fax",
		"site": "new_client_site",
		"type_presentation": "new_client_type_presentation_container",
	});
	// [begin] Clear fields.
	$("#new_client_addr1_alert").html("");
	var textSymbols = [
		"#new_client_name",
		"#new_client_kana",
		"#new_client_addr_vip",
		"#new_client_addr1",
		"#new_client_addr2",
		"#new_client_tel",
		"#new_client_fax",
		"#new_client_site",
		"#new_client_note",
	];
	var checkSymbols = [
		"#new_client_type_presentation_0",
		"#new_client_type_presentation_1",
	];
	var comboSymbols = [
		"#new_client_type_dealing",
		"#new_client_charging_worker1",
		"#new_client_charging_worker2",
	];
	var radioSymbols = [
		/*"[name=m_client_gender_grp]",*/
	];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		if (textSymbols[i] instanceof Array) {
			$(textSymbols[i][0])[0].value = textSymbols[i][1];
		} else {
			$(textSymbols[i])[0].value = "";
		}
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = false;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$("#new_client_charging_worker1").val(env.userProfile.user.id);
	$("#new_client_type_dealing")[0].selectedIndex = 1;

	$("#add_new_client_modal").modal('show');
	$("#add_new_client_mode").val(mode);
}

function commitNewClient() {
	var reqObj = genCommitValueOfNewClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "new_client_name",
			"kana": "new_client_kana",
			"addr_vip": "new_client_addr_vip",
			"addr1": "new_client_addr1",
			"addr2": "new_client_addr2",
			"tel": "new_client_tel",
			"fax": "new_client_fax",
			"site": "new_client_site",
			"type_presentation": "new_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return false;
	}
	c4s.invokeApi_ex({
		location: "client.createClient",
		body: reqObj,
		onSuccess: function (data) {
			alert("1件登録しました。");
			setNewClientOption(data.data.id, reqObj.name);
			$("#add_new_client_modal").modal("hide");
		},
		onError: function (data) {
			alert("登録に失敗しました。");
		}
	});
}

function genCommitValueOfNewClient () {
	var reqObj = {};
	var textSymbols = [
		["#new_client_id", Number],
		["#new_client_name", String, ""],
		["#new_client_kana", String, ""],
		["#new_client_addr_vip", String, ""],
		["#new_client_addr1", String, ""],
		["#new_client_addr2", String, ""],
		["#new_client_tel", String, ""],
		["#new_client_fax", String, ""],
		["#new_client_site", String, ""],
		["#new_client_note", String, ""],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [
		["#new_client_type_dealing", String],
		["#new_client_charging_worker1", Number],
		["#new_client_charging_worker2", Number],
	];
	var radioSymbols = [];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		if (tmpEl.val()) {
			reqObj[tmpEl.attr("id").replace("new_client_", "")] = textSymbols[i][1](tmpEl.val());
		} else if (tmpEl.val() === "" && textSymbols[i].length == 3) {
			reqObj[tmpEl.attr("id").replace("new_client_", "")] = textSymbols[i][1](textSymbols[i][2]);
		}
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("new_client_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("new_client_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("new_client_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("new_client_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	// [begin] Variable filters.
	reqObj.charging_worker1 = reqObj.charging_worker1 || null;
	reqObj.charging_worker2 = reqObj.charging_worker2 || null;
	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}
	reqObj.type_presentation = [];
	$("[id^=new_client_type_presentation_]").each(function (idx, el) {
		if (el.checked) {
			reqObj.type_presentation.push(el.value);
		}
	});
	// [end] Variable filters.
	env.debugOut(reqObj);
	return reqObj;
}

function setNewClientOption(client_id, client_name){

	var mode = $("#add_new_client_mode").val();

	$("#m_project_client_id").append('<option value="' + client_id + '">' + client_name + '</option>');
	$("#m_engineer_client_id").append('<option value="' + client_id + '">' + client_name + '</option>');

	switch(mode){
		case "engineer":
			$('#m_engineer_client_id').val(client_id);
			$('#m_engineer_client_id').select2({allowClear: true});

			break;
		case "project":
			$('#m_project_client_id').val(client_id);
			$('#m_project_client_id').select2();
			break;
	}

}

function confirmAccountFlgPublic(current_flg_public){
	var flg_public_update = false;
	if(current_flg_public && !env.companyInfo.flg_public) {
		if (confirm("貴社アカウントでマッチング用公開設定が非公開になっているため、このままでは他社に公開されません。\n合わせて公開設定に変更しますか。")) {
			flg_public_update = true;
		}
	}
	return flg_public_update;
}

function updateAccountFlgPublic(onSuccessFunc) {

	var reqObj = {};
	reqObj.value = 1;
	reqObj.prefix = env.prefix;
	c4s.invokeApi_ex({
		location: "manage.updateFlgPublic",
		body: reqObj,
		onSuccess: function(data) {
			alert("更新しました");
			if(onSuccessFunc){
				onSuccessFunc();
			}
		},
	});
}

$(function() {
   $('.input-file').on('change', function() {
	   var file_name = $(this).prop('files')[0].name;
	   if(file_name != ""){
		   $(".input-file-message").addClass("hidden");
	   }else{
		   $(".input-file-message").removeClass("hidden");
	   }
   });
});

function formatForView(val){
    return val.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
}

function formatForCalc(val) {

    if (val === undefined || val === "") {
        return 0;
    }

    val = val.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function (s) {
        return String.fromCharCode(s.charCodeAt(0) - 65248);
    });
    val = val.replace(/,/g, '');

    val = parseInt(val);

    if (val === "" || isNaN(val)) {
        return 0;
    }

    return val;
}

function addComma(target) {

    var val = $(target).val();

    if (val === undefined || val === "") {
        return;
    }

    val = formatForCalc(val);

    $(target).val(formatForView(val));
}

function genSkillList(type) {
	if (type === "engineer") {
		var is_sort = $('#m_skill_sort')[0].checked ? 1 : 0;
		$('#skill_list').empty();
	} else {
		var is_sort = $('#m_project_skill_sort')[0].checked ? 1 : 0;
		$('#project_skill_list').empty();
	}
	c4s.invokeApi_ex({
		location: "skill.enumSkills",
		body: {is_sort: is_sort},
		onSuccess: function(data) {
			if (data.data) {
				if (type === "engineer") {
					var html = '';
					$.each(env.data.skillCategories, function(index, category) {
						var loop_idx = index + 1;
						html += '<div id="engineer_skill_categories_header_'+ loop_idx +'" style="border-bottom: 1px solid #e5e5e5; margin-bottom: 10px;margin-top: 10px"><label>'+ category +'</label></div>';
						html += '<table class="">';
						$.each(data.data, function(sIndex, skill) {
							if (category == skill.category_name) {
								html += '<tr>';
								html += '<td>';
								html += '<input type="checkbox" name="m_engineer_skill[]" id="engineer_skill_label_'+ skill.id +'" class="search-chk" onchange="viewSelectedEngineerSkill();" value="'+ skill.id +'">';
								html += '<label id="skill_'+ skill.id +'" for="engineer_skill_label_'+ skill.id +'" style="font-weight: normal; margin: 0px">'+ skill.name +'</label>'
								html += '</td>';
								html += '<td>';
								html += '<select id="m_engineer_skill_level_'+ skill.id +'" name="m_engineer_skill_level[]" value="" class="" onchange="viewSelectedEngineerSkill();">';
								html += '<option value="0">----</option>';
								$.each(env.data.skillLevels, function(lIndex, level) {
									html += '<option value="'+ level.level +'">'+ level.name +'</option>'
								});
								html += '</option>';
								html += '</td>';
								html += '</tr>';
							}
						});
						html += '</table>';
					});
					$('#skill_list').append(html);
					if(skill_id_list){
						$('[name="m_engineer_skill[]"]').each(function (index) {
		                    var setval = $(this).val();
		                    var skillArr = skill_id_list.split(",");
		                    if (skillArr.indexOf(setval) >= 0) {
								$(this).val([setval]);
								$('#m_engineer_skill_level_' + setval).removeClass("hidden");
								skill_level_list.forEach(function(e, i, a) {
									if(setval == e["skill_id"]){
										$("#m_engineer_skill_level_" + setval).val(e["level"]);
									}
								})
		                    }
		                });
					}
					viewSelectedEngineerSkill();
				} else {
					var html = '';
					$.each(env.data.skillCategories, function(index, category) {
						var loop_idx = index + 1;
						html += '<div id="project_skill_categories_header_'+ loop_idx +'" style="border-bottom: 1px solid #e5e5e5; margin-bottom: 10px;margin-top: 10px"><label>'+ category +'</label></div>';
						html += '<table class="">';
						$.each(data.data, function(sIndex, skill) {
							if (category == skill.category_name) {
								html += '<tr>';
								html += '<td>';
								html += '<input type="checkbox" name="m_project_skill[]" id="project_skill_label_'+ skill.id +'" class="search-chk" onchange="viewSelectedProjectSkill();" value="'+ skill.id +'">';
								html += '<label id="skill_'+ skill.id +'" for="project_skill_label_'+ skill.id +'" style="font-weight: normal; margin: 0px">'+ skill.name +'</label>'
								html += '</td>';
								html += '<td>';
								html += '<select id="m_project_skill_level_'+ skill.id +'" name="m_project_skill_level[]" value="" class="" onchange="viewSelectedProjectSkill();">';
								html += '<option value="0">----</option>';
								$.each(env.data.skillLevels, function(lIndex, level) {
									html += '<option value="'+ level.level +'">'+ level.name +'</option>'
								});
								html += '</option>';
								html += '</td>';
								html += '</tr>';
							}
						});
						html += '</table>';
					});
					$('#project_skill_list').append(html);
					if(project_skill_id_list){
						$('[name="m_project_skill[]"]').each(function (index) {
		                    var setval = $(this).val();
		                    var skillArr = project_skill_id_list.split(",");
		                    if (skillArr.indexOf(setval) >= 0) {
								$(this).val([setval]);
								$('#m_project_skill_level_' + setval).removeClass("hidden");
								project_skill_level_list.forEach(function(e, i, a) {
									if(setval == e["skill_id"]){
										$("#m_project_skill_level_" + setval).val(e["level"]);
									}
								})
		                    }
		                });
					}
					viewSelectedProjectSkill();
				}
			}
		},
		onError: function(data) {
			alert("更新に失敗しました。（" + data.status.description + "）")
		},
	});
}

$(document).on('change', '#m_skill_sort', function() {
	genSkillList("engineer");
});

$(document).on('change', '#m_project_skill_sort', function() {
	genSkillList("project");
});

function exportPdfEngineer()
{
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_engineer_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_engineer_selected_cb_", "")));
		}
	});

	if (id_list.length <= 0) {
		alert("対象データを選択してください。");
		return false;
	}
	reqObj = {
		prefix: env.prefix,
		id_list: id_list
	}
	var h = $(window).height();
    $('#loader-bg2 ,#loader2').height(h).css('display','block');
	downloadLoadingTimer = setInterval(function () {
        var cookieData = c4s.getCookies();
        var downloadCookie = cookieData["downloaded"];
        if(downloadCookie != undefined && downloadCookie == "yes"){
            c4s.setCookies("downloaded", "no");
            clearInterval(downloadLoadingTimer);
            // c4s.sleep(2500);
            $('#loader-bg2').delay(150).fadeOut(130);
            $('#loader2').delay(100).fadeOut(50);
        }
    }, 100);
	c4s.invokeApi_ex({
		location: "quotation.downloadPdfEngineer",
		body: reqObj,
        pageMove: true,
        newPage: false
	});
}

function exportPdfProject()
{
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_project_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_project_selected_cb_", "")));
		}
	});

	if (id_list.length <= 0) {
		alert("対象データを選択してください。");
		return false;
	}
	reqObj = {
		prefix: env.prefix,
		id_list: id_list
	}
	var h = $(window).height();
    $('#loader-bg2 ,#loader2').height(h).css('display','block');
	downloadLoadingTimer = setInterval(function () {
        var cookieData = c4s.getCookies();
        var downloadCookie = cookieData["downloaded"];
        if(downloadCookie != undefined && downloadCookie == "yes"){
            c4s.setCookies("downloaded", "no");
            clearInterval(downloadLoadingTimer);
            // c4s.sleep(2500);
            $('#loader-bg2').delay(150).fadeOut(130);
            $('#loader2').delay(100).fadeOut(50);
        }
    }, 100);
	c4s.invokeApi_ex({
		location: "quotation.downloadPdfProject",
		body: reqObj,
        pageMove: true,
        newPage: false
	});
}

$(document).on('click', '.video-click', function() {
	c4s.hdlClickVideoBtn('home');
});
