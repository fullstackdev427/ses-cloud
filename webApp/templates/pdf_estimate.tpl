<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <title>タイトル</title>
    <style type="text/css">
        <!--
        body{
            font-family: "Helvetica Neue",Helvetica,Arial,sans-serif;

        }
        -->
    </style>
</head>

<body style="margin: 0pt">

{% if env['output'].is_view_window %}
<div style="margin: 0pt; height: 150pt;">
    <p>
        〒{{ data['client.enumClients'][0].addr_vip|e }}&nbsp;<br/>
            {{ data['client.enumClients'][0].addr1|e}}<br/>
            {% if data['client.enumClients'][0].addr2|e %}
            {{ data['client.enumClients'][0].addr2|e }}<br/>
            {% endif %}
            {{ data['client.enumClients'][0].name|e }}　御中
    </p>
</div>
{% endif %}
{% if env['output'].is_view_window %}
    {% set first_page_height = 546 %}
{% else %}
    {% set first_page_height = 708 %}
{% endif %}
<div style="height: {{ first_page_height }}pt;">
    <h1 style="text-align: center;  margin-bottom: 20px">見積書</h1>

    <table style="border-collapse: collapse;" class="">
        <tr>
            <td style="background-color: #eaeaea; width: 70pt; padding-left: 10pt; font-weight: inherit; font-size: small; "> no.</td>
            <td style="padding-left: 10pt;">{{ env['output'].quotation_no }}</td>
        </tr>
        <tr>
            <td style="background-color: #eaeaea; width: 70pt; padding-left: 10pt; font-weight: inherit; font-size: small; "> 見積日</td>
            <td style="padding-left: 10pt;"> {{ env['output'].quotation_date }}</td>
        </tr>
    </table>

    <div style="float: left;" class="">
        <h3>{{ data['client.enumClients'][0].name|e }}　御中</h3>
        <p>下記の通り、お見積申し上げます。</p>
        <table style="border-spacing: 0px;" class="">
            <tr>
                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt; font-weight: inherit; font-size: small; "> 件名</td>
                <td>　{{ env['output'].quotation_name }}</td>
            </tr>
            <tr>
                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt; font-weight: inherit; font-size: small; "> 支払い条件</td>
                <td>　{{ env['output'].payment_condition }}</td>
            </tr>
            <tr>
                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt; font-weight: inherit; font-size: small; "> 有効期限</td>
                <td>　{{ env['output'].expiration_date }}</td>
            </tr>
        </table>
        <br/>
        <table style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd">
            <tr>
                <td style="background-color: #eaeaea; width: 100pt; padding-left: 10pt;"><h4>合計金額</h4></td>
                <td class="text-center" style="width: 150pt; text-align: center">
                    {% if env['output'].is_view_excluding_tax %}
                        <h4>{{ env['output'].subtotal }} 円（税抜）</h4>
                    {% else %}
                        <h4>{{ env['output'].total_including_tax }} 円（税込）</h4>
                    {% endif %}
                </td>
            </tr>
        </table>
        <br/>
    </div>

    <div style="float: left; width: 200px;" class="">　</div>

    <div style="float: left; height: 200px;" class="">
        <h4>{{ data['manage.readUserProfile'].company.name|e }}</h4>
            <p style="position: absolute; z-index: 2;">
                〒{{ data['manage.readUserProfile'].company.addr_vip|e }}&nbsp;<br/>
                {{ data['manage.readUserProfile'].company.addr1|e}}<br/>
                {% if data['manage.readUserProfile'].company.addr2|e %}
                {{ data['manage.readUserProfile'].company.addr2|e }}<br/>
                {% endif %}
                TEL：{{ data['manage.readUserProfile'].company.tel|e }}<br/>
                FAX：{{ data['manage.readUserProfile'].company.fax|e }}<br/>
                担当：{% if data['manage.readUserProfile'].company.estimate_charging_user_id %}
                        {% for item in data['manage.enumAccounts'] %}
                            {% if item.is_enabled == True %}
                                {% if item.id == data['manage.readUserProfile'].company.estimate_charging_user_id %}{{ item.name|e }}{% endif %}
                            {% endif %}
                        {% endfor %}
                    {% endif %}
            </p>
        {% if data['manage.readUserProfile'].company.company_seal %}
        <span style="position: relative;z-index: 1; left: 120px; top: -20px;">
             <img style="height: 100px; width: 100px;" src="{{ data['manage.readUserProfile'].company.company_seal|e }}">
        </span>
        {% endif %}
    </div>

    {% if data['manage.readUserProfile'].company.company_version %}
    <img border="0" style="position: absolute; z-index: 1; right: 20px;top: 330px;" width="auto" height="auto" src="{{ data['manage.readUserProfile'].company.company_version|e }}">
    {% endif %}

    <div style="clear: both;"></div>
{% if env['output'].is_view_window %}
    {% set first_range = 10 %}
{% else %}
    {% set first_range = 25 %}
{% endif %}

    <div class="" style="margin-top: 120px">
        <table class="view_table table-bordered" width="100%" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd" id="detail-table">
            <thead>
            <tr id="detail-table-first" style="background-color: #eaeaea;">
                <th style="font-weight: inherit; font-size: small; width: 51%;">摘要</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">数量</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">単位</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">実績</th>
                <th style="font-weight: inherit; font-size: small; width: 12%;">単価</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">非課税</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">消費税</th>
                <th style="font-weight: inherit; font-size: small; width: 120px;">金額</th>
            </thead>
            <tbody id="detail-table-body">
            {% set outputItems = env['output'].print_rows[0:first_range] %}
            {% for item in outputItems %}
                <tr id="">
                    <td style="font-weight: inherit; font-size: small; width: 51%;">　{{ item.summary }}</td>
                    <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{{ item.quantity }}</td>
                    <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{{ item.unit }}</td>
                    <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{{ item.settlement_exp }}</td>
                    <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;">{{ item.price }}</td>
                    <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.isIncludingTax %}◯{% endif %}</td>
                    <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{% if item.subtotal %}{{ item.tax }}%{% else %}　{% endif %}</td>
                    <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;">{{ item.subtotal }}</td>
                </tr>
            {% endfor %}
            {% if (env['output'].print_rows|length) < first_range %}
                {% for item in range(first_range - (env['output'].print_rows|length)) %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 51%;">　</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;"></td>
                    </tr>
                {% endfor %}
            {% endif %}
            </tbody>
        </table>
    </div>


    <div class="" style="float:right; margin-top: 15pt;  margin-bottom: 15pt;">
        <table class="table-bordered" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd">
            <tr>
                <td style="background-color: #eaeaea; width: 80px; padding-left: 10pt;">小計</td>
                <td class="text-center" style="width: 120px; text-align: right;">{{ env['output'].subtotal }}</td>
                </tr>
            <tr>
                <td style="background-color: #eaeaea; width: 80px; padding-left: 10pt;">消費税</td>
                <td class="text-center" style="width: 120px; text-align: right;">{{ env['output'].tax }}</td>
                </tr>
            <tr>
                <td style="background-color: #eaeaea; width: 80px; padding-left: 10pt;">合計</td>
                <td class="text-center" style="width: 120px; text-align: right;">{{ env['output'].total_including_tax }}</td>
            </tr>
        </table>
    </div>
    <div style="clear: both;"></div>
</div>
<div class="" style="width: 100%; margin: 10pt">
    <table class="" style=" border-collapse: collapse; width: 98%;" border="1" bordercolor="#ddd">
        <tr>
            <td style="background-color: #eaeaea;width: 100%; text-align: center; font-size: small">備考</td>
        </tr>
        <tr style="height: 180pt;">
            <td style="width: 100%; height: 100%"><p style="height:100%">{{ "<br />".join(env['output'].memo.split("\n")) }}</p></td>
        </tr>
    </table>
</div>
<div class="" style="height: 20pt;width: 100%; margin: 0pt; text-align: center">
    {% if env['output'].print_rows > first_range %}
        {% set max_page = ((((env['output'].print_rows|length) - first_range) / 60) | round(0, 'ceil') + 1 )|int %}
        <span>　1/{{ max_page }}</span>
    {% else %}
        <span>　</span>
    {% endif %}
</div>
{% if env['output'].print_rows > first_range %}
    {% set total_loop = (((env['output'].print_rows|length) - first_range) / 60) | round(0, 'ceil')|int %}
    {% set def_view_range_start = first_range %}
    {% set def_view_range = 60 %}
    {% set def_view_range_end = def_view_range_start + def_view_range %}
    {% for n in range(total_loop) %}
    <div style="height: 969pt;margin-bottom: 0pt;">
        <div style="" >
            <table class="view_table table-bordered" width="100%" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd" id="detail-table">
                <thead>
                <tr id="detail-table-first" style="background-color: #eaeaea;">
                    <th style="font-weight: inherit; font-size: small; width: 51%;">摘要</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">数量</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">単位</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">実績</th>
                    <th style="font-weight: inherit; font-size: small; width: 12%;">単価</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">非課税</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">消費税</th>
                    <th style="font-weight: inherit; font-size: small; width: 120px;">金額</th>
                </thead>
                <tbody id="detail-table-body">
                {% set view_range_start = def_view_range_start + (def_view_range * (loop.index - 1)) %}
                {% set view_range_end = def_view_range_end + (def_view_range * (loop.index - 1)) %}
                {% for item in env['output'].print_rows[view_range_start:view_range_end] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 51%;">　{{ item.summary }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{{ item.quantity }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{{ item.unit }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{{ item.settlement_exp }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;">{{ item.price }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.isIncludingTax %}◯{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;">{% if item.subtotal %}{{ item.tax }}%{% else %}　{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;">{{ item.subtotal }}</td>
                    </tr>
                {% endfor %}
                {% if loop.last %}
                    {% set padding_range = 60 - (((env['output'].print_rows|length) - first_range) % 60) %}
                    {% for item in range(padding_range) %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 51%;">　</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: right;"></td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: right;"></td>
                    </tr>
                {% endfor %}
                {% endif %}
                </tbody>
            </table>
        </div>
        <div class="" style="height: 5pt;width: 100%; margin-top: 20pt; text-align: center">
            {% set max_page = ((((env['output'].print_rows|length) - first_range) / 60) | round(0, 'ceil') + 1)|int  %}
            {% set current_page = 1 + loop.index %}
            <span>　{{ current_page }}/{{ max_page }}</span>
        </div>
    </div>
    {% endfor %}
{% endif %}
</body>
</html>
