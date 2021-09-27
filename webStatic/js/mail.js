/* functions for mail. */
$(document).ready(function () {
	// [begin] Set initial recipients.
	var setInitialRecipientTo = function (type) {
		var i;
		var query;
		var tmp_data = $("#recipient_list_to").data() || {};
		tmp_data.workers = tmp_data.workers || {};
		tmp_data.users = tmp_data.users || {};
		tmp_data.engineers = tmp_data.engineers || {};
		if(env.recentQuery && env.recentQuery.quotation_id){
			env.recentQuery.quotation_id;
		}
		if (type === "worker") {
			if (env.recentQuery && env.recentQuery.recipients && env.recentQuery.recipients.workers) {
				query = env.recentQuery.recipients.workers;
				for (i = 0; i < query.length; i++) {
					var tmp_valid_worker = env.data.workers.filter(function (val) {
						return val.id == Number(query[i]) && val.client_type_dealing != "取引停止" && val.flg_sendmail;
					});
					if (tmp_valid_worker.length > 0) {
						tmp_data.workers[query[i]] = tmp_valid_worker[0];
					}
				}
			}
			if (env.recentQuery && env.recentQuery.recipients && env.recentQuery.recipients.users && env.data.users) {
				query = env.recentQuery.recipients.users;
				for (i = 0; i < query.length; i++) {
					var tmp_valid_user = env.data.users.filter(function (val) {
						return val.user_id == Number(query[i]);
					});
					if (tmp_valid_user.length > 0) {
						tmp_data.users[query[i]] = tmp_valid_user[0];
					}
				}
			}
		} else if (type === "engineer") {
			if (env.recentQuery && env.recentQuery.recipients && env.recentQuery.recipients.engineers) {
				query = env.recentQuery.recipients.engineers;
				for (i = 0; i < query.length; i++) {
					tmp_data.engineers[query[i]] = env.data.engineers.filter(function (val) {
						return val.id == Number(query[i]);
					})[0];
				}
			}
		}
		$.data($("#recipient_list_to"), "workers", tmp_data.workers);
		$.data($("#recipient_list_to"), "engineers", tmp_data.engineers);
		$.data($("#recipient_list_to"), "users", tmp_data.users);
		$("#recipient_list_to li:not('.pull-right')").remove();
		var i;
		var li;
		//[begin] worker.
		renderRecipientWorker(tmp_data.workers);
		renderRecipientUser(tmp_data.users);

		renderRecipientEngineerUser();

		//[end] worker.

		//[begin] engineer.
		for(i in tmp_data.engineers) {
			if (tmp_data.engineers[i]) {
				li = $("<li class='btn btn-sm btn-default mail_recipient_client' id='recipient_engineer_" + tmp_data.engineers[i].id + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"engineer\", " + tmp_data.engineers[i].id + ");'>" + tmp_data.engineers[i].name + "&nbsp;<span class='mono'>&lt;" + (tmp_data.engineers[i].mail1 || tmp_data.engineers[i].mail2) + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'></span></li>");
				$("#recipient_list_to").append(li);
			}
		}
		//[end] engineer.
		//[end] cc and bcc.
	}
	var renderTableBody = function(dataType) {
		var tbody, tr, td;
		var source, tmp;
		var i;
		if (dataType === "engineer") {
			tbody = $("#tablebody_forMailContent_engineers");
			tbody.html("");
			source = env.data.engineers.filter(function (val) {
				return val.flg_registered && val.flg_assignable;
			});
			for (i = 0; i < source.length; i++) {
				tmp = source[i];
				tr = $("<tr id='mailContent_iter_engineer_" + tmp.id + "'></tr>");
				td = $("<td class='center'><input type='checkbox' id='iter_engineer_" + tmp.id + "'" + (
					env.recentQuery.engineers && env.recentQuery.engineers.filter(function (val) {
						return val === tmp.id;
					}).length == 1 ? " checked='checked'" : ""
					) + "/></td>");
				tr.append(td);
				var engineer_name = tmp.name;
				if(tmp.owner_company_id != env.companyInfo.id){
					engineer_name = tmp.visible_name;
				}
				td = $("<td><label for='iter_engineer_" + tmp.id + "'>" + engineer_name + "</label></td>");
				tr.append(td);
				td = $("<td class='center'>" + tmp.fee + "</td>");
				tr.append(td);
				td = $("<td>" + (tmp.operation_begin ? tmp.operation_begin : "") + "</td>");
				tr.append(td);
				td = $("<td>" + (
					tmp.skill_list && tmp.skill_list.length > 15 ?
						("<span class='popover-dismiss' data-toggle='popover' data-content='" + tmp.skill_list  + "' onmouseover='$(this).popover(\"show\");' onmouseout='$(this).popover(\"hide\");'>" + tmp.skill_list.substr(0, 15) + "..." + "</span>") :
						(tmp.skill_list ? tmp.skill_list : "")
				) + "</td>");
				tr.append(td);
				td = $("<td class='center'>" + (
					tmp.attachement ?
						("<span class='glyphicon glyphicon-paperclip text-primary pseudo-link-cursor' title='" + tmp.attachement.name + "' onclick='c4s.download(" + tmp.attachement.id + ");'></span>") :
						""
				) + "</td>");
				tr.append(td);
				tbody.append(tr);
			}
		} else if (dataType === "project") {
			tbody = $("#tablebody_forMailContent_projects");
			tbody.html("");
			source = env.data.projects.filter(function (val) {
				return val.flg_shared;
			});
			for (i = 0; i < source.length; i++) {
				tmp = source[i];
				tr = $("<tr id='mailContent_iter_project_'" + tmp.id + "'></tr>");
				td = $("<td class='center'><input type='checkbox' id='iter_project_" + tmp.id + "'" + (
					env.recentQuery.projects && env.recentQuery.projects.filter(function (val) {
						return val === tmp.id;
					}).length == 1 ? " checked='checked'" : ""
				) + "/></td>");
				tr.append(td);
				td = $("<td><span class='popover-dissmiss' data-toggle='popover' data-content='" + (
					// tmp.client.id ? tmp.client.name : tmp.client_name
					tmp.client_name ? tmp.client_name : ""
				) + "' onmouseover='$(this).popover(\"show\");' onmouseout='$(this).popover(\"hide\");'><label for='iter_project_" + tmp.id + "'>" + (tmp.title.length > 8 ? tmp.title.substr(0, 8) + "..." : tmp.title) + "</label></span></td>");
				tr.append(td);
				td = $("<td>" + tmp.fee_inbound  + "</td>");
				tr.append(td);
				td = $("<td>" + (tmp.term_begin ? tmp.term_begin : "") + " - " + (tmp.term_end ? tmp.term_end : "") + "</td>");
				tr.append(td);
				td = $("<td class=''>" + (
						tmp.skill_list ?
							(tmp.skill_list.length > 10 ? (tmp.skill_list.substr(0, 10) + "...") : tmp.skill_list) : ""
					) +  "</td>");
				tr.append(td);
				tbody.append(tr);
			}
		}
	}
	if (["mail.top", "mail.createMail", "mail.createQuotation"].indexOf(env.current) > -1){

		// 画面で取得済みの場合はそれをセット、内場合は非同期で取得する
		enumAccountsStr = enumAccountsStr || null;
		if(enumAccountsStr){
        		env.data = env.data || {};
        		env.data.accounts = $.parseJSON(enumAccountsStr);
        		enumAccountsStr = null;
        		env.current === "mail.top" && env.data.workers ? $("#input_0_type_template_0").trigger("click") : void(0);

        }else{
            c4s.invokeApi_ex({
                location: "manage.enumAccounts",
                body: {},
                onSuccess: function (res) {
                    if (res.data && res.data.length > 0) {
                        env.data = env.data || {};
                        env.data.accounts = res.data;
                        env.current === "mail.top" && env.data.workers ? $("#input_0_type_template_0").trigger("click") : void(0);
                    }
                },
            });
        }
	}
	if (env.current === "mail.top") {
		c4s.invokeApi_ex({
			location: "client.enumWorkersCompact",
			body: {},
			onSuccess: function (res) {
				if (res.data && res.data.length > 0) {
					env.data = env.data || {};
					env.data.workers = res.data;
				}
				$("#input_0_type_template_0").trigger("click");
			},
		});
		//*****　非同期で取得するように変更しここでは取得しない******
		// c4s.invokeApi_ex({
		// 	location: "engineer.enumEngineersCompact",
		// 	body: {},
		// 	onSuccess: function (res) {
		// 		if (res.data && res.data.length > 0) {
		// 			env.data = env.data || {};
		// 			env.data.engineers = res.data;
		// 		}
		// 	},
		// });
		//*****　非同期で取得するように変更しここでは取得しない******
	} else if (env.current === "mail.createReminder") {
		//Todo
		// overwriting will be processed below.
	}
	if (env.current === "mail.createMail" || env.current === "mail.createReminder") {
		if (env.recentQuery.type_recipient === "forWorker" || env.recentQuery.type_recipient === "forMatching") {
			c4s.invokeApi_ex({
				location: "client.enumWorkersCompact",
				body: {},
				onSuccess: function (res) {
					if (res.data && res.data.length > 0) {
						env.data = env.data || {};
						env.data.workers = res.data;
					}
					setInitialRecipientTo("worker");
				},
			});
			c4s.invokeApi_ex({
				location: "manage.enumBpCompanyUsers",
				body: {},
				onSuccess: function (res) {
					if (res.data && res.data.length > 0) {
						env.data = env.data || {};
						env.data.users = res.data;
					}
					setInitialRecipientTo("worker");
				},
			});

		}
		if (env.recentQuery.type_recipient === "forMember") {
			c4s.invokeApi_ex({
				location: "manage.enumAccounts",
				body: {},
				onSuccess: function (res) {
					if (res.data && res.data.length > 0) {
						env.data = env.data || {};
						env.data.members = res.data;
					}
					//setInitialRecipientTo("worker");
				},
			});
		}
		c4s.invokeApi_ex({
			location: "engineer.enumEngineers",
			body: {},
			onSuccess: function (res) {
				env.data = env.data || {};
				if (res.data && res.data.length > 0) {
					env.data.engineers = res.data;
				} else {
					env.data.engineers = [];
				}

				if(env.recentQuery.type_recipient === "forMatching"){
					var bp_engineers = incBpArray(env.recentQuery.engineers, env.data.engineers);
					if(bp_engineers && bp_engineers.length > 0) {
						c4s.invokeApi_ex({
							location: "engineer.enumBpEngineers",
							body: {"engineer_ids": env.recentQuery.engineers},
							onSuccess: function (res) {
								if (res.data && res.data.length > 0) {
									Array.prototype.push.apply(env.data.engineers, res.data);
								}
								setInitialRecipientTo("engineer");
								renderTableBody("engineer");
							},
						});
					}else{
						setInitialRecipientTo("engineer");
						renderTableBody("engineer");
					}
				}else{
					setInitialRecipientTo("engineer");
					renderTableBody("engineer");
				}

			},
		});
		c4s.invokeApi_ex({
			location: "project.enumProjectsCompact",
			body: {},
			onSuccess: function (res) {
				env.data = env.data || {};
				if (res.data && res.data.length > 0) {
					env.data.projects = res.data;
				} else {
					env.data.projects = [];
				}
				if(env.recentQuery.type_recipient === "forMatching") {
                    var bp_projects = incBpArray(env.recentQuery.projects, env.data.projects);
                    if (bp_projects && bp_projects > 0) {
                        c4s.invokeApi_ex({
                            location: "project.enumBpProjects",
                            body: {"project_ids": env.recentQuery.projects},
                            onSuccess: function (res) {
                                env.data = env.data || {};
                                if (res.data && res.data.length > 0) {
                                    Array.prototype.push.apply(env.data.projects, res.data);
                                }
                                renderTableBody("project");
                            },
                        });
                    } else {
                        renderTableBody("project");
                    }
                }else {
					renderTableBody("project");
				}
			},
		});
		//[begin] onload, all templates conversion.
		if (["mail.createMail","mail.createQuotation"].indexOf(env.current) > -1) {
			$('a[data-toggle="tab"]', $("div.nav-tab")[0]).each(function (idx, val) {
				if (idx > 0) {
					$(val).on("show.bs.tab", function (evt) {
						if ($(evt.target).data("firstView")) {
							$(evt.target).trigger("shown.bs.tab");
							$("button[id^=input_0_refresh_btn_]", $("#" + evt.target.href.split("#")[1])).trigger("click");
							$(evt.target).data("firstView", false);
						}
					});
				}
			});
		}
		//[end] onload, all templates conversion.
	}else if(env.current === "mail.createQuotation"){

		env.data = env.data || {};

		if (env.recentQuery.type_recipient === "forWorker" || env.recentQuery.type_recipient === "forMatching") {

			//env.data = env.data || {};
			env.data.workers = env.data.workers || [];//client.enumWorkersCompact
			setInitialRecipientTo("worker");

			//env.data = env.data || {};
			// env.data.users = env.data.users|| [];//manage.enumBpCompanyUsers
			// setInitialRecipientTo("worker");

		}
		if (env.recentQuery.type_recipient === "forMember") {

			//env.data = env.data || {};
			env.data.members = env.data.members|| [];//manage.enumAccounts

		}

		c4s.invokeApi_ex({
			location: "engineer.enumEngineers",
			body: {},
			onSuccess: function (res) {
				env.data = env.data || {};
				if (res.data && res.data.length > 0) {
					env.data.engineers = res.data;
				} else {
					env.data.engineers = [];
				}

				setInitialRecipientTo("engineer");
				renderTableBody("engineer");
			},
		});

		env.data.projects = env.data.projects|| [];//project.enumProjectsCompact
		renderTableBody("project");



		if (["mail.createMail","mail.createQuotation"].indexOf(env.current) > -1) {
			$('a[data-toggle="tab"]', $("div.nav-tab")[0]).each(function (idx, val) {
				if (idx > 0) {
					$(val).on("show.bs.tab", function (evt) {
						if ($(evt.target).data("firstView")) {
							$(evt.target).trigger("shown.bs.tab");
							$("button[id^=input_0_refresh_btn_]", $("#" + evt.target.href.split("#")[1])).trigger("click");
							$(evt.target).data("firstView", false);
						}
					});
				}
			});
		}

	}
	//[begin] Refactor target. (for createReminder).
	// Rewrite symbol of recentQuery.
	// Add code for recipients of which object are valid.
	// Add code in case of that history template was deleted.
	//   Force overwrite default template.
	//   If on reminder, overwrite 'to_addr', 'cc_addr', 'subject', 'body' and 'attachments',
	//   otherwise overwrite 'to_addr', 'cc_addr', 'bcc_addr', 'subject', 'body' and 'attachments'.
	// Add code for attachments. Pay attention to the cases below:
	//   1) One of the attachments were already deleted.
	//   2) Limit of attachments may be shortened.
	if (env && env.recentQuery && env.recentQuery.historyMailReqId) {
	//if (env.recentQuery.referenced_mail_request_id) {
		c4s.invokeApi_ex({
			location: "mail.enumMailRequests",
			body: {
				id_list: [env.recentQuery.historyMailReqId],
				engineers: [],
				projects: [],
			},
			onSuccess: function(res) {
				if (res.data.length == 1) {
					var defaultTplId;
					var mr = res.data[0];
					
					if (env.current === "mail.createReminder") {
						$("#input_0_tpl_id_1").val();
						$("div.col-md-5:has(ul.nav:has(a[href=#dataview_engineers]))").css("display", "none");
						mr.template_id = "0";
						defaultTplId = $("#input_0_tpl_id_1").val();
						$("input[id^=input_0_subject_]").val(mr.subject);
						$("textarea[id^=input_0_body_]").val(mr.body);
					} else {
						//$("[id^=tplview_]:first")[0].id.replace("tplview_", "");
						$("[id^=tplview_]:first" + " input[id^=input_0_subject_]").val(mr.subject);
						$("[id^=tplview_]:first" + " textarea[id^=input_0_body_]").val(mr.body);
						if (mr.type_title === "様") {
							$("#input_0_type_title_" + mr.template_id + "_1")[0].checked = true;
						} else if (mr.type_title === "さん") {
							$("#input_0_type_title_" + mr.template_id + "_2")[0].checked = true;
						}
						var reply_to_combo = $("#reply_to_addr");
						reply_to_combo = reply_to_combo.length ? reply_to_combo[0] : null;
						if (reply_to_combo) {
							Array.prototype.slice.call(reply_to_combo.options).map(function (val, idx){
								reply_to_combo.selectedIndex = (mr.replyto && mr.replyto.id == $(val).data("account-id")) ? idx : reply_to_combo.selectedIndex;
								return null;
							});
						}
					}
					//[begin] to_addr.
					if (mr.addr_to && mr.addr_to.length) {
						var recipientType, srcRecipientIdList, tmpRecipientArr;
						var recipientDict = {};
						var renderRecipientEngineer = function (dataDict) {
							$("li[id^=recipient_engineer_]").remove();
							var k;
							for(k in dataDict) {
								if (dataDict[k].mail1 || dataDict[k].mail2) {
									li = $("<li class='btn btn-sm btn-default mail_recipient_client' id='recipient_engineer_" + dataDict[k].id + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"engineer\", " + dataDict[k].id + ");'>" + dataDict[k].name + "&nbsp;<span class='mono'>&lt;" + (dataDict[k].mail1 || dataDict[k].mail2) + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'</span></li>");
									$("#recipient_list_to").append(li);
								}
							}
						};
						if (mr.addr_to[0].worker_id) {//recipients are client worker.
							recipientType = "worker";
							srcRecipientIdList = mr.addr_to.map(function (val, idx, arr) {
								return val.worker_id;
							});
							tmpRecipientArr = env.data.workers.filter(function (val, idx, arr) {
								return val.client_type_dealing !== "取引停止" && srcRecipientIdList.indexOf(val.id) > -1;
							});

						} else if (mr.addr_to[0].engineer_id) {// recipients are engineer.
							recipientType = "engineer";
							srcRecipientIdList = mr.addr_to.map(function (val, idx, arr) {
								return val.engineer_id;
							});
							tmpRecipientArr = env.data.engineers.filter(function (val, idx, arr) {
								return srcRecipientIdList.indexOf(val.id) > -1;
							});
						}
						tmpRecipientArr ? tmpRecipientArr.map(function (val, idx, arr) {
							recipientDict[val.id] = val;
						}) : void(0);
						//hdlClickAddRecipientBtnOnEdit(recipientType);
						$("#recipient_list_to").data(recipientType === "worker" ? "workers" : "engineers", recipientDict);
						(recipientType === "worker" ? renderRecipientWorker : renderRecipientEngineer)(recipientDict);
					}
					//[end] to_addr.
					//[begin] attachments.
					if (mr.attachment_id && mr.attachment_id.length) {
						c4s.invokeApi_ex({
							location: "file.enum",
							body: {},
							onSuccess: function (cres) {
								if (cres && cres.data) {
									var i, atmtArr;
									atmtArr = cres.data.filter(function (val, idx, arr) {
										return mr.attachment_id.indexOf(val.id) > -1;
									});
									atmtArr = atmtArr.slice(0, env.limit.LMT_LEN_MAIL_ATTACHMENT);
									defaultTplId = $("#input_0_tpl_id_1").val();
									$("[id^=attachment_container_" + defaultTplId + "_]").each(function (idx, el) {
										var loop_idx = el.id.split("_")[3];
										var fileInputEl = $("#attachment_file_" + defaultTplId + "_" + loop_idx);
										var fileIdEl = $("#attachment_id_" + defaultTplId + "_" + loop_idx);
										var labelEl = $("#attachment_label_" + defaultTplId + "_" + loop_idx);
										var commitBtnEl = $("#attachment_btn_commit_" + defaultTplId + "_" + loop_idx);
										var deleteBtnEl = $("#attachment_btn_delete_" + defaultTplId + "_" + loop_idx);
										if (idx < atmtArr.length) {
											var atmtObj = atmtArr[idx];
											fileInputEl.val(null);
											fileIdEl.val(atmtObj.id);
											fileInputEl.css("display", "none");
											labelEl.html(atmtObj.name + "&nbsp;(<span class='mono'>" + atmtObj.size + "bytes</span>)");
											labelEl.css("display", "inline");
											commitBtnEl.css("display", "inline");
											deleteBtnEl.css("display", "inline");
										} else {
											fileInputEl.val(null);
											fileInputEl.css("display", "inline");
											fileIdEl.val(null);
											labelEl.html("");
											labelEl.css("display", "none");
											commitBtnEl.css("display", "none");
											deleteBtnEl.css("display", "none");
										}
									});
								}
							},
						});
					}
					//[end] attachments.
					$("a[href^=#tplview_" + mr.template_id + "]").trigger("click");
				}
			},
		});
	} else {
		if(env.current !== "mail.createMail" && env.current !== "mail.createQuotation"){
			// メール作成の場合は実施しない
			$("#input_0_refresh_btn_1").trigger("click");
		}
	}
	//[end] Refactor target. (for createReminder).
	//[begin] cc and bcc.
	if (env.limit && env.limit.MAIL_RECEIVER_CC) {
		for(i = 0; i < env.limit.MAIL_RECEIVER_CC.length; i++) {
			if (env.limit.MAIL_RECEIVER_CC[i].mail && env.limit.MAIL_RECEIVER_CC[i].mail !== "") {
				li = $("<li class='btn btn-sm btn-default' id='recipient_cc_" + i + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"cc\", \"recipient_cc_" + i + "\");'>" + env.limit.MAIL_RECEIVER_CC[i].name + "&nbsp;<span class='mono'>&lt;" + env.limit.MAIL_RECEIVER_CC[i].mail + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'></span></li>");
				li.data("name", env.limit.MAIL_RECEIVER_CC[i].name);
				li.data("mail", env.limit.MAIL_RECEIVER_CC[i].mail);
				$("#recipient_list_cc").append(li);
			}
		}
	}
	if (env.limit && env.limit.MAIL_RECEIVER_BCC) {
		for(i = 0; i < env.limit.MAIL_RECEIVER_BCC.length; i++) {
			if (env.limit.MAIL_RECEIVER_BCC[i].mail && env.limit.MAIL_RECEIVER_BCC[i].mail !== "") {
				li = $("<li class='btn btn-sm btn-default' id='recipient_bcc_" + i + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"bcc\", \"recipient_bcc_" + i + "\");'>" + env.limit.MAIL_RECEIVER_BCC[i].name + "&nbsp;<span class='mono'>&lt;" + env.limit.MAIL_RECEIVER_BCC[i].mail + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'></span></li>");
				li.data("name", env.limit.MAIL_RECEIVER_BCC[i].name);
				li.data("mail", env.limit.MAIL_RECEIVER_BCC[i].mail);
				$("#recipient_list_bcc").append(li);
			}
		}
	}
	// [end] Set initial recipients.
	if (env.current === "mail.createMail" || env.current === "mail.createQuotation" || env.current === "mail.createReminder") {
		var i;
		/*
		if (env.recentQuery.engineers) {
			for(i = 0; i < env.recentQuery.engineers.length; i++) {
				$("#iter_engineer_" + env.recentQuery.engineers[i])[0].checked = true;
			}
		}
		*/
		/*
		if (env.recentQuery.projects) {
			for(i = 0; i < env.recentQuery.projects.length; i++) {
				$("#iter_project_" + env.recentQuery.projects[i])[0].checked = true;
			}
		}
		*/
		// [begin] Set event handler for content tab activated.
		$("a[data-toggle='tab'][href^=#tplview_]").on("shown.bs.tab", function (evt) {
			var type_iterators = $(evt.target).data("typeIterator");
			$("a[data-toggle='tab'][href^=#dataview_]").css("display", "none");
			$("div[id^=dataview_]").css("display", "none");
			if (type_iterators && type_iterators.length == 2) {
				if (env.recentQuery.type_recipient === "forWorker") {
					$("a[href=#dataview_engineers]").css("display", "block");
					$("#dataview_engineers").css("display", "auto");
					$("a[href=#dataview_projects]").css("display", "block");
					$("#dataview_projects").css("display", "auto");
					if (env.recentQuery.engineers && env.recentQuery.engineers.length) {
						$("a[href=#dataview_engineers]").trigger("click");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					} else if (env.recentQuery.projects && env.recentQuery.projects.length) {
						$("a[href=#dataview_projects]").trigger("click");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					}
					if (!env.recentQuery.historyMailReqId) {
						if(env.current !== "mail.createMail" || env.current !== "mail.createQuotation"){
							// メール作成の場合は実施しない
							$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
						}
					}
				} else if (env.recentQuery.type_recipient === "forMatching") {
					if (env.recentQuery.engineers && env.recentQuery.engineers.length) {
						$("a[href=#dataview_projects]").css("display", "block");
						$("#dataview_projects").css("display", "auto");
						$("a[href=#dataview_projects]").trigger("click");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					} else if (env.recentQuery.projects && env.recentQuery.projects.length) {
						$("a[href=#dataview_engineers]").css("display", "block");
						$("#dataview_engineers").css("display", "auto");
						$("a[href=#dataview_engineers]").trigger("click");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					}
					if (!env.recentQuery.historyMailReqId) {
						if(env.current !== "mail.createMail" || env.current !== "mail.createQuotation"){
							// メール作成の場合は実施しない
							$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
						}
					}
				}
				/*
				if (type_iterators.length > 0) {
					if (type_iterators[0] === "技術者情報") {
						$("a[data-toggle='tab'][href=#dataview_engineers]").trigger("click");
					} else if (type_iterators[0] === "案件情報") {
						setTimeout(function () {
							$("a[data-toggle='tab'][href=#dataview_projects]").trigger("click");
						}, 50);
					}
					//$("a[data-toggle='tab'][href=#dataview_" + (type_iterators[0] === "技術者情報" ? "engineers" : "projects") + "]").trigger("click");

				}
				*/
			} else {
				if (env.recentQuery.type_recipient === "forMatching") {
					if (type_iterators.indexOf("技術者情報") > -1) {
						$("a[href=#dataview_projects]").css("display", "block");
						$("#dataview_projects").css("display", "block");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					}
					if (type_iterators.indexOf("案件情報") > -1) {
						$("a[href=#dataview_engineers]").css("display", "block");
						$("#dataview_engineers").css("display", "block");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					}
					if (type_iterators.length > 0) {
						if (type_iterators[0] === "技術者情報") {
							$("a[data-toggle='tab'][href=#dataview_projects]").trigger("click");
							$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
						} else if (type_iterators[0] === "案件情報") {
							setTimeout(function () {
								$("a[data-toggle='tab'][href=#dataview_engineers]").trigger("click");
								$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
							}, 50);
						}
						//$("a[data-toggle='tab'][href=#dataview_" + (type_iterators[0] === "技術者情報" ? "engineers" : "projects") + "]").trigger("click");
					}
				} else {
					if (type_iterators.indexOf("技術者情報") > -1) {
						$("a[href=#dataview_engineers]").css("display", "block");
						$("#dataview_engineers").css("display", "block");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					}
					if (type_iterators.indexOf("案件情報") > -1) {
						$("a[href=#dataview_projects]").css("display", "block");
						$("#dataview_projects").css("display", "block");
						$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
					}
					if (type_iterators.length > 0) {
						if (type_iterators[0] === "技術者情報") {
							$("a[data-toggle='tab'][href=#dataview_engineers]").trigger("click");
							$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
						} else if (type_iterators[0] === "案件情報") {
							setTimeout(function () {
								$("a[data-toggle='tab'][href=#dataview_projects]").trigger("click");
								$("div[id^=tplview_].active button[id^=input_0_refresh_btn_]").trigger("click");
							}, 50);
						}
						//$("a[data-toggle='tab'][href=#dataview_" + (type_iterators[0] === "技術者情報" ? "engineers" : "projects") + "]").trigger("click");
					}
				}
			}
			if (env.recentQuery.type_iterator_default) {
				if (env.recentQuery.type_recipient === "forMatching") {
					$("a[data-toggle='tab'][href=#dataview_" + (env.recentQuery.type_iterator_default === "技術者情報" ? "projects" : "engineers") + "]").trigger("click");
				} else {
					$("a[data-toggle='tab'][href=#dataview_" + (env.recentQuery.type_iterator_default === "技術者情報" ? "engineers" : "projects") + "]").trigger("click");
				}
			}
		});
		if (env.current === "mail.createReminder") {
			if (env.recentQuery.engineers.length > 0) {
				$("a[data-toggle='tab'][href=#dataview_engineers]").trigger("click");
			} else if (env.recentQuery.projects.length > 0) {
				$("a[data-toggle='tab'][href=#dataview_projects]").trigger("click");
			} else {
				$("a[data-toggle='tab'][href=#dataview_engineers]").trigger("click");
			}
			if (!env.recentQuery || !env.recentQuery.historyMailReqId) {
				$("#input_0_refresh_btn_1").trigger("click");
			}
		}
		// [end] Set event handler for content tab activated.
		$("a[data-toggle='tab'][href^=#tplview_]:first").trigger("click");
	}
	$("#view_body_modal").on("hide.bs.tab", function (evt) {
		$("#sendMail_btn")[0].disabled = false;// for debug mode.
	});
	$("#edit_address_modal").on("hide.bs.modal", function (evt) {
		c4s.clearValidate({
			"mail": "input_add_addr_mail",
		});
		$("#input_add_addr_name").val(null);
		$("#input_add_addr_mail").val(null);
	});
});

/* [begin] trigger functions on creating mail. */
function triggerMailEngineerOnHome() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var idList = [];
	/*
	$("input[id^=iter_engineer_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			idList.push(Number(el.id.replace("iter_engineer_selected_cb_", "")));
		}
	});
	*/
	$("input").each(function (idx, el, arr) {
		if (el.id && el.id.indexOf("iter_engineer_selected_cb_") == 0 && el.checked) {
			idList.push(Number(el.id.replace("iter_engineer_selected_cb_", "")));
		}
	});
	if ( idList.length > 0 ) {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: {
				engineers: idList,
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

function triggerMailProjectOnHome() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var idList = [];
	/*
	$("input[id^=iter_project_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			idList.push(Number(el.id.replace("iter_project_selected_cb_", "")));
		}
	});
	*/
	$("input").each(function (idx, el, arr) {
		if (el.id && el.id.indexOf("iter_project_selected_cb_") == 0 && el.checked){
			idList.push(Number(el.id.replace("iter_project_selected_cb_", "")));
		}
	});
	if ( idList.length > 0 ) {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: {
				projects: idList,
				type_recipient: "forWorker",
				type_iterator_default: "案件情報",
			},
			pageMove: true,
			newPage: true,
		});
	} else {
		alert("対象データを選択してください。");
	}
}

function triggerMailWorkerOnHome() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var idList = [];
	/*
	$("input[id^=iter_worker_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			idList.push(Number(el.id.replace("iter_worker_selected_cb_", "")));
		}
	});
	*/
	$("input").each(function (idx, el, arr) {
		if (el.id && el.id.indexOf("iter_worker_selected_cb_") == 0 && el.checked) {
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

function triggerCreateMailOnMail(option) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	var i;
	if (!option) {
		reqObj.type_recipient = $("#input_0_type_template_0")[0].checked ? "forWorker" : "forEngineer";
		reqObj.recipients = {};
		if (reqObj.type_recipient === "forWorker") {
			reqObj.recipients.workers = [];
			$("input[id^=recipient_iter_worker_]").each(function (idx, el, arr) {
				if (el.checked) {
					reqObj.recipients.workers.push(Number(el.id.replace("recipient_iter_worker_", "")));
				}
			});
		} else if (reqObj.type_recipient === "forEngineer") {
			reqObj.recipients.engineers = [];
			$("input[id^=recipient_iter_engineer_]").each(function (idx, el, arr) {
				if (el.checked) {
					reqObj.recipients.engineers.push(Number(el.id.replace("recipient_iter_engineer_", "")));
				}
			});
		}
	} else {
		reqObj.type_recipient = option.type_recipient;
		reqObj.type_iterator_default = option.type_iterator;
		reqObj.referenced_mail_request_id = option.referenced_mail_request;
		reqObj.recipients = {workers: [], engineers: [], cc: [], bcc: []};
		if (option.workers) {
			reqObj.recipients.workers = option.workers;
		}
		if (option.engineers) {
			reqObj.recipients.engineers = option.engineers;
		}
		if (option.cc) {
			for(i = 0; i < option.cc.length; i++) {
				if (option.cc[i] && option.cc[i].mail) {
					reqObj.recipients.cc.push(option.cc[i]);
				}
			}
		}
		if (option.bcc) {
			for(i = 0; i < option.bcc.length; i++) {
				if (option.bcc[i] && option.bcc[i].mail) {
					reqObj.recipients.bcc.push(option.bcc[i]);
				}
			}
		}
	}
	if ((reqObj.recipients.workers && reqObj.recipients.workers.length == 0 || !reqObj.recipients.workers) &&
		(reqObj.recipients.engineers && reqObj.recipients.engineers.length == 0 || !reqObj.recipients.engineers)) {
		alert("宛先を選択してください。");
	} else {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: reqObj,
			pageMove: true,
			newPage: true,
		});
	}
}

function triggerCreateMailFromHistory(mailReqId) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	if (mailReqId) {
		c4s.invokeApi_ex({
			location: "mail.enumMailRequests",
			body: {id_list: [mailReqId,]},
			onSuccess: function (res) {
				if (res.data.length == 1) {
					var mr = res.data[0];
					c4s.invokeApi_ex({
						location: (function (tr) {
								var ret;
								switch (tr) {
									case "リマインダー":
										ret = "mail.createReminder";
										break;
									case "取引先担当者（既定）":
									case "取引先担当者":
									case "技術者（既定）":
									case "技術者":
									case "マッチング":
										ret = "mail.createMail";
										break;
									case "見積書":
									case "請求先注文書":
									case "注文書":
									case "請求書":
										ret = "mail.createQuotation";
										break;
									default:
										ret = "unknown";
								}
								return ret;
							})(mr.template_type_recipient),
						body: {
							historyMailReqId: mailReqId,
							engineers: [],
							projects: [],
							users: [],
							recipients: {
								workers: mr.addr_to.filter(function (val, idx) {
									return val.worker_id;
								}).map(function (val, idx) {
									return val.worker_id;
								}),
								engineers: mr.addr_to.filter(function (val, idx) {
									return val.engineer_id;
								}).map(function (val, idx) {
									return val.engineer_id;
								}),
								users: mr.addr_to.filter(function (val, idx) {
									return val.user_id;
								}).map(function (val, idx) {
									return val.user_id;
								}),
							},
							type_recipient: (function (tr) {
								var ret;
								switch (tr) {
									case "リマインダー":
										ret = "forMember";
										break;
									case "取引先担当者（既定）":
									case "取引先担当者":
									case "見積書":
									case "請求先注文書":
									case "注文書":
									case "請求書":
										ret = "forWorker";
										break;
									case "技術者（既定）":
									case "技術者":
										ret = "forEngineer";
										break;
									case "マッチング":
										ret = "forMatching";
										break;
									default:
										ret = "unknown";
								}
								return ret;
							})(mr.template_type_recipient),
							quotation_type: (function (tr) {
								var ret;
								switch (tr) {
									case "見積書":
										ret = "estimate";
										break;
									case "請求先注文書":
										ret = "order";
										break;
									case "注文書":
										ret = "purchase";
										break;
									case "請求書":
										ret = "invoice";
										break;
									default:
										ret = "unknown";
								}
								return ret;
							})(mr.template_type_recipient),
						},
						pageMove: true,
						newPage: true,
					});
				} else {
					alert("当該履歴は再利用できません。（id:" + mailReqId + "）");
				}
			},
		});
	} else {
		return false;
	}
}
/* [end] trigger functions on creating mail. */

/* [begin] UI functions for editing mail. */
// [begin] refresh mail message body.
function refreshMailBody(option) {
	var reqObj = {};
	reqObj.template_id = option.template_id;
	reqObj.type_title = option.type_title;
	reqObj.type_recipient = env.recentQuery.type_recipient;
	reqObj.type_data = (function (iter) {
		var i;
		for (i = 0; i < iter.length; i++) {
			if ($(iter[i]).hasClass("active")) {
				return iter[i].id.replace("dataview_", "");
			}
		}
	})($("[id^=dataview_]"));
	if (env.recentQuery.type_recipient === "forMatching") {
		reqObj.type_data = reqObj.type_data === "engineers" ? "projects" : "engineers";
	}
	if(env.current == "mail.createQuotation"){
		reqObj.type_data = "projects";
	}
	reqObj.data = [];
	if (reqObj.type_data === "engineers") {
		$("input[id^=iter_engineer_]").each(function (idx, el) {
			if (el.checked) {
				reqObj.data.push(Number(el.id.replace("iter_engineer_", "")));
			}
		});
	} else if (reqObj.type_data === "projects") {
		$("input[id^=iter_project_]").each(function (idx, el) {
			if (el.checked) {
				reqObj.data.push(Number(el.id.replace("iter_project_", "")));
			}
		});
	}
	reqObj.engineer_ids = [];
	reqObj.project_ids = [];
	reqObj.matching_tmp_flg = (function (iter) {
		var i;
		for (i = 0; i < iter.length; i++) {
			if ($(iter[i]).hasClass("active")) {
				return iter[i].id.replace("dataview_", "");
			}
		}
	})($("[id^=dataview_]"));
	if(reqObj.matching_tmp_flg){
		$("input[id^=iter_engineer_]").each(function (idx, el) {
			if (el.checked) {
				reqObj.engineer_ids.push(Number(el.id.replace("iter_engineer_", "")));
			}
		});

	$("input[id^=iter_project_]").each(function (idx, el) {
			if (el.checked) {
				reqObj.project_ids.push(Number(el.id.replace("iter_project_", "")));
			}
		});
	}

	if(env.recentQuery.quotation_id){
		reqObj.quotation_id = env.recentQuery.quotation_id;
	}
	if(env.recentQuery.quotation_type){
		reqObj.quotation_type = env.recentQuery.quotation_type;
    }
    if(env.current == "mail.createQuotation" && reqObj.data.length ==0){
		reqObj.data = env.recentQuery.projects;
	}

	reqObj.type_data = reqObj.type_data || "null";
	reqObj.data = reqObj.data || [];
	env.debugOut(reqObj);
	$("#view_body_modal .modal-footer button").addClass("disabled");
	c4s.invokeApi_ex({
		location: "mail.simulateMailBody",
		body: reqObj,
		onSuccess: function (data) {
			$("#" + option.body_id).val(data.data.body);
			$("#view_body_modal .modal-footer button").removeClass("disabled");
		},
		onError: function (data) {
			$("#view_body_modal .modal-footer button").removeClass("disabled");
		},
	});
	//[begin] attachment.
	if (reqObj.type_data === "engineers") {
		var attachement_list = [];
		var tmp;
		$("input[id^=iter_engineer_]").each(function (idx, el) {
			if (el.checked) {
				tmp = env.data.engineers.filter(function(val, idx, arr) {
					return Number(el.id.replace("iter_engineer_", "")) == val.id;
				})[0];
				if (tmp.attachement) {
					attachement_list.push(tmp.attachement);
				}
			}
		});
		$("[id^=attachment_container_" + option.template_id + "_]").each(function (idx, el) {
			var tpl_id = el.id.split("_")[2];
			var loop_idx = el.id.split("_")[3];
			var fileInputEl = $("#attachment_file_" + tpl_id + "_" + loop_idx);
			var fileIdEl = $("#attachment_id_" + tpl_id + "_" + loop_idx);
			var labelEl = $("#attachment_label_" + tpl_id + "_" + loop_idx);
			var commitBtnEl = $("#attachment_btn_commit_" + tpl_id + "_" + loop_idx);
			var deleteBtnEl = $("#attachment_btn_delete_" + tpl_id + "_" + loop_idx);
			if (idx < attachement_list.length) {
				var atmtObj = attachement_list[idx];
				fileInputEl.val(null);
				fileIdEl.val(atmtObj.id);
				fileInputEl.css("display", "none");
				labelEl.html(atmtObj.name + "&nbsp;(<span class='mono'>" + atmtObj.size + "bytes</span>)");
				labelEl.css("display", "inline");
				commitBtnEl.css("display", "inline");
				deleteBtnEl.css("display", "inline");
			} else {
				fileInputEl.val(null);
				fileInputEl.css("display", "inline");
				fileIdEl.val(null);
				labelEl.html("");
				labelEl.css("display", "none");
				commitBtnEl.css("display", "none");
				deleteBtnEl.css("display", "none");
			}
		});
		if ($("[id^=attachment_container_" + option.template_id + "_]").length < attachement_list.length) {
			alert("対象技術者の添付ファイル数がメールへのファイル添付数制限数を超えました。メールへのファイル添付数制限数より多くのファイルを除外しました。");
		}
	} else if (reqObj.type_data === "projects") {
		var attachement_list = [];
		var tmp;
		if (reqObj.type_recipient == "forMatching") {
			$("input[id^=iter_engineer_]").each(function (idx, el) {
				if (el.checked) {
					tmp = env.data.engineers.filter(function(val, idx, arr) {
						return Number(el.id.replace("iter_engineer_", "")) == val.id;
					})[0];
					if (tmp.attachement) {
						attachement_list.push(tmp.attachement);
					}
				}
			});
		}
		$("[id^=attachment_container_" + option.template_id + "_]").each(function (idx, el) {
			var tpl_id = el.id.split("_")[2];
			var loop_idx = el.id.split("_")[3];
			var fileInputEl = $("#attachment_file_" + tpl_id + "_" + loop_idx);
			var fileIdEl = $("#attachment_id_" + tpl_id + "_" + loop_idx);
			var labelEl = $("#attachment_label_" + tpl_id + "_" + loop_idx);
			var commitBtnEl = $("#attachment_btn_commit_" + tpl_id + "_" + loop_idx);
			var deleteBtnEl = $("#attachment_btn_delete_" + tpl_id + "_" + loop_idx);
			if (idx < attachement_list.length) {
				var atmtObj = attachement_list[idx];
				fileInputEl.val(null);
				fileIdEl.val(atmtObj.id);
				fileInputEl.css("display", "none");
				labelEl.html(atmtObj.name + "&nbsp;(<span class='mono'>" + atmtObj.size + "bytes</span>)");
				labelEl.css("display", "inline");
				commitBtnEl.css("display", "inline");
				deleteBtnEl.css("display", "inline");
			} else {
				fileInputEl.val(null);
				fileInputEl.css("display", "inline");
				fileIdEl.val(null);
				labelEl.html("");
				labelEl.css("display", "none");
				commitBtnEl.css("display", "none");
				deleteBtnEl.css("display", "none");
			}
		});
	}
	//[end] attachment.
}

function sendMailRequest(option) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//alert($("#reserve_date").val());
	//[end] Limitation of Mailing capacity per month.
	//[begin] Prevent multiple click.
	var smBtn = $("#sendMail_btn");
	if(smBtn.attr("disabled") === "disabled") {
		return;
	} else {
		smBtn.prop("disabled", true);
	}
	//[end] Prevent multiple click.
	$("#recipient_list_to").parent().removeClass("has-error");
	var subjectElementId = "input_0_subject_" + option.body_id.split("_")[3];
	c4s.clearValidate({
		"subject": subjectElementId,
		"addr_to": "recipient_list_to",
		"addr_cc": "recipient_list_cc",
		"addr_bcc": "recipient_list_bcc",
	});
	var reqObj = {};
	reqObj.type_title = option.type_title;
	reqObj.tpl_id = option.template_id;
	reqObj.subject = option.subject;
	reqObj.body = $(option.body_id).val();
	//[begin] addr_to.
	var tmp = $("#recipient_list_to").data();
	var tmp2;
	var s_time = $("#reserve_date").val();
	reqObj.schedule_time = [];
	if (s_time) {
		reqObj.schedule_time[0] = s_time.replace("T", " ");
	}
	var i;
	reqObj.addr_to_list = [];
	if (env.recentQuery.type_recipient === "forMember") {
		for(i in tmp.members) {
			tmp2 = env.data.members.filter(function (val) {
				return val.id == Number(i);
			})[0];
			if (tmp.members[i] && tmp2) {
				reqObj.addr_to_list.push({
					member_id: tmp2.id,
					name: tmp2.name,
					mail: tmp2.mail1,
				});
			}
		}
	} else if (env.recentQuery.type_recipient === "forWorker") {
		$("#recipient_list_to ul").each(function (idx, el) {

				$(el).data("workers").map(function (val) {
					reqObj.addr_to_list.push({
						worker_id: val.id,
						name: val.name,
						mail: val.mail1 || val.mail2,
						client_id: val.client_id,
						client_name: val.client_name,
						recipient_priority: val.recipient_priority,
					});
				});
		});
	} else if (env.recentQuery.type_recipient === "forMatching") {
		$("#recipient_list_to ul").each(function (idx, el) {

				$(el).data("workers").map(function (val) {
					reqObj.addr_to_list.push({
						worker_id: val.id,
						user_id: val.user_id,
						name: val.name,
						mail: val.mail1 || val.mail2,
						client_id: val.client_id,
						client_name: val.client_name,
						recipient_priority: val.recipient_priority,
					});
				});
		});
	} else if (env.recentQuery.type_recipient === "forEngineer") {
		var tmpEngineerId, tmpEngineerObj;
		$("#recipient_list_to li[id^=recipient_engineer_]").each(function (idx, el) {
			tmpEngineerId = Number(el.id.replace("recipient_engineer_", ""));
			tmpEngineerObj = env.data.engineers.filter(function (val, idx, arr) {
				return val.id == tmpEngineerId;
			})[0];
			reqObj.addr_to_list.push({
				engineer_id: tmpEngineerObj.id,
				name: tmpEngineerObj.name,
				mail: tmpEngineerObj.mail1 || tmpEngineerObj.mail2,
			});
		});
	} else {
		env.debugOut("env.recentQuery.type_recipient('" + env.recentQuery.type_recipinet + "')が不定です。");
	}
	//[end] addr_to.
	//[begin] reply_to_addr.
	reqObj.id_replyto = $("#reply_to_addr option:selected").data('account-id');
	//[end] reply_to_addr.
	//[begin] addr_cc.
	reqObj.addr_cc = [];
	$("#recipient_list_cc li:not('.pull-right')").each(function (idx, val, arr) {
		tmp = $(val).data();
		reqObj.addr_cc.push({name: tmp.name, mail: tmp.mail});
	});
	//[end] addr_cc.
	//[begin] addr_bcc.
	reqObj.addr_bcc = [];
	$("#recipient_list_bcc li:not('.pull-right')").each(function (idx, val, arr) {
		tmp = $(val).data();
		reqObj.addr_bcc.push({name: tmp.name, mail: tmp.mail});
	});
	//[end] addr_bcc.
	if (
		(reqObj.addr_to_list && !reqObj.addr_to_list.length && env.recentQuery.type_recipient !== "forMember") ||
			(
				((reqObj.addr_to_list && !reqObj.addr_to_list.length) || !reqObj.addr_to_list) &&
				((reqObj.addr_cc && !reqObj.addr_cc.length) || !reqObj.addr_cc) &&
				env.recentQuery.type_recipient === "forMember"
			)
		) {
		alert("宛先を選択してください。");
		$("#view_body_modal").modal("hide");
		//$("#recipient_list_cc").trigger("focus");
		$("#recipient_list_to").parent().addClass("has-error");
		document.body.scrollTop = 0;
		$("#sendMail_btn").attr("disabled", false);
		return;
	}
	//[begin] attachments.
	reqObj.attachments = (function(idArr) {
		var res = [];
		var tmp;
		var i;
		for(i = 0; i < idArr.length; i++) {
			tmp = $(idArr[i]);
			if (tmp.val()) {
				res.push(Number(tmp.val()));
			}
		}
		return res;
	})(option.attachment_id);
	//[end] attachments.
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.mailRequest,
		{
			"subject": subjectElementId,
			"addr_to": "recipient_list_to",
			"addr_cc": "recipient_list_cc",
			"addr_bcc": "recipient_list_bcc",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		window.alert("要修正項目:\n" + c4s.genValidateMessage(validLog, "mailRequest").join("\n  "));
		$("#view_body_modal").modal("hide");
		$("#sendMail_btn")[0].disabled = false;
		return;
	}
	reqObj.addr_to_str = null;
	reqObj.delay = 200;

	if(env.current == "mail.createQuotation"){
		reqObj.quotation_id = env.recentQuery.quotation_id;
		reqObj.quotation_type = env.recentQuery.quotation_type;
	}

	c4s.invokeApi_ex( {
		location: "mail.sendMailRequestAsync",
		body: reqObj,
		onSuccess: function (data) {
			env.flgTransfering = false;
			alert("メールを送信しました。");
			$("#view_body_modal").modal("hide");
			$("#sendMail_btn")[0].disabled = false;
			if(!env.DEBUG_MODE) {
				window.close();
			}
		},
		onError: function (data) {
			$("#sendMail_btn")[0].disabled = false;
			console ? console.log([reqObj, data]) : void(0);
		},
	});

}

// [end] refresh mail message body.

function sendMailReserve(option) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//alert($("#reserve_date").val());
	//[end] Limitation of Mailing capacity per month.
	//[begin] Prevent multiple click.
	var smBtn = $("#sendMail_btn");
	if(smBtn.attr("disabled") === "disabled") {
		return;
	} else {
		smBtn.prop("disabled", true);
	}
	//[end] Prevent multiple click.
	$("#recipient_list_to").parent().removeClass("has-error");
	var subjectElementId = "input_0_subject_" + option.body_id.split("_")[3];
	c4s.clearValidate({
		"subject": subjectElementId,
		"addr_to": "recipient_list_to",
		"addr_cc": "recipient_list_cc",
		"addr_bcc": "recipient_list_bcc",
	});
	var reqObj = {};
	reqObj.type_title = option.type_title;
	reqObj.tpl_id = option.template_id;
	reqObj.subject = option.subject;
	reqObj.body = $(option.body_id).val();
	//[begin] addr_to.
	var tmp = $("#recipient_list_to").data();
	var tmp2;
	var s_time = $("#reserve_date").val();
	if (env.UA.indexOf("iPhone") > -1) {
		s_time = new Date(s_time).format("DD/MM/YYYY HH:MM A");
	}
	s_time = s_time.replace("T", " ");
	if (isNaN(Date.parse(s_time))) {
		alert("予約時間を入力してください。");
		return;
    }

	// check if selected time is past than now
	var now = new Date();
	now.setSeconds(0);
	var selectedTime = new Date(s_time);
	if (selectedTime < now) {
		alert("過去日時には送信出来ません。");
		return;
	}

	reqObj.schedule_time = [];
	if (s_time) {
		reqObj.schedule_time[0] = s_time;
	}
	var i;
	reqObj.addr_to_list = [];
	if (env.recentQuery.type_recipient === "forMember") {
		for(i in tmp.members) {
			tmp2 = env.data.members.filter(function (val) {
				return val.id == Number(i);
			})[0];
			if (tmp.members[i] && tmp2) {
				reqObj.addr_to_list.push({
					member_id: tmp2.id,
					name: tmp2.name,
					mail: tmp2.mail1,
				});
			}
		}
	} else if (env.recentQuery.type_recipient === "forWorker") {
		$("#recipient_list_to ul").each(function (idx, el) {

				$(el).data("workers").map(function (val) {
					reqObj.addr_to_list.push({
						worker_id: val.id,
						name: val.name,
						mail: val.mail1 || val.mail2,
						client_id: val.client_id,
						client_name: val.client_name,
						recipient_priority: val.recipient_priority,
					});
				});
		});
	} else if (env.recentQuery.type_recipient === "forMatching") {
		$("#recipient_list_to ul").each(function (idx, el) {

				$(el).data("workers").map(function (val) {
					reqObj.addr_to_list.push({
						worker_id: val.id,
						user_id: val.user_id,
						name: val.name,
						mail: val.mail1 || val.mail2,
						client_id: val.client_id,
						client_name: val.client_name,
						recipient_priority: val.recipient_priority,
					});
				});
		});
	} else if (env.recentQuery.type_recipient === "forEngineer") {
		var tmpEngineerId, tmpEngineerObj;
		$("#recipient_list_to li[id^=recipient_engineer_]").each(function (idx, el) {
			tmpEngineerId = Number(el.id.replace("recipient_engineer_", ""));
			tmpEngineerObj = env.data.engineers.filter(function (val, idx, arr) {
				return val.id == tmpEngineerId;
			})[0];
			reqObj.addr_to_list.push({
				engineer_id: tmpEngineerObj.id,
				name: tmpEngineerObj.name,
				mail: tmpEngineerObj.mail1 || tmpEngineerObj.mail2,
			});
		});
	} else {
		env.debugOut("env.recentQuery.type_recipient('" + env.recentQuery.type_recipinet + "')が不定です。");
	}
	//[end] addr_to.
	//[begin] reply_to_addr.
	reqObj.id_replyto = $("#reply_to_addr option:selected").data('account-id');
	//[end] reply_to_addr.
	//[begin] addr_cc.
	reqObj.addr_cc = [];
	$("#recipient_list_cc li:not('.pull-right')").each(function (idx, val, arr) {
		tmp = $(val).data();
		reqObj.addr_cc.push({name: tmp.name, mail: tmp.mail});
	});
	//[end] addr_cc.
	//[begin] addr_bcc.
	reqObj.addr_bcc = [];
	$("#recipient_list_bcc li:not('.pull-right')").each(function (idx, val, arr) {
		tmp = $(val).data();
		reqObj.addr_bcc.push({name: tmp.name, mail: tmp.mail});
	});
	//[end] addr_bcc.
	if (
		(reqObj.addr_to_list && !reqObj.addr_to_list.length && env.recentQuery.type_recipient !== "forMember") ||
			(
				((reqObj.addr_to_list && !reqObj.addr_to_list.length) || !reqObj.addr_to_list) &&
				((reqObj.addr_cc && !reqObj.addr_cc.length) || !reqObj.addr_cc) &&
				env.recentQuery.type_recipient === "forMember"
			)
		) {
		alert("宛先を選択してください。");
		$("#view_body_modal").modal("hide");
		//$("#recipient_list_cc").trigger("focus");
		$("#recipient_list_to").parent().addClass("has-error");
		document.body.scrollTop = 0;
		$("#sendMail_btn").attr("disabled", false);
		return;
	}
	//[begin] attachments.
	reqObj.attachments = (function(idArr) {
		var res = [];
		var tmp;
		var i;
		for(i = 0; i < idArr.length; i++) {
			tmp = $(idArr[i]);
			if (tmp.val()) {
				res.push(Number(tmp.val()));
			}
		}
		return res;
	})(option.attachment_id);
	//[end] attachments.
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.mailRequest,
		{
			"subject": subjectElementId,
			"addr_to": "recipient_list_to",
			"addr_cc": "recipient_list_cc",
			"addr_bcc": "recipient_list_bcc",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		window.alert("要修正項目:\n" + c4s.genValidateMessage(validLog, "mailRequest").join("\n  "));
		$("#view_body_modal").modal("hide");
		$("#sendMail_btn")[0].disabled = false;
		return;
	}
	reqObj.addr_to_str = null;
	reqObj.delay = 200;

	if(env.current == "mail.createQuotation"){
		reqObj.quotation_id = env.recentQuery.quotation_id;
		reqObj.quotation_type = env.recentQuery.quotation_type;
	}

	c4s.invokeApi_ex( {
		location: "mail.sendMailReserve",
		body: reqObj,
		onSuccess: function (data) {
			env.flgTransfering = false;
			alert("送信日時を設定しました。");
			$("#view_body_modal").modal("hide");
			$("#sendMail_btn")[0].disabled = false;
			if(!env.DEBUG_MODE) {
				window.close();
			}
		},
		onError: function (data) {
			alert("送信日時を設定に失敗しました。");
			$("#sendMail_btn")[0].disabled = false;
			console ? console.log([reqObj, data]) : void(0);
		},
	});

}

function addAddr(target) {
	var li;
	var tmp, idx;
	var name = $("#input_add_addr_name").val() || "";
	var mail = $("#input_add_addr_mail").val() || "";
	var validLog = c4s.validate({
			mail: mail,
		}, c4s.validateRules.mailAddr, {
			"mail": "input_add_addr_mail",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
		return false;
	}
	if (mail) {
		if (target === "cc") {
			tmp = $("#recipient_list_cc li:not('.pull-right'):last");
			idx = tmp.length > 0 ? Number(tmp[0].id.replace("recipient_cc_", "")) : -1;
			idx += 1;
			li = $("<li class='btn btn-sm btn-default' id='recipient_cc_" + idx + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"cc\", \"recipient_cc_" + idx + "\");'>" + name + "&nbsp;<span class='mono'>&lt;" + mail + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'></span></li>");
			li.data("name", name);
			li.data("mail", mail);
			$("#recipient_list_cc").append(li);
		} else if (target === "bcc") {
			tmp = $("#recipient_list_bcc li:not('.pull-right'):last");
			idx = tmp.length > 0 ? Number(tmp[0].id.replace("recipient_bcc_", "")) : -1;
			idx += 1;
			li = $("<li class='btn btn-sm btn-default' id='recipient_bcc_" + idx + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"bcc\", \"recipient_bcc_" + idx + "\");'>" + name + "&nbsp;<span class='mono'>&lt;" + mail + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'></span></li>");
			li.data("name", name);
			li.data("mail", mail);
			$("#recipient_list_bcc").append(li);
		}
	} else {
		alert("メールアドレスは必須入力です。");
		return;
	}
	$("#edit_address_modal").modal("hide");
	$("#input_add_addr_name").val(null);
	$("#input_add_addr_mail").val(null);
}

function deleteAttachment(tpl_id, loop_idx) {
	var fileInputEl = $("#attachment_file_" + tpl_id + "_" + loop_idx);
	var fileIdEl = $("#attachment_id_" + tpl_id + "_" + loop_idx);
	var labelEl = $("#attachment_label_" + tpl_id + "_" + loop_idx);
	var commitBtnEl = $("#attachment_btn_commit_" + tpl_id + "_" + loop_idx);
	var deleteBtnEl = $("#attachment_btn_delete_" + tpl_id + "_" + loop_idx);
	fileInputEl.val(null);
	fileInputEl.css("display", "inline");
	fileIdEl.val(null);
	labelEl.html("");
	labelEl.css("display", "none");
	commitBtnEl.css("display", "none");
	deleteBtnEl.css("display", "none");
}

function uploadFile(tpl_id, loop_idx) {
	var fileInputEl = $("#attachment_file_" + tpl_id + "_" + loop_idx);
	var fileIdEl = $("#attachment_id_" + tpl_id + "_" + loop_idx);
	var labelEl = $("#attachment_label_" + tpl_id + "_" + loop_idx);
	var commitBtnEl = $("#attachment_btn_commit_" + tpl_id + "_" + loop_idx);
	var deleteBtnEl = $("#attachment_btn_delete_" + tpl_id + "_" + loop_idx);
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
function hdlClickConfirmRecipientExpandBtn(recipient_type) {
	recipient_type = recipient_type || "to";
	var taEl = $("#confirm_recipient_" + recipient_type);
	var btnEl = $("#confirm_recipient_" + recipient_type + "_expand_btn");
	if(btnEl.data("isExpanded")) {
		taEl.css("height", "2.2em");
		taEl.css("overflow-y", "hidden");
		btnEl.removeClass("glyphicon-minus");
		btnEl.addClass("glyphicon-plus");
		btnEl.data("isExpanded", false);
	} else {
		taEl.css("height", "5.5em");
		taEl.css("overflow-y", "auto");
		btnEl.removeClass("glyphicon-plus");
		btnEl.addClass("glyphicon-minus");
		btnEl.data("isExpanded", true);
	}
}
function confirmBody (option) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	if ($('#recipient_list_to li.mail_recipient_client').length <= 0) {
		$('#recipient_list_to').parent().addClass('has-error');
		alert('宛先を入力してください。');
		$("html, body").animate({ scrollTop: 0 }, "slow");
		return ;
	}
	//[end] Limitation of Mailing capacity per month.
	env.confirmedMailRequest = option;
	//[begin] Overwrite fields. //
	var toEl = $("#confirm_recipient_to");
	var replyToEl = $("#confirm_reply_to_addr");
	var ccEl = $("#confirm_recipient_cc");
	var bccEl = $("#confirm_recipient_bcc");
	var subjectEl = $("#confirm_subject");
	var bodyEl = $("#confirm_body");
	var reserveSubject = $("#reserve_subject");
	var reserveBody = $("#reserve_body");
	var reservedMailCount = $("#reserve_count");
	var attachmentEl = $("#confirm_attachments");
	var i;
	//[begin] recipient_to.
	toEl.html("");
	var to_src;
	var to_arr = [];
	var first_client_id;// forWorker.
	var first_engineer_id;// forEngineer.
	if (env.recentQuery.type_recipient === "forMember") {// forMember.
		to_src = $("#recipient_list_to").data("members");
		if (to_src) {
			for(i in to_src) {
				if (to_src[i]) {
					to_arr.push(to_src[i].name + "&nbsp;&lt;" + to_src[i].mail1 + "&gt;");
				}
			}
			toEl.html(to_arr.join(", "));
		}
	} else if (env.recentQuery.type_recipient === "forWorker" || env.recentQuery.type_recipient === "forMatching") {// forWorker.
		var tmp_workers = [];
		var tmp_users = [];
		$("#recipient_list_to ul").each(function (idx, el) {
			$(el).data("workers").map(function (val) {
				tmp_workers.push(val);
				tmp_users.push(val);
			});
		});
		first_client_id = tmp_workers.length > 0 ? tmp_workers[0].client_id : null;
		first_company_id = tmp_users.length > 0 ? tmp_users[0].company_id : null;
		if(first_client_id != undefined){
			to_src = tmp_workers.filter(function (val) {
			return val.client_id == first_client_id;
			});
			to_src.sort(function (x, y) {
				return x.recipient_priority - y.recipient_priority;
			});
			if (to_src) {
				for(i = 0; i < to_src.length; i++) {
					to_arr.push(to_src[i].name + "&nbsp;&lt;" + to_src[i].mail1 + "&gt;");
				}
				toEl.html(to_arr.join(", "));
			}
			if(first_client_id == 0){
				to_src = to_src.map(function(element, index, array) {
				element.name = element.name;
				element.client_name = "";
				element.recipient_priority = 0;
				element.client_id = 0;
				element.mail1 = element.mail1;
				return element;
			});
			}
		}else if(first_company_id != undefined){
			first_company_id = tmp_users.length > 0 ? tmp_users[0].company_id : null;
			to_src = tmp_users.filter(function (val) {
				return val.company_id == first_company_id;
			});
			to_src.sort(function (x, y) {
				return x.recipient_priority - y.recipient_priority;
			});
			to_src = to_src.map(function(element, index, array) {
				element.name = element.user_name;
				element.client_name = element.company_name;
				element.recipient_priority = 0;
				element.client_id = element.company_id;
				element.mail1 = element.user_mail1;
				return element;
			});
			if (to_src) {
				for(i = 0; i < to_src.length; i++) {
					to_arr.push(to_src[i].user_name + "&nbsp;&lt;" + to_src[i].user_mail1 + "&gt;");
				}
				toEl.html(to_arr.join(", "));
			}
		}
	} else if (env.recentQuery.type_recipient === "forEngineer") {// forEngineer.
		to_src = $("#recipient_list_to").data("engineers");
		if (to_src) {
			for (i in to_src) {
				if (to_src[i]) {
					first_engineer_id = i;
					toEl.html(to_src[i].name + "&nbsp;&lt;" + to_src[i].mail1 + "&gt;");
					break;
				}
			}
		}
	}
	//[end] recipient_to.
	//[begin] reply_to_addr.
	replyToEl.html($("#reply_to_addr option:selected").text());
	//[end] reply_to_addr.
	//[begin] recipient_cc.
	ccEl.html("");
	var cc_arr = [];
	/*
	for(i = 0; i < env.limit.MAIL_RECEIVER_CC.length; i++) {
		cc_arr.push(env.limit.MAIL_RECEIVER_CC[i].name + "&nbsp;&lt;" + env.limit.MAIL_RECEIVER_CC[i].mail + "&gt;");
	}
	*/
	$("#recipient_list_cc li[id^=recipient_cc_]").each(function (idx, el) {
		cc_arr.push($(el).data().name + "&nbsp;&lt;" + $(el).data().mail + "&gt;");
	});
	ccEl.html(cc_arr.join(", "));
	//[end] recipient_cc.
	//[begin] recipient_bcc.
	bccEl.html("");
	var bcc_arr = [];
	/*
	for(i = 0; i < env.limit.MAIL_RECEIVER_BCC.length; i++) {
		bcc_arr.push(env.limit.MAIL_RECEIVER_BCC[i].name + "&nbsp;&lt;" + env.limit.MAIL_RECEIVER_BCC[i].mail + "&gt;");
	}
	*/
	$("#recipient_list_bcc li[id^=recipient_bcc_]").each(function (idx, el) {
		bcc_arr.push($(el).data().name + "&nbsp;&lt;" + $(el).data().mail + "&gt;");
	});
	bccEl.html(bcc_arr.join(", "));
	//[end] recipient_bcc.
	// subject.
	subjectEl.html(option.subject);
	reserveSubject.val(option.subject);
	// body.
	if (env.recentQuery.type_recipient === "forWorker" || env.recentQuery.type_recipient === "forMatching") {
		c4s.invokeApi_ex({
			location: "mail.simulateMailPerClient",
			body: {
				type_title: option.type_title,
				tpl_id: option.template_id,
				subject: option.subject,
				body: $(option.body_id).val(),
				addr_to_list: to_src,
				addr_cc: cc_arr,
				bcc_list: bcc_arr,
			},
			onSuccess: function (res) {
				bodyEl.val(res.data.body);
				reserveBody.val(res.data.body);
			},
		});
	} else if (env.recentQuery.type_recipient === "forEngineer") {
		c4s.invokeApi_ex({
			location: "mail.simulateMailPerClient",
			body: {
				type_title: option.type_title,
				tpl_id: option.template_id,
				subject: option.subject,
				body: $(option.body_id).val(),
				addr_to_list: [to_src[first_engineer_id]],
				addr_cc: cc_arr,
				bcc_list: bcc_arr,
			},
			onSuccess: function (res) {
				bodyEl.val(res.data.body);
				reserveBody.val(res.data.body);
			},
		});
	} else {//forMember.
		bodyEl.val($(option.body_id).val());
		reserveBody.val($(option.body_id).val());
	}
	// attachments.
	attachmentEl.html("");
	if (option.attachment_id && option.attachment_id.length > 0) {
		var atmt_label, liEl;
		var tpl_id = option.attachment_id[0].replace("#attachment_id_", "").split("_")[0];
		for(i = 0; i < option.attachment_id.length; i++) {
			liEl = $("<li class='list-group-item'></li>");
			atmt_label = $("#attachment_label_" + tpl_id + "_" + i);
			if (atmt_label.html()) {
				liEl.html(atmt_label.html());
				attachmentEl.append(liEl);
			}
		}
		attachmentEl.css("display", "block");
	} else {
		attachmentEl.css("display", "none");
	}
	//[end] Overwrite fields. //
	// reserved mails count
	c4s.invokeApi_ex({
		location: "mail.getReservedMailsCount",
		body: {
		},
		onSuccess: function (res) {
			reservedMailCount.html(res.data.body);
		}
	});
	$("#view_body_modal").modal("show");
}

function confirmReserve (option) {
	//[end] Overwrite fields. //
	$("#view_body_modal").modal("hide");
	$("#set_reserve_modal").modal("show");
}

function goBack() {
	$("#set_reserve_modal").modal("hide");
	$("#view_body_modal").modal("show");
}

function enumReserve() {
	$("#view_body_modal").modal("hide");
	$("#enum_reserve_modal").modal("show");

	c4s.invokeApi_ex({
		location: "mail.enumReserve",
		body: {},
		onSuccess: function (res) {
			env.data = env.data || {};
			if (res.data && res.data.length > 0) {
				env.data.mails = res.data;
			} else {
				env.data.mails = [];
			}

			var tbody, tr, td;
			var source, tmp;
			var i;

			tbody = $("#tablebody_forReservedMails");
			tbody.html("");
			source = env.data.mails;
			for (i = 0; i < source.length; i++) {
				tmp = source[i];
				tr = $("<tr id='reservedMails_iter_mail_" + tmp.id + "'></tr>");
				td = $("<td>" + tmp.send_time + "</td>");
				tr.append(td);
				td = $("<td><a onclick='editReserve(" + tmp.id + ");' style='cursor: pointer;'>" + tmp.subject + "</a></td>");
				tr.append(td);
				td = $("<td style='text-align: center;'><a onclick='deleteReserve(" + tmp.id + ");' style='cursor: pointer;'><span class='glyphicon glyphicon-trash text-danger'></span></a></td>");
				tr.append(td);
				tbody.append(tr);
            }
		},
	});
}

function editReserve(id) {
	var editReserveId = $("#edit_reserve_id");
	var editMailId = $("#edit_mail_id");
	var editReserveDateSaved = $("#edit_reserve_date_saved");
	var editReserveSubjectSaved = $("#edit_reserve_subject_saved");
	var editReserveBodySaved = $("#edit_reserve_body_saved");
	var editReserveDate = $("#edit_reserve_date");
	var editReserveSubject = $("#edit_reserve_subject");
	var editReserveBody = $("#edit_reserve_body");
	var reqObj = {};
	reqObj.id = id;
	c4s.invokeApi_ex({
		location: "mail.getReserveInfo",
		body: reqObj,
		onSuccess: function (res) {
			if (res.data != null && res.data.length > 0) {
				var info = res.data[0];
				editReserveId.val(info.id);
				editMailId.val(info.mail_req_id);
				editReserveDateSaved.val(info.send_time);
				editReserveSubjectSaved.val(info.subject);
				editReserveBodySaved.val(info.body);
				editReserveDate.val(info.send_time);
				editReserveSubject.val(info.subject);
				editReserveBody.val(info.body);
            }

			$("#edit_reserve_modal").modal("show");
			$("#enum_reserve_modal").modal("hide");
		},
		onError: function (data) {
			alert("メール情報取得に失敗しました。");
			console ? console.log([reqObj, data]) : void (0);
        },
	});
}

function closeEnumReserve() {
	// reserved mails count
	var reservedMailCount = $("#reserve_count");
	c4s.invokeApi_ex({
		location: "mail.getReservedMailsCount",
		body: {
		},
		onSuccess: function (res) {
			reservedMailCount.html(res.data.body);
		}
	});

	$("#enum_reserve_modal").modal("hide");
	$("#view_body_modal").modal("show");
}

function saveEditReserve() {
	var reserveId = $("#edit_reserve_id");
	var mailId = $("#edit_mail_id");
	var reserveDateSaved = $("#edit_reserve_date_saved");
	var reserveSubjectSaved = $("#edit_reserve_subject_saved");
	var reserveBodySaved = $("#edit_reserve_body_saved");
	var editReserveDate = $("#edit_reserve_date");
	var editReserveSubject = $("#edit_reserve_subject");
	var editReserveBody = $("#edit_reserve_body");

	var reqObj = {};
	if (reserveDateSaved.val().trim() != editReserveDate.val().trim())
		reqObj.send_time = editReserveDate.val().replace("T", " ");
	if (reserveSubjectSaved.val().trim() != editReserveSubject.val().trim())
		reqObj.subject = editReserveSubject.val().trim();
	if (reserveBodySaved.val().trim() != editReserveBody.val().trim())
		reqObj.body = editReserveBody.val().trim();

	var reserveModal = document.getElementById("enum_reserve_modal");
	//var isCreateMailPage = ($("#enum_reserve_modal") > 0);
	var isCreateMailPage = (reserveModal != null);
	if (reqObj != {}) {
		reqObj.id = reserveId.val();
		reqObj.mail_req_id = mailId.val();

		c4s.invokeApi_ex({
			location: "mail.updateReserve",
			body: reqObj,
			onSuccess: function (res) {
				if (res.data && res.data == 'true') {
					if (reqObj.send_time != null)
						reserveDateSaved.val(editReserveDate.val());
					if (reqObj.subject != null)
						reserveSubjectSaved.val(reqObj.subject);
					if (reqObj.body != null)
						reserveBodySaved.val(reqObj.body);

					alert("メール予約情報が更新されました。");

					if (isCreateMailPage) {
						$("#edit_reserve_modal").modal("hide");
						enumReserve();
					} else {
						location.reload();
                    }
					
				}
				else {
					alert("メール予約情報の更新が失敗しました。");
					console.log("saveEditReserve: res: " + JSON.stringify(res));
				}
			},
			onError: function (res) {
				alert("メール予約情報の更新が失敗しました。");
				console.log("saveEditReserve: Error: " + JSON.stringify(res));
			}
		});
	} else { // if nothing changed, close only
		if (isCreateMailPage) {
			$("#edit_reserve_modal").modal("hide");
			enumReserve();
		} else {
			location.reload();
        }		
    }
}

function closeEditReserve() {
	$("#edit_reserve_modal").modal("hide");
	enumReserve();
}

function deleteReserve(id) {
	c4s.invokeApi_ex({
		location: "mail.deleteReserve",
		body: { id: id },
		onSuccess: function (res) {
			if (res.data && res.data == 'true') {
				alert("メール予約を削除しました。");

				var reserveModal = document.getElementById("enum_reserve_modal");
				if (reserveModal != null) // create mail page
					enumReserve();
				else
					location.reload();
			}
			else {
				alert("メール予約の削除が失敗しました。");
				console.log("deleteReserve: res: " + JSON.stringify(res));
			}
		},
		onError: function (res) {
			alert("メール予約の削除が失敗しました。");
			console.log("deleteReserve: onError: " + JSON.stringify(res));
		}
    })
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
	$(form).css("position", "fixed");
	$(form).css("top", "0px");
	$(form).css("left", "0ox");
	$(form).css("width", "1px");
	$(form).css("height", "1px");
	document.body.appendChild(form);
	form.submit();
	*/
	window.console.log("[Deplicated] OLD download() on mail.js is used.");
	c4s.download(id);
}

function jumpToClientPage(clientId) {
	c4s.invokeApi_ex({
		location: "client.clientTop",
		body: {id: Number(clientId)},
		pageMove: true,
	});
}
function jumpToWorkerPage(workerId) {
	c4s.invokeApi_ex({
		location: "client.workerTop",
		body: {id: Number(workerId)},
		pageMove: true,
	});
}

/* [end] UI functions for editing mail. */
/* [begin] UI functions for modal selecting recipients. */
function openRecipientsModalOnMail(type) {
	if (type === "worker") {
		$("#search_recipient_modal_title").html("宛先追加：取引先担当者");
		$("#modal_search_container_worker").css("display", "block");
		$("#modal_search_container_engineer").css("display", "none");
		if (!env.data || !env.data.workers || env.data.workers.length == 0) {
			c4s.invokeApi_ex({
				location: "client.enumWorkers",
				body: {},
				onSuccess: function (res) {
					if (res.data && res.data.length > 0) {
						env.data = env.data || {};
						env.data.workers = res.data;
					}
					renderRecipientModalTable(type, filterRecipientDatum(type));
				},
			});
		} else {
			renderRecipientModalTable(type, filterRecipientDatum(type));
		}
	} else if (type === "engineer") {
		$("#search_recipient_modal_title").html("宛先追加：技術者");
		$("#modal_search_container_worker").css("display", "none");
		$("#modal_search_container_engineer").css("display", "block");
		if (!env.data || !env.data.engineers || env.data.engineers.length == 0) {
			c4s.invokeApi_ex({
				location: "engineer.enumEngineers",
				body: {},
				onSuccess: function (res) {
					if (res.data && res.data.length > 0) {
						env.data = env.data || {};
						env.data.engineers = res.data;
					}
					renderRecipientModalTable(type, filterRecipientDatum(type));
				},
			});
		} else {
			renderRecipientModalTable(type, filterRecipientDatum(type));
		}
	}
	activateRecipientModalTable(type);
	$("#search_recipient_modal").modal("show");
}

function openRecipientsModalOnReminder(type) {
	if (type === "member") {
		$("#search_recipient_modal_title").html("宛先追加：メンバー");
		$("#modal_search_container_worker").css("display", "none");
		$("#modal_search_container_engineer").css("display", "none");
		$("#modal_search_container_member").css("display", "block");
		if (!env.data || !env.data.members || env.data.members.length == 0) {
			c4s.invokeApi_ex({
				location: "manage.enumAccount",/* ここ、manage.enumAccountsだわ */
				body: {},
				onSuccess: function (res) {
					if (res.data && res.data.length > 0) {
						env.data = env.data || {};
						env.data.members = res.data;
					}
					renderRecipientModalTable(type, filterRecipientDatum(type));
				},
			});
		} else {
			renderRecipientModalTable(type, filterRecipientDatum(type));
		}
	}
	activateRecipientModalTable(type);
	$("#search_recipient_modal").modal("show");
}

function filterRecipientDatum(type) {
	var result = [];
	var source;
	var tmp_condition;
	if (type === "worker" && env.data && env.data.workers) {
		source = env.data.workers.filter(function (val) {
			return val.flg_sendmail && val.mail1;
		}) || [];
		tmp_condition = $("#modal_search_client_name").val();
		result = source.filter(function (val) {
			return (tmp_condition && val.client_name.indexOf(tmp_condition) > -1) || !tmp_condition;
		});
		tmp_condition = $("#modal_search_worker_name").val();
		result = result.filter(function (val) {
			return (tmp_condition && val.name.indexOf(tmp_condition) > -1) || !tmp_condition;
		});
		tmp_condition = $("#modal_search_charging_worker").val();
		result = result.filter(function (val) {
			//return (tmp_condition && val.charging_user.id == Number(tmp_condition)) || !tmp_condition;
			return (tmp_condition && (val.client_charging_user_id_1 == Number(tmp_condition) || val.client_charging_user_id_2 == Number(tmp_condition))) || !tmp_condition;
		});
		tmp_condition = $("#modal_search_type_dealing").val();
		result = result.filter(function (val) {
			return (tmp_condition && val.client_type_dealing === tmp_condition) || !tmp_condition;
		});
		tmp_condition = $("#modal_search_type_presentation").val();
		tmp_condition = tmp_condition ? tmp_condition.split("・") : [];
		result = result.filter(function (val) {
			var val_tp = (val.client_type_presentation || "").split(",");
			switch (tmp_condition.length) {
				case 0:
					return true;
					break;
				case 1:
					return val_tp.indexOf(tmp_condition[0]) > -1;
					break;
				default:
					return val_tp.filter(function (cval) {
						return tmp_condition.indexOf(cval) > -1;
					}).length == tmp_condition.length;
					break;
			}
		});
		tmp_condition = $("#modal_search_worker_note").val();
		result = result.filter(function (val) {
			//return (tmp_condition && val.note && val.note.indexOf(tmp_condition) > -1) || !tmp_condition;
			return (tmp_condition && val.client_note && val.client_note.indexOf(tmp_condition) > -1) || !tmp_condition;
		});
	} else if (type === "engineer" && env.data && env.data.engineers) {
		source = env.data.engineers.filter(function (val) {
			return val.mail1;
		}) || [];
		tmp_condition = $("#modal_search_engineer_name").val();
		result = source.filter(function (val) {
			return (tmp_condition && val.name.indexOf(tmp_condition) > -1) || !tmp_condition;
		});
		tmp_condition = $("#modal_search_skill").val();
		result = result.filter(function (val) {
			return (tmp_condition && val.skill.indexOf(tmp_condition) > -1) || !tmp_condition;
		});
		tmp_condition = $("#modal_search_contract").val();
		result = result.filter(function (val) {
			return (tmp_condition && val.contract === tmp_condition) || !tmp_condition;
		});
		tmp_condition = $("#modal_search_engineer_note").val();
		result = result.filter(function (val) {
			return (tmp_condition && val.note && val.note.indexOf(tmp_condition) > -1) || !tmp_condition;
		});
	} else if (type === "member") {
		result = env.data.members.filter(function (val) {
			return !val.is_locked && val.is_enabled && val.mail1;
		});
	}
	return result;
}

function renderRecipientTable(type, datum) {
	var tbody;
	var tmp_tr;
	if (type === "worker") {
		$("#worker_row_count").html(datum.length+"件");
		tbody = $("#search_result_worker tbody");
		tbody.html("");
		if (datum && datum instanceof Array && datum.length > 0) {
			var charging_user;
			datum.map(function (val, idx) {
				if (idx && idx % env.enumSeparationLimit == 0 && (datum.length - idx) > env.enumSeparationLimit / 2) {
					tbody.append($("<tr><td colspan='5' class='" + (env.UA.indexOf("iPhone") > -1 || env.UA.indexOf("Android") > 1 ? "center" : "right") + "'><button class='btn-sm btn-primary' style='margin: 0.2em 0.5em;' onclick='triggerCreateMailOnMail();'><span class=''>メール作成</span></button></td></tr>"));
				}
				tmp_tr = $("<tr></tr>");
				if (val.flg_sendmail && (val.mail1 || val.mail2)) {
					tmp_tr.append($("<td class='center'><input type='checkbox' id='recipient_iter_worker_" + val.id + "'/></td>"));
				} else {
					tmp_tr.append($("<td></td>"));
				}
				if (env.UA.indexOf("iPhone") > -1 || env.UA.indexOf("Android") > -1) {
					tmp_tr.append($("<td style=\"width: " + $("#sp_width_standard").width * 0.6 + "px;\">&nbsp;" + (val.client_name.length > 12 ? val.client_name.substr(0, 12) + "..." : val.client_name) + "</td>"));
				} else {
					tmp_tr.append($("<td>&nbsp;" + val.client_name + "</td>"));
				}
				tmp_tr.append($("<td>&nbsp;" + val.name + "</td>"));
				tmp_tr.append($("<td>&nbsp;" + (val.mail1 || val.mail2) + "</td>"));
				//tmp_tr.append($("<td class='center'>" + (val.charging_user && val.charging_user.user_name || "") + "</td>"));
				var charging_user = env.data.accounts.filter(function (cval, cidx) {
					return cval.id == (val.client_charging_user_id_1 || val.client_charging_user_id_2 || null);
				});
				charging_user = charging_user.length ? charging_user[0] : {};
				tmp_tr.append($("<td class='center'>" + (charging_user.name || "") + "</td>"));
				tbody.append(tmp_tr);
			});
		} else {
			tmp_tr = $("<tr></tr>");
			tmp_tr.append($("<td class='center' colspan='5'>（有効なデータがありません）</td>"));
			tbody.append(tmp_tr);
		}
		$("#search_container_workers").css("display", "block");
		$("#search_container_engineers").css("display", "none");
	} else if (type === "engineer") {
		$("#engineer_row_count").html(datum.length+"件");
		tbody = $("#search_result_engineer tbody");
		tbody.html("");
		if (datum && datum instanceof Array && datum.length > 0) {
			datum.map(function (val, idx) {
				if (idx && idx % env.enumSeparationLimit == 0 && (datum.length - idx) > env.enumSeparationLimit / 2) {
					tbody.append($("<tr><td colspan='6' class='" + (env.UA.indexOf("iPhone") > -1 || env.UA.indexOf("Android") > 1 ? "center" : "right") + "'><button class='btn-sm btn-primary' style='margin: 0.2em 0.5em;' onclick='triggerCreateMailOnMail();'><span class=''>メール作成</span></button></td></tr>"));
				}
				tmp_tr = $("<tr></tr>");
				if (val.mail1 || val.mail2) {
					tmp_tr.append($("<td class='center'><input type='checkbox' id='recipient_iter_engineer_" + val.id + "'/></td>"));
				} else {
					tmp_tr.append($("<td></td>"));
				}
				tmp_tr.append($("<td>" + val.name + "</td>"));
				tmp_tr.append($("<td>" + val.fee + "</td>"));
				tmp_tr.append($("<td>" + val.skill + "</td>"));
				tmp_tr.append($("<td>" + val.state_work + (val.state_work ? "<br/>" : "") +
					((val.flg_assignable || val.flg_caution) ?
						"（" +
						[(val.flg_assignable ? "アサイン可能" : null), (val.flg_caution ? "要注意" : null)].filter(function (val) {
							return Boolean(val);
					}).join(", ") + "）" : "") +
				"</td>"));
				tmp_tr.append($("<td>" + (val.mail1 || val.mail2) + "</td>"));
				tbody.append(tmp_tr);
			});
		$("#search_container_workers").css("display", "none");
		$("#search_container_engineers").css("display", "block");
		} else {
			tmp_tr = $("<tr></tr>");
			tmp_tr.append($("<td class='center' colspan='6'>（有効なデータがありません）</td>"));
			tbody.append(tmp_tr);
		}
	}
}

function renderRecipientModalTable(type, datum) {
	var tbody;
	var tmp_tr;
	$("#row_count").html(datum.length+"件");
	if (type === "worker") {
		tbody = $("#modal_search_result_worker tbody");
		tbody.html("");
		if (datum && datum instanceof Array && datum.length > 0) {
			datum.map(function (val, idx) {
				if (idx && idx % env.enumSeparationLimit == 0 && (datum.length - idx) > env.enumSeparationLimit / 2) {
					tbody.append($("<tr><td colspan='5' class='right'><button type='button' class='btn-sm btn-primary' style='margin 0.2em 0.5em;' onclick=\"hdlClickAddRecipientBtnOnEdit($('#modal_search_container_worker').css('display') === 'block' ? 'worker' : 'engineer');\">まとめて追加</button></td></tr>"));
				}
				tmp_tr = $("<tr></tr>");
				if (val.flg_sendmail && (val.mail1 || val.mail2)) {
					tmp_tr.append($("<td class='center'><input type='checkbox' id='recipient_iter_worker_" + val.id + "'/></td>"));
				} else {
					tmp_tr.append($("<td></td>"));
				}
				tmp_tr.append($("<td>" + val.client_name + "</td>"));
				tmp_tr.append($("<td><label for='recipient_iter_worker_" + val.id + "'>" + val.name + "</label></td>"));
				tmp_tr.append($("<td class='mono'>&nbsp;" + (val.mail1 || val.mail2) + "</td>"));
				//tmp_tr.append($("<td>" + (val.charging_user && val.charging_user.user_name || "") + "</td>"));
				var charging_user = env.data.accounts.filter(function (cval, cidx) {
					return cval.id == (val.client_charging_user_id_1 || val.client_charging_user_id_2 || null);
				});
				charging_user = charging_user.length ? charging_user[0] : {};
				tmp_tr.append($("<td class='center'>" + (charging_user.name || "") + "</td>"));
				tbody.append(tmp_tr);
			});
		} else {
			tmp_tr = $("<tr></tr>");
			tmp_tr.append($("<td class='center' colspan='5'>（有効なデータがありません）</td>"));
			tbody.append(tmp_tr);
		}
	} else if (type === "engineer") {
		tbody = $("#modal_search_result_engineer tbody");
		tbody.html("");
		if (datum && datum instanceof Array && datum.length > 0) {
			datum.map(function (val, idx) {
				if (idx && idx % env.enumSeparationLimit == 0 && (datum.length - idx) > env.enumSeparationLimit / 2) {
					tbody.append($("<tr><td colspan='6' class='right'><button type='button' class='btn-sm btn-primary' style='margin 0.2em 0.5em;' onclick=\"hdlClickAddRecipientBtnOnEdit($('#modal_search_container_worker').css('display') === 'block' ? 'worker' : 'engineer');\">まとめて追加</button></td></tr>"));
				}
				tmp_tr = $("<tr></tr>");
				if (val.mail1 || val.mail2) {
					tmp_tr.append($("<td class='center'><input type='checkbox' id='recipient_iter_engineer_" + val.id + "'/></td>"));
				} else {
					tmp_tr.append($("<td></td>"));
				}
				tmp_tr.append($("<td><label for='recipient_iter_engineer_" + val.id + "'>" + val.name + "</label></td>"));
				tmp_tr.append($("<td>" + val.fee + "</td>"));
				tmp_tr.append($("<td>" + val.skill + "</td>"));
				tmp_tr.append($("<td>" + val.state_work + (val.state_work ? "<br/>" : "") +
					((val.flg_assignable || val.flg_caution) ?
						"（" +
						[(val.flg_assignable ? "アサイン可能" : null), (val.flg_caution ? "要注意" : null)].filter(function (val) {
							return Boolean(val);
					}).join(", ") + "）" : "") +
				"</td>"));
				tmp_tr.append($("<td>" + (val.mail1 || val.mail2) + "</td>"));
				tbody.append(tmp_tr);
			});
		} else {
			tmp_tr = $("<tr></tr>");
			tmp_tr.append($("<td class='center' colspan='6'>（有効なデータがありません）</td>"));
			tbody.append(tmp_tr);
		}
	} else if (type === "member") {
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
		$("#search_container_workers").css("display", "none");
		$("#search_container_engineers").css("display", "none");
		} else {
			tmp_tr = $("<tr></tr>");
			tmp_tr.append($("<td class='center' colspan='4'>（有効なデータがありません）</td>"));
			tbody.append(tmp_tr);
		}
	}
}
function hdlClickAddRecipientBtnOnMail(type) {
	var tmp_data = $("#recipient_list").data() || {};
	tmp_data.workers = tmp_data.workers || {};
	tmp_data.engineers = tmp_data.engineers || {};
	if (type === "worker") {
		$("input[id^=recipient_iter_worker_]").each(function (idx, el, arr) {
			if (el.checked) {
				tmp_data.workers[el.id.replace("recipient_iter_worker_", "")] = env.data.workers.filter(function (val) {
					return val.id == Number(el.id.replace("recipient_iter_worker_", ""));
				})[0];
			}
		});
	} else if (type === "engineer") {
		$("input[id^=recipient_iter_engineer_]").each(function (idx, el, arr) {
			if (el.checked) {
				tmp_data.engineers[el.id.replace("recipient_iter_engineer_", "")] = env.data.engineers.filter(function (val) {
					return val.id == Number(el.id.replace("recipient_iter_engineer_", ""));
				})[0];
			}
		});
	}
	$.data($("#recipient_list"), "workers", tmp_data.workers);
	$.data($("#recipient_list"), "engineers", tmp_data.engineers);
	$("#recipient_list li").remove();
	var i;
	var li;
	//[begin] worker.
	renderRecipientWorker(tmp_data.workers);
	//[end] worker.
	//[begin] engineer.
	for(i in tmp_data.engineers) {
		if (tmp_data.engineers[i]) {
			li = $("<li class='btn btn-sm btn-default mail_recipient_client' id='recipient_engineer_" + tmp_data.engineers[i].id + "' onclick='hdlClickDeleteRecipientBtnOnMail(\"engineer\", " + tmp_data.engineers[i].id + ");'>" + tmp_data.engineers[i].name + "&nbsp;<span class='mono'>&lt;" + (tmp_data.engineers[i].mail1 || tmp_data.engineers[i].mail2) + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'</span></li>");
			$("#recipient_list").append(li);
		}
	}
	//[end] engineer.
	$("#search_recipient_modal").modal("hide");
}
function renderRecipientWorker(workers) {
	$("#recipient_list_to li:gt(0)").remove();
	var i, j, currW, currC;
	var clientDict = {};
	for(i in workers) {
		currW = workers[i];
		if (!clientDict[currW.client_id]) {
			clientDict[currW.client_id] = {
				id: currW.client_id,
				name: currW.client_name,
				typePresentation: currW.client_type_presentation,
				workers: []};
		}
		currC = clientDict[currW.client_id];
		currC.workers.push(currW);
	}
	var liC, ulC, liW;
	for(i in clientDict) {
		currC = clientDict[i];
		var btnClass;
		switch (currC.typePresentation) {
			case "案件":
				btnClass = "btn-job";
				break;
			case "人材":
				btnClass = "btn-worker";
				break;
			case "案件,人材":
				btnClass = "btn-job_and_worker";
				break;
			default:
				btnClass = "btn-warning";
		}
		liC = $("<li class='btn mail_recipient_client "+ btnClass + "' id='recipient_client_" + currC.id + "' style='cursor: default;'><span class='glyphicon glyphicon-home'></span>&nbsp;<span class='bold'>" + currC.name + "</span>&nbsp;</li>");
		ulC = $("<ul style='padding: 0; display: inline; float: none; display: none;'></ul>");
		ulC.data("id", currC.id);
		ulC.data("workers", currC.workers);
		ulC.data("isOpened", false);
		liC.append(ulC);
		for(j = 0; j < currC.workers.length; j++) {
			currW = currC.workers[j];
			liW = $("<li class='btn btn-sm btn-default' style='float: none;' id='recipient_worker_" + currW.id + "' title='クリックすると送信先から除去します' onclick='hdlClickWorkerInRecipientArea(" + currC.id + ", " + currW.id + ");'><span class='glyphicon glyphicon-user'></span>&nbsp;" + currW.name + "&nbsp;<span class='mono'>&lt;" + (currW.mail1 || currW.mail2) + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'</span></li>");
			ulC.append(liW);
		}
		liC.append($("<span class='badge pseudo-link-cursor' id='recipient_client_badge_" + currC.id + "' title='取引先担当者を開く' onclick='hdlClickClientOpenBtnInRecipientArea(" + currC.id + ");'><span class='glyphicon glyphicon-chevron-down'></span>&nbsp;" + currC.workers.length + "</span>"));
		$("#recipient_list_to").append(liC);
	}
}
function renderRecipientUser(users) {
	// $("#recipient_list_to li:gt(0)").remove();
	var i, j, currW, currC;
	var companyDict = {};
	for(i in users) {
		currW = users[i];
		if (!companyDict[currW.company_id]) {
			companyDict[currW.company_id] = {
				id: currW.company_id,
				name: currW.company_name,
				users: []};
		}
		currC = companyDict[currW.company_id];
		currC.users.push(currW);
	}
	var liC, ulC, liW;
	for(i in companyDict) {
		currC = companyDict[i];
		var btnClass;
		btnClass = "btn-bp_user";

		liC = $("<li class='btn mail_recipient_client "+ btnClass + "' id='recipient_client_" + currC.id + "' style='cursor: default;'><span class='glyphicon glyphicon-home'></span>&nbsp;<span class='bold'>" + currC.name + "</span>&nbsp;</li>");
		ulC = $("<ul style='padding: 0; display: inline; float: none; display: none;'></ul>");
		ulC.data("id", currC.id);
		ulC.data("workers", currC.users);
		ulC.data("isOpened", false);
		liC.append(ulC);
		for(j = 0; j < currC.users.length; j++) {
			currW = currC.users[j];
			liW = $("<li class='btn btn-sm btn-default' style='float: none;' id='recipient_worker_" + currW.user_id + "' title='クリックすると送信先から除去します' onclick='hdlClickWorkerInRecipientArea(" + currC.id + ", " + currW.user_id + ");'><span class='glyphicon glyphicon-user'></span>&nbsp;" + currW.user_name + "&nbsp;<span class='mono'>&lt;" + (currW.user_mail1 || currW.user_mail2) + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'</span></li>");
			ulC.append(liW);
		}
		liC.append($("<span class='badge pseudo-link-cursor' id='recipient_client_badge_" + currC.id + "' title='取引先担当者を開く' onclick='hdlClickClientOpenBtnInRecipientArea(" + currC.id + ");'><span class='glyphicon glyphicon-chevron-down'></span>&nbsp;" + currC.users.length + "</span>"));
		$("#recipient_list_to").append(liC);
	}
}
function renderRecipientEngineerUser() {
	// $("#recipient_list_to li:gt(0)").remove();

	env.recentQuery.engineer_user_id = env.recentQuery.engineer_user_id || 0;
	if(env.recentQuery.engineer_user_id == 0){
		return;
	}
	var target_engineer_id = env.recentQuery.engineer_user_id;

	var engineers =  env.data.engineers || [];
	if(engineers.length == 0){
		return;
	}

	engineers = engineers.filter(function (val) {
			return val.id == target_engineer_id && val.mail1;
		});
	if(engineers.length == 0){
		return;
	}

	var i, j, currW, currC;
	var companyDict = {};
	// for(i in engineers) {
		currW = engineers[0];
		if (!companyDict[currW.id]) {
			companyDict[currW.id] = {
				id: currW.id,
				name: currW.name,
				users: []};
		}
		currC = companyDict[currW.id];
		currC.users.push(currW);
	// }
	var liC, ulC, liW;
	for(i in companyDict) {
		currC = companyDict[i];
		var btnClass;
		btnClass = "btn-bp_user";

		liC = $("<li class='btn mail_recipient_client "+ btnClass + "' id='recipient_client_" + currC.id + "' style='cursor: default;'><span class='glyphicon glyphicon-home'></span>&nbsp;<span class='bold'>" + currC.name + "</span>&nbsp;</li>");
		ulC = $("<ul style='padding: 0; display: inline; float: none; display: none;'></ul>");
		ulC.data("id", currC.id);
		ulC.data("workers", currC.users);
		ulC.data("isOpened", false);
		liC.append(ulC);
		for(j = 0; j < currC.users.length; j++) {
			currW = currC.users[j];
			liW = $("<li class='btn btn-sm btn-default' style='float: none;' id='recipient_worker_" + currW.id + "' title='クリックすると送信先から除去します' onclick='hdlClickWorkerInRecipientArea(" + currC.id + ", " + currW.id + ");'><span class='glyphicon glyphicon-user'></span>&nbsp;" + currW.name + "&nbsp;<span class='mono'>&lt;" + (currW.mail1 || currW.mail2) + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'</span></li>");
			ulC.append(liW);
		}
		liC.append($("<span class='badge pseudo-link-cursor' id='recipient_client_badge_" + currC.id + "' title='取引先担当者を開く' onclick='hdlClickClientOpenBtnInRecipientArea(" + currC.id + ");'><span class='glyphicon glyphicon-chevron-down'></span>&nbsp;" + currC.users.length + "</span>"));
		$("#recipient_list_to").append(liC);
	}
}
function hdlClickClientOpenBtnInRecipientArea(clientId) {
	var target = $("#recipient_client_" + clientId + " ul");
	var targetId = target.data("id");
	var targetWorkers = target.data("workers");
	var isOpened = target.data("isOpened");
	if (!isOpened) {
		$("#recipient_list_to ul").each(function(idx, el) {
			$(el).css("display", "none");
			$(el).data("isOpened", false);
		});
		$("#recipient_client_badge_" + targetId).remove();
		target.parent().append($("<span class='badge pseudo-link-cursor' id='recipient_client_badge_" + targetId + "' title='閉じる' onclick='hdlClickClientCloseBtnInRecipientArea(" + targetId + ");'><span class='glyphicon glyphicon-chevron-up'></span></span>"));
		target.css("display", "inline");
	} else {
		//
		target.css("display", "none");
	}
	target.data("isOpened", !isOpened);
};
function hdlClickClientCloseBtnInRecipientArea(clientId) {
	var target = $("#recipient_client_" + clientId + " ul");
	var targetId = target.data("id");
	var targetWorkers = target.data("workers");
	var isOpened = target.data("isOpened");
	if (isOpened) {
		target.css("display", "none");
		$("#recipient_client_badge_" + targetId).remove();
		target.parent().append($("<span class='badge pseudo-link-cursor' id='recipient_client_badge_" + targetId + "' onclick='hdlClickClientOpenBtnInRecipientArea(" + targetId + ");'><span class='glyphicon glyphicon-chevron-down'></span>&nbsp;" + targetWorkers.length + "</span>"));
	}
	target.data("isOpened", !isOpened);
}
function hdlClickWorkerInRecipientArea(clientId, workerId) {
	var clientEl = $("#recipient_client_" + clientId);
	var workerEl = $("#recipient_worker_" + workerId);
	var workersOrg = $("ul", clientEl).data("workers");
	var workersNew = [];
	var i;
	//[begin] presentation layer.
	workerEl.fadeOut(env.TRANS_SPEED_DELETE, function () {
		workerEl.remove();
	});
	for(i = 0; i < workersOrg.length; i++) {
		workersOrg[i].user_id = workersOrg[i].user_id || workersOrg[i].id;
		if(workersOrg[i].id != workerId && workersOrg[i].user_id != workerId) {
			workersNew.push(workersOrg[i]);
		}
	}
	$("ul", clientEl).data("workers", workersNew);
	if (workersNew.length == 0) {
		clientEl.fadeOut(env.TRANS_SPEED_DELETE, function () {
			clientEl.remove();
		});
	}
	//[end] presentation layer.
	//[begin] data layer.
	var target = $("#recipient_list_to").data().workers;
	if (target[workerId]) {
		delete target[workerId];
	}
	//[end] data layer.
}

function hdlClickAddRecipientBtnOnEdit(type) {
	var tmp_data = $("#recipient_list_to").data() || {};
	tmp_data.workers = tmp_data.workers || {};
	tmp_data.engineers = tmp_data.engineers || {};
	tmp_data.members = tmp_data.members || {};
	if (type === "worker") {
		$("input[id^=recipient_iter_worker_]").each(function (idx, el, arr) {
			if (el.checked) {
				tmp_data.workers[el.id.replace("recipient_iter_worker_", "")] = env.data.workers.filter(function (val) {
					return val.id == Number(el.id.replace("recipient_iter_worker_", ""));
				})[0];
			}
		});
	} else if (type === "engineer") {
		$("input[id^=recipient_iter_engineer_]").each(function (idx, el, arr) {
			if (el.checked) {
				tmp_data.engineers[el.id.replace("recipient_iter_engineer_", "")] = env.data.engineers.filter(function (val) {
					return val.id == Number(el.id.replace("recipient_iter_engineer_", ""));
				})[0];
			}
		});
	} else if (type === "member") {
		$("input[id^=recipient_iter_member_]").each(function (idx, el, arr) {
			if (el.checked) {
				tmp_data.members[el.id.replace("recipient_iter_member_", "")] = env.data.members.filter(function (val) {
					return val.id == Number(el.id.replace("recipient_iter_member_", ""));
				})[0];
			}
		});
	}
	$.data($("#recipient_list_to"), "workers", tmp_data.workers);
	$.data($("#recipient_list_to"), "engineers", tmp_data.engineers);
	$.data($("#recipient_list_to"), "members", tmp_data.members);
	$("#recipient_list_to li:not('.pull-right')").remove();
	var i;
	var li;
	//[begin] worker.
	renderRecipientWorker(tmp_data.workers);
	//[end] worker.
	//[begin] engineer.
	for(i in tmp_data.engineers) {
		if (tmp_data.engineers[i]) {
			li = $("<li class='btn btn-sm btn-default mail_recipient_client' id='recipient_engineer_" + tmp_data.engineers[i].id + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"engineer\", " + tmp_data.engineers[i].id + ");'>" + tmp_data.engineers[i].name + "&nbsp;<span class='mono'>&lt;" + (tmp_data.engineers[i].mail1 || tmp_data.engineers[i].mail2) + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'</span></li>");
			$("#recipient_list_to").append(li);
		}
	}
	//[end] engineer.
	//[begin] member.
	for(i in tmp_data.members) {
		if (tmp_data.members[i]) {
			li = $("<li class='btn btn-sm btn-default mail_recipient_client' id='recipient_member_" + tmp_data.members[i].id + "' onclick='hdlClickDeleteRecipientBtnOnEdit(\"member\", " + tmp_data.members[i].id + ");'>" + tmp_data.members[i].name + "&nbsp;<span class='mono'>&lt;" + tmp_data.members[i].mail1 + "&gt;</span>&nbsp;<span class='glyphicon glyphicon-remove text-danger'</span></li>");
			$("#recipient_list_to").append(li);
		}
	}
	//[end] member.
	$("#search_recipient_modal").modal("hide");
}

function hdlClickDeleteRecipientBtnOnMail(type, objId) {
	var source;
	if (type === "worker") {
		source = $("#recipient_list").data("workers");
		source[objId] = null;
		$("#recipient_worker_" + objId).remove();
	} else if (type === "engineer") {
		source = $("#recipient_list").data("engineers");
		source[objId] = null;
		$("#recipient_engineer_" + objId).remove();
	}
}
function hdlClickDeleteRecipientBtnOnEdit(type, objId) {
	var source;
	if (type === "worker") {
		source = $("#recipient_list_to").data("workers");
		source[objId] = null;
		$("#recipient_worker_" + objId).remove();
	} else if (type === "engineer") {
		source = $("#recipient_list_to").data("engineers");
		source[objId] = null;
		$("#recipient_engineer_" + objId).remove();
	} else if (type === "member") {
		source = $("#recipient_list_to").data("members");
		source[objId] = null;
		$("#recipient_member_" + objId).remove();
	} else if (["cc", "bcc"].indexOf(type) > -1) {
		$("#" + objId).fadeOut(env.TRANS_SPEED_DELETE, function () {
			$("#" + objId).remove();
		});
	}
}

function activateRecipientModalTable(type) {
	if (type === "worker") {
		$("#modal_search_result_worker").css("display", "table");
		$("#modal_search_result_engineer").css("display", "none");
		$("#modal_search_result_member").css("display", "none");
	} else if (type === "engineer") {
		$("#modal_search_result_worker").css("display", "none");
		$("#modal_search_result_engineer").css("display", "table");
		$("#modal_search_result_member").css("display", "none");
	} else if (type === "member") {
		$("#modal_search_result_worker").css("display", "none");
		$("#modal_search_result_engineer").css("display", "none");
		$("#modal_search_result_member").css("display", "table");
	}
}

/*
function toggleSelectAll(type, src) {
	$("input[id^=" + type + "]").each(function (idx, el) {
		el.checked = src.checked;
	});
}
*/
/* [end] UI functions for modal selecting recipients. */


function incBpArray(targetList, baseObject) {

	var baseList = [];
		baseObject.forEach(function(v, i, a){baseList.push(v.id);});;
	var bpList = targetList.diff(baseList);

	return bpList;
}

Array.prototype.diff = function(a) {
    return this.filter(function(i) {return a.indexOf(i) < 0;});
};

function hdlClickBackPageQuotation(location) {
	var reqObj = env.recentQuery.back_page_reqObj;
	c4s.invokeApi_ex({
		location: location,
		body: reqObj,
		pageMove: true,
		newPage: false
	});
}
