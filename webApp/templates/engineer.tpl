{% import "cmn_controls.macro" as buttons -%}
{% set contracts = ("正社員", "契約社員", "個人事業主", "パートナー") -%}
{% set contractNews = ("正社員(契約社員)", "個人事業主", "パートナー") -%}
{% set pagenates = ("100", "200", "500", "all") -%}
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
			<img alt="要員" width="22" height="20" src="/img/icon/group_engineer.png"> 要員 一覧
		</div>
		<div id="search-form-accordion" class="row list-group" style="/*background-color: #f1f1f1;*/">
			<a data-toggle="collapse" data-parent="#search-form-accordion" href="#search-form" class="list-group-item">
				<span class="bold list-header">検索条件:</span>
				<ol class="breadcrumb" style="padding: 0px; margin: 0px;">
					{%if query.name %}<li>要員名"{{ query.name|e }}"</li>{% endif %}
					{%if query.station %}<li>最寄駅"{{ query.station|e }}"</li>{% endif %}
					{%if query.contract %}<li>所属"{{ query.contract }}"</li>{% endif %}
					{%if query.employer %}<li>所属団体名"{{ query.employer|e }}"</li>{% endif %}
					{%if query.skill %}<li>スキル"{{ query.skill|e }}"</li>{% endif %}
{#					{%if query.flg_caution %}<li>要注意</li>{% endif %}#}
{#					{%if query.flg_registered %}<li>共有</li>{% endif %}#}
					{%if query.flg_assignable %}<li>アサイン可能</li>{% endif %}
				</ol>
			</a>
			<form onsubmit="c4s.hdlClickSearchBtn(); return false;" id="search-form" class="collapse">
				<!--input type="submit" style="display: none;"/-->
				<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
					<li style="margin: 1px 2em; float: left;">
						<label for="query_name" style="color: #666666; width: 6em;">要員名</label>
						<input type="text" id="query_name" value="{{ query.name|e }}"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_station" style="color: #666666; width: 6em;">最寄駅</label>
						<input type="text" id="query_station" value="{{ query.station|e }}"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_contract" style="color: #666666; width: 6em;">所属</label>
						<select id="query_contract" value="{{ query.contract }}">
							<option value="">すべて</option>
							{% for contract in contractNews %}
							<option value="{{ contract}}"{% if contract == query.contract %} selected="selected"{% endif %}>{{ contract }}</option>
							{% endfor %}
						</select>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_client_name" style="color: #666666; width: 6em;">所属団体名</label>
						<input type="text" id="query_client_name" value="{{ query.client_name|e }}"/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_skill" style="color: #666666; width: 6em;">スキル</label>
						<input type="text" id="query_skill" value="{{ query.skill|e }}"/>
					</li>
{#					<li style="margin: 1px 2em; float: left;">#}
{#						<label for="query_flg_caution" style="color: #666666;">要注意フラグ</label>#}
{#						<input type="checkbox" id="query_flg_caution"{% if query.flg_caution %} checked="checked"{% endif %}/>#}
{#					</li>#}
{#					<li style="margin: 1px 2em; float: left;">#}
{#						<label for="query_flg_registered" style="color: #666666;">共有フラグ</label>#}
{#						<input type="checkbox" id="query_flg_registered"{% if query.flg_registered %} checked="checked"{% endif %}/>#}
{#					</li>#}
					<li style="margin: 1px 2em; float: left;">
						<label for="query_skill" style="color: #666666;">アサイン可能フラグ</label>
						<input type="checkbox" id="query_flg_assignable"{% if query.flg_assignable %} checked="checked"{% endif %}/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_flg_careful" style="color: #666666;">要注意フラグ</label>
						<input type="checkbox" id="query_flg_careful"{% if query.flg_careful %} checked="checked"{% endif %}/>
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
				{{ buttons.new_obj("hdlClickNewObj();") }}
			{% if env.limit.LMT_ACT_MAIL -%}
				{{ buttons.mail_all("openMailForm();") }}
			{% endif -%}
				{{ buttons.delete_checked("deleteItems();") }}
				<span class="btn" onclick="exportPdf();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
			</div>
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['engineer.enumEngineers']) }}
			<!-- /件数 -->
		</div>
		<div class="'row" style="margin-top:20px;margin-bottom:20px;">
			<div class="col-lg-1"></div>
			<div class="col-lg-2">
				<input type="checkbox" id="query_flg_sort" onclick="c4s.hdlClickSearchBtn();"{% if query.flg_sort %} checked="checked"{% endif %}/>
				<label for="query_skill" style="color: #666666;">50音順</label>
			</div>
		</div>
		<!-- /検索結果ヘッダー -->
		<!-- 検索結果 -->
		<div class="row table-responsive" >
			<table class="table view_table table-bordered table-hover">
				<thead>
					<tr>
						<th style="width: 35px;">選択<br/><input type="checkbox" id="iter_engineer_selected_cb_0" onclick="c4s.toggleSelectAll('iter_engineer_selected_cb_', this);"/></th>
						<th>
							{{ buttons.th(query, '要員名', 'kana') }}
						</th>
						<th>スキル</th>
						<th style="width: 35px;">経歴書</th>
					</tr>
				</thead>
				<tbody>
				{% if data['engineer.enumEngineers'] %}
					{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
					{% set items = data['engineer.enumEngineers'][row_min:row_min + env.limit.ROW_LENGTH] %}
					{% for item in items %}
						<tr id="iter_engineer_{{ item.id }}">
							<td class="text-center">
								<input type="checkbox" id="iter_engineer_selected_cb_{{ item.id }}"/>
							</td>
							<td>
								<span class="pseudo-link bold" title="{{ item.kana|e }}"
									onclick="overwriteModalForEdit({{ item.id }});">{{ item.name|truncate(12, True)|e }}</span>
								{% if item.flg_careful == True %}
									<span class="pseudo-link-cursor glyphicon glyphicon-exclamation-sign"
										data-toggle="popover"
										data-placement="right"
										data-content="要注意フラグ"
										onmouseover="$(this).popover('show');"
										onmouseout="$(this).popover('hide');"></span>
								{% endif %}
								<span class="badge pseudo-link-cursor pull-right"
									title="手配数"
									data-toggle="popover"
									data-placement="right"
									data-content="手配状況の一覧と追加はこちらをクリックしてください。"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');"
									onclick="hdlEditPreparation({{ item.id }});">手配数：{{ item.preparations|length }}&nbsp;</span>
							</td>
							<td>{% if item.skill_list %}{{ item.skill_list|truncate(12, True)|e }}{% endif %}</td>
							<td class="text-center">
							{% if item.attachement %}
								<span class="glyphicon glyphicon-file pseudo-link-cursor" style="color: #2a98c5;"
									title="添付ファイル：{{ item.attachement.name|e }}({{ item.attachement.size }}bytes)"
									onclick="c4s.download({{ item.attachement.id }})"></span>
							{% else %}
								<span class="glyphicon glyphicon-file pseudo-link-cursor text-muted" title="添付ファイルはありません"></span>
							{% endif %}
							</td>
						</tr>
					{% endfor %}
				{% else %}
					<td id="iter_engineer_0">
						<td colspan="4">有効なデータがありません</td>
					</td>
				{% endif %}
				</tbody>
			</table>
		</div>
		<!-- /検索結果 -->
		<div class="row" style="margin-top: 0.5em;">
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['engineer.enumEngineers']) }}
			<!-- /件数 -->
		</div>
	</div>
{% else -%}
	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
				<img alt="要員" width="22" height="20" src="/img/icon/group_engineer.png"> 要員 一覧
			</div>
			<div class="row" style="/*background-color: #f1f1f1;*/">
				<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
					<!--input type="submit" style="display: none;"/-->
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
						<li style="margin: 0 2em; float: left;">
							<label for="query_name" style="color: #666666;">要員名</label>
							<input type="text" id="query_name" value="{{ query.name|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_station" style="color: #666666;">最寄駅</label>
							<input type="text" id="query_station" value="{{ query.station|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_contract" style="color: #666666;">所属</label>
							<select id="query_contract" value="{{ query.contract }}">
								<option value="">すべて</option>
								{% for contract in contractNews %}
								<option value="{{ contract}}"{% if contract == query.contract %} selected="selected"{% endif %}>{{ contract }}</option>
								{% endfor %}
							</select>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_client_name" style="color: #666666;">所属団体名</label>
							<input type="text" id="query_client_name" value="{{ query.client_name|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_skill" style="color: #666666;">スキル</label>
							<input type="text" id="query_skill" value="{{ query.skill|e }}"/>
						</li>
{#						<li style="margin: 0 2em; float: left;">#}
{#							<label for="query_flg_caution" style="color: #666666;">要注意フラグ</label>#}
{#							<input type="checkbox" id="query_flg_caution"{% if query.flg_caution %} checked="checked"{% endif %}/>#}
{#						</li>#}
{#						<li style="margin: 0 2em; float: left;">#}
{#							<label for="query_flg_registered" style="color: #666666;">共有フラグ</label>#}
{#							<input type="checkbox" id="query_flg_registered"{% if query.flg_registered %} checked="checked"{% endif %}/>#}
{#						</li>#}
						<li style="margin: 0 2em; float: left;">
							<label for="query_skill" style="color: #666666;">アサイン可能フラグ</label>
							<input type="checkbox" id="query_flg_assignable"{% if query.flg_assignable %} checked="checked"{% endif %}/>
						</li>
						<li style="margin: 0px 2em; float: left;">
						<label for="query_flg_careful" style="color: #666666;">要注意フラグ</label>
						<input type="checkbox" id="query_flg_careful"{% if query.flg_careful %} checked="checked"{% endif %}/>
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
					{{ buttons.new_obj("hdlClickNewObj();") }}
				{% if env.limit.LMT_ACT_MAIL -%}
					{{ buttons.mail_all("openMailForm();") }}
				{% endif -%}
					{{ buttons.delete_checked("deleteItems();") }}
					<span class="btn" onclick="exportPdf();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
				</div>
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['engineer.enumEngineers']) }}
				<!-- /件数 -->
			</div>
			<div class="'row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-1"></div>
				<div class="col-lg-2">
					<input type="checkbox" id="query_flg_sort" onclick="c4s.hdlClickSearchBtn();"{% if query.flg_sort %} checked="checked"{% endif %}/>
					<label for="query_skill" style="color: #666666;">50音順</label>
				</div>
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class="row" >
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 35px;">選択<br/><input type="checkbox" id="iter_engineer_selected_cb_0" onclick="c4s.toggleSelectAll('iter_engineer_selected_cb_', this);"/></th>
							<th style="width: 60px;">状態</th>
							<th>
								{{ buttons.th(query, '要員名', 'kana') }}
							</th>
							<th>要員名（短縮名）</th>
							<th style="width: 150px;">
								{{ buttons.th(query, '所属', 'contract') }}
							</th>
							<th style="width: 150px;">スキル</th>
							<th>稼働</th>
							<th style="width: 60px;">
								{{ buttons.th(query, '単価', 'fee') }}
							</th>
							<th style="width: 45px;">年齢<br/>（性別）</th>
							<th>
								{{ buttons.th(query, '登録日', 'dt_created') }}
							</th>
							<th style="width: 110px;">営業<br>担当</th>
                            <th style="width: 35px;">案件検索</th>
							<th style="width: 35px;">経歴書</th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
						<!-- TODO 動的に切り替える -->
					{% if data['engineer.enumEngineers'] %}
						{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
						{% set items = data['engineer.enumEngineers'][row_min:row_min + env.limit.ROW_LENGTH] %}
						{% for item in items %}
							<tr id="iter_engineer_{{ item.id }}">
								<td class="text-center">
									<input type="checkbox" id="iter_engineer_selected_cb_{{ item.id }}"/>
								</td>
								<td class="text-center">
									<span class="glyphicon glyphicon-user {% if item.flg_assignable %}text-success{% else %}text-muted{% endif %} pseudo-link-cursor"
										title="{% if item.flg_assignable %}アサイン可能{% else %}アサイン不可能{% endif %}"></span>
								{% if item.flg_caution %}
									<span class="glyphicon glyphicon-ban-circle text-danger pseudo-link-cursor" title="要注意フラグ"></span>{% endif %}
                                {% if item.flg_public == True %}
									<span class="glyphicon glyphicon-share-alt text-success pseudo-link-cursor" title="他社公開フラグ(この案件は他社に公開されています。)"></span>
								{% endif %}
								</td>
								<td>
									<span class="pseudo-link bold" title="{{ item.kana|e }}"
										onclick="overwriteModalForEdit({{ item.id }});">{{ item.name|truncate(12, True)|e }}</span>
									{% if item.flg_careful == True %}
										<span class="pseudo-link-cursor glyphicon glyphicon-exclamation-sign"
											data-toggle="popover"
											data-placement="right"
											data-content="要注意フラグ"
											onmouseover="$(this).popover('show');"
											onmouseout="$(this).popover('hide');"></span>
									{% endif %}
									<span class="badge pseudo-link-cursor pull-right"
										title="手配数"
										data-toggle="popover"
										data-placement="right"
										data-content="手配状況の一覧と追加はこちらをクリックしてください。"
										onmouseover="$(this).popover('show');"
										onmouseout="$(this).popover('hide');"
										onclick="hdlEditPreparation({{ item.id }});">手配数：{{ item.preparations|length }}&nbsp;</span>
								</td>
								<td>{{ item.visible_name|e }}</td>
								<td>{{ item.contract }}</td>
								<td style="word-break: break-word;">{% if item.skill_list %}{{ item.skill_list|e }}{% endif %}</td>
								<td>{% if item.operation_begin %}{{ item.operation_begin|e }}{% endif %}</td>
								<td class="center">{{ item.fee_comma }}</td>
								<td class="text-center">{% if item.age %}{{ item.age }}歳<br/>{% endif %}（{{ item.gender }}）</td>
								<td class="center" title="{{ item.dt_created }}">{{ item.dt_created[:10] }}</td>
								<td class="center">
								{% if item.charging_user %}
									{% if item.charging_user.is_enabled == False %}
									<span class="glyphicon glyphicon-ban-circle text-danger" title="無効化されたユーザーです"></span>&nbsp;
									{% endif %}
									<span title="{{ item.charging_user.login_id|e }}">{{ item.charging_user.user_name|e }}</span>
								{% endif %}
								</td>
                                <td class="text-center">
									<span class="pseudo-link-cursor glyphicon glyphicon-search " title="案件検索"
										onclick="triggerSearchProject({{ item.id }});"></span>
								</td>
								<td class="text-center">
								{% if item.attachement %}
									<span class="glyphicon glyphicon-file pseudo-link-cursor" style="color: #2a98c5;"
										title="添付ファイル：{{ item.attachement.name|e }}({{ item.attachement.size }}bytes)"
										onclick="c4s.download({{ item.attachement.id }})"></span>
								{% else %}
									<span class="glyphicon glyphicon-file pseudo-link-cursor text-muted" title="添付ファイルはありません"></span>
								{% endif %}
								</td>
								<td class="text-center">
									<span class="pseudo-link-cursor glyphicon glyphicon-trash text-danger" title="削除"
										onclick="c4s.hdlClickDeleteItem('engineer', {{ item.id }}, true);"></span>
								</td>
							</tr>
						{% endfor %}
					{% else %}
						<tr id="iter_engineer_0">
							<td colspan="14">有効なデータがありません</td>
						</tr>
					{% endif %}
						<!-- /TODO 動的に切り替える -->
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
			<div class="row" style="margin-top: 0.5em;">
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['engineer.enumEngineers']) }}
				<!-- /件数 -->
			</div>
		</div>
	</div>
{% endif -%}
<!-- /メインコンテンツ -->

<!-- [begin] Modal. -->
<div id="edit_engineer_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="($('#m_engineer_id').val() ? updateObj : commitNewObj)();">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_engineer_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_engineer_modal_title">新規要員登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_engineer_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon" style="min-width: 100px;">要員名<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_name" placeholder="要員名を入力してください。"/>
					</li>
					<li class="input-group" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">要員名（カナ）<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_kana" placeholder="カナを入力してください。" />
					</li>
				</ul>
				<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">要員名<br>（短縮表示名）<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_visible_name" placeholder="ST"/>
					</li>
                    <li class="input-group " style="width: 50%; margin: 0; padding: 0; float: left;">
                        <span class="input-group-addon"style="min-width: 100px;">所属</span>
						<select class="form-control" id="m_engineer_contract">
							{% for contract in contracts %}
							<option value="{{ contract}}">{{ contract }}</option>
							{% endfor %}
						</select>
					</li>
					<li class="input-group hidden" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">電話番号</span>
						<input type="text" class="form-control" id="m_engineer_tel"/>
					</li>
				</ul>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">所属先 <span class="text-danger">*</span></span>
                    <select class="form-control" style="width: 100%;" id="m_engineer_client_id" data-placeholder="取引先を選択して下さい。">
                        {% for item in data['client.enumClients'] %}
                            <option value="{{ item.id }}" >{{ item.name|e }}</option>
                        {% endfor %}
                    </select>
                    <span class="input-group-btn">
                        <button type="button" class="btn btn-primary" onclick="showAddNewClientModal();">新規取引先追加</button>
                    </span>
				</div>
                <input type="hidden" id="m_engineer_client_name"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">スキル</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;"  onclick="editSkillCondition();">
						<li style="margin: 0.2em 0.5em; float: left;">
							<div id="m_engineer_skill_container" style="word-break: break-word;">
								<label for="m_engineer_skill"></label>
							</div>
						</li>
					</ul>
				</div>
{#				<div class="input-group">#}
{#					<span class="input-group-addon" style="min-width: 100px;">スキルメモ</span>#}
{#					<textarea class="form-control" id="m_engineer_skill" style="height: 5em;"></textarea>#}
{#				</div>#}
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">職種</span>
                    <div id="m_engineer_occupation_container" class="container-fluid form-control" style="list-style-type: none; overflow: hidden;">
                        <div class="row">
                            {% set occupation_view_count = (data['occupation.enumOccupations']|length) / 2 %}
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index <= occupation_view_count %}
                                     <input type="checkbox" name="m_engineer_occupation[]" id="engineer_occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="engineer_occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index > occupation_view_count  %}
                                     <input type="checkbox" name="m_engineer_occupation[]" id="engineer_occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="engineer_occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                        </div>
                    </div>
				</div>
				<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 60%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon" style="min-width: 100px;">誕生日</span>
						<input class="form-control" id="m_engineer_birth" readOnly="readOnly" type="text"
							data-date-format="yyyy/mm/dd" placeholder="1990/02/01"/>
						<span class="input-group-addon pseudo-link-cursor" onclick="$('#m_engineer_birth').val(null);">クリア</span>
					</li>
					<li class="input-group" style="width: 40%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">年齢</span>
						<input type="number" class="form-control" id="m_engineer_age" style="text-align: center;" min="0" max="99" pattern="\d+" placeholder="28"/>
						<span class="input-group-addon">歳</span>
					</li>
				</ul>
				<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 40%; margin: 0; padding: 0; float: left;">

					</li>
				</ul>
                <ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
                    <li class="input-group" style="width: 40%; margin: 0; padding: 0;float: left;" id="m_engineer_gender_container">
                        <span class="input-group-addon" style="min-width: 100px">性別</span>
                        <span class="form-control" style="font-size: x-small;padding: 0px 5px;">
                            <input type="radio" name="m_engineer_gender_grp" id="m_engineer_gender_01" checked="checked" value="男"/>
                            <label for="m_engineer_gender_01">男性</label>
                            <input type="radio" name="m_engineer_gender_grp" id="m_engineer_gender_02" value="女"/>
                            <label for="m_engineer_gender_02">女性</label>
                        </span>
                    </li>
					<li class="input-group" style="width: 30%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">単価<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_fee" placeholder="600,000" onChange="addComma(this);"/>
					</li>
					<li class="input-group" style="width: 30%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">最寄駅</span>
						<input type="text" class="form-control" id="m_engineer_station" placeholder="秋葉原"/>
                        <input type="hidden" id="m_engineer_station_cd" value="">
                        <input type="hidden" id="m_engineer_station_pref_cd" value="">
                        <input type="hidden" id="m_engineer_station_line_cd" value="">
                        <input type="hidden" id="m_engineer_station_lon" value="">
                        <input type="hidden" id="m_engineer_station_lat" value="">
					</li>
				</ul>
                <div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;">稼働開始日</span>
                    <input type="text" class="form-control" id="m_engineer_operation_begin" data-date-format="yyyy/mm/dd" placeholder="2018/02/01"/>
				</div>
                <ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 100%; float: left;">
						<span class="input-group-addon" style="min-width: 100px;">担当営業</span>
						<div class="form-control">
							<select class="" style="width: 150px; margin-right: 20px;" id="m_engineer_charging_user_id">
								<option></option>
							{% for item in data['manage.enumAccounts'] %}
								{% if item.is_enabled == True %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
								{% endif %}
							{% endfor %}
							</select>
							<input type="checkbox" name="m_engineer_flg_careful" id="m_engineer_flg_careful">
							<span>要注意フラグ</span>
						</div>
					</li>
					<li class="input-group hidden" style="width: 55%; margin: 0; padding: 0; float: left;">
						<div class="input-group">
							<span class="input-group-addon">稼働</span>
							<input type="text" class="form-control" id="m_engineer_state_work" placeholder="稼動時期を入力ください。例：4月～"/>
						</div>
					</li>
				</ul>
				<div class="input-group hidden">
					<span class="input-group-addon">要注意フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_caution"/>
						<label for="m_engineer_flg_caution" class="text-danger">要注意のエンジニアにチェックしてください</label>
					</span>
				</div>
				<div class="input-group hidden">
					<span class="input-group-addon">共有フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_registered"/>
						<label for="m_engineer_flg_registered" class="text-danger">チェック状態の場合、他のメンバーへ共有されます</label>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;font-size: x-small;">メールアドレス</span>
					<input type="text" class="form-control" id="m_engineer_mail1" placeholder='"@"で保存いただけます。'/>
				</div>
				<div class="input-group" style="display: none;">
					<span class="input-group-addon">メールアドレス（サブ）</span>
					<input type="text" class="form-control" id="m_engineer_mail2"/>
				</div>
                <div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;font-size: smaller;">アサイン可能<br>フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_assignable"/>
						<label for="m_engineer_flg_assignable" class="text-danger">要員がアサイン可能であればチェックしてください</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとホームの要員管理一覧に情報が表示（オープン）されます。<br/>外すことで情報をクローズ中として扱えます。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">他社公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_public"/>
						<label for="m_engineer_flg_public" class="text-danger" style="display: inline">チェック状態の場合、本CRMを利用する他社のユーザへ共有されます</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとSESクラウド利用企業様に要員情報が公開されます。<br/>多くの企業様にシェアされるので見合う案件情報獲得に繋がります。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">Web公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_web_public"/>
						<label for="m_engineer_web_public" class="text-danger" style="display: inline">チェック状態の場合、SESクラウドWebページに情報が公開されます。</label>
					</span>
				</div>
				<div class="input-group hidden">
					<span class="input-group-addon">所属備考</span>
					<input type="text" class="form-control" id="m_engineer_employer" placeholder="所属先の情報を入力ください。例：ABC株式会社"/>
				</div>
                <div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;">経歴書</span>
					<span class="form-control">
						<input type="hidden" id="attachment_id_0"/>
						<label id="attachment_label_0"
							class="bold mono pseudo-link"
							style="display: none;"
							onclick="c4s.download($('#attachment_id_0').val());"></label>

                        <span class=""style="position: relative;">
                            <input type="file" class="input-file" style="opacity: 0;position: absolute;top: 0;left: 0;width: 120px;height: 25px;cursor: pointer;"id="attachment_file_0" onchange="uploadFile(0);"/>
                        </span>
                        <span class="input-file-message"><label  for="attachment_file_0"><button>ファイルを選択</button></label>経歴書を選択してください。</span>
						<button class="btn btn-default pull-right"
							id="attachment_btn_delete_0"
							style="display: none;"
							onclick="deleteAttachment(0);"><span class="glyphicon glyphicon-trash text-danger"></span>&nbsp;削除</button>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>要員データをメール送付する際に経歴書が添付ファイルが付きます。<br/>クラウド上で経歴書を閲覧することも可能です。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">社内備考</span>
					<textarea class="form-control" id="m_engineer_internal_note" style="height: 4em;resize: none;"></textarea>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">備考</span>
					<textarea class="form-control" id="m_engineer_note" style="height: 20em;"></textarea>
				</div>
				<div style="width: 100%; text-align: right; display: none;">
					<label for="m_engineer_dt_created">登録日:</label>
					<span id="m_engineer_dt_created" style="font-family: monospace;"></span>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="($('#m_engineer_id').val() ? updateObj : commitNewObj)();">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_preparation_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_preparation_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_preparation_modal_title">手配状況</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_preparation_engineer_id"/>
				<input type="hidden" id="m_preparation_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<input type="hidden" id="m_preparation_client_id"/>
					<span class="input-group-addon">取引先名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_preparation_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">日時</span>
					<input type="text" class="form-control" id="m_preparation_time"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">進捗</span>
					<input type="text" class="form-control" id="m_preparation_progress" placeholder="面談回数などの進み具合を記録します（例：1/2回目）"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">内容</span>
					<input type="text" class="form-control" id="m_preparation_note" placeholder="案件の内容を記載します（例：PHP社内システム開発）"/>
				</div>
				<div class="clearfix" style="width: 100%; padding-top: 0.5em; overflow: hidden;">
					<button class="btn btn-primary pull-right" onclick="commitPreparation();">保存</button>
				</div>
				<hr/>
				<h5>手配履歴</h5>
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 35px;">編集</th>
							<th>顧客名</th>
							<th>日時</th>
							<th>進捗</th>
							<th>内容</th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody></tbody>
				</table>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

{% include "edit_engineer_skill_condition_modal.tpl" %}

<div id="edit_station_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
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

<div id="add_new_engineer_client_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="commitEngineerClient();">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#add_new_engineer_client_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
					<span id="add_new_engineer_client_modal_title">新規取引先登録</span>
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
					onclick="commitEngineerClient();">保存</button>
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
        <script src="/js/bootstrap-datepicker.ja.js" type="text/javascript"></script>
        <link href="/css/select2.css" rel="stylesheet">
        <script src="/js/select2.js"></script>
		<script type="text/javascript" src="/js/engineer.js"></script>
		<script type="text/javascript">
$(document).ready(function () {
	env.data = env.data || {};
	env.userProfile = JSON.parse('{{ data['auth.userProfile']|tojson }}');
	env.data.skillCategories = JSON.parse('{{ data['skill.enumSkillCategories']|tojson }}');
	env.data.skillLevels = JSON.parse('{{ data['skill.enumSkillLevels']|tojson }}');
	{#
	env.data.workers = JSON.parse('{{ data['client.enumWorkers']|tojson }}');
	env.data.projects = JSON.parse('{{ data['project.enumProjects']|tojson }}');
	env.data.engineers = JSON.parse('{{ data['engineer.enumEngineers']|tojson }}');
	#}
	$("#edit_engineer_modal").on("hide.bs.modal", function () {
		$("#m_engineer_dt_created").parent().css("display", "none");
	});
});
		</script>
	</body>
</html>