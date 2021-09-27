{% import "cmn_controls.macro" as buttons -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
{% include "cmn_header.tpl" %}
	<div class="container"><span class="glyphicon glyphicon-facetime-video pseudo-link-cursor" style="font-size: 20px;top: 4px;"></span><label>{{data['video']['title']}}</label></div>
	<div class="container" style="margin-top:50px;margin-bottom:100px;">
		<div class="row mb-5">
			<div class="embed-responsive embed-responsive-16by9 text-center">
				<iframe width="560" height="315" src="{{data['video']['url']}}" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
			</div>
		</div>
		<div class="row mb-5 text-center">
			<span class="pull-right" style="width:560px;">
				<a href="#" style="font-weight: bold" onclick="c4s.hdlClickDirectionBtn('home.direction', 'unleave');">解説動画一覧ページへ＞＞</a>
			</span>
		</div>
	</div>
<!-- /メインコンテンツ -->
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
	</body>
</html>
