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



		


<script type="text/javascript" src="/js/operation.min.js"></script>
<script type="text/javascript">
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
