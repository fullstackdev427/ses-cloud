{% import "cmn_controls.macro" as buttons -%}
{% set contracts = ("正社員(契約社員)", "個人事業主", "パートナー") -%}
{% set pagenates = ("100", "200", "500", "all") -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body >
{% include "cmn_header.tpl" %}
<!-- メインコンテンツ -->
	<div class="row">
		<div class="container" style="margin-bottom:100px;">
			<!-- 検索フォーム -->
			<div class="row">
				<div class="col-sm-2">
					<img alt="注文書" width="22" height="20" src="/img/icon/group_case.png"> 注文書 一覧
				</div>
			</div>
			<div class="row" style="/*background-color: #f1f1f1;*/">
				<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
					<!--input type="submit" style="display: none;"/-->
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
                        <li style="margin: 0 2em; float: left;">
							<label for="query_addr_name" style="color: #666666;">顧客名</label>
							<input type="text" id="query_addr_name" value="{{ query.addr_name|e }}"/>
						</li>
						<li style="margin: 0 2em; float: left;">
							<label for="query_quotation_name" style="color: #666666;">件名</label>
							<input type="text" id="query_quotation_name" value="{{ query.quotation_name|e }}"/>
						</li>
                        <li style="margin: 0 2em; float: left;">
                            <label for="query_charging_user_name" style="color: #666666;">営業担当</label>
                            <input type="text" id="query_charging_user_name" value="{{ query.charging_user_name|e }}"/>
                        </li>
                        <li style="margin: 0 2em; float: left;">
							<label for="query_quotation_month" style="color: #666666;">注文月</label>
							<input type="text" id="query_quotation_month" value="{{ query.quotation_month|e }}" data-date-format="yyyy/mm"/>
                        </li>
                        <li style="margin: 0 2em; float: left;">
                            <label for="query_office_memo" style="color: #666666;">社内メモ</label>
                            <input type="text" id="query_office_memo" value="{{ query.office_memo|e }}"/>
                        </li>
					</ul>
					<div style="margin-top: 1em; text-align:right;">
						{{ buttons.search("c4s.hdlClickSearchBtn();") }}
						{{ buttons.clear("c4s.hdlClickGnaviBtn(env.current);") }}
					</div>
				</form>

			</div>

			<!-- /検索フォーム -->
			<!-- 検索結果ヘッダー -->
			<div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-7">
                    <span class="btn" onclick="triggerCreateQuotationPurchase()">新規作成&nbsp;<span class="glyphicon glyphicon-plus-sign"></span></span>
				</div>
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['purchase.enumPurchases']) }}
				<!-- /件数 -->
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class=" table" >
				<table class="table view_table table-bordered">
					<thead>
						<tr>
{#							<th style="width: 35px;">選択<br/><input type="checkbox" id="iter_estimate_selected_cb_0" onclick="c4s.toggleSelectAll('iter_operation_selected_cb_', this);"/></th>#}
                            <th>注文書出力/編集</th>
                            <th>{{ buttons.th(query, '注文番号', 'quotation_no') }}</th>
                            <th>{{ buttons.th(query, '顧客名（仕入先企業）', 'addr_name') }}</th>
{#                            <th>{{ buttons.th(query, '注文案件', 'project_title') }}</th>#}
                            <th>{{ buttons.th(query, '件名', 'quotation_name') }}</th>
                            <th>{{ buttons.th(query, '金額', 'total_including_tax') }}</th>
                            <th>{{ buttons.th(query, '注文日', 'quotation_date') }}</th>
                            <th>{{ buttons.th(query, '営業担当', 'charging_user_id') }}</th>
                            <th>{{ buttons.th(query, '作成者', 'creator_id') }}</th>
                            <th>{{ buttons.th(query, '作成日時', 'dt_created') }}</th>
                            <th>送付</th>
                            <th>コピー</th>
                            <th>削除</th>
						</tr>
					</thead>
					<tbody>
                    {% if data['purchase.enumPurchases'] %}
						{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
						{% set items = data['purchase.enumPurchases'][row_min:row_min + env.limit.ROW_LENGTH] %}
						{% for item in items %}
                        <tr id="iter_{{ item.id }}">
{#                            <td class="text-center">#}
{#                                <input type="checkbox" id="iter_estimate_selected_cb_{{ item.id }}" value=""/>#}
{#                            </td>#}
                            <td style="text-align: center">
                                <span class="pseudo-link-cursor glyphicon glyphicon-file text-primary" alt="　注文書出力/編集" title="注文書出力/編集"
									onclick="editQuotation({{ item.id|e }},{{ item.project_id|e }});"></span>
                            </td>
                            <td style="text-align: right">{% if item.quotation_no %}{{ item.quotation_no }}{% endif %}</td>
                            <td>
                                {% if item.addr_name %}{{ item.addr_name}}{% endif %}
                            </td>
{#                            <td>{{ item.project_title }}</td>#}
                            <td>
                                {% if item.quotation_name %}{{ item.quotation_name }}{% endif %}
                                {% if item.office_memo %}
                                    <img class="pseudo-link-cursor"
                                         src="/img/icon/memo.png"
                                         style="height: 1em;width: 1em"
                                         data-toggle="popover"
                                         data-placement="right"
                                         data-html="true"
                                         data-content="&lt;span style='font-size: 12px;'&gt;{{ item.office_memo|e|replace("&", "&amp;")|replace("\n", "<br/>") }}&lt;/span&gt;"
                                         onmouseover="$(this).popover('show');"
                                         onmouseout="$(this).popover('hide');"
                                         onclick="">&nbsp;</img>
                                {% endif %}
                            </td>
                            <td style="text-align: right">{{ item.subtotal }}</td>
                            <td style="text-align: center">{% if item.quotation_date %}{{ item.quotation_date }}{% endif %}</td>
                            <td style="text-align: center">{{ item.charging_user.user_name|e }}</td>
                            <td style="text-align: center">{{ item.creator.user_name|e }}</td>
                            <td style="text-align: center">{{ item.dt_created|e }}</td>
                            <td style="text-align: center">
                                {% if item.is_send %}
                                    <span class="pseudo-link-cursor  text-primary" alt="未送付に更新します" title="未送付に更新します"
									onclick="updateQuotationIsSend({{ item.id }}, 0);">済</span>
                                {% else %}
                                    <span class="pseudo-link-cursor  text-primary" alt="送付済に更新します" title="送付済に更新します"
									onclick="updateQuotationIsSend({{ item.id }}, 1);">未</span>
                                {% endif %}
                            </td>
                            <td style="text-align: center">
                                <span class="pseudo-link-cursor glyphicon glyphicon-file text-primary" alt="コピー" title="コピー"
									onclick="copyQuotation({{ item.id|e }},{{ item.project_id|e }});"></span>
                            </td>
                            <td class="center">
								<span class="pseudo-link-cursor glyphicon glyphicon-trash text-danger" alt="削除" title="削除"
									onclick="deleteQuotation({{ item.id }});"></span>
							</td>
                        </tr>
                        {% endfor %}
					{% else %}
						<tr id="iter_estimate_0">
							<td colspan="14">有効なデータがありません</td>
						</tr>
					{% endif %}
					</tbody>
				</table>
			</div>
			<!-- /検索結果 -->
			<div class="row" style="margin-top: 0.5em;">
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['purchase.enumPurchases']) }}
				<!-- /件数 -->
			</div>
		</div>
	</div>
<!-- /メインコンテンツ -->

{% include "cmn_cap_mail_per_month.tpl" %}
{% include "cmn_cap.tpl" %}
<!-- [end] Model. -->
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script src="/js/jquery.autokana.js" type="text/javascript"></script>
		<script src="/js/jquery-ui.js" type="text/javascript"></script>
		<script src="/js/bootstrap-datepicker.js" type="text/javascript"></script>
<script src="/js/bootstrap-datepicker.ja.js" type="text/javascript"></script>
        <script type="text/javascript" src="/js/purchase.js"></script>
		<script type="text/javascript">
$(document).ready(function () {

    row_length = {{ env.limit.ROW_LENGTH }};

	env.data = env.data || {};
	env.userProfile = JSON.parse('{{ data['auth.userProfile']|tojson }}');
    if(env.recentQuery.focus_new_record_id){
	    var focus_id = env.recentQuery.focus_new_record_id;
	    $("#iter_" + focus_id).css("background-color","rgba(3, 169, 244, 0.15);");
    }

});
		</script>
	</body>
</html>