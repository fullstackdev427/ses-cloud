// functions for manage menu.

// [begin] onload functions.
$(document).ready(function(evt) {
	if (env.recentQuery && env.recentQuery.ctrl_selectedTab) {
		$("a[href=\"#" + env.recentQuery.ctrl_selectedTab + "\"]").trigger("click");
	}
});
// [end] onload functions.

// [begin] for signature.
function hdlClickUpdateSignature() {
	var reqObj = {};
	reqObj.value = $("#input_signature_value").val();
	c4s.invokeApi_ex({
		location: "manage.writeMailSignature",
		body: reqObj,
		onSuccess: function(data) {
			if (data && data.status && data.status.code == 0) {
				window.alert("更新しました");
				c4s.invokeApi_ex({
					location: "manage.top",
					body: {ctrl_selectedTab: "ct_signature"},
					pageMove: true,
				});
			}
		},
	});
}
// [end] for signature.

function hdlClickUpdateQuotationSetting() {

	var reqObj = {
			login_id: env.login_id,
			credential: env.credential,
			prefix: env.prefix,
		};

	reqObj.company_seal = $("#company-seal-image").children('img').attr('src');
	reqObj.company_version = $("#company-version-image").children('img').attr('src');
	reqObj.bank_account1 = $("#m_manage_bank_account1").val();
	reqObj.bank_account2 = $("#m_manage_bank_account2").val();
	reqObj.estimate_charging_user_id = $("#m_manage_estimate_charging_user_id").val();
	reqObj.order_charging_user_id = $("#m_manage_order_charging_user_id").val();
	reqObj.purchase_charging_user_id = $("#m_manage_purchase_charging_user_id").val();
	reqObj.invoice_charging_user_id = $("#m_manage_invoice_charging_user_id").val();

	if(reqObj.bank_account1.length > 64){
		alert("振込先１を64文字以内に収まるように修正してください。");
	}
	if(reqObj.bank_account2.length > 64){
		alert("振込先２を64文字以内に収まるように修正してください。");
	}

	c4s.invokeApi_ex({
		location: "manage.setQuotationConfig",
		body: reqObj,
		onSuccess: function(data) {
			if (data && data.status && data.status.code == 0) {
				window.alert("更新しました");
				c4s.invokeApi_ex({
					location: "manage.top",
					body: {ctrl_selectedTab: "ct_form"},
					pageMove: true,
				});
			}
		},
	});
}

function hdlClickBackPageQuotation(location) {
	var reqObj = {
			login_id: env.login_id,
			credential: env.credential,
			prefix: env.prefix,
		};

	reqObj.company_seal = $("#company-seal-image").children('img').attr('src');
	reqObj.bank_account1 = $("#m_manage_bank_account1").val();
	reqObj.bank_account2 = $("#m_manage_bank_account2").val();
	reqObj.estimate_charging_user_id = $("#m_manage_estimate_charging_user_id").val();
	reqObj.order_charging_user_id = $("#m_manage_order_charging_user_id").val();
	reqObj.purchase_charging_user_id = $("#m_manage_purchase_charging_user_id").val();
	reqObj.invoice_charging_user_id = $("#m_manage_invoice_charging_user_id").val();

	if(reqObj.bank_account1.length > 64){
		alert("振込先１を64文字以内に収まるように修正してください。");
	}
	if(reqObj.bank_account2.length > 64){
		alert("振込先２を64文字以内に収まるように修正してください。");
	}

	c4s.invokeApi_ex({
		location: "manage.setQuotationConfig",
		body: reqObj,
		onSuccess: function(data) {
			if (data && data.status && data.status.code == 0) {
				window.alert("更新しました");

				var reqObj = env.recentQuery.back_page_reqObj;
				c4s.invokeApi_ex({
					location: location,
					body: reqObj,
					pageMove: true,
					newPage: false
				});
			}
		},
	});
}

// [begin] for profile.
function hdlClickUpdateProfile() {
	var pwd_ipt = $("#input_profile_password").val();
	var pwd_cfm = $("#input_profile_password_confirm").val();
	var reqObj = {};
	reqObj.tel1 = $("#input_profile_tel1").val();
	reqObj.tel2 = $("#input_profile_tel2").val();
	reqObj.fax = $("#input_profile_fax").val();
	reqObj.mail1 = $("#input_profile_mail1").val();
	if ($("#input_profile_is_admin").length > 0) {
		reqObj.is_admin = $("#input_profile_is_admin")[0].checked;
	}
	if (pwd_ipt !== "" && pwd_cfm !== "" && pwd_ipt === pwd_cfm) {
		reqObj.password = $("#input_profile_password").val();
	} else if (pwd_ipt !== "" && pwd_cfm !== "" && pwd_ipt !== pwd_cfm) {
		alert("変更先パスワードと確認入力が等しくありません");
		return;
	}
	c4s.invokeApi_ex({
		location: "manage.updateUserProfile",
		body: reqObj,
		onSuccess: function(data) {
			alert("更新しました");
			c4s.invokeApi_ex({
				location: reqObj.password || !reqObj.is_admin ? "": "manage.top",
				body: {ctrl_selectedTab: "ct_profile"},
				pageMove: true,
			});
		},
	});
}
// [end] for profile.

// [begin] for use help.
function hdlClickUpdateHelp() {
	var reqObj = {};
	reqObj.value = $("#input_help_flg")[0].checked;
	c4s.invokeApi_ex({
		location: "manage.writeUseHelp",
		body: reqObj,
		onSuccess: function(data) {
			alert("更新しました");
			c4s.invokeApi_ex({
				location: env.current,
				body: {ctrl_selectedTab: "ct_help"},
				pageMove: true,
			});
		},
	});
}
// [end] for use help.

// [begin] for row length.
function hdlClickUpdateRowLength() {
	var reqObj = {};
	reqObj.value = $("#input_row_length").val();
	c4s.invokeApi_ex({
		location: "manage.writeRowLength",
		body: reqObj,
		onSuccess: function(data) {
			alert("更新しました");
			c4s.invokeApi_ex({
				location: env.current,
				body: {ctrl_selectedTab: "ct_help"},
				pageMove: true,
			});
		},
	});
}
// [end] for row length.

// [begin] for row length.
function hdlClickUpdateFlgPublic() {
	var reqObj = {};
	reqObj.value = $('input[name=input_flg_public]:checked').val();
	reqObj.prefix = env.prefix;
	c4s.invokeApi_ex({
		location: "manage.updateFlgPublic",
		body: reqObj,
		onSuccess: function(data) {
			alert("更新しました");
			c4s.invokeApi_ex({
				location: env.current,
				body: {ctrl_selectedTab: "ct_help"},
				pageMove: true,
			});
		},
	});
}
// [end] for row length.

// [begin] for account.
function editAccountObj(accountObj) {
	c4s.clearValidate({
		"name": "input_account_name",
		"tel1": "input_account_tel1",
		"mail1": "input_account_mail1",
		"new_login_id": "input_account_login_id",
		"password": "input_account_password",
	});
	$("#input_account_status").html("");
	if (accountObj) {
		$("#input_account_id").val(accountObj.id);
		$("#input_account_name").val(accountObj.name);
		$("#input_account_name")[0].readOnly = true;
		$("#input_account_tel1").val(accountObj.tel1);
		$("#input_account_tel2").val(accountObj.tel2);
		$("#input_account_fax").val(accountObj.fax);
		$("#input_account_mail1").val(accountObj.mail1);
		$("#input_account_login_id").val(accountObj.login_id);
		$("#input_account_login_id")[0].readOnly = true;
		$("#input_account_password").val(null);
		$("#input_account_is_admin")[0].checked = accountObj.is_admin;
		$("#input_account_is_locked")[0].checked = accountObj.is_locked;
		$("#input_account_is_locked")[0].disabled = false;
		$("#input_account_is_enabled")[0].checked = accountObj.is_enabled;
		$("#input_account_is_enabled")[0].disabled = false;
		$("#edit_account_modal_title").replaceWith('<span id="edit_account_modal_title">アカウント編集</span>');
		if (accountObj.is_enabled && !accountObj.is_locked) {
			$("#input_account_btn")[0].enabled = true;
		} else {
			$("#input_account_btn")[0].enabled = false;
			var statusText = [];
			if (!accountObj.is_enabled) {
				statusText.push("・アカウントが有効ではありません");
			}
			if (accountObj.is_locked) {
				statusText.push("・アカウントがロックアウトされています");
			}
			$("#input_account_status").html(statusText.join("<br/>"));
		}
	} else {
		$("#input_account_id").val(null);
		$("#input_account_name").val(null);
		$("#input_account_name")[0].readOnly = false;
		$("#input_account_tel1").val(null);
		$("#input_account_tel2").val(null);
		$("#input_account_fax").val(null);
		$("#input_account_mail1").val(null);
		$("#input_account_login_id").val(null);
		$("#input_account_login_id")[0].readOnly = false;
		$("#input_account_password").val(null);
		$("#input_account_is_admin")[0].checked = false;
		$("#input_account_is_locked")[0].checked = false;
		$("#input_account_is_locked")[0].disabled = true;
		$("#input_account_is_enabled")[0].checked = true;
		$("#input_account_is_enabled")[0].disabled = true;
		$("#edit_account_modal_title").replaceWith('<span id="edit_account_modal_title">新規アカウント登録</span>');
		$("#input_account_btn")[0].enabled = true;
	}
	$("#edit_account_modal").modal("show");
}
function commitAccountObj(accountId) {
	var reqObj = {};
	reqObj.name = $("#input_account_name").val();
	reqObj.tel1 = $("#input_account_tel1").val();
	reqObj.tel2 = $("#input_account_tel2").val();
	reqObj.fax = $("#input_account_fax").val();
	reqObj.mail1 = $("#input_account_mail1").val();
	reqObj.password = $("#input_account_password").val();
	reqObj.is_admin = $("#input_account_is_admin")[0].checked;
	reqObj.is_enabled = $("#input_account_is_enabled")[0].checked;
	if (accountId) {
		reqObj.id = accountId;
		reqObj.is_locked = $("#input_account_is_locked")[0].checked;
	} else {
		reqObj.new_login_id = $("#input_account_login_id").val();
		var i;
		for(i = 0; i < env.data['accounts'].length; i++) {
			if (reqObj.new_login_id === env.data['accounts'][i].login_id) {
				alert("重複するログインIDは登録できません");
				$("#input_account_login_id").focus();
				return;
			}
		}
	}
	if (accountId && !reqObj.password) {
		delete reqObj.password;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.account,
		{
			"name": "input_account_name",
			"tel1": "input_account_tel1",
			"mail1": "input_account_mail1",
			"new_login_id": "input_account_login_id",
			"password": "input_account_password",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return false;
	}
	var tmp = env.data.accounts.filter(function(val) {
		return !accountId ? true : val.id != accountId;
	});

	if(env.limit.LMT_LEN_ACCOUNT > 0) {
        tmp.push(reqObj);
        if (tmp.filter(function (val, idx, arr) {
                return Boolean(val.is_enabled);
            }).length > env.limit.LMT_LEN_ACCOUNT) {
            alert("有効アカウントの上限数に達しています");
            return;
        }
    }

	c4s.invokeApi_ex({
		location: (accountId ? "manage.updateAccount" : "manage.createAccount"),
		body: reqObj,
		onSuccess: function (data) {
			alert(accountId ? "1件更新しました" : "1件登録しました");
			c4s.invokeApi_ex({
				location: "manage.top",
				body: {ctrl_selectedTab: "ct_account"},
				pageMove: true,
			});
		},
	});
}
function disableAccountItem(accountId) {
	c4s.invokeApi_ex({
		location: "manage.updateAccount",
		body: {id: accountId, is_enabled: false},
		onSuccess: function (data) {
			c4s.invokeApi_ex({
				location: "manage.top",
				body: {ctrl_selectedTab: "ct_account"},
				pageMove: true,
			});
		},
	});
}
// [end] for account.

// [begin] for user_companies.
function editUserCompaniesObj(userCompaniesObj) {
	c4s.clearValidate({
		"name": "input_account_name",
	});

	$("#input_account_status").html("");
	if (userCompaniesObj) {
		$("#input_user_companies_id").val(userCompaniesObj.id);
		$("#input_user_companies_name").val(userCompaniesObj.name);
		$("#input_user_companies_owner_name").val(userCompaniesObj.owner_name);
		$("#input_user_companies_tel").val(userCompaniesObj.tel);
		$("#input_user_companies_fax").val(userCompaniesObj.fax);
		$("#input_user_companies_addr_vip").val(userCompaniesObj.addr_vip);
		$("#input_user_companies_addr1").val(userCompaniesObj.addr1);
		$("#input_user_companies_addr2").val(userCompaniesObj.addr2);
		$("#input_user_companies_prefix").val(userCompaniesObj.prefix);
		$("#input_user_companies_dt_use_begin").val(userCompaniesObj.dt_use_begin);
		$("#input_user_companies_dt_use_end").val(userCompaniesObj.dt_use_end);
		// $("#input_user_companies_dt_charged_end").val(userCompaniesObj.dt_charged_end);
		$("#input_user_companies_is_enabled")[0].checked = userCompaniesObj.is_enabled;
		$("#input_user_companies_is_enabled")[0].disabled = false;
		$("#edit_user_companies_modal_title").replaceWith('<span id="edit_user_companies_modal_title">顧客企業編集</span>');
		$("#new_admin_form_area").hide();
		if (userCompaniesObj.is_enabled) {
			$("#input_user_companies_btn")[0].enabled = true;
		} else {
			$("#input_user_companies_btn")[0].enabled = false;
			var statusText = [];
			if (!userCompaniesObj.is_enabled) {
				statusText.push("・対象顧客企業が有効ではありません");
			}

			$("#input_user_companies_status").html(statusText.join("<br/>"));
		}
	} else {
		$("#input_user_companies_id").val(null);
		$("#input_user_companies_name").val(null);
		$("#input_user_companies_owner_name").val(null);
		$("#input_user_companies_tel").val(null);
		$("#input_user_companies_fax").val(null);
		$("#input_user_companies_addr_vip").val(null);
		$("#input_user_companies_addr1").val(null);
		$("#input_user_companies_addr2").val(null);
		$("#input_user_companies_prefix").val(null);
		$("#input_user_companies_dt_use_begin").val(null);
		$("#input_user_companies_dt_use_end").val(null);
		// $("#input_user_companies_dt_charged_end").val(null);
		$("#input_user_companies_is_enabled")[0].checked = true;
		$("#input_user_companies_is_enabled")[0].disabled = true;
		$("#edit_user_companies_modal_title").replaceWith('<span id="edit_user_companies_modal_title">新規顧客企業登録</span>');
		$("#input_user_companies_btn")[0].enabled = true;
		$("#new_admin_form_area").show();
	}
	$("#edit_user_companies_modal").modal("show");
}

function commitUserCompaniesObj(companyId) {
	companyId = Number(companyId);
	var reqObj = {};
	reqObj.name = $("#input_user_companies_name").val();
	reqObj.owner_name = $("#input_user_companies_owner_name").val();
	reqObj.tel = $("#input_user_companies_tel").val();
	reqObj.fax = $("#input_user_companies_fax").val();
	reqObj.addr_vip = $("#input_user_companies_addr_vip").val();
	reqObj.addr1 = $("#input_user_companies_addr1").val();
	reqObj.addr2 = $("#input_user_companies_addr2").val();
	reqObj.prefix = $("#input_user_companies_prefix").val();
	reqObj.dt_use_begin = $("#input_user_companies_dt_use_begin").val();
	reqObj.dt_use_end = $("#input_user_companies_dt_use_end").val();
	reqObj.is_enabled = $("#input_user_companies_is_enabled")[0].checked;
	reqObj.login_prefix = env.prefix;

	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}


	if (companyId) {
		reqObj.id = companyId;
	} else {
		reqObj.prefix = $("#input_user_companies_prefix").val();
		var i;
		for(i = 0; i < env.data['companies'].length; i++) {
			if (reqObj.prefix === env.data['companies'][i].prefix) {
				alert("重複するprefixは登録できません");
				$("#input_user_companies_prefix").focus();
				return;
			}
		}

	}

	$("#input_user_companies_dt_use_begin").parent().removeClass("has-error");
	$("#input_user_companies_dt_use_end").parent().removeClass("has-error");
	if(reqObj.dt_use_begin == "" || reqObj.dt_use_end == ""){
		alert("利用期間は必須入力です");
		$("#input_user_companies_dt_use_begin").parent().addClass("has-error");
		$("#input_user_companies_dt_use_end").parent().addClass("has-error");
		return;
	}

	if(reqObj.dt_use_begin && reqObj.dt_use_end){
		try{
			var date1 = new Date(reqObj.dt_use_begin);
    		var date2 = new Date(reqObj.dt_use_end);
		}catch(e){
			alert("利用期間は日付の形(YYYY/MM/DD)で入力してください");
			$("#input_user_companies_dt_use_begin").parent().addClass("has-error");
			$("#input_user_companies_dt_use_end").parent().addClass("has-error");
			return;
		}

    	if(date1 > date2){
    		alert("利用期間開始日は利用期間終了日より前である必要があります。");
			$("#input_user_companies_dt_use_begin").parent().addClass("has-error");
			$("#input_user_companies_dt_use_end").parent().addClass("has-error");
			return;
		}
	}

	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.signupCompany,
		{
			"name": "input_user_companies_name",
			"owner_name": "input_user_companies_owner_name",
			"tel": "input_user_companies_tel",
			"fax": "input_user_companies_fax",
			"addr_vip": "input_user_companies_addr_vip",
			"addr1": "input_user_companies_addr1",
			"addr2": "input_user_companies_addr2",
			"prefix": "input_user_companies_prefix",
		});

	var validLog2 = {};

	if (!companyId) {
        reqObj.admin_name = $("#input_admin_name").val();
        reqObj.admin_tel = $("#input_admin_tel").val();
        reqObj.admin_mail = $("#input_admin_mail").val();
        reqObj.admin_password = $("#input_admin_password").val();
        reqObj.admin_login_id = $("#input_admin_login_id").val();
        var i;
        for (i = 0; i < env.data['accounts'].length; i++) {
            if (reqObj.new_login_id === env.data['accounts'][i].login_id) {
                alert("重複するログインIDは登録できません");
                $("#input_admin_login_id").focus();
                return;
            }
        }

        validLog2 = c4s.validate(
            reqObj,
            c4s.validateRules.account,
            {
                "admin_name": "input_admin_name",
                "admin_tel": "input_admin_tel",
                "admin_mail": "input_admin_mail",
                "admin_login_id": "input_account_login_id",
                "admin_password": "input_admin_password",
            });
    }

	if (validLog.length || validLog2.length) {
		env.debugOut(validLog);
		env.debugOut(validLog2);
		alert("入力を修正してください");
		return false;
	}
	c4s.invokeApi_ex({
		location: (companyId ? "manage.updateUserCompany" : "manage.createUserCompany"),
		body: reqObj,
		onSuccess: function (data) {
			alert(companyId ? "1件更新しました" : "1件登録しました");
			c4s.invokeApi_ex({
				location: "manage.top",
				body: {ctrl_selectedTab: "ct_user_group"},
				pageMove: true,
			});
		},
	});
}
// [end] for user_companies.
// [begin] for user_company_cap.
function editUserCompanyCapObj(userCompaniesObj) {

	c4s.invokeApi_ex({
		location: "manage.enumPrefsById",
		body: userCompaniesObj,
		onSuccess: function (data) {

			for(var capidx in data.data) {
				switch (data.data[capidx].key){
					case "LMT_LEN_ACCOUNT":
						$("#input_user_companies_cap_account").val(data.data[capidx].final);
						break;
					case "LMT_LEN_CLIENT":
						$("#input_user_companies_cap_client").val(data.data[capidx].final);
						break;
					case "LMT_LEN_WORKER":
						$("#input_user_companies_cap_worker").val(data.data[capidx].final);
						break;
					case "LMT_LEN_PROJECT":
						$("#input_user_companies_cap_project").val(data.data[capidx].final);
						break;
					case "LMT_LEN_ENGINEER":
						$("#input_user_companies_engineer").val(data.data[capidx].final);
						break;
					case "LMT_LEN_MAIL_TPL":
						$("#input_user_companies_cap_mail_tpl").val(data.data[capidx].final);
						break;
                }
			}
			$("#edit_user_company_cap_modal").modal("show");
			$("#input_user_company_cap_id").val(userCompaniesObj.id);
		},
	});

}

function commitUserCompanyCapObj(companyId) {

	var reqObj = {};
	reqObj.id = parseInt($("#input_user_company_cap_id").val());
	reqObj.max_account = parseInt($("#input_user_companies_cap_account").val());
	reqObj.max_client = parseInt($("#input_user_companies_cap_client").val());
	reqObj.max_worker = parseInt($("#input_user_companies_cap_worker").val());
	reqObj.max_project = parseInt($("#input_user_companies_cap_project").val());
	reqObj.max_engineer = parseInt($("#input_user_companies_engineer").val());
	reqObj.max_mail_tpl = parseInt($("#input_user_companies_cap_mail_tpl").val());
	reqObj.login_prefix = env.prefix;


	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.updatePref,
		{
			"max_account": "input_user_companies_cap_account",
			"max_client": "input_user_companies_cap_client",
			"max_worker": "input_user_companies_cap_worker",
			"max_project": "input_user_companies_cap_project",
			"max_engineer": "input_user_companies_engineer",
			"max_mail_tpl": "input_user_companies_cap_mail_tpl",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return false;
	}
	c4s.invokeApi_ex({
		location: "manage.updatePref",
		body: reqObj,
		onSuccess: function (data) {
			alert("1件更新しました");
			c4s.invokeApi_ex({
				location: "manage.top",
				body: {ctrl_selectedTab: "ct_user_group"},
				pageMove: true,
			});
		},
	});
}
// [end] for user_company_cap.

// [begin] for template.
function editTemplateObj(templateId) {
	if (env.limit.LMT_LEN_MAIL_TPL == $("tr[id^=iter_template_]").length && !templateId) {
		alert("テンプレート保存上限数に達しています。ライセンスをご確認ください。");
		return;
	}
	if (templateId) {
		$("#input_template_id").val(templateId);
		$("#edit_template_modal_title").replaceWith("<span id='edit_template_modal_title'>テンプレート編集</span>");
		$("li[id^=input_template_iter_attachment_] input").val(null);
		$("li[id^=input_template_iter_attachment_] label").html("");
		c4s.invokeApi_ex({
			location: "mail.enumTemplates",
			body: {id: templateId},
			onSuccess: function(data) {
				var obj = data.data.filter(function(val, idx, arr) {
					return val.id == templateId;
				})[0];
				$("#input_template_name").val(obj.name);
				$("#input_template_subject").val(obj.subject);
				$("#input_template_body").val(obj.body);
				$(obj.type_recipient === "取引先担当者" ? "#input_template_type_0" : "#input_template_type_1")[0].checked = true;
				$("input[id^=input_template_type_]").each(function (idx, el) {
					el.disabled = true;
				});
				$("input[id^=input_template_type_iterator_]").each(function (idx, el) {
					el.disabled = false;
					el.checked = false;
				});
				if (obj.type_iterator) {
					var i;
					for(i = 0; i < obj.type_iterator.length; i++) {
						switch (obj.type_iterator[i]) {
							case "技術者情報":
								$("#input_template_type_iterator_0")[0].checked = true;
								break;
							case "案件情報":
								$("#input_template_type_iterator_1")[0].checked = true;
								break;
							default:
								break;
						}
					}
				}
				var i;
				for (i = 0; i < obj.attachments.length; i++) {
					$("#input_template_attachment_" + i + "_id").val(obj.attachments[i].id);
					$("#input_template_attachment_" + i + "_label").html(obj.attachments[i].name + "(" + obj.attachments[i].size +  "bytes)");
				}
			}
		});
	} else {
		$("#input_template_id").val(null);
		$("#input_template_name").val(null);
		$("#input_template_subject").val(null);
		$("#input_template_body").val(null);
		$("#input_template_type_0")[0].checked = true;
		$("input[id^=input_template_type_]").each(function (idx, el) {
			el.disabled = false;
		});
		$("input[id^=input_template_type_iterator_]").each(function (idx, el) {
			el.checked = false;
		});
		$("li[id^=input_template_iter_attachment_] input").val(null);
		$("li[id^=input_template_iter_attachment_] label").html("");
		$("#edit_template_modal_title").replaceWith("<span id='edit_template_modal_title'>新規テンプレート登録</span>");
	}
	$("#edit_template_modal").modal("show");
}

function genTemplateObj() {
	var reqObj = {};
	reqObj.type_recipient = $("#input_template_type_0")[0].checked ? "取引先担当者" : "技術者";
	reqObj.type_iterator = [];
	if ($("#input_template_type_iterator_0")[0].checked) {
		reqObj.type_iterator.push("技術者情報");
	}
	if ($("#input_template_type_iterator_1")[0].checked) {
		reqObj.type_iterator.push("案件情報");
	}
	reqObj.name = $("#input_template_name").val();
	reqObj.subject = $("#input_template_subject").val();
	reqObj.body = $("#input_template_body").val();
	reqObj.attachments = (function() {
		var tmp = [];
		$("input[type=hidden][id^=input_template_attachment_]").each(function(idx, el) {
			if (el.value) {
				tmp.push(Number(el.value));
			}
		});
		return tmp;
	})();
	return reqObj;
}

function commitTemplateObj(templateId) {
	var reqObj = genTemplateObj();
	if (templateId) {
		reqObj.id = templateId;
	}
	c4s.invokeApi_ex({
		location: templateId ? "mail.updateTemplate" : "mail.createTemplate",
		body: reqObj,
		onSuccess: function (data) {
			alert("1件" + (templateId ? "更新" : "登録") + "しました");
			c4s.invokeApi_ex({
				location: env.current,
				body: {ctrl_selectedTab: "ct_template"},
				pageMove: true,
			});
		},
		onError: function (data) {
			
		},
	});
}

function uploadFile(fileInputId, fileIdEl, labelEl) {
	if (window.FormData) {
		var fd = new FormData();
		var fi = $(fileInputId)[0];
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
						$(fileIdEl).val(data.data.id);
						$(labelEl).html(data.data.filename + "(" + data.data.size + "bytes)");
					} else if (data && data.status.code == 13 && data.data && data.data.size && data.data.limit) {
						window.alert(data.status.description + "制限値が" + data.data.limit + "bytesのところ、アップロードしようとしたサイズは" + data.data.size + "bytesでした（" + String((data.data.size / data.data.limit - 1) * 100).split(".")[0] + "％超過）。");
					} else if (data && data.status.code) {
						window.alert(data.status.description);
						$(fileInputId).val(null);
						$(fileIdEl).val(null);
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

function pseudoDeleteAttachment(id) {
	$("#input_template_attachment_" + id + "_id").val(null);
	$("#input_template_attachment_" + id + "_label").html("");
	$("#input_template_attachment_" + id + "_file").val(null);
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
	window.console.log("[Deplicated] OLD download() on manage.js is used.");
	c4s.download(id);
}
// [end] for template.

// [begin] for receiver.
function addReceiver() {
	var obj = {};
	obj.name = $("#input_receiver_name").val();
	obj.mail = $("#input_receiver_mail").val();
	if (obj.mail) {
		env.limit[$("#input_receiver_type_0")[0].checked ? "MAIL_RECEIVER_CC" : "MAIL_RECEIVER_BCC"].push(obj);
		commitReceiver();
	} else {
		$("#input_receiver_mail").parent("div").addClass("has-error");
	}
}

function removeReceiver(type, index) {
	env.limit[type] = (function(iter) {
		var i;
		var tmp = [];
		for(i = 0; i < iter.length; i++) {
			if (i !== index) {
				tmp.push(iter[i]);
			}
		}
		return tmp;
	})(env.limit[type]);
	commitReceiver();
}

function commitReceiver() {
	var req = {};
	req.cc = env.limit.MAIL_RECEIVER_CC;
	req.bcc = env.limit.MAIL_RECEIVER_BCC;
	c4s.invokeApi_ex({
		location: "manage.writeMailReceiver",
		body: req,
		onSuccess: function(data) {
			alert("更新しました");
			c4s.invokeApi_ex({
				location: env.current,
				body: {ctrl_selectedTab: "ct_mail"},
				pageMove: true,
			});
		},
	});
}
// [end] for receiver.

// [begin] for Reply-to.
function addReplyTo() {
	var obj = {};
	obj.name = $("#reply_to_name").val();
	obj.mail = $("#reply_to_mail").val();
	if (obj.mail) {
		env.limit["MAIL_REPLY_TO"] = obj;
		commitReplyTo();
	} else {
		$("#reply_to_mail").parent("div").addClass("has-error");
	}
}

function removeReplyTo() {
	env.limit["MAIL_REPLY_TO"] = ""
	commitReplyTo();
}

function commitReplyTo() {
	var req = {};
	req.replyTo = env.limit.MAIL_REPLY_TO;
	c4s.invokeApi_ex({
		location: "manage.writeMailReplyTo",
		body: req,
		onSuccess: function(data) {
			alert("更新しました");
			c4s.invokeApi_ex({
				location: env.current,
				body: {ctrl_selectedTab: "ct_mail"},
				pageMove: true,
			});
		},
	});
}
// [end] for Reply-to.

// [begin] for data migrate.
function renderMigrateRequests(data) {
	var tbody = $("#view_migrate_req_tbl tbody");
	tbody.empty();
	var tr, td, span, i;
	if (data && data.length) {
		for (i = 0; i < data.length; i++) {
			if (["検証済", "完了", "確認済"].indexOf(data[i].last_status) > -1) {
				tr = $("<tr style='background-color: #dff0d8;'></tr>");
			} else if (["受理", "検証中", "本投入待機", "本投入中", "本投入済"].indexOf(data[i].last_status) > -1) {
				tr = $("<tr style='background-color: #d9edf7;'></tr>");
			} else if ([].indexOf(data[i].last_status) > -1) {
				tr = $("<tr style='background-color: #fcf8e3;'></tr>");
			} else if (["検証失敗", "本投入失敗"].indexOf(data[i].last_status) > -1) {
				tr = $("<tr style='background-color: #f2dede;'></tr>");
			} else if (["キャンセル",].indexOf(data[i].last_status) > -1) {
				tr = $("<tr style='background-color: #cccccc;'></tr>");
			} else {
				tr = $("<tr></tr>");
			}
			tr.data("object", data[i]);
			td = $("<td style='border-right: 0; text-align: center; font-weight: bold;'></td>").text(data[i].last_status);
			tr.append(td);
			td = $("<td style='width: 2em; border-left: 0; text-align: center;'></td>");
			td.append($("<span class='glyphicon glyphicon-zoom-in text-info pseudo-link-cursor' onclick='hdlClickDrillDownMigrateRequestBtn(\"" + data[i].transaction_id + "\");'></span>"));
			if (["受理", "検証中", "検証済", "本投入待機"].indexOf(data[i].last_status) > -1) {
				td.append($("<span class='glyphicon glyphicon-trash text-danger pseudo-link-cursor' onclick='hdlClickCancelMigrateRequestBtn(\"" + data[i].transaction_id + "\", \"" + data[i].last_status + "\");'></span>"));
			}
			tr.append(td);
			td = $("<td></td>")
			span = $("<span class='pseudo-link-cursor' style='color: #2a98c5;' onclick='download(" + data[i].attachment.id + ");'></span>").text(data[i].attachment.filename);
			td.append(span);
			tr.append(td);
			td = $("<td style='text-align: center;'></td>").text(data[i].attachment.size);
			tr.append(td);
			td = $("<td style='text-align: center;'></td>").append($("<span></span>").text(data[i].dt_registered));
			td.append($("<br/>"));
			td.append($("<span style='font-weight: bold;'></span>").text(data[i].dt_updated));
			tr.append(td);
			tbody.append(tr);
		}
	} else {
		tr = $("<tr></tr>");
		td = $("<td colspan='5' style='text-align: center;'>（データがありません）</td>");
		tr.append(td);
		tbody.append(tr);
	};
}

function hdlClickMigrateInvokeBtn(mode) {
	var reqObj = {};
	reqObj.attachment = $("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_id").val();
	reqObj.memo = $("#input_migrate" + (mode === "full" ? "_full" : "") + "_memo").val();
	if (reqObj.attachment) {
		reqObj.attachment = Number(reqObj.attachment);
	} else {
		window.alert("Excel（XLS形式）ファイルを指定してください。");
		return;
	}
	if (reqObj.memo) {
		reqObj.memo = reqObj.memo.substring(0, 512);
	}
	c4s.invokeApi_ex({
		location: "manage.migrateInvoke",
		body: reqObj,
		onSuccess: function (data) {
			window.alert("ファイルを登録しました。");
			$("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_id").val(null);
			$("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_file").val(null);
			$("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_label").text("");
			$("#input_migrate" + (mode === "full" ? "_full" : "") + "_memo").val(null);
			hdlClickRefreshMigrateRequests();
		},
	});
}

function hdlClickRefreshMigrateRequests() {
	c4s.invokeApi_ex({
		location: "manage.migrateEnumRequests",
		body: {},
		onSuccess: function (data) {
			if (data.status.code == 0) {
				renderMigrateRequests(data.data);
			}
		},
	});
}

function hdlClickDrillDownMigrateRequestBtn(tr_id) {
	c4s.invokeApi_ex({
		location: "manage.migrateEnumMessages",
		body: {
			tr_id: tr_id,
		},
		onSuccess: function (data) {
			if (data.data && data.data.length) {
				$("#view_migrate_request_modal_tr_id").text(data.data[0].transaction_id);
				var tbody = $("#view_migrate_request_modal tbody");
				var tr, td, i;
				tbody.empty();
				for (i = 0; i < data.data.length; i++) {
					tr = $("<tr></tr>");
					td = $("<td rowspan='2' style='display: table-cell; vertical-align: middle; text-align: center;'></td>").text(data.data[i].status);
					tr.append(td);
					td = $("<td rowspan='2' style='display: table-cell; vertical-align: middle;'></td>").text(data.data[i].memo);
					tr.append(td);
					td = $("<td style='text-align: center;'></td>").text(data.data[i].dt_created);
					tr.append(td);
					tbody.append(tr);
					tr = $("<tr></tr>");
					td = $("<td style='text-align: center;'></td>").text(data.data[i].creator.name);
					data.data[i].creator.id ? td.attr("title", data.data[i].creator.login_id) : void(0);
					tr.append(td);
					tbody.append(tr);
				}
				var file_req = $("#view_migrate_request_modal ul li:nth-child(1) span:nth-child(2)");
				file_req.empty();
				file_req.append($("<span class='pseudo-link-cursor' style='color: #2a98c5;' onclick='download(" + data.data[0].attachment_request.id + ");'></span>").text(data.data[0].attachment_request.name));
				file_req.append($("<span></span>").text(" (" + data.data[0].attachment_request.size + "bytes)"));
				var file_log = $("#view_migrate_request_modal ul li:nth-child(2) span:nth-child(2)");
				file_log.empty();
				if (data.data[0].attachment_log.id) {
					file_log.append($("<span class='pseudo-link-cursor' style='color: #2a98c5;' onclick='download(" + data.data[0].attachment_log.id + ");'></span>").text(data.data[0].attachment_log.name));
					file_log.append($("<span></span>").text(" (" + data.data[0].attachment_log.size + "bytes)"));
				} else {
					file_log.text("登録されていません");
				}
				$("#view_migrate_request_modal").modal("show");
			} else {
				window.alert("データを表示できません。");
			}
		},
	});
	
}

function hdlClickCancelMigrateRequestBtn(tr_id, status) {
	c4s.invokeApi_ex({
		location: "manage.migrateCancelRequest",
		body: {
			tr_id: tr_id,
			status: status,
		},
		onSuccess: function (data) {
			if (data.status.code == 0 && data.status.description === "OK") {
				window.alert("キャンセルしました。");
				hdlClickRefreshMigrateRequests();
			} else {
				window.alert(data.status.description);
			}
		},
		onError: function (data) {
			if (data && data.status && data.status == 2) {
				window.alert(data.status.description);
				hdlClickRefreshMigrateRequests();
			}
		},
	});
}
// [end] for data migrate.


$(function() {

  // アップロードするファイルを選択
  $("#company-seal").change(function() {
    var file = $(this).prop('files')[0];

    // 画像以外は処理を停止
    if (! file.type.match('image.*')) {
      // クリア
      $(this).val('');
      $('#company-seal-image').html('');
      return;
    }

    // 画像表示
    var reader = new FileReader();
    reader.onload = function() {
      var img_src = $('<img style="height: 100px; width: 100px;">').attr('src', reader.result);
      $('#company-seal-image').html(img_src);
    }
    reader.readAsDataURL(file);
  });

  // アップロードするファイルを選択
  $("#company-version").change(function() {
    var file = $(this).prop('files')[0];

    // 画像以外は処理を停止
    if (! file.type.match('image.*')) {
      // クリア
      $(this).val('');
      $('#company-version-image').html('');
      return;
    }

    // 画像表示
    // var reader = new FileReader();
    // reader.onload = function() {
    //   var img_src = $('<img style="height: auto; width: auto;">').attr('src', reader.result);
    //   $('#company-version-image').html(img_src);
    // }
	// reader.readAsDataURL(file);
	
	var reader = new FileReader();
	//define the width to resize e.g 600px
	var resize_width = 200;//without px
	var resize_height = 200;//without px

	//get the image selected
	var item = file;
  
	//image turned to base64-encoded Data URI.
	reader.readAsDataURL(item);
	reader.name = item.name;//get the image's name
	reader.size = item.size; //get the image's size
	reader.onload = function(event) {
	  var img = new Image();//create a image
	  img.src = event.target.result;//result is base64-encoded Data URI
	  img.name = event.target.name;//set name (optional)
	  img.size = event.target.size;//set size (optional)
	  img.onload = function(el) {
		var elem = document.createElement('canvas');//create a canvas
  
		//scale the image and keep aspect ratio
		if (el.target.width > resize_width || el.target.height > resize_height) {
			var scaleFactor = Math.min(resize_width / el.target.width, resize_height / el.target.height);
			elem.width = el.target.width * scaleFactor;
			elem.height = el.target.height * scaleFactor;
		}
		
  
		//draw in canvas
		var ctx = elem.getContext('2d');
		ctx.drawImage(el.target, 0, 0, elem.width, elem.height);
  
		//get the base64-encoded Data URI from the resize image
		var srcEncoded = ctx.canvas.toDataURL(el.target, 'image/jpeg', 0);
  
		var img_src = $('<img style="height: auto; width: auto;">').attr('src', srcEncoded);
	  	$('#company-version-image').html(img_src);
	  
		//assign it to thumb src
		// document.querySelector('#image').src = srcEncoded;
  
		/*Now you can send "srcEncoded" to the server and
		convert it to a png o jpg. Also can send
		"el.target.name" that is the file's name.*/
  
	  }
	}
  });
});


$("#input_user_companies_dt_use_begin, #input_user_companies_dt_use_end").datepicker({
	weekStart: 1,
	viewMode: "dates",
	language: "ja",
	autoclose: true,
	changeYear: true,
	changeMonth: true,
	dateFormat: "yyyy/mm/dd",
});

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

// [begin] for new information.
function hdlClickUpdateNews() {
	var reqObj = {};
	reqObj.id = $("#info_id").val();
	reqObj.value = $("#input_new_information").val();
	c4s.invokeApi_ex({
		location: "manage.updateNewInformation",
		body: reqObj,
		onSuccess: function(data) {
			if (data && data.status && data.status.code == 0) {
				window.alert("更新しました");
				c4s.invokeApi_ex({
					location: "manage.top",
					body: {ctrl_selectedTab: "ct_new_information"},
					pageMove: true,
				});
			}
		},
	});
}
// [end] for new information.
