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
		var pwd_ipt = $("#c_pwd").val();
		var pwd_cfm = $("#c_pwd_confirm").val();
		var reqObj = {
			uid: env.recentQuery['val']['uid'],
			pwd: $("#c_pwd").val(),
			code: env.recentQuery['code'],
		};
		var valid = function() {
			return pwd_ipt.length && pwd_ipt === pwd_cfm;
		}();
		if (!valid) {
			alert("入力を修正してください");
		} else {
			c4s.invokeApi_ex({
				location: "signup.setpwd",
				body: reqObj,
				pageMove: false,
				newPage: false,
				onSuccess: function () {
					c4s.invokeApi_ex({
						location: "auth.home",
						body: {},
						pageMove: true,
						newPage: false,
					});
				},
			});
		}
		return false;
	};
	$("#btnConfirm").on("click", submitInput);
	$("#c_pwd_confirm").on("keyup", function (){
		if ($("#c_pwd").val() === $("#c_pwd_confirm").val()) {
			$("#c_pwd_confirm").parent().removeClass("has-error");
		} else {
			$("#c_pwd_confirm").parent().addClass("has-error");
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
				<h3>パスワード:入力</h3>
				<p>上書きするパスワードを入力してください。</p>
				<form id="formConfirm">
					<ul class="form-group">
						<li class="input-group">
							<label class="input-group-addon bold" for="c_pwd">パスワード&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="password" id="c_pwd" value=""/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_pwd_confirm">パスワード（確認）&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="password" id="c_pwd_confirm" value=""/>
						</li>
					</ul>
					<div class="row" style="border-top: solid 1px #999; padding: 0.5em 1em; overflow: hidden;">
						<button type="button" class="btn-primary" id="btnConfirm" style="float: right;">確認</button>
					</div>
				</form>
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