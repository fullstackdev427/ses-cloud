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
					<img alt="請求書" width="22" height="20" src="/img/icon/group_case.png"> 請求書 一覧
				</div>
				<div class="col-sm-4">
					<span class="popover-video"
                        data-toggle="popover"
                        data-placement="right"
                        data-content="<a href='#' style='font-weight: bold' class='video-estimate-new-1'>請求書新規作成①</a><br /><a href='#' style='font-weight: bold' class='video-estimate-new-2'>請求書新規作成②</a><br /><a href='#' style='font-weight: bold' class='video-estimate-form'>帳票設定</a>"
                        data-html="true"><a href="#" style="font-weight: bold" onclick="c4s.hdlClickDirectionBtn('home.direction');">解説動画はコチラ≫</a>
                    </span>
				</div>
			</div>

            <div class="row">
							<div class="col-sm-3 col-sm-push-9" style="padding-right:0px;">
									<table class="table table-condensed" style="background-color: #f1f1f1; color: #666666;border: 1px solid #ddd;">
											<thead>
													<tr>
															<th class="text-center" style="border-right: 2px solid #ddd;font-weight: bold;"></th>
															<th class="text-center" >件数</th>
															<th class="text-center" >売上</th>
													</tr>
											</thead>
											<tbody>
													<tr>
															<td class="text-center" style="border-right: 2px solid #ddd;font-weight: bold;">稼働</td>
															<td id="summary_count" class="text-center" style="background-color: #ffffff;">{{ data['invoice.count'] }}</td>
															<td id="summary_base_exc_tax" class="text-center" style="background-color: #ffffff;">{{ data['invoice.total'] }}</td>
													<tr>
											</tbody>
									</table>
							</div>

								<form onsubmit="c4s.hdlClickSearchBtn(); return false;">
									<div class="col-sm-9 col-sm-pull-3" style="background-color: #f1f1f1;padding-left:0px;padding-right:0px;">
										<!--input type="submit" style="display: none;"/-->
										<div class="col-lg-4" style="padding-left:0px!important; padding-right:0px!important;">
											<ul style="padding-inline-start: 0px!important; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
	                                            <li style="float: left;">
                                                    <label for="query_client_name" style="color: #666666;padding-right:20px">顧客名</label>
                                                    <input type="text" id="query_client_name" value="{{ query.client_name|e }}"/>
												</li>
						                        <li style="float: left;">
													<label for="query_quotation_month" style="color: #666666;padding-right:20px;">請求月</label>
													<input type="text" id="query_quotation_month" value="{{ query.quotation_month|e }}" data-date-format="yyyy/mm"/>
												</li>
											</ul>
										</div>
										<div class="col-lg-4" style="padding-left:0px!important; padding-right:0px!important;">
											<ul style="padding-inline-start: 0px!important; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
												<li style="float: left;">
													<label for="query_name" style="color: #666666;padding-right:28px;">件名</label>
													<input type="text" id="query_quotation_name" value="{{ query.quotation_name|e }}"/>
												</li>
						                        <li style="float: left;">
						                            <label for="query_office_memo" style="color: #666666;padding-right:10x">社内メモ </label>
						                            <input type="text" id="query_office_memo" value="{{ query.office_memo|e }}"/>
						                        </li>
											</ul>
										</div>
                                        <div class="col-lg-4" style="padding-left:0px!important; padding-right:0px!important;">
											<ul style="padding-inline-start: 0px!important; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
						                        <li style="float: left;">
													<label for="query_charging_user_name" style="color: #666666;padding-right:10px">営業担当</label>
													<input type="text" id="query_charging_user_name" value="{{ query.charging_user_name|e }}" />                                               
												</li>
											</ul>
										</div>

									</div>
									<div class="col-sm-6" style="margin-top:0 px;">
										<div style="margin-top: 1em; text-align:right;">
						{{ buttons.search("c4s.hdlClickSearchBtn();") }}
						{{ buttons.clear("c4s.hdlClickClearInvoiceBtn(env.current);") }}
										</div>
									</div>
								</form>

			</div>

			<!-- /検索フォーム -->
			<!-- 検索結果ヘッダー -->
			<div class="row" style="margin-top:20px;margin-bottom:20px;">
				<div class="col-lg-7">
                    <span class="btn" onclick="triggerCreateQuotationInvoice()">新規作成&nbsp;<span class="glyphicon glyphicon-plus-sign"></span></span>
					<span class="btn" onclick="triggerExportExcel()">エクスポート&nbsp;</span>
				</div>
				<!-- 件数 -->
				{{ buttons.paging(query, env, data['invoice.enumInvoices']) }}
				<!-- /件数 -->
			</div>
			<!-- /検索結果ヘッダー -->
			<!-- 検索結果 -->
			<div class=" table" >
				<table class="table view_table table-bordered">
					<thead>
						<tr>
							<th style="width: 35px;">選択<br/><input type="checkbox" id="iter_estimate_selected_cb_0" onclick="c4s.toggleSelectAll('iter_estimate_selected_cb_', this);"/></th>
                            <th>請求書出力/編集</th>
                            <th>{{ buttons.th(query, '請求番号', 'quotation_no') }}</th>
                            <th>{{ buttons.th(query, '顧客名（請求先企業）', 'client_name') }}</th>
{#                            <th>{{ buttons.th(query, '請求案件', 'project_title') }}</th>#}
                            <th>{{ buttons.th(query, '件名', 'quotation_name') }}</th>
                            <th>{{ buttons.th(query, '金額', 'total_including_tax') }}</th>
                            <th>{{ buttons.th(query, '請求日', 'quotation_date') }}</th>
                            <th>{{ buttons.th(query, '営業担当', 'charging_user_id') }}</th>
                            <th>{{ buttons.th(query, '作成者', 'creator_id') }}</th>
                            <th>{{ buttons.th(query, '作成日時', 'dt_created') }}</th>
                            <th>送付</th>
                            <th>コピー</th>
                            <th>削除</th>
						</tr>
					</thead>
					<tbody>
                    {% if data['invoice.enumInvoices'] %}
						{% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
						{% set items = data['invoice.enumInvoices'][row_min:row_min + env.limit.ROW_LENGTH] %}
						{% for item in items %}
                        <tr id="iter_{{ item.id }}">
                           	<td class="text-center">
                               <input type="checkbox" id="iter_estimate_selected_cb_{{ item.id }}" value=""/>
                            </td>
                            <td style="text-align: center">
                                <span class="pseudo-link-cursor glyphicon glyphicon-file text-primary" alt="　請求書出力/編集" title="請求書出力/編集"
									onclick="editQuotation({{ item.id|e }},{{ item.project_id|e }});"></span>
                            </td>
                            <td style="text-align: right">{% if item.quotation_no %}{{ item.quotation_no }}{% endif %}</td>
                            <td>{{ item.client_name }}</td>
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
				{{ buttons.paging(query, env, data['invoice.enumInvoices']) }}
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
        <script type="text/javascript" src="/js/invoice.js"></script>
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