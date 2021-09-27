<div id="alert_cap_all_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#alert_cap_mail_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-fire text-danger">&nbsp;</span><span id="m_alert_caps_title"></span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<p class="invoice">ご利用可能なアイテム数がライセンスされた量を超過するため、操作を完了できません。</p>
				<p class="message"><span id="m_alert_caps_key" class="bold"></span>&nbsp;(<span id="m_alert_caps_date"></span>):&nbsp;<span id="m_alert_caps_value"></span><span id="m_alert_caps_measure"></span></p>
				{% if data['auth.userProfile']['user']['is_admin'] == True -%}
				<p class="message">管理者ユーザーの方は、利用状況の詳細を<span id="m_alert_caps_review_link" class="pseudo-link bold">こちら</span>からご確認いただけます。</p>
				{% endif -%}
				<p class="message">ご契約上の制限を解除するには、本サービスの営業担当までご連絡ください。<br/>株式会社グッドワークス Tel.：03-3525-8050</p>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
	<script type="text/javascript" language="JavaScript">
		$(document).ready(function () {
			$("#m_alert_caps_review_link").on("click", function () {
				c4s.invokeApi_ex({
					location: "manage.top",
					body: {"ctrl_selectedTab": "ct_preferences"},
					pageMove: true,
				});
			});
			if (!c4s.showAlertCapacity) {
				c4s.showAlertCapacity = function (key) {
					var t_title, t_kname, t_measure;
					switch (key) {
						case "LMT_LEN_CLIENT":
							t_title = "取引先 登録数警告";
							t_kname = "取引先数";
							t_measure = "件";
							break;
						case "LMT_LEN_WORKER":
							t_title = "取引先担当者 登録数警告";
							t_kname = "取引先担当者数";
							t_measure = "名";
							break;
						case "LMT_LEN_PROJECT":
							t_title = "案件 登録数警告";
							t_kname = "案件数";
							t_measure = "件";
							break;
						case "LMT_LEN_ENGINEER":
							t_title = "要員 登録数警告";
							t_kname = "要員数";
							t_measure = "名";
							break;
						case "LMT_CALL_MAP_EXTERN_M":
							t_title = "地図サービス 利用回数警告";
							t_kname = "地図サービス利用数";
							t_measure = "回";
							break;
						case "LMT_LEN_MAIL_PER_DAY":
							t_title = "メール（直近1日） 発信数警告";
							t_kname = "メール発信数（直近1日）";
							t_measure = "通";
							break;
						case "LMT_LEN_MAIL_PER_MONTH":
							t_title = "メール（直近1ヶ月） 発信数警告";
							t_kname = "メール発信数（直近1ヶ月）";
							t_measure = "通";
							break;
						case "LMT_LEN_MAIL_TPL":
							t_title = "メール テンプレート 登録数警告";
							t_kname = "メール テンプレート数";
							t_measure = "個";
							break;
						case "LMT_SIZE_STORAGE":
							t_title = "データ保存 サイズ警告";
							t_kname = "データ保存容量";
							t_measure = "bytes";
							break;
						default:
							void(0);
					}
					if (t_title && t_kname) {
						$("#m_alert_caps_title").text(t_title);
						$("#m_alert_caps_date").text((new Date()).format("%Y/%m/%d %H時%M分"));
						$("#m_alert_caps_key").text(t_kname);
						$("#m_alert_caps_value").text(env.records[key] + " / " + env.limit[key]);
						$("#m_alert_caps_measure").text(t_measure);
						$("#alert_cap_all_modal").modal("show");
					}
				};
			}
			if (!c4s.inspectCapacity) {
				c4s.inspectCapacity = function (key, preventShowAlert) {
					var ret;
					if (env.records[key] + 1 >= env.limit[key] && env.limit[key] != 0) {
						ret = false;
						if (!preventShowAlert) {
							c4s.showAlertCapacity(key);
						}
					} else {
						ret = true;
					}
					return ret;
				};
			}
			var timer = setInterval(function () {
				c4s.invokeApi_ex({
					location: "manage.enumPrefs",
					body: {},
					onSuccess: function(data) {
						if (data['data'] && data.data instanceof Array) {
							data.data.map(function (val, idx, arr) {
								env.limit[val.key] = val.final;
								if (["LMT_LEN_CLIENT", "LMT_LEN_WORKER", "LMT_LEN_PROJECT",
									"LMT_LEN_ENGINEER", "LMT_LEN_ACCOUNT", "LMT_CALL_MAP_EXTERN_M",
									"LMT_LEN_MAIL_PER_DAY", "LMT_LEN_MAIL_PER_MONTH",
									"LMT_LEN_MAIL_TPL", "LMT_SIZE_STORAGE"].indexOf(val.key) > -1) {
									env.records[val.key] = val.current;
								}
							});
						}
					},
					onError: function(data) {
						delete timer;
					},
				});
			}, 5 * 60 * 1000);
		});
	</script>
</div><!-- div.modal -->
