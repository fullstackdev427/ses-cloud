{% import "cmn_controls.macro" as buttons -%}
{% if env.status -%}
	{% set flg_show_form = env.status.code in (3, 4, 7, 9) -%}
{% else -%}
	{% set flg_show_form = None -%}
{% endif -%}
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
	status: JSON.parse('{{ env['status']|tojson }}'),
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
$(document).ready(function(){
	{#
	var tmpSegment = location.pathname.split("/");
	if (location.host == "dev1.inter-plug.co.jp" && tmpSegment.length > 0 && tmpSegment[0] != "mng") {
		location.href = "http://pool.cloudfor-s.com" + location.pathname;
	}
	#}
	if ($("#login_id").val() === "") {
		$("#login_id").focus();
	} else {
		$("#login_pass").focus();
	}
});
		</script>
	</head>
	<body>
		<div class="container" {% if "iPhone" in env.UA or "Android" in env.UA -%}{% else -%}style="width:1100px;"{% endif -%}>
			<!-- ヘッダー -->
			<div id="header" class="container" style="height:100px;">

			</div>
			<!-- /ヘッダー -->

			<!-- メインコンテンツ -->
			<div id="main_content_" class="container" style="margin-top:50px;margin-bottom:100px;">
				<div class="row">
					<div class="col-lg-5">
						<form id="login_form" action="/{{ env.prefix }}/html/home.enum/" method="POST" onsubmit="hdlClickLoginBtn();" enctype="application/x-www-form-urlencoded">
							<img alt="CloudforSi" width="124" height="40" style="margin: 1px 4px;" src="/img/logo.png"/>
							<!-- エラーメッセージの表示 -->
							{% if flg_show_form -%}
							<div style="margin-top: 1em; font-size:0.8em;">
								<label for="login_id">ログインID</label>
								<input id="login_id" type="text"{% if login_id %} value="{{ login_id }}"{% endif %} placeholder="ID" style="margin:0 0 10px 50px;"></input>
								<br />
								<label for="login_pass">パスワード</label>
								<input id="login_pass" type="password" value="" placeholder="パスワード" style="margin:0 0 10px 50px;"></input><br />
								{{ buttons.login("hdlClickLoginBtn();") }}
								<input type="hidden" id="json_param" name="json"/>
							</div>
							{% else -%}
							{% endif -%}
							<div id="err_msg" style="margin-top: 3em;">
								<p class="text-danger">{% if env.status %}{{ env.status.description }}{% endif %}{% if env.prefix -%}<a href="/{{ env.prefix }}/html/">ログイン ページ</a>に移動する{% endif -%}(ERR_CODE:{% if env.status %}{{ env.status.code }}{% else %}""{% endif %})</p>
							</div>
						</form>
					</div>
				</div>
			</div>
			<!-- /メインコンテンツ -->

			<!-- フッター -->
			<div id="login_footer" class="container" style="border-top: 1px solid #BBBBBB">
				<img alt="Goodworks" width="230" height="23" src="/img/logo_footer.gif">
			</div>
			<!-- /フッター -->
		</div>
{% include "cmn_debug_vars.tpl" %}
{#
{% include "cmn_footer.tpl" %}
#}
	</body>
</html>