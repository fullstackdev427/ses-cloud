<!DOCTYPE html>
<html lang="ja">
	<head>
		<title>{{ title }}</title>
		<link rel="stylesheet" href="/css/bootstrap.min.css" media="screen"/>
		<link href="/css/base.css" rel="stylesheet" media="screen"/>
		{% if "iPhone" in env.UA or "Android" in env.UA -%}
			<link href="/css/base_sp_override.css" rel="stylesheet" media="screen"/>
		{% endif -%}
		<!--[if lt IE 10]>
		<link href="/css/ie9.css" rel="stylesheet" media="screen"/>
		<![endif]-->
		<script src="/js/jquery.1.11.js" type="text/javascript"></script>
		<script src="/js/bootstrap.min.js" type="text/javascript"></script>
		<script src="/js/c4s_common.js" type="text/javascript"></script>
		<script type="text/javascript">
var env = {
	prefix: "{{ env['prefix'] }}",
	cookie_cred: document.cookie.replace("cred=", ""),
	recentAjaxResult: null,
	DEBUG_MODE: {% if env['prod_level'] == "develop" %}true{% else %}false{% endif %},/* If in production level, comment out or set false. */
	TRANS_SPEED_DELETE: 600,
	debugOut: function(obj) {
		if (env.DEBUG_MODE) {
			console.log(obj);
		}
	}, /* debug mode console output. */
	/*UA: JSON.parse('{{ env['UA']|tojson }}'),*/
	enumSeparationLimit: 8,
};
$(document).ready(function (){
	try {
		env.recentQuery = JSON.parse('{{ query|tojson }}');
	} catch (e) {}
	var submitInput = function () {
		c4s.clearValidate({
				name: "#u_name",
				prefer_login_id: "#u_login_id",
				pwd: "#u_pwd",
				pwd_confirm: "#u_pwd_confirm",
				mail1: "#u_mail1",
				tel1: "#u_tel1",
				tel2: "#u_tel2",
				fax: "#u_fax",
			}
		);
		var reqObj = {
			id: env.recentQuery['id'],
			code: env.recentQuery['code'],
			name: $("#u_name").val().trim(),
			prefer_login_id: $("#u_login_id").val().trim(),
			pwd: $("#u_pwd").val().trim(),
			pwd_confirm: $("#u_pwd_confirm").val().trim(),
			mail1: $("#u_mail1").val().trim(),
			tel1: $("#u_tel1").val().trim(),
			tel2: $("#u_tel2").val().trim(),
			fax: $("#u_fax").val().trim(),
			step: "confirm"
		};
		var validLog = c4s.validate(
			reqObj,
			c4s.validateRules.signupUser,
			{
				name: "u_name",
				prefer_login_id: "u_login_id",
				pwd: "u_pwd",
				pwd_confirm: "u_pwd_confirm",
				mail1: "u_mail1",
				tel1: "u_tel1",
				tel2: "u_tel2",
				fax: "u_fax",
			}
		);
		if (validLog.length || reqObj['pwd'] === "" || reqObj['pwd'] !== reqObj['pwd_confirm']) {
			env.debugOut(validLog);
			var validTextArr = c4s.genValidateMessage(validLog, "signupUser");
			$("#validErrorMsgs").empty();
			for (var i = 0; i < validTextArr.length; i++) {
				$("#validErrorMsgs").append($("<li/>").text("パスワードは5文字以上で設定してください"));
				$("#u_pwd").parent().addClass("has-error");
			}
			if (reqObj['pwd'].length <= 5) {
				$("#validErrorMsgs").append($("<li/>").text("パスワードと確認入力が一致しません"));
			}
			if (reqObj['pwd'] !== reqObj['pwd_confirm']) {
				$("#validErrorMsgs").append($("<li/>").text("パスワードと確認入力が一致しません"));
				$("#u_pwd_confirm").parent().addClass("has-error");
			}
			$("#validErrorMsgs").css("display", "block");
			alert("入力を修正してください");
		} else {
			delete reqObj['pwd_confirm'];
			c4s.invokeApi_ex({
				location: "signup.user",
				body: reqObj,
				pageMove: true,
				newPage: false
			});
		}
		return false;
	};
	$("#btnConfirm").on("click", submitInput);
	$("#formConfirm").on("submit", submitInput);
	var submitConfirm = function () {
		var reqObj = {"id": env.recentQuery['id'], "code": env.recentQuery['code'], "step": "thanks"};
		delete reqObj['pwd_confirm'];
		c4s.invokeApi_ex({
			location: "signup.user",
			body: reqObj,
			pageMove: true,
			newPage: false,
		});
		return false;
	};
	var rewindInput = function () {
		var reqObj = {"id": env.recentQuery['id'], "code": env.recentQuery['code'], "step": "input"};
		c4s.invokeApi_ex({
			location: "signup.user",
			body: reqObj,
			pageMove: true,
			newPage: false,
		});
	};
	$("#btnThanks").on("click", submitConfirm);
	$("#btnRewindInput").on("click", rewindInput);
	$("#formThanks").on("submit", submitConfirm);
	$("#u_pwd_confirm").on("keyup", function (){
		if ($("#u_pwd").val() === $("#u_pwd_confirm").val()) {
			$("#u_pwd_confirm").parent().removeClass("has-error");
		} else {
			$("#u_pwd_confirm").parent().addClass("has-error");
		}
	});
});
		</script>
	</head>
	<body>
		<div class="container">
			<div class="row" style="margin: 0.5em auto;">
				<img alt="SESクラウド" width="126" height="41" src="/img/logo.png"/>
			</div>
			<div class="row" style="margin: 0 auto; width: 70%;">
{% if query and query['code'] and "step" in query and query['step'] in ("input", "confirm", "thanks",) -%}
	{% if query['step'] == "input" -%}
				<h3>ユーザー情報:入力</h3>
				<p>以下の項目を入力してください。項目名に<span class="text-danger bold">*</span>の付いた欄は入力必須です。</p>
				<p>確認まで進むと、入力した内容が保存されます。メールでご案内済みのアドレスから登録作業を再開できます。</p>
				<ul id="validErrorMsgs" style="display: none; color: red;"></ul>
				<form id="formConfirm">
					<ul class="form-group">
						<li class="input-group">
							<label class="input-group-addon bold" for="u_name">氏名<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_name"
								value="{{ data['val']['name']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_login_id">ログインID<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_login_id"
								value="{{ data['val']['login_id']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_pwd">パスワード<span class="text-danger">*</span></label>
							<input class="form-control" type="password" id="u_pwd"
								value="{{ data['val']['pwd']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_pwd_confirm">パスワード（確認入力）<span class="text-danger">*</span></label>
							<input class="form-control" type="password" id="u_pwd_confirm"
								value=""/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_mail1">メール アドレス<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_mail1"
								value="{{ data['val']['mail1']|e or data['val']['mail'] or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_tel1">電話番号（メイン）<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_tel1"
								value="{{ data['val']['tel1']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_tel2">電話番号（サブ）</label>
							<input class="form-control" type="text" id="u_tel2"
								value="{% if not data['val']['tel2'] %}{% else %}{{ data['val']['tel2']|e }}{% endif %}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_fax">FAX番号</label>
							<input class="form-control" type="text" id="u_fax"
								value="{% if not data['val']['fax'] %}{% else %}{{ data['val']['fax']|e }}{% endif %}"/>
						</li>
					</ul>
					<div class="row" style="border-top: solid 1px #999; padding: 0.5em 1em; overflow: hidden;">
						<button type="button" class="btn-primary" id="btnConfirm" style="float: right;">確認</button>
					</div>
				</form>
	{% elif query['step'] == "confirm" -%}
				<h3>ユーザー情報:確認</h3>
				<p>以下の項目の入力を確認してください。項目名に<span class="text-danger bold">*</span>の付いた欄は入力必須です。</p>
				<p>確定するか、入力に戻ってください。</p>
				<form id="formThanks">
					<ul class="form-group">
						<li class="input-group">
							<label class="input-group-addon bold" for="u_name">氏名<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_name" disabled="disabled"
								value="{{ data['val']['name']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_login_id">ログインID<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_login_id" disabled="disabled"
								value="{{ data['val']['login_id']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_pwd">パスワード<span class="text-danger">*</span></label>
							<input class="form-control" type="password" id="u_pwd" disabled="disabled"
								value="{{ data['val']['pwd']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_mail1">メール アドレス<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_mail1" disabled="disabled"
								value="{{ data['val']['mail1']|e or data['val']['mail'] or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_tel1">電話番号（メイン）<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="u_tel1" disabled="disabled"
								value="{{ data['val']['tel1']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_tel2">電話番号（サブ）</label>
							<input class="form-control" type="text" id="u_tel2" disabled="disabled"
								value="{% if not data['val']['tel2'] %}{% else %}{{ data['val']['tel2']|e }}{% endif %}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="u_fax">FAX番号</label>
							<input class="form-control" type="text" id="u_fax" disabled="disabled"
								value="{% if not data['val']['fax'] %}{% else %}{{ data['val']['fax']|e }}{% endif %}"/>
						</li>
					</ul>
					<div class="row" style="border-top: solid 1px #999; padding: 0.5em 0;">
						<ul style="float: right; list-style-type: none;">
							<li style="margin: 0 0.5em; float: left;">
								<button type="button" class="btn-primary" id="btnRewindInput" style="float: right;">入力に戻る</button>
							</li>
							<li style="margin: 0 0.5em;float: left;">
								<button type="button" class="btn-primary" id="btnThanks" style="float: right;">確定</button>
							</li>
						</ul>
					</div>
				</form>
	{% elif query['step'] == "thanks" -%}
				<h3>ユーザー情報</h3>
				<p>ご登録ありがとうございます。システムよりメールが送信されますので、メール本文に記載されたアドレスより、ご利用ください。</p>
	{% else -%}
				<p>URLが間違っています。サインアップをご利用いただけません。</p>
	{% endif -%}
{% else -%}
			</div>
		</div>
		<div class="container">
			<div class="row" style="margin: 0.5em auto;">
				<img alt="SESクラウド" width="126" height="41" src="/img/logo.png"/>
			</div>
			<div class="row" style="margin: 20% auto; width: 70%;">
				<p>要求されたURLではサインアップをご利用いただけません。エントリ フォームより再度ご依頼いただき、メール本文に記載されたサインアップ用URLをご利用ください。</p>
			</div>
		</div>
{% endif -%}
		{% if "iPhone" in env.UA or "Android" in env.UA -%}
		<div class="sp_footer">
			<address class="center_content" style="margin-top: 5px; padding-top: 5px; border-top: solid 1px #999999; text-align: center;">
				<p>Copyright &copy; Goodworks. All Rights Reserved.</p>
			</address>
		</div>
		{% else -%}
		<div class="container">
			<div style="padding-top:30px;padding-bottom:30px;border-top: 1px solid #BBBBBB; text-align:center; font-size: 10px;">
				Copyright &copy; Goodworks. All Rights Reserved.
			</div>
		</div>
		{% endif -%}
{% include "cmn_debug_vars.tpl" %}
	</body>
</html>