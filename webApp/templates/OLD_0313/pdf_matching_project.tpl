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

<body style="margin: 0pt;">

{% set first_page_height = 920 %}
{% set first_range = 15 %}
{% set page_top_padding = 0 %}

<div style="height: {{ first_page_height }}pt;">
    <h1 style="text-align: center;  margin-bottom: 50px">案件マッチング 一覧</h1>
    <div class="" style="margin-top: 50px">
        {% if data['engineer.enumEngineers'] %}
            {% set items = data['engineer.enumEngineers'][0:1] %}
            {% for item in items %}
            <ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
                <li style="margin: 0 2em; float: left;">
                    <label for="query_name" style="color: #666666;">要員名</label>
                    {{ item.name}} ({{ item.kana}})
                </li>
                <li style="margin: 0 2em; float: left;">
                    <label for="query_station" style="color: #666666;">最寄駅</label>
                    {% if item.station %}{{ item.station|e }}{% endif %}
                </li>
                <li style="margin: 0 2em; float: left;">
                    <label for="query_contract" style="color: #666666;">所属</label>
                    {% if item.contract %}{{ item.contract|e }}{% endif %}
                </li>
{#                                <li style="margin: 0 2em; float: left;">#}
{#                                    <label for="query_employer" style="color: #666666;">所属団体名</label>#}
{#                                    {{ item.employer|e }}#}
{#                                </li>#}
                <li style="margin: 0 2em; float: left;">
                    <label for="query_skill" style="color: #666666;">職種</label>
                    {% if item.occupation_list %}{{ item.occupation_list|e }}{% endif %}

                </li>
                <li style="margin: 0 2em; float: left;">
                    <label for="query_skill" style="color: #666666;">スキル</label>
                    {% if item.skill_list %}{{ item.skill_list|e }}{% endif %}
                </li>
                <li style="margin: 0 2em; float: left;">
                    <label for="query_name" style="color: #666666;">稼働開始</label>
                    {% if item.operation_begin %}{{ item.operation_begin|e }}{% endif %}
                </li>
            </ul>
            {% endfor %}
        {% endif %}
        <table class="view_table table-bordered" width="100%" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd" id="detail-table">
            <thead>
            <tr id="detail-table-first" style="background-color: #eaeaea;">
                <th style="font-weight: inherit; font-size: small; width: 10%;">案件内容</th>
                <th style="font-weight: inherit; font-size: small; width: 10%;">職種</th>
                <th style="font-weight: inherit; font-size: small; width: 10%;">取引先名</th>
                <th style="font-weight: inherit; font-size: small; width: 20%;">スキル</th>
                <th style="font-weight: inherit; font-size: small; width: 8%;">期間from<br/> 期間to</th>
                <th style="font-weight: inherit; font-size: small; width: 8%;">支払単価<br/>／ 請求単価</th>
                <th style="font-weight: inherit; font-size: small; width: 8%;">年齢from<br/> 年齢to</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">最寄駅</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">面談回数</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">商流</th>
                <th style="font-weight: inherit; font-size: small; width: 6%;">営業担当者</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">外国籍</th>
            </thead>
            <tbody id="detail-table-body">
                {% for item in data['operation.enumProjects'][0:first_range] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">{{ item.title|truncate(12, True)|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">{% if item.occupation != None %}{{ item.occupation|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.owner_company_id != data["auth.userProfile"].company.id %}
                                {{ item.owner_company_name|truncate(10, True)|e }}
                            {% else %}
                                {{ item.client_name }}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 20%; text-align: left;">{% if item.skill != None %}{{ item.skill|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: left;">
                            {% if item.term_begin != None %}{{ item.term_begin|e }}{% endif %}
                            〜{% if item.term_end != None %}{{ item.term_end|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">
                            {{ item.fee_outbound_comma|e }}
                            <br/>／
                            {% if item.owner_company_id == data["auth.userProfile"].company.id %}{{ item.fee_inbound_comma|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">
                            {% if item.age_from != None %}{{ item.age_from|e }}{% endif %}
                            〜{% if item.age_to != None %}{{ item.age_to|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: left;">
                            {% if item.station != None %}
                                {{ item.station|e }}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{{ item.interview|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{{ (item.scheme or "")|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 6%; text-align: center;">{{ item.charging_user.user_name|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.flg_foreign == 1 %}可{%elif item.flg_foreign == 0 %}不可{% else %}{% endif %}</td>
                    </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</div>
<div class="" style="height: 18pt;width: 100%; margin: 0pt; text-align: center;">
    {% if data['operation.enumProjects']|length > first_range %}
        {% set max_page = ((((data['operation.enumProjects']|length) - first_range) / first_range) | round(0, 'ceil') + 1 )|int %}
        <span>　1/{{ max_page }}</span>
    {% else %}
        <span>1/1</span>
    {% endif %}
</div>
{% if data['operation.enumProjects']|length > first_range %}
    {% set total_loop = (((data['operation.enumProjects']|length) - first_range) / first_range) | round(0, 'ceil')|int %}
    {% set def_view_range_start = first_range %}
    {% set def_view_range = first_range %}
    {% set def_view_range_end = def_view_range_start + def_view_range %}
    {% for n in range(total_loop) %}
    <div style="height: {{ first_page_height }}pt;">
        <h1 style="text-align: center;  margin-bottom: 50px"></h1>
        <div class="" style="margin-top: 50px">
            <table class="view_table table-bordered" width="100%" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd" id="detail-table">
                <thead>
                    <tr id="detail-table-first" style="background-color: #eaeaea;">
                    <th style="font-weight: inherit; font-size: small; width: 10%;">案件内容</th>
                    <th style="font-weight: inherit; font-size: small; width: 10%;">職種</th>
                    <th style="font-weight: inherit; font-size: small; width: 10%;">取引先名</th>
                    <th style="font-weight: inherit; font-size: small; width: 20%;">スキル</th>
                    <th style="font-weight: inherit; font-size: small; width: 8%;">期間from<br/> 期間to</th>
                    <th style="font-weight: inherit; font-size: small; width: 8%;">支払単価<br/>／ 請求単価</th>
                    <th style="font-weight: inherit; font-size: small; width: 8%;">年齢from<br/> 年齢to</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">最寄駅</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">面談回数</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">商流</th>
                    <th style="font-weight: inherit; font-size: small; width: 6%;">営業担当者</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">外国籍</th>
                </thead>
                <tbody id="detail-table-body">
                {% set view_range_start = def_view_range_start + (def_view_range * (loop.index - 1)) %}
                {% set view_range_end = def_view_range_end + (def_view_range * (loop.index - 1)) %}
                {% for item in data['operation.enumProjects'][view_range_start:view_range_end] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">{{ item.title|truncate(12, True)|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">{% if item.occupation != None %}{{ item.occupation|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.owner_company_id != data["auth.userProfile"].company.id %}
                                {{ item.owner_company_name|truncate(10, True)|e }}
                            {% else %}
                                {{ item.client_name }}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 20%; text-align: left;">{% if item.skill != None %}{{ item.skill|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: left;">
                            {% if item.term_begin != None %}{{ item.term_begin|e }}{% endif %}
                            〜{% if item.term_end != None %}{{ item.term_end|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: left;">
                            {{ item.fee_outbound_comma|e }}
                            <br/>／
                            {% if item.owner_company_id == data["auth.userProfile"].company.id %}{{ item.fee_inbound_comma|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: left;">
                            {% if item.age_from != None %}{{ item.age_from|e }}{% endif %}
                            〜{% if item.age_to != None %}{{ item.age_to|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: left;">
                            {% if item.station != None %}
                                {{ item.station|e }}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: left;">{{ item.interview|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: left;">{{ (item.scheme or "")|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 6%; text-align: left;">{{ item.charging_user.user_name|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: left;">{% if item.flg_foreign == 1 %}可{%elif item.flg_foreign == 0 %}不可{% else %}{% endif %}</td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
    <div class="" style="height: 18pt;width: 100%; margin: 0pt; text-align: center;">
        {% set max_page = ((((data['operation.enumProjects']|length) - first_range) / first_range) | round(0, 'ceil') + 1)|int  %}
        {% set current_page = 1 + loop.index %}
        <span>　{{ current_page }}/{{ max_page }}</span>
    </div>
    {% endfor %}
{% endif %}
</body>
</html>