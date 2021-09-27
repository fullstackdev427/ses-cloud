{% import "cmn_controls.macro" as buttons -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
{% include "cmn_header.tpl" %}
			<!-- メインコンテンツ -->
			<div class="row">
				<div {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_content" style="margin-top: 1em;" {% else -%}class="container" style="margin-bottom:100px;"{% endif -%}>
					<div class="row">
						<img alt="設定" width="22" height="20" src="/img/icon/group_person.png"> 設定
						<ul class="nav nav-tabs" role="tablist">
							<li class="active"><a href="#ct_signature" role="tab" data-toggle="tab">署名</a></li><!-- 署名 -->
							<li><a href="#ct_profile" role="tab" data-toggle="tab">プロファイル変更</a></li><!-- プロファイル変更 -->
							<li><a href="#ct_help" role="tab" data-toggle="tab">表示設定</a></li><!-- ヘルプ利用フラグ変更 -->
							{% if data['auth.userProfile'].user.is_admin == True %}
							<li><a href="#ct_account" role="tab" data-toggle="tab">アカウント管理</a></li><!-- アカウント管理 -->
							{% if (env and env.limit.LMT_ACT_MAIL == True) or not env %}
							<li><a href="#ct_template" role="tab" data-toggle="tab">メール テンプレート</a></li><!-- テンプレート -->
							<li><a href="#ct_mail" role="tab" data-toggle="tab">メール設定</a></li><!-- メール設定 -->
							{% endif %}
							{% endif %}
							{% if data['manage.readUserProfile'].user.is_admin -%}
							<li><a href="#ct_preferences" role="tab" data-toggle="tab">利用状況</a></li>
                                <li><a href="#ct_form" role="tab" data-toggle="tab">帳票設定</a></li>
							{% endif -%}
                            {% if data['manage.readUserProfile'].user.is_admin and data['manage.readUserProfile'].company.is_admin %}
							<li><a href="#ct_user_group" role="tab" data-toggle="tab">顧客企業管理</a></li>
							{% endif -%}
							{% if data['auth.userProfile'].user.is_admin == True -%}
							{#<li><a href="#ct_migrate" role="tab" data-toggle="tab">データ移行</a></li>#}
							{% endif -%}
							{% if env.prefix == "mng" -%}
							<li><a href="#ct_migrate_full" role="tab" data-toggle="tab">データ移行（フル機能）</a></li>
							{% endif -%}
							{% if env.prod_level == "develop" %}
							<li><a href="#ct_prefs" role="tab" data-toggle="tab" title="ONLY IN DEVELOP MODE">設定値</a></li><!-- 設定値（デバッグ） -->
							{% endif %}
							{% if data['manage.readUserProfile'].user.is_admin and data['manage.readUserProfile'].company.is_admin %}
							<li><a href="#ct_new_information" role="tab" data-toggle="tab">最新情報管理</a></li>
							{% endif -%}
						</ul>
						<div class="tab-content">
							<div class="tab-pane fade in active" id="ct_signature" style="padding: 1em 1.5em;">
								{% if env.limit.SHOW_HELP %}
								<p>メール本文の最下部に差し込む「署名」情報を入力して下さい。</p>
								{% endif %}
								<form class="form-horizontal" role="form">
									<div class="form-group">
										<label for="input_signature_value" class="col-sm-2 control-label">署名</label>
										<div class="col-sm-offset-2 col-sm-10">
											<textarea class="form-control" id="input_signature_value" style="height: 20em;">{{ data['manage.readMailSignature'].MAIL_SIGNATURE|e }}</textarea>
										</div>
									</div>
									<div class="form-group">
										<div class="col-sm-offset-2 col-sm-10">
											<input type="button" class="btn btn-primary" value="登録"
												onclick="hdlClickUpdateSignature();"/>
										</div>
									</div>
								</form>
							</div>
							<div class="tab-pane fade" id="ct_profile" style="padding: 1em 1.5em;">
								{% if env.limit.SHOW_HELP %}
								<p>本CRMの営業パーソナルの個人情報を入力して下さい。</p>
								{% endif %}
								<h4><span class="glyphicon glyphicon-home"></span>&nbsp;会社情報</h4>
								<ul style="list-style-type: none;">
									<li>
										<span class="bold textLabel">社名：</span>
										<span>{{ data['manage.readUserProfile'].company.name|e }}</span>
									</li>
									<li>
										<span class="bold textLabel">代表：</span>
										<span>{{ data['manage.readUserProfile'].company.owner_name|e }}</span>
									</li>
									<li>
										<span class="bold textLabel">住所：</span>
										<span>
											〒{{ data['manage.readUserProfile'].company.addr_vip|e }}&nbsp;
											{{ data['manage.readUserProfile'].company.addr1|e}}
											{% if data['manage.readUserProfile'].company.addr2|e %}
											{{ data['manage.readUserProfile'].company.addr2|e }}
											{% endif %}
										</span>
									</li>
									<li>
										<span class="bold textLabel">代表電話番号：</span>
										<span>{{ data['manage.readUserProfile'].company.tel|e }}</span>
									</li>
									<li>
										<span class="bold textLabel">代表FAX番号：</span>
										<span>{{ (data['manage.readUserProfile'].company.fax or "")|e }}</span>
									</li>
									<li>
										<span class="bold textLabel">利用期間：</span>
										<span>{{ data['manage.readUserProfile'].company.dt_use_begin|e }}</span>
										&nbsp;～&nbsp;
										<span>{{ (data['manage.readUserProfile'].company.dt_use_end or "")|e}}</span>
									</li>
								</ul>
								<h4><span class="glyphicon glyphicon-user"></span>&nbsp;個人情報</h4>
								<ul style="list-style-type: none;">
									<li>
										<span class="bold textLabel">氏名：</span>
										<span>{{ data['manage.readUserProfile'].user.name|e }}</span>
									</li>
									<li>
										<span class="bold textLabel">社用電話番号：</span>
										<input type="text" id="input_profile_tel1"
											value="{{ data['manage.readUserProfile'].user.tel1|e }}"/>
									</li>
									<li style="display: none;">
										<span class="bold textLabel">個人電話番号：</span>
										<input type="text" id="input_profile_tel2"
											value="{{ (data['manage.readUserProfile'].user.tel2 or '')|e }}"/>
									</li>
									<li style="display: none;">
										<span class="bold textLabel">FAX番号：</span>
										<input type="text" id="input_profile_fax"
											value="{{ (data['manage.readUserProfile'].user.fax or '')|e }}"/>
									</li>
									<li>
										<span class="bold textLabel">メールアドレス：</span>
										<input type="text" id="input_profile_mail1"
											value="{{ data['manage.readUserProfile'].user.mail1|e }}"/>
									</li>
									<li>
										<span class="bold textLabel">最終ログイン日時：</span>
										<span>{{ data['manage.readUserProfile'].user.tm_last_login|e }}</span>
									</li>
                                    {% if data['manage.readUserProfile'].user.is_admin %}
									<li>
										<span class="bold textLabel">管理者フラグ：</span>
										<input type="checkbox" id="input_profile_is_admin"
											{% if data['manage.readUserProfile'].user.is_admin == True %} checked="checked"{% endif %}/>
									</li>
                                    {% endif %}
									<li>
										<span class="bold textLabel">パスワード：</span>
										<input type="password" id="input_profile_password"/>
										<span class="text-danger">変更時のみ入力してください。</span>
									</li>
									<li>
										<span class="bold textLabel">パスワード（確認）</span>
										<input type="password" id="input_profile_password_confirm"/>
										<span class="text-danger">変更時のみ入力してください。</span>
									</li>
									<li><hr/></li>
									<li>
										<div class="col-sm-offset-1 col-sm-10">
											<input type="button" class="btn btn-primary" value="更新"
												onclick="hdlClickUpdateProfile();"/>
										</div>
									</li>
								</ul>
							</div>
							<div class="tab-pane fade" id="ct_help" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-info-sign"></span>&nbsp;ヘルプ利用</h4>
								<p>ヘルプ テキストをご覧になるには、チェックを付けて更新してください。チェックをはずして更新すると、ヘルプ テキストが非表示となります。</p>
								<ul style="list-style-type: none;">
									<li>
										<input type="checkbox" id="input_help_flg"{% if env.limit.SHOW_HELP %} checked="checked"{% endif %}/>
										<label class="bold textLabel" for="input_help_flg">ヘルプ利用フラグ</label>
									</li>
									<li>
										<div class="col-sm-offset-1 col-sm-10">
											<input type="button" class="btn btn-primary" value="更新"
												onclick="hdlClickUpdateHelp();"/>
										</div>
									</li>
								</ul>
                                <br/><br/>
								<h4 style="clear: both;"><span class="glyphicon glyphicon-list-alt"></span>&nbsp;表示件数</h4>
								<p>ホームと全文検索結果を除く各ページで、一覧表の表示件数を制御できます。既定値は50件です。</p>
								<ul style="list-style-type: none;">
									<li>
										<input type="text" id="input_row_length" value="{{ env.limit.ROW_LENGTH or 50 }}" pattern="^[0-9]{,2}$"/>&nbsp;件
									</li>
									<li>
										<div class="col-sm-offset-1 col-sm-10">
											<input type="button" class="btn btn-primary" value="更新"
												onclick="hdlClickUpdateRowLength();"/>
										</div>
									</li>
								</ul>
                            {% if data['auth.userProfile'].user.is_admin == True -%}
                                <br/><br/>
                                <h4 style="clear: both;"><span class="glyphicon glyphicon-share"></span>&nbsp;マッチング用公開設定</h4>
								<p>案件と要員の情報を本CRMを使用している他社ユーザに公開できます。<span class="text-danger">※案件と要員にも設定が必要です。</span><br/>
                                    公開された案件と要員は他社ユーザの案件マッチングと要員マッチングの画面にも表示されるようになります。
                                </p>
								<ul style="list-style-type: none;">
									<li>
                                        <input type="radio" name="input_flg_public" id="input_flg_public_1" value="1" {% if data['manage.readUserProfile'].company.flg_public == 1 %}checked="checked"{% endif %}><label for="input_flg_public_1">公開</label>
										<input type="radio" name="input_flg_public" id="input_flg_public_0" value="0" {% if data['manage.readUserProfile'].company.flg_public == 0 %}checked="checked"{% endif %}><label for="input_flg_public_0">非公開</label>
									</li>
									<li>
										<div class="col-sm-offset-1 col-sm-10">
											<input type="button" class="btn btn-primary" value="更新"
												onclick="hdlClickUpdateFlgPublic();"/>
										</div>
									</li>
								</ul>
                            {% endif %}
							</div>
							<div class="tab-pane fade" id="ct_account" style="padding: 1em 1.5em;">
								{% if env.limit.SHOW_HELP %}
								<p>本CRMにログイン出来るアカウントを管理します。<br/>新規登録では新規アカウントを作成することが出来ます。</p>
								{% endif %}
								<div style="margin: 0.5em 0;">
									{{ buttons.new_obj("editAccountObj();") }}
								</div>
								<table class="view_table table-bordered">
									<thead>
										<tr>
											{#<th class="center" style="width: 35px;">選択<br/><input type="checkbox"/></th>#}
											<th class="center" style="width: 55px;">状態</th>
											<th>名前</th>
											<th>ID</th>
											<th>メールアドレス</th>
											<th style="width: 160px;">社用電話番号{#&nbsp;/<br/>個人電話番号&nbsp;/<br/>FAX番号#}</th>
											<th style="width: 180px;">最終ログイン</th>
											<th class="center" style="width: 45px;">無効化</th>
											<th>最終<br/>ログイン<br/>日時</th>
										</tr>
									</thead>
									<tbody>
										{% for item in data['manage.enumAccounts'] %}
										<tr id="iter_accounts_{{ item.id }}"{% if item.is_enabled == False %}class="text-muted"{% endif %}>
											{#
											<td class="center">
												<input type="checkbox"/>
											</td>
											#}
											<td class="center">
												{% if item.is_locked == True %}
												<span class="glyphicon glyphicon-lock text-warning" title="ロック"></span>
												{% endif %}
												{% if item.is_enabled == False %}
												<span class="glyphicon glyphicon-ban-circle text-danger" title="利用停止"></span>
												{% endif %}
												{% if item.is_admin == True %}
												<span class="glyphicon glyphicon-wrench text-info" title="管理者"></span>
												{% endif %}
											</td>
											<td class="center">
												<span class="pseudo-link"
													onclick="editAccountObj(JSON.parse('{{ item|tojson|forceescape }}'));">{{ item.name|e }}</span>
											</td>
											<td class="center mono">{{ item.login_id|e }}</td>
											<td class="mono">{{ item.mail1|e }}</td>
											<td class="center">{#<span class="glyphicon glyphicon-phone-alt"><span>#}&nbsp;{{ item.tel1|e }}{#<br/><span class="glyphicon glyphicon-phone"></span>&nbsp;{{ (item.tel2 or "")|e }}<br/><span class="glyphicon glyphicon-print"></span>&nbsp;{{ (item.fax or "")|e }}#}</td>
											<td class="center">{{ (item.tm_last_login or "")|e }}</td>
											<td class="center">
												{% if item.is_enabled == True %}
												<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor"
													onclick="disableAccountItem({{ item.id }});"></span>
												{% endif %}
											</td>
											<td class="center">{% if item.dt_last_login %}{{ item.dt_last_login|e }}{% endif %}</td>
										</tr>
										{% endfor %}
									</tbody>
								</table>
							</div>
							{% if (env and env.limit.LMT_ACT_MAIL == True) or not env %}
							<div class="tab-pane fade" id="ct_template" style="padding: 1em 1.5em;">
								{% if env.limit.SHOW_HELP %}
								<p>メール作成画面で使用するメールテンプレートを作成します。<br/>ここでメールテンプレートを使用することで取引先などへメールを送付する際の効率化できます。</p>
								{% endif %}
								<div style="margin: 0.5em 0;">
									{{ buttons.new_obj("editTemplateObj();") }}
								</div>
								<table class="view_table table-bordered">
									<thead>
										<tr>
											<th style="width: 150px;">送信先種別</th>
											<th style="width: 120px;">内容種別</th>
											<th>テンプレート名</th>
											<th>テンプレート件名</th>
											<th>添付</th>
											<th>削除</th>
										</tr>
									</thead>
									<tbody>
									{% if data['mail.enumTemplates'] %}
										{% for item in data['mail.enumTemplates'] %}
											{% if item.type_recipient == "マッチング" %}
												{% if item.name == "案件マッチング" %}
													<tr id="iter_template_{{ item.id }}">
														<td class="center" rowspan="2">{{ item.type_recipient }}</td>
														<td class="center">{{ item.type_iterator|join("<br/>") }}</td>
														<td>
															<span class="popover-dismiss pseudo-link-cursor"
																data-toggle="popover"
																data-content="既定のテンプレートは編集および詳細閲覧ができません"
																onmouseover="$(this).popover('show');"
																onmouseout="$(this).popover('hide');"><span class="glyphicon glyphicon-exclamation-sign"></span>&nbsp;{{ item.name }}</span>
														</td>
														<td rowspan="2">{{ item.subject|e }}</td>
														<td class="center">
														{% for atmt in item.attachments %}
															<span class="glyphicon glyphicon-paperclip text-info pseudo-link-cursor"
																title="{{ atmt.name|e }}:{{ atmt.size|filesizeformat }}"
																onclick="c4s.download( {{ atmt.id }})"></span>
														{% endfor %}
														</td>
														<td class="center" rowspan="2">
														</td>
													</tr>
												{% else %}
													<tr id="iter_template_{{ item.id }}">
														<td class="center">{{ item.type_iterator|join("<br/>") }}</td>
														<td>
															<span class="popover-dismiss pseudo-link-cursor"
																data-toggle="popover"
																data-content="既定のテンプレートは編集および詳細閲覧ができません"
																onmouseover="$(this).popover('show');"
																onmouseout="$(this).popover('hide');"><span class="glyphicon glyphicon-exclamation-sign"></span>&nbsp;{{ item.name }}</span>
														</td>
														<td class="center">
														{% for atmt in item.attachments %}
															<span class="glyphicon glyphicon-paperclip text-info pseudo-link-cursor"
																title="{{ atmt.name|e }}:{{ atmt.size|filesizeformat }}"
																onclick="c4s.download( {{ atmt.id }})"></span>
														{% endfor %}
														</td>
													</tr>
												{% endif %}
											{% else %}
												<tr id="iter_template_{{ item.id }}">
													<td class="center">{{ item.type_recipient }}</td>
													<td class="center">{{ item.type_iterator|join("<br/>") }}</td>
													<td>
													{% if item.type_recipient not in ("取引先担当者（既定）", "技術者（既定）", "リマインダー", "マッチング") %}
														<span class="pseudo-link"
															onclick="editTemplateObj({{ item.id }});">{{ item.name|e }}</span>
													{% else %}
														<span class="popover-dismiss pseudo-link-cursor"
															data-toggle="popover"
															data-content="既定のテンプレートは編集および詳細閲覧ができません"
															onmouseover="$(this).popover('show');"
															onmouseout="$(this).popover('hide');"><span class="glyphicon glyphicon-exclamation-sign"></span>&nbsp;{{ item.name }}</span>
													{% endif %}
													</td>
													<td>{{ item.subject|e }}</td>
													<td class="center">
													{% for atmt in item.attachments %}
														<span class="glyphicon glyphicon-paperclip text-info pseudo-link-cursor"
															title="{{ atmt.name|e }}:{{ atmt.size|filesizeformat }}"
															onclick="c4s.download( {{ atmt.id }})"></span>
													{% endfor %}
													</td>
													<td class="center">
													{% if item.type_recipient not in ("取引先担当者（既定）", "技術者（既定）", "リマインダー", "マッチング") %}
														<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor"
															onclick="c4s.hdlClickDeleteItem('template', {{ item.id }}, true);"></span>
													{% endif %}
													</td>
												</tr>
											{% endif %}
										{% endfor %}
									{% endif %}
									</tbody>
								</table>
							</div>
							{% endif %}
							{% if (env and env.limit.LMT_ACT_MAIL == True) or not env %}
							<div class="tab-pane fade" id="ct_mail" style="padding: 1em 1.5em;">
								<div class="row">
									{% if env.limit.SHOW_HELP %}
									<p>メール作成画面でデフォルトで表示するCCアドレス、BCCアドレスを設定できます。</p>
									{% endif %}
									<h4>アドレス追加</h4>
									<div class="col-sm-4">
										<span class="text-danger">必須入力項目（＊）</span>
										<div class="input-group">
											<span class="input-group-addon">種別<span class="text-danger">*</span></span>
											<ul class="form-control" style="list-style-type: none;">
												<li>
													<input type="radio" name="input_receiver_type_rbg" id="input_receiver_type_0" checked="checked"/>
													<label for="input_template_type_0">CC</label>
												</li>
												<li>
													<input type="radio" name="input_receiver_type_rbg" id="input_receiver_type_1"/>
													<label for="input_template_type_1">BCC</label>
												</li>
											</ul>
										</div>
										<div class="input-group">
											<span class="input-group-addon">名前</span>
											<input type="text" class="form-control" id="input_receiver_name"/>
										</div>
										<div class="input-group">
											<span class="input-group-addon">メールアドレス<span class="text-danger">*</span></span>
											<input type="text" class="form-control" id="input_receiver_mail"/>
										</div>
										<hr/>
										<div class="pull-right">
											<button class="btn btn-primary"
												onclick="addReceiver();">追加</button>
										</div>
									</div>
									<ul class="col-sm-8" style="list-style-type: none;">
										<li>
											{% for item in data['manage.readMailReceiver'].MAIL_RECEIVER_CC %}
											<span class="bold textLabel">
												{% if loop.index == 1 %}CCアドレス：{% else %}&nbsp;{% endif %}
											</span>
											{{ item.name|e }}&lt;{{ item.mail|e }}&gt;&nbsp;
											<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor"
												onclick="removeReceiver('MAIL_RECEIVER_CC', {{ loop.index0 }});"></span>
											{% if loop.index != data['manage.readMailReceiver'].MAIL_RECEIVER_CC|length %}<br/>{% endif %}
											{% endfor %}
										</li>
										<li>
											{% for item in data['manage.readMailReceiver'].MAIL_RECEIVER_BCC %}
											<span class="bold textLabel">{% if loop.index == 1 %}BCCアドレス：{% else %}&nbsp;{% endif %}</span>
											{{ item.name|e }}&lt;{{ item.mail|e }}&gt;&nbsp;<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor" onclick="removeReceiver('MAIL_RECEIVER_BCC', {{ loop.index0 }});"></span>
											{% if loop.index != data['manage.readMailReceiver'].MAIL_RECEIVER_BCC|length %}<br/>{% endif %}
											{% endfor %}
										</li>
									</ul>
								</div>
							</div>
							{% endif %}
							<div class="tab-pane fade" id="ct_preferences" style="padding: 1em 1.5em;">
								<div class="col-md-8">
									<table class="view_table table-bordered table-hover col-md-5">
									{% set PREFS = data['manage.enumPrefsDict'] -%}
										<thead>
											<tr>
												<th>制限値</th>
												<th>設定値</th>
												<th>現在値</th>
												<th>利用率</th>
											</tr>
										</thead>
										<tbody>
											{% set item = PREFS['LMT_ACT_MAIL'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">メール利用オプション</td>
												<td class="center">{% if item.final %}<span class="glyphicon glyphicon-ok text-success"></span>{% else %}<span class="glyphicon glyphicon-remove text-danger"></span>{% endif %}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td></td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_ACT_MAP'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">地図利用オプション</td>
												<td class="center">{% if item.final %}<span class="glyphicon glyphicon-ok text-success"></span>{% else %}<span class="glyphicon glyphicon-remove text-danger"></span>{% endif %}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td></td>
											</tr>
												{% if item.final %}
												{% set item = PREFS['LMT_CALL_MAP_EXTERN_M'] %}
												<tr>
													<td class="bold" style="padding: 0.2em 1.5em;">地図利用数上限</td>
													<td class="center">{{ item.final or "無制限" }}</td>
													<td class="center">{{ item.current or "" }}</td>
													<td>
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 %}progress-bar-danger{% elif ratio > 0.7 %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
													</td>
												</tr>
												{% endif %}
											{% endif -%}
											{% set item = PREFS['LMT_LEN_ACCOUNT'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">ユーザー アカウント数上限</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_CLIENT'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">取引先登録数上限</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_WORKER'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">取引先担当者登録数上限</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_PROJECT'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">案件登録数上限</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_ENGINEER'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">要員登録数上限</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_MAIL_TPL'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">メール テンプレート数上限</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_MAIL_PER_DAY'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">メール発信数上限（24時間）</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_MAIL_PER_MONTH'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">メール発信数上限（1ヶ月間）</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_MAIL_ATTACHMENT'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">メール添付ファイル数上限</td>
												<td class="center">{{ item.final or "無制限" }}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_SIZE_BIN'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">添付ファイルサイズ上限（1ファイル）</td>
												<td class="center">{{ item.final|filesizeformat or "無制限"}}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td></td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_LEN_STORE_DATE'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">利用済みデータ保持期間</td>
												<td class="center">{% if item.final %}{{ item.final }}日{% else %}無期限{% endif %}</td>
												<td class="center">{{ item.current or "" }}</td>
												<td></td>
											</tr>
											{% endif -%}
											{% set item = PREFS['LMT_SIZE_STORAGE'] -%}
											{% if item -%}
											<tr>
												<td class="bold" style="padding: 0.2em 1.5em;">ストレージ利用量上限</td>
												<td class="center">{%if item.final %}{{ item.final|filesizeformat }}{% else %}無制限{% endif %}</td>
												<td class="center">{{ (item.current or 0)|filesizeformat }}</td>
												<td class="center">
													<div class="progress" style="width: 150px; margin: 0 auto;">
														{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
														<div
															class="progress-bar {% if ratio > 0.9 and item.final %}progress-bar-danger{% elif ratio > 0.7 and item.final %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
															role="progressbar"
															style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
															aria-valuenow="{{ item.current or 0 }}"
															aria-valuemin="0"
															aria-valuemax="{{ item.final }}"
														><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}" title="{{ ratio * 100 }}%">{{ "%03.2f%% "|format(ratio * 100) }}</span>
														</div>
													</div>
												</td>
											</tr>
											{% endif -%}
										</tbody>
									</table>
								</div>
							</div>
                            <div class="tab-pane fade" id="ct_form" style="padding: 1em 1.5em;">
								{% if env.limit.SHOW_HELP %}
								<p>各種帳票（見積書・請求先注文書・注文書・請求書）のデフォルト値を設定できます。<br>例えば以下の項目を設定することで請求書の振込先情報の設定を行います。<br>また、各種帳票の担当者名表示の設定を行います。</p>
								{% endif %}
								<h4><span class="glyphicon glyphicon-file"></span>&nbsp;帳票設定</h4>
								<ul style="list-style-type: none;">
{#                                    <li>#}
{#										<span class="bold textLabel">支払い条件：</span>#}
{#										<input type="text" id=""#}
{#											value=""/>#}
{#									</li>#}
{#									<li>#}
{#										<span class="bold textLabel">有効期限：</span>#}
{#										<input type="text" id=""#}
{#											value=""/>#}
{#									</li>#}
{#                                    <li>#}
{#										<span class="bold textLabel">備考：</span>#}
{#										<textarea style="height: 10em; width: 70%;"></textarea>#}
{#                                        <br/>#}
{#									</li>#}
                                    <li style="">
										<span class="bold textLabel">振込先１：</span>
										<input style="width: 500px" type="text" id="m_manage_bank_account1" value="{% if data['manage.readUserProfile'].company.bank_account1 %}{{ data['manage.readUserProfile'].company.bank_account1 }}{% endif %}" placeholder="〇〇銀行〇〇支店　普通　XXXXXXXX　〇〇〇〇" maxlength="64"/>
									</li>
                                    <li style="margin-top: 5px">
										<span class="bold textLabel">振込先２：</span>
										<input style="width: 500px" type="text" id="m_manage_bank_account2" value="{% if data['manage.readUserProfile'].company.bank_account2 %}{{ data['manage.readUserProfile'].company.bank_account2 }}{% endif %}" placeholder="〇〇銀行〇〇支店　普通　XXXXXXXX　〇〇〇〇" maxlength="64"/>
									</li>
                                    <li style="margin-top: 5px">
										<span class="bold textLabel">見積書担当者：</span>
										<select class="" style="width: 150px;" id="m_manage_estimate_charging_user_id">
                                            <option></option>
                                        {% for item in data['manage.enumAccounts'] %}
                                            {% if item.is_enabled == True %}
                                            <option value="{{ item.id }}" {% if item.id == data['manage.readUserProfile'].company.estimate_charging_user_id %}selected{% endif %}>{{ item.name|e }}</option>
                                            {% endif %}
                                        {% endfor %}
                                        </select>
									</li>
                                    <li style="margin-top: 5px">
										<span class="bold textLabel">請求先注文書担当者：</span>
										<select class="" style="width: 150px;" id="m_manage_order_charging_user_id">
                                            <option></option>
                                        {% for item in data['manage.enumAccounts'] %}
                                            {% if item.is_enabled == True %}
                                            <option value="{{ item.id }}" {% if item.id == data['manage.readUserProfile'].company.order_charging_user_id %}selected{% endif %}>{{ item.name|e }}</option>
                                            {% endif %}
                                        {% endfor %}
                                        </select>
									</li>
                                    <li style="margin-top: 5px">
										<span class="bold textLabel">注文書担当者：</span>
										<select class="" style="width: 150px;" id="m_manage_purchase_charging_user_id">
                                            <option></option>
                                        {% for item in data['manage.enumAccounts'] %}
                                            {% if item.is_enabled == True %}
                                            <option value="{{ item.id }}" {% if item.id == data['manage.readUserProfile'].company.purchase_charging_user_id %}selected{% endif %}>{{ item.name|e }}</option>
                                            {% endif %}
                                        {% endfor %}
                                        </select>
									</li>
                                    <li style="margin-top: 5px">
										<span class="bold textLabel">請求書担当者：</span>
										<select class="" style="width: 150px;" id="m_manage_invoice_charging_user_id">
                                            <option></option>
                                        {% for item in data['manage.enumAccounts'] %}
                                            {% if item.is_enabled == True %}
                                            <option value="{{ item.id }}" {% if item.id == data['manage.readUserProfile'].company.invoice_charging_user_id %}selected{% endif %}>{{ item.name|e }}</option>
                                            {% endif %}
                                        {% endfor %}
                                        </select>
									</li>
                                    <li style="margin-top: 5px">
										<span class="bold textLabel">社印：</span>
										<input type="file" style="display: inline;" name="userfile" accept="image/*" id="company-seal" />
									</li>
                                    <li>
										<span class="bold textLabel"></span>
                                        <span id="company-seal-image">
                                            {% if data['manage.readUserProfile'].company.company_seal  %}
                                                <img style="height: 100px; width: 100px;" src="{{ data['manage.readUserProfile'].company.company_seal|e }}">
                                            {% endif %}
                                        </span>
									</li>
									<li style="margin-top: 5px">
										<span class="bold textLabel">社版：</span>
										<input type="file" style="display: inline;" name="userfile" accept="image/*" id="company-version" />
									</li>
                                    <li>
										<span class="bold textLabel"></span>
                                        <span id="company-version-image">
                                            {% if data['manage.readUserProfile'].company.company_version  %}
                                                <img style="height: auto; width: auto;" src="{{ data['manage.readUserProfile'].company.company_version|e }}">
                                            {% endif %}
                                        </span>
									</li>
									<li><hr/></li>
									<li>
										<div class="col-sm-offset-1 col-sm-10">
                                            {% if query.back_page_quotation_location %}
                                            <input type="button" class="btn btn-primary" value="更新して帳票作成に戻る"
												onclick="hdlClickBackPageQuotation('{{ query.back_page_quotation_location }}');"/>
                                            {% else %}
                                                <input type="button" class="btn btn-primary" value="更新"
												onclick="hdlClickUpdateQuotationSetting();"/>
                                            {% endif %}
										</div>
									</li>

								</ul>
							</div>
							{#
							<div class="tab-pane fade" id="ct_migrate" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;取り込みデータの指定</h4>
								<div class="input-group" style="">
									<span class="input-group-addon">ファイル<br/>(XLS形式)</span>
									<div class="form-control">
										<input type="hidden" id="input_attachment_migrate_id"/>
										<label id="input_attachment_migrate_label"
											onclick="$('#input_attachment_migrate_id').val() ? c4s.download(Number($('#input_attachment_migrate_id').val())) : null;"></label>
										<input type="file" id="input_attachment_migrate_file"
											onchange="uploadFile('#input_attachment_migrate_file', '#input_attachment_migrate_id', '#input_attachment_migrate_label');"/>
									</div>
								</div>
								<div class="input-group" style="width: 100%;">
									<span class="input-group-addon">メモ</span>
									<textarea class="form-control" id="input_migrate_memo" placeholder="メモを入力できます"></textarea>
								</div>
								<hr/>
								<div style="text-align: right;">
									<a href="/assets/%E3%83%87%E3%83%BC%E3%82%BF%E7%A7%BB%E8%A1%8C%E3%83%86%E3%83%B3%E3%83%97%E3%83%AC%E3%83%BC%E3%83%88.xls" target="_blank" style="float: left;">データ移行テンプレート.xls</a>
									<button onclick="hdlClickMigrateInvokeBtn();">登録</button>
								</div>
							</div>
							#}
							{#
							<div class="tab-pane fade" id="ct_migrate_full" style="padding: 1em 1.5em;">
								<p>取引先と取引先担当者のデータをインポートできます。</p>
								<div class="col-lg-5">
									<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;取り込みデータの指定</h4>
									<div class="input-group" style="">
										<span class="input-group-addon">ファイル<br/>(XLS形式)</span>
										<div class="form-control">
											<input type="hidden" id="input_attachment_migrate_full_id"/>
											<label id="input_attachment_migrate_full_label"
												onclick="$('#input_attachment_migrate_full_id').val() ? c4s.download(Number($('#input_attachment_migrate_full_id').val())) : null;"></label>
											<input type="file" id="input_attachment_migrate_full_file"
												onchange="uploadFile('#input_attachment_migrate_full_file', '#input_attachment_migrate_full_id', '#input_attachment_migrate_full_label');"/>
										</div>
									</div>
									<div class="input-group" style="width: 100%;">
										<span class="input-group-addon">メモ</span>
										<textarea class="form-control" id="input_migrate_full_memo" placeholder="メモを入力できます"></textarea>
									</div>
									<hr/>
									<div style="text-align: right;">
										<a href="/assets/%E3%83%87%E3%83%BC%E3%82%BF%E7%A7%BB%E8%A1%8C%E3%83%86%E3%83%B3%E3%83%97%E3%83%AC%E3%83%BC%E3%83%88.xls" target="_blank" style="float: left;">データ移行テンプレート.xls</a>
										<button onclick="hdlClickMigrateInvokeBtn('full');">登録</button>
									</div>
								</div>
								<div class="col-lg-7">
									<h4><span class="glyphicon glyphicon-th-list"></span>&nbsp;履歴<button style="font-size: 12px; font-weight: bold; float: right;" onclick="hdlClickRefreshMigrateRequests();"><span class="glyphicon glyphicon-refresh text-success"></span>&nbsp;表示更新</button></h4>
									<table class="view_table table-bordered table-hover" id="view_migrate_req_tbl">
										<thead>
											<tr>
												<!--<th>識別子</th>-->
												<th colspan="2">ステータス</th>
												<th>ファイル名</th>
												<th>サイズ（bytes）</th>
												<th>登録日</br>最終更新日</th>
											</tr>
										</thead>
										<tbody></tbody>
									</table>
								</div>
							</div>
							#}
							<div class="tab-pane fade" id="ct_prefs" style="padding: 1em 1.5em;">
								<table class="view_table table-bordered table-hover">
									<thead>
										<tr>
											<th>KEY</th>
											<th>DEFAULT</th>
											<th>PROPER</th>
											<th>FINAL</th>
											<th>RATIO</th>
										</tr>
									</thead>
									<tbody>
										{% for item in data['manage.enumPrefs']|sort(attribute="key") %}
										<tr>
											<td class="bold mono">{{ item.key }}</td>
											<td>{{ item.default }}</td>
											<td>{{ item.proper }}</td>
											<td>{{ item.final }}</td>
											<td>
											{% if "current" in item %}
												<div class="progress" style="width: 150px; margin: 0px;">
													{% set ratio = (item.current or 0) / (item.final or item.current or 1) %}
													<div
														class="progress-bar {% if ratio > 0.9 %}progress-bar-danger{% elif ratio > 0.7 %}progress-bar-warning{% elif ratio > 0.4 %}progress-bar-info{% else %}progress-bar-success{% endif %}"
														role="progressbar"
														style="width: {% if ratio < 1.0 %}{{ ratio * 100 }}{% else %}100{% endif %}%;"
														aria-valuenow="{{ item.current or 0 }}"
														aria-valuemin="0"
														aria-valuemax="{{ item.final }}"
													><span class="bold" style="{%if ratio < 0.4 %}color: #666;{% endif%}">{% if "SIZE" in item.key %}{{ (item.current or 0)|filesizeformat }} / {{ item.final|filesizeformat }}{% else %}{{ item.current or 0 }} / {{ item.final }}{% endif %}</span>
													</div>
												</div>
											{% endif %}
											</td>
										</tr>
										{% endfor %}
									</tbody>
								</table>
							</div>
                            {% if data['manage.readUserProfile'].user.is_admin and data['manage.readUserProfile'].company.is_admin %}
                            <div class="tab-pane fade" id="ct_user_group" style="padding: 1em 1.5em;">
								{% if env.limit.SHOW_HELP %}
								<p>本CRMを利用する顧客企業を管理します。<br/>新規登録では新規顧客企業を作成することが出来ます。</p>
								{% endif %}
								<div style="margin: 0.5em 0;">
									{{ buttons.new_obj("editUserCompaniesObj();") }}
								</div>
								<table class="view_table table-bordered">
									<thead>
										<tr>
											<th>no</th>
											<th>社名</th>
                                            <th>代表</th>
                                            <th>住所</th>
											<th>代表電話番号</th>
                                            <th>代表FAX番号</th>
                                            <th>prefix</th>
											<th>利用期間</th>
                                            <th>設定</th>
											<th class="center" style="width: 45px;">無効化</th>
											<th>最終<br/>ログイン<br/>日時</th>
										</tr>
									</thead>
									<tbody>
                                        {% for item in data['manage.enumUserCompanies'] %}
                                            {% if item.id != 0 %}
                                            <tr id="iter_accounts_{{ item.id }}">
                                                <td class="center">{{ item.id|e }}</td>
                                                <td class="center pseudo-link"
                                                        onclick="editUserCompaniesObj(JSON.parse('{{ item|tojson|forceescape }}'));">{{ item.name|e }}</td>
                                                <td class="center">{{ item.owner_name|e }}</td>
                                                <td class="left">〒{{ item.addr_vip|e }}&nbsp;{{ item.addr1|e}}{{ item.addr2|e}}</td>
                                                <td class="center">{{ item.tel|e }}</td>
                                                <td class="center">&nbsp;{{ item.fax|e }}</td>
                                                <td class="center">&nbsp;{{ item.prefix|e }}</td>
                                                <td class="center">{% if item.dt_use_begin %}{{ item.dt_use_begin|e }}{% endif %} ～ {% if item.dt_use_end %}{{ item.dt_use_end|e }}{% endif %}</td>
                                                <td class="center"><a class="glyphicon glyphicon-wrench text-info pseudo-link" onclick="editUserCompanyCapObj(JSON.parse('{{ item|tojson|forceescape }}'));"></a></td>
                                                <td class="center">
                                                    {% if item.is_enabled == False %}
                                                    <span class="glyphicon glyphicon-ban-circle text-danger" title="利用停止"></span>
                                                    {% endif %}
                                                </td>
												<td class="center">{% if item.dt_last_login %}{{ item.dt_last_login|e }}{% endif %}</td>
                                            </tr>
                                            {% endif %}
										{% endfor %}
									</tbody>
								</table>
							</div>
                            {% endif %}
                            {% if data['manage.readUserProfile'].user.is_admin and data['manage.readUserProfile'].company.is_admin %}
                            <div class="tab-pane fade" id="ct_new_information" style="padding: 1em 1.5em;">
								<form class="form-horizontal" role="form">
									<input type="hidden" name="info_id" id="info_id" value="{{data['manage.information'].id}}">
									<div class="form-group">
										<label for="input_new_information" class="col-sm-2 control-label">最新情報</label>
										<div class="col-sm-offset-2 col-sm-10">
											<textarea class="form-control" id="input_new_information" style="height: 20em;">{{ data['manage.information'].content|e }}</textarea>
										</div>
									</div>
									<div class="form-group">
										<div class="col-sm-offset-2 col-sm-10">
											<input type="button" class="btn btn-primary" value="登録" onclick="hdlClickUpdateNews();"/>
										</div>
									</div>
								</form>
                            </div>
                        	{% endif %}
						</div><!-- div.tab-content -->
					</div><!-- div.row -->
				</div>
			</div>
			<!-- /メインコンテンツ -->
<!-- [begin] Modal. -->
<div id="edit_account_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_account_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_account_modal_title">新規アカウント登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="input_account_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon">氏名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_account_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">社用電話番号<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_account_tel1"/>
				</div>
				<div class="input-group" style="display: none;">
					<span class="input-group-addon">個人電話番号</span>
					<input type="text" class="form-control" id="input_account_tel2"/>
				</div>
				<div class="input-group" style="display: none;">
					<span class="input-group-addon">FAX番号</span>
					<input type="text" class="form-control" id="input_account_fax"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">メールアドレス<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_account_mail1"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">ログインID<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_account_login_id"/>
					{% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;既存アカウントと重複したログインIDは設定できません</span>{% endif -%}
				</div>
				<div class="input-group">
					<span class="input-group-addon">パスワード<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_account_password"/>
					{% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;ログイン時のパスワードを決定します</span>{% endif -%}
				</div>
				<div class="input-group">
					<span class="input-group-addon">フラグ</span>
					<div class="form-control">
						<label class="" for="input_account_is_admin">管理者フラグ</label>
						<input type="checkbox" class="" id="input_account_is_admin"/>
						{% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;管理者フラグは管理者としての権限を付与します</span>{% endif -%}
						<br/>
						<label class="" for="input_account_is_locked">ロックアウト</label>
						<input type="checkbox" class="" id="input_account_is_locked"/>
						{% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;ロックアウトは一時的にアカウントを利用不可にします（システムが自動付与することがあります）</span>{% endif -%}
						<br/>
						<label class="" for="input_account_is_enabled">有効化フラグ</label>
						<input type="checkbox" class="" id="input_account_is_enabled"/>
						{% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;有効化されると、利用ユーザー数にカウントされます</span>{% endif -%}
						<hr style="margin-top: 0.5em; margin-bottom: 0.5em;"/>
						<span id="input_account_status" class="text-danger" style="margin-bottom: 0.5em;"></span>
					</div>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" id="input_account_btn"
					onclick="commitAccountObj($('#input_account_id').val() || null);">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_user_companies_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_user_companies_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_user_companies_modal_title">新規顧客企業登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <input type="hidden" id="input_user_companies_id"/>
                <span class="text-danger">必須入力項目（＊）</span>
                <div class="input-group">
                    <span class="input-group-addon">社名<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_name"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">代表者氏名<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_owner_name"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">代表電話番号<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_tel"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">代表FAX番号</span>
                    <input type="text" class="form-control" id="input_user_companies_fax"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">郵便番号<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_addr_vip" placeholder="nnn-nnnn" style="width: 8em;" maxlength="8"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#input_user_companies_addr_vip').val(), '#input_user_companies_addr1', '#input_user_companies_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">住所<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_addr1"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">住所（ビル名）<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_addr2"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">prefix<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_prefix"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">利用期間<span class="text-danger">*</span></span>
                    <input type="text" class="form-control" id="input_user_companies_dt_use_begin" data-date-format="yyyy/mm/dd"/>〜
                    <input type="text" class="form-control" id="input_user_companies_dt_use_end" data-date-format="yyyy/mm/dd" />
                </div>
{#                <div class="input-group">#}
{#					<span class="input-group-addon">支払い期限<span class="text-danger">*</span></span>#}
{#                    <input type="date" class="form-control" id="input_user_companies_dt_charged_end"/>#}
{#				</div>#}

                <div class="input-group">
                    <span class="input-group-addon">フラグ<span class="text-danger">*</span></span>
                    <div class="form-control">
                        <label class="" for="input_account_is_enabled">有効化フラグ</label>
                        <input type="checkbox" class="" id="input_user_companies_is_enabled"/>
                        <br/>
                        {% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;有効化フラグのチェックをはずすとこの企業に所属するユーザはログインができなくなります</span>{% endif -%}
                        <span id="input_user_companies_status" class="text-danger" style="margin-bottom: 0.5em;"></span>
                    </div>
                </div>

                <span id="new_admin_form_area">
                    <hr>
                    <span class="text-danger">新規登録時には管理者を登録する必要があります。</span><br>
                    <span class="text-danger">必須入力項目（＊）</span>
                    <div class="input-group">
                        <span class="input-group-addon">管理者氏名<span class="text-danger">*</span></span>
                        <input type="text" class="form-control" id="input_admin_name"/>
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">社用電話番号<span class="text-danger">*</span></span>
                        <input type="text" class="form-control" id="input_admin_tel"/>
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">メールアドレス<span class="text-danger">*</span></span>
                        <input type="text" class="form-control" id="input_admin_mail"/>
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">ログインID<span class="text-danger">*</span></span>
                        <input type="text" class="form-control" id="input_admin_login_id"/>
                        {% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;既存アカウントと重複したログインIDは設定できません</span>{% endif -%}
                    </div>
                    <div class="input-group">
                        <span class="input-group-addon">パスワード<span class="text-danger">*</span></span>
                        <input type="text" class="form-control" id="input_admin_password"/>
                        {% if env.limit.SHOW_HELP -%}<span class="text-danger">&nbsp;ログイン時のパスワードを決定します</span>{% endif -%}
                    </div>
                </span>


			</div><!-- div.modal-body -->
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
                <button type="button" class="btn btn-primary" id="input_user_companies_btn"
                        onclick="commitUserCompaniesObj($('#input_user_companies_id').val() || null);">保存</button>
			</div><!-- div.modal-footer -->



		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_user_company_cap_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_user_company_cap_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_user_companies_cap_modal_title">顧客企業制限設定</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">

                <span class="text-danger">必須入力項目（＊）</span><br/>
                <span class="text-danger">０を登録すると無制限になります。</span>
                <input type="hidden" id="input_user_company_cap_id"/>
                <div class="input-group">
                    <span class="input-group-addon">ユーザー アカウント数上限<span class="text-danger">*</span></span>
                    <input type="number" class="form-control" id="input_user_companies_cap_account"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">取引先登録数上限<span class="text-danger">*</span></span>
                    <input type="number" class="form-control" id="input_user_companies_cap_client"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">取引先担当者登録数上限<span class="text-danger">*</span></span>
                    <input type="number" class="form-control" id="input_user_companies_cap_worker"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">案件登録数上限<span class="text-danger">*</span></span>
                    <input type="number" class="form-control" id="input_user_companies_cap_project"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">要員登録数上限<span class="text-danger">*</span></span>
                    <input type="number" class="form-control" id="input_user_companies_engineer"/>
                </div>
                <div class="input-group">
                    <span class="input-group-addon">メール テンプレート数上限<span class="text-danger">*</span></span>
                    <input type="number" class="form-control" id="input_user_companies_cap_mail_tpl"/>
                </div>

			</div><!-- div.modal-body -->
            <div class="modal-footer">
                <button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
                <button type="button" class="btn btn-primary" id="input_user_companies_cap_btn"
                        onclick="commitUserCompanyCapObj($('#input_user_company_cap_id').val() || null);">保存</button>
			</div><!-- div.modal-footer -->

		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<div id="edit_template_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_template_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_template_modal_title">新規テンプレート登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="input_template_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon">テンプレート名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_template_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">件名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="input_template_subject"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">内容<span class="text-danger">*</span></span>
					<textarea class="form-control" id="input_template_body" style="height: 10em;"></textarea>
				</div>
				<div class="input-group">
					<span class="input-group-addon">種別<span class="text-danger">*</span></span>
					<ul class="form-control" style="list-style-type: none;">
						<li style="">
							<ul class="" style="padding: 0; list-style-type: none;">
								<li>
									<h4 class="bold">送信先種別：</h5>
									{% if env.limit.SHOW_HELP %}
									<p>メールの送信先はメール1件につき、取引先担当者と技術者のどちらかのみとなります。</p>
									</p>テンプレートを登録後に送信先種別を変更することはできません。</p>
									{% endif %}
								</li>
								<li style="margin-left: 2em;">
									<input type="radio" name="input_template_type_rbg" id="input_template_type_0" checked="checked"/>
									<label for="input_template_type_0">取引先担当者</label>
								</li>
								<li style="margin-left: 2em;">
									<input type="radio" name="input_template_type_rbg" id="input_template_type_1"/>
									<label for="input_template_type_1">技術者</label>
								</li>
							</ul>
						</li>
						<li style="">
							<ul class="" style="padding: 0; list-style-type: none;">
								<li>
									<h4 class="bold">送信内容種別：</h5>
									{% if env.limit.SHOW_HELP %}
									<p>メール本文に自動展開する登録済みデータの種別を指定します。</p>
									<p>「技術者情報」を選択すると、内容に<kbd>[技術者情報]</kbd>と入力しておくと、その場所にデータが展開されるようになります。</p>
									<p>また、「案件情報」を選択すると、内容に<kbd>[案件情報]</kbd>と入力しておくと、その場所にデータが展開されるようになります。</p>
									{% endif %}
								</li>
								<li style="margin-left: 2em;">
									<input type="checkbox" id="input_template_type_iterator_0"/>
									<label for="input_template_type_iterator_0">技術者情報</label>
								</li>
								<li style="margin-left: 2em;">
									<input type="checkbox" id="input_template_type_iterator_1"/>
									<label for="input_template_type_iterator_1">案件情報</label>
								</li>
							</ul>
						</li>
					</ul>
				</div>
				<div class="input-group">
					<span class="input-group-addon">添付ファイル</span>
					<ul class="form-control list-group">
					{% for idx in range(0, env.limit.LMT_LEN_MAIL_ATTACHMENT, 1) %}
						<li class="list-group-item" id="input_template_iter_attachment_{{ loop.index0 }}">
							<input type="hidden" id="input_template_attachment_{{ loop.index0 }}_id"/>
							<label id="input_template_attachment_{{ loop.index0 }}_label"
								onclick="$('#input_template_attachment_{{ loop.index0 }}_id').val() ? c4s.download(Number($('#input_template_attachment_{{ loop.index0 }}_id').val())) : null;"></label>
							<input type="file" id="input_template_attachment_{{ loop.index0 }}_file"
								onchange="uploadFile('#input_template_attachment_{{ loop.index0 }}_file', '#input_template_attachment_{{ loop.index0 }}_id', '#input_template_attachment_{{ loop.index0 }}_label');"/>
							<button type="button" class="btn btn-default bold"
								onclick="pseudoDeleteAttachment({{ loop.index0 }});"><span class="glyphicon glyphicon-trash text-danger"></span>&nbsp;ファイル削除</button>
						</li>
					{% endfor %}
					</ul>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" id="input_account_btn"
					onclick="commitTemplateObj($('#input_template_id').val() || null);">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="view_migrate_request_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#view_migrate_request_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span>詳細履歴（ID:&nbsp;<span id="view_migrate_request_modal_tr_id" style="font-family: monospace;"></span>）</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<table class="view_table table-bordered table-hover">
					<thead>
						<tr>
							<th rowspan="2" style="text-align: center;">ステータス</th>
							<th rowspan="2" style='text-align: center;'>メモ</th>
							<th style="text-align: center;">登録/更新日時</th>
						</tr>
						<tr>
							<th>登録/更新者</th>
						</tr>
					</thead>
					<tbody></tbody>
				</table>
				<hr/>
				<ul style="list-style-type: none;">
					<li class="input-group">
						<span class="input-group-addon">データ ファイル</span>
						<span class="form-control"></span>
					</li>
					<li class="input-group">
						<span class="input-group-addon">検証結果ファイル</span>
						<span class="form-control"></span>
					</li>
				</ul>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<!-- [end] Model. -->
{% include "cmn_cap.tpl" %}

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
        <script src="/js/bootstrap-datepicker.js" type="text/javascript"></script>
        <script src="/js/bootstrap-datepicker.ja.js" type="text/javascript"></script>
		<script src="/js/manage.js" type="text/javascript"></script>
		<script type="text/javascript">
$(document).ready(function (){
	if (env) {
		env.data = {};
		env.data.accounts = JSON.parse('{{ data['js.accounts']|tojson }}');
        env.data.companies = JSON.parse('{{ data['js.companies']|tojson }}');
		{#
		env.limit = JSON.parse('{{ env.limit|tojson }}');
		#}
	}
	hdlClickRefreshMigrateRequests();
});
		</script>
	</body>
</html>
