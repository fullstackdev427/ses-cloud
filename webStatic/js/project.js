function deleteItems () {
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_project_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_project_selected_cb_", "")));
		}
	});
	if (c4s.hdlClickDeleteItem("project", id_list, false)) {
		c4s.invokeApi_ex({
			location: env.current,
			body: env.recentQuery,
			pageMove: true,
		});
	}
}

function genFilterQuery () {
	var queryObj = {};
	var tgtAttrName;
	$("[id^=query_]").each(function(idx, el) {
		if (el.id) {
			tgtAttrName = el.id.replace("query_", "");
			if (el.localName === "input" && el.type === "checkbox") {
				queryObj[tgtAttrName] = el.checked;
			} else {
				if (el.value !== "") {
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

function jumpToClientPageWithQuery(clientId) {
	c4s.jumpToPage("client.clientTop", {
		query: {id: clientId},
	});
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
					body: {},
					pageMove: true,
				});
			},
		});
	}
}

function hdlClickPublicProjectToggle(projectId, currentFlg) {
	var reqObj = {};
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
						body: {},
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
// [begin] Modal commitment action.
function genCommitValue() {
	var reqObj = {};
	if ($("#m_project_id").val()) {
		reqObj.id = Number($("#m_project_id").val());
	}

    reqObj.fee_inbound = formatForCalc($("#m_project_fee_inbound").val());
    reqObj.fee_outbound = formatForCalc($("#m_project_fee_outbound").val());

	var textSymbols = [
		["#m_project_client_name", String],
		["#m_project_client_id", Number],
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
		reqObj[tmpEl.attr("id").replace("m_project_", "")] = checkSymbols[i][1](tmpEl[0].checked);
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

var project_skill_id_list;
var project_skill_level_list;

function hdlClickNewObj () {

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
		$(notCheckSymbols[i])[0].checked = false;
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

	$("#m_project_charging_user_id").val(env.userProfile.user.id);
	// [end] Clear fields.

	$("#m_project_scheme").val("エンド");

	setMenuItem(0, 0, null, null);
	$("#s").val(0);
	$("#disp-quotation").addClass("hidden");

	$("#m_project_worker_container").addClass("hidden");
	$("#edit_project_modal_title").html("新規案件登録");
	$("#edit_project_modal").modal("show");
	$('#m_project_client_id').select2();
	$('#m_project_skill_sort')[0].checked = false
	project_skill_id_list = '';
	project_skill_level_list = [];
}

function overwriteModalForEdit(objId) {
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
		["client_id", "#m_project_client_id"],
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
			for (i = 0; i < textSymbols.length; i++) {
				$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
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
				$("#s").val(tgtData.station_pref_cd);
				setMenuItem(0, tgtData.station_pref_cd, tgtData.station_line_cd, tgtData.station_cd);
				setMenuItem(1, tgtData.station_line_cd, tgtData.station_line_cd, tgtData.station_cd);
			}
			$("#m_project_flg_foreign").val(tgtData.flg_foreign);
			$("#disp-quotation").removeClass("hidden");
			$("#m_project_worker_container").removeClass("hidden");
			$("#edit_project_modal_title").html("案件編集");
			$("#edit_project_modal").modal("show");
			getRelatedEngineer(tgtData.id);
			$('#m_project_client_id').select2();
		}
	});
}

function commitObject(updateFlg) {
	var reqObj = genCommitValue();
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
// [end] Modal commitment action.

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
		/*
		$("[id^=iter_mailto_worker_]").each(function (idx, el, arr) {
			if (el.checked) {
				reqObj.recipients.workers.push(Number(el.id.replace("iter_mailto_worker_", "")));
			}
		});
		*/
		$("input").each(function (idx, el, arr) {
			if (el.id && el.id.indexOf("iter_mailto_worker_") == 0 && el.checked) {
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
	// [begin] Disable buttons.
	// [end] Disable buttons.
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
		if (data && data.status && data.data &&
			data.status.code == 0 &&
			data.data instanceof Array && data.data[0]) {
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
							var tmpTr = $("<tr id='iter_worker_" + codata.data[i].id + "'/>");
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
							$("<td class='center'><span class='glyphicon glyphicon-trash text-danger pseudo-link-cursor' title='削除' onclick='c4s.hdlClickDeleteItem(\"worker\", " + codata.data[i].id + ", true);'></span></td>").appendTo(tmpTr);
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
	var comboSymbols = [];
	var radioSymbols = [];
	var tgtData;
	var i;
	if (branchId) {
		c4s.invokeApi_ex({
			location: "client.enumBranches",
			body: {client_id: clientId},
			onSuccess: function (data) {
				if (data && data.data && data.data instanceof Array && data.data.length > 0) {
					var tgtData = data.data.filter(function (val, idx, arr) { return val.id == branchId; })[0];
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

		//変更点[106]
/*
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
		$("#ms_worker_tel2").val($("#ms_worker_tel2").val() || $("#m_client_tel").val());

		$("#ms_worker_client_name").val($("#m_client_name").val());
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

function triggerCreateQuotationEstimate(projectId) {

	projectId = Number($("#m_project_id").val());

	if (projectId) {

		c4s.invokeApi_ex({
			location: "quotation.topEstimate",
			body: {
				project_id: projectId
			},
			pageMove: true,
			newPage: true
		});

	} else {
		return false;
	}
}

function triggerCreateQuotationOrder(projectId) {

	projectId = Number($("#m_project_id").val());

	if (projectId) {

		c4s.invokeApi_ex({
			location: "quotation.topOrder",
			body: {
				project_id: projectId,
			},
			pageMove: true,
			newPage: true
		});

	} else {
		return false;
	}
}
/* [end] trigger functions on creating quotation. */

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
				project_id: projectId
			},
			pageMove: true
		});


	} else {
		return false;
	}
}
/* [end] trigger functions on creating quotation. */

$(document).ready(function(evt) {
	$("#m_project_client_name").autocomplete({
		source: env.data.clients,
		select: function (evt, itemDict) {
			env.debugOut(itemDict);
			if (itemDict.item) {
				$("#m_project_client_id").val(itemDict.item.id);
			} else {
				$("#m_project_client_id").val(null);
			}
		},
	});
	$("#edit_project_modal").on("hidden.bs.modal", function (evt) {
		void(0);
	});
	$("#edit_project_modal").on("hidden.bs.modal", c4s.hdlCloseModal);
	// [begin] Set onload view state.
	if (env.recentQuery.modal) {
		switch (env.recentQuery.modal) {
			case "createProject":
				hdlClickNewObj();
				break;
			case "editProject":
				if (env.recentQuery.id) {
					overwriteModalForEdit(env.recentQuery.id);
				}
				break;
			default:
				break;
		}

	}
	env.ak_client = new AutoKana("m_client_name", "m_client_kana", {katakana: true});
	env.ak_worker = new AutoKana("ms_worker_name", "ms_worker_kana", {katakana: true});
	if (env.recentQuery.openNewModal) {
		setTimeout(hdlClickNewObj, 10);
		delete env.recentQuery.openNewModal;
	}

	env.ak_client = new AutoKana("new_client_name", "new_client_kana", {katakana: true});
	$("#new_client_name").on("blur", function (evt) {
		$("#new_client_kana").val($("#new_client_kana").val().replace("カブシキガイシャ", "").replace("ユウゲンガイシャ", "").replace("ゴウドウガイシャ", ""));
	});
	// [end] Set onload view state.
});

function openMailForm() {
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
	if (reqObj.projects.length == 0) {
		alert("対象データを選択してください。");
	}
	env.debugOut(reqObj);
	if (reqObj.projects.length > 0) {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: reqObj,
			pageMove: true,
			newPage: true,
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
			for(var idx in data.data) {
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

function editSkillCondition(){
	// genSkillList();
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
    } else if(type == 1) {
        $('#s1 > option').remove();
        if (code == 0) {
			$('#s1').append($('<option>').html("----").val(0));
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
			$('#s0').append($('<option>').html("----").val(0));
            for (i = 0; i < line.length; i++) {
                ii = i + 1;
                var op_line_name = line[i].line_name;
                var op_line_cd = line[i].line_cd;
                var op_obj = $('<option>').html(op_line_name).val(op_line_cd);
                if(selected_line && op_line_cd == selected_line){
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
                if(selected_station && op_station_cd == selected_station){
                	op_obj.prop('selected', true);
				}
                $('#s1').append(op_obj);
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


$("#query_term, #m_project_term_begin, #m_project_term_end").datepicker({
	weekStart: 1,
	viewMode: "dates",
	language: "ja",
	autoclose: true,
	changeYear: true,
	changeMonth: true,
	dateFormat: "yyyy/mm/dd",
});

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

	$("#add_new_project_client_modal").modal('show');
}

function commitProjectClient() {
	var reqObj = genCommitValueOfProjectClient();
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
			$("#add_new_project_client_modal").modal("hide");
		},
		onError: function (data) {
			alert("登録に失敗しました。");
		}
	});
}

function genCommitValueOfProjectClient () {
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
	$("#m_project_client_id").append('<option value="' + client_id + '">' + client_name + '</option>');
	$('#m_project_client_id').val(client_id);
	$('#m_project_client_id').select2();
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
	var is_sort = $('#m_project_skill_sort')[0].checked ? 1 : 0;
	$('#project_skill_list').empty();
	c4s.invokeApi_ex({
		location: "skill.enumSkills",
		body: {is_sort: is_sort},
		onSuccess: function(data) {
			if (data.data) {
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
		},
		onError: function(data) {
			alert("更新に失敗しました。（" + data.status.description + "）")
		},
	});
}

$(document).on('change', '#m_project_skill_sort', function() {
	genSkillList();
});

function exportPdf()
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
