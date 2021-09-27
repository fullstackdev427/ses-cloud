function genFilterQuery (reqObj) {
	reqObj = reqObj || {};
	var i, key, value;
	// [begin] common.
	var texts = $("input[id^=query_][type=text]");
	texts.each(function (idx, el) {
		if (el.value) {
			reqObj[el.attributes['id'].value.replace("query_", "")] = el.value;
		}
	});
	// [end] common.
	// [begin] contract.
	var contract = $("#query_contract")[0];
	if (contract.selectedIndex != 0) {
		reqObj['contract'] = contract.selectedOptions[0].value;
	}
	// [end] contract.
	// [begin] flags.
	var flags = $("input[id^=query_flg][type=checkbox]");
	flags.each(function (idx, el) {
		if (el.checked) {
			reqObj[el.attributes['id'].value.replace("query_", "")] = true;
		}
	});
	// [end] flags.
	return reqObj;
}

function genOrderQuery (reqObj) {
	reqObj = reqObj || {};
	return reqObj;
}

function deleteItems () {
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_engineer_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_engineer_selected_cb_", "")));
		}
	});
	c4s.hdlClickDeleteItem("engineer", id_list, true);
}

var skill_id_list;
var skill_level_list;

function hdlClickNewObj () {
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


	setMenuItem(0, 0, null, null);
	$("#s").val(0);

	$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>新規要員登録</span>"));
	deleteAttachment(0);
	$("#edit_engineer_modal").modal("show");
	$('#m_engineer_client_id').select2({allowClear: true});
	$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),PHP(1年～2年)</span>");
	$('#m_skill_sort')[0].checked = false
	skill_id_list = '';
	skill_level_list = [];
}

function genCommitValue() {
	var reqObj = {};

    reqObj.fee = formatForCalc($("#m_engineer_fee").val());

	var textSymbols = [
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
		["#m_engineer_client_id", Number],
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

function overwriteModalForEdit(objId) {
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
		"note": "m_engineer_internal_note",
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
		["internal_note", "#m_engineer_internal_note"],
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
		["web_public", "#m_engineer_web_public"],
		["flg_careful", "#m_engineer_flg_careful"],
	];
	var comboSymbols = [
		["contract", "#m_engineer_contract"],
		["client_id", "#m_engineer_client_id"],
	];
	var radioSymbols = [
		["gender", "[name=m_engineer_gender_grp]"],
	];
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
				$("#s").val(tgtData.station_pref_cd);
				setMenuItem(0, tgtData.station_pref_cd, tgtData.station_line_cd, tgtData.station_cd);
				setMenuItem(1, tgtData.station_line_cd, tgtData.station_line_cd, tgtData.station_cd);
			}
			$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>要員編集</span>"));
			$("#edit_engineer_modal").modal("show");
			$('#m_engineer_client_id').select2({allowClear: true});
		}
	});
}

function commitNewObj() {
	var reqObj = genCommitValue();
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
			delete env.recentQuery.openNewModal;
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
			alert("登録に失敗しました。（" + data.status.description + "）")
		},
	});
}

function updateObj () {
	var oldObj = env.recentAjaxResult.data[0];
	var newObj = genCommitValue();
	console.log("--newObj" + JSON.stringify(newObj));
    console.log("--oldObj" + JSON.stringify(oldObj));
    
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
	console.log("--reqObj" + JSON.stringify(reqObj));
    return;
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

function deleteAttachment(loop_idx) {
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

function uploadFile(loop_idx) {
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
					console.log(data);
					if (data && data.data && data.data.id && data.status.code == 0) {
						fileIdEl.val(data.data.id);
						labelEl.html(data.data.filename + "&nbsp;(<span class='mono'>" + data.data.size + "bytes</span>)");
						labelEl.css("display", "inline");
						fileInputEl.css("display", "none");
						commitBtnEl.css("display", "inline");
						deleteBtnEl.css("display", "inline");
						// Ryo_0212_Add
						$(".input-file-message").addClass("hidden");
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

function download(id) {
	/*
	var form = $("<form/>")[0];
	form.enctype = "application/json";
	form.action = "/" + env.prefix + "/api/file.download/json";
	form.method = "POST";
	form.target = "_blank";
	var json = $("<input type='hidden' name='json'/>")[0];
	json.value = JSON.stringify({
		login_id: env.login_id,
		credential: env.credential,
		id: id,
	});
	form.appendChild(json);
	form.submit();
	*/
	window.console.log("[Deplicated] OLD download() on engineer.js is used.");
	c4s.download(id);
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
		"client_name": "m_preparation_client_name",
		"time": "m_preparation_time",
		"progress": "m_preparation_progress",
		"note": "m_preparation_note",
	});
	$("#m_preparation_engineer_id").val(engineerId);
	$("#m_preparation_id").val(null);
	$("#m_preparation_client_id").val(null);
	$("#m_preparation_client_name").val(null);
	$("#m_preparation_time").val(null);
	$("#m_preparation_progress").val(null);
	$("#m_preparation_note").val(null);
	$("#m_preparation_client_name")[0].readOnly = false;
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
			ctmp = env.data.clients.filter(function (val, idx, arr) {
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
		td = $("<td class='center'><span class='glyphicon glyphicon-trash text-danger pseudo-link-cursor' onclick='c4s.hdlClickDeleteItem(\"preparation\", " + tmp.id + ", true); $(\"#edit_preparation_modal\").data(\"commitCompleted\", true);'></span></td>");
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
		"client_name": "m_preparation_client_name",
		"time": "m_preparation_time",
		"progress": "m_preparation_progress",
		"note": "m_preparation_note",
	});
	if (prepObj) {
		$("#m_preparation_id").val(prepObj.id);
		$("#m_preparation_client_id").val(prepObj.client_id);
		$("#m_preparation_client_name").val(prepObj.client_name || env.data.clients.filter(function (val) { return val.id == prepObj.client_id ;})[0].name);
		$("#m_preparation_time").val(prepObj.time);
		$("#m_preparation_progress").val(prepObj.progress);
		$("#m_preparation_note").val(prepObj.note);
	}
}

function commitPreparation() {
	var reqObj = {};
	reqObj.id = $("#m_preparation_id").val() || null;
	reqObj.engineer_id = Number($("#m_preparation_engineer_id").val());
	reqObj.client_id = $("#m_preparation_client_id").val() || null;
	reqObj.client_name = $("#m_preparation_client_name").val();
	reqObj.time = $("#m_preparation_time").val();
	reqObj.progress = $("#m_preparation_progress").val();
	reqObj.note = $("#m_preparation_note").val();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.preparation,
		{
			"client_name": "m_preparation_client_name",
			"time": "m_preparation_time",
			"progress": "m_preparation_progress",
			"note": "m_preparation_note",
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
		alert("入力を確認てください");
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
			$("#edit_negotiation_modal").data("commitCompleted", true);
			hdlEditPreparation(reqObj.engineer_id);
		},
	});
}

function openMailForm(recipientId) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var recipients = [];
	if (recipientId) {
		recipients.push(recipientId);
	} else {
		$("input[id^=iter_engineer_selected_cb_]").each(function (idx, el, arr) {
			if (el.checked) {
				recipients.push(Number(el.id.replace("iter_engineer_selected_cb_", "")));
			}
		});
	}
	if (recipients.length > 0 ) {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: {
				engineers: recipients,
				type_recipient: "forWorker",
				type_iterator_default: "技術者情報",
			},
			pageMove: true,
			newPage: true,
		});
	} else {
		alert("対象データを選択してください。");
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


$(document).ready(function () {
	$("#m_engineer_birth").datepicker({
		weekStart: 1,
		language: "ja",
		autoclose: true,
		changeYear: true,
		changeMonth: true,
		dateFormat: "yyyy/mm/dd",
	});
	$("#m_engineer_birth").datepicker("setDate", "-30y");
	$("#m_engineer_operation_begin").datepicker({
		weekStart: 1,
		viewMode: "dates",
		language: "ja",
		autoclose: true,
		changeYear: true,
		changeMonth: true,
		dateFormat: "yyyy/mm/dd",
	});
	$("#m_engineer_birth").on("hide", function() {
		updateAge();
	});
	c4s.invokeApi_ex({
		location: "engineer.enumEngineers",
		body: {},
		onSuccess: function(data) {
			env.data = env.data || {};
			env.data.engineers = data.data;
		},
	});
	c4s.invokeApi_ex({
		location: "client.enumClients",
		body: {},
		onSuccess: function(data) {
			env.data = env.data || {};
			env.data.clients = data.data;
		},
	});
	env.ak_client = new AutoKana("m_engineer_name", "m_engineer_kana", {katakana: true});
	$("#m_preparation_client_name").autocomplete({
		source: env.data.clients.map(function (val, idx, arr) {
			return {label: val.name, id: val.id};
		}),
		select: function (evt, item) {
			console.log(item);
			if (item.item) {
				$("#m_preparation_client_id").val(item.item.id);
			} else {
				$("#m_preparation_client_id").val(null);
			}
		},
	});
	$("#m_engineer_client_name").autocomplete({
		source: env.data.clients.map(function (val, idx, arr) {
			return {label: val.name, id: val.id};
		}),
		select: function (evt, item) {
			console.log(item);
			if (item.item) {
				$("#m_engineer_client_id").val(item.item.id);
			} else {
				$("#m_engineer_client_id").val(null);
			}
		},
	});
	env.ak_client = new AutoKana("new_client_name", "new_client_kana", {katakana: true});
	$("#new_client_name").on("blur", function (evt) {
		$("#new_client_kana").val($("#new_client_kana").val().replace("カブシキガイシャ", "").replace("ユウゲンガイシャ", "").replace("ゴウドウガイシャ", ""));
	});

	$("#edit_engineer_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_preparation_modal").on("show.bs.modal", function(evt) {
		$(evt.currentTarget).data("commitCompleted", false);
	});
	$("#edit_engineer_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	$("#edit_preparation_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	// [begin] Set onload view state.
	if (env.recentQuery.modal) {
		switch (env.recentQuery.modal) {
			case "createEngineer":
				hdlClickNewObj();
				break;
			case "editEngineer":
				if (env.recentQuery.id) {
					overwriteModalForEdit(env.recentQuery.id);
				}
				break;
			default:
				break;
		}
	}
	if (env.recentQuery.openNewModal) {
		hdlClickNewObj();
	}
	// [end] Set onload view state.
});

function editSkillCondition(){
	// genSkillList();
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

function editStationCondition(){
	$('#edit_station_condition_modal').modal('show');
}

var xml = {};
function setMenuItem(type, code, selected_line, selected_station) {

    var s = document.getElementsByTagName("head")[0].appendChild(document.createElement("script"));
    s.type = "text/javascript";
    s.charset = "utf-8";


    if (type == 0) {
        $('#s0 > option').remove();
        $('#s1 > option').remove();
        $('#s1').append($('<option>').html("----").val(0));

        if (code == 0) {
            $('#s0').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/p/" + code + ".json";
        }
    } else if (type == 1) {
        $('#s1 > option').remove();
        if (code == 0) {
            $('#s1').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/l/" + code + ".json";
        }
    } else {
        s.src = "http://www.ekidata.jp/api/s/" + code + ".json";
    }
    xml.onload = function (data) {
        var line = data["line"];
        var station_l = data["station_l"];
        var station = data["station"];

        if (line != null) {
            $('#s0').append($('<option>').html("----").val(0));
            for (i = 0; i < line.length; i++) {
                ii = i + 1;
                var op_line_name = line[i].line_name;
                var op_line_cd = line[i].line_cd;
                var op_obj = $('<option>').html(op_line_name).val(op_line_cd);
                if (selected_line && op_line_cd == selected_line) {
                    op_obj.prop('selected', true);
                }
                $('#s0').append(op_obj);
            }
        }
        if (station_l != null) {
            $('#s1').append($('<option>').html("----").val(0));
            for (i = 0; i < station_l.length; i++) {
                ii = i + 1;
                var op_station_name = station_l[i].station_name;
                var op_station_cd = station_l[i].station_cd;
                var op_obj = $('<option>').html(op_station_name).val(op_station_cd);
                if (selected_station && op_station_cd == selected_station) {
                    op_obj.prop('selected', true);
                }
                $('#s1').append(op_obj);
            }
        }
        if (station != null) {
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


function showAddNewClientModal() {

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

	$("#add_new_engineer_client_modal").modal('show');
}

function commitEngineerClient() {
	var reqObj = genCommitValueOfEngineerClient();
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
			$("#add_new_engineer_client_modal").modal("hide");
		},
		onError: function (data) {
			alert("登録に失敗しました。");
		}
	});
}

function genCommitValueOfEngineerClient () {
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
	$("#m_engineer_client_id").append('<option value="' + client_id + '">' + client_name + '</option>');
	$('#m_engineer_client_id').val(client_id);
	$('#m_engineer_client_id').select2({allowClear: true});
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

function confirmAccountFlgPublic(current_flg_public){
	var flg_public_update = false;
	if(current_flg_public && !env.companyInfo.flg_public) {
		if (confirm("貴社アカウントでマッチング用公開設定が非公開になっているため、このままでは他社に公開されません。\n合わせて公開設定に変更しますか。")) {
			flg_public_update = true;
		}
	}
	return flg_public_update;
}
// Ryo_Add 0220
// function confirmAccountFlgPublic(current_flg_public, current_web_public){
// 	var flg_public_update = false;
// 	if(current_flg_public && !env.companyInfo.flg_public) {
// 		if (confirm("貴社アカウントでマッチング用公開設定が非公開になっているため、このままでは他社に公開されません。\n合わせて公開設定に変更しますか。")) {
// 			flg_public_update = true;
// 		}
// 	}
// 	if(current_web_public && !env.companyInfo.web_public) {
// 		flg_public_update = true;
// 	}
// 	return flg_public_update;
// }

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
		   //$(".input-file-message").addClass("hidden");
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

function genSkillList() {
	var is_sort = $('#m_skill_sort')[0].checked ? 1 : 0;
	var skill_type = $('#skill_type').val();
	$('#skill_list').empty();
	c4s.invokeApi_ex({
		location: "skill.enumSkills",
		body: {is_sort: is_sort},
		onSuccess: function(data) {
			if (data.data) {
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
							if (skill_type =='engineer.top') {
								$.each(env.data.skillLevels, function(lIndex, level) {
									if (level.name != '未経験') {
										html += '<option value="'+ level.level +'">'+ level.name +'</option>'
									}
								});
							} else {
								$.each(env.data.skillLevels, function(lIndex, level) {
									html += '<option value="'+ level.level +'">'+ level.name +'</option>'
								});
							}
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
			}
		},
		onError: function(data) {
			alert("更新に失敗しました。（" + data.status.description + "）")
		},
	});
}

$(document).on('change', '#m_skill_sort', function() {
	genSkillList();
});

function exportPdf()
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
