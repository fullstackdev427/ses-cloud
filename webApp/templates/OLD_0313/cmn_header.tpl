			<!-- ヘッダー -->
<div class="modal fade" id="fulltext_search_condition_modal" role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#fulltext_search_condition_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-filter">&nbsp;</span>全文検索：詳細条件指定</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<fieldset>
					<legend>取引先</legend>
					<ul class="floating">
						<li>
							<input type="checkbox" checked="checked"/><label>取引先名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>取引先名（カナ）</label>
						</li>
						<li>
							<input type="checkbox"/><label>住所</label>
						</li>
						<li>
							<input type="checkbox"/><label>備考</label>
						</li>
					</ul>
				</fieldset>
				<fieldset>
					<legend>取引先担当者</legend>
					<ul class="floating">
						<li>
							<input type="checkbox" checked="checked"/><label>取引先担当者名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>取引先担当者名（カナ）</label>
						</li>
						<li>
							<input type="checkbox"/><label>備考</label>
						</li>
					</ul>
				</fieldset>
				<fieldset>
					<legend>案件</legend>
					<ul class="floating">
						<li>
							<input type="checkbox" checked="checked"/><label>取引先名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>案件名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>案件内容</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>必須スキル</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>推奨スキル</label>
						</li>
						<li>
							<input type="checkbox"/><label>備考</label>
						</li>
					</ul>
				</fieldset>
				<fieldset>
					<legend>要員</legend>
					<ul class="floating">
						<li>
							<input type="checkbox" checked="checked"/><label>要員名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>要員名（カナ）</label>
						</li>
						<li>
							<input type="checkbox"/><label>スキル</label>
						</li>
						<li>
							<input type="checkbox"/><label>所属備考</label>
						</li>
						<li>
							<input type="checkbox"/><label>備考</label>
						</li>
					</ul>
				</fieldset>
				<fieldset>
					<legend>商談</legend>
					<ul class="floating">
						<li>
							<input type="checkbox" checked="checked"/><label>商談名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>取引先名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>取引先名</label>
						</li>
						<li>
							<input type="checkbox" checked="checked"/><label>取引先名（カナ）</label>
						</li>
					</ul>
				</fieldset>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="c4s.searchAll($('#all_search_ipt').val());">検索開始</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
{% if "iPhone" in env.UA or "Android" in env.UA -%}
			<div class="sp_header" style="display: table;">
				<table>
					<tr>
						<td>
							<img alt="CloudforSi" width="126" height="41" src="/img/logo.png" style="margin-left:20px"/>
						</td>
						<td></td>
						<td>
							<div class="dropdown pull-right" style="margin-right:10px">
								<span class="btn btn_invert dropdown-toggle" type="button" id="SettingDropdownMenu" data-toggle="dropdown">
									<span class="glyphicon glyphicon glyphicon glyphicon-th-list" style="font-size: 20px"></span>
								</span>
								<ul class="dropdown-menu" role="menu" aria-labelledby="SettingDropdownMenu">
									<li role="presentation">
										<input type="image" src="/img/icon/header_negotiate_out.png" alt="商談"
										style="margin-left: 10px;"
										{% if current!="negotiation.top" %}
										onmouseover="this.src='/img/icon/header_negotiate_over.png'"
										onmouseout="this.src='/img/icon/header_negotiate_out.png'"
										onclick="c4s.hdlClickGnaviBtn('negotiation.top');"
										{% endif %}
										id="form_all_search_button"/>
										<input type="image" src="/img/icon/header_sche_out.png" alt="スケジュール"
										style="margin-left: 10px;"
										{% if current!="misc.scheduleTop" %}
										onmouseover="this.src='/img/icon/header_sche_over.png'"
										onmouseout="this.src='/img/icon/header_sche_out.png'"
										onclick="c4s.hdlClickGnaviBtn('misc.scheduleTop');"
										{% endif %}
										id="form_all_search_button"/>
										<input type="image" src="/img/icon/header_todo_out.png" alt="ToDo"
										style="margin-left: 10px;"
										{% if current!="misc.todoTop" %}
										onmouseover="this.src='/img/icon/header_todo_over.png'"
										onmouseout="this.src='/img/icon/header_todo_out.png'"
										onclick="c4s.hdlClickGnaviBtn('misc.todoTop', {status: '未完'});"
										{% endif %}
										{% if (env and env.limit.LMT_ACT_MAIL == True) or not env %}
										id="form_all_search_button"/>
										<input type="image" src="/img/icon/header_mail_out.png" alt="メール"
										style="margin-left: 10px;"
										{% if current!="mail.top" %}
										onmouseover="this.src='/img/icon/header_mail_over.png'"
										onmouseout="this.src='/img/icon/header_mail_out.png'"
										onclick="c4s.hdlClickGnaviBtn('mail.top');"
										{% endif %}
										{% endif %}
										id="form_all_search_button"/>
									</li>
									<li role="presentation" class="divider"></li>
									<li role="presentation" style=" text-align: center;">
										{% if data['auth.userProfile'].user.is_admin %}
											［管理者ユーザー］<br/>
										{% endif %}
											{{ data['auth.userProfile'].user.name }} さん
										{% if env.prod_level == "develop" %}
											{% set MODE = "開発モード" %}
										{% elif env.prod_level == "pool" %}
											{% set MODE = "プールモード" %}
										{% elif env.prod_level == "stage" %}
											{% set MODE = "ステージモード" %}
										{% elif env.prod_level == "prod" %}
											{% set MODE = "" %}
										{% else %}
											{% set MODE = "未設定モード" %}
										{% endif %}
										{% if MODE %}
											<br/>
											<span class="btn text-danger bold">{{ MODE }}</span>
										{% endif %}
									</li>
									<li role="presentation"><a role="menuitem" onclick="c4s.hdlClickGnaviBtn('contact.top');">
										<span class="glyphicon glyphicon-question-sign"></span>&nbsp;お問合せ</a>
									</li>
									<li role="presentation"><a role="menuitem" onclick="c4s.hdlClickGnaviBtn('manage.top');">
										<span class="glyphicon glyphicon-cog"></span>&nbsp;設定</a>
									</li>
									<li role="presentation" class="divider"></li>
									<li role="presentation"><a role="menuitem" onclick="c4s.jumpToPage('auth.logout');">
										<span class="glyphicon glyphicon-lock"></span>&nbsp;ログアウト</a>
									</li>
								</ul>
							</div>
						</td>
					</tr>
				</table>
			</div>
			<nav class="sp_nav">
				<a onclick="c4s.hdlClickGnaviBtn('home.enum');" {% if current == 'home.enum' %} class="current"{% endif %} >ホーム</a>
				<a onclick="c4s.hdlClickGnaviBtn('client.clientTop');" {% if current == 'client.clientTop' %} class="current"{% endif %} >取引先</a>
				<a onclick="c4s.hdlClickGnaviBtn('client.workerTop');" {% if current == 'client.workerTop' %} class="current"{% endif %} >取引先<br/>担当者</a>
				<a onclick="c4s.hdlClickGnaviBtn('project.top', {flg_shared: true});" {% if current == 'project.top' %} class="current"{% endif %} >案件</a>
				<a onclick="c4s.hdlClickGnaviBtn('engineer.top', {flg_assignable: true});" {% if current == 'engineer.top' %} class="current"{% endif %} >要員</a>
			</nav>
{% else -%}
			<div class="row" >
				<div id="header" class="container" style="height:100%; margin-top:30px;">
					<div class="row" style="margin-bottom:15px;">
						<table style="width:100%;min-width:950px;padding-left:15px;padding-right:15px;">
							<tr>
								<td>
									<img alt="SESクラウド" width="126" height="41" style="" src="/img/logo.png"/>
								</td>
								<td>
									<form onsubmit="/*c4s.searchAll($('#all_search_ipt').val());*/return false;">
										<input type="text" style="vertical-align:middle;" id="all_search_ipt" value="{{ query.word|e }}"/>
										<input type="image" style="vertical-align:middle;"
											id="form_all_search_button"
											src="/img/icon/search_out.png" alt="すべて検索"
											onmouseover="this.src='/img/icon/search_over.png'"
											onmouseout="this.src='/img/icon/search_out.png'"
											onclick="c4s.searchAll($('#all_search_ipt').val());/*$('#fulltext_search_condition_modal').modal('show');*/"/>
									</form>
								</td>
								<td>
									<input type="image" src="/img/icon/header_negotiate_out.png" alt="商談"
									{% if current!="negotiation.top" %}
									onmouseover="this.src='/img/icon/header_negotiate_over.png'"
									onmouseout="this.src='/img/icon/header_negotiate_out.png'"
									onclick="c4s.hdlClickGnaviBtn('negotiation.top');"
									{% endif %}
									id="form_all_search_button"/>
									<input type="image" src="/img/icon/header_sche_out.png" alt="スケジュール"
									{% if current!="misc.scheduleTop" %}
									onmouseover="this.src='/img/icon/header_sche_over.png'"
									onmouseout="this.src='/img/icon/header_sche_out.png'"
									onclick="c4s.hdlClickGnaviBtn('misc.scheduleTop');"
									{% endif %}
									id="form_all_search_button"/>
									<input type="image" src="/img/icon/header_todo_out.png" alt="ToDo"
									{% if current!="misc.todoTop" %}
									onmouseover="this.src='/img/icon/header_todo_over.png'"
									onmouseout="this.src='/img/icon/header_todo_out.png'"
									onclick="c4s.hdlClickGnaviBtn('misc.todoTop', {status: '未完'});"
									{% endif %}
									{% if (env and env.limit.LMT_ACT_MAIL == True) or not env %}
									id="form_all_search_button"/>
									<input type="image" src="/img/icon/header_mail_out.png" alt="メール"
									{% if current!="mail.top" %}
									onmouseover="this.src='/img/icon/header_mail_over.png'"
									onmouseout="this.src='/img/icon/header_mail_out.png'"
									onclick="c4s.hdlClickGnaviBtn('mail.top');"
									{% endif %}
									{% endif %}
									id="form_all_search_button"/>
								</td>
								<td>
									<div style="text-align:right;">
									{% if data['auth.userProfile'].user.is_admin %}
										［管理者ユーザー］
									{% endif %}
										{{ data['auth.userProfile'].user.name }} さん
									</div>
									<div style="text-align:right;">
									{% if env.prod_level == "develop" %}
										{% set MODE = "開発モード" %}
									{% elif env.prod_level == "pool" %}
										{% set MODE = "プールモード" %}
									{% elif env.prod_level == "stage" %}
										{% set MODE = "ステージモード" %}
									{% elif env.prod_level == "prod" %}
										{% set MODE = "" %}
									{% else %}
										{% set MODE = "未設定モード" %}
									{% endif %}
									{% if MODE %}
										<span class="btn text-danger bold">{{ MODE }}</span>
									{% endif %}
										{{ buttons.logout("c4s.jumpToPage('auth.logout');") }}
										{{ buttons.setting_generic("c4s.hdlClickGnaviBtn('manage.top');") }}
										{{ buttons.inquire("c4s.hdlClickGnaviBtn('contact.top');") }}
									</div>
								</td>
							</tr>
						</table>
					</div>
					{% include "cmn_gnavi.tpl" %}
				</div>
			</div>
			{% endif -%}
			<!-- /ヘッダー -->
