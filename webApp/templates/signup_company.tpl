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
				name: "#c_name",
				owner_name: "#c_owner_name",
				tel: "#c_tel",
				fax: "#c_fax",
				addr_vip: "#c_addr_vip",
				addr1: "#c_addr1",
				addr2: "#c_addr2"
			}
		);
		var reqObj = {
			id: env.recentQuery['id'],
			code: env.recentQuery['code'],
			name: $("#c_name").val().trim(),
			owner_name: $("#c_owner_name").val().trim(),
			tel: $("#c_tel").val().trim(),
			fax: $("#c_fax").val().trim(),
			addr_vip: $("#c_addr_vip").val().trim(),
			addr1: $("#c_addr1").val().trim(),
			addr2: $("#c_addr2").val().trim(),
			step: "confirm"
		};
		var validLog = c4s.validate(
			reqObj,
			c4s.validateRules.signupCompany,
			{
				name: "c_name",
				owner_name: "c_owner_name",
				tel: "c_tel",
				fax: "c_fax",
				addr_vip: "c_addr_vip",
				addr1: "c_addr1",
				addr2: "c_addr2"
			}
		);
		if (validLog.length) {
			env.debugOut(validLog);
			var validTextArr = c4s.genValidateMessage(validLog, "signupCompany");
			$("#validErrorMsgs").empty();
			for (var i = 0; i < validTextArr.length; i++) {
				$("#validErrorMsgs").append($("<li/>").text(validTextArr[i]));
			}
			$("#validErrorMsgs").css("display", "block");
			alert("入力を修正してください");
		} else {
			c4s.invokeApi_ex({
				location: "signup.company",
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
		c4s.invokeApi_ex({
			location: "signup.company",
			body: reqObj,
			pageMove: true,
			newPage: false,
		});
		return false;
	};
	var rewindInput = function () {
		var reqObj = {"id": env.recentQuery['id'], "code": env.recentQuery['code'], "step": "input"};
		c4s.invokeApi_ex({
			location: "signup.company",
			body: reqObj,
			pageMove: true,
			newPage: false,
		});
	};
	$("#btnThanks").on("click", submitConfirm);
	$("#btnRewindInput").on("click", rewindInput);
	$("#formThanks").on("submit", submitConfirm);
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
				<h3>会社情報:入力</h3>
				<p>以下の項目を入力してください。項目名に<span class="text-danger bold">*</span>の付いた欄は入力必須です。</p>
				<p>確認まで進むと、入力した内容が保存されます。メールでご案内済みのアドレスから登録作業を再開できます。</p>
				<ul id="validErrorMsgs" style="display: none; color: red;"></ul>
				<form id="formConfirm">
					<ul class="form-group">
						<li class="input-group">
							<label class="input-group-addon bold" for="c_name">企業・団体名&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_name"
								value="{{ data['val']['name']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_owner_name">代表氏名&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_owner_name"
								value="{{ data['val']['owner_name']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_tel">代表電話番号&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_tel"
								value="{{ data['val']['tel']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_fax">代表FAX番号</label>
							<input class="form-control" type="text" id="c_fax"
								value="{{ (data['val']['fax'] or '')|e }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_addr_vip">郵便番号&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_addr_vip"
								value="{{ data['val']['addr_vip']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_addr1">住所&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_addr1"
								value="{{ data['val']['addr1']|e or '' }}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_addr2">住所（ビル名/部屋番号など）</label>
							<input class="form-control" type="text" id="c_addr2"
								value="{{ (data['val']['addr2'] or '')|e }}"/>
						</li>
					</ul>
					<div class="row" style="border-top: solid 1px #999; padding: 0.5em 1em; overflow: hidden;">
						<button type="button" class="btn-primary" id="btnConfirm" style="float: right;">確認</button>
					</div>
				</form>
	{% elif query['step'] == "confirm" -%}
				<h3>会社情報:確認</h3>
				<p>以下の項目の入力を確認してください。項目名に<span class="text-danger bold">*</span>の付いた欄は入力必須です。</p>
				<p>確定するか、入力に戻ってください。</p>
				<form id="formThanks">
					<ul class="form-group">
						<li class="input-group">
							<label class="input-group-addon bold" for="c_name">企業・団体名&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_name" disabled="disabled"
								value="{{ query['name']|e}}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_owner_name">代表氏名&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_owner_name" disabled="disabled"
								value="{{ query['owner_name']|e}}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_tel">代表電話番号&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_tel" disabled="disabled"
								value="{{ query['tel']|e}}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_fax">代表FAX番号</label>
							<input class="form-control" type="text" id="c_fax" disabled="disabled"
								value="{{ query['fax']|e}}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_addr_vip">郵便番号&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_addr_vip" disabled="disabled"
								value="{{ query['addr_vip']|e}}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_addr1">住所&nbsp;<span class="text-danger">*</span></label>
							<input class="form-control" type="text" id="c_addr1" disabled="disabled"
								value="{{ query['addr1']|e}}"/>
						</li>
						<li class="input-group">
							<label class="input-group-addon bold" for="c_addr2">住所（ビル名/部屋番号など）</label>
							<input class="form-control" type="text" id="c_addr2" disabled="disabled"
								value="{{ query['addr2']|e}}"/>
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
				<h3>会社情報</h3>
				<p>ご登録ありがとうございます。システムよりメールが送信されますので、メール本文に記載されたアドレスより、初期ユーザー登録を進めてください。</p>
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