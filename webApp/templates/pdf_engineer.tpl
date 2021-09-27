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
{% set first_range = 20 %}
{% set page_top_padding = 0 %}

<div style="height: {{ first_page_height }}pt;">
    <h1 style="text-align: center;  margin-bottom: 50px">要員 一覧</h1>
    <div class="" style="margin-top: 50px">
        <table class="view_table table-bordered" width="100%" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd" id="detail-table">
            <thead>
            <tr id="detail-table-first" style="background-color: #eaeaea;">
                <th style="font-weight: inherit; font-size: small; width: 15%;">要員名（短縮名）</th>
                <th style="font-weight: inherit; font-size: small; width: 20%;">所属</th>
                <th style="font-weight: inherit; font-size: small; width: 30%;">スキル</th>
                <th style="font-weight: inherit; font-size: small; width: 10%;">稼働</th>
                <th style="font-weight: inherit; font-size: small; width: 10%;">単価</th>
                <th style="font-weight: inherit; font-size: small; width: 15%;">年齢<br/>（性別）</th>
            </thead>
            <tbody id="detail-table-body">
                {% for item in data['operation.enumEngineers'][0:first_range] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 15%; text-align: left;">{{ item.visible_name|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 20%; text-align: center;">{{ item.contract }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 30%; text-align: left;">{% if item.skill_list %}{{ item.skill_list|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 15%; text-align: center;">{% if item.operation_begin %}{{ item.operation_begin|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: center;">{{ item.fee_comma }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: center;">{% if item.age %}{{ item.age }}歳<br/>{% endif %}（{{ item.gender }}）</td>
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
                <tr id="detail-table-first" style="background-color: #eaeaea;">
                    <th style="font-weight: inherit; font-size: small; width: 15%;">要員名（短縮名）</th>
                    <th style="font-weight: inherit; font-size: small; width: 20%;">所属</th>
                    <th style="font-weight: inherit; font-size: small; width: 30%;">スキル</th>
                    <th style="font-weight: inherit; font-size: small; width: 15%;">稼働</th>
                    <th style="font-weight: inherit; font-size: small; width: 10%;">単価</th>
                    <th style="font-weight: inherit; font-size: small; width: 10%;">年齢<br/>（性別）</th>
                </thead>
                <tbody id="detail-table-body">
                {% set view_range_start = def_view_range_start + (def_view_range * (loop.index - 1)) %}
                {% set view_range_end = def_view_range_end + (def_view_range * (loop.index - 1)) %}
                {% for item in data['operation.enumEngineers'][view_range_start:view_range_end] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 15%; text-align: left;">{{ item.visible_name|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 20%; text-align: center;">{{ item.contract }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 30%; text-align: left;">{% if item.skill_list %}{{ item.skill_list|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 15%; text-align: center;">{% if item.operation_begin %}{{ item.operation_begin|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: center;">{{ item.fee_comma }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 10%; text-align: center;">{% if item.age %}{{ item.age }}歳<br/>{% endif %}（{{ item.gender }}）</td>
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