{% import "cmn_controls.macro" as buttons -%}
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
			<img alt="取引先" width="22" height="20" src="/img/icon/group_client.png"> 請求書 一覧
		</div>
		<div id="search-form-accordion" class="row list-group" style="/*background-color: #f1f1f1;*/">
			<a data-toggle="collapse" data-parent="#search-form-accordion" href="#search-form" class="list-group-item">
				<span class="bold list-header">検索条件:</span>
				<ol class="breadcrumb" style="padding: 0px; margin: 0px;">
					{%if query.name %}<li>取引先名"{{ query.name|e }}"</li>{% endif %}
					{%if query.charging_worker %}<li>営業担当"
						{% for item in data['manage.enumAccounts'] %}
							{% if item.is_enabled == True and query.charging_worker == item.id|string %}
							 {{ item.name|e }}
							{% endif %}
						{% endfor %}"</li>
					{% endif %}
					{%if query.note %}<li>備考"{{ query.note|e }}"</li>{% endif %}
					{%if query.type_presentation %}<li>提案区分"{{ query.type_presentation|e }}"</li>{% endif %}
					{%if query.type_dealing %}<li>取引区分"{{ query.type_dealing|e }}"</li>{% endif %}
				</ol>
			</a>
			<form onsubmit="c4s.hdlClickSearchBtn(); return false;" id="search-form" class="collapse">
				<!--input type="submit" style="width: 1px; height: 1px; "/-->
				<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
					<li style="margin: 1px 2em; float: left;">
						<label for="query_name" style="color: #666666; width: 5em;">取引先名</label>
						<input type="text" id="query_name"{% if query.name %} value="{{ query.name|e }}"{% endif %}/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_charging_worker" style="color: #666666; width: 5em;">営業担当</label>
						<select id="query_charging_worker">
							<option selected="selected">すべて</option>
							{% for item in data['manage.enumAccounts'] %}
							{% if item.is_enabled == True %}
							<option value="{{ item.id }}"{% if query.charging_worker == item.id|string %} selected="selected"{% endif %}>{{ item.name|e }}</option>
							{% endif %}
							{% endfor %}
						</select>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_note" style="color: #666666; width: 5em;">備考</label>
						<input type="text" id="query_note"{% if query.note %} value="{{ query.note|e }}"{% endif %}/>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_type_presentation" style="color: #666666; width: 5em;">提案区分</label>
						<select class="" id="query_type_presentation">
							<option>すべて</option>
						{% for item, detail in presentations %}
							<option value="{{ item }}"{% if "type_presentation" in query and query['type_presentation'] == item %} selected="selected"{% endif %}>{{ detail }}</option>
						{% endfor %}
						</select>
					</li>
					<li style="margin: 1px 2em; float: left;">
						<label for="query_type_dealing" style="color: #666666; width: 5em;">取引区分</label>
						<select class="" id="query_type_dealing">
							<option>すべて</option>
							{% for item in dealings %}
							<option value="{{ item }}"{% if item == query.type_dealing %} selected="selected"{% endif %}>{{ item }}</option>
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
		<div class="row" style="margin-top:20px;margin-bottom:20px;">
			<div class="col-lg-9">
				{{ buttons.new_obj("hdlClickNewClient();") }}
				{{ buttons.delete_checked("deleteItems();") }}
			</div>
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['client.enumClients']) }}
			<!-- /件数 -->
		</div>
		<!-- /検索結果ヘッダー -->
		<!-- 検索結果 -->
		<div class="table-responsive row" >
			<table class="table view_table table-bordered table-hover">
				<thead>
					<tr>
						<th style="width: 35px;">選択<br><input type="checkbox" id="iter_client_selected_cb_0" onclick="c4s.toggleSelectAll('iter_client_selected_cb_', this);"/></th>
						<th><span class="">
							{{ buttons.th(query, '取引先名', 'kana') }}
						</span></th>
						<th style="width: 130px;">代表電話番号</th>
					</tr>
				</thead>
				<tbody>
				{% if data['client.enumClients'] %}
					{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
					{% set items = data['client.enumClients'][row_min:row_min + env.limit.ROW_LENGTH] %}
					{% for item in items %}
					<tr id="iter_client_{{item.id}}">
						<td class="text-center"><input type="checkbox" id="iter_client_selected_cb_{{ item.id }}"/></td>
						<td><span class="pseudo-link" title="{{ item.kana|e }}"
							onclick="overwriteClientModalForEdit({{ item.id }});">
								{% if item.type_dealing == "重要客" %}
									<span class="glyphicon glyphicon-ok-circle text-info" title="重要客"></span>
								{% elif item.type_dealing == "通常客" %}
									<span class="glyphicon glyphicon-ok-circle text-success" title="通常客"></span>
								{% elif item.type_dealing == "低ポテンシャル" %}
									<span class="glyphicon glyphicon-ok-circle text-muted" title="低ポテンシャル"></span>
								{% elif item.type_dealing == "取引停止" %}
									<span class="glyphicon glyphicon-ban-circle text-danger" title="取引停止"></span>
								{% else %}

								{% endif %}
								&nbsp;{{ item.name|truncate(12, True)|e }}
							</span>
						</td>
						<td class="center">{%if item.tel %}<a href="tel:{{ item.tel|replace('-', '')|e }}">{{ item.tel|e }}</a>{% endif %}</td>
					</tr>
					{% endfor %}
				{% else %}
					<tr id="iter_client_0">
						<td colspan="3">有効なデータがありません</td>
					</tr>
				{% endif %}
				</tbody>
			</table>
		</div>
		<!-- /検索結果 -->
		<div class="row" style="margin-top: 0.5em;">
			<!-- 件数 -->
			{{ buttons.paging(query, env, data['client.enumClients']) }}
			<!-- /件数 -->
		</div>
	</div>
{% else -%}
	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
				<img alt="取引先" width="22" height="20" src="/img/icon/group_client.png"> 請求書 一覧
			</div>
			<div class="row" style="/*background-color: #f1f1f1;*/">
				<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
					<!--input type="submit" style="width: 1px; height: 1px; "/-->
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
						<li style="margin: 0 2em; float: left;">
							<label for="query_name" style="color: #666666;">取引先名</label>
							<input type="text" id="query_name"{% if query.name %} value="{{ query.name|e }}"{% endif %}/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_charging_worker" style="color: #666666;">営業担当</label>
							<select id="query_charging_worker">
								<option selected="selected">すべて</option>
								{% for item in data['manage.enumAccounts'] %}
								{% if item.is_enabled == True %}
								<option value="{{ item.id }}"{% if query.charging_worker == item.id|string %} selected="selected"{% endif %}>{{ item.name|e }}</option>
								{% endif %}
								{% endfor %}
							</select>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_note" style="color: #666666;">備考</label>
							<input type="text" id="query_note"{% if query.note %} value="{{ query.note|e }}"{% endif %}/>
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
                            <label for="query_note" style="color: #666666;">案件</label>
                            <input type="text" id="query_note"/>
                        </li>
                        <li style="margin: 0 2em; float: left;">
                            <label for="query_note" style="color: #666666;">発行月</label>
                            <input type="month" id="query_note"/>
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
				<div class="col-lg-9">
					{{ buttons.new_obj("hdlClickNewClient();") }}
					{{ buttons.delete_checked("deleteItems();") }}
				</div>
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['client.enumClients']) }}
				<!-- /件数 -->
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class="row" >
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 35px;">選択<br><input type="checkbox" id="iter_client_selected_cb_0" onclick="c4s.toggleSelectAll('iter_client_selected_cb_', this);"/></th>
							<th style="width: 70px;">発行月</th>
                            <th><span class="">
								{{ buttons.th(query, '取引先名', 'kana') }}
							</span></th>
							<th style="width: 35px;">Web</th>
							<th style="width: 130px;">代表電話番号</th>
							<th style=""><span class="">住所</span></th>
							{% if env.limit.LMT_ACT_MAP -%}
							<th>Map</th>
							{% endif -%}
							<th style="width: 45px;">
								<span class="">{{ buttons.th(query, '提案区分', 'type_presentation') }}</span>
							</th>
							<th style="width: 85px;">
								{{ buttons.th(query, '自社営業<br/>担当', 'charging_worker_1') }}</th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
						<!-- TODO 動的に切り替える -->
					{% if data['client.enumClients'] %}
						{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
						{% set items = data['client.enumClients'][row_min:row_min + env.limit.ROW_LENGTH] %}
						{% for item in items %}
						<tr id="iter_client_{{item.id}}">
							<td class="text-center"><input type="checkbox" id="iter_client_selected_cb_{{ item.id }}"/></td>
                            <td class="center">2017年8月</td>
							<td><span class="pseudo-link" title="{{ item.kana|e }}"
								onclick="overwriteClientModalForEdit({{ item.id }});">
									{% if item.type_dealing == "重要客" %}
										<span class="glyphicon glyphicon-ok-circle text-info" title="重要客"></span>
									{% elif item.type_dealing == "通常客" %}
										<span class="glyphicon glyphicon-ok-circle text-success" title="通常客"></span>
									{% elif item.type_dealing == "低ポテンシャル" %}
										<span class="glyphicon glyphicon-ok-circle text-muted" title="低ポテンシャル"></span>
									{% elif item.type_dealing == "取引停止" %}
										<span class="glyphicon glyphicon-ban-circle text-danger" title="取引停止"></span>
									{% else %}

									{% endif %}
									&nbsp;{{ item.name|truncate(12, True)|e }}
								</span>&nbsp;
								<!--
								<span class="badge pseudo-link-cursor pull-right popover-dismiss"
									title="コンタクト数"
									data-container="body"
									data-toggle="popover"
									data-placement="left"
									data-content="コンタクトの一覧と追加はこちらをクリックしてください。"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');"
									onclick="overwriteContactModalForEdit({{ item.id }}, '{{ item.name|e }}');">コンタクト数：{{ item.contact_length or "0" }}</span>
								-->
							</td>
							<td class="center">{% if item.site != None and item.site.startswith("http") %}<a href="{{ item.site|e }}" target="_blank"><span class="glyphicon glyphicon-globe text-primary"></span></a>{% endif %}</td>
							<td class="center">{%if item.tel %}<a href="tel:{{ item.tel|replace('-', '')|e }}">{{ item.tel }}</a>{% endif %}</td>
							<td>{#〒{{ item.addr_vip }} #}{#{{ item.addr1 }}{% if item.addr2 %}<br/>&nbsp;&nbsp;{{ item.addr2 }}{% endif %}#}{{ (item.addr1 + item.addr2)|truncate(12, True)|e }}</td>
							{% if env.limit.LMT_ACT_MAP -%}
							<td class="center">
								{% if item.addr1 %}
									{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
									<span class="glyphicon glyphicon-globe text-success pseudo-link-cursor"
										onclick="c4s.openMap({target_id: '{{ item.id|e }}', target_type: 'client', name: '{{ item.name|e }}', addr1: '{{ item.addr1|e }}', addr2: '{{ item.addr2|e }}', tel: '{{ item.tel|e }}', modalId: null, isFloodLMT: false, current: env.current});"></span>
									{% else %}
									<span class="glyphicon glyphicon-globe text-muted pseudo-link-cursor"
										title="Over Limit of Map"
										onclick="c4s.openMap({isFloodLMT: true});"></span>
									{% endif %}
								{% endif %}
							</td>
							{% endif -%}
							<td class="center">{% if item.type_presentation|join("・") == "案件・人材" %}案・人{% else %}{{ item.type_presentation|join("・")|e }}{% endif %}</td>
							<td class="center">
							{% if item.charging_worker1.id %}
								{% if item.charging_worker1.is_enabled == False %}
								<span class="glyphicon glyphicon-ban-circle text-danger" title="無効化されたユーザーです"></span>&nbsp;
								{% endif %}
								<span class=""
									onclick="/*jumpToClientWorkerPageWithQuery({{ item.charging_worker1.id }});*/">{{ item.charging_worker1.name }}
								</span>
							{% endif %}
							{#
							{% if item.charging_worker2.id %}
							<br/>
								{% if item.charging_worker2.is_enabled == False %}
								<span class="glyphicon glyphicon-ban-circle text-danger" title="無効化されたユーザーです"></span>&nbsp;
								{% endif %}
								<span class="pseudo-link">{{ item.charging_worker2.name|e }}</span>
							{% endif %}
							#}
							</td>
							<td class="center text-justify">
								<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor"
									title="削除"
									onclick="c4s.hdlClickDeleteItem('client', {{ item.id }}, true);"></span>
							</td>
						</tr>
						{% endfor %}
					{% else %}
						<tr id="iter_client_0">
							<td colspan="9">有効なデータがありません</td>
						</tr>
					{% endif %}
						<!-- /TODO 動的に切り替える -->
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
			<div class="row" style="margin-top: 0.5em;">
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['client.enumClients']) }}
				<!-- /件数 -->
			</div>
		</div>
	</div>
{% endif -%}
<!-- /メインコンテンツ -->

<!-- [begin] Modal. -->
<!-- [begin] Modal for client instance -->
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
					<input type="text" class="form-control" id="m_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">取引先名（カナ）<span class="text-danger">*</span></span>
					<input type="test" class="form-control" id="m_client_kana"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">郵便番号</span>
					<input type="text" class="form-control" id="m_client_addr_vip" placeholder="nnn-nnnn" style="width: 8em;" maxlength="8"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#m_client_addr_vip').val(), '#m_client_addr1', '#m_client_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
					{% if env.limit.LMT_ACT_MAP -%}
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) -%}
						<span class="input-group-btn">
							<button class="btn btn-default"
								onclick="c4s.openMap({target_id: $('#m_client_id').val(), target_type: 'client', name: $('#m_client_name').val(), addr1: $('#m_client_addr1').val(), addr2: $('#m_client_addr2').val(), tel: $('#m_client_tel').val(), modalId: 'edit_client_modal', isFloodLMT: false, current: env.current});">
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
<!-- [end] Modal for client instance -->
{% include "cmn_cap_mail_per_month.tpl" %}
{% include "cmn_cap.tpl" %}
<!-- [end] Model. -->

{% include "cmn_cap.tpl" %}

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script src="/js/manage.js" type="text/javascript"></script>
        <script src="/js/client.js" type="text/javascript"></script>
		<script type="text/javascript">
$(document).ready(function (){
	if (env) {
		env.data = {};
		env.data.accounts = JSON.parse('{{ data['js.accounts']|tojson }}');
		{#
		env.limit = JSON.parse('{{ env.limit|tojson }}');
		#}
	}
	hdlClickRefreshMigrateRequests();
});
		</script>
	</body>
</html>
