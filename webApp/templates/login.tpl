{% import "cmn_controls.macro" as buttons -%}
<!DOCTYPE html>
<html lang="ja">
	<head>
		<title>{{ title }}</title>
		<meta charset="UTF-8">
		<meta name="viewport" content="width=device-width, initial-scale=1.0">
		<script src="/js/jquery.1.11.js" type="text/javascript"></script>
		<script src="/js/bootstrap.min.js" type="text/javascript"></script>
		<link href="/css/bootstrap.min.css" rel="stylesheet" media="screen">
		<link href="/css/base.css" rel="stylesheet" media="screen">
		<script type="text/javascript">
var env = {
	prefix: "{{ env['prefix'] }}",
	login_id: "{{ env['login_id'] }}",
	credential: "{{ env['credential'] }}",
	cookie_cred: document.cookie.replace("cred=", ""),
	status: JSON.parse('{{ env.status|tojson }}'),
};
		</script>
		<script type="text/javascript">
function hdlClickLoginBtn() {
	var req = {};
	req.prefix = location.pathname.split("/")[1];
	req.login_id = $("#login_id")[0].value;
	req.password = $("#login_pass")[0].value;
	var json = $("#json_param")[0];
	json.value = JSON.stringify(req);
	return req.login_id && req.password;
}

function hdlClickResetPwdBtn() {
	$("#reset_pwd_modal").modal("show");
	return false;
}

function sendResetPwdMail() {
	var login_id = $("#resetpwd_id").val().trim();
	var addr = $("#resetpwd_mail").val().trim();
	if (addr.match("^([0-9a-zA-Z_.\\-\+]+@[0-9a-zA-Z_.\\-\+]+)$")) {
		$.ajax({
			async: false,
			contentType: "application/json",
			cache: false,
			dataType: "json",
			processData: false,
			timeout: 3,
			type: "POST",
			url: "/" + env.prefix + "/api/signup.resetpwd/json",
			data: JSON.stringify({
				"prefix": env.prefix,
				"credential": null,
				"loginid": login_id,
				"mail": addr,
			}),
			success: function(data, dataType) {
				if (data && data.status && data.status.code == 0) {
					confirm("メールを送信しました");
					$("#reset_pwd_modal").modal("hide");
				} else {
					confirm("エラーが発生しました。管理者までご連絡ください。\n" + (data && data['status'] && data.status['description'] ? data.status.description : ""));
					$("#reset_pwd_modal").modal("hide");
				}
			},
		});
	}
}

$(document).ready(function(){
	if ($("#login_id").val() === "") {
		$("#login_id").focus();
	} else {
		$("#login_pass").focus();
	}
	$("#reset_pwd_modal").on("show.bs.modal", function (){
		$("#resetpwd_mail").val(null);
	});
});
		</script>
	</head>
	<body>
		<div class="container" style="padding-bottom: 30px;">
			<!-- ヘッダー -->
			<div id="header" class="container" style="height:100px;">
			</div>
			<!-- /ヘッダー -->

			<!-- メインコンテンツ -->
			<div id="main_content_" class="container" style="/*margin-top:50px;margin-bottom:100px;*/margin: auto auto;">
				{% if data['project.countProject']['count'] + data['engineer.countEngineer']['count'] > 0 %}
					{% set newest_date = data['project.countProject']['date'] if data['project.countProject']['date'] > data['engineer.countEngineer']['date'] else data['engineer.countEngineer']['date'] %}
					<div id="new-infor" class="row" style="margin-bottom:15px;">
						<div class="col-lg-offset-1 col-lg-5 col-md-6">
							<marquee id="marquee-new">
								<span class="glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"></span>
								{{newest_date}} 新しい登録情報が掲載されました！
							</marquee>
						</div>
					</div>
				{% endif %}
				<div class="row">
				{% if "iPhone" in env.UA or "Android" in env.UA -%}
				{% else -%}
					<div id="login_screen_shot" class="col-lg-offset-1 col-lg-5 col-md-6" style="margin-bottom: 2em;">
						<img alt="CloudforS スクリーンショット" src="/img/screen_shot.png" style="width: 100%; /*max-width: 400px;*/"/>
					</div>
				{% endif -%}
					<div class="col-lg-4 col-md-4">
						<form id="login_form" action="/{{ env.prefix }}/html/home.enum/" method="POST" onsubmit="hdlClickLoginBtn();" enctype="application/x-www-form-urlencoded">
							<img alt="SESCloud" width="124" height="40" style="margin: 1px 4px;" src="/img/logo.png"/>
							<!-- エラーメッセージの表示 -->
							<div id="err_msg" style="height:50px;">

							</div>
							<ul style="margin-top: 1em; font-size:0.8em; list-style-type: none;">
								<li>
									<label for="#login_id" style="width: 6em;">ログインID</label>
									<input id="login_id" type="text"{% if login_id %} value="{{ login_id }}"{% endif %} placeholder="ID" style="margin:0 0 10px 50px;"></input>
								</li>
								<li>
									<label for="#login_pass" style="width: 6em;">パスワード</label>
									<input id="login_pass" type="password" value="" placeholder="パスワード" style="margin:0 0 10px 50px;"></input><br />
								</li>
								<li style="float: right;">
									<ul style="padding: 0; list-style-type: none; overflow: hidden;">
										<li style="margin: 0 1em; float: left;">
											{{ buttons.reset_pwd("hdlClickResetPwdBtn();") }}
										</li>
										<li style="margin: 0 1em; float: left;">
											{{ buttons.login("hdlClickLoginBtn();") }}
										</li>
									</ul>
								</li>
							</ul>
							<br/>
							<input type="hidden" id="json_param" name="json"/>
						</form>
						<div class="row" style="padding-top: 30px;padding-left: 30px;">
							<span><b>最新情報</b></span>
						</div>
						<div class="row" style="padding-bottom: 30px;padding-left: 30px;">
							<textarea rows="5" style="width: 100%;cursor: default;resize: none;" readonly="readonly">{{ data['manage.information'].content|e }}</textarea>
						</div>
					</div>
				</div>
				<div id="err_msg" style="margin-top: 3em;{% if env.status and env.status.description -%} display: block;{% else -%} display: none;{% endif -%}">
					<p class="text-danger">{% if env.status %}{{ env.status.description }}{% endif %}(ERR_CODE:{% if env.status %}{{ env.status.code }}{% else %}""{% endif %})</p>
				</div>
			</div>
			<!-- /メインコンテンツ -->

			<!-- フッター -->
			<div id="login_footer" class="container" style="width: 100%; height: 30px; border-top: 1px solid #bbbbbb; position: fixed; bottom: 0px; background-color: #ffffff;">
				<img alt="Goodworks" width="230" height="23" src="/img/logo_footer.gif" style="margin-top: 3px;">
			</div>
			<!-- /フッター -->
		</div>
<div id="reset_pwd_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#search_recipient_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="search_recipient_modal_title"></span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<div>
					<p>ご入力いただいたメール アドレスに向けて、パスワード設定用のURLを記載したメールを配信します。<p>
					<ul class="form-group">
						<li class="input-group">
							<label class="input-group-addon bold" for "resetpwd_id">ログインID:</label>
							<input class="form-control" type="text" id="resetpwd_id"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="resetpwd_mail">メール アドレス:</label>
							<input class="form-control" type="text" id="resetpwd_mail"/>
						</li>
					</ul>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">キャンセル</button>
				<button type="button" class="btn btn-primary" id="input_account_btn"
					onclick='sendResetPwdMail();'>パスワードをクリアする</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
{#
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
#}
	</body>
</html>