{% import "cmn_controls.macro" as buttons %}
{% if "engineers" in query or "workers" in query %}
{% set tpl_types = ("取引先担当者", "取引先担当者（既定）") %}
{% elif "projects" in query %}
{% set tpl_types = ("技術者", "技術者（既定）") %}
{% endif %}
{% set title_types = ("様", "さん") %}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
<h1>DEPLICATED</h1>
{#
{% include "cmn_header.tpl" %}
#}
<!-- メインコンテンツ -->
			<div class="row">
				<div {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_content" style="margin-top: 1em;" {% else -%}class="container" style="margin-bottom:100px;"{% endif -%}>
					<!-- 宛先情報 -->
					<div class="row">
						<h3><img alt="メール" width="22" height="20" src="/img/icon/group_mail.png"> メール作成</h3>

						<div class="col-md-7">
							<h4>メール宛先情報</h4>
							<p>{% if "engineers" in query or "workers" in query %}取引先{% elif "projects" in query %}技術者{% endif %}宛にメールを送付します。</p>
							<div class="input-group">
								<span class="input-group-addon">宛先</span>
								<input type="text" class="form-control mono" id="input_0_toList" readOnly="readOnly"/>
							</div>
							<div class="input-group">
								<span class="input-group-addon">CC</span>
								<input type="text" class="form-control" id="input_0_cc" readOnly="readOnly"/>
								<span class="input-group-btn"><button class="btn btn-default"
									onclick="$('#input_add_addr_target').val('#input_0_cc');$('#edit_address_modal').modal('show');"><span class="glyphicon glyphicon-plus text-success"></span></button></span>
							</div>
							<div class="input-group">
								<span class="input-group-addon">BCC</span>
								<input type="text" class="form-control" id="input_0_bcc" readOnly="readOnly"/>
								<span class="input-group-btn"><button class="btn btn-default"
									onclick="$('#input_add_addr_target').val('#input_0_bcc');$('#edit_address_modal').modal('show');"><span class="glyphicon glyphicon-plus text-success"></span></button></span>
							</div>
						</div>
						<div class="col-md-5">
						{% if "engineers" in query or "workers" in query %}
							<h5>宛先取引先担当者</h5>
							<table class="view_table table-bordered table-hover">
								<thead>
									<tr>
										<th style="width: 25px;"></th>
										<th>取引先名</th>
										<th>担当者名</th>
										<th>メールアドレス</th>
									</tr>
								</thead>
								<tbody>
								{% for item in data['client.enumWorkers'] %}
									{% if item.flg_sendmail %}
									<tr>
										<td class="center">
											<input type="checkbox"
												id="iter_worker_{{ item.id }}"
												{% if item.mail1 == "" and item.mail2 == "" %}
												disabled="disabled"
												{% endif %}
												{% if ("workers" in query and item.id in query.workers) or ("recipient_type" in query and query.recipient_type == "workers" and "recipients" in query and item.id in query.recipients) %}
												checked="checked"
												{% endif %}/>
										</td>
										<td>{{ item.client_name }}</td>
										<td>{{ item.name }}</td>
										<td>{{ item.mail1 }}<br/>{{ item.mail2 }}</td>
									</tr>
									{% endif %}
								{% endfor %}
								</tbody>
							</table>
						{% elif "projects" in query %}
							<h5>宛先技術者</h5>
							<table class="view_table table-bordered table-hover">
								<thead>
									<tr>
										<th style="width: 25px;"></th>
										<th>技術者名</th>
										<th>単価</th>
										<th>スキル</th>
									</tr>
								</thead>
								<tbody>
								{% for item in data['engineer.enumEngineers'] %}
									<tr>
										<td class="center">
											<input type="checkbox"
												id="iter_engineer_{{ item.id }}"
												{% if (item.id in query.engineers) or ("recipient_type" in query and query.recipient_type == "engineers" and "recipients" in query and item.id in query.recipients) %}
												checked="checked"
												{% endif %}/>
										</td>
										<td>{{ item.name }}</td>
										<td class="center">{{ item.fee_comma }}</td>
										<td>
										{% if item.skill|length > 15 %}
											<span class="popover-dismiss"
												data-toggle="popover"
												data-placement="top"
												data-content="{{ item.skill }}"
												onmouseover="$(this).popover('show');"
												onmouseout="$(this).popover('hide');">{{ item.skill|truncate(20, True) }}</span>
										{% else %}
											{{ item.skill }}
										{% endif %}
										</td>
									</tr>
								{% endfor %}
								</tbody>
							</table>
						{% endif %}
					</div>
				</div>
				<!-- 宛先情報（ここまで） -->
				<div class="row">
					<hr/>
				</div>
				<!-- 本文情報 -->
				<div class="row">
					<div class="col-md-7">
						<h4>メール内容情報</h4>
						<ul class="nav nav-tabs" role="tablist">
						{% for item in data['mail.enumTemplates']|sort(attribute="type")|reverse %}
							<li{% if loop.index == 1 %} class="active"{% endif %}>
								<a href="#tplview_{{ item.id }}" role="tab" data-toggle="tab">{{ item.name }}</a>
							</li>
						{% endfor %}
						</ul>
						<div class="tab-content">
						{% for item in data['mail.enumTemplates']|sort(attribute="type")|reverse %}
							{% set tpl_id = item.id %}
							{% set attachments = item.attachments %}
							<div class="tab-pane fade in{% if loop.index == 1 %} active{% endif %}" id="tplview_{{ tpl_id }}">
								<input type="hidden" id="input_0_tpl_id_{{ loop.index }}" value="{{ tpl_id }}"/>
								<div class="input-group">
									<span class="input-group-addon">敬称</span>
									<ul class="form-control" style="list-style-type: none;">
								{% for title in title_types %}
										<li>
											<input type="radio" name="input_0_type_title_{{ tpl_id }}" id="input_0_type_title_{{ tpl_id }}_{{ loop.index }}" value="{{ title }}"{% if loop.index0 == 0 %} checked="checked"{% endif %}/><label for="input_0_type_title_{{ tpl_id }}_{{ loop.index }}">{{ title }}</label>
										</li>
								{% endfor %}
									</ul>
								</div>
								<div class="input-group">
									<span class="input-group-addon">件名</span>
									<input type="text" class="form-control" id="input_0_subject_{{ loop.index }}" value="{{ item.subject }}"/>
								</div>
								<div class="input-group">
									<span class="input-group-addon">本文</span>
									<div class="form-control">
										<textarea class="form-control" id="input_0_body_{{ loop.index }}" style="height: 30em;">{{ item.body }}</textarea>
										<span class="pull-right">
											<button class="popover-dismiss btn btn-default bold"
												id="input_0_refresh_btn_{{ loop.index }}"
												data-toggle="popover"
												data-placement="top"
												data-content="データをテンプレートに再反映させ、編集内容をクリアします。"
												onmouseover="$(this).popover('show');"
												onmouseout="$(this).popover('hide');"
												onclick="refreshMailBody({ template_id:{{ tpl_id }}, type_title: ($('#input_0_type_title_{{ tpl_id }}_{{ loop.index }}')[0].checked ? '様' : 'さん'), type_data: (env.recentQuery.engineers ? 'engineers' : 'projects'), body_id: 'input_0_body_{{ loop.index }}'});">
												<span class="glyphicon glyphicon-refresh text-success"></span>&nbsp;リフレッシュ
											</button>
										</span>
									</div>
								</div>
								<div class="input-group">
									<span class="input-group-addon">添付ファイル</span>
									<ul class="form-control list-group">
									{% for idx in range(0, env.limit.LMT_LEN_MAIL_ATTACHMENT, 1) %}
										{% if idx < attachments|length %}
										{% set attachment = attachments[idx] %}
										{% else %}
										{% set attachment = None %}
										{% endif %}
										<li class="list-group-item">
											<input type="hidden" id="attachment_id_{{ tpl_id }}_{{ idx }}" value="{% if attachment %}{{ attachment.id }}{% endif %}"/>
											<label id="attachment_label_{{ tpl_id }}_{{ idx }}"
												class="bold mono pseudo-link"
												onclick="download({{ attachment.id }});">{% if attachment %}{{ attachment.name }}&nbsp;({{ attachment.size }}bytes){% endif %}</label>
											</span>
											<input type="file" id="attachment_file_{{ tpl_id }}_{{ idx }}"
												style="display: none;"
												onclick="uploadFile('#attachment_file_{{ tpl_id }}_{{ idx }}', '#attachment_id_{{ tpl_id }}_{{ idx }}', '#attachment_label_{{ tpl_id }}_{{ idx }}');"/><br/>
											<button class="btn btn-default"
												id="attachment_btn_delete_{{ tpl_id }}_{{ idx }}"
												style="{%if not attachment %}display: none;{% endif %}"
												onclick="deleteAttachment({{ tpl_id }}, {{ idx }});"><span class="glyphicon glyphicon-trash text-danger"></span>&nbsp;削除</button>
											<button class="btn btn-default"
												id="attachment_btn_commit_{{ tpl_id }}_{{ idx }}"
												onclick="deleteAttachment({{ tpl_id }}, {{ idx }});"><span class="glyphicon glyphicon-refresh text-success"></span>&nbsp;更新</button>
										</li>
									{% endfor %}
									</ul>
								</div>
								<hr/>
								<div style="height: 2em;">
									{#
									<button class="popover-dismiss btn btn-default bold"
										data-toggle="popover"
										data-placement="top"
										data-content="データをテンプレートに再反映させ、編集内容をクリアします。"
										onmouseover="$(this).popover('show');"
										onmouseout="$(this).popover('hide');"
										onclick=""><span class="glyphicon glyphicon-refresh text-success"></span>&nbsp;リフレッシュ</button>
									#}
									<button class="pull-right popover-dismiss btn btn-primary bold"
										data-toggle="popover"
										data-placement="top"
										data-content="送信先と送信内容を確認してから、送信を確定します。"
										onmouseover="$(this).popover('show');"
										onmouseout="$(this).popover('hide');"
										onclick="confirmBody({template_id: {{ tpl_id }}, template_type: '{{ item.type }}', type_title: ($('#input_0_type_title_{{ tpl_id }}_{{ loop.index }}')[0].checked ? '様' : 'さん'), subject: $('#input_0_subject_{{ loop.index }}').val(), body_id: '#input_0_body_{{ loop.index }}', attachment_id: [{% for idx in range(0, env.limit.LMT_LEN_MAIL_ATTACHMENT, 1) %}'#attachment_id_{{ tpl_id }}_{{ idx }}', {% endfor %}]});"><span class="glyphicon glyphicon-ok"></span>&nbsp;確認</button>
								</div>
							</div>
						{% endfor %}
						</div>
					</div><!-- templating fields -->

					<div class="col-md-5">
					{% if "engineers" in query or "workers" in query %}
					<h5>
						技術者
						<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
						data-toggle="popover"
						data-placement="bottom"
						data-content="メール本文に挿入する技術者を選定します。"
						onmouseover="$(this).popover('show');"
						onmouseout="$(this).popover('hide');"></span></h5>
					<table class="view_table table-bordered table-hover">
						<thead>
							<tr>
								<th style="width: 25px;"></th>
								<th>技術者名</th>
								<th>単価</th>
								<th>スキル</th>
							</tr>
						</thead>
						<tbody>
						{% for item in data['engineer.enumEngineers'] %}
							<tr>
								<td class="center">
									<input type="checkbox" id="iter_engineer_{{ item.id }}"{% if item.id in query.engineers %} checked="checked"{% endif %}/>
								</td>
								<td>{{ item.name }}</td>
								<td class="center">{{ item.fee_comma }}</td>
								<td>
								{% if item.skill|length > 15 %}
									<span class="popover-dismiss"
										data-toggle="popover"
										data-content="{{ item.skill }}"
										onmouseover="$(this).popover('show');"
										onmouseout="$(this).popover('hide');">{{ item.skill|truncate(15, True) }}</span>
								{% else %}
									{{ item.skill }}
								{% endif %}
								</td>
							</tr>
						{% endfor %}
						</tbody>
					</table>
					{% elif "projects" in query %}
					<h5>
						案件
						<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
						data-toggle="popover"
						data-placement="bottom"
						data-content="メール本文に挿入する案件を選定します。"
						onmouseover="$(this).popover('show');"
						onmouseout="$(this).popover('hide');"></span></h5>
					<table class="view_table table-bordered table-hover">
						<thead>
							<tr>
								<th style="width: 25px;"></th>
								<th>取引先/案件名</th>
								<th>単価</th>
								<th>期間</th>
								<th>スキル</th>
							</tr>
						</thead>
						<tbody>
						{% for item in data['project.enumProjects'] %}
							{% if item.is_enabled %}
							<tr>
								<td class="center">
									<input type="checkbox" id="iter_project_{{ item.id }}"{% if item.id in query.projects %} checked="checked"{% endif %}/>
								</td>
								<td>
								{% if item.client.id == None %}
									{{ item.client_name }}
								{% else %}
									<span class="pseudo-link"
										data-container="body"
										data-toggle="popover"
										data-placement="top"
										data-content=""
										onmouseover="/*$(this).popover('show');*/"
										onmouseout="/*$(this).popover('hide');*/">{{ item.client.name }}</span>
								{% endif %}／<br/>{{ item.title }}
								</td>
								<td><span class="bold">請求：</span>{{ item.fee_inbound_comma }}<br/><span class="bold">支払：</span>{{ item.fee_outbound_comma }}</td>
								<td>{{ item.term }}</td>
								<td class="center">
								{% if item.skill_needs %}
									<span class="badge pseudo-link-cursor"
										data-container="body"
										data-toggle="popover"
										data-placement="left"
										data-content="{{ item.skill_needs }}"
										onmouseover="$(this).popover('show');"
										onmouseout="$(this).popover('hide');">必須</span>
								{% endif %}
								{% if item.skill_recommends %}
									<span class="badge pseudo-link-cursor"
										data-container="body"
										data-toggle="popover"
										data-placement="left"
										data-content="{{ item.skill_recommends }}"
										onmouseover="$(this).popover('show');"
										onmouseout="$(this).popover('hide');">推奨</span>
								{% endif %}
								</td>
							</tr>
							{% endif %}
						{% endfor %}
						</tbody>
					</table>
					{% endif %}
				</div>
				<!-- 本文情報（ここまで） -->
			</div>
<!-- /メインコンテンツ -->
<!-- [begin] Modal. -->
<div id="view_body_modal" class="modal fade modal-sm"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#view_body_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="view_body_modal_title">メール本文</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<textarea id="body_confirm_ta" style="width: 100%; height: 30em;"></textarea>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary"
					onclick="sendMailRequest(env.confirmedMailRequest);">送信</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_address_modal" class="modal fade modal-sm"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
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
<!-- [end] Modal. -->

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script type="text/javascript" src="/js/mail.js"></script>
		<script type="text/javascript">
$(document).ready(function () {
	env.data = {};
	env.data.workers = JSON.parse('{{ data['client.enumWorkers']|tojson }}');
	{#
	env.data.projects = JSON.parse('{{ data['project.enumProjects']|tojson }}');
	env.data.engineers = JSON.parse('{{ data['engineer.enumEngineers']|tojson }}');
	#}
	$("#input_0_refresh_btn_1").trigger("click");
	c4s.invokeApi_ex({
		location: "engineer.enumEngineers",
		body: {},
		onSuccess: function(data) {
			env.data.engineers = data.data;
		},
	});
});
		</script>
	</body>
</html>