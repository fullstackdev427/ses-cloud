/*
 * Common functionalities for C4S.
 * @version: 0.1
 */

(function () {
	window.c4s = {
		hdlClickGnaviBtn : function (loc, options) {
			var form = $("<form/>")[0];
			var json = $("<input type='hidden' name='json'/>")[0];
			var reqObj = {
				login_id: env.login_id,
				credential: env.credential,
			};
			if(loc == "matching.project" || loc == "matching.engineer"){
				c4s.loadSearchConditionFromCookie(reqObj, loc);
			}
			if(loc == "invoice.top"){
				var date = new Date();
				date.setMonth(date.getMonth()-1)
				reqObj.quotation_month = date.getFullYear() + '/' + (date.getMonth() + 1)
			}
			if (options) {
				var i;
				for (i in options) {
					reqObj[i] = options[i];
				}
			}
			form.appendChild(json);
			form.action = "/" + [env.prefix, "html", loc].join("/") + "/";
			form.method = "POST";
			form.enctype = "application/x-www-form-urlencoded";
			json.value = JSON.stringify(reqObj);
			$("body").append(form);
			form.submit();
		},
		hdlClickClearInvoiceBtn : function (loc, options) {
			var form = $("<form/>")[0];
			var json = $("<input type='hidden' name='json'/>")[0];
			var reqObj = {
				login_id: env.login_id,
				credential: env.credential,
				check_init: 1
			};
			if (options) {
				var i;
				for (i in options) {
					reqObj[i] = options[i];
				}
			}
			form.appendChild(json);
			form.action = "/" + [env.prefix, "html", loc].join("/") + "/";
			form.method = "POST";
			form.enctype = "application/x-www-form-urlencoded";
			json.value = JSON.stringify(reqObj);
			$("body").append(form);
			form.submit();
		},
		hdlClickSearchBtn: function() {
			var reqObj = genFilterQuery();
			genOrderQuery(reqObj);
			reqObj.login_id = env.login_id;
			c4s.invokeApi_ex({
				location: env.current,
				body: reqObj,
				pageMove: true,
			});
		},
		hdlClickDirectionBtn : function (loc, options) {
			var form = $("<form/>")[0];
			var json = $("<input type='hidden' name='json'/>")[0];
			var reqObj = {
				login_id: env.login_id,
				credential: env.credential,
			};
			form.appendChild(json);
			form.action = "/" + [env.prefix, "html", loc].join("/") + "/";
			form.method = "POST";
			form.enctype = "application/x-www-form-urlencoded";
			if (!options) {
				form.target = "_blank";
			}
			json.value = JSON.stringify(reqObj);
			$("body").append(form);
			form.submit();
		},
		hdlClickVideoBtn : function (video) {
			c4s.invokeApi_ex({
				location: "home.video",
				body: {
					video: video
				},
				pageMove: true,
				newPage: true
			});
		},
		// [begin] Transactional methods for map.
		openMap: function (reqObj) {
			var address = reqObj ? (reqObj.addr1 || reqObj.addr2 || '') : false;
			var underLMT = reqObj ? (reqObj.isFloodLMT ? false : true ) : false;
			if (underLMT && address) {
				c4s.invokeApi_ex({
					location: "client.mapClient",
					body: reqObj,
					pageMove: true,
					newPage: true,
				});
			} else if (underLMT === false) {
				alert("月間利用可能回数の上限を超えています。詳細は担当者にご確認下さい");
			} else {
				alert("住所を入力してください");
			}
		},
		// [end] Transactional methods for map.
		invokeApi: function (apiLoc, requestObj, callback, pageMove, moveToNewPage) {
			/*********************************************************
			 !DEPLICATED!
			*********************************************************/
			pageMove = pageMove || false;
			moveToNewPage = moveToNewPage || false;
			requestObj.login_id = env.login_id;
			requestObj.credential = env.credential || env.cookie_cred;
			env.debugOut(requestObj);
			if (pageMove) {
				var form = $("<form/>")[0];
				var json = $("<input type='hidden' name='json'/>")[0];
				form.appendChild(json);
				form.action = "/" + env.prefix + "/html/" + apiLoc + "/";
				form.method = "POST";
				form.enctype = "application/x-www-form-urlencoded";
				if (moveToNewPage) {
					form.target = "_blank";
				}
				json.value = JSON.stringify(requestObj);
				$("body").append(form);
				form.submit();
			} else {
				var option = {};
				option.async = false;
				option.contentType = "application/json";
				option.cache = false;
				option.dataType = "json";
				option.processData = false;
				option.url = apiLoc;
				option.timeout = 3;
				option.type = "POST";
				option.url = "/" + env.prefix + "/api/" + apiLoc + "/json";
				option.success = function(data, dataType) {
					env.debugOut(data);
					callback(data);
				};
				option.data = JSON.stringify(requestObj);
				$.ajax(option);
			}
		},
		validate: function (reqObj, rules, elements) {
			// reqObj: dictionary to be commit.
			// rules: {reqObj_key: {msg: error_msg, rule_name: rule_option,...}} formed dictionary.
			// elements: {reqObj_key: jQuery Selector String or jQuery object} formed dictionary.
			c4s.clearValidate(elements);
			var validator = {
				r_type: function (variable, option) {
					//型同一性検証
					//option: 型オブジェクト
					return typeof(variable) === typeof(option()) || (variable instanceof option);
				},
				r_typeOrNull: function (variable, option) {
					//型同一性検証(null許可)
					if(variable == null){
						return true;
					}
					//option: 型オブジェクト
					return typeof(variable) === typeof(option()) || (variable instanceof option);
				},
				r_bool: function (variable, option) {
					//ブール値検証
					//option: true or false
					return Boolean(variable) === option;
				},
				r_minLength: function (variable, option) {
					//シーケンス長最小値検証
					//option: Number
					try {
						return variable.length >= option;
					} catch (e) {
						return false;
					}
				},
				r_maxLength: function (variable, option) {
					//シーケンス長最大値検証
					//option: Number
					try {
						return variable.length <= option;
					} catch (e) {
						return false;
					}
				},
				r_length: function (variable, option) {
					//シーケンス長検証
					//option: Number
					return variable.length == option;
				},
				r_minNum: function (variable, option) {
					//最小値検証
					//option: Number
					return variable >= option;
				},
				r_maxNum: function (variable, option) {
					//最大値検証
					//option: Number
					return variable <= option;
				},
				r_candidate: function (variable, option) {
					//候補値検証
					//option: Array<String>
					return option instanceof Array ? (option.filter(function (val) {
						return variable == val;
					}).length == 1) : false;
				},
				r_regex: function(variable, option) {
					//文字列パターン検証
					//option: String
					return typeof(option) === "string" ? (
						Boolean(variable.match(new RegExp(option)))
					) : false;
				},
			};
			var req_key;
			var tmpRule, rule_key;
			var tmp_valid;
			var el;
			var log = [];
			for(req_key in reqObj) {
				tmpRule = rules[req_key];
				if (tmpRule) {
					rule_key = null;
					for(rule_key in tmpRule) {
						if (rule_key !== "msg") {
							tmp_valid = validator["r_" + rule_key](reqObj[req_key], tmpRule[rule_key]);
							if (!tmp_valid) {
								// [begin] Logging.
								log.push(tmpRule['msg'] ? tmpRule['msg'] : (req_key + ":" + rule_key));
								// [end] Logging.
								// [begin] Styling element.
								if (elements && elements[req_key]) {
									el = typeof(elements[req_key]) === "string" ?
										$(elements[req_key].indexOf("#") == 0 ? elements[req_key] : ("#" + elements[req_key])) :
										elements[req_key];
									el.parent().removeClass("has-error");
									el.parent().addClass("has-error");
								}
								// [end] Styling element.
							}
						}
					}
				}
			}
			return log;
		},
		clearValidate: function (elements) {
			if (elements) {
				var i;
				var el;
				for(i in elements) {
					el = typeof(elements[i]) === "string" ?
						$(elements[i].indexOf("#") == 0 ? elements[i] : ("#" + elements[i])) :
						elements[i];
					el.parent().removeClass("has-error");
				}
			}
		},
		validateRules: {
			client: {
				id: {type: Number, minNum: 1,},
				name: {type: String, minLength: 1, maxLength: 64,},
				kana: {type: String, minLength: 1, maxLength: 128,},
				addr_vip: {type: String, maxLength: 7, regex: "^([0-9]{3}-?[0-9]{4})?$",},
				addr1: {type: String, minLength: 1, maxLength: 64,},
				addr2: {type: String, maxLength: 64,},
				tel: {type: String, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				fax: {type: String, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				site: {type: String, maxLength: 128, regex: "^((http|https)\\://.+)?$",},
				type_dealing: {type: String,},
				type_presentation: {type: Array, minLength: 1},
				note: {type: String,},
			},
			branch: {
				id: {type: Number, minNum: 1,},
				name: {type: String, minLength: 1, maxLength: 32,},
				client_id: {type: Number, minNum: 1,},
				addr_vip: {type: String, maxLength: 7, regex: "^([0-9]{3}-?[0-9]{4})?$",},
				addr1: {type: String, minLength: 1, maxLength: 64,},
				addr2: {type: String, maxLength: 64,},
				tel: {type: String, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				fax: {type: String, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
			},
			worker: {
				id: {type: Number, minNum: 1,},
				client_id: {type: Number, minNum: 1,},
				name: {type: String, minLength: 1, maxLength: 32,},
				kana: {type: String, minLength: 1, maxLength: 64,},
				section: {type: String, maxLength: 64,},
				title: {type: String, maxLength: 32,},
				tel: {type: String, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				tel2: {type: String, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				mail1: {type: String, maxLength: 64, regex: "^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)?$",},
				mail2: {type: String, maxLength: 64, regex: "^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)?$",},
				flg_keyperson: {type: Boolean,},
				flg_sendmail: {type: Boolean,},
				recipient_priority: {type: Number, minNum: 1, maxNum: 9,},
				// charging_user_login_id: {type: String, maxLength: 15,},
			},
			project: {
				id: {type: Number, minNum: 1,},
				client_id: {type: Number,minNum: 1,},
				client_name: {type: String, minLength: 1, maxLength: 32,},
				title: {type: String, minLength: 1, maxLength: 64,},
				term: {type: String, maxLength: 32,},
				term_begin: {type: Date, maxLength: 10,},
				term_end: {type: Date, maxLength: 10,},
				age_from: {type: Number,minNum: 18, },
				age_to: {type: Number, minNum: 18, },
				fee_inbound: {type: Number, minNum: 0,},
				fee_outbound: {type: Number, minNum: 0,},
				expense: {type: String, maxLength: 64,},
				process: {type: String, maxLength: 128,},
				interview: {type: Number, minNum: 0, maxNum: 99,},
				station: {type: String, maxLength: 15,},
				scheme: {type: String, candidate: ["元請", "エンド", ""],},
				skill_needs: {type: String, maxLength: 512,},
				skill_recommends: {type: String, maxLength: 512,},
			},
			engineer: {
				id: {type: Number, minNum: 1,},
				client_id: {type: Number, minNum: 1,},
				name: {type: String, minLength: 1, maxLength: 32,},
				kana: {type: String, minLength: 1, maxLength: 64,},
				visible_name: {type: String, minLength: 1, maxLength: 16},
				tel: {type: String, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				mail1: {type: String, maxLength: 64, regex: "^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)?$",},
				mail2: {type: String, maxLength: 64, regex: "^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)?$",},
				birth: {type: String, maxLength: 10,},
				age: {type: Number, maxNum: 99},
				gender: {type: String, length: 1,},
				fee: {type: Number, minNum: 0,},
				station: {type: String, maxLength: 15,},
				skill: {type: String, maxLength: 512,},
				state_work: {type: String, maxLength: 8,},
				employer: {type: String, maxLength: 100,},
				operation_begin: {type: String, maxLength: 10,},
				addr_vip: {type: String, maxLength: 7, regex: "^([0-9]{3}-?[0-9]{4})?$",},
				addr1: {type: String, maxLength: 64,},
				addr2: {type: String, maxLength: 64,},
			},
			preparation: {
				client_name: {type: String, minLength: 1, maxLength: 32,},
				time: {type: String, maxLength: 32,},
				progress: {type: String, maxLength: 64,},
				note: {type: String, maxLength: 128,},
			},
			negotiation: {
				id: {type: Number, minNum: 1,},
				name: {type: String, minLength: 1, maxLength: 64,},
				client_name: {type: String, minLength: 1, maxLength: 32,},
				note: {type: String,},
			},
			schedule: {

			},
			todo: {
				id: {type: Number, minNum: 1,},
				note: {type: String, minLength: 1, maxLength: 128,},
			},
			mailRequest: {
				tpl_id: {type: Number, minNum: 1,},
				addr_to: {type: Array, minLength: 1,},
				addr_cc: {type: Array,},
				addr_bcc: {type: Array,},
				subject: {type: String, minLength: 1, maxLength: 64},
				body: {type: String, minLength: 1,},
				attachments: {type: Array,},
			},
			account: {
				new_login_id: {type: String, minLength: 1, maxLength: 32,},
				name: {type: String, minLength: 1, maxLength: 32,},
				tel1: {type: String, minLength: 1, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				mail1: {type: String, minLength: 3, maxLength: 64, regex: "^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)?$",},
				password: {type: String, minLength: 5,},
			},
			mailAddr: {
				mail: {type: String, minLength: 3, maxLength: 64, regex: "^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)?$",},
			},
			signupCompany: {
				name: {type: String, minLength: 1, maxLength: 32,},
				owner_name: {type: String, minLength: 1, maxLength: 32,},
				tel: {type: String, minLength: 1, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)$",},
				fax: {type: String, minLength: 0, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				addr_vip: {type: String, maxLength: 8, regex: "^([0-9]{3}-?[0-9]{4})$",},
				addr1: {type: String, minLength: 1, maxLength: 64,},
				addr2: {type: String, maxLength: 64,},
				prefix:{type: String, maxLength: 8, regex: "^([0-9a-zA-Z_.\\-\+]+)?$",},

			},
			signupUser: {
				name: {type: String, minLength: 1, maxLength: 32,},
				prefer_login_id: {type: String, minLength: 1, maxLength: 32,},
				pwd: {type: String, minLength: 5,},
				mail1: {type: String, minLength: 3, maxLength: 64, regex: "^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)+$",},
				tel1: {type: String, minLength: 1, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)+$",},
				tel2: {type: String, minLength: 0, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
				fax: {type: String, minLength: 0, maxLength: 15, regex: "^([\\(\\)0-9]+-?[0-9\-]+)?$",},
			},
			updatePref: {
				max_account: {type: Number, minNum: 0, maxNum: 19999,},
				max_client: {type: Number, minNum: 0, maxNum: 19999,},
				max_worker: {type: Number, minNum: 0, maxNum: 19999,},
				max_project: {type: Number, minNum: 0, maxNum: 19999,},
				max_engineer: {type: Number, minNum: 0, maxNum: 19999,},
				max_mail_tpl: {type: Number, minNum: 0, maxNum: 19999,},
			},
			operation:{
				project_client_id: {type: Number, minNum: 1,},
				project_name: {type: String, minLength: 1, maxLength: 64,},
				engineer_name: {type: String, minLength: 1, maxLength: 32,},
				term_memo:{type: String, minLength: 0, maxLength: 64,},
				is_active: {type: Number, minNum: 0,},
				is_fixed: {type: Number, minNum: 0,},
				transfer_member:{type: String, minLength: 0, maxLength: 32,},
				demand_site:{type: String, minLength: 0, maxLength: 64,},
				payment_site:{type: String, minLength: 0, maxLength: 64,},
				other_memo:{type: String, minLength: 0, maxLength: 64,},
				base_exc_tax: {type: Number, minNum: 0, maxNum: 999999999,},
				demand_wage_per_hour: {type: Number, minNum: 0, maxNum: 999999999,},
				demand_working_time: {typeOrNull: Number, minNum: 0, maxNum: 9999,},
				settlement_from: {typeOrNull: Number, minNum: 0, maxNum: 9999,},
				settlement_to: {typeOrNull: Number, minNum: 0, maxNum: 9999,},
				deduction: {type: Number, minNum: 0, maxNum: 999999999,},
				excess: {type: Number, minNum: 0, maxNum: 999999999,},
				payment_base: {type: Number, minNum: 0, maxNum: 999999999,},
				payment_wage_per_hour: {type: Number, minNum: 0, maxNum: 999999999,},
				payment_working_time: {typeOrNull: Number, minNum: 0, maxNum: 9999,},
				payment_settlement_from: {typeOrNull: Number, minNum: 0, maxNum: 9999,},
				payment_settlement_to: {typeOrNull: Number, minNum: 0, maxNum: 9999,},
				payment_deduction: {type: Number, minNum: 0, maxNum: 999999999,},
				payment_excess: {type: Number, minNum: 0, maxNum: 999999999,},
				welfare_fee: {type: Number, minNum: 0, maxNum: 999999999,},
				transportation_fee: {type: Number, minNum: 0, maxNum: 999999999,},
				bonuses_division: {type: Number, minNum: 0, maxNum: 999999999,},
				engineer_client_id: {type: Number, minNum: 1,},
			}
		},

		genValidateMessage: function (validLog, signature) {
			var FIELDS = {
				client: {
					name: "取引先名",
					kana: "取引先名（カナ）",
					addr_vip: "郵便番号",
					addr1: "住所1",
					addr2: "住所2",
					tel: "電話番号",
					fax: "FAX番号",
					site: "ホームページ"
				},
				mailRequest: {
					addr_to: "宛先",
					addr_cc: "CC",
					addr_bcc: "BCC",
					subject: "件名"
				},
				signupCompany: {
					name: "企業・団体名",
					owner_name: "代表者名",
					tel: "代表電話番号",
					fax: "代表FAX番号",
					addr_vip: "郵便番号",
					addr1: "住所",
					addr2: "住所（ビル名/部屋番号など）",
				},
				signupUser: {
					name: "氏名",
					login_id: "ログインID",
					pwd: "パスワード",
					mail1: "メール アドレス",
					tel1: "電話番号（メイン）",
					tel2: "電話番号（サブ）",
					fax: "FAX番号",
				},
				updatePref: {
					max_account: "ユーザー アカウント数上限",
					max_client: "取引先登録数上限",
					max_worker: "取引先担当者登録数上限",
					max_project: "案件登録数上限",
					max_engineer: "要員登録数上限",
					max_mail_tpl: "メール テンプレート数上限",
				},
			};
			var RULES = {
				defaults: {
					minNum: "の最小値が範囲外です",
					maxNum: "の最大値が範囲外です",
					minLength: "が短かすぎます",
					maxLength: "が長すぎます",
					regex: "が正しい形式ではありません",
					candidate: "が候補外です"
				}
			};
			var ret = [];
			var i, tmp, field, rule;
			for (i = 0; i < validLog.length; i++) {
				tmp = validLog[i].split(":");
				if (tmp.length == 2) {
					field = tmp[0];
					rule = tmp[1];
					if (FIELDS[signature] && FIELDS[signature][field]) {
						if (RULES['defaults'][rule] || RULES[signature][rule]) {
							ret.push("「" + FIELDS[signature][field] + "」" + (RULES['defaults'][rule] || RULES[signature][rule]));
						} else {
							ret.push("「" + FIELDS[signature][field] + "」" + "が正しくありません");
						}
					}
				} else {
					ret.length == 0 ? ret.push("入力を修正してください") : null;
				}
			}
			return ret;
		},
		invokeApi_ex: function (option) {
			/* option contains parameters below:
				location: API field string in "logic.realm" form.
				body: Request POST body object.
				  This value will be converted into JSON string format
				  and be capsuled into 'json' parameter key.
				pageMove: Boolean. If set true, page will be load.
				newPage: Boolean. If set true, response will be loaded in new page.
				onSuccess: Callback function in success state with single parameter
				  of JSON-deserialized response body. If pageMove set to be true,
				  this entity maybe undefined.
				onError: Callback function in error state with single parameter of
				  JSON-deserialized response body. If pageMove set to be true,
				invokeApi_ex  this entity maybe undefined. In the case of HTTP protocol exception,
				  also this callback will NOT BE CALLED.
			*/
			var delay = option.body.delay ? option.body.delay : null;
			if (option.body) {
				option.body.login_id = env.login_id;
				option.body.credential = env.credential;
			} else {
				option.body = {
					login_id: env.login_id,
					credential: env.credential,
				};
			}
			env.debugOut(option);
			if (option.body) {
				if (option.pageMove) {
					var form = $("<form/>")[0];
					var json = $("<input type='hidden' name='json'/>")[0];
					form.appendChild(json);
					form.action = "/" + env.prefix + "/html/" + option.location + "/";
					form.method = "POST";
					form.enctype = "application/x-www-form-urlencoded";
					if (option.newPage) {
						form.target = "_blank";
					}
					json.value = JSON.stringify(option.body);
					$("body").append(form);
					if (option.location) {
						form.submit();
					}
				} else {
					var options = {};
					options.async = option.async || false;
					options.contentType = "application/json";
					options.cache = false;
					options.dataType = "json";
					options.processData = false;
					options.timeout = option.timeout || 3;
					options.type = "POST";
					options.url = "/" + env.prefix + "/api/" + option.location + "/json";
					options.success = function(data, dataType) {
						env.debugOut(data);
						if (data && data.status && data.status.code == 0) {
							(option.onSuccess ? option.onSuccess : env.debugOut)(data);
						} else if (data && data.status && data.status.code == 15) {
							data.status.signature.length ?
								c4s.showAlertCapacity(data.status.signature[0]) :
								(option.onError ? option.onError : env.debugOut)(data);
						} else {
							(option.onError ? option.onError : env.debugOut)(data);//Todo: code == 3用の処理を追加する
						}
					};
					options.data = JSON.stringify(option.body);
					if (delay) {
						setTimeout(function (options) {
							return function () {
								$.ajax(options);
							}
						}(options), delay);
					} else {
						$.ajax(options);
					}
				}
			} else {
				env.debugOut("option.body must be set.");
			}
		},
		searchAll : function(word) {
			c4s.invokeApi_ex({
				location: "home.search",
				body: {word: word},
				pageMove: true,
			});
			return false;
		},
		reloadWithOrder: function(key, dir) {
			var reqObj = env.recentQuery || {};
			delete reqObj.pageOffset;
			delete reqObj.ctrl_referer;
			delete reqObj.modal;
			delete reqObj.sort_keys;
			reqObj.sort_keys = {};
			if (key, dir) {
				reqObj.sort_keys[key] = dir;
			}
			c4s.invokeApi_ex({
				location: env.current,
				body: reqObj,
				pageMove: true,
			});
		},
		hdlClickDeleteItem: function (objectType, objectId, stopRefresh, refreshHelper) {
			if (!objectId || (objectId instanceof Array && objectId.length == 0)) {
				alert("対象データを選択してください。");
				return;
			}
			var apiUrl_delete;
			var apiUrl_refresh;
			var reqObj = {id_list: objectId instanceof Array ? objectId : [objectId]};
			switch (objectType) {
				case "client":
					apiUrl_delete  = "client.deleteClient";
					apiUrl_refresh = "client.enumClients";
					break;
				case "branch":
					apiUrl_delete  = "client.deleteBranch";
					apiUrl_refresh = "client.enumBranches";
					break;
				case "contact":
					apiUrl_delete  = "client.deleteContact";
					apiUrl_refresh = "client.enumContacts";
					break;
				case "worker":
				case "worker_sm":
					apiUrl_delete  = "client.deleteWorker";
					apiUrl_refresh = "client.enumWorkers";
					break;
				case "project":
					apiUrl_delete  = "project.deleteProject";
					apiUrl_refresh = "project.enumProjects";
					break;
				case "engineer":
					apiUrl_delete  = "engineer.deleteEngineer";
					apiUrl_refresh = "engineer.enumEngineers";
					break;
				case "preparation":
					apiUrl_delete  = "engineer.deletePreparation";
					apiUrl_refresh = "engineer.enumPreparations";
					break;
				case "negotiation":
					apiUrl_delete  = "negotiation.deleteNegotiation";
					apiUrl_refresh = "negotiation.enumNegotiations";
					break;
				case "schedule":
					apiUrl_delete  = "misc.deleteSchedule";
					apiUrl_refresh = "misc.enumSchedules";
					break;
				case "todo":
					apiUrl_delete  = "misc.deleteTodo";
					apiUrl_refresh = "misc.enumTodos";
					break;
				case "template":
					apiUrl_delete  = "mail.deleteTemplate";
					apiUrl_refresh = "mail.enumTemplates";
					break;
				case "account":
					apiUrl_delete  = "manage.deleteAccount";
					apiUrl_refresh = "manage.enumAccounts";
					break;
				default:
					apiUrl_delete  = "manage.env";
					apiUrl_refresh = "manage.env";
					break;
			}
			if (confirm("削除してよろしいですか？")) {
				c4s.invokeApi_ex({
					location: apiUrl_delete,
					body: reqObj,
					onSuccess: function (data) {
						var j;
						env.recentAjaxResult = data;
						if (data && data.data.rows && data.data.rows > 0) {
							if (stopRefresh) {
								for (j = 0; j < reqObj.id_list.length; j++) {
									var deleteTarget = $("#iter_" + objectType + "_" + reqObj.id_list[j]);
									var deleteParent = deleteTarget.parent("tbody");
									deleteTarget.fadeOut(env.TRANS_SPEED_DELETE, function() {
										deleteTarget.remove();
										if (deleteParent.children("tr").length == 0) {
											deleteParent.append("<tr><td colspan='" + deleteParent.prev().children("tr").children("th").length + "'>有効なデータがありません</td></tr>");
										}
									});
								}
							} else {
								if (refreshHelper) {
									refreshHelper();
								} else {
									c4s.invokeApi_ex({
										location: env.current,
										body: env.recentQuery,
										pageMove: true,
									});
								}
							}
						}
					},
				});
				return true;
			}
		},
		jumpToPagination: function (pageNumber) {
			c4s.jumpToPage(env.current, {
				pageNumber: pageNumber,
				query: genFilterQuery(),
				});
		},
		jumpToPage: function(path, option) {
			/*******************************************************************************
			 option:
			   tab:(next) Selected tab name on loaded timing of next page.
			   query(next): Parameters for next page.
			   pageNumber(current): Current selected offset page number of caller page.
			   currentModal(current): Current opened modal signature.
			   currentTab(current): Current selected tab.
			*******************************************************************************/
			option = option || {};
			var reqObj = option.query || {};
			if (option.tab) {
				reqObj.ctrl_selectedTab = option.tab;
			}
			reqObj.ctrl_referer = {
				path: env.current,
				tab: env.currentTab || option.currentTab || null,
				modal: env.currentModal || option.currentModal || null,
				query: env.recentQuery,
			};
			if (reqObj.ctrl_referer.query && reqObj.ctrl_referer.query.login_id) {
				delete reqObj.ctrl_referer.query.login_id;
			}
			if (reqObj.ctrl_referer.query && reqObj.ctrl_referer.query.credential) {
				delete reqObj.ctrl_referer.query.credential;
			}
			if (reqObj.ctrl_referer.query && reqObj.ctrl_referer.query.ctrl_referer) {
				delete reqObj.ctrl_referer.query.ctrl_referer;
			}
			if (option.pageNumber) {
				reqObj.pageNumber = option.pageNumber;
			} else {
				reqObj.pageNumber = 1;
			}
			if (option.modal) {
				reqObj.ctrl_referer.modal = option.modal;
			}
			c4s.invokeApi_ex({
				location: path,
				body: reqObj,
				pageMove: true,
			});
		},
		hdlCloseModal: function(evt) {
			var commitFlg = $(evt.currentTarget).data("commitCompleted");
			//var refererFlg = env.recentQuery && env.recentQuery.ctrl_referer && env.recentQuery.ctrl_referer.path;
			var refererFlg = false;
			var query = {};
			if (env.recentQuery && env.recentQuery.ctrl_referer && env.recentQuery.ctrl_referer.query) {
				var i;
				for(i in env.recentQuery.ctrl_referer.query){
					if (i !== "ctrl_referer") {
						query[i] = env.recentQuery.ctrl_referer.query[i]
					}
				}
			}
			if (commitFlg && refererFlg) {
				c4s.jumpToPage(env.recentQuery.ctrl_referer.path, {
					query: query,
				});
			} else if (commitFlg && !refererFlg) {
				c4s.jumpToPage(env.current, {
					query: env.recentQuery,
				});
			} else if (!commitFlg && refererFlg) {
				c4s.jumpToPage(env.recentQuery.ctrl_referer.path, {
					query: query,
				});
			} else if (!commitFlg && !refererFlg) {
				//pass.
			}
		},
		hdlClickNewObjBtn : function(type) {
			var path;
			var option = {};
			switch (type) {
				case "engineer":
					path = "engineer.top";
					option.query = {
						modal: "createEngineer",
					};
					break;
				case "project":
					path = "project.top";
					option.query = {
						modal: "createProject",
					};
					break;
				default:
					path = "home.enum";
					break;
			}
			c4s.jumpToPage(path, option);
		},
		hdlClickViewObjText: function(type, id) {
			var path;
			var option = {};
			switch (type) {
				case "engineer":
					path = "engineer.top";
					option.query = {
						modal: "editEngineer",
						id: id,
					};
					break;
				case "project":
					path = "project.top";
					option.query = {
						modal: "editProject",
						id: id,
					};
					break;
				case "client":
					path = "client.clientTop",
					option.query = {
						modal: "editClient",
						id: id,
					};
					break;
				default:
					path = "home.enum";
					break;
			}
			c4s.jumpToPage(path, option);
		},
		toggleSelectAll: function (type, src) {
			$("input[id^=" + type + "]").each(function (idx, el) {
				el.checked = src.checked;
			});
		},
		download: function (id) {
			var form = $("<form enctype='application/json' encoding='application/json'></form>")[0];
			//form.enctype = "application/json";
			form.action = "/" + env.prefix + "/api/file.download/json";
			form.method = "POST";
			//form.target = "_blank";
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
		},
		downloadAll: function (id) {
			var form = $("<form enctype='application/json' encoding='application/json'></form>")[0];
			//form.enctype = "application/json";
			form.action = "/" + env.prefix + "/api/file.downloadAll/json";
			form.method = "POST";
			//form.target = "_blank";
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
		},
		setCookies: function(key, value) {
			var expire = new Date();
				expire.setTime( expire.getTime() + 1000 * 3600 * 24 * 365 * 100 );
			document.cookie = key + '=' + encodeURIComponent(value) + '; expires=' + expire.toUTCString() + ';path=/';
		},
		getCookies: function() {
			var result = new Array();
			var cookies = document.cookie;
			{
				var cookiesArray = cookies.split( '; ' );
				for( var i = 0; i < cookiesArray.length; i++ )
				{
					var cookie = cookiesArray[ i ].split( '=' );
					result[ cookie[ 0 ] ] = decodeURIComponent( cookie[ 1 ] );
				}
			}
			return result;
		},
		deleteCookie: function (key) {
			var date = new Date();
			date.setTime( date.getTime() - 1 );
			document.cookie = key + '=; expires=' + date.toUTCString();
        },
		loadSearchConditionFromCookie: function (searchCondition, loc) {
			var cookieData = c4s.getCookies();
			var company_id = env.companyInfo.id;
			var user_id = env.userInfo.id;

			if(loc == "matching.project"){
				// var selectedCompanyIds = cookieData["projectSelectedCompanyId" + company_id + user_id];
				// if(selectedCompanyIds != undefined && selectedCompanyIds != ""){
				// 	searchCondition.company_id = selectedCompanyIds.split(",");
				// }
				// var selectedClientIds = cookieData["projectSelectedClientId" + company_id + user_id];
				// if(selectedClientIds != undefined && selectedClientIds != ""){
				// 	searchCondition.client_id = selectedClientIds.split(",");
				// }
				var blackCompanyIds = cookieData["projectBlackCompanyId" + company_id + user_id];
				if(blackCompanyIds != undefined && blackCompanyIds != ""){
					searchCondition.not_company_id = blackCompanyIds.split(",");
				}
			}
			if(loc == "matching.engineer") {
                // var selectedCompanyIds = cookieData["engineerSelectedCompanyId" + company_id + user_id];
                // if (selectedCompanyIds != undefined && selectedCompanyIds != "") {
                //     searchCondition.company_id = selectedCompanyIds.split(",");
                // }
                // var selectedClientIds = cookieData["engineerSelectedClientId" + company_id + user_id];
                // if (selectedClientIds != undefined && selectedClientIds != "") {
                //     searchCondition.client_id = selectedClientIds.split(",");
                // }
				var blackCompanyIds = cookieData["engineerBlackCompanyId" + company_id + user_id];
				if(blackCompanyIds != undefined && blackCompanyIds != ""){
					searchCondition.not_company_id = blackCompanyIds.split(",");
				}
            }
		},
		calcIncTax: function (valExcTax) {
			var TAX_RATE = 0.1;
			return Math.round(valExcTax * (1 + TAX_RATE));
        },
		calcExcTax: function (valIncTax) {
			var TAX_RATE = 0.1;
			return Math.round(valIncTax / (1 + TAX_RATE));
        },
		floor: function(val, n){
			return Math.floor( val * Math.pow( 10, n ) ) / Math.pow( 10, n ) ;
		},
		sleep: function (sec) {
			var d1 = new Date();
			while (true) {
			  var d2 = new Date();
			  if (d2 - d1 > sec) {
				break;
			  }
			}
        }
	};
})();

