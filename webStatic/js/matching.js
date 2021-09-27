
// [begin] onload functions.
$(document).ready(function(evt) {
	viewSelectedSkill();
	viewSelectedClientAndCompany();
	$("#search_term_begin, #search_term_end").datepicker({
        weekStart: 1,
        viewMode: "dates",
        language: "ja",
        autoclose: true,
        changeYear: true,
        changeMonth: true,
        dateFormat: "yyyy/mm/dd",
    }).on({
        hide: function (date, obj) {
            // searchProjects();
        }
    });
});
// [end] onload functions.


function clearSearchCondition() {

	var reqObj = {
				login_id: env.login_id,
				credential: env.credential,
				prefix: env.prefix,
			};

	reqObj.from_search_page = true;

	reqObj.engineer_id = $("#search_engineer_id").val();
	if(reqObj.engineer_id === undefined){
		delete　reqObj.engineer_id ;
	}
	reqObj.project_id = $("#search_project_id").val();
	if(reqObj.project_id === undefined){
		delete　reqObj.project_id ;
	}

	reqObj.station_lat = $("#search_station_lat").val();
	if(reqObj.station_lat.length == 0){
		delete　reqObj.station_lat ;
	}
	reqObj.station_lon = $("#search_station_lon").val();
	if(reqObj.station_lon.length == 0){
		delete　reqObj.station_lon ;
	}
	reqObj.station = $("#search_station").val();
	if(reqObj.station.length == 0){
		delete　reqObj.station ;
	}


	delete　reqObj.rank_id;
	delete　reqObj.occupation_id;
	delete　reqObj.skill_id;
	delete　reqObj.skill_level_list;
	delete　reqObj.flg_skill_level;
	// delete　reqObj.client_id;
	// delete　reqObj.company_id;
	delete　reqObj.term_begin;
	delete　reqObj.term_end;
	delete　reqObj.amount_from;
	delete　reqObj.amount_to;
	delete　reqObj.age_from;
	delete　reqObj.age_to;
	delete　reqObj.gender;
	delete	reqObj.contract;
	delete	reqObj.engineer_name;
	delete　reqObj.travel_itme;

	reqObj.flg_skill_level = $('#search_flg_skill_level:checked').val() ? "1" : "0";

	reqObj.client_id = $('[name="search_client[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.client_id.length == 0){
		delete　reqObj.client_id ;
	}
	// reqObj.company_id = $('[name="search_company[]"]:checked').map(function(){
  	// 	return $(this).val();
	// }).get();
	// if(reqObj.company_id.length == 0){
	// 	delete　reqObj.company_id ;
	// }
	reqObj.not_company_id = $('[name="search_company[]"]:not(:checked)').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.not_company_id.length == 0){
		delete　reqObj.not_company_id ;
	}


	c4s.invokeApi_ex({
		location: env.current,
		body: reqObj,
		pageMove: true,
		});
}


function searchProjects(){

	var reqObj = {
				login_id: env.login_id,
				credential: env.credential,
				prefix: env.prefix,
			};

	setSearchCondition(reqObj);

	if(validateCondition(reqObj)){
		return;
	}

	c4s.invokeApi_ex({
		location: env.current,
		body: reqObj,
		pageMove: true,
		});
}


function setSearchCondition(reqObj){

	reqObj.from_search_page = true;

	reqObj.rank_id = $('[name="search_rank[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.rank_id.length == 0){
		delete　reqObj.rank_id ;
	}
	reqObj.occupation_id = $('[name="search_occupation[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.occupation_id.length == 0){
		delete　reqObj.occupation_id ;
	}
	reqObj.skill_level_list = [];
	reqObj.skill_id = $('[name="search_skill[]"]:checked').map(function(){
		var skill_id = $(this).val();
  		var skill_level = $("#search_skill_level_" + skill_id).val();
		if(skill_level != ""){
			reqObj.skill_level_list.push({"skill_id": skill_id, "level":skill_level});
		}
		return skill_id;
	}).get();
	if(reqObj.skill_id.length == 0){
		delete　reqObj.skill_id ;
		delete　reqObj.skill_level_list ;
	}
	reqObj.flg_skill_level = $('#search_flg_skill_level:checked').val() ? "1" : "0";
	reqObj.client_id = $('[name="search_client[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.client_id.length == 0){
		delete　reqObj.client_id ;
	}
	// reqObj.company_id = $('[name="search_company[]"]:checked').map(function(){
  	// 	return $(this).val();
	// }).get();
	// if(reqObj.company_id.length == 0){
	// 	delete　reqObj.company_id ;
	// }
	reqObj.not_company_id = $('[name="search_company[]"]:not(:checked)').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.not_company_id.length == 0){
		delete　reqObj.not_company_id ;
	}
	reqObj.gender = $('[name="search_gender[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.gender.length == 0){
		delete　reqObj.gender ;
	}
	reqObj.contract = $('[name="search_contract[]"]:checked').map(function(){
		if ($(this).val() == '正社員(契約社員)') {
			return ['正社員', '契約社員'];
		} else {
	  		return $(this).val();
	  	}
	}).get();
	if(reqObj.contract.length == 0){
		delete　reqObj.contract ;
	}
	reqObj.term_begin = $('[name="search_term_begin"]').val();
	if(reqObj.term_begin.length == 0){
		delete　reqObj.term_begin ;
	}
	reqObj.term_end = $('[name="search_term_end"]').val();
	if(reqObj.term_end.length == 0){
		delete　reqObj.term_end ;
	}
	reqObj.amount_from = $('[name="search_amount_from"]').val();
	if(reqObj.amount_from.length == 0){
		delete　reqObj.amount_from ;
	}
	reqObj.amount_to = $('[name="search_amount_to"]').val();
	if(reqObj.amount_to.length == 0){
		delete　reqObj.amount_to ;
	}
	reqObj.age_from = $('[name="search_age_from"]').val();
	if(reqObj.age_from.length == 0){
		delete　reqObj.age_from ;
	}
	reqObj.age_to = $('[name="search_age_to"]').val();
	if(reqObj.age_to.length == 0){
		delete　reqObj.age_to ;
	}
	reqObj.engineer_name = $('[name="search_engineer_name"]').val();
	if(reqObj.engineer_name === undefined){
		delete　reqObj.engineer_name ;
	}
	reqObj.engineer_id = $("#search_engineer_id").val();
	if(reqObj.engineer_id === undefined){
		delete　reqObj.engineer_id ;
	}
	reqObj.project_id = $("#search_project_id").val();
	if(reqObj.project_id === undefined){
		delete　reqObj.project_id ;
	}
	reqObj.station_lat = $("#search_station_lat").val();
	if(reqObj.station_lat.length == 0){
		delete　reqObj.station_lat ;
	}
	reqObj.station_lon = $("#search_station_lon").val();
	if(reqObj.station_lon.length == 0){
		delete　reqObj.station_lon ;
	}
	reqObj.station = $("#search_station").val();
	if(reqObj.station.length == 0){
		delete　reqObj.station ;
	}
	reqObj.travel_time = $('[name="search_travel_time[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.travel_time.length == 0){
		delete　reqObj.travel_time ;
	}
	reqObj.keyword = $('[name="search_keyword"]').val();
	if(reqObj.keyword === undefined){
		delete reqObj.keyword ;
	}
	reqObj.note = $('[name="search_note"]').val();
	if(reqObj.note === undefined){
		delete reqObj.note ;
	}
	reqObj.flg_foreign = $('#search_flg_foreign').val();
	if(reqObj.flg_foreign === undefined || reqObj.flg_foreign == "all"){
		delete reqObj.flg_foreign ;
	}

}

function validateCondition(reqObj){

	$("#search_term_end").removeClass("has-error");
	if(reqObj.term_begin && reqObj.term_end){
		if(reqObj.term_begin > reqObj.term_end){
			alert("稼働時期の終了日付は開始日付をより後の日にしてください");
			$("#search_term_end").focus();
			$("#search_term_end").addClass("has-error");
			return true;
		}
	}

	$("#amount_from").removeClass("has-error");
	if(reqObj.amount_from && reqObj.amount_to){
		if(Number(reqObj.amount_from) > Number(reqObj.amount_to)){
			alert("単価の最大値は最小値をより大きくしてください");
			$("#amount_to").focus();
			$("#amount_to").addClass("has-error");
			return true;
		}
	}

	$("#age_from").removeClass("has-error");
	if(reqObj.age_from && reqObj.age_to){
		if(Number(reqObj.age_from) > Number(reqObj.age_to)){
			alert("年齢の最大値は最小値をより大きくしてください");
			$("#age_to").focus();
			$("#age_to").addClass("has-error");
			return true;
		}
	}

	return false;
}

function editSearchSkillCondition(){
	$('#edit_search_skill_condition_modal').modal('show');
}

function viewSelectedSkill() {
	$('[name="search_skill_level[]"]').addClass("hidden");
	selectedSkill = $('[name="search_skill[]"]:checked').map(function(){
		$('#search_skill_level_' + $(this).val()).removeClass("hidden");
  		return $("#skill_" + $(this).val()).text();
	}).get();

	$("#selected_skill_list").html(selectedSkill.join(', '));
	skill_id_list = [];
	skill_level_list = [];
	skill_id_list = $('[name="search_skill[]"]:checked').map(function(){
		return $(this).val();
	}).get();
	$('[name="search_skill_level[]"]').each(function (index) {
		if (!$(this).hasClass("hidden")) {
			var item = {
				level: $(this).val(),
				skill_id: $(this).attr("id").replace("search_skill_level_", "")
			};
			skill_level_list.push(item);
		}
	});
}

function editSearchClientAndCompanyCondition(){
	$('#edit_search_client_and_company_condition_modal').modal('show');
}

function viewSelectedClientAndCompany() {
	var selectedClient = $('[name="search_client[]"]:checked').map(function(){
  		return $("#client_" + $(this).val()).text();
	}).get();


	var selectedCompany = $('[name="search_company[]"]:checked').map(function(){
  		return $("#company_" + $(this).val()).text();
	}).get();

	var totalSelectedCount = selectedClient.length + selectedCompany.length;

	if(totalSelectedCount > 0){
		$("#selected_client_and_company_list").html(totalSelectedCount + "件設定中");
	}else{
		$("#selected_client_and_company_list").html("");
	}

	var company_id = env.companyInfo.id;
	var user_id = env.userInfo.id;

	blackCompanyId = $('[name="search_company[]"]:not(:checked)').map(function(){
  		return $(this).val();
	}).get();
	// selectedClientId = $('[name="search_client[]"]:checked').map(function(){
  	// 	return $(this).val();
	// }).get();

	var type = "";
	if(env.current == "matching.engineer"){
		type = "engineer";
	}else{
		type = "project";
	}
	c4s.setCookies(type + "BlackCompanyId" + company_id + user_id, blackCompanyId);
	// c4s.setCookies(type + "SelectedClientId" + company_id + user_id, selectedClientId);

}

function openMailFormOfProject() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	reqObj.type_recipient = "forMatching";
	reqObj.recipients = {engineers: [], workers: []};
	reqObj.all_projects = [];
	$("input[id^=iter_project_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
			var project_id = Number(el.id.replace("iter_project_selected_cb_", ""));
			reqObj.all_projects.push(project_id);
		}
	});
	reqObj.engineers = [];
	$("input[id^=iter_engineer_selected_cb_]").each(function (idx, el, arr) {
        if ($(this).attr('type') == "hidden") {
            reqObj.engineers.push(Number(el.id.replace("iter_engineer_selected_cb_", "")));
        }
    });


	if (reqObj.all_projects.length > 0) {

		setTimeout(function () {

            var project_count = reqObj.all_projects.length;

            for (var i = 0; i < project_count; i++) {
			　　eval("w" + i + "=window.open('', '_blank" + i +"');");
			}

            for (var i = 0; i < project_count; i++) {

            	reqObj.recipients = {engineers: [], workers: [], users:[]};
                reqObj.projects = [];
                var project_id = reqObj.all_projects[i];
                reqObj.projects.push(reqObj.all_projects[i]);

                var worker_ids = $("#search_project_worker_" + project_id).val();
                if (worker_ids != "" && worker_ids != undefined) {
                    worker_id_list = worker_ids.split(',');
                    for (var j = 0; j < worker_id_list.length; j++) {
                        reqObj.recipients.workers.push(Number(worker_id_list[j]));
                    }
                }
                var user_ids = $("#search_project_user_" + project_id).val();
				if(user_ids != "" && user_ids != undefined){
					user_id_list = user_ids.split(',');
					for(var j = 0; j < user_id_list.length; j++) {
						reqObj.recipients.users.push(Number(user_id_list[j]));
					}
				}

                var form = $("<form/>")[0];
                var json = $("<input type='hidden' name='json'/>")[0];
                form.appendChild(json);
                form.action = "/" + env.prefix + "/html/" + "mail.createMail" + "/";
                form.method = "POST";
                form.enctype = "application/x-www-form-urlencoded";
                form.target = "_blank" + i;
                reqObj.login_id = env.login_id;
                reqObj.credential = env.credential;
                json.value = JSON.stringify(reqObj);
                $("body").append(form);

                eval("w" + i + ".document.form = form;");
                eval("w" + i + ".document.form.submit();");

            }
        });

		// c4s.invokeApi_ex({
		// 	location: "mail.createMail",
		// 	body: reqObj,
		// 	pageMove: true,
		// 	newPage: true,
		// });
	} else {
		alert("対象データを選択してください。");
	}
}

function openMailFormOfEngineer() {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	reqObj.type_recipient = "forMatching";
	reqObj.all_engineers = [];
    $("input[id^=iter_engineer_selected_cb_]").each(function (idx, el, arr) {
        if (el.checked) {
        	var engineer_id = Number(el.id.replace("iter_engineer_selected_cb_", ""));
            // reqObj.engineers.push(engineer_id);
            reqObj.all_engineers.push(engineer_id);
        }
    });
	reqObj.projects = [];
	$("input[id^=iter_project_selected_cb_]").each(function (idx, el, arr) {
		if ($(this).attr('type') == "hidden") {
			var project_id = Number(el.id.replace("iter_project_selected_cb_", ""));
			reqObj.projects.push(project_id);
		}
	});

	if (reqObj.projects.length > 0 ||  reqObj.all_engineers.length > 0) {
		setTimeout(function () {
            var engineer_count = reqObj.all_engineers.length;

            for (var i = 0; i < engineer_count; i++) {
			　　eval("w" + i + "=window.open('', '_blank" + i +"');");
			}

            for (var i = 0; i < engineer_count; i++) {

            	reqObj.recipients = {engineers: [], workers: [], users:[]};
                reqObj.engineers = [];
                var engineer_id = reqObj.all_engineers[i];
                reqObj.engineers.push(reqObj.all_engineers[i]);

                var worker_ids = $("#search_engineer_worker_" + engineer_id).val();
				if(worker_ids != "" && worker_ids != undefined){
					worker_id_list = worker_ids.split(',');
					for(var j = 0; j < worker_id_list.length; j++) {
						reqObj.recipients.workers.push(Number(worker_id_list[j]));
					}
				}
				var user_ids = $("#search_engineer_user_" + engineer_id).val();
				if(user_ids != "" && user_ids != undefined){
					user_id_list = user_ids.split(',');
					for(var j = 0; j < user_id_list.length; j++) {
						reqObj.recipients.users.push(Number(user_id_list[j]));
					}
				}

                var form = $("<form/>")[0];
                var json = $("<input type='hidden' name='json'/>")[0];
                form.appendChild(json);
                form.action = "/" + env.prefix + "/html/" + "mail.createMail" + "/";
                form.method = "POST";
                form.enctype = "application/x-www-form-urlencoded";
                form.target = "_blank" + i;
                reqObj.login_id = env.login_id;
                reqObj.credential = env.credential;
                json.value = JSON.stringify(reqObj);
                $("body").append(form);

                eval("w" + i + ".document.form = form;");
                eval("w" + i + ".document.form.submit();");

            }
        });
	} else {
		alert("対象データを選択してください。");
	}
}


// function assignToProject() {
//
// 	var reqObj = {
// 			login_id: env.login_id,
// 			credential: env.credential,
// 			prefix: env.prefix,
// 		};
//
//
// 	reqObj.selected_projects = [];
// 	$("input[id^=iter_project_selected_cb_]").each(function (idx, el, arr) {
// 		if (el.checked) {
// 			reqObj.selected_projects.push(Number(el.id.replace("iter_project_selected_cb_", "")));
// 		}
// 		if($(this).attr('type') == "hidden"){
// 			reqObj.selected_projects.push(Number(el.id.replace("iter_project_selected_cb_", "")));
// 		}
// 	});
//
// 	reqObj.selected_engineers = [];
// 	$("input[id^=iter_engineer_selected_cb_]").each(function (idx, el, arr) {
// 		if (el.checked) {
// 			reqObj.selected_engineers.push(Number(el.id.replace("iter_engineer_selected_cb_", "")));
// 		}
// 		if($(this).attr('type') == "hidden"){
// 			reqObj.selected_engineers.push(Number(el.id.replace("iter_engineer_selected_cb_", "")));
// 		}
//
// 	});
//
// 	if (reqObj.selected_projects.length > 0 && reqObj.selected_engineers.length > 0) {
//
// 		var target_count = reqObj.selected_projects.length * reqObj.selected_engineers.length;
//
// 		for(i = 0; i < env.data['prj_engineer'].length; i++) {
// 			for(j = 0; j < reqObj.selected_projects.length; j++) {
// 				for(k = 0; k < reqObj.selected_engineers.length; k++) {
// 					if (reqObj.selected_projects[j] === env.data['prj_engineer'][i].project_id
//                         && reqObj.selected_engineers[k] === env.data['prj_engineer'][i].engineer_id) {
//                         alert("すでに案件にアサイン済みの要員が含まれています。");
//                         return;
//                     }
//                     var project_owner_id = $("#search_project_owner_" + reqObj.selected_projects[j]).val();
// 					if(project_owner_id != ""){
// 						if (project_owner_id != env.companyInfo["id"]){
// 							alert("他社の案件が含まれています。\n他社の案件にはアサインできません。");
// 							return;
// 						}
// 					}
//                 }
//             }
// 		}
//
// 		c4s.invokeApi_ex({
// 			location: "matching.relateEngineerToProject",
// 			body: reqObj,
// 			pageMove: false,
// 			newPage: true,
// 			onSuccess: function (data) {
// 				alert(target_count + "件登録しました。");
// 				searchProjects();
// 			}
// 		});
// 	} else {
// 		alert("対象データを選択してください。");
// 	}
// }


$(function () {

	$('#edit_search_skill_condition_modal').on('hide.bs.modal', function () {
		// searchProjects();
	});

	$('#edit_search_client_condition_modal').on('hide.bs.modal', function () {
		// searchProjects();
	});

	$('#edit_search_company_condition_modal').on('hide.bs.modal', function () {
		// searchProjects();
	});



});


function genFilterQuery () {
	var queryObj = {};
	var tgtAttrName;
	$("[id^=query_]").each(function(idx, el) {
		if (el.id) {
			tgtAttrName = el.id.replace("query_", "");
			if (el.localName === "input" && el.type === "checkbox") {
				queryObj[tgtAttrName] = el.checked;
			} else {
				if (el.value !== "") {
					queryObj[tgtAttrName] = tgtAttrName.indexOf("flg_") == 0 || tgtAttrName.indexOf("is_") == 0 ? Boolean(Number(el.value)) : el.value;
				}
			}
		}
	});

	setSearchCondition(queryObj);

	return queryObj;
}

function jumpSearchProjectTransit(StationTo) {

	var StationFrom = $("#search_station").val();
	if(StationFrom == undefined){
		return;
	}
	jumpSearchTransit(StationFrom,StationTo);

}

function jumpSearchEngineerTransit(StationFrom) {

	var StationTo = $("#search_station").val();
	if(StationTo == undefined){
		return;
	}
	jumpSearchTransit(StationFrom,StationTo);

}

function jumpSearchTransit(StationFrom,StationTo) {

	if(StationFrom == undefined || StationTo == undefined){
		return;
	}

	var now = new Date();
	var year = now.getYear();
	var month = now.getMonth() + 1;
	var day = now.getDate();
	var hour = now.getHours();
	var min = now.getMinutes();

	if(year < 2000) { year += 1900; }
	if(month < 10) { month = "0" + month; }
	if(day < 10) { day = "0" + day; }
	if(hour < 10) { hour = "0" + hour; }
	if(min < 10) { min = "0" + min; }else{min = "" + min;}

	var m2 = min.substr(1,1);
	var m1 = min.substr(2,1);

	var location = "https://transit.yahoo.co.jp/search/result?flatlon=&from="
				 +	encodeURIComponent(StationFrom)
				 +	"&tlatlon=&to="
				 +	encodeURIComponent(StationTo)
				 +	"&via=&via=&via=&y="
				 +	year + "&m=" + month + "&d=" + day + "&hh=" + hour + "&m2=" + m2 + "&m1=" + m1
				 +	"&type=1&ticket=ic&expkind=1&ws=3&s=0&al=1&shin=1&ex=1&hb=1&lb=1&sr=1&kw="
				 +	encodeURIComponent(StationTo);
	window.open(location, '_blank');

}

function genSkillList() {
	var is_sort = $('#m_skill_sort')[0].checked ? 1 : 0;
	$('#skill_list').empty();
	c4s.invokeApi_ex({
		location: "skill.enumSkills",
		body: {is_sort: is_sort},
		onSuccess: function(data) {
			if (data.data) {
				var html = '';
				$.each(env.data.skillCategories, function(index, category) {
					var loop_idx = index + 1;
					html += '<div id="search_skill_categories_header_'+ loop_idx +'" style="border-bottom: 1px solid #e5e5e5; margin-bottom: 10px;margin-top: 10px"><label>'+ category +'</label></div>';
					html += '<table class="">';
					$.each(data.data, function(sIndex, skill) {
						if (category == skill.category_name) {
							html += '<tr>';
							html += '<td>';
							html += '<input type="checkbox" name="search_skill[]" id="search_skill_label_'+ skill.id +'" class="search-chk" onchange="viewSelectedSkill();" value="'+ skill.id +'">';
							html += '<label id="skill_'+ skill.id +'" for="search_skill_label_'+ skill.id +'" style="font-weight: normal; margin: 0px">'+ skill.name +'</label>'
							html += '</td>';
							html += '<td>';
							html += '<select id="search_skill_level_'+ skill.id +'" name="search_skill_level[]" value="" class="" onchange="viewSelectedSkill();">';
							html += '<option value="0">----</option>';
							$.each(env.data.skillLevels, function(lIndex, level) {
								html += '<option value="'+ level.level +'">'+ level.name +'</option>'
							});
							html += '</option>';
							html += '</td>';
							html += '</tr>';
						}
					});
					html += '</table>';
				});
				$('#skill_list').append(html);
				if(skill_id_list){
					$('[name="search_skill_level[]"]').addClass("hidden");
					$('[name="search_skill[]"]').each(function (index) {
						var setval = $(this).val();
						if (skill_id_list.indexOf(setval) >= 0) {
							$(this).val([setval]);
							$('#search_skill_level_' + setval).removeClass("hidden");
							skill_level_list.forEach(function(e, i, a) {
								if(setval == e["skill_id"]){
									$("#search_skill_level_" + setval).val(e["level"]);
								}
							})
						}
					});
				}
			}
		},
		onError: function(data) {
			alert("更新に失敗しました。（" + data.status.description + "）")
		},
	});
}

$(document).on('change', '#m_skill_sort', function() {
	genSkillList();
});

function overwriteModalForEdit(objId) {
			$("#edit_project_modal_"+objId).modal("show");
}

function viewSelectedProjectSkill() {
	$('[name="m_project_skill_level[]"]').addClass("hidden");
	selectedSkill = $('[name="m_project_skill[]"]:checked').map(function(){
		var targetId = '#m_project_skill_level_' + $(this).val();
		$(targetId).removeClass("hidden");
		var skillLabel = $("#skill_" + $(this).val()).text();
		var skillLevelLabel = $(targetId + " option:selected").text();
		if(skillLevelLabel !== "----"){
			skillLabel += "(" + skillLevelLabel + ")";
		}
  		return skillLabel;
	}).get();
	var viewCount = 5;
	var selectedSkill2 = [];
	if(selectedSkill.length > viewCount){
		for(var i=0; i < viewCount; i++){
			selectedSkill2.push(selectedSkill[i]);
		}
		selectedSkill2.push("...");
	}else{
		selectedSkill2 = selectedSkill;
	}

	if(selectedSkill2.length > 0){
		$("#m_project_skill_container").html(selectedSkill2.join(','));
	}else{
		$("#m_project_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),Oracle,Spring</span>");
	}
}

function overwriteModalForEditE(objId) {
			$("#edit_engineer_modal_"+objId).modal("show");
}

function viewSelectedEngineerSkill() {
	$('[name="m_engineer_skill_level[]"]').addClass("hidden");
	selectedSkill = $('[name="m_engineer_skill[]"]:checked').map(function(){
		var targetId = '#m_engineer_skill_level_' + $(this).val();
		$(targetId).removeClass("hidden");
		var skillLabel = $("#skill_" + $(this).val()).text();
		var skillLevelLabel = $(targetId + " option:selected").text();
		if(skillLevelLabel !== "----"){
			skillLabel += "(" + skillLevelLabel + ")";
		}
  		return skillLabel;
	}).get();
	var viewCount = 5;
	var selectedSkill2 = [];
	if(selectedSkill.length > viewCount){
		for(var i=0; i < viewCount; i++){
			selectedSkill2.push(selectedSkill[i]);
		}
		selectedSkill2.push("...");
	}else{
		selectedSkill2 = selectedSkill;
	}

	if(selectedSkill2.length > 0){
		$("#m_engineer_skill_container").html(selectedSkill2.join(','));
	}else{
		$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3年～5年),PHP(1年～2年)</span>");
	}
}



function hdlClickPublicEngineerToggle(engineerId) {
	var reqObj = {};
	reqObj.id = engineerId;
	if (confirm("非公開状態に変更しますか？")) {
		c4s.invokeApi_ex({
			location: "engineer.updateMatchingEngineer",
			body: reqObj,
			onSuccess: function (res) {
				c4s.invokeApi_ex({
					location: env.current,
					body: {},
					pageMove: true,
				});
			},
		});
	}
}

function hdlClickPublicProjectToggle(projectId) {
	var reqObj = {};
	reqObj.id = projectId;
	if (confirm("非公開状態に変更しますか？")) {
		c4s.invokeApi_ex({
			location: "project.updateMatchingProject",
			body: reqObj,
			onSuccess: function (res) {
				c4s.invokeApi_ex({
					location: env.current,
					body: {},
					pageMove: true,
				});
			},
		});
	}
}

function exportPdfProject()
{
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_project_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_project_selected_cb_", "")));
		}
	});

	if (id_list.length <= 0) {
		alert("対象データを選択してください。");
		return false;
	}
	reqObj = {
		prefix: env.prefix,
		id_list: id_list
	}
	if ($("#search_engineer_id").val() != undefined) {
		reqObj.engineer_id = $("#search_engineer_id").val();
	}
	var h = $(window).height();
	$("#nav-search").css('opacity', 0);
    $('#loader-bg2 ,#loader2').height(h).css('display','block');
	downloadLoadingTimer = setInterval(function () {
        var cookieData = c4s.getCookies();
        var downloadCookie = cookieData["downloaded"];
        if(downloadCookie != undefined && downloadCookie == "yes"){
            c4s.setCookies("downloaded", "no");
            clearInterval(downloadLoadingTimer);
            // c4s.sleep(2500);
            $('#loader-bg2').delay(150).fadeOut(130);
            $('#loader2').delay(100).fadeOut(50);
            $("#nav-search").css('opacity', 1);
        }
    }, 100);
	c4s.invokeApi_ex({
		location: "quotation.downloadPdfMatchingProject",
		body: reqObj,
        pageMove: true,
        newPage: false
	});
}

function exportPdfEngineer()
{
	var id_list = [];
	var targets = $("input[type=checkbox][id^=iter_engineer_selected_cb_]");
	targets.each(function (idx, el) {
		if (el.checked) {
			id_list.push(Number(el.attributes['id'].value.replace("iter_engineer_selected_cb_", "")));
		}
	});

	if (id_list.length <= 0) {
		alert("対象データを選択してください。");
		return false;
	}
	reqObj = {
		prefix: env.prefix,
		id_list: id_list
	}
	if ($("#search_project_id").val() != undefined) {
		reqObj.project_id = $("#search_project_id").val();
	}
	var h = $(window).height();
	$("#nav-search").css('opacity', 0);
    $('#loader-bg2 ,#loader2').height(h).css('display','block');
	downloadLoadingTimer = setInterval(function () {
        var cookieData = c4s.getCookies();
        var downloadCookie = cookieData["downloaded"];
        if(downloadCookie != undefined && downloadCookie == "yes"){
            c4s.setCookies("downloaded", "no");
            clearInterval(downloadLoadingTimer);
            // c4s.sleep(2500);
            $('#loader-bg2').delay(150).fadeOut(130);
            $('#loader2').delay(100).fadeOut(50);
            $("#nav-search").css('opacity', 1);
        }
    }, 100);
	c4s.invokeApi_ex({
		location: "quotation.downloadPdfMatchingEngineer",
		body: reqObj,
        pageMove: true,
        newPage: false
	});
}

$(document).on('click', '.video-matching-project', function() {
	c4s.hdlClickVideoBtn('matching_project');
});

$(document).on('click', '.video-matching-engineer', function() {
	c4s.hdlClickVideoBtn('matching_engineer');
});
