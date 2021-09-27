			<!-- フッタ -->
			{% if "iPhone" in env.UA or "Android" in env.UA -%}
			<div class="sp_footer">
				<address class="center_content" style="margin-top: 5px; padding-top: 5px; border-top: solid 1px #999999; text-align: center;">
					<p>Copyright &copy; Goodworks. All Rights Reserved.</p>
				</address>
			</div>
			{% else -%}
			<div class="container">
				<div style="text-align:right;">
					<a href="#header"><span class="glyphicon glyphicon-chevron-up"></span>トップへ戻る</a>
				</div>
				<div style="padding-top:30px;padding-bottom:30px;border-top: 1px solid #BBBBBB; text-align:center; font-size: 10px;">
					Copyright &copy; Goodworks. All Rights Reserved.
				</div>
			</div>
			{% endif -%}
			<!-- /フッタ -->
