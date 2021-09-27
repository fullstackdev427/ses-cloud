<div id="edit_operation_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
                        {% if current == "operation.top" %}
                            <button type="button" class="btn btn-sm btn-primary"
                                onclick="triggerCommitOperationObject($('#m_operation_id').val() ? true : false);">保存</button>
                        {% else %}
                            <button type="button" class="btn btn-sm btn-primary"
                                onclick="pushOperationObjectList(true);">保存してさらに追加</button>
                            <button type="button" class="btn btn-sm btn-primary"
                                onclick="pushOperationObjectList(false);">追加して帳票作成</button>
                        {% endif %}
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_operation_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_operation_modal_title">新規稼働登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_operation_id"/>
				<span class="text-danger">必須入力項目（＊）</span>

                <div class="input-group">
                    <span class="input-group-addon" style="min-width: 100px;">取引先<span class="text-danger">*</span></span>
                    <select class="form-control" id="m_operation_project_client_id" style="width: 100%;" data-placeholder="取引先を選択して下さい。" onChange="$('#m_operation_project').val('');">
                    {% for item in data['client.enumClients'] %}
                        <option value="{{ item.id }}" >{{ item.name|e }}</option>
                    {% endfor %}
                    </select>
                </div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">案件<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_operation_project_name" placeholder="案件名を入力して下さい。" onChange="$('#m_operation_project').val('');">
					<span class="input-group-btn">
	                    <button type="button" class="btn btn-primary" onclick="selectProjectForNew();">案件選択</button>
	                </span>
				</div>
                <input type="hidden" id="m_operation_project"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">要員<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_operation_engineer_name" placeholder="要員名を入力して下さい。" onChange="$('#m_operation_engineer').val('');">
					<span class="input-group-addon" style="min-width: 50px;">所属<span class="text-danger">*</span></span>
					<select class="form-control" id="m_operation_update_engineer_contract" onchange="changeCalcFormArea(this.value);">
					{% for contract in contracts %}
					    <option value="{{ contract}}">{{ contract }}</option>
					{% endfor %}
                    </select>
					<span class="input-group-btn">
	                    <button type="button" class="btn btn-primary" onclick="selectEngineerForNew();">要員選択</button>
	                </span>
				</div>
                <input type="hidden" id="m_operation_engineer"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">所属先 <span class="text-danger">*</span></span>
                    <select class="form-control" id="m_operation_update_engineer_client_id" style="width: 100%" data-placeholder="所属取引先を選択して下さい。" onChange="$('#m_operation_engineer').val('');">
                    {% for item in data['client.enumClients'] %}
                        <option value="{{ item.id }}" >{{ item.name|e }}</option>
                    {% endfor %}
                    </select>
				</div>
                <div class="input-group container" style="width: 100%; padding-top: 5px;padding-left:0;padding-right:0;">

                    <div class="col-sm-4" style="padding-left:0;padding-right:0;">
                        <table class="table view_table table-bordered ">
                            <tr>
                                <th style="">請求単価</th>
                            </tr>
                            <tr>
                                <td style="white-space: nowrap; padding: 4px;">
                                    <span class="tooltip-parent" id="calc_base_exc_tax_form_area_0">
                                        <input type="text" class="" id="base_exc_tax_0" style="width: 75px; text-align: right;" onclick="openCalcBaseForm(0)"  onchange="updateCalcOperationResult(0);" maxlength="10"/>
                                        (<input type="text" style="width: 70px; text-align: right;border-style: none;" readonly id="base_inc_tax_0" value="" >)
                                        <span class="tooltip-forms1" id="calc_base_exc_tax_form_0">
                                            <span style="font-size: small">時給　　　　　想定稼働時間</span>
                                            <br>
                                            <input type="text" id="demand_wage_per_hour_0" style="width: 75px; text-align: right;" value="" onchange="setBaseExcTax(0);">
                                            &times;
                                            <input type="number" id="demand_working_time_0" style="width: 75px; text-align: right;" value="" onchange="setBaseExcTax(0);">
                                            <br>
                                            <span style="font-size: 10px">時給と想定稼動時間を入力してください。</span>
                                        </span>
                                    </span><br>
                                    <select id="demand_unit_0"  style="" onchange="changeDemandUnitForModal(this,0);">
                                        <option value="1" >月額</option>
                                        <option value="2" >時給</option>
                                    </select>
                                    <span class="tooltip-parent" id="calc_demand_term_form_area_0">
                                        <a class="btn btn-sm btn-primary" style="font-size: xx-small;width:50px;height:20px;padding:0px;margin:0px;" onclick="openCalcDemandTermForm(0)">精算条件</a>
                                        <span id="settlement_mini_view_0" style="font-size: x-small;"></span>
                                        <br>
                                        <span id="demand_memo_area_0" style="font-size: x-small;"></span>
                                        <span class="tooltip-forms1" id="calc_demand_term_form_0">
                                            <span style="font-size: small">　　　　精算時間　　　　　　　　　　精算単価</span>
                                            <br>
                                            <input type="number" id="settlement_from_0" style="width: 60px" value="" onchange="updateDemandExcessAndDeduction(0);updatePaymentExcessAndDeduction(0);">
                                            〜
                                            <input type="number" id="settlement_to_0" style="width: 60px" value="" onchange="updateDemandExcessAndDeduction(0);updatePaymentExcessAndDeduction(0);">
                                            <span>　　</span>
                                            <input type="text" id="deduction_0" style="width: 70px; text-align: right;" value="" onchange="updateCalcOperationResult(0)">
                                            〜
                                            <input type="text" id="excess_0" style="width: 70px; text-align: right;" value="" onchange="updateCalcOperationResult(0)">
                                            <span>　　</span>
                                            <select id="settlement_unit_0" onchange="updateDemandExcessAndDeduction(0)">
                                                <option value="1" >1時間</option>
                                                <option value="2" >30分</option>
                                                <option value="3" >15分</option>
                                            </select>
                                            <br>
                                            <span style="font-size: small">下限時間　　　上限時間　　　　控除単価　　　超過単価　　　精算単位</span>
                                            <br>
                                            <span style="font-size: small">精算備考 <input type="text" id="demand_memo_0" class="autocomplete_demand_memo" style="width: 400px" value="" placeholder="例：固定、8×稼働日-8×稼働日+20h"></span>
                                        </span>
                                    </span>
                                    <script type="text/javascript">
                                    $(document).on('click touchend', function(event) {
                                      if (!$(event.target).closest("#calc_base_exc_tax_form_0").length && !$(event.target).closest("#calc_base_exc_tax_form_area_0").length) {
                                        $("#calc_base_exc_tax_form_0").hide();
                                      }
                                      if (!$(event.target).closest("#calc_demand_term_form_0").length && !$(event.target).closest("#calc_demand_term_form_area_0").length) {
                                        $("#calc_demand_term_form_0").hide();
                                        viewDemandMemoArea(0);
                                      }
                                    });
                                </script>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-sm-4" style="padding-left:0;padding-right:0;">
                        <table class="table view_table table-bordered ">
                            <tr>
                                <th style="">支払単価</th>
                            </tr>
                            <tr>
                                <td style="white-space: nowrap; padding: 4px;">
                                    <span class="tooltip-parent" id="calc_payment_base_exc_tax_form_area_0">
                                        <input type="text" id="payment_base_0" style="width: 75px; text-align: right;" value="" onclick="openCalcPaymentBaseForm(0)" onchange="updateCalcOperationResult(0)">
                                        (<input type="text" style="width: 70px; text-align: right;" id="payment_inc_tax_0" value="" onchange="onchangePaymentIncTax(0)">)
                                        <span class="tooltip-forms2" id="calc_payment_base_exc_tax_form_0">
                                            <span style="font-size: small">時給　　　　　想定稼働時間</span>
                                            <br>
                                            <input type="text" id="payment_wage_per_hour_0" style="width: 75px; text-align: right;" value="" onchange="setPaymentBaseExcTax(0);">
                                            &times;
                                            <input type="number" id="payment_working_time_0" style="width: 75px; text-align: right;" value="" onchange="setPaymentBaseExcTax(0);">
                                            <br>
                                            <span style="font-size: 10px">時給と想定稼動時間を入力してください。</span>
                                        </span>
                                    </span><br>
                                    <select id="payment_unit_0" style="" onchange="changePaymentUnit(this,0);">
                                            <option value="1" >月額</option>
                                            <option value="2" >時給</option>
                                    </select>

                                    <span class="tooltip-parent" id="calc_payment_term_form_area_0">
                                        <a class="btn btn-sm btn-primary" style="font-size: xx-small;width:50px;height:20px;padding:0px;margin:0px;" onclick="openCalcPaymentTermForm(0)">精算条件</a>
                                        <span id="payment_settlement_mini_view_0" style="font-size: x-small;"></span>
                                        <br>
                                        <span id="payment_memo_area_0" style="font-size: x-small;"></span>
                                        <span class="tooltip-forms1" id="calc_payment_term_form_0">
                                            <span style="font-size: small">　　　　精算時間　　　　　　　　　　精算単価</span>
                                            <br>
                                            <input type="number" id="payment_settlement_from_0" style="width: 60px" value="" onchange="updateDemandExcessAndDeduction(0);updatePaymentExcessAndDeduction(0);">
                                            〜
                                            <input type="number" id="payment_settlement_to_0" style="width: 60px" value="" onchange="updateDemandExcessAndDeduction(0);updatePaymentExcessAndDeduction(0);">
                                            <span>　　</span>
                                            <input type="text" id="payment_deduction_0" style="width: 70px; text-align: right;" value="" onchange="updateCalcOperationResult(0)">
                                            〜
                                            <input type="text" id="payment_excess_0" style="width: 70px; text-align: right;" value="" onchange="updateCalcOperationResult(0)">
                                            <span>　　</span>
                                            <select id="payment_settlement_unit_0" onchange="updateDemandExcessAndDeduction(0)">
                                                    <option value="1" >1時間</option>
                                                    <option value="2" >30分</option>
                                                    <option value="3" >15分</option>
                                            </select>
                                            <br>
                                            <span style="font-size: small">下限時間　　　上限時間　　　　控除単価　　　超過単価　　　精算単位</span>
                                            <br>
                                            <span style="font-size: small">精算備考 <input type="text" id="payment_memo_0" class="autocomplete_demand_memo" style="width: 400px" value="" placeholder="例：固定、8×稼働日-8×稼働日+20h"></span>
                                        </span>
                                    </span>
                                    <span class="tooltip-parent hidden" id="calc_allowance_form_area_0">
                                        <a class="btn btn-sm btn-primary" style="font-size: xx-small;width:50px;height:20px;padding:0px;margin:0px;" onclick="openCalcAllowanceForm(0)">手当条件</a>
                                        <span class="tooltip-forms1" id="calc_allowance_form_0">
                                            <span style="font-size: small">　　　　　　　　　　手当入力</span>
                                            <br>
                                            <span>　</span>
                                            <input type="text" id="welfare_fee_0" style="width: 70px; text-align: right;" value="" onchange="updateCalcOperationResult(0)">
                                            <span>　　</span>
                                            <input type="text" id="transportation_fee_0" style="width: 70px; text-align: right;" value="" onchange="updateCalcOperationResult(0)">
                                            <span>　　</span>
                                            <input type="text" id="bonuses_division_0" style="width: 70px; text-align: right;" value="" onchange="updateCalcOperationResult(0)">
                                            <br>
                                            <span style="font-size: small">会社負担保険料　　　月額交通費　　　賞与分割　　</span>
                                            <span style="" class="allowanceHelp popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                                  data-toggle="popover"
                                                  data-placement="right"
                                                  data-html="true"
                                                  data-content=""
                                                  data-container="body"
                                                  onmouseover="$(this).popover('show');"
                                                  onmouseout="$(this).popover('hide');"></span>
                                        </span>
                                    </span>

                                    <script type="text/javascript">
                                        $(document).on('click touchend', function(event) {
                                          if (!$(event.target).closest("#calc_payment_base_exc_tax_form_0").length && !$(event.target).closest("#calc_payment_base_exc_tax_form_area_0").length) {
                                            $("#calc_payment_base_exc_tax_form_0").hide();
                                          }

                                          if (!$(event.target).closest("#calc_payment_term_form_0").length && !$(event.target).closest("#calc_payment_term_form_area_0").length) {
                                            $("#calc_payment_term_form_0").hide();
                                            viewPaymentMemoArea(0);
                                          }
                                          if (!$(event.target).closest("#calc_allowance_form_0").length && !$(event.target).closest("#calc_allowance_form_area_0").length) {
                                            $("#calc_allowance_form_0").hide();
                                          }
                                        });
                                    </script>
                                </td>
                            </tr>
                        </table>
                    </div>
                    <div class="col-sm-4" style="padding-left:0;padding-right:0;">
                        <table class="table view_table table-bordered ">
                            <tr>
                            <th style="">粗利（粗利率）</th>
                            </tr>
                            <tr>
                            <td style="">
                                <input type="text" style="width: 70px; text-align: right;border-style: none;" id="gross_profit_0" value="" >
                                (<span style="width: 40px; text-align: center; padding-right: 2px" id="gross_profit_rate_0_label"></span>)
                                <input type="hidden" id="gross_profit_rate_0" value="" >
                            </td>
                            </tr>
                        </table>
                    </div>
                </div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="min-width: 100px;">期間</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden; padding: 0px 0px;">
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_operation_container">
								<label for="m_operation_term_begin"></label>
								<input type="text" class="" id="m_operation_term_begin" style="width: 150px;" data-date-format="yyyy/mm/dd" maxlength="10" placeholder="2018/02/01"/>
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_operation_container">
								<label for="m_operation_term_end">〜</label>
								<input type="text" class="" id="m_operation_term_end" style="width: 150px;" data-date-format="yyyy/mm/dd" maxlength="10" placeholder="2018/03/31"/>
							</span>
						</li>
                        <li style="margin: 0.2em 0.5em; float: left;">
                            <span id="m_operation_container">
								<label for="m_operation_term_memo">備考:</label>
								<input type="text" class="" style="width: 300px;" id="m_operation_term_memo" maxlength="64" placeholder="スポット契約/3月末で契約終了"/>
							</span>
                        </li>
					</ul>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="min-width: 100px;">スキル</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;"  onclick="editOperationSkillCondition();">
						<li style="margin: 0.2em 0.5em; float: left;">
							<div id="m_operation_skill_container" style="word-break: break-word;">
								<label for="m_operation_skill"></label>
							</div>
						</li>
					</ul>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="width: 100px;">人材担当</span>
					<select class="form-control" id="m_operation_engineer_charging_user_id">
                        {% for item in data['manage.enumAccounts'] %}
                            {% if item.is_enabled == True %}
                                <option value="{{ item.id }}">{{ item.name|e }}</option>
                            {% endif %}
                        {% endfor %}
                    </select>
                    <span class="input-group-addon" style="width: 100px;">案件担当</span>
					<select class="form-control" style="" id="m_operation_project_charging_user_id">
                        {% for item in data['manage.enumAccounts'] %}
                            {% if item.is_enabled == True %}
                                <option value="{{ item.id }}">{{ item.name|e }}</option>
                            {% endif %}
                        {% endfor %}
                    </select>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="min-width: 100px;">終了確定</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;padding: 0px 0px;">
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_operation_container">
								<input type="checkbox" class="" id="m_operation_is_fixed"/>
                                <label for="m_operation_is_fixed">今月の終了確定者にチェックを入れて下さい。</label>
							</span>
						</li>
					</ul>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="min-width: 100px;">稼働/非稼働</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;padding: 0px 0px;">
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_operation_container">
								<input type="checkbox" class="" id="m_operation_is_active"/>
                                <label for="m_operation_is_active">チェック状態の場合、稼働一覧に表示されます。</label>
							</span>
						</li>
					</ul>
				</div>
                <div class="input-group hidden" style="width: 100%;">
					<span class="input-group-addon" style="width: 100px;">引継</span>
					<input type="text" class="form-control" id="m_operation_transfer_member" maxlength="32"/>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="width: 100px;">契約日</span>
					<input type="text" class="form-control" id="m_operation_contract_date" data-date-format="yyyy/mm/dd" maxlength="10"/>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="width: 100px;">請求サイト</span>
					<input type="text" class="form-control autocomplete_site" id="m_operation_demand_site" maxlength="64"placeholder="月末締翌月末支払"/>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="width: 100px;">支払サイト</span>
					<input type="text" class="form-control autocomplete_site" id="m_operation_payment_site" maxlength="64"placeholder="月末締翌々15日支払"/>
				</div>
                <div class="input-group" style="width: 100%;">
					<span class="input-group-addon" style="width: 100px;font-size: x-small;">請求・支払の<br>留意事項</span>
					<input type="text" class="form-control" id="m_operation_other_memo" placeholder="超過金額は0.7掛け"/>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			    {% if current == "operation.top" %}
                    <button type="button" class="btn btn-sm btn-primary"
                        onclick="triggerCommitOperationObject($('#m_operation_id').val() ? true : false);">保存</button>
                {% else %}
                    <button type="button" class="btn btn-sm btn-primary"
                        onclick="pushOperationObjectList();">保存してさらに追加</button>
                    <button type="button" class="btn btn-sm btn-primary"
                        onclick="pushOperationObjectList();">追加して帳票作成</button>
                {% endif %}
                </div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<!-- [begin] Modal. -->
<div id="search_engineer_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog" style="width:700px;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#search_engineer_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span>要員検索</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <h4>検索条件</h4>
				<div id="modal_search_container_engineer" style="overflow: hidden;">
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
                            <button type="button" class="btn btn-primary" onclick="$('#search_engineer_modal').modal('hide');hdlClickNewEngineerObj();">新規登録して選択</button>
							<button type="button" class="btn btn-primary" onclick="renderRecipientModal('engineer');">検索</button>
						</li>
					</ul>
				</div><!-- 絞り込み条件（技術者） -->
                <input type="hidden" id="modal_target_engineer_column_no" value="">
				<div>
					<h4>検索結果 <span id="row_count_engineer" class="badge"></span></h4>
					<table class="view_table table-bordered table-hover"
						id="modal_search_result_engineer"
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
<div id="search_project_modal" class="modal fade" role="dialog" aria-hidden="true">
	<div class="modal-dialog" style="width:700px;">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#search_project_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span>案件検索</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <h4>検索条件</h4>
				<div id="modal_search_container_engineer" style="overflow: hidden;">
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
                        <li style="margin: 1px 2em; float: left;">
                            <label for="modal_query_client_name" style="color: #666666; width: 5em;">取引先名</label>
                            <input type="text" id="modal_query_client_name" value="{{ query.client_name|e }}"/>
                            <input type="hidden" id="modal_query_client_id"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="modal_query_title" style="color: #666666; width: 5em;">案件内容</label>
                            <input type="text" id="modal_query_title" value="{{ query.title|e }}"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="modal_query_title" style="color: #666666; width: 5em;">請求単価</label>
                            <input type="number" id="modal_query_fee_inbound" value="{{ query.fee_inbound|e }}"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="modal_query_term" style="color: #666666; width: 5em;">期間</label>
                            <input type="text" id="modal_query_term" value="{{ query.term|e }}" data-date-format="yyyy/mm/dd"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="modal_query_interview" style="color: #666666; width: 5em;">面談回数</label>
                            <input type="number" id="modal_query_interview" value="{{ query.interview|e }}"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="modal_query_scheme" style="color: #666666; width: 5em;">商流</label>
                            <select id="modal_query_scheme">
                            {% for schemeLabel, schemeValue in schemes %}
                                <option value="{{ schemeValue }}"{% if schemeValue == query.scheme %} selected="selected"{% endif %}>{{ schemeLabel }}</option>
                            {% endfor %}
                            </select>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="modal_query_flg_shared" style="color: #666666; width: 5em;">状態</label>
                            <select id="modal_query_flg_shared">
                            {% for shareLabel, shareValue in shares %}
                                <option value="{{ shareValue }}"{% if shareValue == query.flg_shared %} selected="selected"{% endif %}>{{ shareLabel }}</option>
                            {% endfor %}
                            </select>
                        </li>
                    </ul>
					<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0 0.5em; float: left;">
                            <button type="button" class="btn btn-primary" onclick="$('#search_project_modal').modal('hide');hdlClickNewProjectObj();">新規登録して選択</button>
							<button type="button" class="btn btn-primary"
								onclick="renderRecipientModal('project');">検索</button>
						</li>
					</ul>
                <input type="hidden" id="modal_target_project_column_no" value="">
				</div><!-- 絞り込み条件（技術者） -->
				<div>
					<h4>検索結果 <span id="row_count_project" class="badge"></span></h4>
					<table class="view_table table-bordered table-hover"
						id="modal_search_result_project"
						style="">
						<thead>
							<tr>
								<th style="width: 35px;">
									選択
								</th>
								<th>取引先名</th>
								<th>案件名</th>
								<th>営業担当</th>
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
<div id="edit_engineer_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="($('#m_engineer_id').val() ? triggerUpdateEngineerObj : commitNewEngineerObj)();">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_engineer_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_engineer_modal_title">新規要員登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_engineer_id"/>
                <input type="hidden" id="commitNewEngineerObjMode" value="NormalCreate"/>
				<span class="text-danger">必須入力項目（＊）</span>
                <ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon" style="min-width: 100px;">要員名<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_name" placeholder="要員名を入力してください。"/>
					</li>
					<li class="input-group" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">要員名（カナ）<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_kana" placeholder="カナを入力してください。" />
					</li>
				</ul>
				<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">要員名<br>（短縮表示名）<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_visible_name" placeholder="ST"/>
					</li>
                    <li class="input-group " style="width: 50%; margin: 0; padding: 0; float: left;">
                        <span class="input-group-addon"style="min-width: 100px;">所属</span>
						<select class="form-control" id="m_engineer_contract">
							{% for contract in contracts %}
							<option value="{{ contract}}">{{ contract }}</option>
							{% endfor %}
						</select>
					</li>
					<li class="input-group hidden" style="width: 50%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">電話番号</span>
						<input type="text" class="form-control" id="m_engineer_tel"/>
					</li>
				</ul>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">所属先 <span class="text-danger">*</span></span>
                    <select class="form-control" style="width: 100%;" id="m_engineer_client_id" data-placeholder="取引先を選択して下さい。">
                        {% for item in data['client.enumClients'] %}
                            <option value="{{ item.id }}" >{{ item.name|e }}</option>
                        {% endfor %}
                    </select>
                    <span class="input-group-btn">
                        <button type="button" class="btn btn-primary" onclick="showAddNewClientModal('engineer');">新規取引先追加</button>
                    </span>
				</div>
                <input type="hidden" id="m_engineer_client_name"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">スキル</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;"  onclick="editEngineerSkillCondition();">
						<li style="margin: 0.2em 0.5em; float: left;">
							<div id="m_engineer_skill_container" style="word-break: break-word;">
								<label for="m_engineer_skill"></label>
							</div>
						</li>
					</ul>
				</div>
{#				<div class="input-group">#}
{#					<span class="input-group-addon" style="min-width: 100px;">スキルメモ</span>#}
{#					<textarea class="form-control" id="m_engineer_skill" style="height: 5em;"></textarea>#}
{#				</div>#}
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">職種</span>
                    <div id="m_engineer_occupation_container" class="container-fluid form-control" style="list-style-type: none; overflow: hidden;">
                        <div class="row">
                            {% set occupation_view_count = (data['occupation.enumOccupations']|length) / 2 %}
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index <= occupation_view_count %}
                                     <input type="checkbox" name="m_engineer_occupation[]" id="engineer_occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="engineer_occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index > occupation_view_count  %}
                                     <input type="checkbox" name="m_engineer_occupation[]" id="engineer_occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="engineer_occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                        </div>
                    </div>
				</div>
				<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 60%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon" style="min-width: 100px;">誕生日</span>
						<input class="form-control" id="m_engineer_birth" readOnly="readOnly" type="text"
							data-date-format="yyyy/mm/dd" placeholder="1990/02/01"/>
						<span class="input-group-addon pseudo-link-cursor" onclick="$('#m_engineer_birth').val(null);">クリア</span>
					</li>
					<li class="input-group" style="width: 40%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">年齢</span>
						<input type="number" class="form-control" id="m_engineer_age" style="text-align: center;" min="0" max="99" pattern="\d+" placeholder="28"/>
						<span class="input-group-addon">歳</span>
					</li>
				</ul>
				<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 40%; margin: 0; padding: 0; float: left;">

					</li>
				</ul>
                <ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
                    <li class="input-group" style="width: 40%; margin: 0; padding: 0;float: left;" id="m_engineer_gender_container">
                        <span class="input-group-addon" style="min-width: 100px">性別</span>
                        <span class="form-control" style="font-size: x-small;padding: 0px 5px;">
                            <input type="radio" name="m_engineer_gender_grp" id="m_engineer_gender_01" checked="checked" value="男"/>
                            <label for="m_engineer_gender_01">男性</label>
                            <input type="radio" name="m_engineer_gender_grp" id="m_engineer_gender_02" value="女"/>
                            <label for="m_engineer_gender_02">女性</label>
                        </span>
                    </li>
					<li class="input-group" style="width: 30%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">単価<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_fee" placeholder="600,000" onChange="addComma(this);"/>
					</li>
					<li class="input-group" style="width: 30%; margin: 0; padding: 0; float: left;">
						<span class="input-group-addon">最寄駅</span>
						<input type="text" class="form-control" id="m_engineer_station" placeholder="秋葉原"/>
                        <input type="hidden" id="m_engineer_station_cd" value="">
                        <input type="hidden" id="m_engineer_station_pref_cd" value="">
                        <input type="hidden" id="m_engineer_station_line_cd" value="">
                        <input type="hidden" id="m_engineer_station_lon" value="">
                        <input type="hidden" id="m_engineer_station_lat" value="">
					</li>
				</ul>
                <div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;">稼働開始日</span>
                    <input type="text" class="form-control" id="m_engineer_operation_begin" data-date-format="yyyy/mm/dd" placeholder="2018/02/01"/>
				</div>
                <ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
					<li class="input-group" style="width: 100%; float: left;">
						<span class="input-group-addon" style="min-width: 100px;">担当営業</span>
						<div class="form-control">
							<select class="" style="width: 150px; margin-right: 20px;" id="m_engineer_charging_user_id">
								<option></option>
							{% for item in data['manage.enumAccounts'] %}
								{% if item.is_enabled == True %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
								{% endif %}
							{% endfor %}
							</select>
                            <input type="checkbox" name="m_engineer_flg_careful" id="m_engineer_flg_careful">
                            <span>要注意フラグ</span>
						</div>
					</li>
					<li class="input-group hidden" style="width: 55%; margin: 0; padding: 0; float: left;">
						<div class="input-group">
							<span class="input-group-addon">稼働</span>
							<input type="text" class="form-control" id="m_engineer_state_work" placeholder="稼動時期を入力ください。例：4月～"/>
						</div>
					</li>
				</ul>
				<div class="input-group hidden">
					<span class="input-group-addon">要注意フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_caution"/>
						<label for="m_engineer_flg_caution" class="text-danger">要注意のエンジニアにチェックしてください</label>
					</span>
				</div>
				<div class="input-group hidden">
					<span class="input-group-addon">共有フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_registered"/>
						<label for="m_engineer_flg_registered" class="text-danger">チェック状態の場合、他のメンバーへ共有されます</label>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;font-size: x-small;">メールアドレス</span>
					<input type="text" class="form-control" id="m_engineer_mail1" placeholder="xxxx@co.jp"/>
				</div>
				<div class="input-group" style="display: none;">
					<span class="input-group-addon">メールアドレス（サブ）</span>
					<input type="text" class="form-control" id="m_engineer_mail2"/>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">郵便番号</span>
					<input type="text" class="form-control" id="m_engineer_addr_vip" placeholder="nnn-nnnn" style="width: 8em;" maxlength="8"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#m_engineer_addr_vip').val(), '#m_engineer_addr1', '#m_engineer_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>

					<span class="text-danger" id="m_engineer_addr1_alert"></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">住所</span>
					<input type="text" class="form-control" id="m_engineer_addr1"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">ビル名</span>
					<input type="text" class="form-control" id="m_engineer_addr2"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;font-size: smaller;">アサイン可能<br>フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_assignable"/>
						<label for="m_engineer_flg_assignable" class="text-danger">要員がアサイン可能であればチェックしてください</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとホームの要員管理一覧に情報が表示されます。<br/>チームで情報共有を行うことが出来ます。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">他社公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_flg_public"/>
						<label for="m_engineer_flg_public" class="text-danger" style="display: inline">チェック状態の場合、本CRMを利用する他社のユーザへ共有されます</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとSESクラウド利用企業様に要員情報が公開されます。<br/>多くの企業様にシェアされるので見合う案件情報獲得に繋がります。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;font-size: x-small;">Web公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_project_web_public"/>
						<label for="m_project_web_public" class="text-danger" style="display: inline"></label>
					</span>
				</div>
				<div class="input-group hidden">
					<span class="input-group-addon">所属備考</span>
					<input type="text" class="form-control" id="m_engineer_employer" placeholder="所属先の情報を入力ください。例：ABC株式会社"/>
				</div>
                <div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;">経歴書</span>
					<span class="form-control">
						<input type="hidden" id="attachment_id_0"/>
						<label id="attachment_label_0"
							class="bold mono pseudo-link"
							style="display: none;"
							onclick="c4s.download($('#attachment_id_0').val());"></label>

                        <span class=""style="position: relative;">
                            <input type="file" class="input-file" style="opacity: 0;position: absolute;top: 0;left: 0;width: 120px;height: 25px;cursor: pointer;"id="attachment_file_0" onchange="uploadFileEngineer(0);"/>
                        </span>
                        <span class="input-file-message"><label  for="attachment_file_0"><button>ファイルを選択</button></label>経歴書を選択してください。</span>
						<button class="btn btn-default pull-right"
							id="attachment_btn_delete_0"
							style="display: none;"
							onclick="deleteEngineerAttachment(0);"><span class="glyphicon glyphicon-trash text-danger"></span>&nbsp;削除</button>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>要員データをメール送付する際に経歴書が添付ファイルが付きます。<br/>クラウド上で経歴書を閲覧することも可能です。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">備考</span>
					<textarea class="form-control" id="m_engineer_note" style="height: 8em;"></textarea>
				</div>
				<div style="width: 100%; text-align: right; display: none;">
					<label for="m_engineer_dt_created">登録日:</label>
					<span id="m_engineer_dt_created" style="font-family: monospace;"></span>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="($('#m_engineer_id').val() ? triggerUpdateEngineerObj : commitNewEngineerObj)();">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_project_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="triggerCommitProjectObject($('#m_project_id').val() ? 1 : 0);">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_project_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_project_modal_title">新規案件登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_project_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">案件内容<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_project_title" placeholder="案件内容を入力してください。" style=""/>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">取引先名<span class="text-danger">*</span></span>
                    <select class="form-control" style="width: 100%;" id="m_project_client_id" data-placeholder="取引先を選択して下さい。">
                        {% for item in data['client.enumClients'] %}
                            <option value="{{ item.id }}" >{{ item.name|e }}</option>
                        {% endfor %}
                    </select>
                    <span class="input-group-btn">
                        <button type="button" class="btn btn-primary" onclick="showAddNewClientModal('project');">新規取引先追加</button>
                    </span>
				</div>
                <input type="hidden" id="m_project_client_name"/>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">スキル</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;"  onclick="editProjectSkillCondition();">
						<li style="margin: 0.2em 0.5em; float: left;">
							<div id="m_project_skill_container" style="word-break: break-word;">
								<label for="m_project_skill"></label>

							</div>
						</li>
					</ul>
				</div>
{#                <div class="input-group">#}
{#					<span class="input-group-addon" style="min-width: 100px;">スキルメモ</span>#}
{#					<textarea class="form-control" id="m_project_skill_needs" style="height: 5em;"></textarea>#}
{#				</div>#}
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">職種</span>
                    <div id="m_project_occupation_container" class="container-fluid form-control" style="list-style-type: none; overflow: hidden;">
                        <div class="row">
                            {% set occupation_view_count = (data['occupation.enumOccupations']|length) / 2 %}
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index <= occupation_view_count %}
                                     <input type="checkbox" name="m_project_occupation[]" id="occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                            <div class="col-md-6">
                                {% for item in data['occupation.enumOccupations'] %}
                                    {% if loop.index > occupation_view_count  %}
                                     <input type="checkbox" name="m_project_occupation[]" id="occupation_label_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="occupation_label_{{ item.id }}" style="font-size: x-small; font-weight: normal; margin: 0px">{{ item.name }}</label><br/>
                                    {% endif %}
                                {% endfor %}
                            </div>
                        </div>
                    </div>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">年齢</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_age_container">
								<label for="m_project_age_from">　　</label>
								<input type="number" class="form-control-mini" id="m_project_age_from" style="width: 50px;"/>
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_age_container">
								<label for="m_project_age_to">〜</label>
								<input type="number" class="form-control-mini" id="m_project_age_to" style="width: 50px;"/>
                                　歳
							</span>
						</li>
					</ul>
				</div>
				<ul style="margin: 0; padding: 0;list-style-type: none; overflow: hidden;">
					<li class="input-group" style="float: left;">
						<span class="input-group-addon" style="min-width: 100px;">請求単価<span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_project_fee_inbound" placeholder="650,000" style="" onchange="addComma(this);"/>
					</li>
					<li class="input-group" style="float: left;" style="min-width: 100px;">
						<span class="input-group-addon" style="min-width: 100px;">支払単価</span>
						<input type="text" class="form-control" id="m_project_fee_outbound" placeholder="600,000" style="" onchange="addComma(this);"/>
					</li>
					<li class="input-group hidden" style="float: left;" style="min-width: 100px;">
						<span class="input-group-addon" style="min-width: 100px;">精算条件</span>
						<input class="form-control" id="m_project_expense"/>
					</li>
				</ul>
				<div class="input-group hidden">
					<span class="input-group-addon">作業工程</span>
					<input type="text" class="form-control" id="m_project_process"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">その他</span>
					<ul class="form-control" style="list-style-type: none; overflow: hidden;font-size: small;">
						<li class="hidden" style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_rank_id_container">
								<label for="m_project_rank_id">ランク：</label>
                                <input type="radio" name="m_project_rank_grp" id="m_project_rank_01" checked="checked" value="1"/>
								<label for="m_project_rank_01">A</label>
								<input type="radio" name="m_project_rank_grp" id="m_project_rank_02" value="2"/>
								<label for="m_project_rank_02">B</label>
                                <input type="radio" name="m_project_rank_grp" id="m_project_rank_03" value="3"/>
								<label for="m_project_rank_03">C</label>
							</span>
						</li>
                        <li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_interview_container">
								<label for="m_project_interview">面談回数：</label>
								<input type="number" id="m_project_interview" style="width: 30px;"/>
							</span>
						</li>
                        <li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_scheme_container">
								<label for="m_project_scheme">商流：</label>
								<select id="m_project_scheme" style="">
									<option value=""></option>
									<option value="元請">元請</option>
									<option value="エンド">エンド</option>
								</select>
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_station_container">
								<label for="m_project_station">最寄駅：</label>
								<input type="text" class="" id="m_project_station" style="width: 80px;" placeholder="秋葉原"/>
                                <input type="hidden" id="m_project_station_cd" value="">
                                <input type="hidden" id="m_project_station_pref_cd" value="">
                                <input type="hidden" id="m_project_station_line_cd" value="">
                                <input type="hidden" id="m_project_station_lon" value="">
                                <input type="hidden" id="m_project_station_lat" value="">
							</span>
						</li>
					</ul>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">担当営業</span>
					<span class="form-control">
						<select class="" style="width: 150px;" id="m_project_charging_user_id">
								<option></option>
							{% for item in data['manage.enumAccounts'] %}
								{% if item.is_enabled == True %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
								{% endif %}
							{% endfor %}
							</select>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">期間</span>
                    <ul class="form-control" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_term_container">
								<label for="m_project_term_begin">　　</label>
								<input type="text" class="" id="m_project_term_begin" style="width: 150px;" data-date-format="yyyy/mm/dd" placeholder="2018/02/01"/>
							</span>
						</li>
						<li style="margin: 0.2em 0.5em; float: left;">
							<span id="m_project_term_container">
								<label for="m_project_term_end">〜</label>
								<input type="text" class="" id="m_project_term_end" style="width: 150px;" data-date-format="yyyy/mm/dd" placeholder="2018/03/31"/>
							</span>
						</li>
                        <li class="hidden" style="margin: 0.2em 0.5em; float: left; width: 100%;">
							<span id="m_project_term_container">
								<label for="m_project_term">備考</label>
					            <input type="text" class="" id="m_project_term" style="width: 90%;"/>
							</span>
						</li>
                        <li style="margin: 0.2em 0.5em; float: left; width: 100%; font-size: x-small">
                            案件マッチング画面に表示するためには期間を現在日時が含まれるように設定する必要があります。
                        </li>
					</ul>
				</div>
				<div class="input-group hidden">
					<span class="input-group-addon">推奨スキルメモ</span>
					<textarea class="form-control" id="m_project_skill_recommends" style="height: 5em;"></textarea>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">共有フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_project_flg_shared"/>
						<label for="m_project_flg_shared" class="text-danger">案件がアサイン可能であればチェックしてください</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとホームの案件管理一覧に情報が表示されます。<br/>チームで情報共有を行うことが出来ます。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
                <div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;font-size: x-small;">他社公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_project_flg_public"/>
						<label for="m_project_flg_public" class="text-danger" style="display: inline">チェック状態の場合、本CRMを利用する他社のユーザへ共有されます</label>
                        <span style="color:#225fb1;" class="popover-dismiss glyphicon glyphicon-question-sign pseudo-link-cursor"
                                              data-toggle="popover"
                                              data-placement="right"
                                              data-html="true"
                                              data-content="<span style='font-size: small;color: black'>本チェックが入るとSESクラウド利用企業様に案件情報が公開されます。<br/>多くの企業様にシェアされるので見合う要員獲得に繋がります。</span>"
                                              data-container="body"
                                              onmouseover="$(this).popover('show');"
                                              onmouseout="$(this).popover('hide');"></span>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">Web公開フラグ</span>
					<span class="form-control">
						<input type="checkbox" id="m_engineer_web_public"/>
						<label for="m_engineer_web_public" class="text-danger" style="display: inline"></label>
					</span>
				</div>
				<div class="input-group">
					<span class="input-group-addon" style="min-width: 100px;">備考</span>
					<textarea class="form-control" id="m_project_note" style="height: 10em;"></textarea>
				</div>
				<div style="width: 100%; text-align: right; display: none;">
					<label for="m_project_dt_created">登録日:</label>
					<span id="m_project_dt_created" style="font-family: monospace;"></span>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="triggerCommitProjectObject($('#m_project_id').val() ? 1 : 0);">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

{% include "edit_engineer_skill_condition_modal.tpl" %}
{% include "edit_project_skill_condition_modal.tpl" %}
{% include "edit_operation_skill_condition_modal.tpl" %}

<div id="edit_project_station_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_project_station_condition_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">最寄駅検索</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <form>
                    <table>
                        <tr>
                            <td><label>都道府県</label></td>
                            <td>　<select id="ps" name="pref" onChange="setProjectMenuItem(0,this[this.selectedIndex].value,null,null)">{% include "cmn_pref_select.tpl" %}</select></td>
                        </tr>
                        <tr>
                            <td><label>路線</label></td>
                            <td>　<select id="ps0" name="ps0" onChange="setProjectMenuItem(1,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                        <tr>
                            <td><label>最寄駅</label></td>
                            <td>　<select id="ps1" name="ps1" onChange="setProjectMenuItem(2,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                    </table>
                </form>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<div id="edit_engineer_station_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_engineer_station_condition_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">最寄駅検索</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
                <form>
                    <table>
                        <tr>
                            <td><label>都道府県</label></td>
                            <td>　<select id="es" name="pref" onChange="setEngineerMenuItem(0,this[this.selectedIndex].value,null,null)">{% include "cmn_pref_select.tpl" %}</select></td>
                        </tr>
                        <tr>
                            <td><label>路線</label></td>
                            <td>　<select id="es0" name="es0" onChange="setEngineerMenuItem(1,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                        <tr>
                            <td><label>最寄駅</label></td>
                            <td>　<select id="es1" name="es1" onChange="setEngineerMenuItem(2,this[this.selectedIndex].value,null,null)"><option selected>----</select></td>
                        </tr>
                    </table>
                </form>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<div id="add_new_client_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="commitNewClient();">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#add_new_client_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
					<span id="add_new_client_modal_title">新規取引先登録</span>
                    <input type="hidden" id="#new_client_id">
				</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon">取引先名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="new_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">取引先名（カナ）<span class="text-danger">*</span></span>
					<input type="test" class="form-control" id="new_client_kana"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">郵便番号</span>
					<input type="text" class="form-control" id="new_client_addr_vip" placeholder="nnn-nnnn" style="width: 8em;" maxlength="8"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#new_client_addr_vip').val(), '#new_client_addr1', '#new_client_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
					{% if env.limit.LMT_ACT_MAP -%}
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
						<span class="input-group-btn">
							<button class="btn btn-default"
								onclick="c4s.openMap({target_id: $('#new_client_id').val(), target_type: 'client', name: $('#m_client_name').val(), addr1: $('#m_client_addr1').val(), addr2: $('#m_client_addr2').val(), tel: $('#m_client_tel').val(), modalId: 'edit_client_modal', isFloodLMT: false, current: env.current});">
								<span class="glyphicon glyphicon-globe text-success"></span>
								{% if env.limit.SHOW_HELP %}&nbsp;地図を確認する{% endif %}
							</button>
						</span>
						&nbsp;
						{% else -%}
						<span class="input-group-btn">
							<button class="btn btn-default"
								onclick="c4s.openMap({isFloodLMT: true});">
								<span class="glyphicon glyphicon-globe text-muted"></span>
							</button>
						</span>
						{% endif -%}
					{% endif -%}
					<span class="text-danger" id="new_client_addr1_alert"></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">住所<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="new_client_addr1"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">ビル名</span>
					<input type="text" class="form-control" id="new_client_addr2"/>
				</div>
				<div class="form-group" style="margin-bottom: 0;">
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-phone-alt">&nbsp;代表電話番号</span>
						<input type="text" class="form-control" id="new_client_tel"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-print">&nbsp;代表FAX番号</span>
						<input type="text" class="form-control" id="new_client_fax"/>
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">サイトURL&nbsp;<span class="glyphicon glyphicon-globe text-primary"></span></span>
					<input class="form-control" type="text" id="new_client_site" placeholder="http://"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">提案区分<span class="text-danger">*</span></span>
					<div class="form-control" id="new_client_type_presentation_container">
						<input type="checkbox" id="new_client_type_presentation_0" value="案件"/>
						<label for="new_client_type_presentation_0">案件</label>
						<input type="checkbox" id="new_client_type_presentation_1" value="人材"/>
						<label for="new_client_type_presentation_1">人材</label>
						{% if env.limit.SHOW_HELP -%}&nbsp;<span class="text-danger">案件（保有企業）/人材（保有企業）</span>{% endif -%}
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">重要度</span>
					<select class="form-control" id="new_client_type_dealing">
						<option value="重要客">重要客</option>
						<option value="通常客" selected="selected">通常客</option>
						<option value="低ポテンシャル">低ポテンシャル</option>
						<option value="取引停止">取引停止</option>
					</select>
				</div>
				<div class="input-group">
					<span class="input-group-addon">自社担当営業</span>
						<div class="" style="width: 50%; float: left;">
							<label class="" for="new_client_charging_worker1">主担当：</label>
							<select class="form-control" id="new_client_charging_worker1">
							<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}"{% if data['auth.userProfile'].user.id == item.id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
						<div class="" style="width: 50%; float: left;">
							<label for ="new_client_charging_worker2">副担当：</label>
							<select class="form-control" id="new_client_charging_worker2">
								<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">備考</span>
					<textarea class="form-control" id="new_client_note" style="height: 10em;"></textarea>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary"
					onclick="commitNewClient();">保存</button>
                <input type="hidden" id="add_new_client_mode" value="">
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<div id="edit_client_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							id="m_client_branch_btn0"
							onclick="hdlClickAddBranchBtn($('#m_client_id').val());">支店を追加する</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							id="m_client_worker_btn0"
							onclick="hdlClickAddWorkerBtn($('#m_client_id').val());">取引先担当者を追加する</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="btn btn-sm btn-primary"
							onclick="triggerCommitClient($('#m_client_id').val() !== '');">保存</button>
					</li>
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
							onclick="$('#edit_client_modal').modal('hide');">
							<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
						</button>
					</li>
				</ul>
				<h4 class="modal-title">
					<span class="glyphicon glyphicon-plus-sign"></span>&nbsp;
					<span id="edit_client_modal_title">新規取引先登録</span>
				</h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_client_client_id"/>
				<input type="hidden" id="m_client_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="input-group">
					<span class="input-group-addon">取引先名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">取引先名（カナ）<span class="text-danger">*</span></span>
					<input type="test" class="form-control" id="m_client_kana"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">郵便番号</span>
					<input type="text" class="form-control" id="m_client_addr_vip" placeholder="nnn-nnnn" style="width: 8em;" maxlength="8"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#m_client_addr_vip').val(), '#m_client_addr1', '#m_client_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
					{% if env.limit.LMT_ACT_MAP -%}
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
						<span class="input-group-btn">
							<button class="btn btn-default"
								onclick="c4s.openMap({target_id: $('#m_client_id').val(), target_type: 'client', name: $('#m_client_name').val(), addr1: $('#m_client_addr1').val(), addr2: $('#m_client_addr2').val(), tel: $('#m_client_tel').val(), modalId: 'edit_client_modal', isFloodLMT: false, current: env.current});">
								<span class="glyphicon glyphicon-globe text-success"></span>
								{% if env.limit.SHOW_HELP %}&nbsp;地図を確認する{% endif %}
							</button>
						</span>
						&nbsp;
						{% else -%}
						<span class="input-group-btn">
							<button class="btn btn-default"
								onclick="c4s.openMap({isFloodLMT: true});">
								<span class="glyphicon glyphicon-globe text-muted"></span>
							</button>
						</span>
						{% endif -%}
					{% endif -%}
					<span class="text-danger" id="m_client_addr1_alert"></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">住所<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_client_addr1"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">ビル名</span>
					<input type="text" class="form-control" id="m_client_addr2"/>
				</div>
				<div class="form-group" style="margin-bottom: 0;">
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-phone-alt">&nbsp;代表電話番号</span>
						<input type="text" class="form-control" id="m_client_tel"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-print">&nbsp;代表FAX番号</span>
						<input type="text" class="form-control" id="m_client_fax"/>
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">サイトURL&nbsp;<span class="glyphicon glyphicon-globe text-primary"></span></span>
					<input class="form-control" type="text" id="m_client_site" placeholder="http://"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">提案区分<span class="text-danger">*</span></span>
					<div class="form-control" id="m_client_type_presentation_container">
						<input type="checkbox" id="m_client_type_presentation_0" value="案件"/>
						<label for="m_client_type_presentation_0">案件</label>
						<input type="checkbox" id="m_client_type_presentation_1" value="人材"/>
						<label for="m_client_type_presentation_1">人材</label>
						{% if env.limit.SHOW_HELP -%}&nbsp;<span class="text-danger">案件（保有企業）/人材（保有企業）</span>{% endif -%}
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">重要度</span>
					<select class="form-control" id="m_client_type_dealing">
						<option value="重要客">重要客</option>
						<option value="通常客" selected="selected">通常客</option>
						<option value="低ポテンシャル">低ポテンシャル</option>
						<option value="取引停止">取引停止</option>
					</select>
				</div>
				<div class="input-group">
					<span class="input-group-addon">自社担当営業</span>
						<div class="" style="width: 50%; float: left;">
							<label class="" for="m_client_charging_worker1">主担当：</label>
							<select class="form-control" id="m_client_charging_worker1">
							<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}"{% if data['auth.userProfile'].user.id == item.id %} selected="selected"{% endif %}>{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
						<div class="" style="width: 50%; float: left;">
							<label for ="m_client_charging_worker2">副担当：</label>
							<select class="form-control" id="m_client_charging_worker2">
								<option selected="selected"></option>
							{% for item in data['manage.enumAccounts']|rejectattr("is_enabled", "even") %}
								<option value="{{ item.id }}">{{ item.name|e }}</option>
							{% endfor %}
							</select>
						</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">備考</span>
					<textarea class="form-control" id="m_client_note" style="height: 10em;"></textarea>
				</div>
				<div class="input-group" style="width: 100%;" id="m_client_branch_container">
					<label class="" for="m_client_branch_table">支店</label>
					<table id="m_client_branch_table" class="view_table table-bordered table-hover" style="width: 100%;">
						<thead>
							<tr>
								<th style="width: 35px;">操作</th>
								<th>支店名</th>
								<th>住所</th>
								{% if env.limit.LMT_ACT_MAP -%}
								<th style="width: 35px;">Map</th>
								{% endif -%}
								<th style="width: 140px;"><span class="glyphicon glyphicon-phone-alt"></span>／<span class="glyphicon glyphicon-print"></span></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
				<div class="input-group" style="width: 100%;" id="m_client_worker_container">
					<label class="" for="m_client_branch_table">取引先担当者</label><br/>
					{% if env.limit.LMT_ACT_MAIL -%}
					{{ buttons.mail_all("triggerMailOnClientModal();") }}
					{% endif -%}
					<table id="m_client_worker_table" class="view_table table-bordered table-hover" style="width: 100%;">
						<thead>
							<tr>
								<th style="width: 25px;">
									<input type="checkbox"
										onclick="c4s.toggleSelectAll('iter_mailto_worker_', this);"/>
								</th>
								<th>名前</th><!-- section and title and name -->
								<th style="width: 130px;">携帯電話番号</th><!-- tel -->
								<th>メールアドレス</th><!-- mail1 and mail2 -->
{#								<th style="width: 85px;">自社担当営業</th><!-- charging_user -->#}
								<th style="width: 30px;"></th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" id="m_client_branch_btn1"
					onclick="hdlClickAddBranchBtn($('#m_client_id').val());">支店を追加する</button>
				<button type="button" class="btn btn-primary" id="m_client_worker_btn1"
					onclick="hdlClickAddWorkerBtn($('#m_client_id').val());">取引先担当者を追加する</button>
				<button type="button" class="btn btn-primary"
					onclick="triggerCommitClient($('#m_client_id').val() !== '');">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_branch_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_branch_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">新規取引先支店登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="m_branch_id"/>
				<input type="hidden" id="m_branch_client_id"/>
				<div class="input-group">
					<span class="input-group-addon">取引先名</span>
					<input type="text" class="form-control" readOnly="readOnly" id="m_branch_client_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">支店名<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_branch_name"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">郵便番号</span>
					<input type="text" class="form-control" id="m_branch_addr_vip" placeholder="nnn-nnnn" style="width: 8em;"/>
					&nbsp;<span class="btn btn-sm btn-default"
						onclick="searchZip2Addr($('#m_branch_addr_vip').val(), '#m_branch_addr1', '#m_branch_addr1_alert')"><span class="text-danger bold">〒</span>住所検索</span>
					<span class="input-group-btn">
					{% if env.limit.LMT_ACT_MAP -%}
						{% if (env.limit.LMT_CALL_MAP_EXTERN_M > data['limit.count_records']['LMT_CALL_MAP_EXTERN_M']) or (env.limit.LMT_CALL_MAP_EXTERN_M == 0) %}
						<button class="btn btn-default"
							onclick="c4s.openMap({target_id: $('#m_branch_id').val(), target_type: 'branch', name: $('#m_branch_name').val(), addr1: $('#m_branch_addr1').val(), addr2: $('#m_branch_addr2').val(), tel: $('#m_branch_tel').val(), modalId: 'edit_branch_modal', isFloodLMT: false, current: env.current});">
							<span class="glyphicon glyphicon-globe text-success"></span>
							{% if env.limit.SHOW_HELP %}&nbsp;地図を確認する{% endif %}
						</button>
						{% else -%}
						<button class="btn btn-default"
							onclick="c4s.openMap({isFloodLMT: true});">
							<span class="glyphicon glyphicon-globe text-muted"></span>
						</button>
						{% endif -%}
					{% endif -%}
					</span>
					&nbsp;
					<span class="text-danger" id="m_branch_addr1_alert"></span>
				</div>
				<div class="input-group">
					<span class="input-group-addon">住所<span class="text-danger">*</span></span>
					<input type="text" class="form-control" id="m_branch_addr1" placeholder="住所"/>
				</div>
				<div class="input-group">
					<span class="input-group-addon">ビル名</span>
					<input type="text" class="form-control" id="m_branch_addr2" placeholder="ビル名"/>
				</div>
				<div class="form-group" style="margin-bottom: 0;">
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-phone-alt">&nbsp;代表電話番号</span>
						<input type="text" class="form-control" id="m_branch_tel"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon glyphicon glyphicon-print">&nbsp;代表FAX番号</span>
						<input type="text" class="form-control" id="m_branch_fax"/>
					</div>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary"
					onclick="triggerCommitBranch($('#m_branch_id').val() !== '');">保存</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->
<div id="edit_worker_modal" class="modal fade"
	role="dialog" aria-hidden="true">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_worker_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_worker_modal_title">新規取引先担当者登録</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<input type="hidden" id="ms_client_id"/>
				<input type="hidden" id="ms_worker_id"/>
				<span class="text-danger">必須入力項目（＊）</span>
				<div class="form-group">
					<div class="input-group">
						<span class="input-group-addon">取引先担当者名<span class="text-danger">*</span></span>
						<input class="form-control" type="text" id="ms_worker_name"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">取引先担当者名（カナ）<span class="text-danger">*</span></span>
						<input class="form-control" type="text" id="ms_worker_kana"/>
					</div>
				</div>
				<div class="form-group">
					<h4>企業情報</h4>
					<div class="input-group">
						<span class="input-group-addon">取引先企業名</span>
						<input type="text" class="form-control" id="ms_worker_client_name" readOnly="readOnly"/>
						<input type="hidden" id="ms_worker_client_id"/>
					</div>
					<ul style="padding-left: 0; list-style-type: none;">
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">部署</span>
								<input type="text" class="form-control" id="ms_worker_section"/>
							</div>
						</li>
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">役職</span>
								<input type="text" class="form-control" id="ms_worker_title"/>
							</div>
						</li>
					</ul>
				</div>
				<div class="form-group">
					<ul style="padding-left: 0; list-style-type: none;">
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">携帯電話番号</span>
								<input type="text" class="form-control" id="ms_worker_tel"/>
							</div>
						</li>
						<li style="width: 50%; float: left;">
							<div class="input-group">
								<span class="input-group-addon">代表電話番号</span>
								<input type="text" class="form-control" id="ms_worker_tel2"/>
							</div>
						</li>
					</ul>
					<div class="input-group">
						<span class="input-group-addon">送信用メールアドレス</span>
						<input type="text" class="form-control" id="ms_worker_mail1"/>
					</div>
					<div class="input-group">
						<span class="input-group-addon">サブ メールアドレス</span>
						<input type="text" class="form-control" id="ms_worker_mail2"/>
					</div>
				</div>
				<div class="input-group">
					<span class="input-group-addon">その他</span>
					<div class="form-control" id="m_client_misc_container">
						<ul class="" style="margin-bottom: 0; padding: 0; list-style-type: none; overflow: hidden;">
							<li style="margin: 0 1em; float: left;">
								<input type="checkbox" id="ms_worker_flg_keyperson"/>
								<label for="ms_worker_flg_keyperson">キーマン フラグ</label>
							</li>
							<li style="margin: 0 1em; float: left;">
								<input type="checkbox" id="ms_worker_flg_sendmail"/>
								<label for="ms_worker_flg_sendmail">メール送信フラグ</label>
							</li>
							<li style="margin: 0 1em; float: left;">
								<label for="m_client_recipient_priority">メール送信時宛先表示優先度：</label>
								<input type="text" id="ms_worker_recipient_priority" style="width: 2em; text-align: center;"/>
								{% if env.limit.SHOW_HELP %}
								&nbsp;<span class="text-danger">1（最上位）～9（最下位）で優先度を入力してください</span>
								{% endif %}
							</li>
						</ul>
					</div>
				</div>
				<div class="input-group" style="width: 100%;">
					<span class="input-group-addon">備考</span>
					<textarea class="form-control" id="ms_worker_note" style="height: 10em;"></textarea>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				<button type="button" class="btn btn-primary" onclick="$('#ms_worker_id').val() ? triggerCommitWorkerObj(Number($('#ms_worker_id').val())) : triggerCommitWorkerObj();">保存</button>
				<button type="button" class="btn btn-primary" onclick="hdlClickAddMoreWorkerBtn($('#ms_worker_id').val());">保存してさらに追加</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->