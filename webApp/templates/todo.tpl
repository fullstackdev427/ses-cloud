{% import "cmn_controls.macro" as buttons -%}
{% set priorities = ("高", "中", "低") -%}
{% set statuses = ("すべて", "完了", "未完") -%}
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
				<img alt="Todoリスト" width="22" height="20" src="/img/icon/group_case.png"> Todo 一覧
			</div>
			<!-- /検索フォーム -->
			<!-- 検索結果ヘッダー -->
			<div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-9">
					<input type="text" style="width:200px; vertical-align:middle;" id="input_0_todo_note"/>
					<select style="vertical-align:middle;" id="input_0_todo_priority">
						<option value="高">高</option>
						<option value="中" selected="selected">中</option>
						<option value="低">低</option>
					</select>
					{{ buttons.new_obj("hdlClickCreateBtn();") }}
				</div>
				<div class="col-lg-3" style="text-align:right;">
					ステータス
					<select style="vertical-align:middle;" id="query_status">
					{% for status in statuses %}
						{% if query.status %}<option value="{{ status }}"{% if query.status == status %} selected="selected"{% endif %}>{{ status }}</option>
						{% elif status == "未完" or not query.status %}<option value="{{ status }}"{% if query.status == status %} selected="selected"{% endif %}>{{ status }}</option>
						{% else %}<option value="{{ status }}">{{ status }}</option>
						{% endif %}
					{% endfor %}
					</select>
					{#{{ buttons.search("c4s.hdlClickSearchBtn();") }}#}
					<span class="btn" onclick="c4s.hdlClickSearchBtn();">検索&nbsp;<span class="glyphicon glyphicon-search"></span></span>
				</div>
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class="row table-responsive" >
				<table class="table view_table table-bordered table-hover">
					<thead>
						<tr>
							<th style="width: 35px;">完了</th>
							<th style="width: auto; min-width: 200px;">内容</th>
							<th style="width: 50px;">重要度</th>
							<th style="width: 45px;"></th>
							<th style="width: 35px;">削除</th>
						</tr>
					</thead>
					<tbody>
						<!-- TODO 動的に切り替える -->
					{% if data['misc.enumTodos'] %}
						{% for item in data['misc.enumTodos'] %}
						<tr id="iter_todo_{{ item.id }}">
							<td class="center">
							{% if item.status != "完了" -%}
								<span class="glyphicon glyphicon-ok text-success pseudo-link-cursor" title="完了にする"
									onclick="hdlClickCompleteBtn({{ item.id }});"></span>
							{% else %}
								<span class="glyphicon glyphicon-repeat text-muted pseudo-link-cursor" title="未完了にする"
									onclick="hdlClickCompleteBtn({{ item.id }}, '未完');"></span>
							{% endif -%}
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
							{% if item.status in ("未完", "完了") %}
								<input type="button" id="iter_todo_edit_btn_{{ item.id }}"
									onclick="toggleEditRow({{ item.id }});" value="編集"/>
								<input type="button" id="iter_todo_commit_btn_{{ item.id }}"
									style="display: none;"
									onclick="hdlClickCommitBtn({{ item.id }});" value="登録"/>
							{% endif %}
							</td>
							<td class="center">
								<span class="pseudo-link-cursor glyphicon glyphicon-trash text-danger" title="削除" onclick="c4s.hdlClickDeleteItem('todo', {{ item.id }}, true);"></span>
							</td>
						</tr>
						{% endfor %}
					{% else %}
						<tr>
							<td colspan="7">有効なデータがありません</td>
						</tr>
					{% endif %}
						<!-- /TODO 動的に切り替える -->
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
	</div>
{% else -%}
	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
				<img alt="Todoリスト" width="22" height="20" src="/img/icon/group_case.png"> Todo 一覧
			</div>
			<!-- /検索フォーム -->
			<!-- 検索結果ヘッダー -->
			<div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-9">
					<input type="text" style="width:400px; vertical-align:middle;" id="input_0_todo_note"/>
					<select style="vertical-align:middle;" id="input_0_todo_priority">
						<option value="高">高</option>
						<option value="中" selected="selected">中</option>
						<option value="低">低</option>
					</select>
					{{ buttons.new_obj("hdlClickCreateBtn();") }}
				</div>
				<div class="col-lg-3" style="text-align:right;">
					ステータス
					<select style="vertical-align:middle;" id="query_status">
					{% for status in statuses %}
						{% if query.status %}<option value="{{ status }}"{% if query.status == status %} selected="selected"{% endif %}>{{ status }}</option>
						{% elif status == "未完" or not query.status %}<option value="{{ status }}"{% if query.status == status %} selected="selected"{% endif %}>{{ status }}</option>
						{% else %}<option value="{{ status }}">{{ status }}</option>
						{% endif %}
					{% endfor %}
					</select>
					{#{{ buttons.search("c4s.hdlClickSearchBtn();") }}#}
					<span class="btn" onclick="c4s.hdlClickSearchBtn();">検索&nbsp;<span class="glyphicon glyphicon-search"></span></span>
				</div>
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class="row" >
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
						<!-- TODO 動的に切り替える -->
					{% if data['misc.enumTodos'] %}
						{% for item in data['misc.enumTodos'] %}
						<tr id="iter_todo_{{ item.id }}">
							<td class="center">
							{% if item.status != "完了" -%}
								<span class="glyphicon glyphicon-ok text-success pseudo-link-cursor" title="完了にする"
									onclick="hdlClickCompleteBtn({{ item.id }});"></span>
							{% else %}
								<span class="glyphicon glyphicon-repeat text-muted pseudo-link-cursor" title="未完了にする"
									onclick="hdlClickCompleteBtn({{ item.id }}, '未完');"></span>
							{% endif -%}
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
							{% if item.status in ("未完", "完了") %}
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
						{% endfor %}
					{% else %}
						<tr>
							<td colspan="7">有効なデータがありません</td>
						</tr>
					{% endif %}
						<!-- /TODO 動的に切り替える -->
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
		</div>
	</div>
{% endif -%}
<!-- /メインコンテンツ -->
			
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script src="/js/todo.js" type="text/javascript"></script>
	</body>
</html>