{% import "cmn_controls.macro" as buttons -%}
<!DOCTYPE html>
<html lang="ja">
{% include "cmn_head.tpl" %}
<body>
	<style>
        .popover-content {
            max-height: 200px;
            overflow: auto;
        }
    </style>
{% include "cmn_header.tpl" %}
<div class="container-fluid">
    <div class="row">
        <div class="container" style="margin-bottom:100px;">
            <!-- レフトナビ -->
            <div class="col-sm-2 col-lg-2" style="padding-left: 5px;padding-right: 5px" id="nav-search">
                <nav class="navbar navbar-default navbar-fixed-side" style="height: 100%">
                    <div class="navbar-header">
                        <button class="navbar-toggle" data-target=".navbar-collapse" data-toggle="collapse">
                            <span class="sr-only">絞込み条件</span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                            <span class="icon-bar"></span>
                        </button>
                        <a class="navbar-brand">絞込み条件</a>
                    </div>
                    <div class="collapse navbar-collapse navbar-left" style="width: 100%; max-height: none">
                        <form class="">
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>キーワード検索</label><br/>
                                <input type="text" id="search_keyword" onchange="" name="search_keyword" value="" style="width: 100%"><br/><br/>
                                <span class="btn" style="width:70px" onclick="searchProjects();">検索&nbsp;<span class="glyphicon glyphicon-search"></span></span>
                                <span class="btn" style="width:70px" onclick="clearSearchCondition();">クリア&nbsp;<span class="glyphicon glyphicon-refresh"></span></span>
                            </div>
                            {% if data['occupation.enumOccupations'] %}
                             <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                 <label>職種</label><br/>
                                 {% for item in data['occupation.enumOccupations'] %}
                                     <input type="checkbox" name="search_occupation[]" onchange="" id="search_occupation_{{ item.id }}" class="search-chk" value="{{ item.id }}"> <label for="search_occupation_{{ item.id }}" style="margin: 0px; font-weight: normal;font-size: x-small;cursor: pointer;">{{ item.name }}</label><br/>
                                 {% endfor %}
                            </div>
                            {% endif %}
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>スキル</label>
                                <span style="width: 30%">{{ buttons.add_obj2("editSearchSkillCondition();") }}</span><br/>
                                <span id="selected_skill_list" style="word-break: break-all;"></span>
                                </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>稼働時期</label><br/>
                                <input type="text" id="search_term_begin" onchange="" name="search_term_begin" value="" style="width: 100%" data-date-format="yyyy/mm/dd" ><br/>
                                〜<br/>
                                <input type="text" id="search_term_end" onchange="" name="search_term_end" value="" style="width: 100%" data-date-format="yyyy/mm/dd" ><br/>
                            </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>単価（万）</label><br/>
                                <input id="amount_from" onchange="" name="search_amount_from" type="number" style="width: 65px">〜<input id="amount_to" onchange="" name="search_amount_to" type="number" style="width: 65px"><br/>
                                <div id="slider-range-amount" style="margin-top: 10px"></div>
                                <br/>
                            </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>年齢</label><br/>
                                <input id="age_from" onchange="" name="search_age_from" type="number" style="width: 50px">〜<input id="age_to" onchange="" name="search_age_to" type="number" style="width: 50px">歳<br/>
                                <div id="slider-range-age" style="margin-top: 10px"></div>
                                <br/>
                            </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>性別</label><br/>
                                <input type="checkbox" onchange="" name="search_gender[]" id="search_gender_1" class="search-chk" value="男"><label for="search_gender_1" style="margin: 0px; font-weight: normal;font-size: normal;cursor: pointer;">　男</label><br/>
                                <input type="checkbox" onchange="" name="search_gender[]" id="search_gender_2" class="search-chk" value="女"><label for="search_gender_2" style="margin: 0px; font-weight: normal;font-size: normal;cursor: pointer;">　女</label><br/>
                            </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>所属企業</label>
                                <span style="width: 30%">{{ buttons.add_obj2("editSearchClientAndCompanyCondition();") }}</span><br/>
                                <span id="selected_client_and_company_list" style="word-wrap: break-word;"></span>
{#                                <span class="search-tag-double" >#}
{#                                    <span class="" >株式会社ブルームソフト</span>#}
{#                                    <span class="glyphicon glyphicon-remove" onclick="" ></span>#}
{#                                </span>#}
                            </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>備考検索</label><br/>
                                <input type="text" id="search_note" onchange="" name="search_note" value="" style="width: 100%"><br/><br/>
                                <span class="btn" style="width:70px" onclick="searchProjects();">検索&nbsp;<span class="glyphicon glyphicon-search"></span></span>
                                <span class="btn" style="width:70px" onclick="clearSearchCondition();">クリア&nbsp;<span class="glyphicon glyphicon-refresh"></span></span>
                            </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>所属</label><br/>
                                <input type="checkbox" onchange="" name="search_contract[]" id="search_contract_1" class="search-chk" value="正社員(契約社員)"> <label for="search_contract_1" style="margin: 0px; font-weight: normal;font-size: x-small;cursor: pointer;">正社員(契約社員)</label><br/>
                                <input type="checkbox" onchange="" name="search_contract[]" id="search_contract_2" class="search-chk" value="個人事業主"> <label for="search_contract_2" style="margin: 0px; font-weight: normal;font-size: x-small;cursor: pointer;">個人事業主</label><br/>
                                <input type="checkbox" onchange="" name="search_contract[]" id="search_contract_3" class="search-chk" value="パートナー"> <label for="search_contract_3" style="margin: 0px; font-weight: normal;font-size: x-small;cursor: pointer;">パートナー</label><br/>
                            </div>
                            <div class="" style="border-bottom: solid 2px #e7e7e7; margin-bottom: 20px; padding-bottom: 20px">
                                <label>要員名</label>
                                <span
                                    class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
                                    data-toggle="popover" data-content="漢字/カナ/イニシャルで検索いただけます"
                                    data-placement="top"
                                    onmouseover="$(this).popover('show');"
                                    onmouseout="$(this).popover('hide');"
                                    data-original-title="" title="">
                                    </span>
                                <br/>
                                <input type="text" id="search_engineer_name" onchange="" name="search_engineer_name" class="search-chk" value="" style="width: 70%">
                                <span style="width: 30%"><span class="btn" style="width:30px" onclick="searchProjects();"><span class="glyphicon glyphicon-search"></span></span></span><br/>
{#                                <span class="search-tag">山田太郎 <span class="glyphicon glyphicon-remove" onclick=""></span></span><br/>#}
                            </div>
                            <div class="hidden" style=" margin-bottom: 20px; padding-bottom: 20px">
                                <label>最寄駅</label><br/>
                                <input type="radio" onchange="" name="search_travel_time[]" class="search-chk" value="15"> 15分<br/>
                                <input type="radio" onchange="" name="search_travel_time[]" class="search-chk" value="30"> 30分<br/>
                                <input type="radio" onchange="" name="search_travel_time[]" class="search-chk" value="45"> 45分<br/>
                                <input type="radio" onchange="" name="search_travel_time[]" class="search-chk" value="60"> 60分<br/>
                                <input type="radio" onchange="" name="search_travel_time[]" class="search-chk" value="75"> 75分<br/>
                                <input type="radio" onchange="" name="search_travel_time[]" class="search-chk" value="90"> 90分〜<br/>

                                <input type="hidden" id="search_station_lat">
                                <input type="hidden" id="search_station_lon">
                                <input type="hidden" id="search_station">
                            </div>
                            <div class="" style="margin-bottom: 20px; padding-bottom: 20px">
                                <span class="btn" style="width:70px" onclick="searchProjects();">検索&nbsp;<span class="glyphicon glyphicon-search"></span></span>
                                <span class="btn" style="width:70px" onclick="clearSearchCondition();">クリア&nbsp;<span class="glyphicon glyphicon-refresh"></span></span>
                            </div>
                        </form>
                    </div>
                </nav>
            </div>
            <!-- /レフトナビ -->
            <!-- メインコンテンツ -->
            <div class="col-sm-10 col-lg-10">
                <div class="row" style="padding-left: 15px">
				    <img alt="要員マッチング検索" width="22" height="20" src="/img/icon/group_person.png"> 要員マッチング検索
                    <span class="pull-right popover-video"
                        data-toggle="popover"
                        data-placement="right"
                        data-content="<a href='#' style='font-weight: bold' class='video-matching-engineer'>要員マッチング</a>"
                        data-html="true"><a href="#" style="font-weight: bold" onclick="c4s.hdlClickDirectionBtn('home.direction');">解説動画はコチラ≫</a>
                    </span>
			    </div>
                <div class="row" style="padding-left: 15px;margin-top: 10px;">
                    <a>他社公開案件は、青とオレンジで表示されます。（青=有料会員、オレンジ=無料会員）</a>
                </div>
                {% if data['project.enumProjects'] %}
                    {% set items = data['project.enumProjects'][0:1] %}
                    {% for item in items %}

                        <form onsubmit="c4s.hdlClickSearchBtn(); return false;">
                            <input type="hidden" id="search_project_id" value="{{ item.id|e }}">
                            <input type="hidden" id="iter_project_selected_cb_{{ item.id }}"/>
                            <input type="hidden" id="search_project_owner_{{ item.id }}" value="{{ item.owner_company_id|e }}"/>
                            <input type="hidden" id="search_project_worker_{{ item.id }}" value="{{ item.worker_id_list|e }}"/>
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
                        </form>
                    {% endfor %}
                {% endif %}
                <div class="row">
                    <div class="container" style="margin-bottom:100px;margin-top:10px;">
                        <!-- 検索結果ヘッダー -->
                        <div class="row" style="margin-bottom: 0.5em;">
                            <div class="col-lg-7">
{#                                {% if data['project.enumProjects'] %}#}
{#                                    {{ buttons.assign("assignToProject();", "対象データを選択し、「アサイン」ボタンを押下すると該当の要員をプロジェクトに登録できます") }}#}
{#                                {% endif %}#}
                                {{ buttons.mail_all("openMailFormOfEngineer();", "対象データを選択し、「一括メール」ボタンを押下すると取引先へメールできます") }}
                                <span class="btn" onclick="exportPdfEngineer();" style="width: 100px">レポート作成&nbsp;<span class="glyphicon glyphicon-file"></span></span>
                                <span style="font-size: small">
                                    <span >　　</span>
                                    <input type="checkbox" id="search_flg_skill_level" value="1"/>
                                    <label for="search_flg_skill_level">スキル+経験年数で検索する</label>
                                </span>
                            </div>
                            <!-- 件数 -->
                            {{ buttons.paging(query, env, data['engineer.enumEngineers']) }}
                            <!-- /件数 -->
                        </div>
                        <!-- /検索結果ヘッダー -->
                        <table class="view_table table-bordered table-hover">
                            <thead>
                                <tr style="width: 100%;">
                                    <th style="width: 5%;">選択<br/><input type="checkbox" id="iter_engineer_selected_cb_0" onclick="c4s.toggleSelectAll('iter_engineer_selected_cb_', this);"/></th>
                                    <th style="width: 10%;">
                                        {{ buttons.th(query, '要員名', 'kana') }}<br/>要員短縮名<br/>
																				<span class="popover-dismiss glyphicon glyphicon-exclamation-sign text-warning pseudo-link-cursor"
																					data-toggle="popover"
																					data-placement="bottom"
																					data-content="『要員名』クリックで要員詳細を表示出来ます。"
																					onmouseover="$(this).popover('show');"
																					onmouseout="$(this).popover('hide');"></span>
                                    </th>
                                    <th style="width: 10%;">
                                        {{ buttons.th(query, '職種', 'occupation_count') }}
                                    </th>
                                    <th style="width: 10%;">
                                        {{ buttons.th(query, '所属企業', 'company_name') }}
                                    </th>
                                    <th style="width: 8%;">
                                        {{ buttons.th(query, '所属', 'contract') }}
                                    </th>
                                    <th style="width: 10%;">
                                        {{ buttons.th(query, 'スキル', 'skill_count') }}
                                    </th>
                                    <th style="width: 5%;">{{ buttons.th(query, '稼働', 'operation_begin') }}</th>
                                    <th style="width: 5%;">
                                        {{ buttons.th(query, '単価', 'fee') }}
                                    </th>
                                    <th style="width: 5%;">{{ buttons.th(query, '年齢', 'age') }}</th>
                                    <th style="width: 5%;">{{ buttons.th(query, '性別', 'gender') }}</th>
                                    <th style="width: 5%;">最寄駅</th>
                                    <th style="width: 5%;" class="hidden">{{ buttons.th(query, '移動時間', 'travel_time') }}</th>
                                    <th style="width: 5%">{{ buttons.th(query, '営業担当者', 'charging_user_id') }}</th>
                                    <th style="width: 2%"></th>
                                    <th style="width: 5%">経歴書</th>
                                    {% if data["auth.userProfile"].user.is_admin == True and data["auth.userProfile"].company.prefix == 'gw' %}
                                    <th style="width: 5%">他社公開</th>
                                    {% endif %}
                                </tr>
                            </thead>
                            <tbody>
                            {% if data['engineer.enumEngineers'] %}
                                {% set row_min = env.limit.ROW_LENGTH * ((query.pageNumber or 1) - 1) %}
					            {% set items = data['engineer.enumEngineers'][row_min:row_min + env.limit.ROW_LENGTH] %}
					            {% for item in items %}
                                <tr {% if item.create_from_promo == 1 %} style="background-color:rgba(255, 230, 153, 1)" {% elif item.owner_company_id != data["auth.userProfile"].company.id %} style="background-color:rgba(3, 169, 244, 0.15)" {% endif %}>
                                    <td class="center">
                                        <input type="checkbox" id="iter_engineer_selected_cb_{{ item.id }}"/>
                                        {% if item.owner_company_id != data["auth.userProfile"].company.id %}
                                            <input type="hidden" id="search_engineer_user_{{ item.id }}" value="{{ item.user_id_list|e }}"/>
                                        {% else %}
                                            <input type="hidden" id="search_engineer_worker_{{ item.id }}" value="{{ item.worker_id_list|e }}"/>
                                        {% endif %}
                                    </td>
                                    <td>

{#                                        {% if item.owner_company_id == data["auth.userProfile"].company.id %}#}
{#                                        <span id="assign_{{ item.id }}"#}
{#                                              data-toggle="popover"#}
{#                                              data-content="すでにアサイン済みの案件があります。"#}
{#                                              onmouseover="$(this).popover('show');"#}
{#                                              onmouseout="$(this).popover('hide');"#}
{#                                              class="glyphicon glyphicon-ok text-success hidden"></span>#}
{#                                        {{ item.name|e }}<br/>#}
{#                                        {% endif %}#}
                                        <span class="pseudo-link bold"
																					onclick="overwriteModalForEditE({{ item.id }});"
	                                        >{% if item.owner_company_id == data["auth.userProfile"].company.id %}{{ item.name|e }}<br/>{% endif %}{{ item.visible_name|e }}</span>
                                    </td>
	<!-- [begin] Modal. -->
	<div id="edit_engineer_modal_{{ item.id }}" class="modal fade"
		role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
		<div class="modal-dialog">
			<div class="modal-content">
				<div class="modal-header">
					<ul class="pull-right" style="list-style-type: none; overflow: hidden;">
						<li style="margin: 0 0.5em; float: left;">
							<button type="button" class="close" data-dissmiss="modal"
								onclick="$('#edit_engineer_modal_{{ item.id }}').modal('hide');">
								<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
							</button>
						</li>
					</ul>
					<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_engineer_modal_title">新規要員登録</span></h4>
				</div><!-- div.modal-header -->
				<div class="modal-body">
					<input type="hidden" id="m_engineer_id"/>
					<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
						<li class="input-group" style="width: 50%; margin: 0; padding: 0; float: left;">
							<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">要員名<br>（短縮表示名）<span class="text-danger">*</span></span>
							<input type="text" class="form-control" id="m_engineer_visible_name" placeholder="ST" value="{{ item.name|e }}" disabled/>
						</li>
            <li class="input-group " style="width: 50%; margin: 0; padding: 0; float: left;">
                <span class="input-group-addon"style="min-width: 100px;">所属</span>
								<input type="text" class="form-control" id="m_engineer_contract" value="{{ item.contract|e }}" disabled/>
						</li>
					</ul>
          <div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;">所属先 <span class="text-danger">*</span></span>
						<input type="text" class="form-control" id="m_engineer_client_id" value="{%- if item.owner_company_id != data["auth.userProfile"].company.id -%}{{ item.company_name|e }}{%- else %}{%- if item.client_name %}{{ item.client_name|e }}{%- else %}{{ item.company_name|e }}
								{%- endif %}
						{%- endif %}" disabled/>
					</div>
          <div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;">スキル</span>
						<input type="text" class="form-control" id="m_engineer_skill" value="{% if item.skill_list != None %}{{ item.skill_list|e }}{% endif %}" disabled/>
					</div>
          <div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;">職種</span>
						<input type="text" class="form-control" id="m_engineer_occupation" value="{% if item.occupation_list != None %}{{ item.occupation_list|e }}{% endif %}" disabled/>
					</div>
					<ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
						<li class="input-group" style="width: 60%; margin: 0; padding: 0; float: left;">
							<span class="input-group-addon" style="min-width: 100px;">誕生日</span>
							<input class="form-control" id="m_engineer_birth" readOnly="readOnly" type="text"
								data-date-format="yyyy/mm/dd" value="{{ item.birth|e }}"/>
						</li>
						<li class="input-group" style="width: 40%; margin: 0; padding: 0; float: left;">
							<span class="input-group-addon">年齢</span>
							<input type="number" class="form-control" id="m_engineer_age" style="text-align: center;" min="0" max="99" pattern="\d+" value="{{ item.age|e }}" disabled/>
							<span class="input-group-addon">歳</span>
						</li>
					</ul>
          <ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
              <li class="input-group" style="width: 40%; margin: 0; padding: 0;float: left;" id="m_engineer_gender_container">
                  <span class="input-group-addon">性別</span>
                  <input type="text" class="form-control" id="m_engineer_gender_01" value="{{ item.gender }}" disabled/>
                  </span>
              </li>
						<li class="input-group" style="width: 30%; margin: 0; padding: 0; float: left;">
							<span class="input-group-addon">単価</span>
							<input type="text" class="form-control" id="m_engineer_fee" value="{{ item.fee_comma|e }}" disabled/>
						</li>
						<li class="input-group" style="width: 30%; margin: 0; padding: 0; float: left;">
							<span class="input-group-addon">最寄駅</span>
							<input type="text" class="form-control" id="m_engineer_station" value="{{ item.station|e }}" disabled/>
						</li>
					</ul>
          <div class="input-group">
						<span class="input-group-addon"style="min-width: 100px;">稼働開始日</span>
            <input type="text" class="form-control" id="m_engineer_operation_begin" data-date-format="yyyy/mm/dd" value="{% if item.operation_begin != None %}{{ item.operation_begin|e }}{% endif %}" disabled/>
					</div>
          <ul style="margin: 0; padding: 0; list-style-type: none; overflow: hidden;">
						<li class="input-group" style="width: 100%; float: left;">
							<span class="input-group-addon" style="min-width: 100px;">担当営業</span>
							<input type="text" class="form-control" id="m_engineer_charging_user" value="{% if item.charging_user %}{% if item.charging_user.is_enabled == False %}無効化されたユーザーです{% endif %}{{ item.charging_user.user_name|e }}{% endif %}" disabled/>
						</li>
          <div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;font-size: x-small;">メールアドレス</span>
						<input type="text" class="form-control" id="m_engineer_mail1" value="{{ item.mail1|e }}" disabled/>
					</div>
          <div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;">郵便番号</span>
						<input type="text" class="form-control" id="m_engineer_addr_vip" style="width: 8em;" maxlength="8" value="{{ item.addr_vip|e }}" disabled/>
					</div>
					<div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;">住所</span>
						<input type="text" class="form-control" id="m_engineer_addr1" value="{{ item.addr1|e }}" disabled/>
					</div>
					<div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;">ビル名</span>
						<input type="text" class="form-control" id="m_engineer_addr2" value="{{ item.addr2|e }}" disabled/>
					</div>
					<div class="input-group">
						<span class="input-group-addon"style="min-width: 100px;font-size: smaller;">アサイン可能<br>フラグ</span>
						{% if item.flg_assignable == 1 %}
						<input type="text" class="form-control" id="m_engineer_flg_assignable" value="アサイン可能" style="" readonly="readonly"/>
						{% else %}
						<input type="text" class="form-control" id="m_engineer_flg_assignable" value="アサイン不可" style="" readonly="readonly"/>
						{% endif %}
					</div>
          <div class="input-group">
						<span class="input-group-addon"style="min-width: 100px;font-size: x-small;">他社公開フラグ</span>
						{% if item.flg_public == 1 %}
						<input type="text" class="form-control" id="m_project_term_end" value="他社公開中" style="" readonly="readonly"/>
	          {% else %}
	          <input type="text" class="form-control" id="m_project_term_end" value="他社非公開" style="" readonly="readonly"/>
	          {% endif %}
					</div>
          <div class="input-group">
						<span class="input-group-addon"style="min-width: 100px;">経歴書</span>
						{% if item.attachement %}
								<span class="glyphicon glyphicon-file pseudo-link-cursor" style="color: #2a98c5;"
										title="添付ファイル：{{ item.attachement.name|e }}({{ item.attachement.size }}bytes)"
										onclick="c4s.downloadAll({{ item.attachement.id }})"></span>
						{% else %}
								<span class="glyphicon glyphicon-file pseudo-link-cursor text-muted" title="添付ファイルはありません"></span>
						{% endif %}
					</div>
					<div class="input-group">
						<span class="input-group-addon" style="min-width: 100px;">備考</span>
						<textarea class="form-control" id="m_engineer_note" style="height: 8em;" disabled>{{ '\n'.join(item.note.split('\n'))|e if item.note else '' }}</textarea>
					</div>
				</div><!-- div.modal-body -->
				<div class="modal-footer">
					<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
				</div><!-- div.modal-footer -->
			</div><!-- div.modal-content -->
		</div><!-- div.modal-dialog -->
	</div><!-- div.modal -->

                                    <td style="word-break: break-word;">{% if item.occupation_list != None %}{{ item.occupation_list|e }}{% endif %}</td>
                                    <td>
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
                                    <td>{{ item.contract }}</td>
                                    <td class="center" style="word-break: break-word;">{% if item.skill_list != None %}{{ item.skill_list|e }}{% endif %}</td>
                                    <td class="center">{% if item.operation_begin != None %}{{ item.operation_begin|e }}{% endif %}</td>
                                    <td class="center">{{ item.fee_comma }}</td>
                                    <td class="center">{% if item.age %}{{ item.age }}歳{% endif %}</td>
                                    <td class="center">{{ item.gender }}</td>
                                    <td>
                                        {% if item.station != None %}
                                            {% if data['project.enumProjects'] %}
                                                <a class="pseudo-link" onclick="jumpSearchProjectTransit('{{ item.station|e }}');">{{ item.station|e }}</a>
                                            {% else %}
                                                {{ item.station|e }}
                                            {% endif %}
                                        {% endif %}
                                    </td>
                                    <td class="center hidden">
                                        {% if item.travel_time == "--" or item.travel_time == 0 %}
                                            {{ item.travel_time|e }}
                                        {% else %}
                                            <a class="pseudo-link" onclick="jumpSearchEngineerTransit('{{ item.station|e }}');">{{ item.travel_time|e }}</a>
                                        {% endif %}
                                    </td>
                                    <td class="">
                                        {% if item.charging_user %}
                                            {% if item.charging_user.is_enabled == False %}
                                            <span class="glyphicon glyphicon-ban-circle text-danger" title="無効化されたユーザーです"></span>&nbsp;
                                            {% endif %}
                                            <span title="{{ item.charging_user.login_id|e }}">{{ item.charging_user.user_name|e }}</span>
                                        {% endif %}
                                    </td>
                                    <td class="text-center show-popover"><span class="glyphicon glyphicon-phone pseudo-link-cursor"
                                     		data-toggle="popover"
											data-placement="top"
											data-content="{{ item.company_tel }}"
											onmouseover="$(this).popover('show');"
											onmouseout="$(this).popover('hide');"></span></td>
                                    <td class="text-center">
                                        {% if item.attachement %}
                                            <span class="glyphicon glyphicon-file pseudo-link-cursor" style="color: #2a98c5;"
                                                title="添付ファイル：{{ item.attachement.name|e }}({{ item.attachement.size }}bytes)"
                                                onclick="c4s.downloadAll({{ item.attachement.id }})"></span>
                                        {% else %}
                                            <span class="glyphicon glyphicon-file pseudo-link-cursor text-muted" title="添付ファイルはありません"></span>
                                        {% endif %}
                                    </td>
                                    {% if data["auth.userProfile"].user.is_admin == True and data["auth.userProfile"].company.prefix == 'gw' %}
                                    <td class="text-center">
                                        <span class="glyphicon glyphicon-share-alt text-success pseudo-link-cursor" onclick="hdlClickPublicEngineerToggle({{ item.id}});"></span>
                                    </td>
                                    {% endif %}
                                </tr>
                                {% endfor %}
                            {% else %}
                                <tr>
                                    <td colspan="13">有効なデータがありません</td>
                                </tr>
                            {% endif %}
                            </tbody>
                        </table>
                        <div class="row" style="margin-top: 0.5em;">
                            <!-- 件数 -->
                            {{ buttons.paging(query, env, data['engineer.enumEngineers']) }}
                            <!-- /件数 -->
                        </div>
                    </div>
                </div>
            </div>
            <!-- /メインコンテンツ -->
        </div>
    </div>
</div>

{% include "edit_search_skill_condition_modal.tpl" %}

<div id="edit_search_client_and_company_condition_modal" class="modal fade"
	role="dialog" aria-hidden="true" data-keyboard="false" data-backdrop="static">
	<div class="modal-dialog">
		<div class="modal-content">
			<div class="modal-header">
				<button type="button" class="close" data-dissmiss="modal"
					onclick="$('#edit_search_client_and_company_condition_modal').modal('hide');">
					<span aria-hidden="true">&times;</span><span class="sr-only">閉じる</span>
				</button>
				<h4 class="modal-title"><span class="glyphicon glyphicon-plus-sign">&nbsp;</span><span id="edit_branch_modal_title">所属企業条件追加</span></h4>
			</div><!-- div.modal-header -->
			<div class="modal-body">
				<form>
                    <div class="container-fluid">
                        <div class="row">
{#                            {% if data['client.enumAllClients'] %}#}
{#                                 {% for item in data['client.enumAllClients'] %}#}
{#                                     <div class="col-md-6"><input type="checkbox" name="search_client[]" id="search_client_{{ item.id }}"　class="search-chk" onchange="viewSelectedClientAndCompany();" value="{{ item.id }}"> <label for="search_client_{{ item.id }}" id="client_{{ item.id }}" style="margin: 0px; font-weight: normal;cursor: pointer;">{{ item.name }}</label></div>#}
{#                                 {% endfor %}#}
{#                            {% endif %}#}
                            {% if data['manage.enumBpCompanies'] %}
                                {% set datam = data['manage.enumBpCompanies']|rejectattr('id', 'equalto', data["auth.userProfile"].company.id) %}
                                 {% for item in datam %}
                                     <div class="col-md-6"><input type="checkbox" checked="checked" name="search_company[]" id="search_company_{{ item.id }}" class="search-chk" onchange="viewSelectedClientAndCompany();" value="{{ item.id }}"> <label for="search_company_{{ item.id }}" id="company_{{ item.id }}" style="margin: 0px; font-weight: normal;cursor: pointer;">{{ item.name }}</label></div>
                                 {% endfor %}
                            {% endif %}
                        </div>
                    </div>
                </form>


			</div><!-- div.modal-body -->
			<div class="modal-footer">
                <span class="text-danger" style="font-size: small">※所属企業条件はCookieに保存され、条件をクリアしても保持されます。</span>
				<button type="button" class="btn btn-default" data-dismiss="modal">閉じる</button>
{#				<button type="button" class="btn btn-primary"#}
{#					onclick="commitBranch($('#m_branch_id').val() !== '');">保存</button>#}
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

{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
        <script type="text/javascript" src="/js/jquery-ui.js"></script>
        <script type="text/javascript" src="/js/jquery.ui.touch-punch.js"></script>
        <script type="text/javascript" src="/js/bootstrap-datepicker.js"></script>
        <script src="/js/bootstrap-datepicker.ja.js"></script>
		<script type="text/javascript" src="/js/quotation.js"></script>
        <script type="text/javascript" src="/js/matching.js"></script>

        <script>
            $(".popover-note").popover({ trigger: "manual" , html: true, animation:false})
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

            var search_conditions = JSON.parse('{{ data['matching.searchConditions']|tojson }}');
            env.data = env.data || {};
            env.data.skillCategories = JSON.parse('{{ data['skill.enumSkillCategories']|tojson }}');
            env.data.skillLevels = JSON.parse('{{ data['skill.enumSkillLevels']|tojson }}');
            c4s.loadSearchConditionFromCookie(search_conditions, env.current);

            var amount_from ="";
            var amount_to = "";
            var age_from = "";
            var age_to = "";

            var amount_min_default = 0;
            var amount_max_default = 200;
            var age_min_default = 18;
            var age_max_default = 80;

            var amount_max_dummy = false;
            var age_max_dummy = false;

            if("flg_skill_level" in search_conditions){
                if(search_conditions.flg_skill_level == "1"){
                    $("#search_flg_skill_level").prop('checked', true);
                }
            }

            if("rank_id" in search_conditions) {
                $('[name="search_rank[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.rank_id.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
            }

            if("occupation_id" in search_conditions) {
                $('[name="search_occupation[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.occupation_id.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
            }

            var skill_id_list = [];
            var skill_level_list = [];
            if("skill_id" in search_conditions) {
                skill_id_list = search_conditions.skill_id;
                skill_level_list = search_conditions.skill_level_list;
                $('[name="search_skill[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.skill_id.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                        $('#search_skill_level_' + setval).removeClass("hidden");
						search_conditions.skill_level_list.forEach(function(e, i, a) {
							if(setval == e["skill_id"]){
								$("#search_skill_level_" + setval).val(e["level"]);
							}
						})
                    }
                });
            }

            if("client_id" in search_conditions) {
                $('[name="search_client[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.client_id.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
            }

            if("client_id" in search_conditions) {
                $('[name="search_client[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.client_id.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
            }

{#            if("company_id" in search_conditions) {#}
{#                $('[name="search_company[]"]').each(function (index) {#}
{#                    var setval = $(this).val();#}
{#                    if (search_conditions.company_id.indexOf(setval) >= 0) {#}
{#                        $(this).val([setval]);#}
{#                    }#}
{#                });#}
{#            }#}
            if("not_company_id" in search_conditions) {
                $('[name="search_company[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.not_company_id.indexOf(setval) >= 0) {
                        $(this).prop('checked',false);
                    }
                });
            }

            if("gender" in search_conditions) {
                $('[name="search_gender[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.gender.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
            }

            if("contract" in search_conditions) {
                $('[name="search_contract[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.contract.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
                if (search_conditions.contract.indexOf('正社員') >= 0) {
                    $('#search_contract_1').prop('checked', true);
                }
            }

           if("travel_time" in search_conditions) {
                $('[name="search_travel_time[]"]').each(function (index) {
                    var setval = $(this).val();
                    if (search_conditions.travel_time.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
            }

            if("term_begin" in search_conditions){
                $("#search_term_begin").val(search_conditions.term_begin);
            }
            if("term_end" in search_conditions){
                $("#search_term_end").val(search_conditions.term_end);
            }

            if("station_lat" in search_conditions){
                $("#search_station_lat").val(search_conditions.station_lat);
            }
            if("station_lon" in search_conditions){
                $("#search_station_lon").val(search_conditions.station_lon);
            }
            if("station" in search_conditions){
                $("#search_station").val(search_conditions.station);
            }

            if("engineer_name" in search_conditions){
                $("#search_engineer_name").val(search_conditions.engineer_name);
            }

            if("amount_from" in search_conditions){
                amount_from = search_conditions.amount_from;
                if(amount_from < amount_min_default){
                    amount_min_default = amount_from;
                }
            }
            if("amount_to" in search_conditions){
                amount_to = search_conditions.amount_to;
                if(amount_to > amount_max_default){
                    amount_max_default = amount_to;
                }
            }else{
                amount_to = amount_max_default;
                amount_max_dummy = true;
            }
            if("age_from" in search_conditions){
                age_from = search_conditions.age_from;
                if(age_from < age_min_default){
                    age_min_default = age_from;
                }
            }
            if("age_to" in search_conditions){
                age_to = search_conditions.age_to;
                if(age_to > age_max_default){
                    age_max_default = age_to;
                }
            }else{
                age_to = age_max_default;
                age_max_dummy = true;
            }

            if("keyword" in search_conditions){
                $("#search_keyword").val(search_conditions.keyword);
            }

            if("note" in search_conditions){
                $("#search_note").val(search_conditions.note);
            }


            $( function() {
                $( "#slider-range-amount" ).slider({
                  range: true,
                  min: amount_min_default,
                  max: amount_max_default,
                  values: [ amount_from, amount_to ],
                  slide: function( event, ui ) {
                    $( "#amount_from" ).val( ui.values[ 0 ] );
                    $( "#amount_to" ).val( ui.values[ 1 ] );
{#                    searchProjects();#}
                  }
                });
                if(amount_from != "") {
                    $("#amount_from").val($("#slider-range-amount").slider("values", 0));
                }
                if(amount_to != "") {
                    $("#amount_to").val($("#slider-range-amount").slider("values", 1));
                }
                if(amount_max_dummy){
                    $("#amount_to").val("");
                }

            } );

            $( function() {
                $( "#slider-range-age" ).slider({
                  range: true,
                  min: age_min_default,
                  max: age_max_default,
                  values: [ age_from, age_to ],
                  slide: function( event, ui ) {
                    $( "#age_from" ).val( ui.values[ 0 ] );
                    $( "#age_to" ).val( ui.values[ 1 ] );
{#                    searchProjects();#}
                  }
                });

                if(age_from != "") {
                    $("#age_from").val($("#slider-range-age").slider("values", 0));
                }
                if(age_to != "") {
                    $("#age_to").val($("#slider-range-age").slider("values", 1));
                }
                if(age_max_dummy){
                    $("#age_to").val("");
                }
            } );

{#            function changeBookmark(id){#}
{#              $("#"+ id).toggleClass("glyphicon-star-empty");#}
{#              $("#"+ id).toggleClass("glyphicon-star yellow");#}
{##}
{#            }#}

        </script>
		<script type="text/javascript">
            $(document).ready(function () {
                env.data = env.data || {};

                env.data.prj_engineer = JSON.parse('{{ data['engineer.enumPrjEngineer']|tojson }}');

                for(i in env.data.prj_engineer){
                    try{
                        $("#assign_" + env.data.prj_engineer[i].engineer_id).removeClass("hidden");
                    }catch(e){
                        alert(e);
                    }

                }

{#                c4s.invokeApi_ex({#}
{#                    location: "client.enumWorkers",#}
{#                    body: {},#}
{#                    onSuccess: function(data) {#}
{#                        env.data.workers = data.data;#}
{#                    },#}
{#                });#}

            });

		</script>
	</body>
</html>
