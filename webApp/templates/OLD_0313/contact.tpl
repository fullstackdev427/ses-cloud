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
						<img alt="設定" width="22" height="20" src="/img/icon/group_person.png"> お問合せ
						<p>以下のタブを選択すると、各種お問合せいただけます。</p>
						<ul class="nav nav-tabs" role="tablist">
							<li class="active"><a href="#ct_usage" role="tab" data-toggle="tab">利用方法質問</a></li>
							<li><a href="#ct_trouble" role="tab" data-toggle="tab">不具合報告</a></li>
							{% if data['auth.userProfile'].user.is_admin == True -%}
							<li><a href="#ct_extend" role="tab" data-toggle="tab">プラン変更</a></li>
							<li><a href="#ct_ojt" tole="tab" data-toggle="tab">提案依頼</a></li>
							<li><a href="#ct_migrate" role="tab" data-toggle="tab">データ移行</a></li>
							{% endif -%}
							<li><a href="#ct_misc" role="tab" data-toggle="tab">その他</a></li>
						</ul>
						<div class="tab-content">
							<div class="tab-pane fade in active" id="ct_usage" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;利用方法質問</h4>
								<p>ご利用方法で不明点がありましたら、下欄にご質問内容を書いて送信してください。営業担当よりご連絡させていただきます。</p>
								<div class="input-group">
									<label class="input-group-addon" for="input_usage_content">ご質問内容</label>
									<textarea id="input_usage_content" class="form-control" style="height: 8em;"></textarea>
								</div>
								<div class="row" style="padding: 1em 1.5em;">
									<input type="button" class="btn btn-primary pull-right" value="送信" onclick="hdlClickInquireBtn('USAGE', $('#input_usage_content').val());"/>
								</div>
							</div><!-- #ct_usage -->
							<div class="tab-pane fade" id="ct_trouble" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;不具合報告</h4>
								<p>不具合にお気付きの点がありましたら、下欄に内容を書いて送信してください。営業担当よりご連絡させていただきます。</p>
								<div class="input-group">
									<label class="input-group-addon" for="input_trouble_content">ご報告内容</label>
									<textarea id="input_trouble_content" class="form-control" style="height: 8em;"></textarea>
								</div>
								<div class="row" style="padding: 1em 1.5em;">
									<input type="button" class="btn btn-primary pull-right" value="送信" onclick="hdlClickInquireBtn('TROUBLE', $('#input_trouble_content').val());"/>
								</div>
							</div><!-- #ct_trouble -->
							<div class="tab-pane fade" id="ct_extend" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;プラン変更</h4>
								<p>ご利用制限やご利用プランに関するお問合せやご要望を下欄に書いて送信してください。営業担当よりご連絡させていただきます。</p>
								<div class="input-group">
									<label class="input-group-addon" for="input_extend_content">ご要望</label>
									<textarea id="input_extend_content" class="form-control" style="height: 8em;"></textarea>
								</div>
								<div class="row" style="padding: 1em 1.5em;">
									<input type="button" class="btn btn-primary pull-right" value="送信" onclick="hdlClickInquireBtn('EXTEND', $('#input_extend_content').val());"/>
								</div>
							</div><!-- #ct_extend -->
							<div class="tab-pane fade" id="ct_ojt" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;提案依頼</h4>
								<p>使い方のデモンストレーションやコンサルテーションなどの営業からの提案をご希望の場合には、下欄にご要望を書いて送信してください。営業担当よりご連絡させていただきます。</p>
								<div class="input-group">
									<label class="input-group-addon" for="input_ojt_content">ご報告内容</label>
									<textarea id="input_ojt_content" class="form-control" style="height: 8em;"></textarea>
								</div>
								<div class="row" style="padding: 1em 1.5em;">
									<input type="button" class="btn btn-primary pull-right" value="送信" onclick="hdlClickInquireBtn('OJT', $('#input_ojt_content').val());"/>
								</div>
							</div><!-- #ct_ojt -->
							<div class="tab-pane fade" id="ct_migrate" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;取り込みデータの指定</h4>
								<p>データ移行テンプレートのExcelファイルを使って、取引先と取引先担当者のデータを一括取り込みできます。</p>
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
							</div><!-- #ct_migrate -->
							<div class="tab-pane fade" id="ct_misc" style="padding: 1em 1.5em;">
								<h4><span class="glyphicon glyphicon-pencil"></span>&nbsp;その他</h4>
								<p>お気付きの点がありましたら、下欄に内容を書いて送信してください。営業担当よりご連絡させていただきます。</p>
								<div class="input-group">
									<label class="input-group-addon" for="input_misc_content">お問合せ内容</label>
									<textarea id="input_misc_content" class="form-control" style="height: 8em;"></textarea>
								</div>
								<div class="row" style="padding: 1em 1.5em;">
									<input type="button" class="btn btn-primary pull-right" value="送信" onclick="hdlClickInquireBtn('MISC', $('#input_misc_content').val());"/>
								</div>
							</div><!-- #ct_trouble -->
						</div><!-- div.tab-content -->
					</div><!-- div.row -->
				</div>
			</div>
			<!-- /メインコンテンツ -->
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script src="/js/contact.js" type="text/javascript"></script>
		<script type="text/javascript">
$(document).ready(function (){
	if (env) {
		env.data = {};
	}
});
		</script>
	</body>
</html>
