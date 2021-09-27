{% import "cmn_controls.macro" as buttons -%}
{% set contracts = ("正社員", "契約社員", "個人事業主", "パートナー") -%}
{% set pagenates = ("100", "200", "500", "all") -%}
{% set schemes = (("すべて", ""), ("元請", "元請"), ("エンド", "エンド")) -%}
{% set shares = (("すべて", ""), ("オープン", 1), ("クローズ", 0)) -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body>
{% include "cmn_header.tpl" %}
<input type="hidden" id="project_id" value="{{ query.project_id}}">
<input type="hidden" id="company_id" value="0">
<!-- メインコンテンツ -->
<div class="row">
    <div class="container" style="margin-bottom:100px;margin-top:30px;">

        <div id="" class="row" style="margin-bottom:30px;">
            <div class="container">
                <div class="row">
                    <div class="col-xs-2">
                        <img alt="帳票" width="22" height="20" src="/img/icon/group_case.png">
                        <span id="quotation_header_label">見積書</span>
                    </div>
                    <div class="col-xs-7">
                        <span class="alert-danger" id="quotation_annotation_label"></span>
                        <button type="button" class="btn btn-primary" onclick="$('#search_operation_modal').modal('show');">既存データから作成</button>
                        <button type="button" class="btn btn-primary" onclick="hdlClickNewOperationObj();">稼働情報を入力して作成</button>
                    </div>
                    <div class="col-xs-3">
                        <button type="button" class="btn btn-primary" onclick="saveQuotation()">保存</button>
                        <button type="button" class="btn btn-primary" onclick="triggerDownLoadQuotation();">PDF出力</button>
                        <button type="button" class="btn btn-primary" onclick="sendMailwithPdf();">メール送信</button>
                    </div>
                </div>
            </div>
        </div>

        <input type="hidden" id="client_worker_ids">
        <input type="hidden" id="company_user_ids">


        <div class="row" style="border: solid #999999;border-width: thin;">
            <div class="col-xs-12" style="margin-left:40px;margin-right:30px;margin-top:30px;">
                <div class="row">
                    <div class="col-xs-12 text-left">
                        <input type="checkbox" id="is_view_window"/>窓付き封筒用の宛先住所をつける
                    </div>
                    <div class="col-xs-12 text-left">
                        <input type="checkbox" id="is_view_excluding_tax"/>合計欄のみ税抜き表示
                    </div>
                    <br>
                    <div class="col-xs-12">
                        <table class="">
                            <tr>
                                <td style="background-color: #eaeaea; width: 70pt; padding-left: 10pt;"> no.</td>
                                <td style="padding-left: 10pt;"><input type="text" id="quotation_no" name="quotation_no" size="20" maxlength="20" value="111111"></td>
                            </tr>
                            <tr>
                                <td style="background-color: #eaeaea; width: 70pt; padding-left: 10pt;"><span id="quotation_date_label">見積日</span></td>
                                <td style="padding-left: 10pt;"><input type="text" id="quotation_date" name="quotation_date" size="20" maxlength="20" value=""></td>
                            </tr>
                        </table>
                    </div>
                </div>

                <div class="row">
                    <div class="col-xs-12 text-center strong">
                        <br/><br/>
                        <h1><span id="quotation_title_label">見積書</span></h1>
                    </div>
                </div>
                <div class="row">
                    <div class="col-xs-6">
                        <h3>
                            <select class="" style="width: 70%;" id="client_id">
                                <option>　</option>
                                {% for item in data['client.enumClients'] %}
                                <option value="{{ item.id }}" >{{ item.name|e }}</option>
                                {% endfor %}
                            </select>
                            <input type="hidden" class="form-control" id="client_name"/>
                            　御中
                        </h3>
                        <p><span id="quotation_sentence_label">下記の通り、お見積申し上げます。</span></p>
                        <table class="">
                            <tr>
                                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt;"> 件名</td>
                                <td>
                                    <input type="text" id="quotation_name" name="quotation_name" size="30" maxlength="20" value="{% if data['operation.enumOperations'] %}{% else %}{% if data['operation.enumProjects'] %}{{ data['operation.enumProjects'][0].title|e }}{% endif %}{% endif %}">
                                </td>
                            </tr>
                            <tr>
                                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt;"> 支払い条件</td>
                                <td><input type="text" id="payment_condition" name="payment_condition" size="30" maxlength="20" value=""></td>
                            </tr>
                            <tr>
                                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt;"> 有効期限</td>
                                <td><input type="text" id="expiration_date" name="expiration_date" size="30" maxlength="20" value=""></td>
                            </tr>
                        </table>
                        <br/>
                        <table class="table-bordered">
                            <tr>
                                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt;"><h4>合計金額</h4></td>
                                <td class="text-center" style="width: 200pt;"><h4><span id="total_including_tax_view"></span> 円（税込）</h4></td>
                            </tr>
                        </table>
                        <br/>
                    </div>
                    <div class="col-xs-2">

                    </div>
                    <div class="col-xs-4">
                        <h4>{{ data['manage.readUserProfile'].company.name|e }}</h4>
                        <p style="position: absolute; z-index: 2;">
                            〒{{ data['manage.readUserProfile'].company.addr_vip|e }}&nbsp;<br/>
											{{ data['manage.readUserProfile'].company.addr1|e}}<br/>
											{% if data['manage.readUserProfile'].company.addr2|e %}
											{{ data['manage.readUserProfile'].company.addr2|e }}<br/>
											{% endif %}

                            TEL：{{ data['manage.readUserProfile'].company.tel|e }}<br/>
                            FAX：{{ data['manage.readUserProfile'].company.fax|e }}<br/>
                            担当：
                            {% if current == "quotation.topEstimate" %}
                                {% if data['manage.readUserProfile'].company.estimate_charging_user_id %}
                                    {% for item in data['manage.enumAccounts'] %}
                                        {% if item.is_enabled == True %}
                                            {% if item.id == data['manage.readUserProfile'].company.estimate_charging_user_id %}{{ item.name|e }}{% endif %}
                                        {% endif %}
                                    {% endfor %}
                                {% endif %}
                            {% else %}
                                {% if data['manage.readUserProfile'].company.invoice_charging_user_id %}
                                    {% for item in data['manage.enumAccounts'] %}
                                        {% if item.is_enabled == True %}
                                            {% if item.id == data['manage.readUserProfile'].company.invoice_charging_user_id %}{{ item.name|e }}{% endif %}
                                        {% endif %}
                                    {% endfor %}
                                {% endif %}
                            {% endif %}
                        </p>
                        <img border="0" style="position: absolute; z-index: 1; left: 150px;top: 30px;" src="{{ data['manage.readUserProfile'].company.company_seal|e }}" width="100" height="100" alt="社印">
                        {% if data['manage.readUserProfile'].company.company_version %}
                        <img border="0" style="position: absolute; z-index: 1; left: 40px;top: 150px;" src="{{ data['manage.readUserProfile'].company.company_version|e }}" width="auto" height="auto" alt="社版">
                        {% endif %}
                    </div>
                </div>
            </div>

            <div class="container" style="margin-top: 100px; margin-bottom:20px;">
                <div class="row" style="margin-left:40px;margin-right:20px;">
                    <table class="view_table table-bordered" width="100%" id="detail-table">
                        <thead >
                            <tr id = "detail-table-first">
{#                                <th style="width: 5%; background-color: #ffffff; border-top-style: hidden; border-bottom-style: hidden; border-left-style: hidden;"></th>#}
                                <th style="width: 51%;">摘要</th>
                                <th style="width: 5%;">数量</th>
                                <th style="width: 5%;">単位</th>
                                <th style="width: 5%;">実績</th>
                                <th style="width: 9%;">単価</th>
                                <th style="width: 5%;">非課税</th>
                                <th style="width: 5%;">消費税</th>
                                <th style="width: 10%;">金額</th>
                                <th style="width: 5%; background-color: #ffffff; border-top-style: hidden; border-bottom-style: hidden; border-right-style: hidden;"></th>
                            </tr>
                        </thead>
                        <tbody id="detail-table-body">
                            {% set view_range = 5 %}
                            {% for n in range(view_range) %}
                            <tr id="">
{#                                <td style="width: 5%; border-bottom-style: hidden; border-left-style: hidden;" class="center">#}
{#                                    <span class="glyphicon glyphicon-plus text-danger pseudo-link-cursor" title="行追加" onclick="addClumn({{loop.index}})"></span>#}
{#                                    <span class="glyphicon glyphicon-minus text-danger pseudo-link-cursor" title="行削除" onclick="delClumn({{loop.index}})"></span>#}
{#                                </td>#}
                                <td style="width: 51%;">
                                    <input type="text" style="width: 100%;" id="summary_{{loop.index}}"><br>
                                    超過単価 (<input type="text" style="width: 10%;" pattern="^([1-9]\d*|0)(\.\d+)?$" id="summary_{{loop.index}}_1" onchange="updateExcessAndDeduction({{loop.index}})">h)<br>
                                    控除単価 (<input type="text" style="width: 10%;" pattern="^([1-9]\d*|0)(\.\d+)?$" id="summary_{{loop.index}}_2" onchange="updateExcessAndDeduction({{loop.index}})">h)
                                </td>
                                <td style="width: 5%;">
                                    <input type="text"style="width: 100%;text-align: right;" id="quantity_{{loop.index}}" onchange="updateCalcResult({{loop.index}})"><br>
                                    <input type="text"style="width: 100%;text-align: right;" id="quantity_{{loop.index}}_1" onchange="updateCalcResult({{loop.index}})"><br>
                                    <input type="text"style="width: 100%;text-align: right;" id="quantity_{{loop.index}}_2" onchange="updateCalcResult({{loop.index}})">
                                </td>
                                <td style="width: 5%;">
                                    <select id="unit_{{loop.index}}" style="margin: 2px 0px 2px 0px;">
                                        <option value="1" selected>件</option>
                                        <option value="2">時間</option>
                                        <option value="3">人時</option>
                                        <option value="4">人日</option>
                                        <option value="5">人月</option>
                                    </select><br>
                                    <select id="unit_{{loop.index}}_1" style="margin: 2px 0px 2px 0px;">
                                        <option value="1" selected>件</option>
                                        <option value="2">時間</option>
                                        <option value="3">人時</option>
                                        <option value="4">人日</option>
                                        <option value="5">人月</option>
                                    </select><br>
                                    <select id="unit_{{loop.index}}_2" style="margin:  2px 0px 2px 0px;">
                                        <option value="1" selected>件</option>
                                        <option value="2">時間</option>
                                        <option value="3">人時</option>
                                        <option value="4">人日</option>
                                        <option value="5">人月</option>
                                    </select>
                                </td>
                                <td style="width: 5%;">
                                    <input type="text"style="width: 100%;text-align: right; margin-top: 0px" pattern="^([1-9]\d*|0)(\.\d+)?$" id="settlement_exp_{{loop.index}}" onchange="updateExcessAndDeduction({{loop.index}})"><br>
                                    <span style="font-size: large;">　</span><br>
                                    <span style="font-size: large;">　</span>
                                </td>
                                <td style="width: 9%;">
                                    <input type="text" style="width: 100%;text-align: right;" id="price_{{loop.index}}" onchange="updateCalcResult({{loop.index}})"><br>
                                    <input type="text" style="width: 100%;text-align: right;" id="price_{{loop.index}}_1" onchange="updateCalcResult({{loop.index}})"><br>
                                    <input type="text" style="width: 100%;text-align: right;" id="price_{{loop.index}}_2" onchange="updateCalcResult({{loop.index}})">
                                </td>
                                <td style="width: 5%;" class="center">
                                    <input type="checkbox" name="" style="margin:  7px;" id="is_including_tax_{{loop.index}}" onchange="updateCalcResult({{loop.index}})"><br>
                                    <input type="checkbox" name="" style="margin:  7px;" id="is_including_tax_{{loop.index}}_1" onchange="updateCalcResult({{loop.index}})"><br>
                                    <input type="checkbox" name="" style="margin:  7px;" id="is_including_tax_{{loop.index}}_2" onchange="updateCalcResult({{loop.index}})">
                                </td>
                                <td style="width: 5%;"class="center">
                                    <select id="tax_{{loop.index}}"style="margin: 2px 0px 2px 0px;" onchange="updateCalcResult({{loop.index}})">
					<option value="10" selected>10</option>
                                        <option value="8">8</option>
                                    </select><br>
                                    <select id="tax_{{loop.index}}_1" style="margin: 2px 0px 2px 0px;" onchange="updateCalcResult({{loop.index}})">
					<option value="10" selected>10</option>
                                        <option value="8">8</option>
                                    </select><br>
                                    <select id="tax_{{loop.index}}_2" style="margin: 2px 0px 2px 0px;" onchange="updateCalcResult({{loop.index}})">
					<option value="10" selected>10</option>
                                        <option value="8">8</option>
                                    </select>
                                </td>
                                <td style="width: 10%;" >
                                    <input type="text"  style="width: 100%; text-align: right" id="subtotal_{{loop.index}}" onchange="reformatSubtotal({{loop.index}});calcTotal()"><br>
                                    <input type="text"  style="width: 100%; text-align: right" id="subtotal_{{loop.index}}_1" onchange="reformatSubtotal('{{loop.index}}_1');calcTotal()"><br>
                                    <input type="text"  style="width: 100%; text-align: right" id="subtotal_{{loop.index}}_2" onchange="reformatSubtotal('{{loop.index}}_2');calcTotal()">
                                </td>
                                <td style="width: 5%; border-bottom-style: hidden; border-right-style: hidden;" class="center">
                                    <span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor" title="削除" onclick="resetColumn({{loop.index}})"></span>
                                </td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                    <span class=" pseudo-link-cursor" style="margin-left: 0px;"><a onclick="appendColumn()">行追加</a></span>
                </div>
		    </div>

        <div class="container" style="margin-bottom:20px;">
                <div class="row" style="margin-left:40px;margin-right:20px;">
                    <p>旅費・交通費入力欄</p>
                    <table class="view_table table-bordered" width="100%" id="detail-table">
                        <thead >
                            <tr id = "detail-table-first">
{#                                <th style="width: 5%; background-color: #ffffff; border-top-style: hidden; border-bottom-style: hidden; border-left-style: hidden;"></th>#}
                                <th style="width: 51%;">摘要</th>
                                <th style="width: 5%;">数量</th>
                                <th style="width: 5%;">単位</th>
                                <th style="width: 5%;">実績</th>
                                <th style="width: 9%;">単価</th>
                                <th style="width: 5%;">非課税</th>
                                <th style="width: 5%;">消費税</th>
                                <th style="width: 10%;">金額</th>
                                <th style="width: 5%; background-color: #ffffff; border-top-style: hidden; border-bottom-style: hidden; border-right-style: hidden;"></th>
                            </tr>
                        </thead>
                        <tbody id="free-detail-table-body">
                            {% set view_range = 3 %}
                            {% for n in range(view_range) %}
                            <tr id="">
{#                                <td style="width: 5%; border-bottom-style: hidden; border-left-style: hidden;" class="center">#}
{#                                    <span class="glyphicon glyphicon-plus text-danger pseudo-link-cursor" title="行追加" onclick="addClumn({{loop.index}})"></span>#}
{#                                    <span class="glyphicon glyphicon-minus text-danger pseudo-link-cursor" title="行削除" onclick="delClumn({{loop.index}})"></span>#}
{#                                </td>#}
                                <td style="width: 51%;">
                                    <input type="text" style="width: 100%;" id="free_summary_{{loop.index}}">
                                <td style="width: 5%;">
                                    <input type="text"style="width: 100%;text-align: right;" id="free_quantity_{{loop.index}}" onchange="updateFreeCalcResult({{loop.index}})">
                                </td>
                                <td style="width: 5%;">
                                    <select id="free_unit_{{loop.index}}" style="margin: 2px 0px 2px 0px;">
                                        <option value="1" selected>件</option>
                                        <option value="2">時間</option>
                                        <option value="3">人時</option>
                                        <option value="4">人日</option>
                                        <option value="5">人月</option>
                                    </select><br>
                                </td>
                                <td style="width: 5%;">
                                </td>
                                <td style="width: 9%;">
                                    <input type="text" style="width: 100%;text-align: right;" id="free_price_{{loop.index}}" onchange="updateFreeCalcResult({{loop.index}})"><br>
                                </td>
                                <td style="width: 5%;" class="center">
                                    <input type="checkbox" name="" style="margin:  7px;" id="free_is_including_tax_{{loop.index}}" onchange="updateFreeCalcResult({{loop.index}})" checked="checked"><br>
                                    </td>
                                <td style="width: 5%;"class="center">
                                    <select id="free_tax_{{loop.index}}"style="margin: 2px 0px 2px 0px;" onchange="updateFreeCalcResult({{loop.index}})">
					<option value="10" selected>10</option>
                                        <option value="8">8</option>
                                    </select><br>
                                </td>
                                <td style="width: 10%;" >
                                    <input type="text"  style="width: 100%; text-align: right" id="free_subtotal_{{loop.index}}" onchange="reformatFreeSubtotal({{loop.index}});calcTotal()"><br>
                                </td>
                                <td style="width: 5%; border-bottom-style: hidden; border-right-style: hidden;" class="center">
                                    <span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor" title="削除" onclick="resetFreeColumn({{loop.index}})"></span>
                                </td>
                            </tr>
                            {% endfor %}
                        </tbody>
                    </table>
                    <span class=" pseudo-link-cursor" style="margin-left: 0px;"><a onclick="appendFreeColumn()">行追加</a></span>
                </div>
		    </div>

            <div class="container" style="margin-bottom:20px;">
                <div class="row" style="margin-left:15px;margin-right:5px;">
                    <div class="col-xs-12">
                        <table class="table-bordered" width="100%">
                            <tr>
                                <td class="text-center" style="width: 73%; border-top-style: hidden; border-bottom-style: hidden; border-left-style: hidden;"></td>
                                <td style="background-color: #eaeaea; width: 10%; padding-left: 10pt;">小計</td>
                                <td class="text-center" style="width: 12%;"><input type="text" disabled style="width: 100%;" id="subtotal"></td>
                                <td class="text-center" style="width: 5%; border-top-style: hidden; border-right-style: hidden; border-bottom-style: hidden;"></td>
                            </tr>
                            <tr>
                                <td class="text-center" style="width: 73%; border-top-style: hidden; border-bottom-style: hidden; border-left-style: hidden;"></td>
                                <td style="background-color: #eaeaea; width: 10%; padding-left: 10pt;">消費税</td>
                                <td class="text-center" style="width: 12%;"><input type="text" disabled style="width: 100%;" id="tax"></td>
                                <td class="text-center" style="width: 5%; border-top-style: hidden; border-right-style: hidden; border-bottom-style: hidden;"></td>
                            </tr>
                            <tr>
                                <td class="text-center" style="width: 73%; border-top-style: hidden; border-bottom-style: hidden; border-left-style: hidden;"></td>
                                <td style="background-color: #eaeaea; width: 10%; padding-left: 10pt;">合計</td>
                                <td class="text-center" style="width: 12%;"><input type="text" disabled style="width: 100%;" id="total_including_tax"></td></td>
                                <td class="text-center" style="width: 5%; border-top-style: hidden; border-right-style: hidden; border-bottom-style: hidden;"></td>
                            </tr>

                        </table>
                    </div>
                </div>
            </div>

            {% if current == "quotation.topInvoice" %}
            <div class="container" style="margin-bottom:20px;">
                <div class="row" style="margin-left:30px;margin-right:20px;">
                    <table class="view_table table-bordered">
                        <thead>
                            <tr>
                                <th style="width: 95%;">振込先</th>
                                <th style="width: 5%; background-color: #ffffff; border-top-style: hidden; border-bottom-style: hidden; border-right-style: hidden;"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr id="">
                                <td class="left" style="width: 95%;">
                                    {% if data['manage.readUserProfile'].company.bank_account1|e %}{{ data['manage.readUserProfile'].company.bank_account1|e }}<br/>{% endif %}
                                    {% if data['manage.readUserProfile'].company.bank_account2|e %}{{ data['manage.readUserProfile'].company.bank_account2|e }}{% endif %}
                                </td>
                                <td class="text-center" style="width: 5%; border-top-style: hidden; border-right-style: hidden; border-bottom-style: hidden;"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
		    </div>
            {% endif %}

            <div class="container" style="margin-bottom:20px;">
                <div class="row" style="margin-left:30px;margin-right:20px;">
                    <table class="view_table table-bordered">
                        <thead>
                            <tr>
                                <th style="width: 95%;">備考</th>
                                <th style="width: 5%; background-color: #ffffff; border-top-style: hidden; border-bottom-style: hidden; border-right-style: hidden;"></th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr id="">
                                <td class="center" style="width: 95%;">
                                    <textarea id="memo" name="" rows="4" maxlength="1000" placeholder="備考をご記入ください" style="width: 100%;"></textarea>
                                </td>
                                <td class="text-center" style="width: 5%; border-top-style: hidden; border-right-style: hidden; border-bottom-style: hidden;"></td>
                            </tr>
                        </tbody>
                    </table>
                </div>
		    </div>

        </div>

        <div class="container" style="margin-bottom:20px; margin-top:50px;">
            <div class="" style="">
                <table class="view_table table-bordered">
                    <thead>
                        <tr>
                            <th style="width: 95%;">社内メモ</th>
                            <th style="width: 5%; background-color: #ffffff; border-top-style: hidden; border-bottom-style: hidden; border-right-style: hidden;"></th>
                        </tr>
                    </thead>
                    <tbody>
                        <tr id="">
                            <td class="center" style="width: 100%;">
                                <textarea id="office_memo" name="" rows="5" maxlength="200" placeholder="社内メモをご記入ください（帳票には印字されません）" style="width: 100%;"></textarea>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

    </div>
</div>
<!-- /メインコンテンツ -->
<!-- [begin] Modal. -->
<div id="search_operation_modal" class="modal fade" role="dialog" aria-hidden="true">
	<div class="modal-dialog" style="width:1000px;">
		<div class="modal-content">
			<div class="modal-header">
                <ul class="pull-right" style="list-style-type: none; overflow: hidden;">
					<li style="margin: 0 0.5em; float: left;">
						<button type="button" class="close" data-dissmiss="modal"
                        onclick="$('#search_operation_modal').modal('hide');">
                        <span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span></button>
					</li>
                </ul>
				<h4 class="modal-title">
                    <span class="glyphicon glyphicon-search">&nbsp;</span>既存データから作成
                </h4>

			</div><!-- div.modal-header -->
			<div class="modal-body">
                <h4>検索条件</h4>
				<div id="modal_search_container_engineer" style="overflow: hidden;">
					<ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
                        <li style="margin: 1px 2em; float: left;">
                            <label for="query_client_name" style="color: #666666; width: 5em;">取引先名</label>
                            <input type="text" id="query_client_name" value="{{ query.client_name|e }}"/>
                            <input type="hidden" id="query_client_id"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="query_title" style="color: #666666; width: 5em;">案件内容</label>
                            <input type="text" id="query_title" value="{{ query.title|e }}"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="query_title" style="color: #666666; width: 5em;">請求単価</label>
                            <input type="text" id="query_fee_inbound" value="{{ query.fee_inbound|e }}"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="query_term" style="color: #666666; width: 5em;">期間</label>
                            <input type="text" id="query_term" value="{{ query.term|e }}" data-date-format="yyyy/mm/dd"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="query_interview" style="color: #666666; width: 5em;">面談回数</label>
                            <input type="text" id="query_interview" value="{{ query.interview|e }}"/>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="query_scheme" style="color: #666666; width: 5em;">商流</label>
                            <select id="query_scheme">
                            {% for schemeLabel, schemeValue in schemes %}
                                <option value="{{ schemeValue }}"{% if schemeValue == query.scheme %} selected="selected"{% endif %}>{{ schemeLabel }}</option>
                            {% endfor %}
                            </select>
                        </li>
                        <li style="margin: 1px 2em; float: left;">
                            <label for="query_flg_shared" style="color: #666666; width: 5em;">状態</label>
                            <select id="query_flg_shared">
                            {% for shareLabel, shareValue in shares %}
                                <option value="{{ shareValue }}"{% if shareValue == query.flg_shared %} selected="selected"{% endif %}>{{ shareLabel }}</option>
                            {% endfor %}
                            </select>
                        </li>
						<li style="margin: 1px 2em; float: right;">
							<button type="button" class="btn btn-primary"
								onclick="renderOperationModal('');">検索</button>
							<button type="button" class="btn btn-primary"
								onclick="renderOperationModal('clear');">クリア</button>
						</li>
                    </ul>
				</div>
				<button type="button" class="btn btn-primary pull-right" onclick="$('#search_operation_modal').modal('hide');hdlClickNewOperationObj();">稼働情報を入力して作成</button>
				<div>
					<h4>検索結果 <span id="row_count" class="badge"></span></h4>
					<table class="view_table table-bordered table-hover"
						id="modal_search_result_operation"
						style="">
						<thead>
							<tr>
								<th>選択</th>
								<th>取引先名</th>
								<th>案件名</th>
								<th>営業担当</th>
                                <th>所属取引先名</th>
								<th>要員名</th>
                                <th>勤務開始日</th>
                                <th>勤務終了日</th>
							</tr>
						</thead>
						<tbody></tbody>
					</table>
				</div>
			</div><!-- div.modal-body -->
			<div class="modal-footer">
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
			</div><!-- div.modal-footer -->
		</div><!-- div.modal-content -->
	</div><!-- div.modal-dialog -->
</div><!-- div.modal -->

<div id="loader-bg">
  <div id="loader">
    <img src="/img/icon/img-loading.gif" width="80" height="80" alt="Now Loading..." />
    <p>メール送信用PDFファイルを<br/>準備中です。</p>
  </div>
</div>

<div id="loader-bg2">
  <div id="loader2">
    <img src="/img/icon/img-loading.gif" width="80" height="80" alt="Now Loading..." />
    <p>PDFファイルを準備中です。</p>
  </div>
</div>

<input type="hidden" id="output_history_rec" value='{{ data['output_history_rec'] }}'>

{% include "operation_modal.tpl" %}

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
        <script src="/js/jquery.autokana.js" type="text/javascript"></script>
        <script type="text/javascript" src="/js/jquery-ui.js"></script>
        <script type="text/javascript" src="/js/jquery.ui.touch-punch.js"></script>
        <script src="/js/bootstrap-datepicker.js" type="text/javascript"></script>
        <script src="/js/bootstrap-datepicker.ja.js" type="text/javascript"></script>
        <link href="/css/select2.css" rel="stylesheet">
        <script src="/js/select2.js"></script>
        <script src="/js/bignumber.min.js" type="text/javascript"></script>
		<script type="text/javascript" src="/js/quotation.js"></script>
        <script type="text/javascript" src="/js/operation.js"></script>
		<script type="text/javascript">
$(document).ready(function () {
	unsaved = false;
	env.data = env.data || {};
	env.userProfile = JSON.parse('{{ data['auth.userProfile']|tojson }}');
	env.manageUserProfile = JSON.parse('{{ data['manage.readUserProfile']|tojson }}');
{#	env.history = JSON.parse('{{ data['output_history']|tojson }}');#}
	env.quotation_default_no = {% if data['quotation_default_no'] %}{{ data['quotation_default_no']}}{% else %}""{% endif %};

	env.quotation_id = {% if data['quotation_id'] %}{{ data['quotation_id']}}{% else %}0{% endif %};

	rec_history =  $("#output_history_rec").val();
	if(rec_history != undefined && rec_history != ""){
	    rec_history_json = JSON.parse(rec_history.replace(/^"/g,'¥"').replace(/"$/g,'¥"'));
	    env.history = rec_history_json.output;
    }else{
	    redirectConfig();
    }

	if(env.quotation_default_no != ""){
	    $('#quotation_no').val(env.quotation_default_no);
    }

    initLabel();
	if(env.history != undefined && env.history.length != 0){
        loadDataFromHistory();
    }else {
        env.operations = JSON.parse('{{ data['operation.enumOperations']|tojson }}');
        loadDataFromOperation();
    }

    if(env.recentQuery.action_type){
	    if(env.recentQuery.action_type == "COPY"){
            resetDataForCopy();
        }
    }

	$("#client_id").select2();
	loadClientInfo();

    setAutoKana();
    setAutocompleteSite();
    setAllowanceHelpMessageStr();
    setDatePicker();

});

$(function() {

    $('#client_id').change(function() {
        loadClientInfo();
    });

});
		</script>
	</body>
</html>
