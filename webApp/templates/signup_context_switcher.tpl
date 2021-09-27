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
{% if data['unique_code'] -%}
		<script type="text/javascript">
var env = {
	prefix: "{{ env['prefix'] }}",
	cookie_cred: document.cookie.replace("cred=", ""),
	recentAjaxResult: null,
	modalStack: [],/* support variable for stacking modals. */
	DEBUG_MODE: {% if env['prod_level'] == "develop" %}true{% else %}false{% endif %},/* If in production level, comment out or set false. */
	TRANS_SPEED_DELETE: 600,
	debugOut: function(obj) {
		if (env.DEBUG_MODE) {
			console.log(obj);
		}
	}, /* debug mode console output. */
	UA: JSON.parse('{{ env['UA']|tojson }}'),
	enumSeparationLimit: 8,
};
$(document).ready(function (){
	c4s.invokeApi_ex({
		location: "{{ data['location'] }}",
		body: JSON.parse('{{ data['parameter']|tojson }}'),
		pageMove: true,
		newPage: false,
	});
});
		</script>
{% endif -%}
	</head>
	<body>
{% if not data['unique_code'] or not data['location']-%}
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