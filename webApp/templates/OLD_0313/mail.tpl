{% import "cmn_controls.macro" as buttons -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
{% include "cmn_header.tpl" %}
<!-- メインコンテンツ -->
{% if "iPhone" in env.UA or "Android" in env.UA -%}
	<div class="sp_content">
		<div class="col-md-3" style="margin-top: 1em;">
			<!-- mail reserve history -->
			<img alt="メール" width="22" height="20" src="/img/icon/group_mail.png">&nbsp;メール 予約送信({{data['mail.enumMailReserves']|length }})&nbsp;
			<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
				data-toggle="popover"
				data-placement="bottom"
				data-content="直近5件のメール予約を表示しています。"
				onmouseover="$(this).popover('show');"
				onmouseout="$(this).popover('hide');"></span>
			<table class="view_table table-bordered table-hover">
				<thead>
					<tr>
						<th width="40%">日時</th>
						<th>件名</th>
						<th width="30px">削除</th>
					</tr>
				</thead>
				<tbody>
				{% for item in data['mail.enumMailReserves'] %}
					{% if loop.index0 < 5 %}
					<tr id="reservedMails_iter_mail_{{ item.id|e }}">
						<td>{{ item.send_time|e }}</td>
						<td>
							<a onclick="editReserve({{ item.id|e }});" style="cursor: pointer;">{{ item.subject|e }} </a>
						</td>
						<td style="text-align: center;"><a onclick="deleteReserve({{ item.id|e }});" style="cursor: pointer;"><span class="glyphicon glyphicon-trash text-danger"></span></a></td>
					</tr>
					{% endif %}
				{% endfor %}
				</tbody>
			</table>

			<img alt="メール" width="22" height="20" src="/img/icon/group_mail.png">&nbsp;メール 履歴&nbsp;
			<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
				data-toggle="popover"
				data-placement="bottom"
				data-content="直近20件のメール履歴を表示しています。"
				onmouseover="$(this).popover('show');"
				onmouseout="$(this).popover('hide');"></span>
			<table class="view_table table-bordered table-hover">
				<thead>
					<tr>
						<th>件名</th>
					</tr>
				</thead>
				<tbody>
				{% for item in data['mail.enumMailRequests'] %}
					{% if loop.index0 == 3 %}
					{# 3個以上のアイテムをアコーディオンするためのコード #}
					<tr>
						<td>
							<a data-toggle="collapse" data-target="#hoge">...</a>
						</td>
					</tr>
					</tbody></table>
					<table class="view_table table-bordered table-hover collapse" id="hoge">
					<tbody>
					{% endif %}
					{% if loop.index0 < 10 %}
					<tr id="iter_mail_request_{{ item.id }}">
						<td>
							<span
								class="popover-dismiss pseudo-link"
								data-toggle="popover"
								data-selector="'div.container'"
								data-placement="bottom"
								data-html="true"
								data-content="&lt;span style='font-size: 12px;'&gt;{{ item.body|e|replace("&", "&amp;")|replace("\n\n", "<br/>") }}&lt;/span&gt;"
								title="{{ item.subject|e }}"
								onmouseover="$(this).popover('show');"
								onmouseout="$(this).popover('hide');"
								onclick="triggerCreateMailFromHistory({{ item.id }});">{{ item.subject|truncate(20, True)|e }}</span>
						</td>
					</tr>
					{% endif %}
				{% endfor %}
				</tbody>
			</table>
		</div>
		<div class="col-md-9" style="margin-top: 1em;">
			<span class="glyphicon glyphicon-align-left"></span>&nbsp;メール テンプレート指定
			<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
				data-toggle="popover"
				data-placement="bottom"
				data-content="メール本文に適用するテンプレートの種類を指定してください。"
				onmouseover="$(this).popover('show');"
				onmouseout="$(this).popover('hide');"></span>
			<div class="input-group" style="clear: both;">
				<span class="input-group-addon">テンプレート種別</span>
				<ul class="form-control" style="list-style-type: none;">
					<li>
						<input type="radio" name="input_0_type_template"
							id="input_0_type_template_0"
							onchange="renderRecipientTable('worker', filterRecipientDatum('worker'));"/>
						<label for="input_0_type_template_0">
							取引先担当者
							<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
								data-toggle="popover"
								data-content="取引先担当者に向けて、技術者情報の送信に利用するテンプレート種別です。"
								onmouseover="$(this).popover('show');"
								onmouseout="$(this).popover('hide');"></span>
						</label>
					</li>
					<li>
						<input type="radio" name="input_0_type_template"
							id="input_0_type_template_1"
							onchange="renderRecipientTable('engineer', filterRecipientDatum('engineer'));"/>
						<label for="input_0_type_template_1">
							技術者
							<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
								data-toggle="popover"
								data-content="技術者に向けて、案件情報の送信に利用するテンプレート種別です。"
								onmouseover="$(this).popover('show');"
								onmouseout="$(this).popover('hide');"></span>
						</label>
					</li>
				</ul>
			</div>
		</div>
		<div class="col-md-9" style="margin: 1em 0;">
			<hr style="width: 80%; margin: 0 auto;"/>
		</div>
		<div class="col-md-9" id="search_container_workers"
			style="display: none;">
			<span class="glyphicon glyphicon-user"></span>&nbsp;メール 宛先指定（取引先担当者）
			<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
				data-toggle="popover"
				data-placement="bottom"
				data-content="下記の表から選択した送信先宛のメールを作成します。"
				onmouseover="$(this).popover('show');"
				onmouseout="$(this).popover('hide');"></span>
			<ul id="sp_width_standard" style="padding: 0; background-color: #ebebeb; list-style-type: none; overflow: hidden;">
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_client_name" style="width: 8em;">取引先名</label>
					<input type="text" id="modal_search_client_name"/>
				</li>
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_worker_name" style="width: 8em;">取引先担当者名</label>
					<input type="text" id="modal_search_worker_name"/>
				</li>
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_charging_worker" style="width: 8em;">営業担当</label>
					<select id="modal_search_charging_worker">
						<option value=""></option>
					{% for user in data['manage.enumAccounts']|selectattr("is_enabled") %}
						<option value="{{ user.id }}">{{ user.name|e }}</option>
					{% endfor %}
					</select>
				</li>
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_type_dealing" style="width: 8em;">取引区分</label>
					<select id="modal_search_type_dealing">
						<option value="">すべて</option>
						<option value="重要客">重要客</option>
						<option value="通常客">通常客</option>
						<option value="低ポテンシャル">低ポテンシャル</option>
						<option value="取引停止">取引停止</option>
					</select>
				</li>
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_type_presentation" style="width: 8em;">提案区分</label>
					<select id="modal_search_type_presentation">
						<option value="">すべて</option>
						<option value="案件">案件（保有企業）</option>
						<option value="人材">人材（保有企業）</option>
						<option value="案件・人材">案件・人材（保有企業）</option>
					</select>
				</li>
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_note" style="width: 8em;">備考</label>
					<input type="text" id="modal_search_worker_note"/>
				</li>
			</ul>
			<div class="pull-right" style="margin-bottom: 0.5em;">
				<button class="btn btn-primary"
					onclick="renderRecipientTable('worker', filterRecipientDatum('worker'));"><span class="bold">絞り込み</span>（取引先担当者）</button>
				<button class="btn btn-primary"
					onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
			</div>
			{% if env.limit.SHOW_HELP -%}
			<p style="width: 100%; clear: both; text-align: right;">メール宛先を選択し、「メール作成」ボタンをクリックすることでメールを送信できます</p>
			{% endif -%}
			<h4>検索結果 <span id="worker_row_count" class="badge"></span></h4>
			<div class="table-responsive" >
				<table class="table view_table table-bordered table-hover"
					id="search_result_worker">
					<thead>
						<tr>
							<th style="width: 25px;">
								<input type="checkbox"
									onclick="c4s.toggleSelectAll('recipient_iter_worker_', this);"/>
							</th>
							<th>取引先名</th>
							<th>取引先担当者名</th>
							<th style="display: none;">メールアドレス</th>
							<th style="display: none;">営業担当</th>
						</tr>
					</thead>
					<tbody></tbody>
				</table>
			</div>
			<div class="pull-right" style="margin-bottom: 0.5em;">
				<button class="btn btn-primary"
					onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
			</div>
		</div>
		<div class="col-md-9" id="search_container_engineers"
			style="display: none;">
			<span class="glyphicon glyphicon-user"></span>&nbsp;メール 宛先指定（技術者）
			<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
				data-toggle="popover"
				data-placement="bottom"
				data-content="下記の表から選択した送信先宛のメールを作成します。"
				onmouseover="$(this).popover('show');"
				onmouseout="$(this).popover('hide');"></span>
			<ul style="padding: 0; background-color: #ebebeb; list-style-type: none; overflow: hidden;">
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_engineer_name" style="width: 5em;">技術者名</label>
					<input type="text" id="modal_search_engineer_name"/>
				</li>
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_skill" style="width: 5em;">スキル</label>
					<input type="text" id="modal_search_skill"/>
				</li>
				<li style="margin: 3px 5px; float: left;">
					<label for="modal_search_contract" style="width: 5em;">所属</label>
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
					<label for="modal_search_engineer_note" style="width: 5em;">備考</label>
					<input type="text" id="modal_search_engineer_note"/>
				</li>
			</ul>
			<div class="pull-right" style="margin-bottom: 0.5em;">
				<button class="btn btn-primary"
					onclick="renderRecipientTable('engineer', filterRecipientDatum('engineer'));"><span class="bold">絞り込み</span>（技術者）</button>
				<button class="btn btn-primary"
					onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
			</div>
			{% if env.limit.SHOW_HELP -%}
			<p style="width: 100%; clear: both; text-align: right;">メール宛先を選択し、「メール作成」ボタンをクリックすることでメールを送信できます</p>
			{% endif -%}
			<h4>検索結果 <span id="engineer_row_count" class="badge"></span></h4>
			<div class="table-responsive" >
				<table class="table view_table table-bordered table-hover"
					id="search_result_engineer">
					<thead>
						{# CSS側で tbody 側該当フィールドを display:none にして合わせてある #}
						<tr>
							<th style="width: 25px;">
								<input type="checkbox"
									onclick="c4s.toggleSelectAll('recipient_iter_engineer_', this);"/>
							</th>
							<th>技術者名</th>
							<th style="display:none">単価</th>
							<th>スキル</th>
							<th style="display:none">状態</th>
							<th style="display:none">メールアドレス</th>
						</tr>
					</thead>
					<tbody></tbody>
				</table>
			</div>
			<div class="pull-right" style="margin-bottom: 0.5em;">
				<button class="btn btn-primary"
					onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
			</div>
		</div>
	</div>
{% else -%}
	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<div class="col-md-3">
				<img alt="メール" width="22" height="20" src="/img/icon/group_mail.png">&nbsp;メール 予約送信({{data['mail.enumMailReserves']|length }})&nbsp;
				<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
					data-toggle="popover"
					data-placement="bottom"
					data-content="直近5件のメール予約を表示しています。"
					onmouseover="$(this).popover('show');"
					onmouseout="$(this).popover('hide');"></span>
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th width="40%">日時</th>
							<th>件名</th>
							<th width="30px">削除</th>
						</tr>
					</thead>
					<tbody>
					{% for item in data['mail.enumMailReserves'] %}
						{% if loop.index0 < 5 %}
						<tr id="reservedMails_iter_mail_{{ item.id|e }}">
							<td>{{ item.send_time|e }}</td>
							<td>
								<a onclick="editReserve({{ item.id|e }});" style="cursor: pointer;">{{ item.subject|e }} </a>
							</td>
							<td style="text-align: center;"><a onclick="deleteReserve({{ item.id|e }});" style="cursor: pointer;"><span class="glyphicon glyphicon-trash text-danger"></span></a></td>
						</tr>
						{% endif %}
					{% endfor %}
					</tbody>
				</table>

				<img alt="メール" width="22" height="20" src="/img/icon/group_mail.png">&nbsp;メール 履歴&nbsp;
				<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
					data-toggle="popover"
					data-placement="bottom"
					data-content="直近20件のメール履歴を表示しています。"
					onmouseover="$(this).popover('show');"
					onmouseout="$(this).popover('hide');"></span>
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th>件名</th>
						</tr>
					</thead>
					<tbody>
					{% for item in data['mail.enumMailRequests'] %}
						{% if loop.index0 < 20 %}
						<tr id="iter_mail_request_{{ item.id }}">
							<td>
								<span
									class="popover-dismiss pseudo-link"
									data-toggle="popover"
									data-selector="'div.container'"
									data-placement="bottom"
									data-html="true"
									data-content="&lt;span style='font-size: 12px;'&gt;{{ item.body|e|replace("&", "&amp;")|replace("\n\n", "<br/>") }}&lt;/span&gt;"
									title="{{ item.subject|e }}"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');"
									onclick="triggerCreateMailFromHistory({{ item.id }});">{{ item.subject|truncate(20, True)|e }}</span>
							</td>
						</tr>
						{% endif %}
					{% endfor %}
					</tbody>
				</table>
			</div>
			<div class="col-md-9">
				<span class="glyphicon glyphicon-align-left"></span>&nbsp;メール テンプレート指定
				<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
					data-toggle="popover"
					data-placement="bottom"
					data-content="メール本文に適用するテンプレートの種類を指定してください。"
					onmouseover="$(this).popover('show');"
					onmouseout="$(this).popover('hide');"></span>
				<div class="input-group" style="clear: both;">
					<span class="input-group-addon">テンプレート種別</span>
					<ul class="form-control" style="list-style-type: none;">
						<li>
							<input type="radio" name="input_0_type_template"
								id="input_0_type_template_0"
								onchange="renderRecipientTable('worker', filterRecipientDatum('worker'));"/>
							<label for="input_0_type_template_0">
								取引先担当者
								<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
									data-toggle="popover"
									data-content="取引先担当者に向けて、技術者情報の送信に利用するテンプレート種別です。"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');"></span>
							</label>
						</li>
						<li>
							<input type="radio" name="input_0_type_template"
								id="input_0_type_template_1"
								onchange="renderRecipientTable('engineer', filterRecipientDatum('engineer'));"/>
							<label for="input_0_type_template_1">
								技術者
								<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
									data-toggle="popover"
									data-content="技術者に向けて、案件情報の送信に利用するテンプレート種別です。"
									onmouseover="$(this).popover('show');"
									onmouseout="$(this).popover('hide');"></span>
							</label>
						</li>
					</ul>
				</div>
				<hr style="width: 90%; margin: 0.5em auto;"/>
				<div class="" id="search_container_workers"
					style="display: none;">
					<span class="glyphicon glyphicon-user"></span>&nbsp;メール 宛先指定（取引先担当者）
					<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
						data-toggle="popover"
						data-placement="bottom"
						data-content="下記の表から選択した送信先宛のメールを作成します。"
						onmouseover="$(this).popover('show');"
						onmouseout="$(this).popover('hide');"></span>
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
					<div class="pull-right" style="margin-bottom: 0.5em;">
						<button class="btn btn-primary"
							onclick="renderRecipientTable('worker', filterRecipientDatum('worker'));"><span class="bold">絞り込み</span>（取引先担当者）</button>
						<button class="btn btn-primary"
							onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
					</div>
					{% if env.limit.SHOW_HELP -%}
					<p style="width: 100%; clear: both; text-align: right;">メール宛先を選択し、「メール作成」ボタンをクリックすることでメールを送信できます</p>
					{% endif -%}
					<h4>検索結果 <span id="worker_row_count" class="badge"></span></h4>
					<table class="view_table table-bordered table-hover"
						id="search_result_worker">
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
					<div class="pull-right" style="margin-bottom: 0.5em;">
						<button class="btn btn-primary"
							onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
					</div>
				</div>
				<div class="" id="search_container_engineers"
					style="display: none;">
					<span class="glyphicon glyphicon-user"></span>&nbsp;メール 宛先指定（技術者）
					<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
						data-toggle="popover"
						data-placement="bottom"
						data-content="下記の表から選択した送信先宛のメールを作成します。"
						onmouseover="$(this).popover('show');"
						onmouseout="$(this).popover('hide');"></span>
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
					<div class="pull-right" style="margin-bottom: 0.5em;">
						<button class="btn btn-primary"
							onclick="renderRecipientTable('engineer', filterRecipientDatum('engineer'));"><span class="bold">絞り込み</span>（技術者）</button>
						<button class="btn btn-primary"
							onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
					</div>
					{% if env.limit.SHOW_HELP -%}
					<p style="width: 100%; clear: both; text-align: right;">メール宛先を選択し、「メール作成」ボタンをクリックすることでメールを送信できます</p>
					{% endif -%}
					<h4>検索結果 <span id="engineer_row_count" class="badge"></span></h4>
					<table class="view_table table-bordered table-hover"
						id="search_result_engineer">
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
					<div class="pull-right" style="margin-bottom: 0.5em;">
						<button class="btn btn-primary"
							onclick="triggerCreateMailOnMail();"><span class="bold">メール作成</span></button>
					</div>
				</div>
			</div>
		</div>
	</div>

<!-- edit reserved mail dialog -->
<div id="edit_reserve_modal" class="modal fade modal-sm"  role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<div class="modal-body">
					<input type="hidden" id="edit_reserve_id"/>
					<input type="hidden" id="edit_mail_id"/>
					<input type="hidden" id="edit_reserve_date_saved"/>
					<input type="hidden" id="edit_reserve_subject_saved"/>
					<input type="hidden" id="edit_reserve_body_saved"/>
					<div class="input-group">
						<span class="input-group-addon">送信日時</span>
						<input type="datetime-local" id="edit_reserve_date">
					</div>
					<div class="input-group">
						<span class="input-group-addon">件名</span>
						<input type="text" class="form-control" id="edit_reserve_subject"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">本文</span>
						<span><textarea class="form-control" id="edit_reserve_body" style="height: 30em;"></textarea></span>
					</div>
				</div>
				<div style="height: 2em;">
					<button type="button" class="btn btn-danger" style="float: left; margin-left: 20px;"
						onclick="if (!this.disabled) {closeEditReserve();}">戻る</button>
					<button type="button" id="save_edit_reserve" class="btn btn-success" style="float: right; margin-right: 20px;"
						onclick="if (!this.disabled) {saveEditReserve();}">確認</button>
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
        <script type="text/javascript">
            enumAccountsStr ="{{ data['manage.enumAccounts'] }}";
            enumAccountsStr = enumAccountsStr.replace(/: u/g, ': ')
                .replace(/True/gi, 'true')
                .replace(/False/gi, 'false')
                .replace(/None/gi, 'null')
                .replace(/\'/g, '\"');

            var asyncObj = setInterval(function() {
                env.data = env.data || {};
                if (!env.data.engineers) {
                    c4s.invokeApi_ex({
			            location: "engineer.enumEngineersCompact",
			            body: {},
			            onSuccess: function (res) {
                            if (res.data && res.data.length > 0) {
                                env.data = env.data || {};
                                env.data.engineers = res.data;
                            }
			            }
                    });
                }
                clearInterval( asyncObj );
            }, 100);

            $(document).ready(function(){
                function splitByLength(str, length) {
                    var resultArr = [];
                    if (!str || !length || length < 1) {
                        return resultArr;
                    }
                    var index = 0;
                    var start = index;
                    var end = start + length;
                    while (start < str.length) {
                        resultArr[index] = str.substring(start, end);
                        index++;
                        start = end;
                        end = start + length;
                    }
                    return resultArr;
                }

                $(".popover-dismiss").each(function (idx, el, arr) {
                    var str = $(this).attr("data-content");
                    var arrStr = str.split('<br/>');

                    for(var i = 0; i< arrStr.length; i++){
                        if(arrStr[i].length > 100){
                            var tmpArrStr = splitByLength(arrStr[i], 35);
                            arrStr[i]= tmpArrStr.join('<br/>');

                        }
                    }
                    str = arrStr.join('<br/>');

                    $(this).attr("data-content", str);

			    });

            });

        </script>
		<script type="text/javascript" src="/js/mail.js"></script>

	</body>
</html>