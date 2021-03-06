{% import "cmn_controls.macro" as buttons -%}
{% set priorities = ("高", "中", "低") -%}
{% set statuses = ("すべて", "完了", "未完") -%}
{% set contracts = ("正社員", "契約社員", "個人事業主", "パートナー") -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
{% include "cmn_header.tpl" %}
<!-- メインコンテンツ -->
{% if "iPhone" in env.UA or "Android" in env.UA -%}
	<div class="sp_content">
		<!-- 要員管理 -->
		<div style="margin-top: 1em;">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_interview.png" width="22" height="20" alt="要員"> 要員 管理
			</div>
			<ul class="row" style="margin-bottom:5px; padding: 0; list-style-type: none; overflow: hidden;">
			{% if env.limit.LMT_ACT_MAIL -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.mail_all("triggerMailEngineerOnHome();", "対象データを選択し、「一括メール」ボタンを押下すると取引先へメールできます") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.remind("openReminderFormOfEngineer();", "「リマインダ」ボタンを押下すると自社向けに情報をリマインドします") }}
				</li>
			{% endif -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.delete_checked("deleteItems('engineer');") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					<span class="btn" onclick="exportPdfEngineer();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.new_obj("hdlClickNewEngineerObj();") }}
				</li>
			</ul>
			{% if env.limit.SHOW_HELP %}
			<div class="row" style="margin-bottom:10px;">
{#				「アサイン可能フラグ」、「共有フラグ」がチェックされたデータを表示しています。<br/>#}
                「アサイン可能フラグ」がチェックされたデータを表示しています。<br/>
				「手配数」をクリックすると手配情報を追加できます。<br /><span class="pull-right popover-video"
					data-toggle="popover"
					data-placement="right"
					data-content="<a href='#' style='font-weight: bold' class='video-click'>マッチング検索</a>"
					data-html="true"><a href="#" style="font-weight: bold" onclick="c4s.hdlClickDirectionBtn('home.direction');">解説動画はコチラ≫</a></span>
			</div>
			{% endif %}
			<div class="row table-responsive">
				<table class="table view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 25px;"><input type="checkbox" id="iter_engineer_selected_cb_0" onclick="c4s.toggleSelectAll('iter_engineer_selected_cb_', this);"/></th>
							<th>要員名</th>
							<th>スキル</th>
							<th style="width: 35px;">経歴書</th>
						</tr>
					</thead>
					<tbody>
					{% if data['engineer.enumEngineers'] %}
					{% set datum = data['engineer.enumEngineers']|rejectattr('flg_registered', 'even')|rejectattr('flg_assignable', 'even') %}
						{% for item in datum -%}
						{% if loop.index0 < 10 -%}
							<tr id="iter_engineer_{{ item.id }}">
								<td class="text-center">
									<input type="checkbox" id="iter_engineer_selected_cb_{{ item.id }}"/>
								</td>
								<td>
									<span class="pseudo-link bold"
										onclick="overwriteModalForEditEngineer({{ item.id }});">{{ item.name|truncate(12, True)|e }}</span>
									{% if item.flg_careful == True %}
										<span class="pseudo-link-cursor glyphicon glyphicon-exclamation-sign"
											data-toggle="popover"
											data-placement="right"
											data-content="要注意フラグ"
											onmouseover="$(this).popover('show');"
											onmouseout="$(this).popover('hide');"></span>
									{% endif %}
									<span class="badge pseudo-link-cursor pull-right"
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
						{% endif -%}
						{% endfor -%}
					{% else %}
						<tr id="iter_engineer_0">
							<td colspan="4">有効なデータがありません</td>
						</td>
					{% endif %}
					</tbody>
				</table>
			</div>
			<div style="margin-top:1em; text-align:right;">
				<span class="btn" onclick="c4s.hdlClickGnaviBtn('engineer.top', {flg_assignable: true});">要員一覧</span>
			</div>
		</div>
		<!-- /要員管理 -->
		<div style="margin-top: 2em; margin-bottom: 2em; border-top: 1px solid #BBBBBB;"></div>
		<!-- 案件管理 -->
		<div style="">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_case.png" width="22" height="20" alt="案件"> 案件 管理
			</div>
			<div class="row" style="margin-bottom:5px;">
				<div id='interview_list_error_massage'></div>
			</div>
			<ul class="row" style="margin-bottom:5px; padding: 0; list-style-type: none; overflow: hidden;">
			{% if env.limit.LMT_ACT_MAIL -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.mail_all("openMailFormOfProject();", "対象データを選択し、「一括メール」ボタンを押下すると取引先へメールできます") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.remind("openReminerFormOfProject();", "「リマインダ」ボタンを押下すると自社向けに情報をリマインドします") }}
				</li>
			{% endif -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.delete_checked("if(deleteItems('project')) {c4s.jumpToPage(env.current);}") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					<span class="btn" onclick="exportPdfProject();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.new_obj("hdlClickNewProjectObj();") }}
				</li>
			</ul>
			{% if env.limit.SHOW_HELP %}
			<div class="row" style="margin-bottom:10px;">
				案件内容をクリックすると詳細情報が表示されます。<br />
				対象データを選択し、「一括メール」ボタンを押下することで自動的にメールを生成します。
			</div>
			{% endif %}
			<div class="row table-responsive">
				<table class="table view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 25px;"><input type="checkbox" id="iter_project_selected_cb_0" onclick="c4s.toggleSelectAll('iter_project_selected_cb_', this);"/></th>
							<th>取引先名</th>
							<th>案件内容<br/>／スキル</th>
						</tr>
					</thead>
					<tbody>
					{% if data['project.enumProjects'] %}
					{% set projects = data['project.enumProjects']|rejectattr('is_enabled', 'even')|rejectattr('flg_shared', 'even') -%}
					{% for item in projects -%}
						{% if loop.index0 < 10 -%}
						<tr>
							<td class="center">
								<input type="checkbox" id="iter_project_selected_cb_{{ item.id }}"/>
							</td>
							<td>
								{% if item.client_name and not item.client.name %}
								<span>{{ item.client_name|truncate(12, True)|e }}</span>
								{% else %}
								<span class="pseudo-link"
									onclick="overwriteClientModalForEdit({{ item.client.id }});">{{ item.client.name|truncate(12, True) }}</span>
								{% endif %}
							</td>
							<td>
								<span class="pseudo-link bold"
									onclick="overwriteModalForEditProject({{ item.id }});">{{ item.title|truncate(12, True)|e }}</span><br/>／{% if item.skill_list %}{{ item.skill_list|truncate(12, True)|e }}{% endif %}</td>
						</tr>
						{% endif -%}
					{% endfor -%}
					{% else %}
						<tr>
							<td colspan="3">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
			<div style="margin-top:1em; text-align:right;">
				<span class="btn" onclick="c4s.hdlClickGnaviBtn('project.top', {flg_shared: true});">案件一覧</span>
			</div>
		</div>
		<!-- /案件管理 -->
		<div style="margin-top: 2em; margin-bottom: 2em; border-top: 1px solid #BBBBBB;"></div>
		<!-- メンバー スケジュール -->
		<div style="">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_schedule.png" width="22" height="20" alt="スケジュール"> メンバー スケジュール（{{ data['today_str'] }}）
				<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
					data-toggle="popover"
					data-content="グループの営業スケジュールを表示しています"
					onmouseover="$(this).popover('show');"
					onmouseout="$(this).popover('hide');"></span>
			</div>
			<div style="margin: 0.5em 0;">
				{{ buttons.new_obj("c4s.hdlClickGnaviBtn('misc.scheduleTop');") }}
			</div>
			<div class="row table-responsive">
				<table class="table view_table table-bordered table-hover">
				{% set datum = data['enumGroupSchedules'] %}
					<thead>
						<tr>
							<th colspan="3">{{ data.today_str }}</th>
						</tr>
						<tr>
							<th style="width: 130px;"></th>
							{% set acc_k = data['auth.userProfile'].user.id -%}
							<th style="width: auto;"><span title="{{ data['enumAccounts'][acc_k].login_id|e }}">{{ data['enumAccounts'][acc_k].name|e }}</span></th>
							<th style="width: auto;"><span title="グループメンバー">グループメンバー</span></th>
						</tr>
					</thead>
					<tbody>
					{% for tt in datum|sort -%}
						<tr{% if tt[:8] <= data.now_str and data.now_str < tt[11:] %} style="background-color: #ccff66;"{% endif %}>
							<td class="center bold">
								{{ tt[:8] }}<br/>～&nbsp;{{ tt[11:] }}
							</td>
							{% set acc_k = data['auth.userProfile'].user.id -%}
							{% set cnt = 0 %}
							<td class="bold">
							{% for sch in datum[tt][acc_k]|sort(attribute='dt_scheduled') -%}
								{% set cnt = cnt + 1 %}
								<span class="popover-dismiss pseudo-link-cursor"
									title="{{ sch.title|e }} （{{ sch.dt_scheduled[11:] }}～）"
									data-html="true"
									data-content="{{ (sch.note|replace('\n', '<br/>') or "（空白）")|e }}"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');">
									{% if sch.title|length > 12 %}
										{{ sch.title|truncate(12, True)|e }}
									{% else %}
										{{ sch.title|e }}
									{% endif %}
									（{{ sch.dt_scheduled[11:] }}～）
								</span>
								{% if cnt < datum[tt][acc_k]|length -%}
								<hr style="margin: 0.2em 1em;"/>
								{% endif -%}
							{% endfor -%}
							</td>
							<td>
							{% set sch_dict = datum[tt] -%}
							{% for acc_k in sch_dict -%}
							{% if acc_k != data['auth.userProfile'].user.id -%}
							{% set sch_list = sch_dict[acc_k]|sort(attribute='dt_scheduled') -%}
							{% for sch in sch_list -%}
								<span class="popover-dismiss pseudo-link-cursor"
									style="display: inline-block; margin: 0.1em 0.5em; padding: 0.1em 0.5em; border: solid 1px #ccc; border-radius: 3px; float: left;"
									title="{{ sch.title|e }} （{{ sch.dt_scheduled[11:] }}～）"
									data-html="true"
									data-content="{{ (sch.note|replace('\n', '<br/>') or "（空白）")|e }}"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');">
									{% if sch.title|length > 12 %}
										{{ sch.title|truncate(12, True)|e }}
									{% else %}
										{{ sch.title|e }}
									{% endif %}
									（{{ sch.creator.user_name|e }}:&nbsp;{{ sch.dt_scheduled[11:] }}～）
								</span>
							{% endfor -%}
							{% endif -%}
							{% endfor -%}

							</td>
						</tr>
					{% endfor -%}
					</tbody>
				</table>
			</div>
		</div>
		<!-- /メンバー スケジュール -->
		<div style="margin-top: 2em; margin-bottom: 2em; border-top: 1px solid #BBBBBB;"></div>
		<!-- Todo一覧 -->
		<div style="">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_case.png" width="22" height="20" alt="ToDo"> Todo 一覧
			</div>
			<div class="row" style="margin-bottom:5px;">
				{{ buttons.new_obj("c4s.hdlClickGnaviBtn('misc.todoTop', {status: '未完'});") }}
			</div>
			<div class="row table-responsive">
				<table class="table view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 35px;">完了</th>
							<th style="width: auto;">内容</th>
							<th style="width: 50px;">重要度</th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
					{% if data['misc.enumTodos'] %}
						{% for item in data['misc.enumTodos'] %}
						{% if item.status != "完了" %}
						<tr id="iter_todo_{{ item.id }}">
							<td class="center">
								<span class="glyphicon glyphicon-ok text-success pseudo-link-cursor" title="完了"
									onclick="hdlClickCompleteBtn({{ item.id }});"></span>
							</td>
							<td>
								<input type="text" id="iter_todo_note_{{ item.id }}" style="width: 100%;" readOnly="readOnly" value="{{ item.note|e }}"/>
							</td>
							<td class="center">
								<span id="iter_todo_priority_read_{{ item.id }}">{{ item.priority }}</span>
								<select id="iter_todo_priority_write_{{ item.id }}" style="display: none;">
								{% for priority in priorities %}
									<option value="{{ priority }}"{% if item.priority == priority %} selected="selected"{% endif %}>{{ priority }}</option>
								{% endfor %}
								</select>
							</td>
							<td class="center">
								<span class="pseudo-link-cursor glyphicon glyphicon-trash text-danger" title="削除" onclick="c4s.hdlClickDeleteItem('todo', {{ item.id }}, true);"></span>
							</td>
						</tr>
						{% endif %}
						{% endfor %}
					{% else %}
						<tr>
							<td colspan="4">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
		</div>
		<!-- /Todo一覧 -->
	</div>
{% else -%}
	<div class="container" style="margin-bottom:100px;">
		<!-- 要員管理 -->
		<div style="margin-top: 1em;">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_interview.png" width="22" height="20" alt="要員"> 要員 管理
			</div>
			<ul class="row" style="margin-bottom:5px; padding: 0; list-style-type: none; overflow: hidden;">
			{% if env.limit.LMT_ACT_MAIL -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.mail_all("triggerMailEngineerOnHome();", "対象データを選択し、「一括メール」ボタンを押下すると取引先へメールできます") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.remind("openReminderFormOfEngineer();", "「リマインダ」ボタンを押下すると自社向けに情報をリマインドします") }}
				</li>
			{% endif -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.delete_checked("deleteItems('engineer');") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					<span class="btn" onclick="exportPdfEngineer();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.new_obj("hdlClickNewEngineerObj();") }}
				</li>
			</ul>
			{% if env.limit.SHOW_HELP %}
			<div class="row" style="margin-bottom:10px;">
{#				「アサイン可能フラグ」、「共有フラグ」がチェックされたデータを表示しています。<br/>#}
                「アサイン可能フラグ」がチェックされたデータを表示しています。<br/>
				「手配数」をクリックすると手配情報を追加できます。<span class="pull-right popover-video"
					data-toggle="popover"
					data-placement="right"
					data-content="<a href='#' style='font-weight: bold' class='video-click'>マッチング検索</a>"
					data-html="true"><a href="#" style="font-weight: bold" onclick="c4s.hdlClickDirectionBtn('home.direction');">解説動画はコチラ≫</a></span>
			</div>
			{% endif %}
			<div class="row">
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 25px;"><input type="checkbox" id="iter_engineer_selected_cb_0" onclick="c4s.toggleSelectAll('iter_engineer_selected_cb_', this);"/></th>
							<th style="width: 60px;">他社<br/>公開</th>
							<th>要員名</th>
							<th>要員名（短縮名）</th>
							<th style="width: 150px;">所属</th>
							<th>スキル</th>
							<th>稼働</th>
							<th style="width: 60px;">単価</th>
							<th style="width: 45px;">年齢<br/>（性別）</th>
							<th>登録日</th>
							<th style="width: 110px;">営業<br/>担当</th>
                            <th style="width: 35px;">案件検索</th>
							<th style="width: 35px;">経歴書</th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
					{% if data['engineer.enumEngineers'] %}
					{% set datum = data['engineer.enumEngineers']|rejectattr('flg_registered', 'even')|rejectattr('flg_assignable', 'even') %}
						{% for item in datum -%}
						{% if loop.index0 < 10 -%}
							<tr id="iter_engineer_{{ item.id }}">
								<td class="text-center">
									<input type="checkbox" id="iter_engineer_selected_cb_{{ item.id }}"/>
								</td>
								<!--20200817修正
								<td class="text-center">
									<span class="glyphicon glyphicon-user {% if item.flg_assignable %}text-success{% else %}text-muted{% endif %} pseudo-link-cursor"
										title="{% if item.flg_assignable %}アサイン可能{% else %}アサイン不可能{% endif %}"></span>
								{% if item.flg_caution %}
									<span class="glyphicon glyphicon-ban-circle text-danger pseudo-link-cursor" title="要注意フラグ"></span>{% endif %}
                                {% if item.flg_public == True %}
									<span class="glyphicon glyphicon-share-alt text-success pseudo-link-cursor" title="他社公開フラグ"></span>
								{% endif %}
								-->
								<!--20200817追加-->
								<td class="center">
									{% if item.flg_public == True  %}
										<span class="glyphicon text-info pseudo-link-cursor" alt="この案件は他社に公開されています。" title="この案件は他社に公開されています。" onclick="hdlClickPublicEngineerToggle({{ item.id}}, JSON.parse({{ item.flg_public|tojson }}));">公開</span>
									{% else %}
										<span class="glyphicon text-muted pseudo-link-cursor" alt="この案件は他社に非公開です。" title="この案件は他社に非公開です。" onclick="hdlClickPublicEngineerToggle({{ item.id}}, JSON.parse({{ item.flg_public|tojson }}));">非<br/>公開</span>
									{% endif %}
								<!--/20200817追加-->
								</td>
								<td>
									<span class="pseudo-link bold" title="{{ item.kana|e }}"
										onclick="overwriteModalForEditEngineer({{ item.id }});">{{ item.name|truncate(12, True)|e }}</span>
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
								<td class="center">{{ item.fee_comma|e }}</td>
								<td class="text-center">{% if item.age != None %}{{ item.age }}歳<br/>{% endif %}（{{ item.gender }}）</td>
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
						{% endif -%}
						{% endfor -%}
					{% else %}
						<tr id="iter_engineer_0">
							<td colspan="14">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
			<div style="margin-top:1em; text-align:right;">
				<span class="btn" onclick="c4s.hdlClickGnaviBtn('engineer.top', {flg_assignable: true});">要員一覧</span>
			</div>
		</div>
		<!-- /要員管理 -->
		<div style="margin-top: 2em; margin-bottom: 2em; border-top: 1px solid #BBBBBB;"></div>
		<!-- 案件管理 -->
		<div style="">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_case.png" width="22" height="20" alt="案件"> 案件 管理
			</div>
			<div class="row" style="margin-bottom:5px;">
				<div id='interview_list_error_massage'></div>
			</div>
			<ul class="row" style="margin-bottom:5px; padding: 0; list-style-type: none; overflow: hidden;">
			{% if env.limit.LMT_ACT_MAIL -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.mail_all("openMailFormOfProject();", "対象データを選択し、「一括メール」ボタンを押下すると取引先へメールできます") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.remind("openReminerFormOfProject();", "「リマインダ」ボタンを押下すると自社向けに情報をリマインドします") }}
				</li>
			{% endif -%}
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.delete_checked("if(deleteItems('project')) {c4s.jumpToPage(env.current);}") }}
				</li>
				<li style="margin-right: 0.5em; float: left;">
					<span class="btn" onclick="exportPdfProject();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
				</li>
				<li style="margin-right: 0.5em; float: left;">
					{{ buttons.new_obj("hdlClickNewProjectObj();") }}
				</li>
			</ul>
			{% if env.limit.SHOW_HELP %}
			<div class="row" style="margin-bottom:10px;">
				案件内容をクリックすると詳細情報が表示されます。<br />
				対象データを選択し、「一括メール」ボタンを押下することで自動的にメールを生成します。
			</div>
			{% endif %}
			<div class="row">
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 25px;"><input type="checkbox" id="iter_project_selected_cb_0" onclick="c4s.toggleSelectAll('iter_project_selected_cb_', this);"/></th>
							<th style="width: 35px;">共有</th>
                            <th style="width: 35px;">他社<br/>公開</th>
							<th>取引先名</th><!-- client_name or clients[client_id] -->
							<th>案件内容</th><!-- title and process -->
							<th>スキル</th><!-- skill_needs and skill_recommends -->
							<th style="width: 50px;">商流</th><!-- scheme -->
							<th>期間</th><!-- term -->
							<th>請求単価<br/>／支払単価</th><!-- fee_inbound and fee_outbound -->
							<th style="width: 35px;">面談<br/>回数</th><!-- interview -->
							<th class="hidden">精算条件</th><!-- expense -->
							<th>最寄駅</th><!-- station -->
							<th>登録日</th><!-- dt_created -->
							<th>営業担当</th><!-- charging_user.name -->
                            <th>要員<br/>検索</th>
                            <th style="width: 70px;">外国籍</th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
					{% if data['project.enumProjects'] %}
					{% set projects = data['project.enumProjects']|rejectattr('is_enabled', 'even')|rejectattr('flg_shared', 'even') -%}
					{% for item in projects -%}
						{% if loop.index0 < 10 -%}
						<tr>
							<td class="center">
								<input type="checkbox" id="iter_project_selected_cb_{{ item.id }}"/>
							</td>
							<td class="center">
								{% if item.flg_shared == True  %}
								<span class="glyphicon glyphicon-folder-open text-info pseudo-link-cursor" alt="共有状態" title="共有" onclick="hdlClickShareProjectToggle({{ item.id}}, JSON.parse({{ item.flg_shared|tojson }}));"></span>
								{% else %}
								<span class="glyphicon glyphicon-folder-close text-muted pseudo-link-cursor" alt="非共有状態" title="非共有" onclick="hdlClickShareProjectToggle({{ item.id}}, JSON.parse({{ item.flg_shared|tojson }}));"></span>
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
								<span>{{ item.client_name|truncate(12, True) }}</span>
								{% else %}
								<span class="pseudo-link" title="取引先企業にジャンプします"
									onclick="overwriteClientModalForEdit({{ item.client.id }});">{{ item.client.name|truncate(12, True)|e }}</span>
								{% endif %}
							</td>
							<td>
								<span class="pseudo-link bold"
									onclick="overwriteModalForEditProject({{ item.id }});">{{ item.title|truncate(12, True)|e }}</span></td>
							<td style="word-break: break-word;">{% if item.skill_list %}{{ item.skill_list|e }}{% endif %}</td>
							<td class="center">{{ (item.scheme or "")|e }}</td>
							<td>{% if item.term_begin %}{{ item.term_begin|e }}{% endif %}
                                〜
                                {% if item.term_end %}{{ item.term_end|e }}{% endif %}
                            </td>
							<td class="center">{{ item.fee_inbound_comma|e }}<br/>／{{ item.fee_outbound_comma|e }}</td>
							<td class="center">{{ item.interview }}</td>
							<td class="hidden">{{ item.expense|e }}</td>
							<td class="center">{% if item.station != None %}{{ item.station|e }}{% endif %}</td>
							<td class="center" title="{{ item.dt_created }}">{{ item.dt_created[:10] }}</td>
							<td class="center"><span title="{{ item.charging_user.login_id|e }}">{%if item.charging_user.is_enabled == False %}<span class="glyphicon glyphicon-ban-circle text-danger" title="無効化されたユーザーです"></span>&nbsp;{% endif %}{{ item.charging_user.user_name|e }}</span></td>
							<td class="text-center">
									<span class="pseudo-link-cursor glyphicon glyphicon-search " title="要員検索"
										onclick="triggerSearchEngineer({{ item.id }});"></span>
                            </td>
                            <td class="center">{% if item.flg_foreign == 1 %}可{%elif item.flg_foreign == 0 %}不可{% else %}{% endif %}</td>
                            <td class="center">
								<span class="pseudo-link-cursor glyphicon glyphicon-trash text-danger" alt="削除" title="削除"
									onclick="c4s.hdlClickDeleteItem('project', {{ item.id }}, false);"></span>
							</td>
						</tr>
						{% endif -%}
					{% endfor -%}
					{% else %}
						<tr>
							<td colspan="16">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
			<div style="margin-top:1em; text-align:right;">
				<span class="btn" onclick="c4s.hdlClickGnaviBtn('project.top', {flg_shared: true});">案件一覧</span>
			</div>
		</div>
		<!-- /案件管理 -->
		<div style="margin-top: 2em; margin-bottom: 2em; border-top: 1px solid #BBBBBB;"></div>
		<!-- メンバー スケジュール -->
		<div style="">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_schedule.png" width="22" height="20" alt="スケジュール"> メンバー スケジュール（{{ data['today_str'] }}）
				<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
					data-toggle="popover"
					data-content="グループの営業スケジュールを表示しています"
					onmouseover="$(this).popover('show');"
					onmouseout="$(this).popover('hide');"></span>
			</div>
			<div style="margin: 0.5em 0;">
				{{ buttons.new_obj("c4s.hdlClickGnaviBtn('misc.scheduleTop');") }}
			</div>
			<div class="row">
				<table class="view_table table-bordered table-hover">
				{% set datum = data['enumGroupSchedules'] %}
					<thead>
						<tr>
							<th colspan="3">{{ data.today_str }}</th>
						</tr>
						<tr>
							<th style="width: 130px;"></th>
							{% set acc_k = data['auth.userProfile'].user.id -%}
							<th style="width: auto;"><span title="{{ data['enumAccounts'][acc_k].login_id }}">{{ data['enumAccounts'][acc_k].name|e }}</span></th>
							<th style="width: auto;"><span title="グループメンバー">グループメンバー</span></th>
						</tr>
					</thead>
					<tbody>
					{% for tt in datum|sort -%}
						<tr{% if tt[:8] <= data.now_str and data.now_str < tt[11:] %} style="background-color: #ccff66;"{% endif %}>
							<td class="center bold">
								{{ tt[:8] }}<br/>～&nbsp;{{ tt[11:] }}
							</td>
							{% set acc_k = data['auth.userProfile'].user.id -%}
							{% set cnt = 0 %}
							<td class="bold">
							{% for sch in datum[tt][acc_k]|sort(attribute='dt_scheduled') -%}
								{% set cnt = cnt + 1 %}
								<span class="popover-dismiss pseudo-link-cursor"
									title="{{ sch.title|e }} （{{ sch.dt_scheduled[11:] }}～）"
									data-html="true"
									data-content="{{ (sch.note|replace('\n', '<br/>') or "（空白）")|e }}"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');">
									{% if sch.title|length > 12 %}
										{{ sch.title|truncate(12, True)|e }}
									{% else %}
										{{ sch.title|e }}
									{% endif %}
									（{{ sch.dt_scheduled[11:] }}～）
								</span>
								{% if cnt < datum[tt][acc_k]|length -%}
								<hr style="margin: 0.2em 1em;"/>
								{% endif -%}
							{% endfor -%}
							</td>
							<td>
							{% set sch_dict = datum[tt] -%}
							{% for acc_k in sch_dict -%}
							{% if acc_k != data['auth.userProfile'].user.id -%}
							{% set sch_list = sch_dict[acc_k]|sort(attribute='dt_scheduled') -%}
							{% for sch in sch_list -%}
								<span class="popover-dismiss pseudo-link-cursor"
									style="display: inline-block; margin: 0.1em 0.5em; padding: 0.1em 0.5em; border: solid 1px #ccc; border-radius: 3px; float: left;"
									title="{{ sch.title|e }} （{{ sch.dt_scheduled[11:] }}～）"
									data-html="true"
									data-content="{{ (sch.note|replace('\n', '<br/>') or "（空白）")|e }}"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');">
									{% if sch.title|length > 12 %}
										{{ sch.title|truncate(12, True)|e }}
									{% else %}
										{{ sch.title|e }}
									{% endif %}
									（{{ sch.creator.user_name|e }}:&nbsp;{{ sch.dt_scheduled[11:] }}～）
								</span>
							{% endfor -%}
							{% endif -%}
							{% endfor -%}

							</td>
						</tr>
					{% endfor -%}
					</tbody>
				</table>
			</div>
		</div>
		<!-- /メンバー スケジュール -->
		<div style="margin-top: 2em; margin-bottom: 2em; border-top: 1px solid #BBBBBB;"></div>
		<!-- Todo一覧 -->
		<div style="">
			<div class="row" style="margin-bottom:10px;">
				<img src="/img/icon/group_case.png" width="22" height="20" alt="ToDo"> Todo 一覧
			</div>
			<div class="row" style="margin-bottom:5px;">
				{{ buttons.new_obj("c4s.hdlClickGnaviBtn('misc.todoTop', {status: '未完'});") }}
			</div>
			<div class="row">
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 35px;">完了</th>
							<th style="width: auto;">内容</th>
							<th style="width: 50px;">重要度</th>
							<th style="width: 45px;"></th>
							<th style="width: 150px;">最終更新日時</th>
							<th style="width: 40px;">状態</th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
					{% if data['misc.enumTodos'] %}
						{% for item in data['misc.enumTodos'] %}
						{% if item.status != "完了" %}
						<tr id="iter_todo_{{ item.id }}">
							<td class="center">
								<span class="glyphicon glyphicon-ok text-success pseudo-link-cursor" title="完了"
									onclick="hdlClickCompleteBtn({{ item.id }});"></span>
							</td>
							<td>
								<input type="text" id="iter_todo_note_{{ item.id }}" style="width: 100%;" readOnly="readOnly" value="{{ item.note|e }}"/>
							</td>
							<td class="center">
								<span id="iter_todo_priority_read_{{ item.id }}">{{ item.priority }}</span>
								<select id="iter_todo_priority_write_{{ item.id }}" style="display: none;">
								{% for priority in priorities %}
									<option value="{{ priority }}"{% if item.priority == priority %} selected="selected"{% endif %}>{{ priority }}</option>
								{% endfor %}
								</select>
							</td>
							<td class="center">
							{% if item.status == "未完" %}
								<input type="button" id="iter_todo_edit_btn_{{ item.id }}"
									onclick="toggleEditRow({{ item.id }});" value="編集"/>
								<input type="button" id="iter_todo_commit_btn_{{ item.id }}"
									style="display: none;"
									onclick="hdlClickCommitBtn({{ item.id }});" value="登録"/>
							{% endif %}
							</td>
							<td class="center">{{ item.dt_modified or item.dt_created }}</td>
							<td class="center">{{ item.status }}</td>
							<td class="center">
								<span class="pseudo-link-cursor glyphicon glyphicon-trash text-danger" title="削除" onclick="c4s.hdlClickDeleteItem('todo', {{ item.id }}, true);"></span>
							</td>
						</tr>
						{% endif %}
						{% endfor %}
					{% else %}
						<tr>
							<td colspan="7">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
		</div>
		<!-- /Todo一覧 -->
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
							onclick="($('#m_engineer_id').val() ? updateEngineerObj : commitNewEngineerObj)();">保存</button>
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
                        <buttontype="button" class="btn btn-primary" onclick="showAddNewClientModal('engineer');">新規取引先追加</button>
                    </span>
				</div>
                <input type="hidden" id="m_engineer_client_name"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">スキル</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;"  onclick="editEngineerSkillCondition();">
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
					<input type="text" class="form-control" id="m_engineer_mail1" placeholder="xxxx@co.jp"/>
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
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとホームの要員管理一覧に情報が表示されます。<br/>チームで情報共有を行うことが出来ます。</span>"
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
                            <input type="file" class="input-file" style="opacity: 0;position: absolute;top: 0;left: 0;width: 120px;height: 25px;cursor: pointer;"id="attachment_file_0" onchange="uploadFileEngineer(0);"/>
                        </span>
                        <span class="input-file-message"><label  for="attachment_file_0"><button>ファイルを選択</button></label>経歴書を選択してください。</span>
						<button class="btn btn-default pull-right"
							id="attachment_btn_delete_0"
							style="display: none;"
							onclick="deleteEngineerAttachment(0);"><span class="glyphicon glyphicon-trash text-danger"></span>&nbsp;削除</button>
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
				<button type="button" class="btn btn-primary" onclick="($('#m_engineer_id').val() ? updateEngineerObj : commitNewEngineerObj)();">保存</button>
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
				<input type="hidden" id="input_1_engineer_id"/>
				<input type="hidden" id="input_1_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<input type="hidden" id="input_1_client_id"/>
					<span class="input-group-addon">取引先名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_1_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">日時</span>
					<input type="text" class="form-control" id="input_1_time"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">進捗</span>
					<input type="text" class="form-control" id="input_1_progress" placeholder="面談回数などの進み具合を記録します（例：1/2回目）"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">内容</span>
					<input type="text" class="form-control" id="input_1_note" placeholder="案件の内容を記載します（例：PHP社内システム開発）"/>
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
</div><!-- div.modal --><!-- 要員手配数モーダル -->
<div id="edit_project_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="commitProjectObject($('#m_project_id').val() ? true : false);">保存</button>
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
                        <button type="button" class="btn btn-primary" onclick="showAddNewClientModal('project');">新規取引先追加</button>
                    </span>
				</div>
                <input type="hidden" id="m_project_client_name"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">スキル</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;"  onclick="editProjectSkillCondition();">
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
					<span class="input-group-addon" style="min-width: 100px;">共有フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_project_flg_shared"/>
						<label for="m_project_flg_shared" class="text-danger">案件がアサイン可能であればチェックしてください</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとホームの案件管理一覧に情報が表示されます。<br/>チームで情報共有を行うことが出来ます。</span>"
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
						<label for="m_project_web_public" class="text-danger" style="display: inline">チェック状態の場合、SESクラウドWebページに情報が公開されます。</label>
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
{#								<th>名前</th><!-- section and title and name -->#}
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
				<button type="button" class="btn btn-primary" onclick="commitProjectObject($('#m_project_id').val() ? true : false);">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_client_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
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
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
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
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
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
					<span class="input-group-btn">
					{% if env.limit.LMT_ACT_MAP -%}
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
					{% endif -%}
					</span>
					&nbsp;
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
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
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

{% include "edit_engineer_skill_condition_modal.tpl" %}
{% include "edit_project_skill_condition_modal.tpl" %}

<div id="edit_project_station_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_project_station_condition_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">最寄駅検索</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <form>
                    <table>
                        <tr>
                            <td><label>都道府県</label></td>
                            <td>　<select id="ps" name="pref" onChange="setProjectMenuItem(0,this[this.selectedIndex].value,null,null)">{% include "cmn_pref_select.tpl" %}</select></td>
                        </tr>
                        <tr>
                            <td><label>路線</label></td>
                            <td>　<select id="ps0" name="ps0" onChange="setProjectMenuItem(1,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                        <tr>
                            <td><label>最寄駅</label></td>
                            <td>　<select id="ps1" name="ps1" onChange="setProjectMenuItem(2,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
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

<div id="edit_engineer_station_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_engineer_station_condition_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">最寄駅検索</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <form>
                    <table>
                        <tr>
                            <td><label>都道府県</label></td>
                            <td>　<select id="es" name="pref" onChange="setEngineerMenuItem(0,this[this.selectedIndex].value,null,null)">{% include "cmn_pref_select.tpl" %}</select></td>
                        </tr>
                        <tr>
                            <td><label>路線</label></td>
                            <td>　<select id="es0" name="es0" onChange="setEngineerMenuItem(1,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                        <tr>
                            <td><label>最寄駅</label></td>
                            <td>　<select id="es1" name="es1" onChange="setEngineerMenuItem(2,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
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

<div id="add_new_client_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="commitNewClient();">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#add_new_client_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
					<span id="add_new_client_modal_title">新規取引先登録</span>
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
					onclick="commitNewClient();">保存</button>
                <input type="hidden" id="add_new_client_mode" value="">
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
<!-- [end] Modal. -->
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script src="/js/jquery.autokana.js" type="text/javascript"></script>
		<script src="/js/jquery-ui.js" type="text/javascript"></script>
		<script src="/js/bootstrap-datepicker.js" type="text/javascript"></script>
        <script src="/js/bootstrap-datepicker.ja.js" type="text/javascript"></script>
        <link href="/css/select2.css" rel="stylesheet">
        <script src="/js/select2.js"></script>
		<script type="text/javascript" src="/js/home.js"></script>
		<script type="text/javascript" src="/js/mail.js"></script>
		<script type="text/javascript" src="/js/todo.js"></script>
		<script type="text/javascript">
// [end] Support handler for preparation modal.
$(document).ready(function () {
	$(".popover-video").popover({ trigger: "manual" , html: true, animation:false})
        .on("mouseenter", function () {
            var _this = this;
            $(this).popover("show");
            $(".popover").on("mouseleave", function () {
                $(_this).popover('hide');
            });
        }).on("mouseleave", function () {
            var _this = this;
            setTimeout(function () {
                if (!$(".popover:hover").length) {
                    $(_this).popover("hide");
                }
            }, 500);
    });
	env.data = env.data || {};
	env.userProfile = JSON.parse('{{ data['auth.userProfile']|tojson }}');
	env.data.clients_compact = JSON.parse('{{ data['js.clients']|tojson }}');
	env.data.skillCategories = JSON.parse('{{ data['skill.enumSkillCategories']|tojson }}');
	env.data.skillLevels = JSON.parse('{{ data['skill.enumSkillLevels']|tojson }}');
	env.mapLimit = {{ data['limit.count_records']['LMT_CALL_MAP_EXTERN_M'] or 'null' }} || 0;
	$("#edit_engineer_modal").on("hide.bs.modal", function () {
		$("#m_engineer_dt_created").parent().css("display", "none");
	});
	$("#m_project_modal").on("hide.bs.modal", function () {
		$("#m_project_dt_created").parent().css("display", "none");
	});
	$("#m_engineer_client_name").autocomplete({
		source: env.data.clients_compact,
		select: function (evt, itemDict) {
			env.debugOut(itemDict);
			if (itemDict.item) {
				$("#m_engineer_client_id").val(itemDict.item.id);
			} else {
				$("#m_engineer_client_id").val(null);
			}
		},
	});
	$("#m_project_client_name").autocomplete({
		source: env.data.clients_compact,
		select: function (evt, itemDict) {
			env.debugOut(itemDict);
			if (itemDict.item) {
				$("#m_project_client_id").val(itemDict.item.id);
			} else {
				$("#m_project_client_id").val(null);
			}
		},
	});
	$("#input_1_client_name").autocomplete({
		source: env.data.clients_compact,
		select: function (evt, item) {
			if (item.item) {
				$("#input_1_client_id").val(item.item.id);
			} else {
				$("#input_1_client_id").val(null);
			}
		},
	});
});
		</script>
	</body>
</html>
