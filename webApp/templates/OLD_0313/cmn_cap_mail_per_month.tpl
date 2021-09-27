<div id="alert_cap_mail_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#alert_cap_mail_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-fire text-danger">&nbsp;</span>メール送信量警告</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<p class="invoice">メールの月間使用量がライセンスされた量を超過しています。</p>
				<div class="progress">
					<div class="progress-bar progress-bar-success" role="progressbar" style="width: 50%;"></div>
					<div class="progress-bar progress-bar-danger" role="progressbar" style="width: 50%;"></div>
				</div>
				<p class="message">メール発信数の制限を解除するには、本サービスの営業担当までご連絡ください。<br/>株式会社グッドワークス Tel.：03-3525-8050</p>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
