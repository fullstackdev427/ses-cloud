{% import "cmn_controls.macro" as buttons -%}
{% set contracts = ("正社員", "契約社員", "個人事業主", "パートナー") -%}
{% set contractNews = ("正社員(契約社員)", "個人事業主", "パートナー") -%}
{% set pagenates = ("100", "200", "500", "all") -%}
{% set schemes = (("すべて", ""), ("元請", "元請"), ("エンド", "エンド")) -%}
{% set shares = (("すべて", ""), ("オープン", 1), ("クローズ", 0)) -%}
{% set limits = (("〜40件", 40),("〜60件", 60),("〜80件", 80), ("〜100件", 100), ("100件〜", -1)) -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<script src="/js/jquery-ui.min.js" type="text/javascript"></script>
<script src="/js/jquery.autokana.min.js" type="text/javascript"></script>
<script src="/js/bootstrap-datepicker.js" type="text/javascript"></script>
<script src="/js/bootstrap-datepicker.ja.js" type="text/javascript"></script>
<link href="/css/select2.min.css" rel="stylesheet">        
<script src="/js/select2.min.js"></script>
<script src="/js/bignumber.min.js" type="text/javascript"></script>
<script src="/js/jquery.tablefix.min.js" type="text/javascript"></script>
        


<body {% if "iPhone" in env.UA or "Android" in env.UA -%}class="sp_body" {% endif -%}>
<img src = "/img/jquery-ui/ui-bg_flat_75_ffffff_40x100.png" style="height: 0px;"/>


{% include "cmn_header.tpl" %}
<!-- メインコンテンツ -->

	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
                <div class="col-sm-2">
    				<img alt="稼働" width="22" height="20" src="/img/icon/group_engineer.png"> 稼働 一覧
                </div>
                <div class="col-sm-4">
                    <span class="popover-video"
                        data-toggle="popover"
                        data-placement="right"
                        data-content="<a href='#' style='font-weight: bold' class='video-operation-new'>稼働新規登録</a><br /><a href='#' style='font-weight: bold' class='video-operation-quotation'>稼働見積書作成</a>"
                        data-html="true"><a href="#" style="font-weight: bold" onclick="c4s.hdlClickDirectionBtn('home.direction');">解説動画はコチラ≫</a>
                    </span>
                </div>
			</div>

            <div class="row">
							<div class="col-sm-5 col-sm-push-7" style="padding-right:0px;">
									<table class="table table-condensed" style="background-color: #f1f1f1; color: #666666;border: 1px solid #ddd;">
											<thead>
													<tr>
															<th class="text-center" style="border-right: 2px solid #ddd;font-weight: bold;"></th>
															<th class="text-center" >稼働人数</th>
															<th class="text-center" >売上</th>
															<th class="text-center" >粗利</th>
															<th class="text-center" >粗利率</th>
													</tr>
											</thead>
											<tbody>
													<tr>
															<td class="text-center" style="border-right: 2px solid #ddd;font-weight: bold;">稼働</td>
															<td id="summary_count" class="text-center" style="background-color: #ffffff;">---</td>
															<td id="summary_base_exc_tax" class="text-center" style="background-color: #ffffff;">---</td>
															<td id="summary_gross_profit" class="text-center" style="background-color: #ffffff;">---</td>
															<td id="summary_gross_profit_rate" class="text-center" style="background-color: #ffffff;">---</td>
													<tr>
													<tr>
															<td class="text-center" style="border-right: 2px solid #ddd;font-weight: bold;">終了確定</td>
															<td id="summary_fix_count" class="text-center" style="background-color: #ffffff;">---</td>
															<td id="summary_fix_base_exc_tax" class="text-center" style="background-color: #ffffff;">---</td>
															<td id="summary_fix_gross_profit" class="text-center" style="background-color: #ffffff;">---</td>
															<td id="summary_fix_gross_profit_rate" class="text-center" style="background-color: #ffffff;">---</td>
													<tr>
											</tbody>
									</table>
							</div>

								<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
									<div class="col-sm-7 col-sm-pull-5" style="background-color: #f1f1f1;padding-left:0px;padding-right:0px;">
										<!--input type="submit" style="display: none;"/-->
										<div class="col-lg-6" style="padding-left:0px!important; padding-right:0px!important;">
											<ul
											    style="padding-inline-start: 0px!important; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
											    <li style="float: left;">
											        <label for="query_client_name" style="color: #666666;padding-right:60px">顧客名</label>
											        <input type="text" id="query_client_name" value="{{ query.client_name|e }}" />
                                                </li>
                                                <li style="float: left;">
											        <label for="query_project_title" style="color: #666666;padding-right: 4px;">プロジェクト名</label>
											        <input type="text" id="query_project_title" value="{{ query.project_title|e }}" />
											    </li>
						                        <li style="float: left;">
													<label for="query_term_begin" style="color: #666666;padding-right:32px">勤務開始日</label>
													<input type="text" id="query_term_begin" value="{{ query.term_begin|e }}" data-date-format="yyyy/mm/dd"/>
												</li>
						                        <li style="float: left;">
						                            <label for="query_engineer_charging_user_name" style="color: #666666;padding-right:46px">人材担当</label>
						                            <input type="text" id="query_engineer_charging_user_name" value="{{ query.engineer_charging_user_name|e }}"/>
						                        </li>
						                        <li style="float: left;">
													<label for="query_contract" style="color: #666666;padding-right:74px">所属</label>
													<select id="query_contract" value="{{ query.contract }}">
														<option value="">すべて</option>
														{% for contract in contractNews %}
														<option value="{{ contract}}"{% if contract == query.contract %} selected="selected"{% endif %}>{{ contract }}</option>
														{% endfor %}
													</select>
												</li>
						{#                        <li style="float: left;">#}
						{#							<label for="query_view_limit" style="color: #666666;padding-right: 46px;">表示件数</label>#}
						{#							<select id="query_view_limit" value="{{ query.view_limit }}">#}
						{#                                {% for limitLabel, limitValue in limits %}#}
						{#								<option value="{{limitValue}}"{% if limitValue == query.view_limit %} selected="selected"{% endif %}>{{ limitLabel }}</option>#}
						{#								{% endfor %}#}
						{#							</select>#}
						{#						</li>#}
											</ul>
										</div>
										<div class="col-lg-6" style="padding-left:0px!important; padding-right:0px!important;">
											<ul style="padding-inline-start: 0px!important; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
												<li style="float: left;">
													<label for="query_name" style="color: #666666;">要員名/所属企業</label>
													<input type="text" id="query_name" value="{{ query.name|e }}"/>
												</li>
						                        <li style="float: left;">
													<label for="query_term_end" style="color: #666666;padding-right:32px;">勤務終了日</label>
													<input type="text" id="query_term_end" value="{{ query.term_end|e }}" data-date-format="yyyy/mm/dd"/>
												</li>
						                        <li style="float: left;">
													<label for="query_charging_user_name" style="color: #666666;padding-right:46px;">案件担当</label>
													<input type="text" id="query_charging_user_name" value="{{ query.charging_user_name|e }}"/>
												</li>
                                                <li style="float: left;">
													<label for="query_contract_month" style="color: #666666;padding-right:60px">契約月</label>
													<input type="text" id="query_contract_month" value="{{ query.contract_month|e }}" data-date-format="yyyy/mm"/>
												</li>
						                        <li style="float: left;display: none">
						                            <label for="query_transfer_member" style="color: #666666;">引継</label>
						                            <input type="text" id="query_transfer_member" value="{{ query.transfer_member|e }}"/>
						                        </li>
												<li style="float: left; width: 275px">
													<label for="query_is_active" style="color: #666666;">稼働/非稼働</label>
													<input type="checkbox" id="query_is_active"{% if query.is_active == 1 %} value="1" checked="checked" {% else %} value="0" {% endif %}/>
													<label for="query_is_fixed" style="color: #666666;">終了確定</label>
													<input type="checkbox" id="query_is_fixed"{% if query.is_fixed == 1 %} value="1" checked="checked" {% else %} value="0" {% endif %}/>
												</li>
						{#                        <li style="float: left;">#}
						{#							<label for="query_view_limit" style="color: #666666;">表示件数</label>#}
						{#							<select id="query_view_limit" value="{{ query.view_limit }}">#}
						{#                                {% for limitLabel, limitValue in limits %}#}
						{#								<option value="{{limitValue}}"{% if limitValue == query.view_limit %} selected="selected"{% endif %}>{{ limitLabel }}</option>#}
						{#								{% endfor %}#}
						{#							</select>#}
						{#						</li>#}
											</ul>
										</div>
									</div>
									<div class="col-sm-6 col-sm-push-6" style="margin-top:-40px;">
										<div style="margin-top: 1em; text-align:right;">
											{{ buttons.search_operation("triggerSearch();") }}
											{{ buttons.clear("triggerSearchClear();") }}
										</div>
									</div>
								</form>


			</div>
<!--
			<div class="row" style="/*background-color: #f1f1f1;*/">
				<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
                        <li style="margin: 0 2em; float: left;">
							<label for="query_client_name" style="color: #666666;">顧客名</label>
							<input type="text" id="query_client_name" value="{{ query.client_name|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_name" style="color: #666666;">要員名/所属企業名</label>
							<input type="text" id="query_name" value="{{ query.name|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_contract" style="color: #666666;">所属</label>
							<select id="query_contract" value="{{ query.contract }}">
								<option value="">すべて</option>
								{% for contract in contractNews %}
								<option value="{{ contract}}"{% if contract == query.contract %} selected="selected"{% endif %}>{{ contract }}</option>
								{% endfor %}
							</select>
						</li>
							<label for="query_is_active" style="color: #666666;">稼働/非稼働</label>
							<input type="checkbox" id="query_is_active"{% if query.is_active == 1 %} value="1" checked="checked" {% else %} value="0" {% endif %}/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_is_fixed" style="color: #666666;">終了確定</label>
							<input type="checkbox" id="query_is_fixed"{% if query.is_fixed == 1 %} value="1" checked="checked" {% else %} value="0" {% endif %}/>
						</li>
                        <li style="margin: 0 2em; float: left;">
							<label for="query_term_begin" style="color: #666666;">勤務開始日</label>
							<input type="text" id="query_term_begin" value="{{ query.term_begin|e }}" data-date-format="yyyy/mm/dd"/>
						</li>
                        <li style="margin: 0 2em; float: left;">
							<label for="query_term_end" style="color: #666666;">勤務終了日</label>
							<input type="text" id="query_term_end" value="{{ query.term_end|e }}" data-date-format="yyyy/mm/dd"/>
						</li>
                        <li style="margin: 0 2em; float: left;">
							<label for="query_charging_user_name" style="color: #666666;">案件担当</label>
							<input type="text" id="query_charging_user_name" value="{{ query.charging_user_name|e }}"/>
						</li>
                        <li style="margin: 0 2em; float: left;">
                            <label for="query_engineer_charging_user_name" style="color: #666666;">人材担当</label>
                            <input type="text" id="query_engineer_charging_user_name" value="{{ query.engineer_charging_user_name|e }}"/>
                        </li>
                        <li style="margin: 0 2em; float: left;display: none">
                            <label for="query_transfer_member" style="color: #666666;">引継</label>
                            <input type="text" id="query_transfer_member" value="{{ query.transfer_member|e }}"/>
                        </li>
                        <li style="margin: 0 2em; float: left;">
							<label for="query_contract_month" style="color: #666666;">契約月</label>
							<input type="text" id="query_contract_month" value="{{ query.contract_month|e }}" data-date-format="yyyy/mm"/>
						</li>
{#                        <li style="margin: 0 2em; float: left;">#}
{#							<label for="query_view_limit" style="color: #666666;">表示件数</label>#}
{#							<select id="query_view_limit" value="{{ query.view_limit }}">#}
{#                                {% for limitLabel, limitValue in limits %}#}
{#								<option value="{{limitValue}}"{% if limitValue == query.view_limit %} selected="selected"{% endif %}>{{ limitLabel }}</option>#}
{#								{% endfor %}#}
{#							</select>#}
{#						</li>#}
					</ul>
					<div style="margin-top: 1em; text-align:right;">
						{{ buttons.search_operation("triggerSearch();") }}
						{{ buttons.clear("triggerSearchClear();") }}
					</div>
				</form>

			</div>
-->
			<!-- /検索フォーム -->
			<!-- 検索結果ヘッダー -->
			<div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-5">
                    <input type="hidden" id="focus_new_record" value="0" />
                    {{ buttons.new_obj("hdlClickNewOperationObj();") }}
					{{ buttons.create_estimate_sheet("triggerCreateQuotationEstimate()") }}
                    {#{{ buttons.create_order_sheet("triggerCreateQuotationOrder()") }}#}
                    {{ buttons.create_purchase_sheet("triggerCreateQuotationPurchase()") }}
                    {{ buttons.create_invoice_sheet("triggerCreateQuotationInvoice()") }}
				</div>
				<!-- 件数 -->
{#                {% set LOW_LIMIT = (query.view_limit or 40) %}#}
{#				{{ buttons.count_view(data['operation.enumOperations'], LOW_LIMIT)}}#}
				<!-- /件数 -->
				<!--
			</div>
            <div class="row" style="margin-top:20px; margin-bottom: 10px;">
                <div class="col-lg-1"></div>
			-->
                <div class="col-lg-2 text-center">
                    <input type="checkbox" id="query_is_sort_name" onclick="$('#query_is_sort_client').prop('checked', false);triggerSearch();"{% if query.is_sort_name == 1 %} checked="checked"{% endif %}/>
                    <label for="query_is_sort_name" style="color: #666666;">売上50音順</label>
                </div>
                <div class="col-lg-2 text-center">
                    <input type="checkbox" id="query_is_sort_client" onclick="$('#query_is_sort_name').prop('checked', false);triggerSearch();"{% if query.is_sort_client == 1 %} checked="checked"{% endif %}/>
                    <label for="query_is_sort_client" style="color: #666666;">BP売上50音順</label>
                </div>
				<!--
                <div class="col-lg-2"></div>
            </div>
            <div class="row" style="margin-bottom:10px;">
				-->
                <div class="col-lg-3">
                {% set OPERATUON_TOTAL = data['operation.total'][0].count if data['operation.total'] else 0 %}
                {{ buttons.paging_operation(query, OPERATUON_TOTAL) }}
								</div>
            </div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
            <div id="row-table" class="row" style="overflow-x: scroll;margin-left: 0px;">
			<div class="fixed_table">
				<table class="table view_table table-bordered table-hover" style="white-space: nowrap;">
					<thead>
						<tr style="height: 65px;">
							<th style="min-width:31px;max-width:31px;width:31px;padding-bottom:20px;">選<br/>択<br/>
{#                                <input type="checkbox" id="iter_operation_selected_cb_0" onclick="c4s.toggleSelectAll('iter_operation_selected_cb_', this);"/>#}
                            </th>
                            <th style="min-width:32px;max-width:32px;width:32px;padding-bottom:20px;">操<br/>作</th>
							<th style="min-width:40px;max-width:40px;width:40px;padding-bottom:20px;">稼働/<br/>非稼働</th>
                            <th style="min-width:140px;max-width:140px;width:140px;padding-bottom:20px;">顧客名<br/>(請求先企業)</th>
                            <th style="min-width:140px;max-width:140px;width:140px;padding-bottom:20px;">プロジェクト名</th>
							<th style="min-width:80px;max-width:80px;width:80px; border-right: double;border-color: #ddd;padding-bottom:20px;">要員名</th>
							<th style="min-width:200px;max-width:200px;width:200px;padding-bottom:20px;">所属企業<br/>区分</th>
                            <th style="min-width:95px;max-width:95px;width:95px;padding-bottom:20px;">勤務開始日</th>
                            <th style="min-width:95px;max-width:95px;width:95px;padding-bottom:20px;">勤務終了日</th>
                            <th style="min-width:110px;max-width:110px;width:110px;padding-bottom:20px;">請求単価</th>
                            <th style="min-width:95px;max-width:95px;width:95px;padding-bottom:20px;">請求税抜<br>(税込)</th>
                            <th style="min-width:110px;max-width:110px;width:110px;padding-bottom:20px;">支払単価</th>
                            <th style="min-width:95px;max-width:95px;width:95px;padding-bottom:20px;">支払税抜<br>(税込)</th>
                            <th style="min-width:80px;max-width:80px;width:80px;padding-bottom:20px;">粗利</th>
                            <th style="min-width:70px;max-width:70px;width:70px;padding-bottom:20px;">粗利率</th>
                            <th style="min-width:110px;max-width:110px;width:110px;padding-bottom:20px;">期間備考</th>
                            <th style="min-width:95px;max-width:95px;width:95px;padding-bottom:20px;">案件担当</th>
                            <th style="min-width:95px;max-width:95px;width:95px;padding-bottom:20px;">人材担当</th>
                            <th style="min-width:95px;max-width:95px;width:95px;display: none;padding-bottom:20px;">引継</th>
                            <th style="min-width:32px;max-width:32px;width:32px;padding-bottom:20px;">終了<br/>確定</th>
                            <th style="min-width:150px;max-width:150px;width:150px;padding-bottom:20px;">スキル</th>
                            <th style="min-width:95px;max-width:95px;width:95px;padding-bottom:20px;">契約日</th>
                            <th style="min-width:170px;max-width:170px;width:170px;padding-bottom:20px;">請求サイト</th>
                            <th style="min-width:170px;max-width:170px;width:170px;padding-bottom:20px;">支払サイト</th>
                            <th style="min-width:170px;max-width:170px;width:170px;padding-bottom:20px;">請求・支払の留意事項</th>
						</tr>
					</thead>
					<tbody id="detail-table-body">
                    {% if data['operation.enumOperations'] %}
{#                        {% if LOW_LIMIT != -1%}#}
{#						    {% set items = data['operation.enumOperations'][0:LOW_LIMIT] %}#}
{#                        {% else %}#}
{#                            {% set items = data['operation.enumOperations'] %}#}
{#                        {% endif %}#}
					    {% set items = data['operation.enumOperations'] %}
                        {% set clItems = data['client.enumClients'] %}
						{% for item in items %}
                        <tr id="iter_operation_" style="height: 84px;">
                            <td class="text-center" style="min-width: 31px; max-width:31px;width:31px;">
                                {% if item.is_active == 1 %}
                                    <input type="checkbox" name="select_quotation_target" id="iter_operation_selected_cb_{{ item.id }}" value="{{ item.id }}-{{ item.project_id }}-{{ item.engineer_id }}-{{ item.client_id }}-{% if item.engineer_company_id %}{{ item.engineer_company_id }}{% endif %}-{% if item.engineer_client_id %}{{ item.engineer_client_id }}{% endif %}"/>
                                {% endif %}
                                <input type="hidden" id="operation_id_{{ loop.index }}" value="{{ item.id }}"/>
                                <input type="hidden" id="project_id_{{ loop.index }}" value="{{ item.project_id }}"/>
                                <input type="hidden" id="engineer_id_{{ loop.index }}" value="{{ item.engineer_id }}"/>
                                <input type="hidden" id="client_id_{{ loop.index }}" value="{{ item.client_id }}"/>
                            </td>
                            <td class="center " style="min-width: 32px; max-width:32px;width:32px;">
                                <div class="btn-group dropup">
                                    <a class="btn dropdown-toggle pseudo-link-cursor glyphicon glyphicon-align-justify" data-toggle="dropdown" aria-expanded="false" alt="操作" title="操作"onclick="" style="width: 15px;box-shadow: none; padding: 0;"></a>
                                    <ul class="dropdown-menu" role="menu">
                                        <li role="presentation"><a role="menuitem" tabindex="-1" onclick="triggerCopyOperationRecord({{ item.id }});" style="color: white;font-size: small;">コピー</a></li>
                                        <li role="presentation"><a role="menuitem" tabindex="-1" onclick="triggerDeleteOperationRecord({{ item.id }});" style="color: white;font-size: small;">削除</a></li>
                                    </ul>
                                </div>
							</td>
                            <td class="center" style="min-width: 40px; max-width:40px;width:40px;">
                                <input type="checkbox" id="is_active_{{ loop.index }}" value="1" {% if item.is_active == 1 %}checked="checked"{% endif %} />
                            </td>
                            <td style="font-size: 11px;min-width: 140px; max-width:140px;width:140px;">
                                <span class="project_client_name pseudo-link" title="{{ item.client_name|e }}" onclick="overwriteClientModalForEdit({{ item.client_id }});">{{ item.client_name|truncate(12, True)|e }}</span>
                            </td>
                            <td style="font-size: 11px;min-width: 140px; max-width:140px;width:140px;">
                                <span class="project_title pseudo-link" title="{{ item.project_title }}" onclick="overwriteModalForEditProject({{ item.project_id }});">{{ item.project_title|truncate(20, True)|e }}</span>
                            </td>
                            <td style="font-size: 11px;min-width: 80px; max-width:80px;width:80px;border-right: double; border-color: #ddd">
                                {% if item.engineer_company_id != data["auth.userProfile"].company.id %}
                                    {{ item.engineer_name|truncate(6, True)|e }}
                                {% else %}
                                    <span class="engineer_name pseudo-link" title="{{ item.name }}" onclick="overwriteModalForEditEngineer({{ item.engineer_id }});">{{ item.engineer_name|truncate(6, True)|e }}</span>
                                {% endif %}
                                <br><br><span class="pseudo-link" style="font-size: xx-small" onclick="changeEngineerForNew({{ item.id }});">要員選択</span>
                            </td>
                            <td style="font-size: 11px;min-width: 200px; max-width:200px;width:200px;" id="operation-client-select">
                                {% if item.engineer_company_id != data["auth.userProfile"].company.id %}
                                    {{ item.engineer_company_name|truncate(10, True)|e }}
                                {% else %}
                                    <select class="engineer_client_select" id="engineer_client_select_{{ loop.index }}" style="width: 100%;" id="" onclick="setMtClients({{ loop.index }});" onchange="stackUpdateEngineerClient({{ item.engineer_id }}, $(this).val())";>
                                        {% if item.engineer_client_id %}
                                            {% for clItem in clItems %}
                                                {% if clItem.id == item.engineer_client_id %}
                                                    <option value="{{ item.engineer_client_id }}" selected >{{ clItem.name }}</option>
                                                {% endif %}
                                            {% endfor %}
                                        {% else %}
                                            <option>　</option>
                                        {% endif %}
                                    </select>
                                    <script type="text/javascript">
                                        var select2_engineer_client_select_{{ loop.index }}_flg = false;
                                        $(document).on('mouseover', function(event) {
                                            if ($(event.target).closest("#select2-engineer_client_select_{{ loop.index }}-container").length & select2_engineer_client_select_{{ loop.index }}_flg == false) {
                                                setMtClients({{ loop.index }});
                                                select2_engineer_client_select_{{ loop.index }}_flg = true;
                                            }
                                        });
                                    </script>
                                {% endif %}
                                <br/>
                                <select id="engineer_contract_{{ loop.index }}" value="{{ item.contract|truncate(10, True)|e }}" onchange="changeCalcFormAreaWithIndex({{ item.engineer_id }}, this.value, {{ loop.index }});">
                                    {% for contract in contracts %}
                                    <option value="{{ contract}}"{% if contract == item.contract %} selected="selected"{% endif %}>{{ contract }}</option>
                                    {% endfor %}
                                </select>
                            </td>
                            <td style="min-width: 95px; max-width:95px;width:95px;"><input type="text" id="term_begin_{{ loop.index }}" style="width: 80px" value="{% if item.term_begin %}{{ item.term_begin }}{% else %}{% if item.term_begin_project %}{{ item.term_begin_project }}{% endif %}{% endif %}" data-date-format="yyyy/mm/dd"></td>
														{% if item.is_fixed != 1 %}
														<td style="min-width: 95px; max-width:95px;width:95px;"><input type="text" id="term_end_{{ loop.index }}" style="width: 80px" value="{% if item.term_end %}{{ item.term_end }}{% else %}{% if item.term_end_project %}{{ item.term_end_project }}{% endif %}{% endif %}" data-date-format="yyyy/mm/dd"></td>
														{% else %}
                            <td style="min-width: 95px; max-width:95px;width:95px;"><input type="text" id="term_end_{{ loop.index }}" style="width: 80px;color:red;" value="{% if item.term_end %}{{ item.term_end }}{% else %}{% if item.term_end_project %}{{ item.term_end_project }}{% endif %}{% endif %}" data-date-format="yyyy/mm/dd"></td>
														{% endif %}
                            <td style="min-width: 110px; max-width:110px;width:110px;">
                                <span class="tooltip-parent" id="calc_base_exc_tax_form_area_{{ loop.index }}">
                                    <input type="text" id="base_exc_tax_{{ loop.index }}" style="width: 75px; text-align: right;" value="{{ item.base_exc_tax }}" onclick="openCalcBaseForm({{loop.index}})" onchange="updateCalcOperationResult({{loop.index}})" maxlength="10">
                                    <span class="tooltip-forms1{% if loop.last %}-bottom{% endif %}" id="calc_base_exc_tax_form_{{ loop.index }}">
                                        <span style="font-size: small">時給　　　　　想定稼働時間</span>
                                        <br>
                                        <input type="text" id="demand_wage_per_hour_{{ loop.index }}" style="width: 75px; text-align: right;" value="{{ item.demand_wage_per_hour }}" onchange="setBaseExcTax({{loop.index}});">
                                        &times;
                                        <input type="number" id="demand_working_time_{{ loop.index }}" style="width: 75px; text-align: right;" value="{{ item.demand_working_time }}" onchange="setBaseExcTax({{loop.index}});">
                                        <br>
                                        <span style="font-size: 10px">時給と想定稼動時間を入力してください。</span>
                                    </span>
                                </span><br>
                                <select id="demand_unit_{{loop.index}}" {% if item.demand_unit == 2%}readonly="readonly" {% endif %} style="width: 50px;font-size: 13px;" onchange="changeDemandUnit(this,{{loop.index}});">
                                        <option value="1" {% if item.demand_unit == 1 %}selected{% endif %}>月額</option>
                                        <option value="2" {% if item.demand_unit == 2 %}selected{% endif %}>時給</option>
                                </select>

                                <span class="tooltip-parent" id="calc_demand_term_form_area_{{ loop.index }}">
                                    <a class="pseudo-link-cursor " style="font-size: xx-small;width:50px;height:20px;padding:0px;margin:0px;" onclick="openCalcDemandTermForm({{ loop.index }})">精算条件</a>
                                    <br>
                                    <div style="overflow: hidden;text-overflow: ellipsis; white-space: nowrap;">
                                        <span id="settlement_mini_view_{{ loop.index }}" style="font-size: x-small;"></span>
                                        <span id="demand_memo_area_{{ loop.index }}" style="font-size: x-small;"></span>
                                    </div>
                                    <span class="tooltip-forms1{% if loop.last %}-bottom{% endif %}" id="calc_demand_term_form_{{ loop.index }}">
                                        <span style="font-size: small">　　　　精算時間　　　　　　　　　　精算単価</span>
                                        <br>
                                        <input type="number" id="settlement_from_{{ loop.index }}" style="width: 60px" value="{{ item.settlement_from|int }}" onchange="updateDemandExcessAndDeduction({{loop.index}});updatePaymentExcessAndDeduction({{loop.index}});">
                                        〜
                                        <input type="number" id="settlement_to_{{ loop.index }}" style="width: 60px" value="{{ item.settlement_to|int }}" onchange="updateDemandExcessAndDeduction({{loop.index}});updatePaymentExcessAndDeduction({{loop.index}});">
                                        <span>　　</span>
                                        <input type="text" id="deduction_{{ loop.index }}" style="width: 70px; text-align: right;" value="{{ item.deduction }}" onchange="updateCalcOperationResult({{loop.index}})">
                                        〜
                                        <input type="text" id="excess_{{ loop.index }}" style="width: 70px; text-align: right;" value="{{ item.excess }}" onchange="updateCalcOperationResult({{loop.index}})">
                                        <span>　　</span>
                                        <select id="settlement_unit_{{loop.index}}" onchange="updateDemandExcessAndDeduction({{loop.index}})">
                                                <option value="1" {% if item.settlement_unit == 1 %}selected{% endif %}>1時間</option>
                                                <option value="2" {% if item.settlement_unit == 2 %}selected{% endif %}>30分</option>
                                                <option value="3" {% if item.settlement_unit == 3 %}selected{% endif %}>15分</option>
                                        </select>
                                        <br>
                                        <span style="font-size: small">下限時間　　　上限時間　　　　控除単価　　　超過単価　　　精算単位</span>
                                        <br>
                                        <span style="font-size: small">精算備考 <input type="text" id="demand_memo_{{ loop.index }}" class="autocomplete_demand_memo" style="width: 400px" value="{% if item.demand_memo %}{{ item.demand_memo }}{% endif %}" placeholder="例：固定、8×稼働日-8×稼働日+20h"></span>
                                    </span>
                                </span>
                                <script type="text/javascript">
                                    $(document).on('click touchend', function(event) {
                                      if (!$(event.target).closest("#calc_base_exc_tax_form_{{ loop.index }}").length && !$(event.target).closest("#calc_base_exc_tax_form_area_{{ loop.index }}").length) {
                                        $("#calc_base_exc_tax_form_{{ loop.index }}").hide();
                                      }
                                      if (!$(event.target).closest("#calc_demand_term_form_{{ loop.index }}").length && !$(event.target).closest("#calc_demand_term_form_area_{{ loop.index }}").length) {
                                        $("#calc_demand_term_form_{{ loop.index }}").hide();
                                        viewDemandMemoArea({{loop.index}});
                                      }
                                    });
                                </script>
                            </td>
                            <td style="min-width: 95px; max-width:95px;width:95px;">
                                <span style="width: 70px; text-align: right;" id="base_exc_tax_{{ loop.index }}_label"></span><br>
                                <input type="hidden" id="base_inc_tax_{{ loop.index }}" value="{{ item.base_inc_tax }}" >
                                (<span style="width: 70px; text-align: right;" id="base_inc_tax_{{ loop.index }}_label"></span>)
                            </td>
                            <td style="min-width: 110px; max-width:110px;width:110px;">
                                <span class="tooltip-parent" id="calc_payment_base_exc_tax_form_area_{{ loop.index }}">
                                    <input type="text" id="payment_base_{{ loop.index }}" style="width: 75px; text-align: right;" value="{{ item.payment_base }}" onclick="openCalcPaymentBaseForm({{loop.index}})" onchange="updateCalcOperationResult({{loop.index}})" maxlength="10">
                                    <span class="tooltip-forms2{% if loop.last %}-bottom{% endif %}" id="calc_payment_base_exc_tax_form_{{ loop.index }}">
                                        <span style="font-size: small">時給　　　　　想定稼働時間</span>
                                        <br>
                                        <input type="text" id="payment_wage_per_hour_{{ loop.index }}" style="width: 75px; text-align: right;" value="{{ item.payment_wage_per_hour }}" onchange="setPaymentBaseExcTax({{loop.index}});">
                                        &times;
                                        <input type="number" id="payment_working_time_{{ loop.index }}" style="width: 75px; text-align: right;" value="{{ item.payment_working_time }}" onchange="setPaymentBaseExcTax({{loop.index}});">
                                        <br>
                                        <span style="font-size: 10px">時給と想定稼動時間を入力してください。</span>
                                    </span>
                                </span><br>
                                <select id="payment_unit_{{loop.index}}" style="width: 50px;font-size: 13px;" onchange="changePaymentUnit(this,{{loop.index}});">
                                        <option value="1" {% if item.payment_unit == 1 %}selected{% endif %}>月額</option>
                                        <option value="2" {% if item.payment_unit == 2 %}selected{% endif %}>時給</option>
                                </select>

                                <span class="tooltip-parent {% if (item.engineer_company_id == data["auth.userProfile"].company.id and item.contract != "正社員" and item.contract != "契約社員") or item.engineer_company_id != data["auth.userProfile"].company.id %}{% else %}hidden{% endif %}" id="calc_payment_term_form_area_{{ loop.index }}">
                                    <a class="pseudo-link-cursor " style="font-size: xx-small;width:50px;height:20px;padding:0px;margin:0px;" onclick="openCalcPaymentTermForm({{ loop.index }})">精算条件</a>
                                    <div style="overflow: hidden;text-overflow: ellipsis; white-space: nowrap;">
                                        <span id="payment_settlement_mini_view_{{ loop.index }}" style="font-size: x-small;"></span>
                                        <span id="payment_memo_area_{{ loop.index }}" style="font-size: x-small;"></span>
                                    </div>
                                    <span class="tooltip-forms1{% if loop.last %}-bottom{% endif %}" id="calc_payment_term_form_{{ loop.index }}">
                                        <span style="font-size: small">　　　　精算時間　　　　　　　　　　精算単価</span>
                                        <br>
                                        <input type="number" id="payment_settlement_from_{{ loop.index }}" style="width: 60px" value="{{ item.payment_settlement_from|int }}" onchange="updateDemandExcessAndDeduction({{loop.index}});updatePaymentExcessAndDeduction({{loop.index}});">
                                        〜
                                        <input type="number" id="payment_settlement_to_{{ loop.index }}" style="width: 60px" value="{{ item.payment_settlement_to|int }}" onchange="updateDemandExcessAndDeduction({{loop.index}});updatePaymentExcessAndDeduction({{loop.index}});">
                                        <span>　　</span>
                                        <input type="text" id="payment_deduction_{{ loop.index }}" style="width: 70px; text-align: right;" value="{{ item.payment_deduction }}" onchange="updateCalcOperationResult({{loop.index}})">
                                        〜
                                        <input type="text" id="payment_excess_{{ loop.index }}" style="width: 70px; text-align: right;" value="{{ item.payment_excess }}" onchange="updateCalcOperationResult({{loop.index}})">
                                        <span>　　</span>
                                        <select id="payment_settlement_unit_{{loop.index}}" onchange="updateDemandExcessAndDeduction({{loop.index}})">
                                                <option value="1" {% if item.payment_settlement_unit == 1 %}selected{% endif %}>1時間</option>
                                                <option value="2" {% if item.payment_settlement_unit == 2 %}selected{% endif %}>30分</option>
                                                <option value="3" {% if item.payment_settlement_unit == 3 %}selected{% endif %}>15分</option>
                                        </select>
                                        <br>
                                        <span style="font-size: small">下限時間　　　上限時間　　　　控除単価　　　超過単価　　　精算単位</span>
                                        <br>
                                        <span style="font-size: small">精算備考 <input type="text" id="payment_memo_{{ loop.index }}" class="autocomplete_demand_memo" style="width: 400px" value="{% if item.payment_memo %}{{ item.payment_memo }}{% endif %}" placeholder="例：固定、8×稼働日-8×稼働日+20h"></span>
                                    </span>
                                </span>
                                <span class="tooltip-parent {% if (item.engineer_company_id == data["auth.userProfile"].company.id and item.contract != "正社員" and item.contract != "契約社員") or item.engineer_company_id != data["auth.userProfile"].company.id %}hidden{% endif %}" id="calc_allowance_form_area_{{ loop.index }}">
                                    <a class="pseudo-link-cursor " style="font-size: xx-small;width:50px;height:20px;padding:0px;margin:0px;" onclick="openCalcAllowanceForm({{ loop.index }})">手当条件</a>
                                    <span class="tooltip-forms1{% if loop.last %}-bottom{% endif %}" id="calc_allowance_form_{{ loop.index }}">
                                        <span style="font-size: small">　　　　　　　　　　手当入力</span>
                                        <br>
                                        <span>　</span>
                                        <input type="text" id="welfare_fee_{{ loop.index }}" style="width: 70px; text-align: right;" value="{{ item.welfare_fee }}" onchange="updateCalcOperationResult({{loop.index}})">
                                        <span>　　</span>
                                        <input type="text" id="transportation_fee_{{ loop.index }}" style="width: 70px; text-align: right;" value="{{ item.transportation_fee }}" onchange="updateCalcOperationResult({{loop.index}})">
                                        <span>　　</span>
                                        <input type="text" id="bonuses_division_{{ loop.index }}" style="width: 70px; text-align: right;" value="{{ item.bonuses_division }}" onchange="updateCalcOperationResult({{loop.index}})">
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
                                      if (!$(event.target).closest("#calc_payment_base_exc_tax_form_{{ loop.index }}").length && !$(event.target).closest("#calc_payment_base_exc_tax_form_area_{{ loop.index }}").length) {
                                        $("#calc_payment_base_exc_tax_form_{{ loop.index }}").hide();
                                      }

                                      if (!$(event.target).closest("#calc_payment_term_form_{{ loop.index }}").length && !$(event.target).closest("#calc_payment_term_form_area_{{ loop.index }}").length) {
                                        $("#calc_payment_term_form_{{ loop.index }}").hide();
                                        viewPaymentMemoArea({{loop.index}});
                                      }
                                      if (!$(event.target).closest("#calc_allowance_form_{{ loop.index }}").length && !$(event.target).closest("#calc_allowance_form_area_{{ loop.index }}").length) {
                                        $("#calc_allowance_form_{{ loop.index }}").hide();
                                      }
                                    });
                                </script>
                            </td>
                            <td style="min-width: 95px; max-width:95px;width:95px;">
                                <span style="width: 70px; text-align: right;" id="payment_exc_tax_{{ loop.index }}_label"></span><br>
                                (<input type="text" style="width: 70px; text-align: right;" id="payment_inc_tax_{{ loop.index }}" value="{{ item.payment_inc_tax }}" onchange="onchangePaymentIncTax({{ loop.index }})">)
{#                                (<span style="width: 70px; text-align: right;" id="payment_inc_tax_{{ loop.index }}_label"></span>)#}
                            </td>
                            <td style="min-width: 80px; max-width:80px;width:80px;">
                                <input type="hidden" id="gross_profit_{{ loop.index }}" value="{{ item.gross_profit }}">
                                <div style="width: 60px; text-align: right; padding-right: 3px" id="gross_profit_{{ loop.index }}_label"></div>
                            </td>
                            <td style="min-width: 70px; max-width:70px;width:70px;">
                                <input type="hidden" id="gross_profit_rate_{{ loop.index }}" value="{{ item.gross_profit_rate }}">
                                <div style="width: 40px; text-align: center; padding-right: 2px" id="gross_profit_rate_{{ loop.index }}_label"></div>
                            </td>
                            <td style="min-width: 110px; max-width:110px;width:110px;">
                                <input type="text" id="term_memo_{{ loop.index }}" style="width: 90px" value="{% if item.term_memo %}{{ item.term_memo }}{% endif %}">
                            </td>
                            <td style="min-width: 95px; max-width:95px;width:95px;font-size: 11px;">
{#                                {% if item.engineer_company_id != data["auth.userProfile"].company.id %}#}
{#                                   <span class="charging_user_name">{{ item.charging_user.user_name|truncate(6, True)|e }}</span>#}
{#                                {% else %}#}
                                    <select style="font-size: 11px;max-width: 80px;" class="" id="" onchange="stackUpdateProjectChargingUser({{ item.project_id }},$(this).val());">
                                    {% for itemA in data['manage.enumAccounts'] %}
                                        {% if itemA.is_enabled == True %}
                                            <option value="{{ itemA.id }}" {% if item.charging_user.id  == itemA.id  %} selected="selected"{% endif %}>{{ itemA.name|e }}</option>
                                        {% endif %}
                                    {% endfor %}
                                </select>
{#                                {% endif %}#}
                            </td>
                            <td style="min-width: 95px; max-width:95px;width:95px;font-size: 11px;">
                                {% if item.engineer_company_id != data["auth.userProfile"].company.id %}
                                   <span class="engineer_charging_user_name">{{ item.engineer_charging_user.user_name|truncate(6, True)|e }}</span>
                                {% else %}
                                    <select style="font-size: 11px;max-width: 80px;" class="" id="" onchange="stackUpdateEngineerChargingUser({{ item.engineer_id }},$(this).val());">
                                        {% for itemA in data['manage.enumAccounts'] %}
                                            {% if itemA.is_enabled == True %}
                                                <option value="{{ itemA.id }}" {% if item.engineer_charging_user.id  == itemA.id  %} selected="selected"{% endif %}>{{ itemA.name|e }}</option>
                                            {% endif %}
                                        {% endfor %}
                                    </select>
                                {% endif %}
                            </td>
                            <td style="min-width: 95px; max-width:95px;width:95px;display: none"><input type="text" id="transfer_member_{{ loop.index }}" style="width: 80px" value="{% if item.transfer_member %}{{ item.transfer_member }}{% endif %}"></td>
                            <td style="min-width: 32px; max-width:32px;width:32px;"class="center"><input type="checkbox" id="is_fixed_{{ loop.index }}" value="" {% if item.is_fixed == 1 %}checked="checked"{% endif %} style=""></td>
                            <td style="min-width: 150px; max-width:150px;width:150px;white-space: normal;">{% if item.skill_list %}{{ item.skill_list|truncate(20, True)|e  }}{% endif %}</td>
                            <td style="min-width: 95px; max-width:95px;width:95px;"><input type="text" id="contract_date_{{ loop.index }}" style="width: 80px" value="{% if item.contract_date %}{{ item.contract_date }}{% endif %}" data-date-format="yyyy/mm/dd"></td>
                            <td style="min-width: 170px; max-width:170px;width:170px;"><input type="text" id="demand_site_{{ loop.index }}" class="autocomplete_site" style="width: 150px" value="{% if item.demand_site %}{{ item.demand_site }}{% endif %}" placeholder="例：月末締翌月末支払"></td>
                            <td style="min-width: 170px; max-width:170px;width:170px;"><input type="text" id="payment_site_{{ loop.index }}" class="autocomplete_site" style="width: 150px" value="{% if item.payment_site %}{{ item.payment_site }}{% endif %}" placeholder="例：月末締翌月末支払"></td>
                            <td style="min-width: 95px; max-width:170px;width:170px;"><input type="text" id="other_memo_{{ loop.index }}" style="width: 150px" value="{% if item.other_memo %}{{ item.other_memo }}{% endif %}"></td>
                        </tr>
                        {% endfor %}
					{% else %}
						<tr id="iter_operation_0">
							<td colspan="24">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
            </div>
            <div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-7">
                    {{ buttons.new_obj("hdlClickNewOperationObj();") }}

				</div>
                {{ buttons.paging_operation(query, OPERATUON_TOTAL) }}
				<!-- 件数 -->
{#				{{ buttons.count_view(data['operation.enumOperations'], LOW_LIMIT) }}#}
				<!-- /件数 -->
			</div>
			<!-- /検索結果 -->
			<div class="row text-right" style="margin-top: 0.5em;">
				{{ buttons.update_operation("updateObject();") }}
			</div>
		</div>
	</div>
<!-- /メインコンテンツ -->

<div class="modal fade" id="modal-confirm-unsaved" tabindex="-1" role="dialog" aria-labelledby="info" aria-hidden="true">
    <input type="hidden" name="before_action" id="before_action">
    <input type="hidden" name="loc" id="loc">
    <input type="hidden" name="page_number" id="page_number">
    <div class="modal-dialog" >
        <div class="modal-content">
            <div class="modal-body">
                <p> 内容が変更されています。保存しますか？</p>
            </div>
            <div class="modal-footer">
                <button type="button" id="btn-confirm-unsaved" class="btn btn-primary">はい</button>
                <button type="button" class="btn btn-default" data-dismiss="modal">いいえ</button>
            </div>
        </div>
    </div>
</div>


{% include "operation_modal.tpl" %}
{% include "change_engineer_modal.tpl" %}

{% include "cmn_cap_mail_per_month.tpl" %}
{% include "cmn_cap.tpl" %}
<!-- [end] Model. -->
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}



		


<!--script type="text/javascript" src="/js/operation.min.js"></script-->
<script type="text/javascript">
function genFilterQuery(e){e=e||{};var t=$("input[id^=query_][type=text]");t.each(function(t,n){n.value&&(e[n.attributes.id.value.replace("query_","")]=n.value)});var n=$("#query_contract")[0];0!=n.selectedIndex&&(e.contract=n.selectedOptions[0].value);var a=$("input[id^=query_is][type=checkbox]");return a.each(function(t,n){n.checked?e[n.attributes.id.value.replace("query_","")]=1:e[n.attributes.id.value.replace("query_","")]=0}),0==e.is_fixed&&delete e.is_fixed,e.from_operation=!0,e.focus_new_record=!1,"0"!=$("#focus_new_record").val()&&(e.focus_new_record=!0),e}function genOrderQuery(e){return e=e||{},e}function hdlClickSearchBtnForUpdate(){c4s.hdlClickSearchBtn()}function updateObject(e,t){if(e=e||hdlClickSearchBtnForUpdate,t=t||{},env.updateEngineerClientStackList)for(var n=0;n<env.updateEngineerClientStackList.length;n++){var a=env.updateEngineerClientStackList[n],i={};i.id=Number(a.engineer_id),i.client_id=""!=a.client_id?Number(a.client_id):null,i.update_data_only=!0,c4s.invokeApi_ex({location:"engineer.updateEngineer",body:i,onSuccess:function(e){$("input[id^=iter_operation_selected_cb_]").each(function(e,t,n){var i=$(this).val().split("-");if(a.engineer_id==i[2]){i[5]=a.client_id;var r=i.join("-");$(this).val(r)}})},onError:function(e){alert("更新に失敗しました。（"+e.status.description+"）")}})}if(env.updateEngineerChargingUserStackList)for(n=0;n<env.updateEngineerChargingUserStackList.length;n++){a=env.updateEngineerChargingUserStackList[n],i={};i.id=Number(a.engineer_id),i.charging_user_id=""!=a.charging_user_id?Number(a.charging_user_id):null,i.update_data_only=!0,c4s.invokeApi_ex({location:"engineer.updateEngineer",body:i,onSuccess:function(e){},onError:function(e){alert("更新に失敗しました。（"+e.status.description+"）")}})}if(env.updateEngineerContractStackList)for(n=0;n<env.updateEngineerContractStackList.length;n++){a=env.updateEngineerContractStackList[n],i={};i.id=Number(a.engineer_id),i.contract=""!=a.contract?a.contract:null,i.update_data_only=!0,c4s.invokeApi_ex({location:"engineer.updateEngineer",body:i,onSuccess:function(e){},onError:function(e){alert("更新に失敗しました。（"+e.status.description+"）")}})}if(env.updateProjectChargingUserStackList)for(n=0;n<env.updateProjectChargingUserStackList.length;n++){var r=env.updateProjectChargingUserStackList[n];i={};i.id=Number(r.project_id),i.charging_user_id=""!=r.charging_user_id?Number(r.charging_user_id):null,i.update_data_only=!0,c4s.invokeApi_ex({location:"project.updateProject",body:i,onSuccess:function(e){},onError:function(e){alert("更新に失敗しました。（"+e.status.description+"）")}})}updateOperation(e,t)}function updateOperation(e,t){var n=genUpdateValue(),a=n.operationObjList.length;a>0?c4s.invokeApi_ex({location:"operation.updateOperation",body:n,onSuccess:function(n){e===hdlClickSearchBtnForUpdate&&alert("更新しました。"),e(t)},onError:function(e){alert("更新に失敗しました（"+e.status.description+"）")}}):e(t)}function genUpdateValue(){for(var e={login_id:env.login_id,credential:env.credential,prefix:env.prefix,operationObjList:[]},t=1;t<=row_length;t++){var n={};n.id=$("#operation_id_"+t).val(),null!=n.id&&""!=n.id&&(n=getInputValueOperationObj(t),e.operationObjList.push(n))}return e}function getInputValueOperationObj(e){var t={};return t.id=$("#operation_id_"+e).val(),t.term_memo=$("#term_memo_"+e).val(),t.demand_exc_tax=formatForCalc($("#demand_exc_tax_"+e).val()),t.demand_inc_tax=formatForCalc($("#demand_inc_tax_"+e).val()),t.payment_exc_tax=formatForCalc($("#payment_exc_tax_"+e).val()),t.payment_inc_tax=formatForCalc($("#payment_inc_tax_"+e).val()),t.gross_profit=formatForCalc($("#gross_profit_"+e).val()),t.gross_profit_rate=formatForCalc($("#gross_profit_rate_"+e).val()),t.settlement_from=""!=$("#settlement_from_"+e).val()?Number($("#settlement_from_"+e).val()):null,t.settlement_to=""!=$("#settlement_to_"+e).val()?Number($("#settlement_to_"+e).val()):null,t.contract_date=""!=$("#contract_date_"+e).val()?$("#contract_date_"+e).val():null,t.tax=formatForCalc($("#tax_"+e).val()),t.welfare_fee=formatForCalc($("#welfare_fee_"+e).val()),t.transportation_fee=formatForCalc($("#transportation_fee_"+e).val()),t.base_exc_tax=formatForCalc($("#base_exc_tax_"+e).val()),t.base_inc_tax=formatForCalc($("#base_inc_tax_"+e).val()),t.excess=formatForCalc($("#excess_"+e).val()),t.deduction=formatForCalc($("#deduction_"+e).val()),t.demand_memo=$("#demand_memo_"+e).val(),t.payment_memo=$("#payment_memo_"+e).val(),t.demand_site=$("#demand_site_"+e).val(),t.payment_site=$("#payment_site_"+e).val(),t.cutoff_date=""!=$("#cutoff_date_"+e).val()?$("#cutoff_date_"+e).val():null,t.other_memo=$("#other_memo_"+e).val(),t.is_active=$("#is_active_"+e).is(":checked")?1:0,t.is_fixed=$("#is_fixed_"+e).is(":checked")?1:0,t.transfer_member=$("#transfer_member_"+e).val(),t.term_begin=""!=$("#term_begin_"+e).val()?$("#term_begin_"+e).val():null,t.term_end=""!=$("#term_end_"+e).val()?$("#term_end_"+e).val():null,t.term_begin_exp=""!=$("#term_begin_exp_"+e).val()?$("#term_begin_exp_"+e).val():null,t.term_end_exp=""!=$("#term_end_exp_"+e).val()?$("#term_end_exp_"+e).val():null,t.settlement_exp=""!=$("#settlement_exp_"+e).val()?$("#settlement_exp_"+e).val():null,t.settlement_unit=$("#settlement_unit_"+e).val(),t.demand_unit=$("#demand_unit_"+e).val(),t.payment_unit=$("#payment_unit_"+e).val(),t.bonuses_division=formatForCalc($("#bonuses_division_"+e).val()),t.payment_base=formatForCalc($("#payment_base_"+e).val()),t.payment_excess=formatForCalc($("#payment_excess_"+e).val()),t.payment_deduction=formatForCalc($("#payment_deduction_"+e).val()),t.payment_exp=""!=$("#payment_exp_"+e).val()?$("#payment_exp_"+e).val():null,t.payment_settlement_unit=$("#payment_settlement_unit_"+e).val(),t.payment_settlement_from=""!=$("#payment_settlement_from_"+e).val()?Number($("#payment_settlement_from_"+e).val()):null,t.payment_settlement_to=""!=$("#payment_settlement_to_"+e).val()?Number($("#payment_settlement_to_"+e).val()):null,t.demand_wage_per_hour=formatForCalc($("#demand_wage_per_hour_"+e).val()),t.demand_working_time=$("#demand_working_time_"+e).val()?Number($("#demand_working_time_"+e).val()):null,t.payment_wage_per_hour=formatForCalc($("#payment_wage_per_hour_"+e).val()),t.payment_working_time=$("#payment_working_time_"+e).val()?Number($("#payment_working_time_"+e).val()):null,t}function updateCalcOperationResult(e){updateBaseIncTax(e),updateDemandIncTax(e),updatePaymentIncTax(e),updateGrossProfit(e),viewSettlementMiniArea(e),viewPaymentSettlementMiniArea(e)}function updateDemandExcessAndDeduction(e){var t=formatForCalc($("#excess_"+e).val()),n=formatForCalc($("#deduction_"+e).val()),a=formatForCalc($("#settlement_from_"+e).val()),i=formatForCalc($("#settlement_to_"+e).val()),r=formatForCalc($("#base_exc_tax_"+e).val());$("#settlement_unit_"+e).val();a=c4s.floor(parseFloat(a),2),i=c4s.floor(parseFloat(i),2),r>0&&a>0&&(n=new BigNumber(r).div(a).toFixed(0),n=10*Math.floor(n/10)),r>0&&i>0&&(t=new BigNumber(r).div(i).toFixed(0),t=10*Math.floor(t/10)),$("#excess_"+e).val(formatForView(t)),$("#deduction_"+e).val(formatForView(n)),$("#settlement_from_"+e).val(a),$("#settlement_to_"+e).val(i),updateCalcOperationResult(e),viewSettlementMiniArea(e)}function updatePaymentExcessAndDeduction(e){var t=formatForCalc($("#payment_excess_"+e).val()),n=formatForCalc($("#payment_deduction_"+e).val()),a=formatForCalc($("#payment_settlement_from_"+e).val()),i=formatForCalc($("#payment_settlement_to_"+e).val()),r=formatForCalc($("#payment_base_"+e).val());$("#payment_settlement_unit_"+e).val();a=c4s.floor(parseFloat(a),2),i=c4s.floor(parseFloat(i),2),r>0&&a>0&&(n=new BigNumber(r).div(a).toFixed(0),n=10*Math.floor(n/10)),r>0&&i>0&&(t=new BigNumber(r).div(i).toFixed(0),t=10*Math.floor(t/10)),$("#payment_excess_"+e).val(formatForView(t)),$("#payment_deduction_"+e).val(formatForView(n)),$("#payment_settlement_from_"+e).val(a),$("#payment_settlement_to_"+e).val(i),updateCalcOperationResult(e),viewPaymentSettlementMiniArea(e)}function adjustExpFromUnit(e,t){switch(t){case"1":e=Math.floor(e);break;case"2":tmp=e-Math.floor(e),tmp>=.5?tmp=.5:tmp=0,e=Math.floor(e)+tmp;break;case"3":tmp=e-Math.floor(e),tmp<.25?tmp=0:.25<=tmp&&tmp<.5?tmp=.25:5<=tmp&&tmp<.75?tmp=.5:tmp=.75,e=Math.floor(e)+tmp}return e.round().toPrecision()}function updateGrossProfit(e){var t=formatForCalc($("#base_exc_tax_"+e).val()),n=formatForCalc($("#payment_base_"+e).val()),a=formatForCalc($("#welfare_fee_"+e).val()),i=formatForCalc($("#transportation_fee_"+e).val()),r=formatForCalc($("#bonuses_division_"+e).val()),_=$("#engineer_contract_"+e).val(),o=$("#m_operation_update_engineer_contract").val();if("パートナー"==_||"個人事業主"==_||"パートナー"==o||"個人事業主"==o)var l=t-n;else l=t-n-a-i-r;var c=0,d=0;0!=l&&0!=t?(c=new BigNumber(l).div(t).toPrecision(3),d=Math.round(100*c*1e3)/1e3,c>1e3?(c=9.99,d=999.9):c<-1e3&&(c=-9.99,d=-999.9)):c=0,$("#welfare_fee_"+e).val(formatForView(a)),$("#transportation_fee_"+e).val(formatForView(i)),$("#bonuses_division_"+e).val(formatForView(r)),$("#gross_profit_"+e).val(formatForView(l)),$("#gross_profit_rate_"+e).val(formatForView(c)),$("#gross_profit_"+e+"_label").html(formatForView(l)),$("#gross_profit_rate_"+e+"_label").html(d+"%")}function updateBaseIncTax(e){var t=$("#base_exc_tax_"+e).val();if(void 0!==t&&""!==t){t=formatForCalc(t);var n=c4s.calcIncTax(t);$("#base_exc_tax_"+e).val(formatForView(t)),$("#base_exc_tax_"+e+"_label").html(formatForView(t)),$("#base_inc_tax_"+e).val(formatForView(n)),$("#base_inc_tax_"+e+"_label").html(formatForView(n))}}function updateDemandIncTax(e){var t=$("#base_exc_tax_"+e).val();if(void 0!==t&&""!==t){var n=c4s.calcIncTax(formatForCalc(t)),a=n-formatForCalc(t);$("#base_exc_tax_"+e).val(formatForView(t)),$("#demand_inc_tax_"+e).val(formatForView(n)),$("#tax_"+e).val(formatForView(a)),$("#demand_exc_tax_"+e+"_label").html(formatForView(t)),$("#demand_inc_tax_"+e+"_label").html(formatForView(n)),$("#tax_"+e+"_label").html(formatForView(a))}}function updatePaymentIncTax(e){var t=$("#payment_base_"+e).val();if(void 0!==t&&""!==t){t=formatForCalc(t);var n=c4s.calcIncTax(t);$("#payment_base_"+e).val(formatForView(t)),$("#payment_exc_tax_"+e).val(formatForView(t)),$("#payment_inc_tax_"+e).val(formatForView(n)),$("#payment_exc_tax_"+e+"_label").html(formatForView(t)),$("#payment_inc_tax_"+e+"_label").html(formatForView(n))}}function formatForCalc(e){return void 0===e||""===e?0:(e=e.replace(/[Ａ-Ｚａ-ｚ０-９]/g,function(e){return String.fromCharCode(e.charCodeAt(0)-65248)}),e=e.replace(/,/g,""),e=parseInt(e),""===e||isNaN(e)?0:e)}function formatForView(e){return e.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g,"$1,")}function onchangePaymentIncTax(e){var t=$("#payment_inc_tax_"+e).val();if(void 0!==t&&""!==t){t=formatForCalc(t);var n=c4s.calcExcTax(t);$("#payment_base_"+e).val(formatForView(n)),$("#payment_exc_tax_"+e).val(formatForView(n)),$("#payment_inc_tax_"+e).val(formatForView(t)),$("#payment_exc_tax_"+e+"_label").html(formatForView(n)),$("#payment_inc_tax_"+e+"_label").html(formatForView(t)),updateGrossProfit(e)}}function viewSettlementMiniArea(e){var t=formatForCalc($("#settlement_from_"+e).val()),n=formatForCalc($("#settlement_to_"+e).val()),a="("+t+"h-"+n+"h)",i="";i=a.length>11&&0==e?"<br>　　　　　"+a:a,$("#settlement_mini_view_"+e).html(i)}function viewPaymentSettlementMiniArea(e){var t=formatForCalc($("#payment_settlement_from_"+e).val()),n=formatForCalc($("#payment_settlement_to_"+e).val()),a="("+t+"h-"+n+"h)",i="";i=a.length>11&&0==e?"<br>　　　　　"+a:a,$("#payment_settlement_mini_view_"+e).html(i)}function viewDemandMemoArea(e){var t=$("#demand_memo_"+e).val();t.length>15&&0==e?$("#demand_memo_area_"+e).html(t.slice(0,15)+"..."):$("#demand_memo_area_"+e).html(t)}function viewPaymentMemoArea(e){var t=$("#payment_memo_"+e).val();t.length>15&&0==e?$("#payment_memo_area_"+e).html(t.slice(0,15)+"..."):$("#payment_memo_area_"+e).html(t)}function triggerCreateQuotationEstimate(){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide"),updateObject(createQuotationEstimate,null)}function createQuotationEstimate(){if(operations=[],projects=[],$("input[id^=iter_operation_selected_cb_]").each(function(e,t,n){if(t.checked){var a=$(this).val().split("-");operations.push(a[0]),projects.push(a[1])}}),projects=projects.filter(function(e,t,n){return n.indexOf(e)===t}),0!=projects.length)if(projects.length>1)alert("対象の案件を１つに絞ってください。");else for(var e in projects)projects[e]&&c4s.invokeApi_ex({location:"quotation.topEstimate",body:{action_type:"CREATE",project_id:parseInt(projects[e]),operation_ids:operations},pageMove:!0,newPage:!0});else alert("対象を選択してください。")}function triggerCreateQuotationOrder(){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide"),updateObject(createQuotationOrder,null)}function createQuotationOrder(){if(operations=[],projects=[],$("input[id^=iter_operation_selected_cb_]").each(function(e,t,n){if(t.checked){var a=$(this).val().split("-");operations.push(a[0]),projects.push(a[1])}}),projects=projects.filter(function(e,t,n){return n.indexOf(e)===t}),0!=projects.length)if(projects.length>1)alert("対象の案件を１つに絞ってください。");else for(var e in projects)projects[e]&&c4s.invokeApi_ex({location:"quotation.topOrder",body:{action_type:"CREATE",project_id:parseInt(projects[e]),operation_ids:operations},pageMove:!0,newPage:!0});else alert("対象を選択してください。")}function triggerCreateQuotationInvoice(){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide"),updateObject(createQuotationInvoice,null)}function createQuotationInvoice(){if(operations=[],projects=[],clients=[],$("input[id^=iter_operation_selected_cb_]").each(function(e,t,n){if(t.checked){var a=$(this).val().split("-");operations.push(a[0]),projects.push(a[1]),clients.push(a[3])}}),projects=projects.filter(function(e,t,n){return n.indexOf(e)===t}),0!=projects.length)if(projects.length>1)alert("対象の案件を１つに絞ってください。");else for(var e in projects)projects[e]&&c4s.invokeApi_ex({location:"quotation.topInvoice",body:{action_type:"CREATE",project_id:parseInt(projects[e]),operation_ids:operations},pageMove:!0,newPage:!0});else alert("対象を選択してください。")}function triggerCreateQuotationPurchase(){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide"),updateObject(createQuotationPurchase,null)}function createQuotationPurchase(){if(operations=[],engineers=[],projects=[],clients=[],companies=[],engineer_clients=[],$("input[id^=iter_operation_selected_cb_]").each(function(e,t,n){if(t.checked){var a=$(this).val().split("-");operations.push(a[0]),projects.push(a[1]),engineers.push(a[2]),clients.push(a[3]),""!=a[4]&&companies.push(a[4]),""!=a[5]&&engineer_clients.push(a[5])}}),projects=projects.filter(function(e,t,n){return n.indexOf(e)===t}),0!=projects.length)if(projects.length>1)alert("対象の案件を１つに絞ってください。");else if(companies=companies.filter(function(e,t,n){return n.indexOf(e)===t}),0!=companies.length)if(companies.length>1)alert("異なる企業に所属する要員が選択されています。\n対象の企業を１件に絞ってください。");else for(var e in projects){var t={action_type:"CREATE",project_id:parseInt(projects[e]),operation_ids:operations};companies.length>0&&companies[0]!=env.companyInfo.id?(t.company_id=parseInt(companies[0]),t.engineer_company_id=parseInt(companies[0])):engineer_clients.length>0?t.engineer_client_id=parseInt(engineer_clients[0]):t.engineer_id=parseInt(engineers[0]),projects[e]&&c4s.invokeApi_ex({location:"quotation.topPurchase",body:t,pageMove:!0,newPage:!0})}else alert("対象を選択してください。");else alert("対象を選択してください。")}function renderRecipientModal(e){"project"==e?c4s.invokeApi_ex({location:"project.enumProjects",body:genModalFilterQuery(),onSuccess:function(t){env.data=env.data||{},t.data&&t.data.length>0?env.data.projects=t.data:env.data.projects=[],renderRecipientModalTable(e,env.data.projects)}}):"engineer"!=e&&"change_engineer"!=e||c4s.invokeApi_ex({location:"engineer.enumEngineers",body:genModalFilterQuery(),onSuccess:function(t){env.data=env.data||{},t.data&&t.data.length>0?env.data.engineers=t.data:env.data.engineers=[],renderRecipientModalTable(e,env.data.engineers)}})}function renderRecipientModalTable(e,t){var n,a;"engineer"===e||"change_engineer"===e?($("#row_count_engineer").html(t.length+"件"),n=$("#modal_search_result_engineer tbody"),"change_engineer"===e&&(n=$("#modal_change_result_engineer tbody")),n.html(""),t&&t instanceof Array&&t.length>0?t.map(function(t,i){a=$("<tr></tr>"),"engineer"===e?a.append($("<td class='center'><a class='pseudo-link-cursor' onclick='setEngineerForNew("+t.id+',"'+t.name+'","'+t.contract+'",'+t.client_id+","+t.charging_user.id+","+t.fee+',"'+t.company_name+"\");'>選択</a></td>")):a.append($("<td class='center'><a class='pseudo-link-cursor' onclick='setTargetOperationEngineer("+t.id+");'>選択</a></td>")),a.append($("<td><label for='recipient_iter_engineer_"+t.id+"'>"+t.name+"</label></td>")),a.append($("<td>"+t.fee+"</td>")),a.append($("<td style='word-break: break-word;'>"+(t.skill_list||"")+"</td>")),a.append($("<td>"+t.state_work+(t.state_work?"<br/>":"")+(t.flg_assignable||t.flg_caution?"（"+[t.flg_assignable?"アサイン可能":null,t.flg_caution?"要注意":null].filter(function(e){return Boolean(e)}).join(", ")+"）":"")+"</td>")),a.append($("<td>"+(t.mail1||t.mail2)+"</td>")),n.append(a)}):(a=$("<tr></tr>"),a.append($("<td class='center' colspan='6'>（有効なデータがありません）</td>")),n.append(a))):"project"===e&&($("#row_count_project").html(t.length+"件"),n=$("#modal_search_result_project tbody"),n.html(""),t&&t instanceof Array&&t.length>0?t.map(function(e,t){a=$("<tr></tr>"),a.append($("<td class='center'><a class='pseudo-link-cursor' onclick='setProjectForNew("+e.id+',"'+e.title+'","'+e.client.id+'",'+e.charging_user.id+","+e.fee_inbound+', "'+e.skill_id_list+'",'+JSON.stringify(e.skill_level_list)+");'>選択</a></td>")),a.append($("<td>"+e.client_name+"</td>")),a.append($("<td><label for='recipient_iter_project_"+e.id+"'>"+e.title+"</label></td>")),a.append($("<td>"+(e.charging_user.user_name||"")+"</td>")),n.append(a)}):(a=$("<tr></tr>"),a.append($("<td class='center' colspan='6'>（有効なデータがありません）</td>")),n.append(a)))}function genModalFilterQuery(){var e,t={};return $("[id^=modal_query_]").each(function(n,a){a.id&&(e=a.id.replace("modal_query_",""),"input"===a.localName&&"checkbox"===a.type?t[e]=a.checked:""!==a.value&&(t[e]=0==e.indexOf("flg_")||0==e.indexOf("is_")?Boolean(Number(a.value)):a.value))}),0!=t.flg_caution.length&&0!=t.flg_caution||delete t.flg_caution,0!=t.flg_registered.length&&0!=t.flg_registered||delete t.flg_registered,0!=t.flg_assignable.length&&0!=t.flg_assignable||delete t.flg_assignable,t}function selectProjectForNew(){$("#search_project_modal").modal("show"),renderRecipientModal("project")}function selectEngineerForNew(){$("#search_engineer_modal").modal("show"),renderRecipientModal("engineer")}function changeEngineerForNew(e){$("#change_engineer_modal").modal("show"),env.updatetargetOperationId=e,renderRecipientModal("change_engineer")}function setProjectForNew(e,t,n,a,i,r,_){$("#search_project_modal").modal("hide"),$("#m_operation_project").val(e),$("#m_operation_project_name").val(t),$("#m_operation_project_client_id").val(n),$("#m_operation_project_client_id").select2(),$("#m_operation_project_charging_user_id").val(a),""!=i&&($("#base_exc_tax_0").val(i),updateCalcOperationResult(0)),$('[name="m_operation_skill[]"]').each(function(e,t){t.checked=!1}),$('[name="m_operation_skill_level[]"]').each(function(e,t){t.selectedIndex=0}),$('[name="m_operation_skill_level[]"]').addClass("hidden"),""!=r&&$('[name="m_operation_skill[]"]').each(function(e){var t=$(this).val(),n=r.split(",");n.indexOf(t)>=0&&($(this).val([t]),$("#m_operation_skill_level_"+t).removeClass("hidden"),_.forEach(function(e,n,a){t!=e.skill_id&&t!=e.id||$("#m_operation_skill_level_"+t).val(e.level)}))}),viewSelectedOperationSkill()}function setEngineerForNew(e,t,n,a,i,r,_){$("#search_engineer_modal").modal("hide"),$("#m_operation_engineer").val(e),$("#m_operation_engineer_name").val(t),$("#m_operation_engineer_charging_user_id").val(i),$("#m_operation_update_engineer_contract").val(n),$("#m_operation_update_engineer_client_id").val(a),$("#m_operation_update_engineer_client_id").select2({allowClear:!0}),""!=r&&($("#payment_base_0").val(r),updateCalcOperationResult(0)),changeCalcFormArea(n)}function setTargetOperationEngineer(e){var t=[],n={id:env.updatetargetOperationId,engineer_id:e};t.push(n);var a={login_id:env.login_id,credential:env.credential,prefix:env.prefix,operationObjList:t};updateObject(updateOperationEngineer,a)}function updateOperationEngineer(e){c4s.invokeApi_ex({location:"operation.updateOperation",body:e,onSuccess:function(e){alert("1件更新しました。"),c4s.hdlClickSearchBtn()},onError:function(e){alert("更新に失敗しました（"+e.status.description+"）")}})}function triggerCopyOperationRecord(e){updateObject(copyOperationRecord,e)}function copyOperationRecord(e){var t={login_id:env.login_id,credential:env.credential,prefix:env.prefix,operation_id:e};c4s.invokeApi_ex({location:"operation.copyOperation",body:t,pageMove:!1,newPage:!0,onSuccess:function(e){alert("コピーしました。"),$("#focus_new_record").val(1),c4s.hdlClickSearchBtn()},onError:function(e){alert("コピーに失敗しました。（"+e.status.description+"）")}})}function triggerDeleteOperationRecord(e){updateObject(deleteOperationRecord,e)}function deleteOperationRecord(e){if(confirm("削除してよろしいですか。")){var t={login_id:env.login_id,credential:env.credential,prefix:env.prefix,operation_id:e};c4s.invokeApi_ex({location:"operation.deleteOperation",body:t,pageMove:!1,newPage:!0,onSuccess:function(e){alert("削除しました。"),c4s.hdlClickSearchBtn()},onError:function(e){alert("削除に失敗しました。（"+e.status.description+"）")}})}}function hdlClickNewEngineerObj(e){$("#commitNewEngineerObjMode").val("NormalCreate"),"changeOperationEngineer"==e&&$("#commitNewEngineerObjMode").val("changeOperationEngineer"),c4s.clearValidate({client_id:"m_engineer_client_id",client_name:"m_engineer_client_name",name:"m_engineer_name",kana:"m_engineer_kana",visible_name:"m_engineer_visible_name",tel:"m_engineer_tel",mail1:"m_engineer_mail1",mail2:"m_engineer_mail2",birth:"m_engineer_birth",gender:"m_engineer_gender_container",state_work:"m_engineer_state_work",age:"m_engineer_age",fee:"m_engineer_fee",station:"m_engineer_station",skill:"m_engineer_skill",note:"m_engineer_note",charging_user_id:"m_engineer_charging_user_id",employer:"m_engineer_employer",operation_begin:"m_engineer_operation_begin",addr_vip:"m_engineer_addr_vip",addr1:"m_engineer_addr1",addr2:"m_engineer_addr2"});var t,n=["#m_engineer_client_id","#m_engineer_client_name","#m_engineer_name","#m_engineer_kana","#m_engineer_visible_name","#m_engineer_tel","#m_engineer_mail1","#m_engineer_mail2","#m_engineer_birth","#m_engineer_age","#m_engineer_fee","#m_engineer_station","#m_engineer_state_work","#m_engineer_employer","#m_engineer_note","#attachment_id_0","#attachment_label_0","#m_engineer_skill","#m_engineer_operation_begin","#m_engineer_station_cd","#m_engineer_station_pref_cd","#m_engineer_station_line_cd","#m_engineer_station_lon","#m_engineer_station_lat","#m_engineer_addr_vip","#m_engineer_addr1","#m_engineer_addr2"],a=["#m_engineer_flg_caution","#m_engineer_flg_registered","#m_engineer_flg_assignable","#m_engineer_flg_public","#m_engineer_web_public","#m_engineer_flg_careful"],i=["#m_engineer_contract"],r=["[name=m_engineer_gender_grp]"];for(t=0;t<n.length;t++)$(n[t]).val(null);for(t=0;t<a.length;t++)$(a[t])[0].checked=!1;for(t=0;t<i.length;t++)$(i[t])[0].selectedIndex=0;for(t=0;t<r.length;t++)$(r[t])[0].checked=!0;$("#m_engineer_id").val(null),$("#m_engineer_flg_registered")[0].checked=!0,$("#m_engineer_flg_assignable")[0].checked=!0,$("#m_engineer_flg_public")[0].checked=!1,$("#m_engineer_web_public")[0].checked=!1,$("#m_engineer_flg_careful")[0].checked=!1,$("#m_engineer_charging_user_id").val(env.userProfile.user.id),$('[name="m_engineer_skill_level[]"]').each(function(e,t){t.selectedIndex=0}),$('[name="m_engineer_skill[]"]').each(function(e,t){t.checked=!1}),viewSelectedEngineerSkill(),$('[name="m_engineer_occupation[]"]').each(function(e,t){t.checked=!1}),setEngineerMenuItem(0,0,null,null),$("#es").val(0),$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>新規要員登録</span>")),deleteEngineerAttachment(0),$("#edit_engineer_modal").modal("show"),$("#m_engineer_client_id").select2({allowClear:!0}),$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),PHP(1年～2年)</span>")}function updateAge(){var e=$("#m_engineer_birth").val(),t=e?e.split("/")[0]:null,n=e?e.split("/")[1]:null,a=e?e.split("/")[2]:null;if(t&&n&&a){var i=new Date,r=new Date(t,n,a),_=i.getFullYear()-Number(t);haveBirthday(r)&&(_-=1),$("#m_engineer_age").val(_)}}function haveBirthday(e){var t=new Date,n=t.getMonth()+1,a=t.getDate(),i=e.getMonth(),r=e.getDate();return n==i?a<r:n<i}function commitNewEngineerObj(){var e=$("#commitNewEngineerObjMode").val(),t=genCommitValueOfEngineer(),n=c4s.validate(t,c4s.validateRules.engineer,{client_id:"m_engineer_client_id",client_name:"m_engineer_client_name",name:"m_engineer_name",kana:"m_engineer_kana",visible_name:"m_engineer_visible_name",tel:"m_engineer_tel",mail1:"m_engineer_mail1",mail2:"m_engineer_mail2",age:"m_engineer_age",birth:"m_engineer_birth",gender:"m_engineer_gender_container",state_work:"m_engineer_state_work",fee:"m_engineer_fee",station:"m_engineer_station",skill:"m_engineer_skill",note:"m_engineer_note",charging_user_id:"m_engineer_charging_user_id",employer:"m_engineer_employer",operation_begin:"m_engineer_operation_begin",addr_vip:"m_engineer_addr_vip",addr1:"m_engineer_addr1",addr2:"m_engineer_addr2"});if(n.length)return env.debugOut(n),void alert("入力を修正してください");c4s.invokeApi_ex({location:"engineer.createEngineer",body:t,onSuccess:function(n){alert("1件登録しました。");var a=confirmAccountFlgPublic(t.flg_public),i=function(){$("#edit_engineer_modal").modal("hide"),"changeOperationEngineer"==e?setTargetOperationEngineer(n.data.id):setEngineerForNew(n.data.id,t.name,t.contract,t.client_id,t.charging_user_id,t.fee,"")};a?updateAccountFlgPublic(i):i()},onError:function(e){alert("登録に失敗しました。（"+e.status.description+"）")}})}function deleteEngineerAttachment(e){var t=$("#attachment_file_"+e),n=$("#attachment_id_"+e),a=$("#attachment_label_"+e),i=$("#attachment_btn_commit_"+e),r=$("#attachment_btn_delete_"+e);t.val(null),t.css("display","inline"),n.val(null),a.html(""),a.css("display","none"),i.css("display","none"),r.css("display","none"),$(".input-file-message").removeClass("hidden")}function uploadFileEngineer(e){var t=$("#attachment_file_"+e),n=$("#attachment_id_"+e),a=$("#attachment_label_"+e),i=$("#attachment_btn_commit_"+e),r=$("#attachment_btn_delete_"+e);if(window.FormData){var _=new FormData,o=t[0];o.files.length&&(_.append("attachement",o.files[0]),_.append("json",JSON.stringify({login_id:env.login_id,credential:env.credential})),$.ajax({url:"/"+env.prefix+"/api/file.upload/json",type:"POST",data:_,processData:!1,contentType:!1,dataType:"json",success:function(e){e&&e.data&&e.data.id&&0==e.status.code?(n.val(e.data.id),a.html(e.data.filename+"&nbsp;(<span class='mono'>"+e.data.size+"bytes</span>)"),a.css("display","inline"),t.css("display","none"),i.css("display","inline"),r.css("display","inline")):e&&13==e.status.code&&e.data&&e.data.size&&e.data.limit?window.alert(e.status.description+"制限値が"+e.data.limit+"bytesのところ、アップロードしようとしたサイズは"+e.data.size+"bytesでした（"+String(100*(e.data.size/e.data.limit-1)).split(".")[0]+"％超過）。"):e&&e.status.code?(window.alert(e.status.description),t.val(null),n.val(null)):window.console&&console.log("file upload error.")},error:function(e){}}))}else alert("FormDataに非対応のWebブラウザです。Webブラウザのバージョンを最新に保ってください。")}function genCommitValueOfEngineer(){var e={};e.fee=formatForCalc($("#m_engineer_fee").val());var t,n,a=[["#m_engineer_client_id",Number],["#m_engineer_client_name",String],["#m_engineer_name",String],["#m_engineer_kana",String],["#m_engineer_visible_name",String],["#m_engineer_tel",String],["#m_engineer_mail1",String],["#m_engineer_mail2",String],["#m_engineer_age",Number],["#m_engineer_station",String],["#m_engineer_note",String],["#attachment_id_0",Number],["#m_engineer_skill",String],["#m_engineer_state_work",String],["#m_engineer_employer",String],["#m_engineer_operation_begin",String],["#m_engineer_station_cd",String],["#m_engineer_station_pref_cd",String],["#m_engineer_station_line_cd",String],["#m_engineer_station_lon",Number],["#m_engineer_station_lat",Number],["#m_engineer_addr_vip",String],["#m_engineer_addr1",String],["#m_engineer_addr2",String]],i=[["#m_engineer_birth",String]],r=[["#m_engineer_flg_caution",Boolean],["#m_engineer_flg_registered",Boolean],["#m_engineer_flg_assignable",Boolean],["#m_engineer_flg_public",Boolean],["#m_engineer_web_public",Boolean],["#m_engineer_flg_careful",Boolean]],_=[["#m_engineer_contract",String],["#m_engineer_charging_user_id",Number]],o=[["[name=m_engineer_gender_grp]:checked",String]];for(t=0;t<a.length;t++)n=$(a[t][0]),e[n.attr("id").replace("m_engineer_","")]=a[t][1](n.val());for(t=0;t<i.length;t++)n=$(i[t][0]),e[n.attr("id").replace("m_engineer_","")]=i[t][1](n.val());for(t=0;t<r.length;t++)n=$(r[t][0]),e[n.attr("id").replace("m_engineer_","")]=r[t][1](n[0].checked);for(t=0;t<_.length;t++)n=$(_[t][0]),e[n.attr("id").replace("m_engineer_","")]=_[t][1](n.val());for(t=0;t<o.length;t++)n=$(o[t][0]),e[n.attr("name").replace("m_engineer_","").split("_")[0]]=o[t][1](n.val());return e.attachment_id_0?(e.attachement=e.attachment_id_0,delete e.attachment_id_0):e.attachement=null,e.skill_level_list=[],e.skill_id_list=$('[name="m_engineer_skill[]"]:checked').map(function(){var t=$(this).val(),n=$("#m_engineer_skill_level_"+t).val();return""!=n&&e.skill_level_list.push({id:t,level:n}),t}).get(),0==e.skill_id_list.length&&delete e.skill_id_list,e.occupation_id_list=$('[name="m_engineer_occupation[]"]:checked').map(function(){return $(this).val()}).get(),0==e.occupation_id_list.length&&delete e.occupation_id_list,e.addr_vip&&(e.addr_vip=e.addr_vip.replace("-","")),e}function hdlClickNewProjectObj(){c4s.clearValidate({id:"m_project_id",client_id:"m_project_client_id",client_name:"m_project_client_name",title:"m_project_title",term:"m_project_term",term_begin:"m_project_term_begin",term_end:"m_project_term_end",age_from:"m_project_age_from",age_to:"m_project_age_to",fee_inbound:"m_project_fee_inbound",fee_outbound:"m_project_fee_outbound",expense:"m_project_expense",process:"m_project_process",interview:"m_project_interview_container",station:"m_project_station_container",scheme:"m_project_scheme_container",skill_needs:"m_project_skill_needs",skill_recommends:"m_project_skill_recommends",rank_id:"m_project_rank_id_container"});var e,t=["#m_project_id","#m_project_client_name","#m_project_client_id","#m_project_fee_inbound","#m_project_fee_outbound","#m_project_expense","#m_project_title","#m_project_process",["#m_project_interview",1],"#m_project_station","#m_project_note","#m_project_term","#m_project_term_begin","#m_project_term_end",["#m_project_age_from",22],["#m_project_age_to",65],"#m_project_skill_needs","#m_project_skill_recommends","#m_project_station_cd","#m_project_station_pref_cd","#m_project_station_line_cd","#m_project_station_lon","#m_project_station_lat"],n=["#m_project_flg_shared"],a=["#m_project_flg_public","#m_project_web_public"],i=[],r=["[name=m_project_rank_grp]"];for(e=0;e<t.length;e++)t[e]instanceof Array?$(t[e][0])[0].value=t[e][1]:$(t[e])[0].value="";for(e=0;e<n.length;e++)$(n[e])[0].checked=!0;for(e=0;e<a.length;e++)$(a[e])[0].checked=!1;for(e=0;e<i.length;e++)$(i[e])[0].selectedIndex=0;for(e=0;e<r.length;e++)$(r[e])[0].checked=!0;$('[name="m_project_skill[]"]').each(function(e,t){t.checked=!1}),$('[name="m_project_skill_level[]"]').each(function(e,t){t.selectedIndex=0}),viewSelectedProjectSkill(),$('[name="m_project_occupation[]"]').each(function(e,t){t.checked=!1}),$("#m_project_scheme").val(null),$("#m_project_charging_user_id").val(env.userProfile.user.id),$("#m_project_scheme").val("エンド"),setProjectMenuItem(0,0,null,null),$("#ps").val(0),$("#m_project_worker_container").addClass("hidden"),$("#edit_project_modal_title").html("新規案件登録"),
$("#edit_project_modal").modal("show"),$("#m_project_client_id").select2()}function genCommitValueOfProject(){var e={};$("#m_project_id").val()&&(e.id=Number($("#m_project_id").val())),e.fee_inbound=formatForCalc($("#m_project_fee_inbound").val()),e.fee_outbound=formatForCalc($("#m_project_fee_outbound").val());var t,n,a=[["#m_project_client_name",String],["#m_project_client_id",Number],["#m_project_expense",String],["#m_project_title",String],["#m_project_process",String],["#m_project_interview",Number],["#m_project_station",String],["#m_project_note",String],["#m_project_term",String],["#m_project_term_begin",String],["#m_project_term_end",String],["#m_project_age_from",Number],["#m_project_age_to",Number],["#m_project_skill_needs",String],["#m_project_skill_recommends",String],["#m_project_station_cd",String],["#m_project_station_pref_cd",String],["#m_project_station_line_cd",String],["#m_project_station_lon",Number],["#m_project_station_lat",Number]],i=[],r=[["#m_project_flg_shared",Boolean],["#m_project_flg_public",Boolean],["#m_project_web_public",Boolean]],_=[["#m_project_client_id",Number],["#m_project_scheme",String],["#m_project_charging_user_id",Number]],o=[["[name=m_project_rank_grp]:checked",Number]];for(t=0;t<a.length;t++)n=$(a[t][0]),e[n.attr("id").replace("m_project_","")]=a[t][1](n.val());for(t=0;t<i.length;t++)n=$(i[t][0]),""!==n.val()&&(e[n.attr("id").replace("m_project_","")]=i[t][1](n.val()));for(t=0;t<r.length;t++)n=$(r[t][0]),e[n.attr("id").replace("m_project_","")]=r[t][1](n[0].checked);for(t=0;t<_.length;t++)n=$(_[t][0]),e[n.attr("id").replace("m_project_","")]=_[t][1](n.val());for(t=0;t<o.length;t++)n=$(o[t][0]),e[n.attr("name").replace("m_project_","").split("_")[0]]=o[t][1](n.val());return e.rank&&(e.rank_id=e.rank,delete e.rank),0==e.client_id&&(e.client_id=null),e.client_id&&delete e.client_name,0==e.charging_user_id&&(e.charging_user_id=null),e.skill_level_list=[],e.needs=$('[name="m_project_skill[]"]:checked').map(function(){var t=$(this).val(),n=$("#m_project_skill_level_"+t).val();return""!=n&&e.skill_level_list.push({id:t,level:n}),t}).get(),0==e.needs.length&&delete e.needs,e.occupations=$('[name="m_project_occupation[]"]:checked').map(function(){return $(this).val()}).get(),0==e.occupations.length&&delete e.occupations,env.debugOut(e),e}function triggerCommitProjectObject(e){updateObject(commitProjectObject,e)}function commitProjectObject(e){e=1==e;var t=genCommitValueOfProject(),n=c4s.validate(t,c4s.validateRules.project,{id:"m_project_id",client_id:"m_project_client_id",client_name:"m_project_client_name",title:"m_project_title",term:"m_project_term",term_begin:"m_project_term_begin",term_end:"m_project_term_end",age_from:"m_project_age_from",age_to:"m_project_age_to",fee_inbound:"m_project_fee_inbound",fee_outbound:"m_project_fee_outbound",expense:"m_project_expense",process:"m_project_process",interview:"m_project_interview_container",station:"m_project_station_container",scheme:"m_project_scheme_container",skill_needs:"m_project_skill_needs",skill_recommends:"m_project_skill_recommends",rank_id:"m_project_rank_container"});if(n.length)return env.debugOut(n),void alert("入力を修正してください");validateCondition(t)||c4s.invokeApi_ex({location:e?"project.updateProject":"project.createProject",body:t,onSuccess:function(n){alert(e?"1件更新しました。":"1件登録しました。");var a=confirmAccountFlgPublic(t.flg_public),i=function(){$("#edit_project_modal").modal("hide");$("#m_project_client_id option:selected").text();setProjectForNew(n.data.id,t.title,client_id,t.charging_user_id,t.fee_inbound,t.needs.join(","),t.skill_level_list)};e&&(i=function(){$("#edit_project_modal").data("commitCompleted",!0),$("#edit_project_modal").modal("hide"),c4s.hdlClickSearchBtn()}),a?updateAccountFlgPublic(i):i()},onError:function(t){alert((e?"更新":"登録")+"に失敗しました（"+t.status.description+"）")}})}function editProjectSkillCondition(){$("#edit_project_skill_condition_modal").modal("show")}function viewSelectedProjectSkill(){$('[name="m_project_skill_level[]"]').addClass("hidden"),selectedSkill=$('[name="m_project_skill[]"]:checked').map(function(){var e="#m_project_skill_level_"+$(this).val();$(e).removeClass("hidden");var t=$("#skill_"+$(this).val()).text(),n=$(e+" option:selected").text();return"----"!==n&&(t+="("+n+")"),t}).get();var e=5,t=[];if(selectedSkill.length>e){for(var n=0;n<e;n++)t.push(selectedSkill[n]);t.push("...")}else t=selectedSkill;t.length>0?$("#m_project_skill_container").html(t.join(",")):$("#m_project_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),Oracle,Spring</span>")}function editEngineerSkillCondition(){$("#edit_engineer_skill_condition_modal").modal("show")}function viewSelectedEngineerSkill(){$('[name="m_engineer_skill_level[]"]').addClass("hidden"),selectedSkill=$('[name="m_engineer_skill[]"]:checked').map(function(){var e="#m_engineer_skill_level_"+$(this).val();$(e).removeClass("hidden");var t=$("#skill_"+$(this).val()).text(),n=$(e+" option:selected").text();return"----"!==n&&(t+="("+n+")"),t}).get();var e=5,t=[];if(selectedSkill.length>e){for(var n=0;n<e;n++)t.push(selectedSkill[n]);t.push("...")}else t=selectedSkill;t.length>0?$("#m_engineer_skill_container").html(t.join(",")):$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),PHP(1年～2年)</span>")}function editOperationSkillCondition(){$("#edit_operation_skill_condition_modal").modal("show")}function viewSelectedOperationSkill(){$('[name="m_operation_skill_level[]"]').addClass("hidden"),selectedSkill=$('[name="m_operation_skill[]"]:checked').map(function(){var e="#m_operation_skill_level_"+$(this).val();$(e).removeClass("hidden");var t=$("#skill_"+$(this).val()).text(),n=$(e+" option:selected").text();return"----"!==n&&(t+="("+n+")"),t}).get();var e=5,t=[];if(selectedSkill.length>e){for(var n=0;n<e;n++)t.push(selectedSkill[n]);t.push("...")}else t=selectedSkill;t.length>0?$("#m_operation_skill_container").html(t.join(",")):$("#m_operation_skill_container").html("<span style='color:#9b9b9b;'>スキルを入力して下さい</span>")}function editProjectStationCondition(){$("#edit_project_station_condition_modal").modal("show")}function setProjectMenuItem(e,t,n,a){var r=document.getElementsByTagName("head")[0].appendChild(document.createElement("script"));r.type="text/javascript",r.charset="utf-8",0==e?($("#ps0 > option").remove(),$("#ps1 > option").remove(),$("#ps1").append($("<option>").html("----").val(0)),0==t?$("#ps0").append($("<option>").html("----").val(0)):r.src="http://www.ekidata.jp/api/p/"+t+".json"):1==e?($("#ps1 > option").remove(),0==t?$("#ps1").append($("<option>").html("----").val(0)):r.src="http://www.ekidata.jp/api/l/"+t+".json"):r.src="http://www.ekidata.jp/api/s/"+t+".json",xml.onload=function(e){var t=e.line,r=e.station_l,_=e.station;if(null!=t)for($("#ps0").append($("<option>").html("----").val(0)),i=0;i<t.length;i++){ii=i+1;var o=t[i].line_name,l=t[i].line_cd,c=$("<option>").html(o).val(l);n&&l==n&&c.prop("selected",!0),$("#ps0").append(c)}if(null!=r)for($("#ps1").append($("<option>").html("----").val(0)),i=0;i<r.length;i++){ii=i+1;var d=r[i].station_name,m=r[i].station_cd;c=$("<option>").html(d).val(m);a&&m==a&&c.prop("selected",!0),$("#ps1").append(c)}if(null!=_){var s=_[0];$("#m_project_station_cd").val(s.station_cd),$("#m_project_station_pref_cd").val(s.pref_cd),$("#m_project_station_line_cd").val(s.line_cd),$("#m_project_station_lon").val(s.lon),$("#m_project_station_lat").val(s.lat),$("#m_project_station").val(s.station_name)}}}function editEngineerStationCondition(){$("#edit_engineer_station_condition_modal").modal("show")}function setEngineerMenuItem(e,t,n,a){var r=document.getElementsByTagName("head")[0].appendChild(document.createElement("script"));r.type="text/javascript",r.charset="utf-8",0==e?($("#es0 > option").remove(),$("#es1 > option").remove(),$("#es1").append($("<option>").html("----").val(0)),0==t?$("#es0").append($("<option>").html("----").val(0)):r.src="http://www.ekidata.jp/api/p/"+t+".json"):1==e?($("#es1 > option").remove(),0==t?$("#es1").append($("<option>").html("----").val(0)):r.src="http://www.ekidata.jp/api/l/"+t+".json"):r.src="http://www.ekidata.jp/api/s/"+t+".json",xml.onload=function(e){var t=e.line,r=e.station_l,_=e.station;if(null!=t)for($("#es0").append($("<option>").html("----").val(0)),i=0;i<t.length;i++){ii=i+1;var o=t[i].line_name,l=t[i].line_cd,c=$("<option>").html(o).val(l);n&&l==n&&c.prop("selected",!0),$("#es0").append(c)}if(null!=r)for($("#es1").append($("<option>").html("----").val(0)),i=0;i<r.length;i++){ii=i+1;var d=r[i].station_name,m=r[i].station_cd;c=$("<option>").html(d).val(m);a&&m==a&&c.prop("selected",!0),$("#es1").append(c)}if(null!=_){var s=_[0];$("#m_engineer_station_cd").val(s.station_cd),$("#m_engineer_station_pref_cd").val(s.pref_cd),$("#m_engineer_station_line_cd").val(s.line_cd),$("#m_engineer_station_lon").val(s.lon),$("#m_engineer_station_lat").val(s.lat),$("#m_engineer_station").val(s.station_name)}}}function changeDemandUnit(e,t){unsaved=!0,"1"==e.value?$("#base_exc_tax_"+t).attr("readonly",!1):$("#base_exc_tax_"+t).attr("readonly",!0)}function changeDemandUnitForModal(e,t){"1"==e.value?($("#base_exc_tax_"+t).attr("readonly",!1),$(".demand_wage_area").hide()):($("#base_exc_tax_"+t).attr("readonly",!0),$(".demand_wage_area").show())}function openCalcBaseForm(e){"2"==$("#demand_unit_"+e).val()&&($("#calc_base_exc_tax_form_"+e).show(),""==$("#demand_working_time_"+e).val()&&$("#demand_working_time_"+e).val(160))}function setBaseExcTax(e){var t=$("#demand_wage_per_hour_"+e).val(),n=$("#demand_working_time_"+e).val();if(void 0!==t&&""!==t&&void 0!==n&&""!==n){t=formatForCalc(t),n=formatForCalc(n);var a=Math.round(t*n);$("#base_exc_tax_"+e).val(formatForView(a)),$("#demand_wage_per_hour_"+e).val(formatForView(t)),$("#demand_working_time_"+e).val(n),updateCalcOperationResult(e)}}function changePaymentUnit(e,t){unsaved=!0,"1"==e.value?$("#payment_base_"+t).attr("readonly",!1):$("#payment_base_"+t).attr("readonly",!0)}function changePaymentUnitForModal(e,t){"1"==e.value?($("#payment_base_"+t).attr("readonly",!1),$(".payment_wage_area").hide()):($("#payment_base_"+t).attr("readonly",!0),$(".payment_wage_area").show())}function openCalcPaymentBaseForm(e){"2"==$("#payment_unit_"+e).val()&&($("#calc_payment_base_exc_tax_form_"+e).show(),""==$("#payment_working_time_"+e).val()&&$("#payment_working_time_"+e).val(160))}function setPaymentBaseExcTax(e){var t=$("#payment_wage_per_hour_"+e).val(),n=$("#payment_working_time_"+e).val();if(void 0!==t&&""!==t&&void 0!==n&&""!==n){t=formatForCalc(t),n=formatForCalc(n);var a=Math.round(t*n);$("#payment_base_"+e).val(formatForView(a)),$("#payment_wage_per_hour_"+e).val(formatForView(t)),$("#payment_working_time_"+e).val(n),updateCalcOperationResult(e)}}function openCalcDemandTermForm(e){$("#calc_demand_term_form_"+e).show()}function openCalcPaymentTermForm(e){$("#calc_payment_term_form_"+e).show()}function openCalcAllowanceForm(e){$("#calc_allowance_form_"+e).show()}function setAllowanceHelpMessageStr(e){var t="<span style='font-size: small;color: black'>正社員、契約社員様の手当欄を入力してください。<br>従業員様の各手当項目を入力されることで一か月あたりのプロジェクト想定利益を出すことが出来ます。<br><br>会社負担保険料<br>→会社が負担している年金・保険料の合算数字を入力ください。<br><br>月額交通費<br>→従業員様にお支払している定期代、または交通費を入力ください。<br><br>賞与分割<br>→想定する賞与額を入力ください。<br>たとえば年2回賞与を支払される場合、1/6に分割した賞与額を入力頂きます。<br><br>例：30万円の賞与を夏と冬で年2回払う場合、（6＝12か月÷2）<br>5万＝30万÷6<br><br>ご不明な点ございましたらお問い合わせよりご連絡ください。<br><span>";$(".allowanceHelp").attr("data-content",t)}function setAutocompleteSite(){var e=["月末締翌月末支払","月末締翌々月10日支払","月末締翌々月15日支払","月末締翌々月20日支払","月末締翌々月25日支払","月末締翌々月末日支払","20日締翌月末日支払","20日締翌々月5日支払","20日締翌々月10日支払","20日締翌々月15日支払","20日締翌々月20日支払","20日締翌々月25日支払","20日締翌々月末日支払"];$(".autocomplete_site").autocomplete({source:e,minLength:0,select:function(e,t){}})}function setAutocompleteDemandMemo(){var e=["固定","8×稼働日-8×稼働日+20h"];$(".autocomplete_demand_memo").autocomplete({source:e,minLength:0,select:function(e,t){}})}function setAutoKana(){env.ak_new_client=new AutoKana("new_client_name","new_client_kana",{katakana:!0}),$("#new_client_name").on("blur",function(e){$("#new_client_kana").val($("#new_client_kana").val().replace("カブシキガイシャ","").replace("ユウゲンガイシャ","").replace("ゴウドウガイシャ",""))}),env.ak_client=new AutoKana("m_client_name","m_client_kana",{katakana:!0}),env.ak_worker=new AutoKana("ms_worker_name","ms_worker_kana",{katakana:!0}),$("#m_client_name").on("blur",function(e){$("#m_client_kana").val($("#m_client_kana").val().replace("カブシキガイシャ","").replace("ユウゲンガイシャ","").replace("ゴウドウガイシャ",""))}),env.ak_client=new AutoKana("m_engineer_name","m_engineer_kana",{katakana:!0})}function setDatePicker(){$("#m_engineer_birth").datepicker({weekStart:1,startView:2,viewMode:"years",language:"ja",autoclose:!0,changeYear:!0,changeMonth:!0,dateFormat:"yyyy/mm/dd"}),$("#m_engineer_operation_begin").datepicker({weekStart:1,viewMode:"dates",language:"ja",autoclose:!0,changeYear:!0,changeMonth:!0,dateFormat:"yyyy/mm/dd"}),$("#m_engineer_birth").on("hide",function(){updateAge()})}function validateCondition(e){return $("#m_project_term_begin").parent().parent().parent().parent().removeClass("has-error"),$("#m_project_term_end").parent().parent().parent().parent().removeClass("has-error"),e.term_begin&&e.term_end&&e.term_begin>e.term_end?(alert("期間の終了日付は開始日付をより後の日にしてください"),$("#m_project_term_end").focus(),$("#m_project_term_begin").parent().parent().parent().parent().addClass("has-error"),$("#m_project_term_end").parent().parent().parent().parent().addClass("has-error"),!0):($("#m_project_age_from").parent().parent().parent().parent().removeClass("has-error"),$("#m_project_age_to").parent().parent().parent().parent().removeClass("has-error"),!!(e.age_from&&e.age_to&&Number(e.age_from)>Number(e.age_to))&&(alert("年齢の最大値は最小値をより大きくしてください"),$("#m_project_age_to").focus(),$("#m_project_age_from").parent().parent().parent().parent().addClass("has-error"),$("#m_project_age_to").parent().parent().parent().parent().addClass("has-error"),!0))}function validateOperationCondition(e){return $("#m_operation_term_begin").parent().parent().parent().parent().removeClass("has-error"),$("#m_operation_term_end").parent().parent().parent().parent().removeClass("has-error"),!!(e.term_begin&&e.term_end&&e.term_begin>e.term_end)&&(alert("期間の終了日付は開始日付をより後の日にしてください"),$("#m_operation_term_end").focus(),$("#m_operation_term_begin").parent().parent().parent().parent().addClass("has-error"),$("#m_operation_term_end").parent().parent().parent().parent().addClass("has-error"),!0)}function stackUpdateEngineerClient(e,t){unsaved=!0,env.updateEngineerClientStackList=env.updateEngineerClientStackList||[];var n=e;env.updateEngineerClientStackList.some(function(e,t){e.engineer_id==n&&env.updateEngineerClientStackList.splice(t,1)});var a={engineer_id:e,client_id:t};env.updateEngineerClientStackList.push(a)}function stackUpdateEngineerChargingUser(e,t){unsaved=!0,env.updateEngineerChargingUserStackList=env.updateEngineerChargingUserStackList||[];var n=e;env.updateEngineerChargingUserStackList.some(function(e,t){e.engineer_id==n&&env.updateEngineerChargingUserStackList.splice(t,1)});var a={engineer_id:e,charging_user_id:t};env.updateEngineerChargingUserStackList.push(a)}function stackUpdateProjectChargingUser(e,t){unsaved=!0,env.updateProjectChargingUserStackList=env.updateProjectChargingUserStackList||[];var n=e;env.updateProjectChargingUserStackList.some(function(e,t){e.engineer_id==n&&env.updateProjectChargingUserStackList.splice(t,1)});var a={project_id:e,charging_user_id:t};env.updateProjectChargingUserStackList.push(a)}function showAddNewClientModal(e){c4s.clearValidate({name:"new_client_name",kana:"new_client_kana",addr_vip:"new_client_addr_vip_container",addr1:"new_client_addr1",addr2:"new_client_addr2",tel:"new_client_tel",fax:"new_client_fax",site:"new_client_site",type_presentation:"new_client_type_presentation_container"}),$("#new_client_addr1_alert").html("");var t,n=["#new_client_name","#new_client_kana","#new_client_addr_vip","#new_client_addr1","#new_client_addr2","#new_client_tel","#new_client_fax","#new_client_site","#new_client_note"],a=["#new_client_type_presentation_0","#new_client_type_presentation_1"],i=["#new_client_type_dealing","#new_client_charging_worker1","#new_client_charging_worker2"],r=[];for(t=0;t<n.length;t++)n[t]instanceof Array?$(n[t][0])[0].value=n[t][1]:$(n[t])[0].value="";for(t=0;t<a.length;t++)$(a[t])[0].checked=!1;for(t=0;t<i.length;t++)$(i[t])[0].selectedIndex=0;for(t=0;t<r.length;t++)$(r[t])[0].checked=!0;$("#new_client_charging_worker1").val(env.userProfile.user.id),$("#new_client_type_dealing")[0].selectedIndex=1,$("#add_new_client_modal").modal("show"),$("#add_new_client_mode").val(e)}function commitNewClient(){var e=genCommitValueOfNewClient(),t=c4s.validate(e,c4s.validateRules.client,{name:"new_client_name",kana:"new_client_kana",addr_vip:"new_client_addr_vip",addr1:"new_client_addr1",addr2:"new_client_addr2",tel:"new_client_tel",fax:"new_client_fax",site:"new_client_site",type_presentation:"new_client_type_presentation_container"});if(t.length)return env.debugOut(t),alert("入力を修正してください"),!1;c4s.invokeApi_ex({location:"client.createClient",body:e,onSuccess:function(t){alert("1件登録しました。"),setNewClientOption(t.data.id,e.name),$("#add_new_client_modal").modal("hide")},onError:function(e){alert("登録に失敗しました。")}})}function genCommitValueOfNewClient(){var e,t,n={},a=[["#new_client_id",Number],["#new_client_name",String,""],["#new_client_kana",String,""],["#new_client_addr_vip",String,""],["#new_client_addr1",String,""],["#new_client_addr2",String,""],["#new_client_tel",String,""],["#new_client_fax",String,""],["#new_client_site",String,""],["#new_client_note",String,""]],i=[],r=[],_=[["#new_client_type_dealing",String],["#new_client_charging_worker1",Number],["#new_client_charging_worker2",Number]],o=[];for(e=0;e<a.length;e++)t=$(a[e][0]),t.val()?n[t.attr("id").replace("new_client_","")]=a[e][1](t.val()):""===t.val()&&3==a[e].length&&(n[t.attr("id").replace("new_client_","")]=a[e][1](a[e][2]));for(e=0;e<i.length;e++)t=$(i[e][0]),""!==t.val()&&(n[t.attr("id").replace("new_client_","")]=i[e][1](t.val()));for(e=0;e<r.length;e++)t=$(r[e][0]),n[t.attr("id").replace("new_client_","")]=r[e][1](t[0].checked);for(e=0;e<_.length;e++)t=$(_[e][0]),n[t.attr("id").replace("new_client_","")]=_[e][1](t.val());for(e=0;e<o.length;e++)t=$(o[e][0]),n[t.attr("name").replace("new_client_","").split("_")[0]]=o[e][1](t.val());return n.charging_worker1=n.charging_worker1||null,n.charging_worker2=n.charging_worker2||null,n.addr_vip&&(n.addr_vip=n.addr_vip.replace("-","")),n.type_presentation=[],$("[id^=new_client_type_presentation_]").each(function(e,t){t.checked&&n.type_presentation.push(t.value)}),env.debugOut(n),n}function setNewClientOption(e,t){var n=$("#add_new_client_mode").val();switch($("#m_project_client_id").append('<option value="'+e+'">'+t+"</option>"),$("#m_engineer_client_id").append('<option value="'+e+'">'+t+"</option>"),$("#m_operation_update_engineer_client_id").append('<option value="'+e+'">'+t+"</option>"),n){case"engineer":$("#m_engineer_client_id").val(e),$("#m_engineer_client_id").select2({allowClear:!0});break;case"project":$("#m_project_client_id").val(e),$("#m_project_client_id").select2();break;case"operation":$("#m_operation_update_engineer_client_id").val(e),$("#m_operation_update_engineer_client_id").select2({allowClear:!0})}}function triggerSearch(){$("#modal-confirm-unsaved").modal("hide"),updateObject(triggerLeave,null),unsaved=!1,updateObject(c4s.hdlClickSearchBtn,null)}function triggerSearchClear(){$("#modal-confirm-unsaved").modal("hide"),updateObject(triggerLeave,null),unsaved=!1,updateObject(c4s.hdlClickGnaviBtn,env.current)}function confirmAccountFlgPublic(e){var t=!1;return e&&!env.companyInfo.flg_public&&confirm("貴社アカウントでマッチング用公開設定が非公開になっているため、このままでは他社に公開されません。\n合わせて公開設定に変更しますか。")&&(t=!0),t}function updateAccountFlgPublic(e){var t={value:1};t.prefix=env.prefix,c4s.invokeApi_ex({location:"manage.updateFlgPublic",body:t,onSuccess:function(t){alert("更新しました"),e&&e()}})}function overwriteModalForEditEngineer(e){$("#commitNewEngineerObjMode").val("NormalCreate"),c4s.clearValidate({client_id:"m_engineer_client_id",client_name:"m_engineer_client_name",name:"m_engineer_name",kana:"m_engineer_kana",visible_name:"m_engineer_visible_name",tel:"m_engineer_tel",mail1:"m_engineer_mail1",mail2:"m_engineer_mail2",birth:"m_engineer_birth",age:"m_engineer_age",gender:"m_engineer_gender_container",state_work:"m_engineer_state_work",fee:"m_engineer_fee",station:"m_engineer_station",skill:"m_engineer_skill",note:"m_engineer_note",charging_user_id:"m_engineer_charging_user_id",employer:"m_engineer_employer",operation_begin:"m_engineer_operation_begin",addr_vip:"m_engineer_addr_vip",addr1:"m_engineer_addr1",addr2:"m_engineer_addr2"});var t=[["id","#m_engineer_id"],["client_name","#m_engineer_client_name"],["name","#m_engineer_name"],["kana","#m_engineer_kana"],["visible_name","#m_engineer_visible_name"],["tel","#m_engineer_tel"],["mail1","#m_engineer_mail1"],["mail2","#m_engineer_mail2"],["age","#m_engineer_age"],["fee_comma","#m_engineer_fee"],["station","#m_engineer_station"],["note","#m_engineer_note"],["skill","#m_engineer_skill"],["state_work","#m_engineer_state_work"],["employer","#m_engineer_employer"],["operation_begin","#m_engineer_operation_begin"],["station_cd","#m_engineer_station_cd"],["station_pref_cd","#m_engineer_station_pref_cd"],["station_line_cd","#m_engineer_station_line_cd"],["station_lon","#m_engineer_station_lon"],["station_lat","#m_engineer_station_lat"],["addr_vip","#m_engineer_addr_vip"],["addr1","#m_engineer_addr1"],["addr2","#m_engineer_addr2"]],n=[["birth","#m_engineer_birth"]],a=[["flg_caution","#m_engineer_flg_caution"],["flg_registered","#m_engineer_flg_registered"],["flg_assignable","#m_engineer_flg_assignable"],["flg_public","#m_engineer_flg_public"],["web_public","#m_engineer_web_public"]],i=[["contract","#m_engineer_contract"],["client_id","#m_engineer_client_id"]],r=[["gender","[name=m_engineer_gender_grp]"]];c4s.invokeApi("engineer.enumEngineers",{id:Number(e)},function(e){if(env.recentAjaxResult=e,e&&e.status&&e.data&&0==e.status.code&&e.data instanceof Array&&e.data[0]){var _,o=e.data[0];for(_=0;_<t.length;_++)o[t[_][0]]?$(t[_][1])[0].value=o[t[_][0]]:$(t[_][1]).val("");for(_=0;_<n.length;_++)o[n[_][0]]?$(n[_][1]).datepicker("setValue",o[n[_][0]]):$(n[_][1]).val(null);for(_=0;_<a.length;_++)$(a[_][1])[0].checked=o[a[_][0]];for(_=0;_<i.length;_++)$(i[_][1])[0].selectedIndex=0,$(i[_][1])[0].value=o[i[_][0]];for(_=0;_<r.length;_++)$(r[_][1]).each(function(e,t){t.value===o[r[_][0]]&&(t.checked=!0)});o.charging_user&&o.charging_user.id&&$("#m_engineer_charging_user_id").val(o.charging_user.id),$("input[type=checkbox][id^=m_engineer_skill_]").each(function(e,t){tgtSkillDict[t.id.replace("m_engineer_skill_","")]?t.checked=!0:t.checked=!1}),$('[name="m_engineer_skill[]"]').each(function(e,t){t.checked=!1}),$('[name="m_engineer_skill_level[]"]').each(function(e,t){t.selectedIndex=0}),$('[name="m_engineer_skill_level[]"]').addClass("hidden"),$('[name="m_engineer_occupation[]"]').each(function(e,t){t.checked=!1}),o.skill_id_list&&$('[name="m_engineer_skill[]"]').each(function(e){var t=$(this).val(),n=o.skill_id_list.split(",");n.indexOf(t)>=0&&($(this).val([t]),$("#m_engineer_skill_level_"+t).removeClass("hidden"),o.skill_level_list.forEach(function(e,n,a){t==e.skill_id&&$("#m_engineer_skill_level_"+t).val(e.level)}))}),viewSelectedEngineerSkill(),o.occupation_id_list&&$('[name="m_engineer_occupation[]"]').each(function(e){var t=$(this).val(),n=o.occupation_id_list.split(",");n.indexOf(t)>=0&&$(this).val([t])}),o.age||updateAge(),$("#attachment_id_0").val(o.attachement&&o.attachement.id?o.attachement.id:null);var l=$("#attachment_file_0"),c=$("#attachment_id_0"),d=$("#attachment_label_0"),m=$("#attachment_btn_commit_0"),s=$("#attachment_btn_delete_0");if(o.attachement){var p=o.attachement;l.val(null),c.val(p.id),l.css("display","none"),d.html(p.name+"&nbsp;(<span class='mono'>"+p.size+"bytes</span>)"),d.css("display","inline"),m.css("display","inline"),s.css("display","inline")}else l.val(null),l.css("display","inline"),c.val(null),d.html(""),d.css("display","none"),m.css("display","none"),s.css("display","none");o.dt_created&&($("#m_engineer_dt_created").text(o.dt_created.substr(0,10)),$("#m_engineer_dt_created").parent().css("display","block")),o.station_pref_cd&&o.station_line_cd&&o.station_cd&&($("#es").val(o.station_pref_cd),setEngineerMenuItem(0,o.station_pref_cd,o.station_line_cd,o.station_cd),setEngineerMenuItem(1,o.station_line_cd,o.station_line_cd,o.station_cd)),$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>要員編集</span>")),$("#edit_engineer_modal").modal("show"),$("#m_engineer_client_id").select2({allowClear:!0})}})}function triggerUpdateEngineerObj(){updateObject(updateEngineerObj,null)}function updateEngineerObj(){var e,t=env.recentAjaxResult.data[0],n=genCommitValueOfEngineer(),a={};for(e in n)void 0!==t[e]&&n[e]!=t[e]&&(a[e]=n[e]);n.charging_user_id&&(a.charging_user_id=n.charging_user_id),a.id=Number($("#m_engineer_id").val()),n.skill_id_list&&(a.skill_id_list=n.skill_id_list,a.skill_level_list=n.skill_level_list),n.occupation_id_list&&(a.occupation_id_list=n.occupation_id_list);var i=c4s.validate(a,c4s.validateRules.engineer,{client_id:"m_engineer_client_id",client_name:"m_engineer_client_name",name:"m_engineer_name",kana:"m_engineer_kana",visible_name:"m_engineer_visible_name",tel:"m_engineer_tel",mail1:"m_engineer_mail1",mail2:"m_engineer_mail2",birth:"m_engineer_birth",age:"m_engineer_age",gender:"m_engineer_gender_container",state_work:"m_engineer_state_work",fee:"m_engineer_fee",station:"m_engineer_station",skill:"m_engineer_skill",note:"m_engineer_note",employer:"m_engineer_employer",operation_begin:"m_engineer_operation_begin"});if(i.length)return env.debugOut(i),void alert("入力を修正してください");c4s.invokeApi_ex({location:"engineer.updateEngineer",body:a,onSuccess:function(e){alert("1件更新しました。");var t=confirmAccountFlgPublic(a.flg_public),n=function(){$("#edit_engineer_modal").data("commitCompleted",!0),$("#edit_engineer_modal").modal("hide"),c4s.hdlClickSearchBtn()};t?updateAccountFlgPublic(n):n()},onError:function(e){alert("更新に失敗しました。（"+e.status.description+"）")}})}function overwriteModalForEditProject(e){c4s.clearValidate({id:"m_project_id",client_id:"m_project_client_id",client_name:"m_project_client_name",title:"m_project_title",term:"m_project_term",term_begin:"m_project_term_begin",term_end:"m_project_term_end",age_from:"m_project_age_from",age_to:"m_project_age_to",fee_inbound:"m_project_fee_inbound",fee_outbound:"m_project_fee_outbound",expense:"m_project_expense",process:"m_project_process",interview:"m_project_interview_container",station:"m_project_station_container",scheme:"m_project_scheme_container",skill_needs:"m_project_skill_needs",skill_recommends:"m_project_skill_recommends",rank_id:"m_project_rank_container"});var t=[["id","#m_project_id"],["client_name","#m_project_client_name"],["fee_inbound_comma","#m_project_fee_inbound"],["fee_outbound_comma","#m_project_fee_outbound"],["expense","#m_project_expense"],["title","#m_project_title"],["process","#m_project_process"],["interview","#m_project_interview"],["station","#m_project_station"],["note","#m_project_note"],["term","#m_project_term"],["term_begin","#m_project_term_begin"],["term_end","#m_project_term_end"],["age_from","#m_project_age_from"],["age_to","#m_project_age_to"],["skill_needs","#m_project_skill_needs"],["skill_recommends","#m_project_skill_recommends"],["station_cd","#m_project_station_cd"],["station_pref_cd","#m_project_station_pref_cd"],["station_line_cd","#m_project_station_line_cd"],["station_lon","#m_project_station_lon"],["station_lat","#m_project_station_lat"]],n=[],a=[["flg_shared","#m_project_flg_shared"],["flg_public","#m_project_flg_public"],["web_public","#m_project_web_public"]],i=[["scheme","#m_project_scheme"],["charging_user_id","#m_project_charging_user_id"]],r=[["rank_id","[name=m_project_rank_grp]"]];c4s.invokeApi("project.enumProjects",{id:Number(e)},function(e){if(env.recentAjaxResult=e,e&&e.status&&e.data&&0==e.status.code&&e.data instanceof Array&&e.data[0]){var _,o=e.data[0];for(o.client_id=o.client&&o.client.id||null,o.charging_user_id=o.charging_user.id,_=0;_<t.length;_++)$(t[_][1])[0].value=o[t[_][0]]||"";for(_=0;_<n.length;_++)o[n[_][0]]?$(n[_][1]).datepicker("setValue",o[n[_][0]]):$(n[_][1]).val(null);for(_=0;_<a.length;_++)$(a[_][1])[0].checked=o[a[_][0]];for(_=0;_<i.length;_++)$(i[_][1])[0].selectedIndex=0,$(i[_][1]+" option").each(function(e,t){String(o[i[_][0]])==t.value&&(t.selected=!0)});for(_=0;_<r.length;_++)$(r[_][1]).each(function(e,t){t.value==o[r[_][0]]&&(t.checked=!0)});o.client_id&&($("#m_project_client_id").val(o.client_id),$("#m_project_client_name").val(o.client.name)),o.dt_created&&($("#m_project_dt_created").text(o.dt_created.substr(0,10)),$("#m_project_dt_created").parent().css("display","block")),$('[name="m_project_skill[]"]').each(function(e,t){t.checked=!1}),$('[name="m_project_skill_level[]"]').each(function(e,t){t.selectedIndex=0}),$('[name="m_project_skill_level[]"]').addClass("hidden"),$('[name="m_project_occupation[]"]').each(function(e,t){t.checked=!1}),o.skill_id_list&&$('[name="m_project_skill[]"]').each(function(e){var t=$(this).val(),n=o.skill_id_list.split(",");n.indexOf(t)>=0&&($(this).val([t]),$("#m_project_skill_level_"+t).removeClass("hidden"),o.skill_level_list.forEach(function(e,n,a){t==e.skill_id&&$("#m_project_skill_level_"+t).val(e.level)}))}),viewSelectedProjectSkill(),o.occupation_id_list&&$('[name="m_project_occupation[]"]').each(function(e){var t=$(this).val(),n=o.occupation_id_list.split(",");n.indexOf(t)>=0&&$(this).val([t])}),o.station_pref_cd&&o.station_line_cd&&o.station_cd&&($("#ps").val(o.station_pref_cd),setProjectMenuItem(0,o.station_pref_cd,o.station_line_cd,o.station_cd),setProjectMenuItem(1,o.station_line_cd,o.station_line_cd,o.station_cd)),$("#m_project_worker_container").removeClass("hidden"),$("#edit_project_modal_title").html("案件編集"),$("#edit_project_modal").modal("show"),$("#m_project_client_id").select2()}})}function overwriteClientModalForEdit(e){c4s.clearValidate({name:"m_client_name",kana:"m_client_kana",addr_vip:"m_client_addr_vip",addr1:"m_client_addr1",addr2:"m_client_addr2",tel:"m_client_tel",fax:"m_client_fax",site:"m_client_site",type_presentation:"m_client_type_presentation_container"}),$("#m_client_addr1_alert").html("");var t=[["id","#m_client_id"],["name","#m_client_name"],["kana","#m_client_kana"],["addr_vip","#m_client_addr_vip"],["addr1","#m_client_addr1"],["addr2","#m_client_addr2"],["tel","#m_client_tel"],["fax","#m_client_fax"],["site","#m_client_site"],["note","#m_client_note"]],n=[],a=[["type_presentation_0","#m_client_type_presentation_0"],["type_presentation_1","#m_client_type_presentation_1"]],i=[["type_dealing","#m_client_type_dealing"],["charging_worker_1_id","#m_client_charging_worker1"],["charging_worker_2_id","#m_client_charging_worker2"]],r=[];c4s.invokeApi("client.enumClients",{id:Number(e)},function(_){if($("#m_client_branch_container").css("display","inline"),$("#m_client_worker_container").css("display","inline"),env.recentAjaxResult=_,_&&_.status&&_.data&&0==_.status.code&&_.data instanceof Array&&_.data[0]){var o,l=_.data[0];for(l.site=""!=l.site&&"null"!=l.site&&l.site?l.site:"",l.type_presentation_0=!!(l.type_presentation&&l.type_presentation.join("").indexOf("案件")>-1),l.type_presentation_1=!!(l.type_presentation&&l.type_presentation.join("").indexOf("人材")>-1),l.charging_worker_1_id=l.charging_worker1?l.charging_worker1.id:null,l.charging_worker_2_id=l.charging_worker2?l.charging_worker2.id:null,o=0;o<t.length;o++)$(t[o][1])[0].value=l[t[o][0]]||"";for(o=0;o<n.length;o++)$(n[o][1]).datepicker("setValue",l[n[o][0]]);for(o=0;o<a.length;o++)$(a[o][1])[0].checked=l[a[o][0]];for(o=0;o<i.length;o++)$(i[o][1])[0].selectedIndex=0,$(i[o][1]+" option").each(function(e,t){String(l[i[o][0]])==t.value&&(t.selected=!0)})
;for(o=0;o<r.length;o++)$(r[o][1]).each(function(e,t){t.value===l[r[o][0]]&&(t.checked=!0)});c4s.invokeApi_ex({location:"client.enumBranches",body:{client_id:e},onSuccess:function(t){var n;if($("#m_client_branch_table tbody tr").remove(),t&&t.data&&t.data instanceof Array&&t.data.length>0)for(n=0;n<t.data.length;n++){var a=$("<tr></tr>");if(a.appendTo("#m_client_branch_table tbody"),$("<td class='center'><span class='glyphicon glyphicon-pencil text-success pseudo-link-cursor' title='編集' onclick='overwriteBranchModalForEdit("+e+", "+t.data[n].id+");'></span></td>").appendTo(a),$("<td></td>").text(t.data[n].name).appendTo(a),$("<td></td>").text("〒"+t.data[n].addr_vip+" "+t.data[n].addr1+" "+t.data[n].addr2).appendTo(a),env.limit.LMT_ACT_MAP)if(env.limit.LMT_CALL_MAP_EXTERN_M>env.mapLimit||0==env.limit.LMT_CALL_MAP_EXTERN_M){var i={target_id:t.data[n].id,target_type:"branch",name:t.data[n].name,addr1:t.data[n].addr1,addr2:t.data[n].addr2,tel:t.data[n].tel,modalId:"edit_client_modal",isFloodLMT:!1,current:env.current};for(var r in i)i[r]="string"==typeof i[r]?i[r].replace('"',""):i[r];var _=$("<td></td>").attr("class","center").css("width","35px"),o=$("<span></span>").attr("class","glyphicon glyphicon-globe text-success pseudo-link-cursor").bind("click",function(e){return function(){c4s.openMap(e)}}(i));o.appendTo(_),_.appendTo(a)}else{_=$("<td></td>").attr("class","center").css("width","35px"),o=$("<span></span>").attr("class","glyphicon glyphicon-globe text-muted pseudo-link-cursor").bind("click",function(){c4s.openMap({isFloodLMT:!0})});o.appendTo(_),_.appendTo(a)}$("<td class='center'>"+(t.data[n].tel&&""!==t.data[n].tel?"<span class='glyphicon glyphicon-phone-alt'></span>&nbsp;<a href='tel:"+t.data[n].tel.replace(/-/g,"")+"'>"+t.data[n].tel+"</a>":"")+(t.data[n].fax&&""!==t.data[n].fax?"<br/><span class='glyphicon glyphicon-print'></span>&nbsp;"+t.data[n].fax:"")+"</td>").appendTo(a)}else $("#m_client_branch_container")[0].style.display="none"}}),$("#m_client_worker_table tbody tr").remove(),$("#m_client_worker_container")[0].style.display="none",c4s.invokeApi_ex({location:"client.enumWorkers",body:{client_id:e},onSuccess:function(e){if(e&&e.data&&e.data instanceof Array&&e.data.length>0){var t;for(t=0;t<e.data.length;t++){var n=$("<tr id='iter_worker_sm_"+e.data[t].id+"'/>");n.appendTo("#m_client_worker_table tbody"),(e.data[t].mail1||e.data[t].mail2)&&e.data[t].flg_sendmail?$("<td class='center'><input type='checkbox' id='iter_mailto_worker_"+e.data[t].id+"'/></td>").appendTo(n):$("<td></td>").appendTo(n),$("<td><img src='/img/icon/key_man.jpg' title='キーマン'"+(e.data[t].flg_keyperson?"":" style='visibility: hidden;'")+"/>&nbsp;<span class='pseudo-link' onclick='overwriteWorkerModalForEdit("+e.data[t].id+");'>"+e.data[t].name+"</span></td>").appendTo(n),$("<td class='center'>"+(e.data[t].tel&&""!==e.data[t].tel?"<a href='tel:"+e.data[t].tel.replace(/-/g,"")+"'>"+e.data[t].tel+"</a>":"")+"</td>").appendTo(n),$("<td class=''>"+(e.data[t].mail1?env.limit.LMT_ACT_MAIL?"&nbsp;<span onclick='triggerMailOnClientModal(["+e.data[t].id+"]);'><span class='glyphicon glyphicon-envelope text-warning pseudo-link-cursor'></span>&nbsp;<span class='pseudo-link'>"+e.data[t].mail1+"</span></span>":"&nbsp;"+e.data[t].mail1:"")+"</td>").appendTo(n),$("<td class='center'><span class='glyphicon glyphicon-trash text-danger pseudo-link-cursor' title='削除' onclick='c4s.hdlClickDeleteItem(\"worker_sm\", "+e.data[t].id+", true);'></span></td>").appendTo(n)}$("#m_client_worker_container")[0].style.display="block"}else $("#m_client_worker_container")[0].style.display="none"}}),$("#edit_client_modal_title").replaceWith($("<span id='edit_client_modal_title'>取引先編集</span>")),$("#edit_client_modal").modal("show")}})}function genCommitValueOfClient(){var e,t,n={},a=[["#m_client_id",Number],["#m_client_name",String,""],["#m_client_kana",String,""],["#m_client_addr_vip",String,""],["#m_client_addr1",String,""],["#m_client_addr2",String,""],["#m_client_tel",String,""],["#m_client_fax",String,""],["#m_client_site",String,""],["#m_client_note",String,""]],i=[],r=[],_=[["#m_client_type_dealing",String],["#m_client_charging_worker1",Number],["#m_client_charging_worker2",Number]],o=[];for(e=0;e<a.length;e++)t=$(a[e][0]),t.val()?n[t.attr("id").replace("m_client_","")]=a[e][1](t.val()):""===t.val()&&3==a[e].length&&(n[t.attr("id").replace("m_client_","")]=a[e][1](a[e][2]));for(e=0;e<i.length;e++)t=$(i[e][0]),""!==t.val()&&(n[t.attr("id").replace("m_client_","")]=i[e][1](t.val()));for(e=0;e<r.length;e++)t=$(r[e][0]),n[t.attr("id").replace("m_client_","")]=r[e][1](t[0].checked);for(e=0;e<_.length;e++)t=$(_[e][0]),n[t.attr("id").replace("m_client_","")]=_[e][1](t.val());for(e=0;e<o.length;e++)t=$(o[e][0]),n[t.attr("name").replace("m_client_","").split("_")[0]]=o[e][1](t.val());return n.charging_worker1=n.charging_worker1||null,n.charging_worker2=n.charging_worker2||null,n.addr_vip&&(n.addr_vip=n.addr_vip.replace("-","")),n.type_presentation=[],$("[id^=m_client_type_presentation_]").each(function(e,t){t.checked&&n.type_presentation.push(t.value)}),env.debugOut(n),n}function triggerCommitClient(){updateObject(commitClient,null)}function commitClient(e){var t=genCommitValueOfClient(),n=c4s.validate(t,c4s.validateRules.client,{name:"m_client_name",kana:"m_client_kana",addr_vip:"m_client_addr_vip",addr1:"m_client_addr1",addr2:"m_client_addr2",tel:"m_client_tel",fax:"m_client_fax",site:"m_client_site",type_presentation:"m_client_type_presentation_container"});if(n.length)return env.debugOut(n),alert("入力を修正してください"),!1;c4s.invokeApi_ex({location:e?"client.updateClient":"client.createClient",body:t,onSuccess:function(t){alert(e?"1件更新しました。":"1件登録しました。");var n,a={};for(n in env.recentQuery)"id"!==n&&(a[n]=env.recentQuery[n]);$("#edit_client_modal").data("commitCompleted",!0),$("#edit_client_modal").modal("hide"),c4s.hdlClickSearchBtn()},onError:function(t){alert(e?"更新に失敗しました。":"登録に失敗しました。")}})}function hdlClickAddWorkerBtn(e){var t=genCommitValueOfClient(),n=c4s.validate(t,c4s.validateRules.client,{name:"m_client_name",kana:"m_client_kana",addr_vip:"m_client_addr_vip_container",addr1:"m_client_addr1",addr2:"m_client_addr2",tel:"m_client_tel",fax:"m_client_fax",site:"m_client_site",type_presentation:"m_client_type_presentation_container"});if(n.length)return env.debugOut(n),alert("入力を修正してください"),!1;c4s.invokeApi_ex({location:e?"client.updateClient":"client.createClient",body:t,onSuccess:function(t){$("#ms_client_id").val(t.data.id),$("#ms_worker_id").val(e),overwriteWorkerModalForEdit()}})}function hdlClickAddBranchBtn(e){var t=genCommitValueOfClient(),n=c4s.validate(t,c4s.validateRules.client,{name:"m_client_name",kana:"m_client_kana",addr_vip:"m_client_addr_vip_container",addr1:"m_client_addr1",addr2:"m_client_addr2",tel:"m_client_tel",fax:"m_client_fax",site:"m_client_site",type_presentation:"m_client_type_presentation_container"});if(n.length)return env.debugOut(n),alert("入力を修正してください"),!1;c4s.invokeApi_ex({location:e?"client.updateClient":"client.createClient",body:t,onSuccess:function(e){$("#m_client_id").val(e.data.id),overwriteBranchModalForEdit(e.data.id)}})}function hdlClickAddMoreWorkerBtn(e){var t=genCommitValueOfWorker();e||delete t.id;var n=c4s.validate(t,c4s.validateRules.worker,{id:"ms_worker_id",client_id:"ms_worker_client_id",name:"ms_worker_name",kana:"ms_worker_kana",section:"ms_worker_section",title:"ms_worker_title",tel:"ms_worker_tel",tel2:"ms_worker_tel2",mail1:"ms_worker_mail1",mail2:"ms_worker_mail2",flg_keyperson:"ms_worker_misc_container",flg_sendmail:"ms_worker_misc_container",recipient_priority:"ms_worker_misc_container"});if(n.length)return env.debugOut(n),void alert("入力を修正してください");e?c4s.invokeApi_ex({location:"client.updateWorker",body:t,onSuccess:function(e){alert("1件更新しました"),overwriteClientModalForEdit(t.client_id),overwriteWorkerModalForEdit()},onError:function(e){alert("更新に失敗しました")}}):c4s.invokeApi_ex({location:"client.createWorker",body:t,onSuccess:function(e){alert("1件登録しました"),overwriteClientModalForEdit(t.client_id),overwriteWorkerModalForEdit()},onError:function(e){alert("登録に失敗しました")}})}function overwriteBranchModalForEdit(e,t){c4s.clearValidate({id:"m_branch_id",client_id:"m_branch_client_id",name:"m_branch_name",addr_vip:"m_branch_addr_vip",addr1:"m_branch_addr1",addr2:"m_branch_addr2",tel:"m_branch_tel",fax:"m_branch_fax"});var n,a=[["id","#m_branch_id"],["client_id","#m_branch_client_id"],["client_name","#m_branch_client_name"],["name","#m_branch_name"],["addr_vip","#m_branch_addr_vip"],["addr1","#m_branch_addr1"],["addr2","#m_branch_addr2"],["tel","#m_branch_tel"],["fax","#m_branch_fax"]],i=[],r=[],_=[],o=[];if(t)c4s.invokeApi_ex({location:"client.enumBranches",body:{client_id:e},onSuccess:function(e){if(e&&e.data&&e.data instanceof Array&&e.data.length>0){var n=e.data.filter(function(e,n,a){return e.id==t})[0];for(l=0;l<a.length;l++)$(a[l][1])[0].value=n[a[l][0]]||"";for(l=0;l<i.length;l++)$(i[l][1]).datepicker("setValue",n[i[l][0]]);for(l=0;l<r.length;l++)$(r[l][1])[0].checked=n[r[l][0]];for(l=0;l<_.length;l++)$(_[l][1]+" option").each(function(e,t){String(n[_[l][0]])==t.value&&(t.selected=!0)});for(l=0;l<o.length;l++)$(o[l][1]).each(function(e,t){t.value===n[o[l][0]]&&(t.checked=!0)});$("#edit_branch_modal_title").replaceWith($("<span id='edit_branch_modal_title'>取引先支店編集</span>")),$("#edit_branch_modal").modal("show")}}});else{var l;for(n={client_id:e,client_name:$("#m_client_name").val()},l=0;l<a.length;l++)$(a[l][1])[0].value=n[a[l][0]]||"";for(l=0;l<i.length;l++)$(i[l][1]).datepicker("setValue",n[i[l][0]]);for(l=0;l<r.length;l++)$(r[l][1])[0].checked=n[r[l][0]];for(l=0;l<_.length;l++)$(_[l][1]+" option").each(function(e,t){String(n[_[l][0]])==t.value&&(t.selected=!0)});for(l=0;l<o.length;l++)$(o[l][1]).each(function(e,t){t.value===n[o[l][0]]&&(t.checked=!0)});$("#m_branch_addr1_alert").html(""),$("#m_branch_client_id").val($("#m_client_id").val()),$("#edit_branch_modal_title").replaceWith($("<span id='edit_branch_modal_title'>取引先支店新規追加</span>")),$("#edit_branch_modal").modal("show")}}function genCommitValueOfBranch(){var e,t,n={},a=[["#m_branch_id",Number],["#m_branch_client_id",Number],["#m_branch_name",String],["#m_branch_addr_vip",String],["#m_branch_addr1",String],["#m_branch_addr2",String,""],["#m_branch_tel",String,""],["#m_branch_fax",String,""]],i=[],r=[],_=[],o=[];for(e=0;e<a.length;e++)t=$(a[e][0]),n[t.attr("id").replace("m_branch_","")]=a[e][1](t.val());for(e=0;e<i.length;e++)t=$(i[e][0]),""!==t.val()&&(n[t.attr("id").replace("m_branch_","")]=i[e][1](t.val()));for(e=0;e<r.length;e++)t=$(r[e][0]),n[t.attr("id").replace("m_branch_","")]=r[e][1](t[0].checked);for(e=0;e<_.length;e++)t=$(_[e][0]),n[t.attr("id").replace("m_branch_","")]=_[e][1](t.val());for(e=0;e<o.length;e++)t=$(o[e][0]),n[t.attr("name").replace("m_branch_","").split("_")[0]]=o[e][1](t.val());return n.addr_vip&&(n.addr_vip=n.addr_vip.replace("-","")),env.debugOut(n),n}function triggerCommitBranch(e){updateObject(commitBranch,e)}function commitBranch(e){var t=genCommitValueOfBranch();!0!==e&&(e=!1,delete t.id);var n=c4s.validate(t,c4s.validateRules.branch,{id:"m_branch_id",client_id:"m_branch_client_id",name:"m_branch_name",addr_vip:"m_branch_addr_vip",addr1:"m_branch_addr1",addr2:"m_branch_addr2",tel:"m_branch_tel",fax:"m_branch_fax"});if(n.length)return env.debugOut(n),void alert("入力を修正してください");c4s.invokeApi_ex({location:e?"client.updateBranch":"client.createBranch",body:t,onSuccess:function(n){alert(e?"1件更新しました。":"1件登録しました。"),$("#edit_branch_modal").modal("hide"),overwriteClientModalForEdit(t.client_id)},onError:function(t){alert(e?"更新に失敗しました。":"登録に失敗しました。")}})}function overwriteWorkerModalForEdit(e){e=Number(e),c4s.clearValidate({id:"ms_worker_id",client_id:"ms_worker_client_id",name:"ms_worker_name",kana:"ms_worker_kana",section:"ms_worker_section",title:"ms_worker_title",tel:"ms_worker_tel",tel2:"ms_worker_tel2",mail1:"ms_worker_mail1",mail2:"ms_worker_mail2",flg_keyperson:"ms_worker_misc_container",flg_sendmail:"ms_worker_misc_container",recipient_priority:"ms_worker_misc_container"});var t,n,a=[["id","#ms_worker_id"],["name","#ms_worker_name"],["kana","#ms_worker_kana"],["client_name","#ms_worker_client_name"],["client_id","#ms_worker_client_id"],["section","#ms_worker_section"],["title","#ms_worker_title"],["tel","#ms_worker_tel"],["tel2","#ms_worker_tel2"],["mail1","#ms_worker_mail1"],["mail2","#ms_worker_mail2"],["note","#ms_worker_note"],["recipient_priority","#ms_worker_recipient_priority",5]],i=[["flg_keyperson","#ms_worker_flg_keyperson",!1],["flg_sendmail","#ms_worker_flg_sendmail",!0]],r=[];if($("#ms_worker_id").val(e),e)c4s.invokeApi_ex({location:"client.enumWorkers",body:{id:e},onSuccess:function(e){for(n=e.data[0],t=0;t<a.length;t++)$(a[t][1]).val(n[a[t][0]]);for(t=0;t<i.length;t++)$(i[t][1])[0].checked=n[i[t][0]];$("#ms_client_id").val(n.client_id),$("#ms_worker_client_name").val(n.client_name),$("#ms_worker_id").val(n.id),$("#ms_worker_recipient_priority").val(n.recipient_priority),$("#edit_worker_modal_title").replaceWith($("<span id='edit_worker_modal_title'>取引先担当者編集</span>")),$("#edit_worker_modal").modal("show")}});else{for(t=0;t<a.length;t++)$(a[t][1]).val("");for(t=0;t<i.length;t++)$(i[t][1])[0].checked=i[t][2];for(t=0;t<r.length;t++)$(r[t][1]+" option").each(function(e,t){t.value===env.login_id?t.selected=!0:t.selected=!1});$("#ms_worker_client_id").val($("#m_client_id").val()),$("#ms_client_id").val(null),$("#ms_worker_client_name").val($("#m_client_name").val()),$("#ms_worker_tel2").val($("#ms_worker_tel2").val()||$("#m_client_tel").val()),$("#ms_worker_recipient_priority").val(5),$("#edit_worker_modal_title").replaceWith($("<span id='edit_worker_modal_title'>新規取引先担当者</span>")),$("#edit_worker_modal").modal("show")}}function genCommitValueOfWorker(){var e,t,n={},a=[["id","#ms_worker_id",Number,null],["name","#ms_worker_name",String],["kana","#ms_worker_kana",String],["section","#ms_worker_section",String,""],["title","#ms_worker_title",String,""],["tel","#ms_worker_tel",String,""],["tel2","#ms_worker_tel2",String,""],["mail1","#ms_worker_mail1",String,""],["mail2","#ms_worker_mail2",String,""],["note","#ms_worker_note",String],["client_id","#ms_worker_client_id",Number],["recipient_priority","#ms_worker_recipient_priority",Number,5]],i=[["flg_keyperson","#ms_worker_flg_keyperson",!1],["flg_sendmail","#ms_worker_flg_sendmail",!0]];for(e=0;e<a.length;e++)t=$(a[e][1]).val(),n[a[e][0]]=a[e][2](t);for(e=0;e<i.length;e++)t=$(i[e][1])[0].checked,n[i[e][0]]=t;return n}function triggerCommitWorkerObj(e){updateObject(commitWorkerObj,e)}function commitWorkerObj(e){var t=genCommitValueOfWorker();isNaN(e)&&(delete t.id,e=null);var n=c4s.validate(t,c4s.validateRules.worker,{id:"ms_worker_id",client_id:"ms_worker_client_id",name:"ms_worker_name",kana:"ms_worker_kana",section:"ms_worker_section",title:"ms_worker_title",tel:"ms_worker_tel",tel2:"ms_worker_tel2",mail1:"ms_worker_mail1",mail2:"ms_worker_mail2",flg_keyperson:"ms_worker_misc_container",flg_sendmail:"ms_worker_misc_container",recipient_priority:"ms_worker_misc_container"});if(n.length)return env.debugOut(n),void alert("入力を修正してください");e?c4s.invokeApi_ex({location:"client.updateWorker",body:t,onSuccess:function(e){alert("1件更新しました"),$("#edit_client_modal").data("commitCompleted",!0),$("#edit_worker_modal").modal("hide"),overwriteClientModalForEdit(t.client_id)},onError:function(e){alert("更新に失敗しました")}}):c4s.invokeApi_ex({location:"client.createWorker",body:t,onSuccess:function(e){alert("1件登録しました"),$("#edit_client_modal").data("commitCompleted",!0),$("#edit_worker_modal").modal("hide"),overwriteClientModalForEdit(t.client_id)},onError:function(e){alert("登録に失敗しました")}})}function triggerMailOnClientModal(e){updateObject(sendMailOnClientModal,e)}function sendMailOnClientModal(e){if(env.records.LMT_LEN_MAIL_PER_MONTH>env.limit.LMT_LEN_MAIL_PER_MONTH&&0!=env.limit.LMT_LEN_MAIL_PER_MONTH)$("#alert_cap_mail_modal").modal("show");else{var t={type_recipient:"forWorker",recipients:{engineers:[],workers:[]}};e?t.recipients.workers=e:$("[id^=iter_mailto_worker_]").each(function(e,n,a){n.checked&&t.recipients.workers.push(Number(n.id.replace("iter_mailto_worker_","")))}),0==t.recipients.workers.length?alert("対象データを選択してください。"):c4s.invokeApi_ex({location:"mail.createMail",body:t,pageMove:!0,newPage:!0})}}function hdlClickNewOperationObj(){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide"),$("#m_operation_project").val(""),$("#m_operation_engineer").val(""),c4s.clearValidate({term_begin:"m_operation_term_begin",term_end:"m_operation_term_end",term_memo:"m_operation_term_memo",transfer_member:"m_operation_transfer_member",contract_date:"m_operation_contract_date",demand_site:"m_operation_demand_site",payment_site:"m_operation_payment_site",other_memo:"m_operation_other_memo",base_exc_tax:"base_exc_tax_0",demand_wage_per_hour:"demand_wage_per_hour_0",demand_working_time:"demand_working_time_0",settlement_from:"settlement_from_0",settlement_to:"settlement_to_0",deduction:"deduction_0",excess:"excess_0",payment_base:"payment_base_0",payment_wage_per_hour:"payment_wage_per_hour_0",payment_working_time:"payment_working_time_0",payment_settlement_from:"payment_settlement_from_0",payment_settlement_to:"payment_settlement_to_0",payment_deduction:"payment_deduction_0",payment_excess:"payment_excess_0",welfare_fee:"welfare_fee_0",transportation_fee:"transportation_fee_0",bonuses_division:"bonuses_division_0"});var e,t=["#m_operation_term_begin","#m_operation_term_end","#m_operation_term_memo","#m_operation_transfer_member","#m_operation_contract_date","#m_operation_demand_site","#m_operation_payment_site","#m_operation_other_memo","#base_exc_tax_0","#demand_wage_per_hour_0","#demand_working_time_0","#settlement_from_0","#settlement_to_0","#deduction_0","#excess_0","#payment_base_0","#payment_wage_per_hour_0","#payment_working_time_0","#payment_settlement_from_0","#payment_settlement_to_0","#payment_deduction_0","#payment_excess_0","#welfare_fee_0","#transportation_fee_0","#bonuses_division_0","#m_operation_project_client_id","#m_operation_update_engineer_client_id"],n=["#m_operation_is_active"],a=["#m_operation_is_fixed"],i=["#demand_unit_0","#payment_unit_0","#settlement_unit_0","#payment_settlement_unit_0"],r=[];for(e=0;e<t.length;e++)t[e]instanceof Array?$(t[e][0])[0].value=t[e][1]:$(t[e])[0].value="";for(e=0;e<n.length;e++)$(n[e])[0].checked=!0;for(e=0;e<a.length;e++)$(a[e])[0].checked=!1;for(e=0;e<i.length;e++)$(i[e])[0].selectedIndex=0;for(e=0;e<r.length;e++)$(r[e])[0].checked=!0;$('[name="m_operation_skill[]"]').each(function(e,t){t.checked=!1}),$('[name="m_operation_skill_level[]"]').each(function(e,t){t.selectedIndex=0}),viewSelectedOperationSkill(),$("#base_inc_tax_0_label").empty(),$("#payment_inc_tax_0_label").empty(),$("#gross_profit_0_label").empty(),$("#gross_profit_rate_0_label").empty(),$("#gross_profit_rate_0_label").html("　　　"),$('#m_operation_engineer_charging_user_id option[selected="selected"]').each(function(){$(this).removeAttr("selected")}),$("#m_operation_engineer_charging_user_id option:first").attr("selected","selected"),$('#m_operation_project_charging_user_id option[selected="selected"]').each(function(){$(this).removeAttr("selected")}),$("#m_operation_project_charging_user_id option:first").attr("selected","selected");var _=new Date,o=_.getFullYear(),l=_.getMonth()+1,c=_.getDate(),d=("0"+l).slice(-2),m=("0"+c).slice(-2);$("#m_operation_contract_date").datepicker("setDate",o+"/"+d+"/"+m),$("#settlement_unit_0").val(2),$("#payment_settlement_unit_0").val(2),$("#m_operation_update_engineer_contract").val("パートナー"),changeCalcFormArea("パートナー"),$("#edit_operation_modal_title").html("新規稼働登録"),$("#edit_operation_modal").modal("show"),$("#m_operation_project_client_id").select2(),$("#m_operation_update_engineer_client_id").select2({allowClear:!0}),viewSettlementMiniArea(0),viewPaymentSettlementMiniArea(0),viewDemandMemoArea(0),viewPaymentMemoArea(0)}function genCommitValueOfOperation(){var e=getInputValueOperationObj(0);$("#m_operation_id").val()&&(e.id=Number($("#m_operation_id").val())),e.project_client_id=Number($("#m_operation_project_client_id").val()),e.project_id=Number($("#m_operation_project").val()),e.engineer_id=Number($("#m_operation_engineer").val()),e.engineer_client_id=Number($("#m_operation_update_engineer_client_id").val());var t,n,a=[["#m_operation_project_name",String],["#m_operation_engineer_name",String],["#m_operation_transfer_member",String],["#m_operation_term_memo",String],["#m_operation_demand_site",String],["#m_operation_payment_site",String],["#m_operation_other_memo",String]],i=[["#m_operation_term_begin",String],["#m_operation_term_end",String],["#m_operation_contract_date",String]],r=[],_=[],o=[];for(t=0;t<a.length;t++)n=$(a[t][0]),e[n.attr("id").replace("m_operation_","")]=a[t][1](n.val());for(t=0;t<i.length;t++)n=$(i[t][0]),""!==n.val()?e[n.attr("id").replace("m_operation_","")]=i[t][1](n.val()):e[n.attr("id").replace("m_operation_","")]=null;for(t=0;t<r.length;t++)n=$(r[t][0]),e[n.attr("id").replace("m_operation_","")]=r[t][1](n[0].checked);for(t=0;t<_.length;t++)n=$(_[t][0]),e[n.attr("id").replace("m_operation_","")]=_[t][1](n.val());for(t=0;t<o.length;t++)n=$(o[t][0]),e[n.attr("name").replace("m_operation_","").split("_")[0]]=o[t][1](n.val());return e.is_active=$("#m_operation_is_active").is(":checked")?1:0,e.is_fixed=$("#m_operation_is_fixed").is(":checked")?1:0,e}function triggerCommitOperationObject(){updateObject(commitOperationObject,null)}function commitOperationObject(e){e=!1;var t=genCommitValueOfOperation(),n=c4s.validate(t,c4s.validateRules.operation,{project_client_id:"m_operation_project_client_id",project_name:"m_operation_project_name",engineer_name:"m_operation_engineer_name",term_begin:"m_operation_term_begin",term_end:"m_operation_term_end",is_active:"m_operation_is_active",is_fixed:"m_operation_is_fixed",base_exc_tax:"base_exc_tax_0",demand_wage_per_hour:"demand_wage_per_hour_0",demand_working_time:"demand_working_time_0",settlement_from:"settlement_from_0",settlement_to:"settlement_to_0",deduction:"deduction_0",excess:"excess_0",payment_base:"payment_base_0",payment_wage_per_hour:"payment_wage_per_hour_0",payment_working_time:"payment_working_time_0",payment_settlement_from:"payment_settlement_from_0",payment_settlement_to:"payment_settlement_to_0",payment_deduction:"payment_deduction_0",payment_excess:"payment_excess_0",welfare_fee:"welfare_fee_0",transportation_fee:"transportation_fee_0",bonuses_division:"bonuses_division_0",transfer_member:"m_operation_transfer_member",contract_date:"m_operation_contract_date",demand_site:"m_operation_demand_site",payment_site:"m_operation_payment_site",other_memo:"m_operation_other_memo",engineer_client_id:"m_operation_update_engineer_client_id"});if(n.length)return env.debugOut(n),void alert("入力を修正してください");if(!validateOperationCondition(t)){var a=function(n,a){c4s.invokeApi_ex({location:e?"operation.updateOperation":"operation.createOperation",body:t,onSuccess:function(t){alert(e?"1件更新しました。":"1件登録しました。");var n=function(){$("#focus_new_record").val(1),c4s.hdlClickSearchBtn()};n()},onError:function(t){alert((e?"更新":"登録")+"に失敗しました（"+t.status.description+"）")}})},i=function(e,n){var a={},i="project.updateProject";a.id=t.project_id,a.title=t.project_name,a.charging_user_id=$("#m_operation_project_charging_user_id").val(),a.update_data_and_skill_only=!0,a.skill_level_list=[],a.needs=$('[name="m_operation_skill[]"]:checked').map(function(){var e=$(this).val(),t=$("#m_operation_skill_level_"+e).val();return""!=t&&a.skill_level_list.push({id:e,level:t}),e}).get(),0==a.id&&(i="project.createProject",delete a.id,a.age_from=22,a.age_to=65,a.client_id=t.project_client_id,a.expense="",a.fee_inbound=0,a.fee_outbound=0,a.flg_public=!1,a.web_public=!1,a.flg_shared=!1,a.interview=1,a.process="",a.rank_id=1,a.scheme="エンド",a.station_cd="",a.station_lat=0,a.station_line_cd="",a.station_lon=0,a.station_pref_cd=""),c4s.invokeApi_ex({location:i,body:a,onSuccess:function(a){a&&a.data&&a.data.id&&(t.project_id=a.data.id),e(n)},onError:function(e){alert("案件の更新に失敗しました（"+e.status.description+"）")}})},r=function(e,n){var a={},i="engineer.updateEngineer";a.id=t.engineer_id,a.name=t.engineer_name,""!=$("#m_operation_update_engineer_client_id").val()&&(a.client_id=$("#m_operation_update_engineer_client_id").val()),a.contract=$("#m_operation_update_engineer_contract").val(),a.charging_user_id=$("#m_operation_engineer_charging_user_id").val(),a.update_data_only=!0,0==a.id&&(i="engineer.createEngineer",delete a.id,a.client_name="",a.fee=0,a.flg_assignable=!1,a.flg_caution=!1,a.flg_public=!1,a.web_public=!1,a.flg_registered=!0,a.gender="男",a.kana="",a.mail1="",a.station_cd="",a.station_lat=0,a.station_line_cd="",a.station_lon=0,a.station_pref_cd="",a.tel="",a.visible_name=""),c4s.invokeApi_ex({location:i,body:a,onSuccess:function(a){a&&a.data&&a.data.id&&(t.engineer_id=a.data.id),e(n)},onError:function(e){alert("要員の更新に失敗しました（"+e.status.description+"）")}})};i(r,a)}}function searchZip2Addr(e,t,n){var a=e.replace("-","");if(a.match(/[^0-9]+/))alert("半角数値(0〜9)と半角のハイフン(-)のみ利用できます");else{var i=$(t),r=$(n);a&&i.length>0&&c4s.invokeApi_ex({location:"zip.search",body:{code:a},onSuccess:function(t){t.data.addr1?(i.val(t.data.addr1),r.html("")):r.html("該当する住所はありませんでした（"+e+"）")},onError:function(e){r.html("検索でエラーが発生しました")}})}}function changeCalcFormArea(e){$("#calc_payment_term_form_area_0").removeClass("hidden"),$("#calc_allowance_form_area_0").removeClass("hidden"),"正社員"==e||"契約社員"==e?$("#calc_payment_term_form_area_0").addClass("hidden"):$("#calc_allowance_form_area_0").addClass("hidden"),updateGrossProfit(0)}function changeCalcFormAreaWithIndex(e,t,n){unsaved=!0,$("#calc_payment_term_form_area_"+n).removeClass("hidden"),$("#calc_allowance_form_area_"+n).removeClass("hidden"),"正社員"==t||"契約社員"==t?$("#calc_payment_term_form_area_"+n).addClass("hidden"):$("#calc_allowance_form_area_"+n).addClass("hidden"),updateGrossProfit(n),env.updateEngineerContractStackList=env.updateEngineerContractStackList||[];var a=e;env.updateEngineerContractStackList.some(function(e,t){e.engineer_id==a&&env.updateEngineerContractStackList.splice(t,1)});var i={engineer_id:e,contract:t};env.updateEngineerContractStackList.push(i)}function setMtClients(e){var t=$("#engineer_client_select_"+e+" > option:selected").val();if($("#engineer_client_select_"+e+" > option").remove(),env.data.clients){var n="";for(var a in env.data.clients)n+="<option value='"+env.data.clients[a].id+"'>"+env.data.clients[a].name+"</option>";$("#engineer_client_select_"+e).append(n)}""!=t.trim()&&$("#engineer_client_select_"+e).val(t),$("#engineer_client_select_"+e).select2()}function addComma(e){var t=$(e).val();void 0!==t&&""!==t&&(t=formatForCalc(t),$(e).val(formatForView(t)))}function triggerLeave(){}$("#m_operation_contract_date, #m_operation_term_begin, #m_operation_term_end, #query_term_begin, #query_term_end, #query_term_begin_exp, #query_term_end_exp, [id^=term_begin], [id^=term_end], [id^=contract_date_], [id^=cutoff_date_]").datepicker({weekStart:1,viewMode:"dates",language:"ja",autoclose:!0,changeYear:!0,changeMonth:!0,dateFormat:"yyyy/mm/dd"}),$("#query_contract_month").datepicker({startView:1,viewMode:"months",minViewMode:"months",language:"ja",autoclose:!0,changeYear:!0,changeMonth:!0,dateFormat:"yyyy/mm"});var xml={};$("#m_project_term_begin, #m_project_term_end, #m_engineer_operation_begin").datepicker({weekStart:1,viewMode:"dates",language:"ja",autoclose:!0,changeYear:!0,changeMonth:!0,dateFormat:"yyyy/mm/dd"}),$(function(){$(".input-file").on("change",function(){var e=$(this).prop("files")[0].name;""!=e?$(".input-file-message").addClass("hidden"):$(".input-file-message").removeClass("hidden")})}),c4s.jumpToPagination=function(e){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide");var t=function(){c4s.jumpToPage(env.current,{pageNumber:e,query:genFilterQuery()})};updateObject(t,null)},c4s.hdlClickGnaviBtn=function(e,t){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide");var n,a=$("<form/>")[0],i=$("<input type='hidden' name='json'/>")[0],r={login_id:env.login_id,credential:env.credential};if("matching.project"!=e&&"matching.engineer"!=e||c4s.loadSearchConditionFromCookie(r,e),t)for(n in t)r[n]=t[n];a.appendChild(i),a.action="/"+[env.prefix,"html",e].join("/")+"/",a.method="POST",a.enctype="application/x-www-form-urlencoded",i.value=JSON.stringify(r),$("body").append(a),a.submit()},c4s.jumpToPage=function(e,t){updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide"),t=t||{};var n=t.query||{};t.tab&&(n.ctrl_selectedTab=t.tab),n.ctrl_referer={path:env.current,tab:env.currentTab||t.currentTab||null,modal:env.currentModal||t.currentModal||null,query:env.recentQuery},n.ctrl_referer.query&&n.ctrl_referer.query.login_id&&delete n.ctrl_referer.query.login_id,n.ctrl_referer.query&&n.ctrl_referer.query.credential&&delete n.ctrl_referer.query.credential,n.ctrl_referer.query&&n.ctrl_referer.query.ctrl_referer&&delete n.ctrl_referer.query.ctrl_referer,t.pageNumber?n.pageNumber=t.pageNumber:n.pageNumber=1,t.modal&&(n.ctrl_referer.modal=t.modal),c4s.invokeApi_ex({location:e,body:n,pageMove:!0})},c4s.searchAll=function(e){return updateObject(triggerLeave,null),unsaved=!1,$("#modal-confirm-unsaved").modal("hide"),c4s.invokeApi_ex({location:"home.search",body:{word:e},pageMove:!0}),!1},$(function(){$("#btn-confirm-unsaved").on("click",function(){updateObject(triggerLeave,null),unsaved=!1,"new_operation"==$("#before_action").val()&&hdlClickNewOperationObj(),"trigger_estimate"==$("#before_action").val()&&triggerCreateQuotationEstimate(),"trigger_order"==$("#before_action").val()&&triggerCreateQuotationOrder(),"trigger_purchase"==$("#before_action").val()&&triggerCreateQuotationPurchase(),"trigger_invoice"==$("#before_action").val()&&triggerCreateQuotationInvoice(),"trigger_search"==$("#before_action").val()&&triggerSearch(),"trigger_search_clear"==$("#before_action").val()&&triggerSearchClear(),"jump_page"==$("#before_action").val()&&c4s.jumpToPagination(parseInt($("#page_number").val())),"click_gnavi"==$("#before_action").val()&&c4s.hdlClickGnaviBtn($("#loc").val(),null),"logout"==$("#before_action").val()&&c4s.jumpToPage("auth.logout",null),"search_all"==$("#before_action").val()&&c4s.searchAll($("#all_search_ipt").val(),null)})}),$(document).on("click",".video-operation-new",function(){c4s.hdlClickVideoBtn("operaion_new")}),$(document).on("click",".video-operation-quotation",function(){c4s.hdlClickVideoBtn("operaion_quotation")});
$(document).ready(function () {
    $(".popover-video").popover({ trigger: "manual" , html: true, animation:false})
        .on("mouseenter", function () {
            var _this = this;
            $(this).popover("show");
            $(".popover").on("mouseleave", function () {
                $(_this).popover('hide');
            });
        }).on("mouseleave", function () {
            var _this = this;
            setTimeout(function () {
                if (!$(".popover:hover").length) {
                    $(_this).popover("hide");
                }
            }, 500);
    });

    row_length = {{ data['operation.enumOperations']|length }};
    for(var i = 1; i <= row_length; i++){
        try{
            updateCalcOperationResult(i);
            viewDemandMemoArea(i);
            viewPaymentMemoArea(i);
        }
        catch (e){

        }
    }

	env.data = env.data || {};
	env.userProfile = JSON.parse('{{ data['auth.userProfile']|tojson }}');
    env.data.clients = JSON.parse(escapeSpecialChars('{{ data['client.enumClients']|tojson }}'));
	{#
	env.data.workers = JSON.parse('{{ data['client.enumWorkers']|tojson }}');
	env.data.projects = JSON.parse('{{ data['project.enumProjects']|tojson }}');
	env.data.engineers = JSON.parse('{{ data['engineer.enumEngineers']|tojson }}');
	#}
    unsaved = false;

    function escapeSpecialChars(jsonString) {
        return jsonString.replace(/\n/g, "\\n")
            .replace(/\r/g, "\\r")
            .replace(/\t/g, "\\t")
            .replace(/\f/g, "\\f");

    }

	$("#edit_engineer_modal").on("hide.bs.modal", function () {
		$("#m_engineer_dt_created").parent().css("display", "none");
	});

	$("#modal_query_flg_assignable").prop("checked", true);

	env.addNewColumnNo = 1;

    env.data.clients_compact = JSON.parse('{{ data['js.clients']|tojson }}');
	$("#m_project_client_name").autocomplete({
		source: env.data.clients_compact,
		select: function (evt, itemDict) {
			env.debugOut(itemDict);
			if (itemDict.item) {
				$("#m_project_client_id").val(itemDict.item.id);
			} else {
				$("#m_project_client_id").val(null);
			}
		},
	});
	$("#m_engineer_client_name").autocomplete({
		source: env.data.clients_compact,
		select: function (evt, itemDict) {
			env.debugOut(itemDict);
			if (itemDict.item) {
				$("#m_engineer_client_id").val(itemDict.item.id);
			} else {
				$("#m_engineer_client_id").val(null);
			}
		},
	});

	if(env.recentQuery.focus_new_record){
	    $("#detail-table-body tr:first-child").css("background-color","rgba(3, 169, 244, 0.15);");
	    $("#detail-table-body tr:first-child input[id^=base_exc_tax_]").focus();
    }

    $(".engineer_client_select").select2();

	function splitByLength(str, length) {
        var resultArr = [];
        if (!str || !length || length < 1) {
            return resultArr;
        }
        var index = 0;
        var start = index;
        var end = start + length;
        while (start < str.length) {
            resultArr[index] = str.substring(start, end);
            index++;
            start = end;
            end = start + length;
        }
        return resultArr;
    }

    $(".project_client_name").each(function (idx, el, arr) {
        var str = $(this).text();
        var tmpArrStr = splitByLength(str, 10);
        str = tmpArrStr.join('<br/>');
        $(this).html(str);
    });
	$(".project_title").each(function (idx, el, arr) {
        var str = $(this).text();
        var tmpArrStr = splitByLength(str, 10);
        str = tmpArrStr.join('<br/>');
        $(this).html(str);
    });
	$(".engineer_name").each(function (idx, el, arr) {
        var str = $(this).text();
        var tmpArrStr = splitByLength(str, 6);
        str = tmpArrStr.join('<br/>');
        $(this).html(str);
    });
    $(".charging_user_name").each(function (idx, el, arr) {
        var str = $(this).text();
        var tmpArrStr = splitByLength(str, 6);
        str = tmpArrStr.join('<br/>');
        $(this).html(str);
    });
    $(".engineer_charging_user_name").each(function (idx, el, arr) {
        var str = $(this).text();
        var tmpArrStr = splitByLength(str, 6);
        str = tmpArrStr.join('<br/>');
        $(this).html(str);
    });

    setAutoKana();
    setAutocompleteSite();
    setAutocompleteDemandMemo();
    setAllowanceHelpMessageStr();
    setDatePicker();

    c4s.invokeApi_ex({
        location: "operation.enumOperationsSummary",
        body: genFilterQuery(),
        onSuccess: function (res) {
            if (res.data.length > 0) {
                $('#summary_count').html(res.data[0].count);
                $('#summary_base_exc_tax').html(res.data[0].base_exc_tax);
                $('#summary_gross_profit').html(res.data[0].gross_profit);
                $('#summary_gross_profit_rate').html(res.data[0].gross_profit_rate);
                $('#summary_fix_count').html(res.data[0].fix_count);
                $('#summary_fix_base_exc_tax').html(res.data[0].fix_base_exc_tax);
                $('#summary_fix_gross_profit').html(res.data[0].fix_gross_profit);
                $('#summary_fix_gross_profit_rate').html(res.data[0].fix_gross_profit_rate);
            }
        },
    });
    $('#detail-table-body input').each(function() {
        $(this).on('change', function() {
            unsaved = true;
        })
    })
});
$(function(){
	var $child = $(".fixed_table");
	var $parent = $child.parent().parent();
    {% if data['operation.enumOperations'] %}
        {% set FIXED_TABLE_VIEW_MAX = 8 %}
        {% if items|length < FIXED_TABLE_VIEW_MAX %}
                {% set ADJUST_COUNT = FIXED_TABLE_VIEW_MAX - items|length %}
                {% if ADJUST_COUNT > 4 %}
                    {% set ADJUST_COUNT = 4 %}
                {% endif %}
        {% else %}
                {% set ADJUST_COUNT = 1 %}
        {% endif %}
    {% else %}
        {% set ADJUST_COUNT = 10 %}
{% endif %}

    $('#row-table').css('overflow-x', 'hidden');
    {% if data['operation.enumOperations'] %}
        $('.fixed_table table').tablefix({width: $parent.width(), height: window.innerHeight-(100 * {{ ADJUST_COUNT }}), fixRows: 1, fixCols: 6});
    {% endif %}
});
		</script>
	</body>
</html>
