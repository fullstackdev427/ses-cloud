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
			<img alt="スケジュール" width="22" height="20" src="/img/icon/group_schedule.png"/> スケジュール
		</div>
		<!-- /検索フォーム -->
		<!-- 検索結果ヘッダー -->
		<div class="row" style="margin-top:20px;margin-bottom:20px;">
			<div class="col-lg-9">
				<select style="vertical-align:middle;" id="queue_acl_filter">
				{% if data['auth.userProfile'].group.name == None %}
					{#<option value="query_acl_filter_user_group">所属グループすべて</option>#}
				{% else %}
					<option value="query_acl_filter_group_{{ data['auth.userProfile'].group.id }}">{{ data['auth.userProfile'].group.name|e }}</option>
				{% endif %}
				{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
					<option value="query_acl_filter_user_{{ item.id }}"{% if item.id == data['auth.userProfile'].user.id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
				{% endfor %}
				</select>
				{#{ buttons.search("c4s.hdlClickSearchBtn();") }#}
				{#{{ buttons.search() }}#}
				{% if env.limit.SHOW_HELP -%}
				&nbsp;<span class="text-danger">左のコンボボックスを選択すると表示が切り替わります。</span>
				{% endif -%}
			</div>
		</div>
		<!-- /検索結果ヘッダー -->
		<!-- 検索結果 -->
		<div class="row" >
			<div id="week-control">
				<div class="pull-left" style="margin: 0 20px">
					<span class="glyphicon glyphicon-fast-backward text-success pseudo-link"
						onclick="jumpToSchedulePage(-1);">&nbsp;<span class="text-success pseudo-link-cursor" style="font-weight: bold;">前週</span></span>
				</div>
				<div class="pull-right" style="margin: 0 20px">
					<span class="text-success pseudo-link" style="font-weight: bold;"
						onclick="jumpToSchedulePage(+1);">来週&nbsp;<span class="glyphicon glyphicon-fast-forward text-success pseudo-link-cursor"></span></span>
				</div>
			</div>
			<div class="row table-responsive">
				<table class="table view_table table-bordered">
					<thead >
						<tr id="account_header">
							{% for dt_label in data['manage.enumSchedules:data_dict'][data['auth.userProfile']['user']['id']]|sort %}
							{% set dt_datum = data['manage.enumSchedules:data_dict'][data['auth.userProfile']['user']['id']][dt_label] %}
							<th>
								{{ dt_label|e }}&nbsp;（{{ data['manage.enumSchedules:day_list'][loop.index0]|e }}）
								<span class="glyphicon glyphicon-pencil text-primary pseudo-link-cursor" title="新規作成"
									onclick="overwriteScheduleForEdit(null, '{{ dt_label|e }}');"></span> &nbsp;
							</th>
							{% endfor %}
						</tr>
						<tr id="group_header" style="display: none;">
							{% set self_schedules = data['manage.enumSchedules:data_dict'][data['auth.userProfile']['user']['id']]|sort %}
							<th colspan="7">{{ self_schedules[0]|e }}（{{ data['manage.enumSchedules:day_list'][0]|e }}）</th>
						</tr>
					</thead>
					<tbody>
					<!-- TODO 動的に切り替える -->
					{% for account_id in data['manage.enumSchedules:data_dict'] %}
						{% set accountDatum = data['manage.enumSchedules:data_dict'][account_id] %}
						{% set accountDatumIsNotEmpty = accountDatum|tojson|length != 126 %}
					{% if account_id != "group" %}
						<tr id="account_schedule_{{ account_id }}" style="display: none;">
						{% if accountDatumIsNotEmpty %}
							{% for dt_label in accountDatum|sort %}
							<td style="min-height: 200px; vertical-align: top;">
							{% set dt_datum = accountDatum[dt_label] %}
							{% for item in dt_datum %}
								<span id="iter_schedule_{{ item .id }}"
									class="popover-dismiss"
									data-toggle="popover"
									data-placement="top"
									data-content="{{ item.note|e }}"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');">
									<span style="font-weight: bold;">{{ item.dt_scheduled[11:16] }}</span>&nbsp;
									<span class="pseudo-link" id="iter_schedule_{{ item.id }}"
										style=""
										title="{{ item.creator.user_name|e }}"
										onclick="overwriteScheduleForEdit(env.data.schedules[{{ item.id }}]);">
								{% if item.title|length > 20 %}
									{{ item.title[:20]|e }}...
								{% else %}
									{{ item.title|e }}
								{% endif %}
									</span>
									<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor" title="削除"
										onclick="c4s.hdlClickDeleteItem('schedule', {{ item.id }}, true);"></span>
									{% if loop.index < dt_datum|length %}
									<hr style="width: 100%; margin: 0.3em auto; border-color: #999; border-style: dotted;"/>
									{% endif %}
								</span>
							{% endfor %}
							</td>
							{% endfor %}
						{% else %}
							<td colspan="7">（有効なデータはありません）</td>
						{% endif %}
						</tr>
					{% else %}
						{#<tr id="account_schedule_group" style="min-height: 400px;">
							<td colspan="7" style="vertical-align: top;">
							{% for item in accountDatum|sort(attribute="dt_scheduled") %}
								<span id="iter_schedule_group{{ item.id }}">
									<span style="font-weight: bold;">{{ item.dt_scheduled[11:16] }}</span>&nbsp;
									<span class="pseudo-link"
										title="{{ item.note }}">
										{% if item.title|length > 20 %}
											{{ item.title[:20]|e }}...
										{% else %}
											{{ item.title|e }}
										{% endif %}
									</span>
									（{{ item.creator.user_name|e }}）
								</span>
								{% if loop.index < accountDatum|length %}
								<br/><hr style="width: 100%; margin: 0.3em auto; border-color: #999; border-style: dotted;"/>
								{% endif %}
							{% endfor %}
							</td>
						</tr>#}
					{% endif %}
					{% endfor %}
					<!-- /TODO 動的に切り替える -->
					</tbody>
				</table>
			</div>
		</div>
		<!-- /検索結果 -->
		<div class="row" id="input_schedule_container" style="display: none;">
			<h4 id="input_schedule_title">スケジュール登録</h4>
			<div class="form-group">
				<input type="hidden" id="input_0_id"/>
				<div class="input-group">
					<span class="input-group-addon">日時</span>
					<input type="text" class="" id="input_0_dt_scheduled_date" data-date-format="yyyy/mm/dd" readOnly="readOnly"/>&nbsp;
					<select id="input_0_dt_scheduled_hh">
						<option value="00">00</option>
						<option value="01">01</option>
						<option value="02">02</option>
						<option value="03">03</option>
						<option value="04">04</option>
						<option value="05">05</option>
						<option value="06">06</option>
						<option value="07">07</option>
						<option value="08">08</option>
						<option value="09">09</option>
						<option value="10">10</option>
						<option value="11">11</option>
						<option value="12">12</option>
						<option value="13">13</option>
						<option value="14">14</option>
						<option value="15">15</option>
						<option value="16">16</option>
						<option value="17">17</option>
						<option value="18">18</option>
						<option value="19">19</option>
						<option value="20">20</option>
						<option value="21">21</option>
						<option value="22">22</option>
						<option value="23">23</option>
					</select>&nbsp;時
					<select id="input_0_dt_scheduled_mm">
						<option value="00">00</option>
						<option value="05">05</option>
						<option value="10">10</option>
						<option value="15">15</option>
						<option value="20">20</option>
						<option value="25">25</option>
						<option value="30">30</option>
						<option value="35">35</option>
						<option value="40">40</option>
						<option value="45">45</option>
						<option value="50">50</option>
						<option value="55">55</option>
					</select>&nbsp;分
				</div>
				<div class="input-group">
					<span class="input-group-addon">題名</span>
					<input type="text" class="form-control" id="input_0_title"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">内容</span>
					<textarea class="form-control" id="input_0_note"></textarea>
				</div>
				<div style="text-align: right;">
					<button type="button" class="btn btn-primary"
						onclick="($('#input_0_id').val() ? updateObj : createObj)();">登録</button>
				</div>
			</div>
		</div>
	</div>
{% else -%}
	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
				<img alt="スケジュール" width="22" height="20" src="/img/icon/group_schedule.png"/> スケジュール
				{% if env.limit.SHOW_HELP -%}
				<p style="margin: 0.5em; 1em;">以下、「日付」横にある編集アイコン&nbsp;<span class="glyphicon glyphicon-pencil text-primary"></span>&nbsp;より営業スケジュールを入力して下さい。<br/>検索で各営業のスケジュールやグループ毎のスケジュールを確認することができます。</p>
				{% endif -%}
			</div>
			<!-- /検索フォーム -->
			<!-- 検索結果ヘッダー -->
			<div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-9">
					<select style="vertical-align:middle;" id="queue_acl_filter">
					{% if data['auth.userProfile'].group.name == None %}
						{#<option value="query_acl_filter_user_group">所属グループすべて</option>#}
					{% else %}
						<option value="query_acl_filter_group_{{ data['auth.userProfile'].group.id }}">{{ data['auth.userProfile'].group.name|e }}</option>
					{% endif %}
					{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
						<option value="query_acl_filter_user_{{ item.id }}"{% if item.id == data['auth.userProfile'].user.id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
					{% endfor %}
					</select>
					{#{ buttons.search("c4s.hdlClickSearchBtn();") }#}
					{#{{ buttons.search() }}#}
					{% if env.limit.SHOW_HELP -%}
					&nbsp;<span class="text-danger">左のコンボボックスを選択すると表示が切り替わります。</span>
					{% endif -%}
				</div>
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class="row" >
				<div id="week-control">
					<div class="col-md-4" style="text-align: left;">
						<span class="glyphicon glyphicon-fast-backward text-success pseudo-link"
							onclick="jumpToSchedulePage(-1);">&nbsp;<span class="text-success pseudo-link-cursor" style="font-weight: bold;">前週</span></span>
					</div>
					<div class="col-md-4 col-md-offset-4" style="text-align: right;">
						<span class="text-success pseudo-link" style="font-weight: bold;"
							onclick="jumpToSchedulePage(+1);">来週&nbsp;<span class="glyphicon glyphicon-fast-forward text-success pseudo-link-cursor"></span></span>
					</div>
				</div>
				<table class="view_table table-bordered">
					<thead >
						<tr id="account_header">
							{% for dt_label in data['manage.enumSchedules:data_dict'][data['auth.userProfile']['user']['id']]|sort %}
							{% set dt_datum = data['manage.enumSchedules:data_dict'][data['auth.userProfile']['user']['id']][dt_label] %}
							<th style="width: 14%;">
								{{ dt_label|e }}&nbsp;（{{ data['manage.enumSchedules:day_list'][loop.index0]|e }}）&nbsp;
								<span class="glyphicon glyphicon-pencil text-primary pseudo-link-cursor" title="新規作成"
									onclick="overwriteScheduleForEdit(null, '{{ dt_label|e }}');"></span><br/>
							</th>
							{% endfor %}
						</tr>
						<tr id="group_header" style="display: none;">
							{% set self_schedules = data['manage.enumSchedules:data_dict'][data['auth.userProfile']['user']['id']]|sort %}
							<th colspan="7">{{ self_schedules[0]|e }}（{{ data['manage.enumSchedules:day_list'][0]|e }}）</th>
						</tr>
					</thead>
					<tbody>
					<!-- TODO 動的に切り替える -->
					{% for account_id in data['manage.enumSchedules:data_dict'] %}
						{% set accountDatum = data['manage.enumSchedules:data_dict'][account_id] %}
						{% set accountDatumIsNotEmpty = accountDatum|tojson|length != 126 %}
					{% if account_id != "group" %}
						<tr id="account_schedule_{{ account_id }}" style="display: none;">
						{% if accountDatumIsNotEmpty %}
							{% for dt_label in accountDatum|sort %}
							<td style="min-height: 200px; vertical-align: top;">
							{% set dt_datum = accountDatum[dt_label] %}
							{% for item in dt_datum %}
								<span id="iter_schedule_{{ item .id }}"
									class="popover-dismiss"
									data-toggle="popover"
									data-placement="top"
									data-content="{{ item.note|e }}"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');">
									<span style="font-weight: bold;">{{ item.dt_scheduled[11:16]|e }}</span>&nbsp;
									<span class="pseudo-link" id="iter_schedule_{{ item.id }}"
										style=""
										title="{{ item.creator.user_name|e }}"
										onclick="overwriteScheduleForEdit(env.data.schedules[{{ item.id }}]);">
								{% if item.title|length > 20 %}
									{{ item.title[:20] }}...
								{% else %}
									{{ item.title }}
								{% endif %}
									</span>
									<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor" title="削除"
										onclick="c4s.hdlClickDeleteItem('schedule', {{ item.id }}, true);"></span>
									{% if loop.index < dt_datum|length %}
									<hr style="width: 100%; margin: 0.3em auto; border-color: #999; border-style: dotted;"/>
									{% endif %}
								</span>
							{% endfor %}
							</td>
							{% endfor %}
						{% else %}
							<td colspan="7">（有効なデータはありません）</td>
						{% endif %}
						</tr>
					{% else %}
						{#<tr id="account_schedule_group" style="min-height: 400px;">
							<td colspan="7" style="vertical-align: top;">
							{% for item in accountDatum|sort(attribute="dt_scheduled") %}
								<span id="iter_schedule_group{{ item.id }}">
									<span style="font-weight: bold;">{{ item.dt_scheduled[11:16]|e }}</span>&nbsp;
									<span class="pseudo-link"
										title="{{ item.note|e }}">
										{% if item.title|length > 20 %}
											{{ item.title[:20]|e }}...
										{% else %}
											{{ item.title|e }}
										{% endif %}
									</span>
									（{{ item.creator.user_name|e }}）
								</span>
								{% if loop.index < accountDatum|length %}
								<br/><hr style="width: 100%; margin: 0.3em auto; border-color: #999; border-style: dotted;"/>
								{% endif %}
							{% endfor %}
							</td>
						</tr>#}
					{% endif %}
					{% endfor %}
					<!-- /TODO 動的に切り替える -->
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
			<div class="row" id="input_schedule_container" style="display: none;">
				<h4 id="input_schedule_title">スケジュール登録</h4>
				<div class="form-group">
					<input type="hidden" id="input_0_id"/>
					<div class="input-group">
						<span class="input-group-addon">日時</span>
						<input type="text" class="" id="input_0_dt_scheduled_date" data-date-format="yyyy/mm/dd" readOnly="readOnly"/>&nbsp;
						<select id="input_0_dt_scheduled_hh">
							<option value="00">00</option>
							<option value="01">01</option>
							<option value="02">02</option>
							<option value="03">03</option>
							<option value="04">04</option>
							<option value="05">05</option>
							<option value="06">06</option>
							<option value="07">07</option>
							<option value="08">08</option>
							<option value="09">09</option>
							<option value="10">10</option>
							<option value="11">11</option>
							<option value="12">12</option>
							<option value="13">13</option>
							<option value="14">14</option>
							<option value="15">15</option>
							<option value="16">16</option>
							<option value="17">17</option>
							<option value="18">18</option>
							<option value="19">19</option>
							<option value="20">20</option>
							<option value="21">21</option>
							<option value="22">22</option>
							<option value="23">23</option>
						</select>&nbsp;時
						<select id="input_0_dt_scheduled_mm">
							<option value="00">00</option>
							<option value="05">05</option>
							<option value="10">10</option>
							<option value="15">15</option>
							<option value="20">20</option>
							<option value="25">25</option>
							<option value="30">30</option>
							<option value="35">35</option>
							<option value="40">40</option>
							<option value="45">45</option>
							<option value="50">50</option>
							<option value="55">55</option>
						</select>&nbsp;分
					</div>
					<div class="input-group">
						<span class="input-group-addon">題名</span>
						<input type="text" class="form-control" id="input_0_title"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">内容</span>
						<textarea class="form-control" id="input_0_note"></textarea>
					</div>
					<div style="text-align: right;">
						<button type="button" class="btn btn-primary"
							onclick="($('#input_0_id').val() ? updateObj : createObj)();">登録</button>
					</div>
				</div>
			</div>
		</div>
	</div>
{% endif -%}
<!-- /メインコンテンツ -->
<!-- [begin] Modal. -->
{% include "cmn_cap_mail_per_month.tpl" %}
<!-- [end] Modal. -->
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
        <script type="text/javascript" src="/js/bootstrap-datepicker.js"></script>
        <script src="/js/bootstrap-datepicker.ja.js"></script>
		<script src="/js/schedule.js" type="text/javascript"></script>
	</body>
</html>