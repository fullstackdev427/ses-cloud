{% import "cmn_controls.macro" as buttons -%}
{% set presentations = (("案件", "案件（保有企業）"), ("人材", "人材（保有企業）"), ("案件・人材", "案件・人材（保有企業）")) -%}
{% set dealings = ("重要客", "通常客", "低ポテンシャル", "取引停止") -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
{% include "cmn_header.tpl" %}
<!-- メインコンテンツ -->
{% if "iPhone" in env.UA or "Android" in env.UA -%}
	<div class="sp_content">
		<!-- 検索フォーム -->
		<div class="row" style="margin-top: 1em;">
			<img alt="取引先担当者" width="22" height="20" src="/img/icon/group_person.png" /> 取引先担当者 一覧
		</div>
		<div id="search-form-accordion" class="row list-group" style="/*background-color: #f1f1f1;*/">
			<a data-toggle="collapse" data-parent="#search-form-accordion" href="#search-form" class="list-group-item">
				<span class="bold list-header">検索条件:</span>
				<ol class="breadcrumb" style="padding: 0px; margin: 0px;">
					{%if query.client_name %}<li>取引先名"{{ query.client_name|e }}"</li>{% endif %}
					{%if query.name %}<li>取引先担当者名"{{ query.name|e }}"</li>{% endif %}
					{%if query.charging_user_id %}<li>営業担当"
						{% for item in data['manage.enumAccounts'] %}
							{% if item.is_enabled == True and query.charging_user_id == item.id|string %}
							 {{ item.name|e }}
							{% endif %}
						{% endfor %}"</li>
					{% endif %}
					{%if query.type_presentation %}<li>提案区分"{{ query.type_presentation }}"</li>{% endif %}
					{%if query.type_dealing %}<li>取引区分"{{ query.type_dealing }}"</li>{% endif %}
					{%if query.note %}<li>備考"{{ query.note|e }}"</li>{% endif %}
				</ol>
			</a>
			<form onsubmit="c4s.hdlClickSearchBtn(); return false;" id="search-form" class="collapse">
				<!--input type="submit" style="display: none;"/-->
				<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
					<li style="margin: 1px 2em; float: left;">
						<label for="query_client_name" style="color: #666666; width: 8em;">取引先名</label>
						<input type="text" id="query_client_name"{% if query.client_name %} value="{{ query.client_name|e }}"{% endif %}/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_name" style="color: #666666; width: 8em;">取引先担当者名</label>
						<input type="text" id="query_name"{% if query.name %} value="{{ query.name|e }}"{% endif %}/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_charging_user_id" style="color: #666666; width: 8em;">営業担当</label>
						<select class="form01_1_" id="query_charging_user_id">
							<option>すべて</option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
							<option value="{{ item.id }}"{% if item.id|string == query.charging_user_id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
							{% endfor %}
						</select>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_type_presentation" style="color: #666666; width: 8em;">提案区分</label>
						<select class="" id="query_type_presentation">
							<option>すべて</option>
						{% for item, detail in presentations %}
							<option value="{{ item }}"{% if "type_presentation" in query and query['type_presentation'] == item %} selected="selected"{% endif %}>{{ detail }}</option>
						{% endfor %}
						</select>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_type_dealing" style="color: #666666; width: 8em;">取引区分</label>
						<select class="" id="query_type_dealing">
							<option>すべて</option>
							{% for item in dealings %}
							<option value="{{ item }}"{% if item == query.type_dealing %} selected="selected"{% endif %}>{{ item }}</option>
							{% endfor %}
						</select>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_note" style="color: #666666; width: 8em;">備考</label>
						<input type="text" class="" id="query_note" value="{{ query.value|e }}"/>
					</li>
				</ul>
				<div style="margin-top: 1em; text-align:right;">
					{{ buttons.search("c4s.hdlClickSearchBtn();") }}
					{{ buttons.clear("c4s.hdlClickGnaviBtn(env.current);") }}
				</div>
			</form>
		</div>
		<!-- /検索フォーム -->
		<!-- 検索結果ヘッダー -->
		<div class="row" style="margin-top:20px;margin-bottom:20px;">
			<div class="col-lg-7">
				{{ buttons.new_obj("overwriteWorkerModalForEdit();") }}
			{% if env.limit.LMT_ACT_MAIL -%}
				{{ buttons.mail_all("triggerMailOnWorker();") }}
			{% endif -%}
				{{ buttons.delete_checked("deleteItems();") }}
			</div>
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['client.enumWorkers']) }}
			<!-- /件数 -->
		</div>
		<!-- /検索結果ヘッダー -->
		<!-- 検索結果 -->
		<div class="row table-responsive" >
			<table class="table view_table table-bordered table-hover">
				<thead>
					<tr>
						<th style="width: 35px;">選択<br/><input type="checkbox" id="iter_worker_selected_cb_0" onclick="c4s.toggleSelectAll('iter_worker_selected_cb_', this);"/></th>
						<th style="width: 35px;"></th>
						<th style="width: auto;">
							{{ buttons.th(query, '取引先担当者名', 'kana') }}
						</th>
						<th style="width: auto;">
							{{ buttons.th(query, '取引先名', 'client_name') }}
						</th>
					</tr>
				</thead>
				<tbody>
				{% if data['client.enumWorkers'] %}
					{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
					{% set items = data['client.enumWorkers'][row_min:row_min + env.limit.ROW_LENGTH] %}
					{% for item in items %}
					<tr id="iter_worker_{{ item.id }}">
						<td class="center"><input type="checkbox" id="iter_worker_selected_cb_{{ item.id }}"/></td>
						<td class="center">
							{% if item.tel %}
								<a href="tel:{{ item.tel|replace('-', '')|e }}"><span class="glyphicon glyphicon-earphone"></span></a>
							{% elif item.tel2 or item.client_tel %}
								<a href="tel:{{ (item.tel2 or item.client_tel)|replace('-', '')|e }}"><span class="glyphicon glyphicon-phone-alt"></span></a>
							{% endif %}
						</td>
						<td>
							<span class="pseudo-link" title="{{ item.kana|e }}"
								onclick="overwriteWorkerModalForEdit({{ item.id }});">
								{{ item.name|e }}
							</span>
						</td>
						<td>
							<span class="pseudo-link"
								onclick="overwriteClientModalForEdit({{ item.client_id }});">{{ item.client_name|truncate(12, True)|e }}</span>
						</td>
					</tr>
					{% endfor %}
				{% else %}
					<tr id="iter_worker_0">
						<td colspan="4">有効なデータがありません</td>
					</tr>
				{% endif %}
				</tbody>
			</table>
		</div>
		<!-- /検索結果 -->
		<div class="row" style="margin-top: 0.5em;">
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['client.enumWorkers']) }}
			<!-- /件数 -->
		</div>
	</div>
{% else -%}
	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
				<img alt="取引先担当者" width="22" height="20" src="/img/icon/group_person.png" /> 取引先担当者 一覧
			</div>
			<div class="row" style="/*background-color: #f1f1f1;*/">
				<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
					<!--input type="submit" style="display: none;"/-->
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
						<li style="margin: 0 2em; float: left;">
							<label for="query_client_name" style="color: #666666;">取引先名</label>
							<input type="text" id="query_client_name"{% if query.client_name %} value="{{ query.client_name|e }}"{% endif %}/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_name" style="color: #666666;">取引先担当者名</label>
							<input type="text" id="query_name"{% if query.name %} value="{{ query.name|e }}"{% endif %}/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_charging_user_id" style="color: #666666;">営業担当</label>
							<select class="form01_1_" id="query_charging_user_id">
								<option>すべて</option>
								{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}"{% if item.id|string == query.charging_user_id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
								{% endfor %}
							</select>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_type_presentation" style="color: #666666;">提案区分</label>
							<select class="" id="query_type_presentation">
								<option>すべて</option>
							{% for item, detail in presentations %}
								<option value="{{ item }}"{% if "type_presentation" in query and query['type_presentation'] == item %} selected="selected"{% endif %}>{{ detail }}</option>
							{% endfor %}
							</select>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_type_dealing" style="color: #666666;">取引区分</label>
							<select class="" id="query_type_dealing">
								<option>すべて</option>
								{% for item in dealings %}
								<option value="{{ item }}"{% if item == query.type_dealing %} selected="selected"{% endif %}>{{ item }}</option>
								{% endfor %}
							</select>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_note" style="color: #666666;">備考</label>
							<input type="text" class="" id="query_note" value="{{ query.note|e }}"/>
						</li>
					</ul>
					<div style="margin-top: 1em; text-align:right;">
						{{ buttons.search("c4s.hdlClickSearchBtn();") }}
						{{ buttons.clear("c4s.hdlClickGnaviBtn(env.current);") }}
					</div>
				</form>
			</div>

			<!-- /検索フォーム -->
			<!-- 検索結果ヘッダー -->
			<div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-7">
					{{ buttons.new_obj("overwriteWorkerModalForEdit();") }}
				{% if env.limit.LMT_ACT_MAIL -%}
					{{ buttons.mail_all("triggerMailOnWorker();") }}
				{% endif -%}
					{{ buttons.delete_checked("deleteItems();") }}
				</div>
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['client.enumWorkers']) }}
				<!-- /件数 -->
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class="row" >
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 35px;">選択<br/><input type="checkbox" id="iter_worker_selected_cb_0" onclick="c4s.toggleSelectAll('iter_worker_selected_cb_', this);"/></th>
							<th style="width: 50px;">フラグ</th>
							<th style="width: auto;">
								{{ buttons.th(query, '取引先担当者名', 'kana') }}
							</th>
							<th style="width: auto;">
								{{ buttons.th(query, '取引先名', 'client_name') }}
							</th>
							<th style="width: 35px;">Web</th>
							<th style="width: 120px;">携帯番号</th>
							<th style="width: 120px;">代表電話番号</th>
							{# <!-- mantis ID:0000104 取引先担当者の営業担当フィールドを使用しない -->
							<th style="width: 110px;">
								{{ buttons.th(query, '営業担当', 'charging_user') }}</th> #}
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
					{% if data['client.enumWorkers'] %}
						{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
						{% set items = data['client.enumWorkers'][row_min:row_min + env.limit.ROW_LENGTH] %}
						{% for item in items %}
						<tr id="iter_worker_{{ item.id }}">
							<td class="center"><input type="checkbox" id="iter_worker_selected_cb_{{ item.id }}"/></td>
							<td class="center">
								<img src="/img/icon/key_man.jpg"{% if item.flg_keyperson %} title="キーマン"{% else %} style="visibility: hidden;"{% endif %}/>
							{% if env.limit.LMT_ACT_MAIL -%}
								<span class="glyphicon glyphicon-envelope text-warning pseudo-link-cursor"{% if item.flg_sendmail %} title="メール送信可" onclick='triggerMailOnWorker([{{ item.id }}]);'{% else %} style="visibility: hidden;"{% endif %}></span>
							{% else -%}
								<span class="glyphicon glyphicon-envelope text-warning"{% if item.flg_sendmail %} title="メール送信可"{% else %} style="visibility: hidden;"{% endif %}></span>
							{% endif -%}
							</td>
							<td>
								<span class="pseudo-link" title="{{ item.kana|e }}"
									onclick="overwriteWorkerModalForEdit({{ item.id }});">
									{{ item.name|e }}
								</span>
							</td>
							<td>
								<span class="pseudo-link"
									onclick="overwriteClientModalForEdit({{ item.client_id }});">{{ item.client_name|truncate(12, True) }}</span>
							</td>
							<td class="center">{% if item.client_site|e %}<a href="{{ item.client_site|e }}" target="_blank"><span class="glyphicon glyphicon-globe text-primary"></span></a>{% endif %}</td>
							<td class="center">{% if item.tel %}<a href="tel:{{ item.tel|replace('-', '')|e }}">{{ item.tel|e }}</a>{% endif %}</td>
							{% set tel2 = item.tel2 or item.client_tel %}
							<td class="center">{% if tel2 %}<a href="tel:{{ tel2|replace('-', '')|e }}">{{ tel2|e }}</a>{% endif %}</td>
							{# <!-- mantis ID:0000104 取引先担当者の営業担当フィールドを使用しない -->
							<td class="center">
							{% if item.charging_user %}
								{% if item.charging_user.is_enabled == False %}
								<span class="glyphicon glyphicon-ban-circle text-danger" title="無効化されたユーザーです"></span>&nbsp;
								{% endif %}
								<span title="{{ item.charging_user.login_id }}">{{ item.charging_user.user_name }}</span>
							{% endif %}
							</td> #}
							<td class="center">
								<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor"
									title="削除"
									onclick="c4s.hdlClickDeleteItem('worker', {{ item.id }}, true);"></span>
								<!--
								<span class="glyphicon glyphicon-pencil text-success pseudo-link-cursor"
									title="編集"
									onclick=""></span>
								-->
							</td>
						</tr>
						{% endfor %}
					{% else %}
						<tr id="iter_worker_0">
							<td colspan="9">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
			<div class="row" style="margin-top: 0.5em;">
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['client.enumWorkers']) }}
				<!-- /件数 -->
			</div>
		</div>
	</div>
{% endif -%}
<!-- /メインコンテンツ -->

<!-- [begin] Modal. -->
<!-- [begin] Modal for client worker instance -->
<div id="edit_worker_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="($('#m_worker_id').val() ? updateObj : createObj)();">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_worker_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_worker_modal_title">新規取引先担当者登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_worker_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="form-group">
					<div class="input-group">
						<span class="input-group-addon">取引先担当者名<span class="text-danger">*</span></span>
						<input class="form-control" type="text" id="m_worker_name"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">取引先担当者名（カナ）<span class="text-danger">*</span></span>
						<input class="form-control" type="text" id="m_worker_kana"/>
					</div>
					{#  <!-- mantis ID:0000104 取引先担当者の営業担当フィールドを使用しない -->
					<div class="input-group">
						<span class="input-group-addon">営業担当</span>
						<select class="" id="m_worker_charging_user_login_id">
							<option></option>
							{% for item in data['manage.enumAccounts'] %}
							{% if item.is_enabled == True %}
							<option value="{{ item.login_id }}">{{ item.name }}</option>
							{% endif %}
							{% endfor %}
						</select>
					</div>
					#}
				</div>
				<div class="form-group">
					<h4>企業情報</h4>
					<div class="input-group">
						<span class="input-group-addon">取引先企業名</span>
						<input type="text" class="form-control" id="m_worker_client_name"/>
						<input type="hidden" id="m_worker_client_id"/>
						<span class="text-danger">*&nbsp;（新規登録時以外は変更できません）</span>
					</div>
					<ul style="padding-left: 0; list-style-type: none;">
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">部署</span>
								<input type="text" class="form-control" id="m_worker_section"/>
							</div>
						</li>
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">役職</span>
								<input type="text" class="form-control" id="m_worker_title"/>
							</div>
						</li>
					</ul>
				</div>
				<div class="form-group">
					<ul style="padding-left: 0; list-style-type: none;">
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">携帯電話番号</span>
								<input type="text" class="form-control" id="m_worker_tel"/>
							</div>
						</li>
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">代表電話番号</span>
								<input type="text" class="form-control" id="m_worker_tel2"/>
							</div>
						</li>
					</ul>
					<div class="input-group">
						<span class="input-group-addon">送信用メールアドレス</span>
						<input type="text" class="form-control" id="m_worker_mail1"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">サブ メールアドレス</span>
						<input type="text" class="form-control" id="m_worker_mail2"/>
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">その他</span>
					<div class="form-control" id="m_worker_misc_container">
						<ul class="" style="margin-bottom: 0; padding: 0; list-style-type: none; overflow: hidden;">
							<li style="margin: 0 1em; float: left;">
								<input type="checkbox" id="m_worker_flg_keyperson"/>
								<label for="m_worker_flg_keyperson">キーマン フラグ</label>
							</li>
							<li style="margin: 0 1em; float: left;">
								<input type="checkbox" id="m_worker_flg_sendmail"/>
								<label for="m_worker_flg_sendmail">メール送信フラグ</label>
							</li>
							<li style="margin: 0 1em; float: left;">
								<label for="m_worker_recipient_priority">メール送信時宛先表示優先度：</label>
								<input type="text" id="m_worker_recipient_priority" style="width: 2em; text-align: center;"/>
								<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
									data-toggle="popover"
									data-placement="bottom"
									data-html="true"
									data-content="メール送信の際に同一取引先の取引先担当者が複数選択されている際の宛名の表示順位を決定します。<br/>例：1　鈴木　太郎、2　田中　一の場合、<br/><br/>株式会社○○<br/>鈴木　太郎様<br/>田中　一様"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');"></span>
								{% if env.limit.SHOW_HELP %}
								<br/><span class="text-danger">1（最上位）～9（最下位）で優先度を入力してください</span>
								{% endif %}
							</li>
						</ul>
					</div>
				</div>
				<div class="input-group" style="width: 100%;">
					<span class="input-group-addon">備考</span>
					<textarea class="form-control" id="m_worker_note" style="height: 10em;"></textarea>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="($('#m_worker_id').val() ? updateObj : createObj)();">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<!-- [end] Modal for client worker instance -->
<div id="edit_client_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							id="m_client_branch_btn0"
							onclick="hdlClickAddBranchBtn($('#m_client_id').val());">支店を追加する</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							id="m_client_worker_btn0"
							onclick="hdlClickAddWorkerBtn($('#m_client_id').val());">取引先担当者を追加する</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="commitClient($('#m_client_id').val() !== '');">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_client_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
					<span id="edit_client_modal_title">新規取引先登録</span>
				</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_client_client_id"/>
				<input type="hidden" id="m_client_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon">取引先名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_client_name" readOnly="readOnly"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">取引先名（カナ）<span class="text-danger">*</span></span>
					<input type="test" class="form-control" id="m_client_kana" readOnly="readOnly"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">郵便番号</span>
					<input type="text" class="form-control" id="m_client_addr_vip" placeholder="nnn-nnnn" style="width: 8em;" maxlength="8"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#m_client_addr_vip').val(), '#m_client_addr1', '#m_client_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
					{% if env.limit.LMT_ACT_MAP -%}
					<span class="input-group-btn">
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
						<button class="btn btn-default"
							onclick="c4s.openMap({target_id: $('#m_client_id').val(), target_type: 'client', name: $('#m_client_name').val(), addr1: $('#m_client_addr1').val(), addr2: $('#m_client_addr2').val(), tel: $('#m_client_tel').val(), modalId: 'edit_client_modal', isFloodLMT: false, current: env.current});">
							<span class="glyphicon glyphicon-globe text-success"></span>
							{% if env.limit.SHOW_HELP %}&nbsp;地図を確認する{% endif %}
						</button>
						{% else -%}
						<button class="btn btn-default"
							onclick="c4s.openMap({isFloodLMT: true});">
							<span class="glyphicon glyphicon-globe text-muted"></span>
						</button>
						{% endif -%}
					</span>
					&nbsp;
					{% endif -%}
					<span class="text-danger" id="m_client_addr1_alert"></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">住所<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_client_addr1"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">ビル名</span>
					<input type="text" class="form-control" id="m_client_addr2"/>
				</div>
				<div class="form-group" style="margin-bottom: 0;">
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-phone-alt">&nbsp;代表電話番号</span>
						<input type="text" class="form-control" id="m_client_tel"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-print">&nbsp;代表FAX番号</span>
						<input type="text" class="form-control" id="m_client_fax"/>
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">サイトURL&nbsp;<span class="glyphicon glyphicon-globe text-primary"></span></span>
					<input class="form-control" type="text" id="m_client_site" placeholder="http://"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">提案区分<span class="text-danger">*</span></span>
					<div class="form-control" id="m_client_type_presentation_container">
						<input type="checkbox" id="m_client_type_presentation_0" value="案件"/>
						<label for="m_client_type_presentation_0">案件</label>
						<input type="checkbox" id="m_client_type_presentation_1" value="人材"/>
						<label for="m_client_type_presentation_1">人材</label>
						{% if env.limit.SHOW_HELP -%}&nbsp;<span class="text-danger">案件（保有企業）/人材（保有企業）</span>{% endif -%}
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">重要度</span>
					<select class="form-control" id="m_client_type_dealing">
						<option value="重要客">重要客</option>
						<option value="通常客" selected="selected">通常客</option>
						<option value="低ポテンシャル">低ポテンシャル</option>
						<option value="取引停止">取引停止</option>
					</select>
				</div>
				<div class="input-group">
					<span class="input-group-addon">自社担当営業</span>
						<div class="" style="width: 50%; float: left;">
							<label class="" for="m_client_charging_worker1">主担当：</label>
							<select class="form-control" id="m_client_charging_worker1">
							<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}"{% if data['auth.userProfile'].user.id == item.id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
						<div class="" style="width: 50%; float: left;">
							<label for ="m_client_charging_worker2">副担当：</label>
							<select class="form-control" id="m_client_charging_worker2">
								<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">備考</span>
					<textarea class="form-control" id="m_client_note" style="height: 10em;"></textarea>
				</div>
				<div class="input-group" style="width: 100%;" id="m_client_branch_container">
					<label class="" for="m_client_branch_table">支店</label>
					<table id="m_client_branch_table" class="view_table table-bordered table-hover" style="width: 100%;">
						<thead>
							<tr>
								<th style="width: 35px;">操作</th>
								<th>支店名</th>
								<th>住所</th>
								{% if env.limit.LMT_ACT_MAP -%}
									<th style="width: 35px;">Map</th>
								{% endif -%}
								<th style="width: 140px;"><span class="glyphicon glyphicon-phone-alt"></span>／<span class="glyphicon glyphicon-print"></span></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
				<div class="input-group" style="width: 100%;" id="m_client_worker_container">
					<label class="" for="m_client_branch_table">取引先担当者</label><br/>
					{% if env.limit.LMT_ACT_MAIL -%}
					{{ buttons.mail_all("triggerMailOnClientModal();") }}
					{% endif -%}
					<table id="m_client_worker_table" class="view_table table-bordered table-hover" style="width: 100%;">
						<thead>
							<tr>
								<th style="width: 25px;">
									<input type="checkbox"
										onclick="c4s.toggleSelectAll('iter_mailto_worker_', this);"/>
								</th>
								<th>名前</th><!-- section and title and name -->
								<th style="width: 130px;">携帯電話番号</th><!-- tel -->
								<th>メールアドレス</th><!-- mail1 and mail2 -->
{#								<th style="width: 85px;">自社担当営業</th><!-- charging_user -->#}
								<th style="width: 30px;"></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" id="m_client_branch_btn1"
					onclick="hdlClickAddBranchBtn($('#m_client_id').val());">支店を追加する</button>
				<button type="button" class="btn btn-primary" id="m_client_worker_btn1"
					onclick="hdlClickAddWorkerBtn($('#m_client_id').val());">取引先担当者を追加する</button>
				<button type="button" class="btn btn-primary"
					onclick="commitClient($('#m_client_id').val() !== '');">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_branch_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_branch_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">新規取引先支店登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_branch_id"/>
				<input type="hidden" id="m_branch_client_id"/>
				<div class="input-group">
					<span class="input-group-addon">取引先名</span>
					<input type="text" class="form-control" readOnly="readOnly" id="m_branch_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">支店名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_branch_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">郵便番号</span>
					<input type="text" class="form-control" id="m_branch_addr_vip" placeholder="nnn-nnnn" style="width: 8em;"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#m_branch_addr_vip').val(), '#m_branch_addr1', '#m_branch_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
					{% if env.limit.LMT_ACT_MAP -%}
					<span class="input-group-btn">
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
						<button class="btn btn-default"
							onclick="c4s.openMap({target_id: $('#m_branch_id').val(), target_type: 'branch', name: $('#m_branch_name').val(), addr1: $('#m_branch_addr1').val(), addr2: $('#m_branch_addr2').val(), tel: $('#m_branch_tel').val(), modalId: 'edit_branch_modal', isFloodLMT: false, current: env.current});">
							<span class="glyphicon glyphicon-globe text-success"></span>
							{% if env.limit.SHOW_HELP %}&nbsp;地図を確認する{% endif %}
						</button>
						{% else -%}
						<button class="btn btn-default"
							onclick="c4s.openMap({isFloodLMT: true});">
							<span class="glyphicon glyphicon-globe text-muted"></span>
						</button>
						{% endif -%}
					</span>
					&nbsp;
					{% endif -%}
					<span class="text-danger" id="m_branch_addr1_alert"></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">住所<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_branch_addr1" placeholder="住所"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">ビル名</span>
					<input type="text" class="form-control" id="m_branch_addr2" placeholder="ビル名"/>
				</div>
				<div class="form-group" style="margin-bottom: 0;">
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-phone-alt">&nbsp;代表電話番号</span>
						<input type="text" class="form-control" id="m_branch_tel"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-print">&nbsp;代表FAX番号</span>
						<input type="text" class="form-control" id="m_branch_fax"/>
					</div>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary"
					onclick="commitBranch($('#m_branch_id').val() !== '');">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_worker_modal_sub" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_worker_modal_sub').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_worker_modal_sub_title">新規取引先担当者登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="ms_client_id"/>
				<input type="hidden" id="ms_worker_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="form-group">
					<div class="input-group">
						<span class="input-group-addon">取引先担当者名<span class="text-danger">*</span></span>
						<input class="form-control" type="text" id="ms_worker_name"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">取引先担当者名（カナ）<span class="text-danger">*</span></span>
						<input class="form-control" type="text" id="ms_worker_kana"/>
					</div>
					{#  <!-- mantis ID:0000104 取引先担当者の営業担当フィールドを使用しない -->
					<div class="input-group">
						<span class="input-group-addon">営業担当</span>
						<select class="" id="ms_worker_charging_user_login_id">
							<option></option>
							{% for item in data['manage.enumAccounts'] %}
							{% if item.is_enabled == True %}
							<option value="{{ item.login_id }}">{{ item.name }}</option>
							{% endif %}
							{% endfor %}
						</select>
					</div>
					#}
				</div>
				<div class="form-group">
					<h4>企業情報</h4>
					<div class="input-group">
						<span class="input-group-addon">取引先企業名</span>
						<input type="text" class="form-control" id="ms_worker_client_name" readOnly="readOnly"/>
						<input type="hidden" id="ms_worker_client_id"/>
					</div>
					<ul style="padding-left: 0; list-style-type: none;">
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">部署</span>
								<input type="text" class="form-control" id="ms_worker_section"/>
							</div>
						</li>
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">役職</span>
								<input type="text" class="form-control" id="ms_worker_title"/>
							</div>
						</li>
					</ul>
				</div>
				<div class="form-group">
					<ul style="padding-left: 0; list-style-type: none;">
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">携帯電話番号</span>
								<input type="text" class="form-control" id="ms_worker_tel"/>
							</div>
						</li>
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">代表電話番号</span>
								<input type="text" class="form-control" id="ms_worker_tel2"/>
							</div>
						</li>
					</ul>
					<div class="input-group">
						<span class="input-group-addon">送信用メールアドレス</span>
						<input type="text" class="form-control" id="ms_worker_mail1"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">サブ メールアドレス</span>
						<input type="text" class="form-control" id="ms_worker_mail2"/>
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">その他</span>
					<div class="form-control" id="m_client_misc_container">
						<ul class="" style="margin-bottom: 0; padding: 0; list-style-type: none; overflow: hidden;">
							<li style="margin: 0 1em; float: left;">
								<input type="checkbox" id="ms_worker_flg_keyperson"/>
								<label for="ms_worker_flg_keyperson">キーマン フラグ</label>
							</li>
							<li style="margin: 0 1em; float: left;">
								<input type="checkbox" id="ms_worker_flg_sendmail"/>
								<label for="ms_worker_flg_sendmail">メール送信フラグ</label>
							</li>
							<li style="margin: 0 1em; float: left;">
								<label for="m_client_recipient_priority">メール送信時宛先表示優先度：</label>
								<input type="text" id="ms_worker_recipient_priority" style="width: 2em; text-align: center;"/>
								{% if env.limit.SHOW_HELP %}
								&nbsp;<span class="text-danger">1（最上位）～9（最下位）で優先度を入力してください</span>
								{% endif %}
							</li>
						</ul>
					</div>
				</div>
				<div class="input-group" style="width: 100%;">
					<span class="input-group-addon">備考</span>
					<textarea class="form-control" id="ms_worker_note" style="height: 10em;"></textarea>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="$('#ms_worker_id').val() ? commitWorkerObj(Number($('#ms_worker_id').val())) : commitWorkerObj();">保存</button>
				<button type="button" class="btn btn-primary" onclick="hdlClickAddMoreWorkerBtn($('#ms_worker_id').val());">保存してさらに追加</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
{% include "cmn_cap_mail_per_month.tpl" %}
{% include "cmn_cap.tpl" %}
<!-- [end] Model. -->

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		</div>
		<script src="/js/jquery.autokana.js" type="text/javascript"></script>
		<script src="/js/jquery-ui.js" type="text/javascript"></script>
		<script type="text/javascript" src="/js/worker.js"></script>
		<script type="text/javascript">
			env.mapLimit = {{ data['limit.count_records']['LMT_CALL_MAP_EXTERN_M'] or 'null' }} || 0;
		</script>
	</body>
</html>
