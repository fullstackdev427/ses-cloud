	<head>
		<script type="text/javascript">
			window.console = window.console || {log: function (obj) {void(0);}};
		</script>
		<title>{{ title }}</title>
		<meta charset="UTF-8"/>
		<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
		<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"/>
		<!--[if lt IE 9]>
		<script src="/js/ltie8array.js" type="text/javascript"></script>
		<![endif]-->
		<script src="/js/jquery.1.11.js" type="text/javascript"></script>
		<script src="/js/bootstrap.min.js" type="text/javascript"></script>
		<script src="/js/bootstrap-datepicker.js" type="text/javascript"></script>
		<!--[if lt IE 9]>
		<script src="/js/html5shiv.js" type="text/javascript"></script>
		<script src="/js/respond.min.js" type="text/javascript"></script>
		<![endif]-->
		<script src="/js/c4s_common.js" type="text/javascript"></script>
		<script src="/js/datepatch.js" type="text/javascript"></script>
		<link rel="shortcur icon" href="/favicon.ico"/>
		<link rel="stylesheet" href="/css/bootstrap.min.css" media="screen"/>
		<link rel="stylesheet" href="/css/datepicker.css"/>
		<link rel="stylesheet" href="/css/jquery-ui.css"/>
		<link href="/css/base.css" rel="stylesheet" media="screen"/>
		{% if "iPhone" in env.UA or "Android" in env.UA -%}
			<link href="/css/base_sp_override.css" rel="stylesheet" media="screen"/>
		{% endif -%}
		<!--[if lt IE 10]>
		<link href="/css/ie9.css" rel="stylesheet" media="screen"/>
		<![endif]-->
		<script type="text/javascript">
var env = {
	current: "{{ current }}",
	prefix: "{{ env['prefix'] }}",
	login_id: "{{ env['login_id'] }}",
	credential: "{{ env['credential'] }}",
	{#
	limit: JSON.parse('{{ env['limit']|tojson }}'),
	#}
	userInfo: JSON.parse('{{ data["auth.userProfile"].user|tojson }}'),
    companyInfo: JSON.parse('{{ data["auth.userProfile"].company|tojson }}'),
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
	records: JSON.parse('{{ data['limit.count_records']|tojson }}'),
};
c4s.invokeApi_ex({
	location: "manage.enumPrefs",
	body: {},
	onSuccess: function (data) {
		env.limit = {};
		var i, tmp;
		for(i=0; i < data.data.length; i++) {
			tmp = data.data[i];
			env.limit[tmp.key] = tmp.final;
		}
		//[begin] Limitation of Mailing capacity per month.
		$(document).ready(function () {
			if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
				$("#alert_cap_mail_modal p.invoice").text("直近1ヶ月間のメール発信数がライセンスされた量を超過しています。");
				$("#alert_cap_mail_modal .progress-bar-success").css("width", env.limit.LMT_LEN_MAIL_PER_MONTH / env.records.LMT_LEN_MAIL_PER_MONTH * 100 + "%");
				$("#alert_cap_mail_modal .progress-bar-danger").css("width", (100 - env.limit.LMT_LEN_MAIL_PER_MONTH / env.records.LMT_LEN_MAIL_PER_MONTH * 100) + "%");
				$("#alert_cap_mail_modal .progress-bar-success").text(env.limit.LMT_LEN_MAIL_PER_MONTH + "通（ライセンス分）");
				$("#alert_cap_mail_modal .progress-bar-danger").text(env.records.LMT_LEN_MAIL_PER_MONTH - env.limit.LMT_LEN_MAIL_PER_MONTH + "通（超過分）");
			} else if (env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
				$("#alert_cap_mail_modal p.invoice").text("直近1ヶ月間のメール発信数は以下の通りです。");
				$("#alert_cap_mail_modal .progress-bar-success").css("width", env.records.LMT_LEN_MAIL_PER_MONTH / env.limit.LMT_LEN_MAIL_PER_MONTH * 100 + "%");
				$("#alert_cap_mail_modal .progress-bar-success").attr("aria-valuenow", env.records.LMT_LEN_MAIL_PER_MONTH);
				$("#alert_cap_mail_modal .progress-bar-success").attr("aria-valuemin", 0);
				$("#alert_cap_mail_modal .progress-bar-success").attr("aria-valuemax", env.limit.LMT_LEN_MAIL_PER_MONTH);
				$("#alert_cap_mail_modal .progress-bar-danger").css("display", "none");
				$("#alert_cap_mail_modal .progress-bar-success").text(env.records.LMT_LEN_MAIL_PER_MONTH + "通（発信数）");
			} else {
				$("#alert_cap_mail_modal p.invoice").text("直近1ヶ月間のメール発信数は以下の通りです。ライセンス利用量は無制限なので問題ありません。");
				$("#alert_cap_mail_modal .progress-bar-success").css("width", "100%");
				$("#alert_cap_mail_modal .progress-bar-success").text(env.records.LMT_LEN_MAIL_PER_MONTH + "通（発信数）");
			}
			if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0 && ["mail.createMail", "mail.createReminder"].indexOf(env.current) > -1) {
				$("#alert_cap_mail_modal").modal("show");
			}
		});
		//[end] Limitation of Mailing capacity per month.
	},
});
try {
	env.recentQuery = JSON.parse('{{ query|tojson }}');
} catch (e) {}
// {{ query|tojson }}
		</script>
	</head>