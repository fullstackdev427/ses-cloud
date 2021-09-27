{% import "cmn_controls.macro" as buttons -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%} >
{% include "cmn_header.tpl" %}
	<div class="container"><span class="glyphicon glyphicon-facetime-video pseudo-link-cursor" style="font-size: 20px;top: 4px;"></span><label>解説動画一覧</label></div>
	<div class="container" style="margin-top:50px;margin-bottom:100px;">
		<div class="row mb-5">
			<div class="col-lg-3 col-md-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/qKNoDQZSUs8" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画①<br /><br />マッチング検索→メール提案 ver1.3</p>
			</div>
			<div class="col-lg-3 col-sm-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/Pt3A-lmQsC0" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画②<br /><br />稼働新規登録ver1.1</p>
			</div>
			<div class="col-lg-3 col-sm-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/x70SPxrDQv4" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画③<br /><br />稼働見積書作成ver1.3</p>
			</div>
			<div class="col-lg-3 col-sm-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/jKaJ7Uo0MU8" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画④<br /><br />請求書新規作成ver1.1</p>
			</div>
		</div>
		<div style="margin-top: 2em; margin-bottom: 2em;"></div>
		<div class="row mb-5">
			<div class="col-lg-3 col-md-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/hAPPeiPW9Bo" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画⑤<br /><br />請求書新規作成ver1.1</p>
			</div>
			<div class="col-lg-3 col-sm-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/v4O2sybuxuI" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画⑥<br /><br />案件マッチングver1.2</p>
			</div>
			<div class="col-lg-3 col-sm-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/U9xR1rN3_pU" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画⑦<br /><br />要員マッチングver1.0</p>
			</div>
			<div class="col-lg-3 col-sm-3">
				<div class="embed-responsive embed-responsive-16by9">
					<iframe width="100%" src="https://www.youtube.com/embed/u5dYICRzUdk" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
				</div>
				<p class="h5 mb-4 text-center" style="padding: 10px; font-weight: bold;">【完パケ】SESクラウド解説動画⑧<br /><br />帳票設定 ver1.0</p>
			</div>
		</div>
	</div>
<!-- /メインコンテンツ -->
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
	</body>
</html>
