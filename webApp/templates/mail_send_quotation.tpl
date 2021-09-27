{% import "cmn_controls.macro" as buttons -%}
{% if "quotation_type" in query and (query.quotation_type == "estimate") -%}
	{% set tpl_types = ("見積書") -%}
{% elif "quotation_type" in query and (query.quotation_type == "order") -%}
	{% set tpl_types = ("請求先注文書") -%}
{% elif "quotation_type" in query and (query.quotation_type == "purchase") -%}
    {% set tpl_types = ("注文書") -%}
{% else %}
    {% set tpl_types = ("請求書") -%}
{% endif -%}

{% set title_types = ("様", "さん") -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
{#
{% include "cmn_header.tpl" %}
#}
<!-- メインコンテンツ -->
			<div class="row">
				<div {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_content" style="margin-top: 1em;" {% else -%}class="container" style="margin-bottom:100px;"{% endif -%}>
					<!-- 宛先情報 -->
					<div id="header" class="row">
						<h3><img alt="メール" width="22" height="20" src="/img/icon/group_mail.png"> メール作成</h3>

						<div class="col-md-12">
							<h4>メール宛先情報</h4>
							<p>以下の送信先にメールを送付します。送信先の追加は各項の右側のボタンを、送信先の削除は<span class="glyphicon glyphicon-remove text-danger"></span>ボタンの付いた個々のアドレスをクリックしてください。</p>

							<div class="input-group">
								<span class="input-group-addon">宛先</span>
								<ul class="form-control recipient_list" id="recipient_list_to">
								{% if query.type_recipient == "forWorker" or query.type_recipient == "forMatching" %}
									<li class="btn btn-sm btn-primary bold pull-right" style="text-align: right;" title="取引先担当者"
										onclick="openRecipientsModalOnMail('worker');">追加
									</li>
								{% endif %}
								{% if query.type_recipient == "forEngineer" %}
									<li class="btn btn-sm btn-primary bold pull-right" style="text-align: right;" title="技術者"
										onclick="openRecipientsModalOnMail('engineer');">追加
									</li>
								{% endif %}
								</ul>
							</div>
							<div class="input-group">
								<span class="input-group-addon">Reply-to</span>
								<select class="form-control" id="reply_to_addr">
								{% for account in data['manage.enumAccounts']|rejectattr("is_enabled", "even")|rejectattr("is_locked", "odd") %}
									{% if account.id == data['auth.userProfile'].user.id %}
									<option data-account-id={{ account.id }} selected>{{ account.name }} &lt;{{ account.mail1 }}&gt;</option>
									{% else %}
									<option data-account-id={{ account.id }}>{{ account.name }} &lt;{{ account.mail1 }}&gt;</option>
									{% endif %}
								{% endfor %}
								</select>
							</div>
							<div class="input-group">
								<span class="input-group-addon">CC</span>
								<ul class="form-control recipient_list" id="recipient_list_cc">
									<li class="pull-right" style="text-align: right;">
										<button class="btn btn-sm btn-primary"
											onclick="$('#input_add_addr_target').val('cc');$('#edit_address_modal').modal('show');"><span class="bold">追加</span></button>
									</li>
								</ul>
							</div>
							<div class="input-group">
								<span class="input-group-addon">BCC</span>
								<ul class="form-control recipient_list" id="recipient_list_bcc">
									<li class="pull-right" style="text-align: right;">
										<button class="btn btn-sm btn-primary"
											onclick="$('#input_add_addr_target').val('bcc');$('#edit_address_modal').modal('show');"><span class="bold">追加</span></button>
									</li>
								</ul>
							</div>
						</div>
					</div>
					<!-- 宛先情報（ここまで） -->
					<div class="">
						<hr/>
                        {% if query.back_page_quotation_location %}
                            <input type="button" class="btn btn-primary" value="帳票作成に戻る"
                                onclick="hdlClickBackPageQuotation('{{ query.back_page_quotation_location }}');"/>
                        {% endif %}
					</div>
					<!-- 本文情報 -->
					<div class="">
                        <div class="col-md-2">
                        </div>
						<div class="col-md-8">
							<h4>メール内容情報{% if query.type_recipient == "forWorker" %}&nbsp;（取引先担当者向けテンプレート）{% elif query.type_recipient == "forEngineer" %}&nbsp;（技術者向けテンプレート）{% else %}&nbsp;（マッチングテンプレート）{% endif %}&nbsp;
								<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
									data-toggle="popover"
									data-html="true"
									data-content="最適なテンプレートをクリックすることでメールが自動生成されます。<br/>「案件配信」、「人材配信」をクリックするとリストを表示し、対象データを本文に差し込めます。（テンプレートによって差し込めるデータの種類が決定されます）"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');"></span>
							</h4>
							<ul class="nav nav-tabs" role="tablist">
							{% for item in data['mail.enumTemplates']|sort(attribute="type_recipient")|reverse %}
								<li>
									<a href="#tplview_{{ item.id }}" role="tab" data-toggle="tab" data-type-iterator='{{ item.type_iterator|tojson }}' data-first-view="{% if loop.first %}false{% else %}true{% endif -%}">{{ item.name }}</a>
								</li>
							{% endfor %}
							</ul>
							<div class="tab-content">
							{% for item in data['mail.enumTemplates']|sort(attribute="type_recipient")|reverse %}
								{% set tpl_id = item.id %}
								{% set attachments = item.attachments %}
								<div class="tab-pane fade in" id="tplview_{{ tpl_id }}">
									<input type="hidden" id="input_0_tpl_id_{{ loop.index }}" value="{{ tpl_id }}"/>
									<div class="input-group">
										<span class="input-group-addon">敬称</span>
										<ul class="form-control" style="list-style-type: none;">
									{% for title in title_types %}
											<li>
												<input type="radio" name="input_0_type_title_{{ tpl_id }}" id="input_0_type_title_{{ tpl_id }}_{{ loop.index }}" value="{{ title|e }}"{% if loop.index0 == 0 %} checked="checked"{% endif %}/><label for="input_0_type_title_{{ tpl_id }}_{{ loop.index }}">{{ title|e }}</label>
											</li>
									{% endfor %}
										</ul>
									</div>
									<div class="input-group">
										<span class="input-group-addon">件名</span>
										<input type="text" class="form-control" id="input_0_subject_{{ loop.index }}" value="{{ item.subject|e }}"/>
									</div>
									<div class="input-group">
										<span class="input-group-addon">本文</span>
										<div class="form-control">
											<span><textarea class="form-control" id="input_0_body_{{ loop.index }}" style="height: 30em;">{{ item.body|e }}</textarea></span>
											<button class="popover-dismiss btn btn-default bold"
												id="input_0_refresh_btn_{{ loop.index }}"
												data-toggle="popover"
												data-placement="top"
												data-content="データをテンプレートに再反映させ、編集内容をクリアします。"
												onmouseover="$(this).popover('show');"
												onmouseout="$(this).popover('hide');"
												onclick="refreshMailBody({ template_id:{{ tpl_id }}, type_title: ($('#input_0_type_title_{{ tpl_id }}_1')[0].checked ? '様' : 'さん'), body_id: 'input_0_body_{{ loop.index }}'});">
												<span class="glyphicon glyphicon-refresh text-success"></span>&nbsp;
												差し込みデータを本文に反映
											</button>
                                            {% if env.limit.SHOW_HELP %}
                                                <span class="text-warning">右表で選択し、左のボタンで本文に反映させます。</span>
                                            {% endif %}
										</div>
									</div>
									<div class="input-group">
										<span class="input-group-addon">添付ファイル</span>
										<ul class="form-control list-group" style="padding: 0;">
										{% for idx in range(0, env.limit.LMT_LEN_MAIL_ATTACHMENT, 1) %}
											{% if idx < attachments|length %}
											{% set attachment = attachments[idx] %}
											{% else %}
											{% set attachment = None %}
											{% endif %}
											<li class="list-group-item" id="attachment_container_{{ tpl_id }}_{{ idx }}" style="overflow: hidden;">
												<input type="hidden" id="attachment_id_{{ tpl_id }}_{{ idx }}" value="{% if attachment %}{{ attachment.id }}{% endif %}"/>
												<label id="attachment_label_{{ tpl_id }}_{{ idx }}"
													class="bold mono pseudo-link"
													style="display: {% if attachment %} inline {% else %} none{% endif %};"
													onclick="c4s.download($('#attachment_id_{{ tpl_id }}_{{ idx }}').val());">
													{% if attachment %}
													{{attachment.name}}&nbsp;({{attachment.size}}bytes)
													{% endif %}
												</label>
												<input type="file" id="attachment_file_{{ tpl_id }}_{{ idx }}"
													onchange="uploadFile({{ tpl_id }}, {{ idx }});"
													style="display: {% if attachment %} none {% else %} inline {% endif %}"/>
												<button class="btn btn-default pull-right"
													id="attachment_btn_delete_{{ tpl_id }}_{{ idx }}"
													style="display: {% if attachment %}inline {% else %}none {% endif %};"
													onclick="deleteAttachment({{ tpl_id }}, {{ idx }});"><span class="glyphicon glyphicon-trash text-danger"></span>&nbsp;削除</button>
											</li>
										{% endfor %}
										</ul>
									</div>
									<hr/>
									<div style="height: 2em;">
                                        {% if query.back_page_quotation_location %}
                                            <input type="button" class="btn btn-primary" value="帳票作成に戻る"
												onclick="hdlClickBackPageQuotation('{{ query.back_page_quotation_location }}');"/>
                                        {% endif %}
										<button class="pull-right popover-dismiss btn btn-primary bold"
											data-toggle="popover"
											data-placement="top"
											data-content="送信先と送信内容を確認してから、送信を確定します。"
											onmouseover="$(this).popover('show');"
											onmouseout="$(this).popover('hide');"
											onclick="confirmBody({template_id: {{ tpl_id }}, template_type: '{{ item.type_recipient }}', type_title: ($('input[id^=input_0_type_title_{{ tpl_id }}_]')[0].checked ? '様' : 'さん'), subject: $('#input_0_subject_{{ loop.index }}').val(), body_id: '#input_0_body_{{ loop.index }}', attachment_id: [{% for idx in range(0, env.limit.LMT_LEN_MAIL_ATTACHMENT, 1) %}'#attachment_id_{{ tpl_id }}_{{ idx }}'{% if loop.index < env.limit.LMT_LEN_MAIL_ATTACHMENT %}, {% endif %}{% endfor %}]});"><span class="glyphicon glyphicon-ok"></span>&nbsp;確認</button>
									</div>
								</div>
							{% endfor %}
							</div>
						</div><!-- templating fields -->
                        <div class="col-md-2">
                        </div>
						
						<div class="hidden">
							<ul class="nav nav-tabs" role="tablist">
								<li>
									<a href="#dataview_engineers" role="tab" data-toggle="tab">技術者情報</a>
								</li>
								<li>
									<a href="#dataview_projects" role="tab" data-toggle="tab">案件情報</a>
								</li>
							</ul>
							<div class="tab-content">
								<div class="tab-pane fade in" id="dataview_engineers">
									<table class="view_table table-bordered table-hover">
										<thead>
											<tr>
												<th style="width: 25px;"></th>
												<th>要員名</th>
												<th>単価</th>
												<th>稼働</th>
												<th>スキル</th>
												<th style="width: 35px;"></th>
											</tr>
										</thead>
										<tbody id="tablebody_forMailContent_engineers"></tbody>
									</table>
								</div>
								<div class="tab-pane fade in" id="dataview_projects">
									<table class="view_table table-bordered table-hover">
										<thead>
											<tr>
												<th style="width: 25px;"></th>
												<th>案件名</th>
												<th>請求単価</th>
												<th>期間</th>
												<th>スキル</th>
											</tr>
										</thead>
										<tbody id="tablebody_forMailContent_projects"></tbody>
									</table>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
<!-- /メインコンテンツ -->
<!-- [begin] Modal. -->
<div id="view_body_modal" class="modal fade modal-sm"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#view_body_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="view_body_modal_title">メール確認</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				{% if env.limit.SHOW_HELP and query.type_recipient == "forWorker" or query.type_recipient == "forMatching" %}<p class="text-danger">Toに表示される宛先列は、選択された宛先のうち、先頭の取引先のみです。</p>{% endif %}
				<div class="input-group">
					<span class="input-group-addon">To</span>
					<span><textarea class="form-control mono" id="confirm_recipient_to" style="height: 2.2em; overflow-y: hidden; resize: none;" readOnly="readOnly"></textarea></span>
					<span class="input-group-addon pseudo-link-cursor"
						onclick="hdlClickConfirmRecipientExpandBtn('to');">
						<span class="glyphicon glyphicon-plus" id="confirm_recipient_to_expand_btn"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">Reply-to</span>
					<span><textarea class="form-control mono" id="confirm_reply_to_addr" style="height: 2.2em; overflow-y: hidden; resize: none;" readOnly="readOnly"></textarea></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">Cc</span>
					<span><textarea class="form-control mono" id="confirm_recipient_cc" style="height: 2.2em; overflow-y: hidden; resize: none;" readOnly="readOnly"></textarea></span>
					<span class="input-group-addon pseudo-link-cursor"
						onclick="hdlClickConfirmRecipientExpandBtn('cc');">
						<span class="glyphicon glyphicon-plus" id="confirm_recipient_cc_expand_btn"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">Bcc</span>
					<span><textarea class="form-control mono" id="confirm_recipient_bcc" style="height: 2.2em; overflow-y: hidden; resize: none;" readOnly="readOnly"></textarea></span>
					<span class="input-group-addon pseudo-link-cursor"
						onclick="hdlClickConfirmRecipientExpandBtn('bcc');">
						<span class="glyphicon glyphicon-plus" id="confirm_recipient_bcc_expand_btn"></span>
					</span>
				</div>
				<label id="confirm_subject" style="margin: 0.5em 0; padding: 0 0.5em;"></label>
				<span><textarea id="confirm_body" style="width: 100%; height: 30em; overflow-x: hidden; overflow-y: auto; resize: none;" readOnly="readOnly"></textarea></span>
				<div class="input-group">
					<span class="input-group-addon">添付ファイル</span>
					<div class="form-control">
						<ul class="list-group" id="confirm_attachments" style="margin: 0; padding: 0;"></ul>
					</div>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" id="sendMail_btn"
					onclick="if (!this.disabled) {sendMailRequest(env.confirmedMailRequest);}">送信</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_address_modal" class="modal fade modal-sm"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_address_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_address_modal_title">アドレス追加</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="input_add_addr_target"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon">名前</span>
					<input type="text" class="form-control" id="input_add_addr_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">メールアドレス<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_add_addr_mail"/>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" id="input_account_btn"
					onclick="addAddr($('#input_add_addr_target').val());">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<!-- [begin] Modal. -->
<div id="search_recipient_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#search_recipient_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="search_recipient_modal_title"></span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<h4>検索条件</h4>
				<div id="modal_search_container_worker" style="overflow: hidden;">
					<ul style="padding: 0; background-color: #ebebeb; list-style-type: none; overflow: hidden;">
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_client_name">取引先名</label>
							<input type="text" id="modal_search_client_name"/>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_worker_name">取引先担当者名</label>
							<input type="text" id="modal_search_worker_name"/>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_charging_worker">営業担当</label>
							<select id="modal_search_charging_worker">
								<option value=""></option>
							{% for user in data['manage.enumAccounts']|selectattr("is_enabled") %}
								<option value="{{ user.id }}">{{ user.name|e }}</option>
							{% endfor %}
							</select>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_type_dealing">取引区分</label>
							<select id="modal_search_type_dealing">
								<option value="">すべて</option>
								<option value="重要客">重要客</option>
								<option value="通常客">通常客</option>
								<option value="低ポテンシャル">低ポテンシャル</option>
								<option value="取引停止">取引停止</option>
							</select>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_type_presentation">提案区分</label>
							<select id="modal_search_type_presentation">
								<option value="">すべて</option>
								<option value="案件">案件（保有企業）</option>
								<option value="人材">人材（保有企業）</option>
								<option value="案件・人材">案件・人材（保有企業）</option>
							</select>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_note">備考</label>
							<input type="text" id="modal_search_worker_note"/>
						</li>
					</ul>
					<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0 0.5em; float: left;">
							<button class="btn btn-primary"
								onclick="renderRecipientModalTable('worker', filterRecipientDatum('worker'));">絞り込み</button>
						</li>
						<li style="margin: 0; float: left;">
							<button class="btn btn-primary"
								onclick="hdlClickAddRecipientBtnOnEdit($('#modal_search_container_worker').css('display') === 'block' ? 'worker' : 'engineer');">まとめて追加</button>
						</li>
					</ul>
				</div><!-- 絞り込み条件（取引先担当者） -->
				<div id="modal_search_container_engineer" style="overflow: hidden;">
					<ul style="padding: 0; background-color: #ebebeb; list-style-type: none; overflow: hidden;">
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_engineer_name">技術者名</label>
							<input type="text" id="modal_search_engineer_name"/>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_skill">スキル</label>
							<input type="text" id="modal_search_skill"/>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_contract">所属</label>
							<select id="modal_search_contract">
								<option value="">すべて</option>
								<option value="正社員">正社員</option>
								<option value="契約社員">契約社員</option>
								<option value="個人事業主">個人事業主</option>
								<option value="パートナー正社員">パートナー正社員</option>
								<option value="パートナー契約社員">パートナー契約社員</option>
								<option value="パートナー個人事業主">パートナー個人事業主</option>
							</select>
						</li>
						<li style="margin: 3px 5px; float: left;">
							<label for="modal_search_engineer_note">備考</label>
							<input type="text" id="modal_search_engineer_note"/>
						</li>
					</ul>
					<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0 0.5em; float: left;">
							<button type="button" class="btn btn-primary"
								onclick="renderRecipientModalTable('engineer', filterRecipientDatum('engineer'));">絞り込み</button>
						</li>
						<li style="margin: 0; float: left;">
							<button type="button" class="btn btn-primary"
								onclick="hdlClickAddRecipientBtnOnEdit($('#modal_search_container_worker').css('display') === 'block' ? 'worker' : 'engineer');">まとめて追加</button>
						</li>
					</ul>
				</div><!-- 絞り込み条件（技術者） -->
				<div>
					<h4>検索結果 <span id="row_count" class="badge"></span></h4>
					<table class="view_table table-bordered table-hover"
						id="modal_search_result_worker"
						style="display: none;">
						<thead>
							<tr>
								<th style="width: 25px;">
									<input type="checkbox"
										onclick="c4s.toggleSelectAll('recipient_iter_worker_', this);"/>
								</th>
								<th>取引先名</th>
								<th>取引先担当者名</th>
								<th>メールアドレス</th>
								<th>営業担当</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
					<table class="view_table table-bordered table-hover"
						id="modal_search_result_engineer"
						style="display: none;">
						<thead>
							<tr>
								<th style="width: 25px;">
									<input type="checkbox"
										onclick="c4s.toggleSelectAll('recipient_iter_engineer_', this);"/>
								</th>
								<th>技術者名</th>
								<th>単価</th>
								<th>スキル</th>
								<th>状態</th>
								<th>メールアドレス</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div><!-- 絞り込み結果-->
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" id="input_account_btn"
					onclick="hdlClickAddRecipientBtnOnEdit($('#modal_search_container_worker').css('display') === 'block' ? 'worker' : 'engineer');">まとめて追加</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
{% include "cmn_cap_mail_per_month.tpl" %}
<!-- [end] Modal. -->

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
        <script type="text/javascript">
            replaceJsonFunc = function(s){
                s = s.replace(/\\n/g, "\\n")
                .replace(/\\'/g, "\\'")
                .replace(/\\"/g, '\\"')
                .replace(/\\&/g, "\\&")
                .replace(/\\r/g, "\\r")
                .replace(/\\t/g, "\\t")
                .replace(/\\b/g, "\\b")
                .replace(/\\f/g, "\\f");

                // remove non-printable and other non-valid JSON chars
                s = s.replace(/[\u0000-\u0019]+/g,"");

                return s;
            }

            enumAccountsStr ="{{ data['manage.enumAccounts'] }}";
            enumAccountsStr = enumAccountsStr
                .replace(/: u/g, ': ')
                .replace(/True/gi, 'true')
                .replace(/False/gi, 'false')
                .replace(/None/gi, 'null')
                .replace(/\'/g, '\"');

            env.data = env.data || {};

            env.data.workers = JSON.parse(replaceJsonFunc('{{ data['js.workers']|tojson }}'));//client.enumWorkersCompact
{#            env.data.users = JSON.parse('{{ data['js.users']|tojson }}');;//manage.enumBpCompanyUsers#}
            env.data.members = JSON.parse(replaceJsonFunc('{{ data['manage.enumAccounts']|tojson }}'));//manage.enumAccounts
{#            env.data.engineers = JSON.parse('{{ data['js.engineers']|tojson }}');;//engineer.enumEngineers#}
            env.data.projects = JSON.parse(replaceJsonFunc('{{ data['js.projects']|tojson }}'));//project.enumProjectsCompact

        </script>
		<script type="text/javascript" src="/js/mail.js"></script>
	</body>
</html>
