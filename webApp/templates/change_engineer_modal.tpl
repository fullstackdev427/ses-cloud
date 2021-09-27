<!-- [begin] Modal. -->
<div id="change_engineer_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog" style="width:700px;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#change_engineer_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span>要員検索</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <h4>検索条件</h4>
				<div id="modal_change_container_engineer" style="overflow: hidden;">
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_name" style="color: #666666;">要員名</label>
							<input type="text" id="modal_query_name" value="{{ query.name|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_station" style="color: #666666;">最寄駅</label>
							<input type="text" id="modal_query_station" value="{{ query.station|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_contract" style="color: #666666;">所属</label>
							<select id="modal_query_contract" value="{{ query.contract }}">
								<option value="">すべて</option>
								{% for contract in contracts %}
								<option value="{{ contract}}"{% if contract == query.contract %} selected="selected"{% endif %}>{{ contract }}</option>
								{% endfor %}
							</select>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_client_name" style="color: #666666;">所属企業名</label>
							<input type="text" id="modal_query_client_name" value="{{ query.client_name|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_skill" style="color: #666666;">スキル</label>
							<input type="text" id="modal_query_skill" value="{{ query.skill|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_flg_caution" style="color: #666666;">要注意フラグ</label>
							<input type="checkbox" id="modal_query_flg_caution"{% if query.flg_caution %} checked="checked"{% endif %}/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_flg_registered" style="color: #666666;">共有フラグ</label>
							<input type="checkbox" id="modal_query_flg_registered"{% if query.flg_registered %} checked="checked"{% endif %}/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="modal_query_flg_assignable" style="color: #666666;">アサイン可能フラグ</label>
							<input type="checkbox" id="modal_query_flg_assignable"{% if query.flg_assignable %} checked="checked"{% endif %}/>
						</li>
					</ul>
					<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0; float: left;">
                            <button type="button" class="btn btn-primary" onclick="$('#change_engineer_modal').modal('hide');hdlClickNewEngineerObj('changeOperationEngineer');">新規登録して選択</button>
							<button type="button" class="btn btn-primary" onclick="renderRecipientModal('change_engineer');">検索</button>
						</li>
					</ul>
				</div><!-- 絞り込み条件（技術者） -->
                <input type="hidden" id="modal_target_engineer_column_no" value="">
				<div>
					<h4>検索結果 <span id="row_count_engineer" class="badge"></span></h4>
					<table class="view_table table-bordered table-hover"
						id="modal_change_result_engineer"
						style="">
						<thead>
							<tr>
								<th style="width: 35px;">
									選択
								</th>
								<th>技術者名</th>
								<th>単価</th>
								<th>スキル</th>
								<th>状態</th>
								<th>メールアドレス</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div><!-- 絞り込み結果-->
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<!-- [begin] Modal. -->