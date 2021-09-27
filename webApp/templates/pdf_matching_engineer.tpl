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
{% set first_range = 10 %}
{% set page_top_padding = 0 %}

<div style="height: {{ first_page_height }}pt;">
    <h1 style="text-align: center;  margin-bottom: 50px">要員マッチング 一覧</h1>
    <div class="" style="margin-top: 50px">
        {% if data['project.enumProjects'] %}
            {% set items = data['project.enumProjects'][0:1] %}
            {% for item in items %}
                <ul style="margin-top: 0.5em; padding: 0.3em 0.5em; background-color: #f1f1f1; list-style-type: none;/* font-size: 11px;*/ overflow: hidden;">
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_name" style="color: #666666;">案件名</label>
                        {{ item.title|e}}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_name" style="color: #666666;">取引先企業</label>
                        {{ item.client_name|e}}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_name" style="color: #666666;">請求単価</label>
                        {% if item.fee_inbound %}{{ item.fee_inbound_comma|e }}{% endif %}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_name" style="color: #666666;">支払単価</label>
                        {% if item.fee_outbound %}{{ item.fee_outbound_comma|e }}{% endif %}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_name" style="color: #666666;">期間</label>
                        {% if item.term_begin %}{{ item.term_begin|e }}{% endif %}
                         〜
                        {% if item.term_end %}{{ item.term_end|e }}{% endif %}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_name" style="color: #666666;">要求年齢</label>
                        {% if item.age_from %}{{ item.age_from|e }}{% endif %}
                         〜
                        {% if item.age_to %}{{ item.age_to|e }}{% endif %}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_station" style="color: #666666;">最寄駅</label>
                        {{ item.station|e }}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_skill" style="color: #666666;">要求職種</label>
                        {% if item.occupation_list %}{{ item.occupation_list|e }}{% endif %}
                    </li>
                    <li style="margin: 0 2em; float: left;">
                        <label for="query_skill" style="color: #666666;">要求スキル</label>
                        {% if item.skill_list %}{{ item.skill_list|e }}{% endif %}
                    </li>
                </ul>
            {% endfor %}
        {% endif %}
        <table class="view_table table-bordered" width="100%" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd" id="detail-table">
            <thead>
            <tr id="detail-table-first" style="background-color: #eaeaea;">
                <th style="font-weight: inherit; font-size: small; width: 10%;">要員名<br/> 要員短縮名</th>
                <th style="font-weight: inherit; font-size: small; width: 10%;">職種</th>
                <th style="font-weight: inherit; font-size: small; width: 10%;">所属企業</th>
                <th style="font-weight: inherit; font-size: small; width: 8%;">所属</th>
                <th style="font-weight: inherit; font-size: small; width: 25%;">スキル</th>
                <th style="font-weight: inherit; font-size: small; width: 8%;">稼働</th>
                <th style="font-weight: inherit; font-size: small; width: 8%;">単価</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">年齢</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">性別</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">最寄駅</th>
                <th style="font-weight: inherit; font-size: small; width: 6%;">営業担当者</th>
            </thead>
            <tbody id="detail-table-body">
                {% for item in data['operation.enumEngineers'][0:first_range] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.owner_company_id == data["auth.userProfile"].company.id %}{{ item.name|e }}<br/>{% endif %}{{ item.visible_name|e }}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.occupation_list != None %}{{ item.occupation_list|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.owner_company_id != data["auth.userProfile"].company.id %}
                                {{ item.company_name|truncate(10, True)|e }}
                            {% else %}
                                {% if item.client_name %}
                                    {{ item.client_name }}
                                {% else %}
                                    {{ item.company_name|truncate(10, True)|e }}
                                {% endif %}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: left;">{{ item.contract }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 25%; text-align: left;">{% if item.skill_list != None %}{{ item.skill_list|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">{% if item.operation_begin != None %}{{ item.operation_begin|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">{{ item.fee_comma }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.age %}{{ item.age }}歳{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{{ item.gender }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">
                            {% if item.station != None %}
                                {{ item.station|e }}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 6%; text-align: left;">
                            {% if item.charging_user %}
                                {{ item.charging_user.user_name|e }}
                            {% endif %}
                        </td>
                    </tr>
                {% endfor %}
            </tbody>
        </table>
    </div>
</div>
<div class="" style="height: 18pt;width: 100%; margin: 0pt; text-align: center;">
    {% if data['operation.enumEngineers']|length > first_range %}
        {% set max_page = ((((data['operation.enumEngineers']|length) - first_range) / first_range) | round(0, 'ceil') + 1 )|int %}
        <span>　1/{{ max_page }}</span>
    {% else %}
        <span>1/1</span>
    {% endif %}
</div>
{% if data['operation.enumEngineers']|length > first_range %}
    {% set total_loop = (((data['operation.enumEngineers']|length) - first_range) / first_range) | round(0, 'ceil')|int %}
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
                    <th style="font-weight: inherit; font-size: small; width: 10%;">要員名<br/> 要員短縮名</th>
                    <th style="font-weight: inherit; font-size: small; width: 10%;">職種</th>
                    <th style="font-weight: inherit; font-size: small; width: 10%;">所属企業</th>
                    <th style="font-weight: inherit; font-size: small; width: 8%;">所属</th>
                    <th style="font-weight: inherit; font-size: small; width: 25%;">スキル</th>
                    <th style="font-weight: inherit; font-size: small; width: 8%;">稼働</th>
                    <th style="font-weight: inherit; font-size: small; width: 8%;">単価</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">年齢</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">性別</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">最寄駅</th>
                    <th style="font-weight: inherit; font-size: small; width: 6%;">営業担当者</th>
                </thead>
                <tbody id="detail-table-body">
                {% set view_range_start = def_view_range_start + (def_view_range * (loop.index - 1)) %}
                {% set view_range_end = def_view_range_end + (def_view_range * (loop.index - 1)) %}
                {% for item in data['operation.enumEngineers'][view_range_start:view_range_end] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.owner_company_id == data["auth.userProfile"].company.id %}{{ item.name|e }}<br/>{% endif %}{{ item.visible_name|e }}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.occupation_list != None %}{{ item.occupation_list|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: left;">
                            {% if item.owner_company_id != data["auth.userProfile"].company.id %}
                                {{ item.company_name|truncate(10, True)|e }}
                            {% else %}
                                {% if item.client_name %}
                                    {{ item.client_name }}
                                {% else %}
                                    {{ item.company_name|truncate(10, True)|e }}
                                {% endif %}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: left;">{{ item.contract }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 25%; text-align: left;">{% if item.skill_list != None %}{{ item.skill_list|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">{% if item.operation_begin != None %}{{ item.operation_begin|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">{{ item.fee_comma }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.age %}{{ item.age }}歳{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{{ item.gender }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">
                            {% if item.station != None %}
                                {{ item.station|e }}
                            {% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 6%; text-align: left;">
                            {% if item.charging_user %}
                                {{ item.charging_user.user_name|e }}
                            {% endif %}
                        </td>
                    </tr>
                {% endfor %}
                </tbody>
            </table>
        </div>
    </div>
    <div class="" style="height: 18pt;width: 100%; margin: 0pt; text-align: center;">
        {% set max_page = ((((data['operation.enumEngineers']|length) - first_range) / first_range) | round(0, 'ceil') + 1)|int  %}
        {% set current_page = 1 + loop.index %}
        <span>　{{ current_page }}/{{ max_page }}</span>
    </div>
    {% endfor %}
{% endif %}
</body>
</html>