{% import "cmn_controls.macro" as buttons -%}
{% set schemes = (("すべて", ""), ("元請", "元請"), ("エンド", "エンド")) -%}
{% set shares = (("すべて", ""), ("オープン", 1), ("クローズ", 0)) -%}
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
			<img alt="案件" width="22" height="20" src="/img/icon/group_case.png"> 案件 一覧
		</div>
		<div id="search-form-accordion" class="row list-group" style="/*background-color: #f1f1f1;*/">
			<a data-toggle="collapse" data-parent="#search-form-accordion" href="#search-form" class="list-group-item">
				<span class="bold list-header">検索条件:</span>
				<ol class="breadcrumb" style="padding: 0px; margin: 0px;">
					{%if query.client_name %}<li>取引先名"{{ query.client_name|e }}"</li>{% endif %}
					{%if query.title %}<li>案件内容"{{ query.title|e }}"</li>{% endif %}
					{%if query.fee_inbound %}<li>請求単価"{{ query.fee_inbound_comma|e }}"</li>{% endif %}
					{%if query.term %}<li>期間"{{ query.term|e }}"</li>{% endif %}
					{%if query.interview %}<li>面談回数"{{ query.interview|e }}"</li>{% endif %}
					{%if query.scheme %}<li>商流"
						{% for schemeLabel, schemeValue in schemes %}
							{% if schemeValue == query.scheme %}
							 {{ schemeLabel }}
							{% endif %}
						{% endfor %}"</li>
					{% endif %}
					{%if query.flg_shared %}<li>状態"
						{% for shareLabel, shareValue in shares %}
							{% if shareValue == query.flg_shared %}
							 {{ shareLabel }}
							{% endif %}
						{% endfor %}"</li>
					{% endif %}
				</ol>
			</a>
			<form onsubmit="c4s.hdlClickSearchBtn(); return false;" id="search-form" class="collapse">
				<!--input type="submit" style="display: none;"/-->
				<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
					<li style="margin: 1px 2em; float: left;">
						<label for="query_client_name" style="color: #666666; width: 5em;">取引先名</label>
						<input type="text" id="query_client_name" value="{{ query.client_name|e }}"/>
						<input type="hidden" id="query_client_id"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_title" style="color: #666666; width: 5em;">案件内容</label>
						<input type="text" id="query_title" value="{{ query.title|e }}"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_fee_inbound" style="color: #666666; width: 5em;">請求単価</label>
						<input type="text" id="query_fee_inbound" value="{{ query.fee_inbound|e }}"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_term" style="color: #666666; width: 5em;">期間</label>
						<input type="text" id="query_term" value="{{ query.term|e }}" data-date-format="yyyy/mm/dd"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_interview" style="color: #666666; width: 5em;">面談回数</label>
						<input type="number" id="query_interview" value="{{ query.interview|e }}"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_scheme" style="color: #666666; width: 5em;">商流</label>
						<select id="query_scheme">
						{% for schemeLabel, schemeValue in schemes %}
							<option value="{{ schemeValue }}"{% if schemeValue == query.scheme %} selected="selected"{% endif %}>{{ schemeLabel }}</option>
						{% endfor %}
						</select>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_flg_shared" style="color: #666666; width: 5em;">状態</label>
						<select id="query_flg_shared">
						{% for shareLabel, shareValue in shares %}
							<option value="{{ shareValue }}"{% if shareValue == query.flg_shared %} selected="selected"{% endif %}>{{ shareLabel }}</option>
						{% endfor %}
						</select>
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
		<div class="row" style="margin-top: 1em;margin-bottom: 0.5em;">
			<div class="col-lg-7">
				{{ buttons.new_obj("hdlClickNewObj();") }}
			{% if env.limit.LMT_ACT_MAIL -%}
				{{ buttons.mail_all("openMailForm();") }}
			{% endif -%}
				{{ buttons.delete_checked("deleteItems();") }}
				<span class="btn" onclick="exportPdf();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
			</div>
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['project.enumProjects']) }}
			<!-- /件数 -->
		</div>
		<!-- /検索結果ヘッダー -->
		<!-- 検索結果 -->
		<div class="row table-responsive" >
			<table class="table view_table table-bordered table-hover">
				<thead>
					<tr>
						<th style="width: 25px;">選択<br/><input type="checkbox" id="iter_project_selected_cb_0" onclick="c4s.toggleSelectAll('iter_project_selected_cb_', this);"/></th>
						<th>
							{{ buttons.th(query, '取引先名', 'client_name') }}
						</th><!-- client_name or clients[client_id] -->
						<th>
							{{ buttons.th(query, '案件内容', 'title') }}<br/>／スキル</th>
					</tr>
				</thead>
				<tbody>
				{% if data['project.enumProjects'] %}
					{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
					{% set items = data['project.enumProjects'][row_min:row_min + env.limit.ROW_LENGTH] %}
					{% for item in items %}
					<tr id="iter_project_{{ item.id }}">
						<td class="center">
							<input type="checkbox" id="iter_project_selected_cb_{{ item.id }}"/>
						</td>
						<td>
							{% if item.client_name and not item.client.name %}
							<span>{{ item.client_name|truncate(12, True)|e }}</span>
							{% else %}
							<span class="pseudo-link"
								onclick="overwriteClientModalForEdit({{ item.client.id }});">{{ item.client.name|truncate(12, True)|e }}</span>
							{% endif %}
						</td>
						<td>
							<span class="pseudo-link bold"
								onclick="overwriteModalForEdit({{ item.id }});">{{ item.title|truncate(12, True)|e }}</span><br/>／{% if item.skill_list %}{{ item.skill_list|truncate(12, True)|e }}{% endif %}
                        </td>
					</tr>
					{% endfor %}
				{% else %}
					<tr>
						<td colspan="3">有効なデータがありません</td>
					</tr>
				{% endif %}
				</tbody>
			</table>
		</div>
		<!-- /検索結果 -->
		<div class="row" style="margin-top: 0.5em;">
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['project.enumProjects']) }}
			<!-- /件数 -->
		</div>
	</div>
{% else -%}

	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
				<img alt="案件" width="22" height="20" src="/img/icon/group_case.png"> 案件 一覧
			</div>
			<div class="row" style="/*background-color: #f1f1f1;*/">
				<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
					<!--input type="submit" style="display: none;"/-->
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
						<li style="margin: 0 2em; float: left;">
							<label for="query_client_name" style="color: #666666;">取引先名</label>
							<input type="text" id="query_client_name" value="{{ query.client_name|e }}"/>
							<input type="hidden" id="query_client_id"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_title" style="color: #666666;">案件内容</label>
							<input type="text" id="query_title" value="{{ query.title|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_title" style="color: #666666;">請求単価</label>
							<input type="text" id="query_fee_inbound" value="{{ query.fee_inbound|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_term" style="color: #666666;">期間</label>
							<input type="text" id="query_term" value="{{ query.term|e }}" data-date-format="yyyy/mm/dd"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_interview" style="color: #666666;">面談回数</label>
							<input type="number" id="query_interview" value="{{ query.interview|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_scheme" style="color: #666666;">商流</label>
							<select id="query_scheme">
							{% for schemeLabel, schemeValue in schemes %}
								<option value="{{ schemeValue }}"{% if schemeValue == query.scheme %} selected="selected"{% endif %}>{{ schemeLabel }}</option>
							{% endfor %}
							</select>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_flg_shared" style="color: #666666;">状態</label>
							<select id="query_flg_shared">
							{% for shareLabel, shareValue in shares %}
								<option value="{{ shareValue }}"{% if shareValue == query.flg_shared %} selected="selected"{% endif %}>{{ shareLabel }}</option>
							{% endfor %}
							</select>
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
			<div class="row" style="margin-top: 1em;margin-bottom: 0.5em;">
				<div class="col-lg-7">
					{{ buttons.new_obj("hdlClickNewObj();") }}
				{% if env.limit.LMT_ACT_MAIL -%}
					{{ buttons.mail_all("openMailForm();") }}
				{% endif -%}
					{#{{ buttons.search_complex() }}#}
					{{ buttons.delete_checked("deleteItems();") }}
					<span class="btn" onclick="exportPdf();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
				</div>
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['project.enumProjects']) }}
				<!-- /件数 -->
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class="row" >
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 25px;">選択<br/><input type="checkbox" id="iter_project_selected_cb_0" onclick="c4s.toggleSelectAll('iter_project_selected_cb_', this);"/></th>
							<th style="width: 35px;">
								{{ buttons.th(query, '状態', 'flg_shared') }}
							</th>
                            <th style="width: 35px;">
								{{ buttons.th(query, '他社公開', 'flg_public') }}
							</th>
							<th>
								{{ buttons.th(query, '取引先名', 'client_name') }}
							</th><!-- client_name or clients[client_id] -->
							<th>
								{{ buttons.th(query, '案件内容', 'title') }}</th><!-- title and process -->
							<th style="width: 100px;">スキル</th><!-- skill_needs and skill_recommends -->
							<th style="width: 50px;">
								{{ buttons.th(query, '商流', 'scheme') }}
							</th><!-- scheme -->
							<th>期間</th><!-- term -->
							<th>
								{{ buttons.th(query, '請求単価', 'fee_inbound') }}<br/>／{{ buttons.th(query, '支払単価', 'fee_outbound') }}
							</th><!-- fee_inbound and fee_outbound -->
							<th style="width: 35px;">面談<br/>回数</th><!-- interview -->
							<th class="hidden">
								{{ buttons.th(query, '精算条件', 'expense') }}
							</th><!-- expense -->
							<th>
								{{ buttons.th(query, '最寄駅', 'station') }}
							</th><!-- station -->
							<th>
								{{ buttons.th(query, '登録日', 'dt_created') }}
							</th>
							<th>営業担当</th><!-- charging_user.name -->
							<th>要員<br/>検索</th>
							<th style="width: 70px;">外国籍</th>
                            <th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
						<!-- TODO 動的に切り替える -->
					{% if data['project.enumProjects'] %}
						{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
						{% set items = data['project.enumProjects'][row_min:row_min + env.limit.ROW_LENGTH] %}
						{% for item in items %}
						<tr id="iter_project_{{ item.id }}">
							<td class="center">
								<input type="checkbox" id="iter_project_selected_cb_{{ item.id }}"/>
							</td>
							<td class="center">
								{% if item.flg_shared == True  %}
								<span class="glyphicon glyphicon-folder-open text-info pseudo-link-cursor" alt="共有状態" title="オープン" onclick="hdlClickShareProjectToggle({{ item.id}}, JSON.parse({{ item.flg_shared|tojson }}));"></span>
								{% else %}
								<span class="glyphicon glyphicon-folder-close text-muted pseudo-link-cursor" alt="非共有状態" title="クローズ" onclick="hdlClickShareProjectToggle({{ item.id}}, JSON.parse({{ item.flg_shared|tojson }}));"></span>
								{% endif %}
							</td>
                            <td class="center">
								{% if item.flg_public == True  %}
									<span class="glyphicon text-info pseudo-link-cursor" alt="この案件は他社に公開されています。" title="この案件は他社に公開されています。" onclick="hdlClickPublicProjectToggle({{ item.id}}, JSON.parse({{ item.flg_public|tojson }}));">公開</span>
								{% else %}
									<span class="glyphicon text-muted pseudo-link-cursor" alt="この案件は他社に非公開です。" title="この案件は他社に非公開です。" onclick="hdlClickPublicProjectToggle({{ item.id}}, JSON.parse({{ item.flg_public|tojson }}));">非<br/>公開</span>
								{% endif %}
							</td>
							<td>
								{% if item.client_name and not item.client.name %}
								<span>{{ item.client_name|truncate(12, True)|e }}</span>
								{% else %}
								<span class="pseudo-link"
									onclick="overwriteClientModalForEdit({{ item.client.id }});">{{ item.client.name|truncate(12, True)|e }}</span>
								{% endif %}
							</td>
							<td>
								<span class="pseudo-link bold"
									onclick="overwriteModalForEdit({{ item.id }});">{{ item.title|truncate(12, True)|e }}</span></td>
							<td style="word-break: break-word;">{% if item.skill_list %}{{ item.skill_list|e }}{% endif %}</td>
							<td class="center">{{ (item.scheme or "")|e }}</td>
							<td>{% if item.term_begin %}{{ item.term_begin|e }}{% endif %}
                                〜
                                {% if item.term_end %}{{ item.term_end|e }}{% endif %}
                            </td>
							<td class="center">{{ item.fee_inbound_comma|e }}<br/>／{{ item.fee_outbound_comma|e }}</td>
							<td class="center">{{ item.interview|e }}</td>
							<td class="hidden">{{ item.expense|e }}</td>
							<td class="center">{% if item.station != None %}{{ item.station|e }}{% endif %}</td>
							<td class="center" title="{{ item.dt_created }}">{{ item.dt_created[:10] }}</td>
							<td class="center"><span title="{{ item.charging_user.login_id }}">{%if item.charging_user.is_enabled == False %}<span class="glyphicon glyphicon-ban-circle text-danger" title="無効化されたユーザーです"></span>&nbsp;{% endif %}{{ item.charging_user.user_name|e }}</span></td>
							<td class="text-center">
									<span class="pseudo-link-cursor glyphicon glyphicon-search " title="要員検索"
										onclick="triggerSearchEngineer({{ item.id }});"></span>
                            </td>
                            <td class="center">{% if item.flg_foreign == 1 %}可{%elif item.flg_foreign == 0 %}不可{% else %}{% endif %}</td>
                            <td class="center">
								<span class="pseudo-link-cursor glyphicon glyphicon-trash text-danger" alt="削除" title="削除"
									onclick="c4s.hdlClickDeleteItem('project', {{ item.id }}, true);"></span>
							</td>
						</tr>
						{% endfor %}
					{% else %}
						<tr>
							<td colspan="16">有効なデータがありません</td>
						</tr>
					{% endif %}
						<!-- /TODO 動的に切り替える -->
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
			<div class="row" style="margin-top: 0.5em;">
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['project.enumProjects']) }}
				<!-- /件数 -->
			</div>
		</div>
	</div>
{% endif -%}
<!-- /メインコンテンツ -->
<!-- [begin] Modal. -->
<div id="edit_project_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="commitObject($('#m_project_id').val() ? true : false);">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_project_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_project_modal_title">新規案件登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_project_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">案件内容<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_project_title" placeholder="案件内容を入力してください。" style=""/>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">取引先名<span class="text-danger">*</span></span>
                    <select class="form-control" style="width: 100%;" id="m_project_client_id" data-placeholder="取引先を選択して下さい。">
                        {% for item in data['client.enumClients'] %}
                            <option value="{{ item.id }}" >{{ item.name|e }}</option>
                        {% endfor %}
                    </select>
                    <span class="input-group-btn">
                        <button type="button" class="btn btn-primary" onclick="showAddNewClientModal();">新規取引先追加</button>
                    </span>
				</div>
                <input type="hidden" id="m_project_client_name"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">スキル</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;"  onclick="editSkillCondition();">
						<li style="margin: 0.2em 0.5em; float: left;">
							<div id="m_project_skill_container" style="word-break: break-word;">
								<label for="m_project_skill"></label>

							</div>
						</li>
					</ul>
				</div>
{#                <div class="input-group">#}
{#					<span class="input-group-addon" style="min-width: 100px;">スキルメモ</span>#}
{#					<textarea class="form-control" id="m_project_skill_needs" style="height: 5em;"></textarea>#}
{#				</div>#}
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">職種</span>
                    <div id="m_project_occupation_container" class="container-fluid form-control" style="list-style-type: none; overflow: hidden;">
                        <div class="row">
                            {% set occupation_view_count = (data['occupation.enumOccupations']|length) / 2 %}
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index <= occupation_view_count %}
                                     <input type="checkbox" name="m_project_occupation[]" id="occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index > occupation_view_count  %}
                                     <input type="checkbox" name="m_project_occupation[]" id="occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                        </div>
                    </div>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">年齢</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_age_container">
								<input type="number" class="form-control-mini" id="m_project_age_from" style="width: 50px;"/>
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_age_container">
								<label for="m_project_age_to">〜</label>
								<input type="number" class="form-control-mini" id="m_project_age_to" style="width: 50px;"/>
                                　歳
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_foreign">
								<label for="m_project_flg_foreign">外国籍：</label>
								<select id="m_project_flg_foreign">
									<option value=""></option>
									<option value="1">可</option>
									<option value="0">不可</option>
								</select>
							</span>
						</li>
					</ul>
				</div>
				<ul style="margin: 0; padding: 0;list-style-type: none; overflow: hidden;">
					<li class="input-group" style="float: left;">
						<span class="input-group-addon" style="min-width: 100px;">請求単価<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_project_fee_inbound" placeholder="650,000" style="" onChange="addComma(this);"/>
					</li>
					<li class="input-group" style="float: left;" style="min-width: 100px;">
						<span class="input-group-addon" style="min-width: 100px;">支払単価</span>
						<input type="text" class="form-control" id="m_project_fee_outbound" placeholder="600,000" style="" onChange="addComma(this);"/>
					</li>
					<li class="input-group hidden" style="float: left;" style="min-width: 100px;">
						<span class="input-group-addon" style="min-width: 100px;">精算条件</span>
						<input class="form-control" id="m_project_expense"/>
					</li>
				</ul>
				<div class="input-group hidden">
					<span class="input-group-addon">作業工程</span>
					<input type="text" class="form-control" id="m_project_process"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">その他</span>
					<ul class="form-control" style="list-style-type: none; overflow: hidden;font-size: small;">
						<li class="hidden" style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_rank_id_container">
								<label for="m_project_rank_id">ランク：</label>
                                <input type="radio" name="m_project_rank_grp" id="m_project_rank_01" checked="checked" value="1"/>
								<label for="m_project_rank_01">A</label>
								<input type="radio" name="m_project_rank_grp" id="m_project_rank_02" value="2"/>
								<label for="m_project_rank_02">B</label>
                                <input type="radio" name="m_project_rank_grp" id="m_project_rank_03" value="3"/>
								<label for="m_project_rank_03">C</label>
							</span>
						</li>
                        <li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_interview_container">
								<label for="m_project_interview">面談回数：</label>
								<input type="number" id="m_project_interview" style="width: 30px;"/>
							</span>
						</li>
                        <li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_scheme_container">
								<label for="m_project_scheme">商流：</label>
								<select id="m_project_scheme" style="">
									<option value=""></option>
									<option value="元請">元請</option>
									<option value="エンド">エンド</option>
								</select>
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_station_container">
								<label for="m_project_station">最寄駅：</label>
								<input type="text" class="" id="m_project_station" style="width: 80px;" placeholder="秋葉原"/>
                                <input type="hidden" id="m_project_station_cd" value="">
                                <input type="hidden" id="m_project_station_pref_cd" value="">
                                <input type="hidden" id="m_project_station_line_cd" value="">
                                <input type="hidden" id="m_project_station_lon" value="">
                                <input type="hidden" id="m_project_station_lat" value="">
							</span>
						</li>
					</ul>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">担当営業</span>
					<span class="form-control">
						<select class="" style="width: 150px;" id="m_project_charging_user_id">
								<option></option>
							{% for item in data['manage.enumAccounts'] %}
								{% if item.is_enabled == True %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
								{% endif %}
							{% endfor %}
							</select>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">期間</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_term_container">
								<label for="m_project_term_begin">　　</label>
								<input type="text" class="" id="m_project_term_begin" style="width: 150px;" data-date-format="yyyy/mm/dd" placeholder="2018/02/01"/>
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_term_container">
								<label for="m_project_term_end">〜</label>
								<input type="text" class="" id="m_project_term_end" style="width: 150px;" data-date-format="yyyy/mm/dd" placeholder="2018/03/31"/>
							</span>
						</li>
                        <li class="hidden" style="margin: 0.2em 0.5em; float: left; width: 100%;">
							<span id="m_project_term_container">
								<label for="m_project_term">備考</label>
					            <input type="text" class="" id="m_project_term" style="width: 90%;"/>
							</span>
						</li>
                        <li style="margin: 0.2em 0.5em; float: left; width: 100%; font-size: x-small">
                            案件マッチング画面に表示するためには期間を現在日時が含まれるように設定する必要があります。
                        </li>
					</ul>
				</div>
				<div class="input-group hidden">
					<span class="input-group-addon">推奨スキルメモ</span>
					<textarea class="form-control" id="m_project_skill_recommends" style="height: 5em;"></textarea>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">状態フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_project_flg_shared"/>
						<label for="m_project_flg_shared" class="text-danger">案件が募集中であればチェックしてください。</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとホームの案件管理一覧に情報が表示（オープン）されます。<br/>チェックを外すと情報を『クローズ』中として扱えます。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;font-size: x-small;">他社公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_project_flg_public"/>
						<label for="m_project_flg_public" class="text-danger" style="display: inline">チェック状態の場合、本CRMを利用する他社のユーザへ共有されます</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとSESクラウド利用企業様に案件情報が公開されます。<br/>多くの企業様にシェアされるので見合う要員獲得に繋がります。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;font-size: x-small;">Web公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_project_web_public"/>
						<label for="m_project_web_public" class="text-danger" style="display: inline"></label>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">社内備考</span>
					<textarea class="form-control" id="m_project_internal_note" style="height: 4em;resize: none;"></textarea>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">備考</span>
					<textarea class="form-control" id="m_project_note" style="height: 20em;"></textarea>
				</div>
{#                <div class="input-group hidden" style="width: 100%;" id="m_project_worker_container">#}
{#					<label class="" for="m_client_branch_table">要員</label><br/>#}
{##}
{#                    <div style="margin-bottom: 10px">#}
{#                        {% if "iPhone" in env.UA or "Android" in env.UA -%}#}
{#                        {% else %}#}
{#                        <span class="btn" onclick="triggerSearchEngineer();">#}
{#                        検索 <span class="pseudo-link-cursor glyphicon glyphicon-search " title="要員検索"></span>#}
{#                        </span>#}
{#                        {% endif %}#}
{#                    </div>#}
{##}
{#					<table id="m_client_worker_table" class="view_table table-bordered table-hover" style="width: 100%;">#}
{#						<thead>#}
{#							<tr>#}
{#								<th>部署&nbsp;役職<br/>名前</th><!-- section and title and name -->#}
{#								<th style="width: 130px;">携帯電話番号</th><!-- tel -->#}
{#								<th>メールアドレス</th><!-- mail1 and mail2 -->#}
{#								<th style="width: 30px;">削除</th>#}
{#							</tr>#}
{#						</thead>#}
{#						<tbody id="assign_engineer_list">#}
{#                            <tr><td colspan="4">誰もアサインされていません。</td></tr>#}
{#                        </tbody>#}
{#					</table>#}
{#				</div>#}
				<div style="width: 100%; text-align: right; display: none;">
					<label for="m_project_dt_created">登録日:</label>
					<span id="m_project_dt_created" style="font-family: monospace;"></span>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="commitObject($('#m_project_id').val() ? true : false);">保存</button>
{#                <span id="disp-quotation">#}
{#                    <button type="button" class="btn btn-primary" onclick="triggerCreateQuotationEstimate($('#m_project_id').val() ? true : false);">見積書作成</button>#}
{#                    <button type="button" class="btn btn-primary" onclick="triggerCreateQuotationOrder($('#m_project_id').val() ? true : false);">注文書作成</button>#}
{#                </span>#}

			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
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
								<th>{#部署&nbsp;役職<br/>#}名前</th><!-- section and title and name -->
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
<div id="edit_worker_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_worker_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_worker_modal_title">新規取引先担当者登録</span></h4>
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
							<option value="{{ item.login_id }}">{{ item.name|e }}</option>
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

{% include "edit_project_skill_condition_modal.tpl" %}

<div id="edit_station_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_station_condition_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">最寄駅検索</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <form>
                    <table>
                        <tr>
                            <td><label>都道府県</label></td>
                            <td>　<select id="s" name="pref" onChange="setMenuItem(0,this[this.selectedIndex].value,null,null)">{% include "cmn_pref_select.tpl" %}</select></td>
                        </tr>
                        <tr>
                            <td><label>路線</label></td>
                            <td>　<select id="s0" name="s0" onChange="setMenuItem(1,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                        <tr>
                            <td><label>最寄駅</label></td>
                            <td>　<select id="s1" name="s1" onChange="setMenuItem(2,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                    </table>
                </form>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<div id="add_new_project_client_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="commitProjectClient();">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#add_new_project_client_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
					<span id="add_new_project_client_modal_title">新規取引先登録</span>
                    <input type="hidden" id="#new_client_id">
				</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon">取引先名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="new_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">取引先名（カナ）<span class="text-danger">*</span></span>
					<input type="test" class="form-control" id="new_client_kana"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">郵便番号</span>
					<input type="text" class="form-control" id="new_client_addr_vip" placeholder="nnn-nnnn" style="width: 8em;" maxlength="8"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#new_client_addr_vip').val(), '#new_client_addr1', '#new_client_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
					{% if env.limit.LMT_ACT_MAP -%}
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
						<span class="input-group-btn">
							<button class="btn btn-default"
								onclick="c4s.openMap({target_id: $('#new_client_id').val(), target_type: 'client', name: $('#m_client_name').val(), addr1: $('#m_client_addr1').val(), addr2: $('#m_client_addr2').val(), tel: $('#m_client_tel').val(), modalId: 'edit_client_modal', isFloodLMT: false, current: env.current});">
								<span class="glyphicon glyphicon-globe text-success"></span>
								{% if env.limit.SHOW_HELP %}&nbsp;地図を確認する{% endif %}
							</button>
						</span>
						&nbsp;
						{% else -%}
						<span class="input-group-btn">
							<button class="btn btn-default"
								onclick="c4s.openMap({isFloodLMT: true});">
								<span class="glyphicon glyphicon-globe text-muted"></span>
							</button>
						</span>
						{% endif -%}
					{% endif -%}
					<span class="text-danger" id="new_client_addr1_alert"></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">住所<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="new_client_addr1"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">ビル名</span>
					<input type="text" class="form-control" id="new_client_addr2"/>
				</div>
				<div class="form-group" style="margin-bottom: 0;">
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-phone-alt">&nbsp;代表電話番号</span>
						<input type="text" class="form-control" id="new_client_tel"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-print">&nbsp;代表FAX番号</span>
						<input type="text" class="form-control" id="new_client_fax"/>
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">サイトURL&nbsp;<span class="glyphicon glyphicon-globe text-primary"></span></span>
					<input class="form-control" type="text" id="new_client_site" placeholder="http://"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">提案区分<span class="text-danger">*</span></span>
					<div class="form-control" id="new_client_type_presentation_container">
						<input type="checkbox" id="new_client_type_presentation_0" value="案件"/>
						<label for="new_client_type_presentation_0">案件</label>
						<input type="checkbox" id="new_client_type_presentation_1" value="人材"/>
						<label for="new_client_type_presentation_1">人材</label>
						{% if env.limit.SHOW_HELP -%}&nbsp;<span class="text-danger">案件（保有企業）/人材（保有企業）</span>{% endif -%}
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">重要度</span>
					<select class="form-control" id="new_client_type_dealing">
						<option value="重要客">重要客</option>
						<option value="通常客" selected="selected">通常客</option>
						<option value="低ポテンシャル">低ポテンシャル</option>
						<option value="取引停止">取引停止</option>
					</select>
				</div>
				<div class="input-group">
					<span class="input-group-addon">自社担当営業</span>
						<div class="" style="width: 50%; float: left;">
							<label class="" for="new_client_charging_worker1">主担当：</label>
							<select class="form-control" id="new_client_charging_worker1">
							<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}"{% if data['auth.userProfile'].user.id == item.id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
						<div class="" style="width: 50%; float: left;">
							<label for ="new_client_charging_worker2">副担当：</label>
							<select class="form-control" id="new_client_charging_worker2">
								<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">備考</span>
					<textarea class="form-control" id="new_client_note" style="height: 10em;"></textarea>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary"
					onclick="commitProjectClient();">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<div id="loader-bg">
  <div id="loader">
    <img src="/img/icon/img-loading.gif" width="80" height="80" alt="Now Loading..." />
    <p>メール送信用PDFファイルを<br/>準備中です。</p>
  </div>
</div>

<div id="loader-bg2">
  <div id="loader2">
    <img src="/img/icon/img-loading.gif" width="80" height="80" alt="Now Loading..." />
    <p>PDFファイルを準備中です。</p>
  </div>
</div>

{% include "cmn_cap_mail_per_month.tpl" %}
{% include "cmn_cap.tpl" %}
<!-- [end] Model. -->

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script src="/js/jquery.autokana.js" type="text/javascript"></script>
		<script src="/js/jquery-ui.js" type="text/javascript"></script>
        <script src="/js/bootstrap-datepicker.js" type="text/javascript"></script>
        <script src="/js/bootstrap-datepicker.ja.js"></script>
        <link href="/css/select2.css" rel="stylesheet">
        <script src="/js/select2.js"></script>
		<script src="/js/project.js" type="text/javascript"></script>
		<script type="text/javascript">
			env = env || {};
			env.userProfile = JSON.parse('{{ data['auth.userProfile']|tojson }}');
			env.data = env.data || {};
			env.data.clients = JSON.parse('{{ data['js.clients']|tojson }}');
			env.data.skillCategories = JSON.parse('{{ data['skill.enumSkillCategories']|tojson }}');
			env.data.skillLevels = JSON.parse('{{ data['skill.enumSkillLevels']|tojson }}');
			env.mapLimit = {{ data['limit.count_records']['LMT_CALL_MAP_EXTERN_M'] or 'null' }} || 0;
			$("#edit_project_modal").on("hide.bs.modal", function () {
				$("#m_project_dt_created").parent().css("display", "none");
			});
		</script>
	</body>
</html>