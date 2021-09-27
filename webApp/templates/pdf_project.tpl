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
    <h1 style="text-align: center;  margin-bottom: 50px">案件 一覧</h1>
    <div class="" style="margin-top: 50px">
        <table class="view_table table-bordered" width="100%" style="border-collapse: collapse;" class="" border="1" bordercolor="#ddd" id="detail-table">
            <thead>
            <tr id="detail-table-first" style="background-color: #eaeaea;">
                <th style="font-weight: inherit; font-size: small; width: 20%;">案件内容</th>
                <th style="font-weight: inherit; font-size: small; width: 30%;">スキル</th>
                <th style="font-weight: inherit; font-size: small; width: 8%;">商流</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">期間</th>
                <th style="font-weight: inherit; font-size: small; width: 15%;">請求単価<br/>／支払単価</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">面談<br/>回数</th>
                <th style="font-weight: inherit; font-size: small; width: 12%;">最寄駅</th>
                <th style="font-weight: inherit; font-size: small; width: 5%;">外国籍</th>
            </thead>
            <tbody id="detail-table-body">
                {% for item in data['operation.enumProjects'][0:first_range] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 20%; text-align: left;">{{ item.title }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 30%; text-align: left;">{% if item.skill_list %}{{ item.skill_list|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">{{ (item.scheme or "")|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.term_begin %}{{ item.term_begin|e }}{% endif %}
                            〜
                            {% if item.term_end %}{{ item.term_end|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 15%; text-align: center;">{{ item.fee_inbound_comma|e }}<br/>／{{ item.fee_outbound_comma|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{{ item.interview|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: center;">{% if item.station != None %}{{ item.station|e }}{% endif %}</td>
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
                    <th style="font-weight: inherit; font-size: small; width: 20%;">案件内容</th>
                    <th style="font-weight: inherit; font-size: small; width: 30%;">スキル</th>
                    <th style="font-weight: inherit; font-size: small; width: 8%;">商流</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">期間</th>
                    <th style="font-weight: inherit; font-size: small; width: 15%;">請求単価<br/>／支払単価</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">面談<br/>回数</th>
                    <th style="font-weight: inherit; font-size: small; width: 12%;">最寄駅</th>
                    <th style="font-weight: inherit; font-size: small; width: 5%;">外国籍</th>
                </thead>
                <tbody id="detail-table-body">
                {% set view_range_start = def_view_range_start + (def_view_range * (loop.index - 1)) %}
                {% set view_range_end = def_view_range_end + (def_view_range * (loop.index - 1)) %}
                {% for item in data['operation.enumProjects'][view_range_start:view_range_end] %}
                    <tr id="">
                        <td style="font-weight: inherit; font-size: small; width: 20%; text-align: left;">{{ item.title }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 30%; text-align: left;">{% if item.skill_list %}{{ item.skill_list|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 8%; text-align: center;">{{ (item.scheme or "")|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.term_begin %}{{ item.term_begin|e }}{% endif %}
                            〜
                            {% if item.term_end %}{{ item.term_end|e }}{% endif %}
                        </td>
                        <td style="font-weight: inherit; font-size: small; width: 15%; text-align: center;">{{ item.fee_inbound_comma|e }}<br/>／{{ item.fee_outbound_comma|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{{ item.interview|e }}</td>
                        <td style="font-weight: inherit; font-size: small; width: 12%; text-align: center;">{% if item.station != None %}{{ item.station|e }}{% endif %}</td>
                        <td style="font-weight: inherit; font-size: small; width: 5%; text-align: center;">{% if item.flg_foreign == 1 %}可{%elif item.flg_foreign == 0 %}不可{% else %}{% endif %}</td>
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