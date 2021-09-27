function deleteItems () {
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_negotiation_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_negotiation_selected_cb_", "")));
		}
	});
	c4s.hdlClickDeleteItem("negotiation", id_list);
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
	var reqObj = {};
	return reqObj;
}

function jumpToClientPageWithQuery(clientId) {
	c4s.invokeApi_ex({
		location: "client.clientTop",
		body: {id: clientId},
		pageMove: true,
	});
}

// [begin] Modal commitment action.
function genCommitValue() {
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

function hdlClickNewObj () {
	c4s.clearValidate({
		"name": "m_negotiation_name",
		"client_name": "m_negotiation_client_name",
		"note": "m_negotiation_note",
		"charging_user_id": "m_negotiation_charging_user_id",
		});
	// [begin] Clear fields.
	var textSymbols = [
		"#m_negotiation_id",
		"#m_negotiation_client_name",
		"#m_negotiation_client_id",
		"#m_negotiation_name",
		["#m_negotiation_dt_negotiation", null],
		"#m_negotiation_note",
	];
	var comboSymbols = [
		"#m_negotiation_charging_user_id",
		"#m_negotiation_status",
		"#m_negotiation_business_type",
		"#m_negotiation_phase_0",
		"#m_negotiation_phase_1",
	];
	var radioSymbols = [];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		if (textSymbols[i] instanceof Array) {
			$(textSymbols[i][0])[0].value = textSymbols[i][1];
		} else {
			$(textSymbols[i]).val(null);
		}
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	// [begin] sendmail UI control.
	$("#m_negotiation_sendmail_check_container").removeClass("hidden");
	$("#m_negotiation_sendmail_btn").addClass("hidden");
	// [end] sendmail UI control.
	// [end] Clear fields.
	var tmpDt = new Date();
	$("#m_negotiation_dt_negotiation").val(tmpDt.getFullYear() + "/" + String(tmpDt.getMonth() + 101).substr(1, 2) + "/" + String(tmpDt.getDate() + 100).substr(1, 2));
	$("#edit_negotiation_modal_title").replaceWith($("<span id='edit_negotiation_modal_title'>新規商談登録</span>"));
	$("#edit_negotiation_modal").modal("show");
}

function overwriteModalForEdit(objId) {
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
			// [begin] sendmail UI control.
			$("#m_negotiation_sendmail_check_container").addClass("hidden");
			$("#m_negotiation_sendmail_btn").removeClass("hidden");
			// [end] sendmail UI control.
			$("#m_negotiation_id").val(objId);
			$("#edit_negotiation_modal_title").replaceWith($("<span id='edit_negotiation_modal_title'>商談編集</span>"));
			$("#edit_negotiation_modal").modal("show");
		}
	});
}

function commitObject(updateFlg) {
	var reqObj = genCommitValue();
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
		$("#m_negotiation_sendmail_check")[0].checked = false;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "negotiation.updateNegotiation" : "negotiation.createNegotiation",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1件更新しました。" : "1件登録しました。");
			c4s.invokeApi_ex({
				location: "negotiation.top",
				body: {},
				pageMove: !$("#m_negotiation_sendmail_check")[0].checked,
			});
			if ($("#m_negotiation_sendmail_check")[0].checked) {
				$("#search_recipient_modal").data("negotiationId", updateFlg ? Number($("#m_negotiation_id").val()) : data.data.id);
				openRecipientsModalOnReminderSharingMail();
				$("#edit_negotiation_modal").modal("hide");
			}
		},
		onError: function (data) {
			alert(updateFlg ? "更新に失敗しました。" : "登録に失敗しました。");
		}
	});
}
// [end] Modal commitment action.

function jumpToClient(clientId) {
	c4s.jumpToPage("client.clientTop", {
		query: {id: clientId},
	});
}

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
		$("[id^=iter_mailto_worker_").each(function (idx, el, arr) {
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
			"charging_user_login_id": "ms_worker_charging_user_login_id",
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
			"charging_user_login_id": "ms_worker_charging_user_login_id",
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
	var comboSymbols = [
		["charging_user_login_id", "#ms_worker_charging_user_login_id"],
	];
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
				for (i = 0; i < comboSymbols.length; i++) {
					$(comboSymbols[i][1])[0].selectedIndex = 0;
					$(comboSymbols[i][1] + " option").each(function (idx, el) {
						if (el.value === tgtData.charging_user.login_id) {
							el.selected = true;
						} else {
							el.selected = false;
						}
					});
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
			$(comboSymbols[i][1])[0].selectedIndex = 0;
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
	var comboSymbols = [
		["charging_user_login_id", "#ms_worker_charging_user_login_id"],
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
	for (i = 0; i < comboSymbols.length; i++) {
		tgtVal = $(comboSymbols[i][1]).val();
		reqObj[comboSymbols[i][0]] = tgtVal;
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
			"charging_user_login_id": "ms_worker_charging_user_login_id",
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

//[begin] Send reminder mail modal functions. (Fullset are maintained at mail.js)
function openRecipientsModalOnReminderSharingMail() {
	var filterRecipientDatum = function () {
		return env.data.members.filter(function (val) {
			return !val.is_locked && val.is_enabled && val.mail1;
		}) || [];
	};
	var renderRecipientModalTable = function (datum) {
		var tbody;
		var tmp_tr;
		$("#row_count").html(datum.length+"件");
		tbody = $("#modal_search_result_member tbody");
		tbody.html("");
		if (datum && datum instanceof Array && datum.length > 0) {
			datum.map(function (val) {
				tmp_tr = $("<tr></tr>");
				if (!val.is_locked && val.is_enabled && val.mail1) {
					tmp_tr.append($("<td class='center'><input type='checkbox' id='recipient_iter_member_" + val.id + "'/></td>"));
				} else {
					tmp_tr.append($("<td></td>"));
				}
				tmp_tr.append($("<td><label for='recipient_iter_member_" + val.id + "'>" + val.name + "</label></td>"));
				tmp_tr.append($("<td>" + val.login_id + "</td>"));
				tmp_tr.append($("<td>" + val.mail1 + "</td>"));
				tbody.append(tmp_tr);
			});
		} else {
			tmp_tr = $("<tr></tr>");
			tmp_tr.append($("<td class='center' colspan='4'>（有効なデータがありません）</td>"));
			tbody.append(tmp_tr);
		}
		tbody.parent().attr("style", "");
	};
	$("#search_recipient_modal_title").html("商談リマインダー：送信先選択");
	$("#modal_search_container_worker").css("display", "none");
	$("#modal_search_container_engineer").css("display", "none");
	$("#modal_search_container_member").css("display", "block");
	c4s.invokeApi_ex({
		location: "manage.enumAccounts",
		body: {},
		onSuccess: function (res) {
			if (res.data && res.data.length > 0) {
				env.data = env.data || {};
				env.data.members = res.data;
			}
			renderRecipientModalTable(filterRecipientDatum());
		},
	});
	$("#search_recipient_modal").modal("show");
}

function sendReminderSharingMail() {
	var negotiationId = $("#search_recipient_modal").data("negotiationId");
	var recipientIds = [];
	$("input[id^=recipient_iter_member_]:checked").each(function (idx, el) {
		recipientIds.push(Number(el.getAttribute("id").replace("recipient_iter_member_", "")));
	});
	if (negotiationId && recipientIds.length) {
		c4s.invokeApi_ex({
			location: "negotiation.sendReminderMail",
			body : {
				negotiationId: negotiationId,
				recipientIdList: recipientIds
			},
			onSuccess: function (res) {
				if (res.status && res.status.code == 0) {
					confirm("リマインダー メールを送信しました");
					$("#search_recipient_modal").modal("hide");
					c4s.invokeApi_ex({
						location: "negotiation.top",
						body : env.recentQuery,
						pageMove: true
					});
				} else {
					confirm("問題が発生しました（" + res.status.code + ": " + res.status.description + "）");
				}
			}
		});
	}
}
//[end] Send reminder mail modal functions.

// [begin] onload functions.
$(document).ready(function(evt) {
	$("#m_negotiation_client_id").on("change", function () {
		$("#m_negotiation_client_name")[0].value = "";
	});
	$("#m_negotiation_client_name").on("change", function(evt) {
		if (evt.currentTarget.value !== "") {
			$("#m_negotiation_client_id")[0].selectedIndex = 0;
		}
	});
	$("#m_negotiation_client_name").on("keyup", function(evt) {
		if (nameClients.indexOf($("#m_negotiation_client_name").val()) <= -1) {
			$("#m_negotiation_client_id").val(null);
		}
	});
	$("#m_negotiation_client_name").autocomplete({
		source: env.data.clients,
		select: function (evt, itemDict) {
			env.debugOut(itemDict);
			if (itemDict.item) {
				$("#m_negotiation_client_id").val(itemDict.item.id);
			} else {
				$("#m_negotiation_client_id").val(null);
			}
		},
	});
	$("#m_negotiation_dt_negotiation").datepicker({
		weekStart: 1,
		viewMode: "days",
		language: "ja",
		autoclose: true,
		changeYear: true,
		changeMonth: true,
		dateFormat: "yyyy/mm/dd",
	});
	$("#m_negotiation_business_type").on("change", function (evt) {
		var hideCombobox, showCombobox;
		switch ($("#m_negotiation_business_type").val()) {
			case "SES":
				showCombobox = $("#m_negotiation_phase_0");
				hideCombobox = $("#m_negotiation_phase_1");
				break;
			case "受託":
				showCombobox = $("#m_negotiation_phase_1");
				hideCombobox = $("#m_negotiation_phase_0");
				break;
			default:
				break;
		}
		showCombobox[0].style.display = "inline";
		hideCombobox[0].style.display = "none";
	});
	if (env.recentQuery.openNewModal) {
		setTimeout(hdlClickNewObj, 10);
		delete env.recentQuery.openNewModal;
	}
});
// [end] onload functions.