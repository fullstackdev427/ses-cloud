function genFilterQuery (reqObj) {
	reqObj = reqObj || {};
	var i, key, value;
	// [begin] common.
	var texts = $("input[id^=query_][type=text]");
	texts.each(function (idx, el) {
		if (el.value) {
			reqObj[el.attributes['id'].value.replace("query_", "")] = el.value;
		}
	});
	// [end] common.
	// [begin] contract.
	var contract = $("#query_contract")[0];
	if (contract.selectedIndex != 0) {
		reqObj['contract'] = contract.selectedOptions[0].value;
	}
	// [end] contract.
    // var view_limit = $("#query_view_limit")[0];
	// if (view_limit.selectedIndex != 0) {
	// 	reqObj['view_limit'] = Number(view_limit.selectedOptions[0].value);
	// }
	// [begin] flags.
	var flags = $("input[id^=query_is][type=checkbox]");
	flags.each(function (idx, el) {
		if (el.checked) {
			reqObj[el.attributes['id'].value.replace("query_", "")] = 1;
		}else{
		    reqObj[el.attributes['id'].value.replace("query_", "")] = 0;
        }
	});
	if (reqObj["is_fixed"]==0){
		delete reqObj["is_fixed"];
	}

	reqObj.from_operation = true;

	reqObj.focus_new_record = false;
	if($("#focus_new_record").val() != "0"){
        reqObj.focus_new_record = true;
    }


	// [end] flags.
	return reqObj;
}

function genOrderQuery (reqObj) {
	reqObj = reqObj || {};
	return reqObj;
}

function hdlClickSearchBtnForUpdate(){
    c4s.hdlClickSearchBtn();
}

function updateObject(funcObj,funcVal) {

    funcObj = funcObj || hdlClickSearchBtnForUpdate;
    funcVal = funcVal || {};

    if(env.updateEngineerClientStackList){
        for(var i = 0; i < env.updateEngineerClientStackList.length; i++){
            var updateEngineerStack = env.updateEngineerClientStackList[i];
            var reqObj ={};
            reqObj.id = Number(updateEngineerStack.engineer_id);
            reqObj.client_id = updateEngineerStack.client_id != "" ? Number(updateEngineerStack.client_id) : null;
            reqObj.update_data_only = true;

            c4s.invokeApi_ex({
                location: "engineer.updateEngineer",
                body: reqObj,
                onSuccess: function(data) {
                    $("input[id^=iter_operation_selected_cb_]").each(function (idx, el, arr) {
                            var idList = $(this).val().split("-");
                            if(updateEngineerStack.engineer_id == idList[2]){
                                idList[5] = updateEngineerStack.client_id;
                                var updateVal = idList.join("-");
                                $(this).val(updateVal);
                            }
                    });
                },
                onError: function(data) {
                    alert("?????????????????????????????????" + data.status.description + "???")
                    return;
                }
            });
        }
    }
    if(env.updateEngineerChargingUserStackList){
        for(var i = 0; i < env.updateEngineerChargingUserStackList.length; i++){
            var updateEngineerStack = env.updateEngineerChargingUserStackList[i];
            var reqObj ={};
            reqObj.id = Number(updateEngineerStack.engineer_id);
            reqObj.charging_user_id = updateEngineerStack.charging_user_id != "" ? Number(updateEngineerStack.charging_user_id) : null;
            reqObj.update_data_only = true;

            c4s.invokeApi_ex({
                location: "engineer.updateEngineer",
                body: reqObj,
                onSuccess: function(data) {
                    // $("input[id^=iter_operation_selected_cb_]").each(function (idx, el, arr) {
                    //         var idList = $(this).val().split("-");
                    //         if(updateEngineerStack.engineer_id == idList[2]){
                    //             idList[5] = updateEngineerStack.client_id;
                    //             var updateVal = idList.join("-");
                    //             $(this).val(updateVal);
                    //         }
                    // });
                },
                onError: function(data) {
                    alert("?????????????????????????????????" + data.status.description + "???")
                    return;
                }
            });
        }
    }

    if(env.updateEngineerContractStackList){
        for(var i = 0; i < env.updateEngineerContractStackList.length; i++){
            var updateEngineerStack = env.updateEngineerContractStackList[i];
            var reqObj ={};
            reqObj.id = Number(updateEngineerStack.engineer_id);
            reqObj.contract = updateEngineerStack.contract != "" ? updateEngineerStack.contract : null;
            reqObj.update_data_only = true;

            c4s.invokeApi_ex({
                location: "engineer.updateEngineer",
                body: reqObj,
                onSuccess: function(data) {
                },
                onError: function(data) {
                    alert("?????????????????????????????????" + data.status.description + "???")
                    return;
                }
            });
        }
    }

    if(env.updateProjectChargingUserStackList){
        for(var i = 0; i < env.updateProjectChargingUserStackList.length; i++){
            var updateProjectStack = env.updateProjectChargingUserStackList[i];
            var reqObj ={};
            reqObj.id = Number(updateProjectStack.project_id);
            reqObj.charging_user_id = updateProjectStack.charging_user_id != "" ? Number(updateProjectStack.charging_user_id) : null;
            reqObj.update_data_only = true;

            c4s.invokeApi_ex({
                location: "project.updateProject",
                body: reqObj,
                onSuccess: function(data) {
                    // $("input[id^=iter_operation_selected_cb_]").each(function (idx, el, arr) {
                    //         var idList = $(this).val().split("-");
                    //         if(updateEngineerStack.engineer_id == idList[2]){
                    //             idList[5] = updateEngineerStack.client_id;
                    //             var updateVal = idList.join("-");
                    //             $(this).val(updateVal);
                    //         }
                    // });
                },
                onError: function(data) {
                    alert("?????????????????????????????????" + data.status.description + "???")
                    return;
                }
            });
        }
    }
    updateOperation(funcObj,funcVal);

}

function updateOperation(funcObj, funcVal){
    var reqObj = genUpdateValue();
	var count = reqObj.operationObjList.length;
    if(count > 0){
        c4s.invokeApi_ex({
            location: "operation.updateOperation",
            body: reqObj,
            onSuccess: function (data) {
                if(funcObj === hdlClickSearchBtnForUpdate){
                    alert("?????????????????????");
                }
                funcObj(funcVal);

            },
            onError: function (data) {
                alert("??????????????????????????????" + data.status.description + "???");
            }
        });
    }else {
        funcObj(funcVal);
    }

}

function genUpdateValue() {

	var reqObj = {
        login_id: env.login_id,
        credential: env.credential,
        prefix: env.prefix,
        operationObjList : [],
    };


	for(var i =1; i <= row_length; i++){

	    var operationObj = {};
	    operationObj.id = $('#operation_id_' + i).val();

	    if(operationObj.id == undefined || operationObj.id == ""){
	        continue;
        }
        operationObj = getInputValueOperationObj(i);
	    reqObj.operationObjList.push(operationObj);

    }

	return reqObj;
}

function getInputValueOperationObj(i){

    var operationObj = {};
	    operationObj.id = $('#operation_id_' + i).val();
	    operationObj.term_memo = $('#term_memo_' + i).val();
	    operationObj.demand_exc_tax = formatForCalc($('#demand_exc_tax_' + i).val());
	    operationObj.demand_inc_tax = formatForCalc($('#demand_inc_tax_' + i).val());
	    operationObj.payment_exc_tax = formatForCalc($('#payment_exc_tax_' + i).val());
	    operationObj.payment_inc_tax = formatForCalc($('#payment_inc_tax_' + i).val());
	    operationObj.gross_profit = formatForCalc($('#gross_profit_' + i).val());
	    operationObj.gross_profit_rate = formatForCalc($('#gross_profit_rate_' + i).val());
	    operationObj.settlement_from = $('#settlement_from_' + i).val() != "" ?  Number($('#settlement_from_' + i).val()): null;
	    operationObj.settlement_to = $('#settlement_to_' + i).val() != "" ?  Number($('#settlement_to_' + i).val()): null;
	    operationObj.contract_date = $('#contract_date_' + i).val() != "" ?  $('#contract_date_' + i).val(): null;
	    operationObj.tax = formatForCalc($('#tax_' + i).val());
	    operationObj.welfare_fee = formatForCalc($('#welfare_fee_' + i).val());
	    operationObj.transportation_fee = formatForCalc($('#transportation_fee_' + i).val());
	    operationObj.base_exc_tax = formatForCalc($('#base_exc_tax_' + i).val());
	    operationObj.base_inc_tax = formatForCalc($('#base_inc_tax_' + i).val());
	    operationObj.excess = formatForCalc($('#excess_' + i).val());
	    operationObj.deduction = formatForCalc($('#deduction_' + i).val());
	    operationObj.demand_memo = $('#demand_memo_' + i).val();
	    operationObj.payment_memo = $('#payment_memo_' + i).val();
	    operationObj.demand_site = $('#demand_site_' + i).val();
	    operationObj.payment_site = $('#payment_site_' + i).val();
	    operationObj.cutoff_date = $('#cutoff_date_' + i).val() != "" ?  $('#cutoff_date_' + i).val(): null;
	    operationObj.other_memo = $('#other_memo_' + i).val();
        operationObj.is_active = $('#is_active_' + i).is(':checked') ? 1:0;
        operationObj.is_fixed = $('#is_fixed_' + i).is(':checked') ? 1:0;
        operationObj.transfer_member = $('#transfer_member_' + i).val();
        operationObj.term_begin = $('#term_begin_' + i).val() != "" ?  $('#term_begin_' + i).val(): null;
        operationObj.term_end = $('#term_end_' + i).val() != "" ?  $('#term_end_' + i).val(): null;
        operationObj.term_begin_exp = $('#term_begin_exp_' + i).val() != "" ?  $('#term_begin_exp_' + i).val(): null;
        operationObj.term_end_exp = $('#term_end_exp_' + i).val() != "" ?  $('#term_end_exp_' + i).val(): null;
        operationObj.settlement_exp = $('#settlement_exp_' + i).val() != "" ?  $('#settlement_exp_' + i).val(): null;
        operationObj.settlement_unit = $('#settlement_unit_' + i).val();
        operationObj.demand_unit = $('#demand_unit_' + i).val();
        operationObj.payment_unit = $('#payment_unit_' + i).val();
        operationObj.bonuses_division = formatForCalc($('#bonuses_division_' + i).val());
        operationObj.payment_base = formatForCalc($('#payment_base_' + i).val());
        operationObj.payment_excess = formatForCalc($('#payment_excess_' + i).val());
        operationObj.payment_deduction = formatForCalc($('#payment_deduction_' + i).val());
        operationObj.payment_exp = $('#payment_exp_' + i).val() != "" ?  $('#payment_exp_' + i).val(): null;
        operationObj.payment_settlement_unit = $('#payment_settlement_unit_' + i).val();

        operationObj.payment_settlement_from = $('#payment_settlement_from_' + i).val() != "" ?  Number($('#payment_settlement_from_' + i).val()): null;
        operationObj.payment_settlement_to = $('#payment_settlement_to_' + i).val() != "" ?  Number($('#payment_settlement_to_' + i).val()): null;

        operationObj.demand_wage_per_hour = formatForCalc($('#demand_wage_per_hour_' + i).val());
        operationObj.demand_working_time = $('#demand_working_time_' + i).val() ? Number($('#demand_working_time_' + i).val()): null;
        operationObj.payment_wage_per_hour = formatForCalc($('#payment_wage_per_hour_' + i).val());
        operationObj.payment_working_time = $('#payment_working_time_' + i).val()? Number($('#payment_working_time_' + i).val()): null;

        return operationObj;
}

function updateCalcOperationResult(rowId) {

    // calcSubtotal(rowId);
    updateBaseIncTax(rowId);
    // updateDemandExcTax(rowId);
    updateDemandIncTax(rowId);
    // updatePaymentExcTax(rowId);
    updatePaymentIncTax(rowId);
	updateGrossProfit(rowId);

    viewSettlementMiniArea(rowId);
	viewPaymentSettlementMiniArea(rowId);
}

function updateDemandExcessAndDeduction(rowId) {

    var excess = formatForCalc($("#excess_" + rowId).val());
    var deduction = formatForCalc($("#deduction_" + rowId).val());
    var settlement_from = formatForCalc($("#settlement_from_" + rowId).val());
    var settlement_to = formatForCalc($("#settlement_to_" + rowId).val());
    // var settlement_exp = formatForCalc($("#settlement_exp_" + rowId).val());
    var base = formatForCalc($("#base_exc_tax_" + rowId).val());
    var settlement_unit = $("#settlement_unit_" + rowId).val();

    settlement_from = c4s.floor(parseFloat(settlement_from),2);
    settlement_to = c4s.floor(parseFloat(settlement_to),2);


    if(base > 0 && settlement_from > 0 ){
        // deduction = Math.round(base / settlement_from);
        deduction = new BigNumber(base).div(settlement_from).toFixed(0) ;
        deduction = Math.floor(deduction/10)*10;
    }
    if(base > 0 && settlement_to > 0 ){
        excess = new BigNumber(base).div(settlement_to).toFixed(0) ;
        excess = Math.floor(excess/10)*10;
    }
    $("#excess_" + rowId).val(formatForView(excess));
    $("#deduction_" + rowId).val(formatForView(deduction));
    $("#settlement_from_" + rowId).val(settlement_from);
    $("#settlement_to_" + rowId).val(settlement_to);

    updateCalcOperationResult(rowId);
    viewSettlementMiniArea(rowId);

}

function updatePaymentExcessAndDeduction(rowId) {

    var excess = formatForCalc($("#payment_excess_" + rowId).val());
    var deduction = formatForCalc($("#payment_deduction_" + rowId).val());
    var settlement_from = formatForCalc($("#payment_settlement_from_" + rowId).val());
    var settlement_to = formatForCalc($("#payment_settlement_to_" + rowId).val());
    // var payment_exp = formatForCalc($("#payment_exp_" + rowId).val());
    var base = formatForCalc($("#payment_base_" + rowId).val());
    var settlement_unit = $("#payment_settlement_unit_" + rowId).val();

    settlement_from = c4s.floor(parseFloat(settlement_from),2);
    settlement_to = c4s.floor(parseFloat(settlement_to),2);

    if(base > 0 && settlement_from > 0 ){
        deduction = new BigNumber(base).div(settlement_from).toFixed(0) ;
        deduction = Math.floor(deduction/10)*10;
    }
    if(base > 0 && settlement_to > 0){
        excess = new BigNumber(base).div(settlement_to).toFixed(0) ;
        excess = Math.floor(excess/10)*10;
    }

    $("#payment_excess_" + rowId).val(formatForView(excess));
    $("#payment_deduction_" + rowId).val(formatForView(deduction));
    $("#payment_settlement_from_" + rowId).val(settlement_from);
    $("#payment_settlement_to_" + rowId).val(settlement_to);

    updateCalcOperationResult(rowId);
    viewPaymentSettlementMiniArea(rowId);

}

function adjustExpFromUnit(exp, unit){

        switch (unit){
            case "1":
                //???????????????
                exp = Math.floor(exp);
                break;
            case "2":
                //???????????????
                tmp = exp - Math.floor(exp);
                if(tmp >= 0.5){
                    tmp = 0.5;
                }else{
                    tmp = 0;
                }
                exp = Math.floor(exp) + tmp;
                break;
            case "3":
                //???????????????
                tmp = exp - Math.floor(exp);
                if(tmp < 0.25){
                    tmp = 0;
                }else if (0.25 <= tmp && tmp < 0.5){
                    tmp = 0.25;
                }else if (5 <= tmp && tmp < 0.75){
                    tmp = 0.5;
                }else{
                    tmp = 0.75;
                }
                exp = Math.floor(exp) + tmp;
                break;
        }
        return exp.round().toPrecision();
}



function updateGrossProfit(rowId){

    var demand_exc_tax = formatForCalc($("#base_exc_tax_" + rowId).val());
    var payment_exc_tax = formatForCalc($("#payment_base_" + rowId).val());
    var welfare_fee = formatForCalc($("#welfare_fee_" + rowId).val());
    var transportation_fee = formatForCalc($("#transportation_fee_" + rowId).val());
    var bonuses_division = formatForCalc($("#bonuses_division_" + rowId).val());

	var engineer_contract = $("#engineer_contract_" + rowId).val();
	var update_engineer_contract = $("#m_operation_update_engineer_contract").val();
	if(engineer_contract == "???????????????" || engineer_contract == "???????????????" || update_engineer_contract == "???????????????" || update_engineer_contract == "???????????????") {
		var gross_profit = demand_exc_tax - payment_exc_tax;
	} else {
		var gross_profit = demand_exc_tax - payment_exc_tax - welfare_fee - transportation_fee - bonuses_division;
	}

    var gross_profit_rate = 0;
    var gross_profit_rate_percent_view = 0;
    if(gross_profit != 0 && demand_exc_tax != 0){
        gross_profit_rate = new BigNumber(gross_profit).div(demand_exc_tax).toPrecision(3);
        // gross_profit_rate = Math.round(gross_profit / demand_exc_tax * 1000) / 1000;
        gross_profit_rate_percent_view = Math.round(gross_profit_rate * 100 * 1000)/1000;

        if(gross_profit_rate > 1000){
            gross_profit_rate = 9.99;
            gross_profit_rate_percent_view = 999.9;
        }else if(gross_profit_rate < -1000){
            gross_profit_rate = -9.99;
            gross_profit_rate_percent_view = -999.9;
        }

    }else{
        gross_profit_rate = 0;
    }

    $("#welfare_fee_" + rowId).val(formatForView(welfare_fee));
    $("#transportation_fee_" + rowId).val(formatForView(transportation_fee));
    $("#bonuses_division_" + rowId).val(formatForView(bonuses_division));

    $("#gross_profit_" + rowId).val(formatForView(gross_profit));
    $("#gross_profit_rate_" + rowId).val(formatForView(gross_profit_rate));
    $("#gross_profit_" + rowId + "_label").html(formatForView(gross_profit));
    $("#gross_profit_rate_" + rowId + "_label").html((gross_profit_rate_percent_view) + "%");

}

function updateBaseIncTax(rowId) {

    var base_exc_tax = $("#base_exc_tax_" + rowId).val();

    if (base_exc_tax === undefined || base_exc_tax === "") {
        return;
    }

    base_exc_tax = formatForCalc(base_exc_tax);

    var base_inc_tax = c4s.calcIncTax(base_exc_tax);


    $("#base_exc_tax_" + rowId).val(formatForView(base_exc_tax));
    $("#base_exc_tax_" + rowId + "_label").html(formatForView(base_exc_tax));
    $("#base_inc_tax_" + rowId).val(formatForView(base_inc_tax));
    $("#base_inc_tax_" + rowId + "_label").html(formatForView(base_inc_tax));
}

// function updateDemandExcTax(rowId) {
//
//     var base = $("#base_exc_tax_" + rowId).val();
//     var excess = $("#excess_" + rowId).val();
//     var deduction = $("#deduction_" + rowId).val();
//
//     base = formatForCalc(base);
//     excess = formatForCalc(excess);
//     deduction = formatForCalc(deduction);
//
//     // var demand_exc_tax = base + excess - deduction;
//     var demand_exc_tax = base;
//
//     $("#base_exc_tax_" + rowId).val(formatForView(base));
//     $("#excess_" + rowId).val(formatForView(excess));
//     $("#deduction_" + rowId).val(formatForView(deduction));
//     $("#demand_exc_tax_" + rowId).val(formatForView(demand_exc_tax));
// }


function updateDemandIncTax(rowId) {

    var demand_exc_tax = $("#base_exc_tax_" + rowId).val();

    if (demand_exc_tax === undefined || demand_exc_tax === "") {
        return;
    }

    var demand_inc_tax = c4s.calcIncTax(formatForCalc(demand_exc_tax));
    var tax = demand_inc_tax - formatForCalc(demand_exc_tax);

    $("#base_exc_tax_" + rowId).val(formatForView(demand_exc_tax));
    $("#demand_inc_tax_" + rowId).val(formatForView(demand_inc_tax));
    $("#tax_" + rowId).val(formatForView(tax));
    $("#demand_exc_tax_" + rowId + "_label").html(formatForView(demand_exc_tax));
    $("#demand_inc_tax_" + rowId + "_label").html(formatForView(demand_inc_tax));
    $("#tax_" + rowId + "_label").html(formatForView(tax));


}


// function updatePaymentExcTax(rowId) {
//
//     var base = $("#payment_base_" + rowId).val();
//     var excess = $("#payment_excess_" + rowId).val();
//     var deduction = $("#payment_deduction_" + rowId).val();
//
//     base = formatForCalc(base);
//     excess = formatForCalc(excess);
//     deduction = formatForCalc(deduction);
//
//     // var payment_exc_tax = base + excess - deduction;
//     var payment_exc_tax = base;
//
//     $("#payment_base_" + rowId).val(formatForView(base));
//     $("#payment_excess_" + rowId).val(formatForView(excess));
//     $("#payment_deduction_" + rowId).val(formatForView(deduction));
//     $("#payment_exc_tax_" + rowId).val(formatForView(payment_exc_tax));
// }

function updatePaymentIncTax(rowId) {

    var payment_exc_tax = $("#payment_base_" + rowId).val();

    if (payment_exc_tax === undefined || payment_exc_tax === "") {
       return;
    }
    payment_exc_tax = formatForCalc(payment_exc_tax);

    var payment_inc_tax = c4s.calcIncTax(payment_exc_tax);

    $("#payment_base_" + rowId).val(formatForView(payment_exc_tax));
    $("#payment_exc_tax_" + rowId).val(formatForView(payment_exc_tax));
    $("#payment_inc_tax_" + rowId).val(formatForView(payment_inc_tax));
    $("#payment_exc_tax_" + rowId + "_label").html(formatForView(payment_exc_tax));
    $("#payment_inc_tax_" + rowId + "_label").html(formatForView(payment_inc_tax));

}


function formatForCalc(val) {

    if (val === undefined || val === "") {
        return 0;
    }

    val = val.replace(/[???-??????-??????-???]/g, function (s) {
        return String.fromCharCode(s.charCodeAt(0) - 65248);
    });
    val = val.replace(/,/g, '');

    val???= parseInt(val);

    if (val === "" || isNaN(val)) {
        return 0;
    }

    return val;
}

function formatForView(val){
    return val.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
}

function onchangePaymentIncTax(rowId) {

    var payment_inc_tax = $("#payment_inc_tax_" + rowId).val();

    if (payment_inc_tax === undefined || payment_inc_tax === "") {
       return;
    }
    payment_inc_tax = formatForCalc(payment_inc_tax);

    //???????????????
    var payment_exc_tax = c4s.calcExcTax(payment_inc_tax);

    //????????????????????????
    $("#payment_base_" + rowId).val(formatForView(payment_exc_tax));
    $("#payment_exc_tax_" + rowId).val(formatForView(payment_exc_tax));
    $("#payment_inc_tax_" + rowId).val(formatForView(payment_inc_tax));
    $("#payment_exc_tax_" + rowId + "_label").html(formatForView(payment_exc_tax));
    $("#payment_inc_tax_" + rowId + "_label").html(formatForView(payment_inc_tax));

    //??????????????????
    updateGrossProfit(rowId);
}

function viewSettlementMiniArea(rowId){
    var settlement_from = formatForCalc($("#settlement_from_" + rowId).val());
    var settlement_to = formatForCalc($("#settlement_to_" + rowId).val());

    var str_settlement_mini_view_base = "(" + settlement_from + "h-" + settlement_to + "h)";
    var str_settlement_mini_view = "";
    if(str_settlement_mini_view_base.length > 11 && rowId == 0){
        str_settlement_mini_view = "<br>???????????????" + str_settlement_mini_view_base;
    }else{
        str_settlement_mini_view = str_settlement_mini_view_base;
    }

    $("#settlement_mini_view_" + rowId).html(str_settlement_mini_view);
}
function viewPaymentSettlementMiniArea(rowId){
    var settlement_from = formatForCalc($("#payment_settlement_from_" + rowId).val());
    var settlement_to = formatForCalc($("#payment_settlement_to_" + rowId).val());

    var str_settlement_mini_view_base = "(" + settlement_from + "h-" + settlement_to + "h)";
    var str_settlement_mini_view = "";
    if(str_settlement_mini_view_base.length > 11 && rowId == 0){
        str_settlement_mini_view = "<br>???????????????" + str_settlement_mini_view_base;
    }else{
        str_settlement_mini_view = str_settlement_mini_view_base;
    }

    $("#payment_settlement_mini_view_" + rowId).html(str_settlement_mini_view);
}

function viewDemandMemoArea(rowId){
    var memo = $("#demand_memo_" + rowId).val();

    if(memo.length > 15 && rowId == 0){
        $("#demand_memo_area_" + rowId).html(memo.slice(0,15) + "...");
    }else{
        $("#demand_memo_area_" + rowId).html(memo);
    }
}

function viewPaymentMemoArea(rowId){
    var memo = $("#payment_memo_" + rowId).val();

    if(memo.length > 15 && rowId == 0){
        $("#payment_memo_area_" + rowId).html(memo.slice(0,15) + "...");
    }else{
        $("#payment_memo_area_" + rowId).html(memo);
    }
}

function triggerCreateQuotationEstimate(){
    /*if (unsaved == true) {
        $('#before_action').val('trigger_estimate');
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");
    updateObject(createQuotationEstimate,null);
}

function createQuotationEstimate() {

    operations = [];
	projects = [];
	$("input[id^=iter_operation_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
		    var idList = $(this).val().split("-");
		    operations.push(idList[0]);
			projects.push(idList[1]);
		}
	});

    if(operations.length == 0){
	    alert("????????????????????????????????????");
	    return;
    }

	c4s.invokeApi_ex({
		location: "quotation.topEstimate",
		body: {
			action_type: "CREATE",
			operation_ids: operations,
			project_id_top: projects[0]
		},
		pageMove: true,
		newPage: true
	});

}

function triggerCreateQuotationOrder(){
    /*if (unsaved == true) {
        $('#before_action').val('trigger_order');
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");
    updateObject(createQuotationOrder,null);
}

function createQuotationOrder() {

    operations = [];
	projects = [];
	$("input[id^=iter_operation_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
		    var idList = $(this).val().split("-");
		    operations.push(idList[0]);
			projects.push(idList[1]);
		}
	});

    if(operations.length == 0){
	    alert("????????????????????????????????????");
	    return;
    }

	c4s.invokeApi_ex({
		location: "quotation.topOrder",
		body: {
			action_type: "CREATE",
			operation_ids: operations,
			project_id_top: projects[0]
		},
		pageMove: true,
		newPage: true
	});
}

function triggerCreateQuotationInvoice(){
    /*if (unsaved == true) {
        $('#before_action').val('trigger_invoice');
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");
    updateObject(createQuotationInvoice,null);
}

function createQuotationInvoice() {

    operations = [];
	projects = [];
    clients =[];
	$("input[id^=iter_operation_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
		    var idList = $(this).val().split("-");
		    operations.push(idList[0]);
			projects.push(idList[1]);
		    clients.push(idList[3]);
		}
	});

    if(operations.length == 0){
	    alert("????????????????????????????????????");
	    return;
    }

	c4s.invokeApi_ex({
		location: "quotation.topInvoice",
		body: {
			action_type: "CREATE",
			operation_ids: operations,
			project_id_top: projects[0]
		},
		pageMove: true,
		newPage: true
	});
}

function triggerCreateQuotationPurchase(){
    /*if (unsaved == true) {
        $('#before_action').val('trigger_purchase');
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");
    updateObject(createQuotationPurchase,null);
}

function createQuotationPurchase() {

    operations = [];
	projects = [];
    engineers = [];
    clients =[];
    companies =[];
    engineer_clients = [];

	$("input[id^=iter_operation_selected_cb_]").each(function (idx, el, arr) {
		if (el.checked) {
		    var idList = $(this).val().split("-");
		    operations.push(idList[0]);
			projects.push(idList[1]);
		    engineers.push(idList[2]);
		    clients.push(idList[3]);
		    if(idList[4] != ""){
		        companies.push(idList[4]);
            }
            if(idList[5] != ""){
		        engineer_clients.push(idList[5]);
            }
		}
	});

	if(operations.length == 0){
	    alert("????????????????????????????????????");
	    return;
    }

    companies = companies.filter(function (x, i, self) {
        return self.indexOf(x) === i;
    });

    if(companies.length == 0){
        alert("????????????????????????????????????");
        return;
    }
    if(companies.length > 1){
        alert("??????????????????????????????????????????????????????????????????\n???????????????????????????????????????????????????");
        return;
    }

    // if(companies[0] == env.companyInfo.id){
    //     engineer_clients = engineer_clients.filter(function (x, i, self) {
    //         return self.indexOf(x) === i;
    //     });
    //
    //     if(engineer_clients.length == 0){
    //         alert("??????????????????????????????????????????????????????????????????????????????\n ??????????????????????????????????????????????????????????????????");
    //         return;
    //     }
    //     if(engineer_clients.length > 1){
    //         alert("??????????????????????????????????????????????????????????????????\n???????????????????????????????????????????????????");
    //         return;
    //     }
    // }

	var reqObj = {
		action_type: "CREATE",
		operation_ids: operations,
		project_id_top: projects[0]
	};

	// if(companies.length > 0 && companies[0] != env.companyInfo.id){
	// 	reqObj.company_id = parseInt(companies[0]);
	// 	reqObj.engineer_company_id = parseInt(companies[0]);
	// }else if (engineer_clients.length > 0) {
	// 	reqObj.engineer_client_id = parseInt(engineer_clients[0]);
	// }else{
	// 	// alert("??????????????????????????????????????????????????????????????????????????????\n ??????????????????????????????????????????????????????????????????");
	// 	// return;
	// 	reqObj.engineer_id = parseInt(engineers[0]);
	// }

	c4s.invokeApi_ex({
		location: "quotation.topPurchase",
		body: reqObj,
		pageMove: true,
		newPage: true
	});

}


$("#m_operation_contract_date, #m_operation_term_begin, #m_operation_term_end, #query_term_begin, #query_term_end, #query_term_begin_exp, #query_term_end_exp, [id^=term_begin], [id^=term_end], [id^=contract_date_], [id^=cutoff_date_]").datepicker({
        weekStart: 1,
        viewMode: "dates",
        language: "ja",
        autoclose: true,
        changeYear: true,
        changeMonth: true,
        dateFormat: "yyyy/mm/dd",
    });
$("#query_contract_month").datepicker({
        startView: 1,
        viewMode: "months",
        minViewMode: 'months',
        language: "ja",
        autoclose: true,
        changeYear: true,
        changeMonth: true,
        dateFormat: "yyyy/mm",
    });

// function appendColumn() {
//
//     var clumn_str = "";
//
//     if(!row_length){
//         return;
//     }
//
//     row_length++;
//
//     clumn_str += '<tr>';
//
//     clumn_str += '<td class="text-center">'
//                 // +'<input type="checkbox" id="iter_operation_selected_cb_0" value="0-0-0-0"/>'
//                 +'</td>';
//
//     clumn_str += '<td class="center">'
//                 // +'<div class="btn-group dropup">'
//                 // +'<a class="btn dropdown-toggle pseudo-link-cursor glyphicon glyphicon-align-justify" data-toggle="dropdown" aria-expanded="false" alt="??????" title="??????"onclick="" style="width: 30px;box-shadow: none; padding: 0;"></a>'
//                 // +'<ul class="dropdown-menu" role="menu">'
//                 // +'<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="color: white;font-size: small;">?????????</a></li>'
//                 // +'<li role="presentation"><a role="menuitem" tabindex="-1" href="#" style="color: white;font-size: small;">??????</a></li>'
//                 // +'</ul>'
//                 // +'</div>'
//                 +'</td>';
//
//     clumn_str += '<td class="center">'
//                 // +'<input type="checkbox" id="is_active_'+ row_length +'" value="1" />'
//                 +'</td>';
//
//
//     clumn_str += '<td class="center"></td>';
//     clumn_str += '<td class="left" id="add_new_column_project_'+ env.addNewColumnNo +'"><a tabIndex="-1" id="aaa" class="pseudo-link-cursor" onclick="selectProjectForNew('+env.addNewColumnNo+');">???????????????</a></td>';
//     clumn_str += '<td class="left" style="border-right: double;border-color: #ddd" id="add_new_column_engineer_'+ env.addNewColumnNo +'"><a class="pseudo-link-cursor" onclick="selectEngineerForNew('+env.addNewColumnNo+');">???????????????</a></td>';
//
//     $('.fixed_header_display_none_at_print #detail-table-body').append(clumn_str);
//
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//     clumn_str += '<td></td>';
//     clumn_str += '<td></td>';
//
//
//     // clumn_str += '<td style="width: 51%;"><input type="text" style="width: 100%;" id="summary_' + rowMax + '"></td>';
//     // clumn_str += '<td style="width: 5%;"><input type="number"style="width: 100%;" id="quantity_' + rowMax + '" onchange="updateCalcOperationResult(' + rowMax + ')"></td>';
//     //
//
//     clumn_str += '</tr>';
//
//     $('#detail-table-body').append(clumn_str);
//     setTimeout(function() {
//         window.scroll(0,$(document).height());
//     },0);
//
//     env.addNewColumnNo++;
// }


function renderRecipientModal(type){

    if(type == "project"){
        c4s.invokeApi_ex({
			location: "project.enumProjects",
			body: genModalFilterQuery(),
			onSuccess: function (res) {
				env.data = env.data || {};
				if (res.data && res.data.length > 0) {
					env.data.projects = res.data;
				} else {
					env.data.projects = [];
				}
				renderRecipientModalTable(type, env.data.projects)
			},
		});
    }else if(type == "engineer" || type == "change_engineer"){
        c4s.invokeApi_ex({
			location: "engineer.enumEngineers",
			body: genModalFilterQuery(),
			onSuccess: function (res) {
				env.data = env.data || {};
				if (res.data && res.data.length > 0) {
					env.data.engineers = res.data;
				} else {
					env.data.engineers = [];
				}
				renderRecipientModalTable(type, env.data.engineers)
			},
		});
    }

}

function renderRecipientModalTable(type, datum) {
	var tbody;
	var tmp_tr;

	if (type === "engineer" || type === "change_engineer") {
	    $("#row_count_engineer").html(datum.length+"???");
		tbody = $("#modal_search_result_engineer tbody");
		if(type === "change_engineer"){
		   tbody = $("#modal_change_result_engineer tbody");
        }
		tbody.html("");
		if (datum && datum instanceof Array && datum.length > 0) {
			datum.map(function (val, idx) {

				tmp_tr = $("<tr></tr>");
				if(type === "engineer"){
				    tmp_tr.append($("<td class='center'><a class='pseudo-link-cursor' onclick='setEngineerForNew(" + val.id +",\""+ val.name + "\",\"" + val.contract + "\"," + val.client_id + "," + val.charging_user.id + ","+ val.fee +",\"" + val.company_name + "\");'>??????</a></td>"));
                }else{
				    tmp_tr.append($("<td class='center'><a class='pseudo-link-cursor' onclick='setTargetOperationEngineer(" + val.id +");'>??????</a></td>"));
                }
				tmp_tr.append($("<td><label for='recipient_iter_engineer_" + val.id + "'>" + val.name + "</label></td>"));
				tmp_tr.append($("<td>" + val.fee + "</td>"));
				tmp_tr.append($("<td style='word-break: break-word;'>" + (val.skill_list || "") + "</td>"));
				tmp_tr.append($("<td>" + val.state_work + (val.state_work ? "<br/>" : "") +
					((val.flg_assignable || val.flg_caution) ?
						"???" +
						[(val.flg_assignable ? "??????????????????" : null), (val.flg_caution ? "?????????" : null)].filter(function (val) {
							return Boolean(val);
					}).join(", ") + "???" : "") +
				"</td>"));
				tmp_tr.append($("<td>" + (val.mail1 || val.mail2) + "</td>"));
				tbody.append(tmp_tr);
			});
		} else {
			tmp_tr = $("<tr></tr>");
			tmp_tr.append($("<td class='center' colspan='6'>??????????????????????????????????????????</td>"));
			tbody.append(tmp_tr);
		}
	} else if (type === "project") {
	    $("#row_count_project").html(datum.length+"???");
        tbody = $("#modal_search_result_project tbody");
        tbody.html("");
        if (datum && datum instanceof Array && datum.length > 0) {
            datum.map(function (val, idx) {
                tmp_tr = $("<tr></tr>");
                tmp_tr.append($("<td class='center'><a class='pseudo-link-cursor' onclick='setProjectForNew(" + val.id +",\""+ val.title + "\",\""+ val.client.id + "\","+ val.charging_user.id + "," + val.fee_inbound + ", \"" + val.skill_id_list + "\"," + JSON.stringify(val.skill_level_list) + ");'>??????</a></td>"));
                tmp_tr.append($("<td>" + val.client_name + "</td>"));
                tmp_tr.append($("<td><label for='recipient_iter_project_" + val.id + "'>" + val.title + "</label></td>"));
                tmp_tr.append($("<td>" + (val.charging_user.user_name || "") + "</td>"));

                tbody.append(tmp_tr);
            });
        } else {
            tmp_tr = $("<tr></tr>");
            tmp_tr.append($("<td class='center' colspan='6'>??????????????????????????????????????????</td>"));
            tbody.append(tmp_tr);
        }
    }
}

function genModalFilterQuery() {
	var queryObj = {};
	var tgtAttrName;
	$("[id^=modal_query_]").each(function(idx, el) {
		if (el.id) {
			tgtAttrName = el.id.replace("modal_query_", "");
			if (el.localName === "input" && el.type === "checkbox") {
				queryObj[tgtAttrName] = el.checked;
			} else {
				if (el.value !== "") {
					queryObj[tgtAttrName] = tgtAttrName.indexOf("flg_") == 0 || tgtAttrName.indexOf("is_") == 0 ? Boolean(Number(el.value)) : el.value;
				}
			}
		}
	});

    if(queryObj.flg_caution.length == 0 || queryObj.flg_caution == false){
		delete???queryObj.flg_caution ;
	}
    if(queryObj.flg_registered.length == 0 || queryObj.flg_registered == false){
		delete???queryObj.flg_registered ;
	}
    if(queryObj.flg_assignable.length == 0 || queryObj.flg_assignable == false){
		delete???queryObj.flg_assignable ;
	}
	return queryObj;
}

function selectProjectForNew(){
    $('#search_project_modal').modal('show');
    renderRecipientModal('project');
}

function selectEngineerForNew() {
    $('#search_engineer_modal').modal('show');
    renderRecipientModal('engineer');
}

function changeEngineerForNew(operation_id) {
    $('#change_engineer_modal').modal('show');
    //tmpValue
    env.updatetargetOperationId = operation_id;
    renderRecipientModal('change_engineer');
}

function setProjectForNew(project_id, project_title, client_id, charging_user_id, base_exc_tax, skill_id_list, skill_level_list){
    $('#search_project_modal').modal('hide');
    $("#m_operation_project").val(project_id);
    $("#m_operation_project_name").val(project_title);
    $("#m_operation_project_client_id").val(client_id);
    $("#m_operation_project_client_id").select2();
    $("#m_operation_project_charging_user_id").val(charging_user_id);
    if(base_exc_tax != ""){
        $("#base_exc_tax_0").val(base_exc_tax);
        updateCalcOperationResult(0);
    }
    $('[name="m_operation_skill[]"]').each(function (idx, el) {
        el.checked = false;
    });
    $('[name="m_operation_skill_level[]"]').each(function (idx, el) {
        el.selectedIndex = 0;
    });

    $('[name="m_operation_skill_level[]"]').addClass("hidden");
    if(skill_id_list != ""){
        $('[name="m_operation_skill[]"]').each(function (index) {
            var setval = $(this).val();
            var skillArr = skill_id_list.split(",");
            if (skillArr.indexOf(setval) >= 0) {
                $(this).val([setval]);
                $('#m_operation_skill_level_' + setval).removeClass("hidden");
                skill_level_list.forEach(function(e, i, a) {
                    if(setval == e["skill_id"] || setval == e["id"]){
                        $("#m_operation_skill_level_" + setval).val(e["level"]);
                    }
                })
            }
        });
    }
    viewSelectedOperationSkill();
}

function setEngineerForNew(engineer_id, name, contract, client_id, charging_user_id, payment_base, company_name){
    $("#search_engineer_modal").modal('hide');
    $("#m_operation_engineer").val(engineer_id);
    $("#m_operation_engineer_name").val(name);
    $("#m_operation_engineer_charging_user_id").val(charging_user_id);
    $("#m_operation_update_engineer_contract").val(contract);
    $("#m_operation_update_engineer_client_id").val(client_id);
    $("#m_operation_update_engineer_client_id").select2({allowClear: true});
    if(payment_base != ""){
        $("#payment_base_0").val(payment_base);
        updateCalcOperationResult(0);
    }
    changeCalcFormArea(contract);
}

function setTargetOperationEngineer(engineer_id){
    var operationObjList = [];
    var operationObj = {
        id: env.updatetargetOperationId,
        engineer_id: engineer_id
    };
    operationObjList.push(operationObj);

    var updateObj = {
        login_id: env.login_id,
        credential: env.credential,
        prefix: env.prefix,
        operationObjList : operationObjList
    }
    updateObject(updateOperationEngineer, updateObj);
}

function updateOperationEngineer(reqObj){

    c4s.invokeApi_ex({
            location: "operation.updateOperation",
            body: reqObj,
            onSuccess: function (data) {
                alert("1????????????????????????");
                c4s.hdlClickSearchBtn();
            },
            onError: function (data) {
                alert("??????????????????????????????" + data.status.description + "???");
            }
        });
}

// function triggerCreateOperationRecord(){
//     updateObject(createOperationRecord,null);
// }
//
// function createOperationRecord(){
//     for(var i=1; i < env.addNewColumnNo ;i++){
//         var project_id = $("#new_column_project_" + i).val();
//         var engineer_id = $("#new_column_engineer_" + i).val();
//
//         if(project_id != undefined && project_id != ""
//             && engineer_id != undefined && engineer_id != "" ){
//
//             var reqObj = {
//                 login_id: env.login_id,
//                 credential: env.credential,
//                 prefix: env.prefix,
//                 operationObjList:[
//                     {
//                         project_id: Number(project_id),
//                         engineer_id: Number(engineer_id),
//                     }
//                 ]
// 		    };
//
//
//             c4s.invokeApi_ex({
//                 location: "operation.createOperation",
//                 body: reqObj,
//                 pageMove: false,
//                 newPage: true,
//                 onSuccess: function (data) {
//                     alert("???????????????????????????");
//                     $("#focus_new_record").val(1);
//                     c4s.hdlClickSearchBtn();
//                 },
//                 onError: function (data) {
//                 alert("???????????????????????????????????????" + data.status.description + "???");
//             }
//             });
//         }
//     }
//
// }

function triggerCopyOperationRecord(id){
    updateObject(copyOperationRecord,id);
}

function copyOperationRecord(id){
    var reqObj = {
                login_id: env.login_id,
                credential: env.credential,
                prefix: env.prefix,
                operation_id: id,
		    };
    c4s.invokeApi_ex({
        location: "operation.copyOperation",
        body: reqObj,
        pageMove: false,
        newPage: true,
        onSuccess: function (data) {
            alert("????????????????????????");
            $("#focus_new_record").val(1);
            c4s.hdlClickSearchBtn();
        },
		onError: function (data) {
			alert("????????????????????????????????????" + data.status.description + "???");
		}
    });
}

function triggerDeleteOperationRecord(id){
    updateObject(deleteOperationRecord,id);
}

function deleteOperationRecord(id){

    if(confirm('????????????????????????????????????')){

        var reqObj = {
                        login_id: env.login_id,
                        credential: env.credential,
                        prefix: env.prefix,
                        operation_id: id,
                    };
        c4s.invokeApi_ex({
            location: "operation.deleteOperation",
            body: reqObj,
            pageMove: false,
            newPage: true,
            onSuccess: function (data) {
                alert("?????????????????????");
                c4s.hdlClickSearchBtn();
            },
            onError: function (data) {
                alert("?????????????????????????????????" + data.status.description + "???");
            }
        });
	}
}


//[begin] Functions for engineer modal.
function hdlClickNewEngineerObj (fromMode) {

    $("#commitNewEngineerObjMode").val("NormalCreate");
    if(fromMode == "changeOperationEngineer"){
        $("#commitNewEngineerObjMode").val("changeOperationEngineer");
    }
	c4s.clearValidate({
            "client_id": "m_engineer_client_id",
            "client_name": "m_engineer_client_name",
			"name": "m_engineer_name",
			"kana": "m_engineer_kana",
			"visible_name": "m_engineer_visible_name",
			"tel": "m_engineer_tel",
			"mail1": "m_engineer_mail1",
			"mail2": "m_engineer_mail2",
			"birth": "m_engineer_birth",
			"gender": "m_engineer_gender_container",
			"state_work": "m_engineer_state_work",
			"age": "m_engineer_age",
			"fee": "m_engineer_fee",
			"station": "m_engineer_station",
			"skill": "m_engineer_skill",
			"note": "m_engineer_note",
			"charging_user_id": "m_engineer_charging_user_id",
			"employer": "m_engineer_employer",
			"operation_begin": "m_engineer_operation_begin",
            "addr_vip": "m_engineer_addr_vip",
			"addr1": "m_engineer_addr1",
			"addr2": "m_engineer_addr2",
		});
	// [begin] Clear fields.
	var textSymbols = [
	    "#m_engineer_client_id",
        "#m_engineer_client_name",
		"#m_engineer_name",
		"#m_engineer_kana",
		"#m_engineer_visible_name",
		"#m_engineer_tel",
		"#m_engineer_mail1",
		"#m_engineer_mail2",
		"#m_engineer_birth",
		"#m_engineer_age",
		"#m_engineer_fee",
		"#m_engineer_station",
		"#m_engineer_state_work",
		"#m_engineer_employer",
		/*
		"#m_engineer_dt_assignable",
		*/
		"#m_engineer_note",
		"#attachment_id_0",
		"#attachment_label_0",
		"#m_engineer_skill",
		"#m_engineer_operation_begin",
		"#m_engineer_station_cd",
		"#m_engineer_station_pref_cd",
		"#m_engineer_station_line_cd",
		"#m_engineer_station_lon",
		"#m_engineer_station_lat",
        "#m_engineer_addr_vip",
		"#m_engineer_addr1",
		"#m_engineer_addr2",
	];
	var checkSymbols = [
		"#m_engineer_flg_caution",
		"#m_engineer_flg_registered",
		"#m_engineer_flg_assignable",
		"#m_engineer_flg_public",
		"#m_engineer_web_public",
        "#m_engineer_flg_careful",
	];
	var comboSymbols = [
		"#m_engineer_contract",
	];
	var radioSymbols = [
		"[name=m_engineer_gender_grp]",
	];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		$(textSymbols[i]).val(null);
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = false;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$("#m_engineer_id").val(null);
	$("#m_engineer_flg_registered")[0].checked = true;
	$("#m_engineer_flg_assignable")[0].checked = true;
	$("#m_engineer_flg_public")[0].checked = false;
	$("#m_engineer_web_public")[0].checked = false;
    $("#m_engineer_flg_careful")[0].checked = false;
	$("#m_engineer_charging_user_id").val(env.userProfile.user.id);
	$('[name="m_engineer_skill_level[]"]').each(function (idx, el) {
		el.selectedIndex = 0;
	});
	$('[name="m_engineer_skill[]"]').each(function (idx, el) {
		el.checked = false;
	});
	viewSelectedEngineerSkill();
	$('[name="m_engineer_occupation[]"]').each(function (idx, el) {
		el.checked = false;
	});
	// [end] Clear fields.
	setEngineerMenuItem(0, 0, null, null);
	$("#es").val(0);
	$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>??????????????????</span>"));
	deleteEngineerAttachment(0);
	$("#edit_engineer_modal").modal("show");
	$('#m_engineer_client_id').select2({allowClear: true});
	$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3??????5???),PHP(1??????2???)</span>");
}

function updateAge() {
	var tmpDtStr = $("#m_engineer_birth").val();
	var tmpYYYY = tmpDtStr ? tmpDtStr.split("/")[0] : null;
	var tmpMM = tmpDtStr ? tmpDtStr.split("/")[1] : null;
	var tmpDD = tmpDtStr ? tmpDtStr.split("/")[2] : null;

	if (tmpYYYY && tmpMM && tmpDD) {
		var now = new Date();
		var ageDate = new Date(tmpYYYY, tmpMM, tmpDD);
		var age = now.getFullYear() - Number(tmpYYYY);
		if(haveBirthday(ageDate)){
			age = age - 1;
		}
		$("#m_engineer_age").val(age);
	} else {
		void(0);
	}
}

function haveBirthday(date) {
	var now = new Date();
	var month1 = now.getMonth() + 1;
	var day1 = now.getDate();

	var month2= date.getMonth();
	var day2 = date.getDate();

	if (month1 == month2) {
		return day1 < day2;
	}
	else {
		return month1 < month2;
	}
}

function commitNewEngineerObj() {
    var mode = $("#commitNewEngineerObjMode").val();
	var reqObj = genCommitValueOfEngineer();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.engineer,
		{
			"client_id": "m_engineer_client_id",
            "client_name": "m_engineer_client_name",
		    "name": "m_engineer_name",
			"kana": "m_engineer_kana",
			"visible_name": "m_engineer_visible_name",
			"tel": "m_engineer_tel",
			"mail1": "m_engineer_mail1",
			"mail2": "m_engineer_mail2",
			"age": "m_engineer_age",
			"birth": "m_engineer_birth",
			"gender": "m_engineer_gender_container",
			"state_work": "m_engineer_state_work",
			"fee": "m_engineer_fee",
			"station": "m_engineer_station",
			"skill": "m_engineer_skill",
			"note": "m_engineer_note",
			"charging_user_id": "m_engineer_charging_user_id",
			"employer": "m_engineer_employer",
			"operation_begin": "m_engineer_operation_begin",
            "addr_vip": "m_engineer_addr_vip",
			"addr1": "m_engineer_addr1",
			"addr2": "m_engineer_addr2",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return;
	}
	c4s.invokeApi_ex({
		location: "engineer.createEngineer",
		body: reqObj,
		onSuccess: function(data) {
			alert("1????????????????????????");
			var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
                var onSuccessFunc = function () {
					$("#edit_engineer_modal").modal("hide");
					if(mode == "changeOperationEngineer"){
					    setTargetOperationEngineer(data.data.id);
                    }else{
			            setEngineerForNew(data.data.id, reqObj.name, reqObj.contract, reqObj.client_id, reqObj.charging_user_id, reqObj.fee, "");
                    }
                };
                if(flg_public_update){
					updateAccountFlgPublic(onSuccessFunc);
				}else{
					onSuccessFunc();
				}
		},
		onError: function(data) {
			alert("?????????????????????????????????" + data.status.description + "???");
		},
	});
}

function deleteEngineerAttachment(loop_idx) {
	var fileInputEl = $("#attachment_file_" + loop_idx);
	var fileIdEl = $("#attachment_id_" + loop_idx);
	var labelEl = $("#attachment_label_" + loop_idx);
	var commitBtnEl = $("#attachment_btn_commit_" + loop_idx);
	var deleteBtnEl = $("#attachment_btn_delete_" + loop_idx);
	fileInputEl.val(null);
	fileInputEl.css("display", "inline");
	fileIdEl.val(null);
	labelEl.html("");
	labelEl.css("display", "none");
	commitBtnEl.css("display", "none");
	deleteBtnEl.css("display", "none");
	$(".input-file-message").removeClass("hidden");
}

function uploadFileEngineer(loop_idx) {
	var fileInputEl = $("#attachment_file_" + loop_idx);
	var fileIdEl = $("#attachment_id_" + loop_idx);
	var labelEl = $("#attachment_label_" + loop_idx);
	var commitBtnEl = $("#attachment_btn_commit_" + loop_idx);
	var deleteBtnEl = $("#attachment_btn_delete_" + loop_idx);
	if (window.FormData) {
		var fd = new FormData();
		var fi = fileInputEl[0];
		if (fi.files.length) {
			fd.append("attachement", fi.files[0]);
			fd.append("json", JSON.stringify({
				login_id: env.login_id,
				credential: env.credential,
			}));
			$.ajax({
				url: "/" + env.prefix + "/api/file.upload/json",
				type: "POST",
				data: fd,
				processData: false,
				contentType: false,
				dataType: 'json',
				success: function (data) {
					if (data && data.data && data.data.id && data.status.code == 0) {
						fileIdEl.val(data.data.id);
						labelEl.html(data.data.filename + "&nbsp;(<span class='mono'>" + data.data.size + "bytes</span>)");
						labelEl.css("display", "inline");
						fileInputEl.css("display", "none");
						commitBtnEl.css("display", "inline");
						deleteBtnEl.css("display", "inline");
					} else if (data && data.status.code == 13 && data.data && data.data.size && data.data.limit) {
						window.alert(data.status.description + "????????????" + data.data.limit + "bytes???????????????????????????????????????????????????????????????" + data.data.size + "bytes????????????" + String((data.data.size / data.data.limit - 1) * 100).split(".")[0] + "???????????????");
					} else if (data && data.status.code) {
						window.alert(data.status.description);
						fileInputEl.val(null);
						fileIdEl.val(null);
					} else {
						window.console ? console.log("file upload error.") : void(0);
					}
				},
				error: function (data) {

				}
			});
		}
	} else {
		alert("FormData???????????????Web?????????????????????Web??????????????????????????????????????????????????????????????????");
	}
}

function genCommitValueOfEngineer() {
	var reqObj = {};

    reqObj.fee = formatForCalc($("#m_engineer_fee").val());

	var textSymbols = [
	    ["#m_engineer_client_id", Number],
        ["#m_engineer_client_name", String],
		["#m_engineer_name", String],
		["#m_engineer_kana", String],
		["#m_engineer_visible_name", String],
		["#m_engineer_tel", String],
		["#m_engineer_mail1", String],
		["#m_engineer_mail2", String],
		["#m_engineer_age", Number],
		["#m_engineer_station", String],
		["#m_engineer_note", String],
		["#attachment_id_0", Number],
		["#m_engineer_skill", String],
		["#m_engineer_state_work", String],
		["#m_engineer_employer", String],
		["#m_engineer_operation_begin", String],
		["#m_engineer_station_cd", String],
		["#m_engineer_station_pref_cd", String],
		["#m_engineer_station_line_cd", String],
		["#m_engineer_station_lon", Number],
		["#m_engineer_station_lat", Number],
        ["#m_engineer_addr_vip", String],
		["#m_engineer_addr1", String],
		["#m_engineer_addr2", String],
	];
	var datepickerSymbols = [
		["#m_engineer_birth", String],
	];
	var checkSymbols = [
		["#m_engineer_flg_caution", Boolean],
		["#m_engineer_flg_registered", Boolean],
		["#m_engineer_flg_assignable", Boolean],
		["#m_engineer_flg_public", Boolean],
		["#m_engineer_web_public", Boolean],
        ["#m_engineer_flg_careful", Boolean],
	];
	var comboSymbols = [
		["#m_engineer_contract", String],
		["#m_engineer_charging_user_id", Number],
	];
	var radioSymbols = [
		["[name=m_engineer_gender_grp]:checked", String],
	];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = textSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = datepickerSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_engineer_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_engineer_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	if (reqObj.attachment_id_0) {
		reqObj.attachement = reqObj.attachment_id_0;
		delete reqObj.attachment_id_0;
	} else {
		reqObj.attachement = null;
	}

	reqObj.skill_level_list = [];
	reqObj.skill_id_list = $('[name="m_engineer_skill[]"]:checked').map(function(){
		var skill_id = $(this).val();
		var skill_level = $("#m_engineer_skill_level_" + skill_id).val();
		if(skill_level != ""){
			reqObj.skill_level_list.push({"id": skill_id, "level":skill_level});
		}
  		return skill_id;
	}).get();
	if(reqObj.skill_id_list.length == 0){
		delete???reqObj.skill_id_list;
	}

	reqObj.occupation_id_list = $('[name="m_engineer_occupation[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.occupation_id_list.length == 0){
		delete???reqObj.occupation_id_list;
	}

	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}

	return reqObj;
}
//[end] Functions for engineer modal.


//[begin] Functions for project modal.
function hdlClickNewProjectObj () {
	c4s.clearValidate({
		"id": "m_project_id",
		"client_id": "m_project_client_id",
		"client_name": "m_project_client_name",
		"title": "m_project_title",
		"term": "m_project_term",
		"term_begin": "m_project_term_begin",
		"term_end": "m_project_term_end",
		"age_from": "m_project_age_from",
		"age_to": "m_project_age_to",
		"fee_inbound": "m_project_fee_inbound",
		"fee_outbound": "m_project_fee_outbound",
		"expense": "m_project_expense",
		"process": "m_project_process",
		"interview": "m_project_interview_container",
		"station": "m_project_station_container",
		"scheme": "m_project_scheme_container",
		"skill_needs": "m_project_skill_needs",
		"skill_recommends": "m_project_skill_recommends",
		"rank_id" : "m_project_rank_id_container",
	});
	// [begin] Clear fields.
	var textSymbols = [
		"#m_project_id",
		"#m_project_client_name",
		"#m_project_client_id",
		"#m_project_fee_inbound",
		"#m_project_fee_outbound",
		"#m_project_expense",
		"#m_project_title",
		"#m_project_process",
		["#m_project_interview", 1],
		"#m_project_station",
		"#m_project_note",
		"#m_project_term",
		"#m_project_term_begin",
		"#m_project_term_end",
		["#m_project_age_from", 22],
		["#m_project_age_to", 65],
		"#m_project_skill_needs",
		"#m_project_skill_recommends",
		"#m_project_station_cd",
		"#m_project_station_pref_cd",
		"#m_project_station_line_cd",
		"#m_project_station_lon",
		"#m_project_station_lat",
	];
	var checkSymbols = [
		"#m_project_flg_shared",
	];
	var notCheckSymbols = [
		"#m_project_flg_public",
		"#m_project_web_public",
	];
	var comboSymbols = [];
	var radioSymbols = [
		"[name=m_project_rank_grp]",
	];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		if (textSymbols[i] instanceof Array) {
			$(textSymbols[i][0])[0].value = textSymbols[i][1];
		} else {
			$(textSymbols[i])[0].value = "";
		}
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = true;
	}
	for (i = 0; i < notCheckSymbols.length; i++) {
		$(notCheckSymbols[i])[0].checked = false;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$('[name="m_project_skill[]"]').each(function (idx, el) {
		el.checked = false;
	});
    $('[name="m_project_skill_level[]"]').each(function (idx, el) {
		el.selectedIndex = 0;
	});
	viewSelectedProjectSkill();
	$('[name="m_project_occupation[]"]').each(function (idx, el) {
		el.checked = false;
	});
	$("#m_project_scheme").val(null);
	$("#m_project_charging_user_id").val(env.userProfile.user.id);
	// [end] Clear fields.

    $("#m_project_scheme").val("?????????");

	setProjectMenuItem(0, 0, null, null);
	$("#ps").val(0);

	$("#m_project_worker_container").addClass("hidden");
	$("#edit_project_modal_title").html("??????????????????");
	$("#edit_project_modal").modal("show");
	$('#m_project_client_id').select2();
}

function genCommitValueOfProject() {
	var reqObj = {};
	if ($("#m_project_id").val()) {
		reqObj.id = Number($("#m_project_id").val());
	}

    reqObj.fee_inbound = formatForCalc($("#m_project_fee_inbound").val());
    reqObj.fee_outbound = formatForCalc($("#m_project_fee_outbound").val());

	var textSymbols = [
		["#m_project_client_name", String],
		["#m_project_client_id", Number],
		["#m_project_expense", String],
		["#m_project_title", String],
		["#m_project_process", String],
		["#m_project_interview", Number],
		["#m_project_station", String],
		["#m_project_note", String],
		["#m_project_term", String],
		["#m_project_term_begin", String],
		["#m_project_term_end", String],
		["#m_project_age_from", Number],
		["#m_project_age_to", Number],
		["#m_project_skill_needs", String],
		["#m_project_skill_recommends", String],
		["#m_project_station_cd", String],
		["#m_project_station_pref_cd", String],
		["#m_project_station_line_cd", String],
		["#m_project_station_lon", Number],
		["#m_project_station_lat", Number],

	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["#m_project_flg_shared", Boolean],
		["#m_project_flg_public", Boolean],
		["#m_project_web_public", Boolean],
	];
	var comboSymbols = [
		["#m_project_client_id", Number],
		["#m_project_scheme", String],
		["#m_project_charging_user_id", Number],
	];
	var radioSymbols = [
		["[name=m_project_rank_grp]:checked", Number],
	];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_project_", "")] = textSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("m_project_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_project_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_project_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_project_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	if(reqObj.rank){
		reqObj.rank_id = reqObj.rank;
		delete reqObj.rank;
	}
    if(reqObj.client_id == 0){
			reqObj.client_id = null;
	}
	if (reqObj.client_id) {
		delete reqObj.client_name;
	}
	if (reqObj.charging_user_id == 0) {
		reqObj.charging_user_id = null;
	}
    reqObj.skill_level_list = [];
	reqObj.needs = $('[name="m_project_skill[]"]:checked').map(function(){
  		var skill_id = $(this).val();
  		var skill_level = $("#m_project_skill_level_" + skill_id).val();
		if(skill_level != ""){
			reqObj.skill_level_list.push({"id": skill_id, "level":skill_level});
		}
		return skill_id;
	}).get();
	if(reqObj.needs.length == 0){
		delete???reqObj.needs;
	}

	reqObj.occupations = $('[name="m_project_occupation[]"]:checked').map(function(){
  		return $(this).val();
	}).get();
	if(reqObj.occupations.length == 0){
		delete???reqObj.occupations;
	}

	env.debugOut(reqObj);
	return reqObj;
}

function triggerCommitProjectObject(updateFlg){
    updateObject(commitProjectObject,updateFlg);
}

function commitProjectObject(updateFlg) {
    updateFlg = (updateFlg == 1) ? true: false;
	var reqObj = genCommitValueOfProject();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.project,
		{
			"id": "m_project_id",
			"client_id": "m_project_client_id",
			"client_name": "m_project_client_name",
			"title": "m_project_title",
			"term": "m_project_term",
			"term_begin": "m_project_term_begin",
			"term_end": "m_project_term_end",
			"age_from": "m_project_age_from",
			"age_to": "m_project_age_to",
			"fee_inbound": "m_project_fee_inbound",
			"fee_outbound": "m_project_fee_outbound",
			"expense": "m_project_expense",
			"process": "m_project_process",
			"interview": "m_project_interview_container",
			"station": "m_project_station_container",
			"scheme": "m_project_scheme_container",
			"skill_needs": "m_project_skill_needs",
			"skill_recommends": "m_project_skill_recommends",
			"rank_id": "m_project_rank_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return;
	}
	if(validateCondition(reqObj)){
		return;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "project.updateProject" : "project.createProject",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1????????????????????????" : "1????????????????????????");
			var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
                var onSuccessFunc = function () {
					$("#edit_project_modal").modal("hide");

					var client_name = $('#m_project_client_id option:selected').text();

			        setProjectForNew(data.data.id, reqObj.title, client_id, reqObj.charging_user_id, reqObj.fee_inbound, reqObj.needs.join(","), reqObj.skill_level_list);
                };
                if(updateFlg){
                    onSuccessFunc = function () {
                        $("#edit_project_modal").data("commitCompleted", true);
                        $("#edit_project_modal").modal("hide");
                        c4s.hdlClickSearchBtn();
                    };
                }
                if(flg_public_update){
					updateAccountFlgPublic(onSuccessFunc);
				}else{
					onSuccessFunc();
				}
		},
		onError: function (data) {
			alert((updateFlg ? "??????" : "??????") + "????????????????????????" + data.status.description + "???");
		}
	});
}
//[end] Functions for project modal.

function editProjectSkillCondition(){
	$('#edit_project_skill_condition_modal').modal('show');
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
		$("#m_project_skill_container").html("<span style='color:#9b9b9b;'>java(3??????5???),Oracle,Spring</span>");
	}
}

function editEngineerSkillCondition(){
	$('#edit_engineer_skill_condition_modal').modal('show');
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
		$("#m_engineer_skill_container").html("<span style='color:#9b9b9b;'>java(3??????5???),PHP(1??????2???)</span>");
	}
}

function editOperationSkillCondition(){
	$('#edit_operation_skill_condition_modal').modal('show');
}

function viewSelectedOperationSkill() {
	$('[name="m_operation_skill_level[]"]').addClass("hidden");
	selectedSkill = $('[name="m_operation_skill[]"]:checked').map(function(){
	    var targetId = '#m_operation_skill_level_' + $(this).val();
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
		$("#m_operation_skill_container").html(selectedSkill2.join(','));
	}else{
		$("#m_operation_skill_container").html("<span style='color:#9b9b9b;'>?????????????????????????????????</span>");
	}
}

function editProjectStationCondition(){
	$('#edit_project_station_condition_modal').modal('show');
}

var xml = {};
function setProjectMenuItem(type, code, selected_line, selected_station) {

    var s = document.getElementsByTagName("head")[0].appendChild(document.createElement("script"));
    s.type = "text/javascript";
    s.charset = "utf-8";


    if (type == 0) {
    	$('#ps0 > option').remove();
		$('#ps1 > option').remove();
		$('#ps1').append($('<option>').html("----").val(0));

        if (code == 0) {
			$('#ps0').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/p/" + code + ".json";
        }
    } else if(type == 1) {
        $('#ps1 > option').remove();
        if (code == 0) {
			$('#ps1').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/l/" + code + ".json";
        }
    } else{
    	s.src = "http://www.ekidata.jp/api/s/" + code + ".json";
	}
    xml.onload = function (data) {
        var line = data["line"];
        var station_l = data["station_l"];
        var station = data["station"];

        if (line != null) {
			$('#ps0').append($('<option>').html("----").val(0));
            for (i = 0; i < line.length; i++) {
                ii = i + 1;
                var op_line_name = line[i].line_name;
                var op_line_cd = line[i].line_cd;
                var op_obj = $('<option>').html(op_line_name).val(op_line_cd);
                if(selected_line && op_line_cd == selected_line){
                	op_obj.prop('selected', true);
				}
                $('#ps0').append(op_obj);
            }
        }
        if (station_l != null) {
			$('#ps1').append($('<option>').html("----").val(0));
            for (i = 0; i < station_l.length; i++) {
                ii = i + 1;
                var op_station_name = station_l[i].station_name;
                var op_station_cd = station_l[i].station_cd;
                var op_obj = $('<option>').html(op_station_name).val(op_station_cd);
                if(selected_station && op_station_cd == selected_station){
                	op_obj.prop('selected', true);
				}
                $('#ps1').append(op_obj);
            }
        }
        if(station != null){
        	var station_info = station[0];
        	$("#m_project_station_cd").val(station_info.station_cd);
        	$("#m_project_station_pref_cd").val(station_info.pref_cd);
        	$("#m_project_station_line_cd").val(station_info.line_cd);
        	$("#m_project_station_lon").val(station_info.lon);
        	$("#m_project_station_lat").val(station_info.lat);
        	$("#m_project_station").val(station_info.station_name);

		}
    }
}

function editEngineerStationCondition(){
	$('#edit_engineer_station_condition_modal').modal('show');
}

function setEngineerMenuItem(type, code, selected_line, selected_station) {

    var s = document.getElementsByTagName("head")[0].appendChild(document.createElement("script"));
    s.type = "text/javascript";
    s.charset = "utf-8";


    if (type == 0) {
    	$('#es0 > option').remove();
		$('#es1 > option').remove();
		$('#es1').append($('<option>').html("----").val(0));

        if (code == 0) {
			$('#es0').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/p/" + code + ".json";
        }
    } else if(type == 1) {
        $('#es1 > option').remove();
        if (code == 0) {
			$('#es1').append($('<option>').html("----").val(0));
        } else {
            s.src = "http://www.ekidata.jp/api/l/" + code + ".json";
        }
    } else{
    	s.src = "http://www.ekidata.jp/api/s/" + code + ".json";
	}
    xml.onload = function (data) {
        var line = data["line"];
        var station_l = data["station_l"];
        var station = data["station"];

        if (line != null) {
			$('#es0').append($('<option>').html("----").val(0));
            for (i = 0; i < line.length; i++) {
                ii = i + 1;
                var op_line_name = line[i].line_name;
                var op_line_cd = line[i].line_cd;
                var op_obj = $('<option>').html(op_line_name).val(op_line_cd);
                if(selected_line && op_line_cd == selected_line){
                	op_obj.prop('selected', true);
				}
                $('#es0').append(op_obj);
            }
        }
        if (station_l != null) {
			$('#es1').append($('<option>').html("----").val(0));
            for (i = 0; i < station_l.length; i++) {
                ii = i + 1;
                var op_station_name = station_l[i].station_name;
                var op_station_cd = station_l[i].station_cd;
                var op_obj = $('<option>').html(op_station_name).val(op_station_cd);
                if(selected_station && op_station_cd == selected_station){
                	op_obj.prop('selected', true);
				}
                $('#es1').append(op_obj);
            }
        }
        if(station != null){
        	var station_info = station[0];
        	$("#m_engineer_station_cd").val(station_info.station_cd);
            $("#m_engineer_station_pref_cd").val(station_info.pref_cd);
            $("#m_engineer_station_line_cd").val(station_info.line_cd);
            $("#m_engineer_station_lon").val(station_info.lon);
            $("#m_engineer_station_lat").val(station_info.lat);
            $("#m_engineer_station").val(station_info.station_name);
		}
    }
}

$("#m_project_term_begin, #m_project_term_end, #m_engineer_operation_begin").datepicker({
	weekStart: 1,
	viewMode: "dates",
	language: "ja",
	autoclose: true,
	changeYear: true,
	changeMonth: true,
	dateFormat: "yyyy/mm/dd",
});


function changeDemandUnit(obj, rowId){
    unsaved = true;

    if(obj.value == "1"){
        $("#base_exc_tax_" + rowId).attr('readonly',false);
    }else{
        $("#base_exc_tax_" + rowId).attr('readonly',true);
    }
}
function changeDemandUnitForModal(obj, rowId){

    if(obj.value == "1"){
        $("#base_exc_tax_" + rowId).attr('readonly',false);
        $(".demand_wage_area").hide();
    }else{
        $("#base_exc_tax_" + rowId).attr('readonly',true);
        $(".demand_wage_area").show();
    }
}

function openCalcBaseForm(rowId){
    if($("#demand_unit_" + rowId).val() == "2"){
        $("#calc_base_exc_tax_form_" + rowId).show();
        if($("#demand_working_time_" + rowId).val() == ""){
            $("#demand_working_time_" + rowId).val(160);
        }
    }
}

function setBaseExcTax(rowId){
    var demand_wage_per_hour = $("#demand_wage_per_hour_" + rowId).val();
    var demand_working_time = $("#demand_working_time_" + rowId).val();

    if (demand_wage_per_hour === undefined || demand_wage_per_hour === ""
        || demand_working_time === undefined || demand_working_time === "") {
        return;
    }

    demand_wage_per_hour = formatForCalc(demand_wage_per_hour);
    demand_working_time = formatForCalc(demand_working_time);

    var base_exc_tax = Math.round(demand_wage_per_hour * demand_working_time);

    $("#base_exc_tax_" + rowId).val(formatForView(base_exc_tax));
    $("#demand_wage_per_hour_" + rowId).val(formatForView(demand_wage_per_hour));
    $("#demand_working_time_" + rowId).val(demand_working_time);

    updateCalcOperationResult(rowId);
}

function changePaymentUnit(obj, rowId){
    unsaved = true;

    if(obj.value == "1"){
        $("#payment_base_" + rowId).attr('readonly',false);
    }else{
        $("#payment_base_" + rowId).attr('readonly',true);
    }
}
function changePaymentUnitForModal(obj, rowId){

    if(obj.value == "1"){
        $("#payment_base_" + rowId).attr('readonly',false);
        $(".payment_wage_area").hide();
    }else{
        $("#payment_base_" + rowId).attr('readonly',true);
        $(".payment_wage_area").show();
    }
}

function openCalcPaymentBaseForm(rowId){
    if($("#payment_unit_" + rowId).val() == "2"){
        $("#calc_payment_base_exc_tax_form_" + rowId).show();
        if($("#payment_working_time_" + rowId).val() == ""){
            $("#payment_working_time_" + rowId).val(160);
        }
    }
}

function setPaymentBaseExcTax(rowId){
    var payment_wage_per_hour = $("#payment_wage_per_hour_" + rowId).val();
    var payment_working_time = $("#payment_working_time_" + rowId).val();

    if (payment_wage_per_hour === undefined || payment_wage_per_hour === ""
        || payment_working_time === undefined || payment_working_time === "") {
        return;
    }

    payment_wage_per_hour = formatForCalc(payment_wage_per_hour);
    payment_working_time = formatForCalc(payment_working_time);

    var base_exc_tax = Math.round(payment_wage_per_hour * payment_working_time);

    $("#payment_base_" + rowId).val(formatForView(base_exc_tax));
    $("#payment_wage_per_hour_" + rowId).val(formatForView(payment_wage_per_hour));
    $("#payment_working_time_" + rowId).val(payment_working_time);

    updateCalcOperationResult(rowId);
}

function openCalcDemandTermForm(rowId){
    if(true){
        $("#calc_demand_term_form_" + rowId).show();
    }
}

function openCalcPaymentTermForm(rowId){
    if(true){
        $("#calc_payment_term_form_" + rowId).show();
    }
}


function openCalcAllowanceForm(rowId){
    if(true){
        $("#calc_allowance_form_" + rowId).show();
    }
}

function setAllowanceHelpMessageStr(obj){

    var str = "<span style='font-size: small;color: black'>"
            + "?????????????????????????????????????????????????????????????????????<br>"
            + "?????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????<br>"
            + "<br>"
            + "?????????????????????<br>"
            + "???????????????????????????????????????????????????????????????????????????????????????<br>"
            + "<br>"
            + "???????????????<br>"
            + "?????????????????????????????????????????????????????????????????????????????????????????????<br>"
            + "<br>"
            + "????????????<br>"
            + "????????????????????????????????????????????????<br>"
            + "???????????????2????????????????????????????????????1/6????????????????????????????????????????????????<br>"
            + "<br>"
            + "??????30?????????????????????????????????2?????????????????????6???12????????2???<br>"
            + "5??????30?????6<br>"
            + "<br>"
            + "????????????????????????????????????????????????????????????????????????????????????<br>"
            + "<span>"
    $(".allowanceHelp").attr("data-content", str);
}

function setAutocompleteSite() {
    var site_data = [
        '????????????????????????',
        '??????????????????10?????????',
        '??????????????????15?????????',
        '??????????????????20?????????',
        '??????????????????25?????????',
        '??????????????????????????????',
        '20????????????????????????',
        '20???????????????5?????????',
        '20???????????????10?????????',
        '20???????????????15?????????',
        '20???????????????20?????????',
        '20???????????????25?????????',
        '20???????????????????????????'
    ];
    $('.autocomplete_site').autocomplete({
		source: site_data,
        minLength: 0,
		select: function (evt, itemDict) {
		},
	});
}

function setAutocompleteDemandMemo() {
    var data = [
        '??????',
        '8???????????-8???????????+20h'
    ];
    $('.autocomplete_demand_memo').autocomplete({
		source: data,
        minLength: 0,
		select: function (evt, itemDict) {
		},
	});
}

function setAutoKana(){
    env.ak_new_client = new AutoKana("new_client_name", "new_client_kana", {katakana: true});
	$("#new_client_name").on("blur", function (evt) {
		$("#new_client_kana").val($("#new_client_kana").val().replace("????????????????????????", "").replace("????????????????????????", "").replace("????????????????????????", ""));
	});
	env.ak_client = new AutoKana("m_client_name", "m_client_kana", {katakana: true});
	env.ak_worker = new AutoKana("ms_worker_name", "ms_worker_kana", {katakana: true});
	$("#m_client_name").on("blur", function (evt) {
		$("#m_client_kana").val($("#m_client_kana").val().replace("????????????????????????", "").replace("????????????????????????", "").replace("????????????????????????", ""));
	});
	env.ak_client = new AutoKana("m_engineer_name", "m_engineer_kana", {katakana: true});
}

function setDatePicker(){
    $("#m_engineer_birth").datepicker({
		weekStart: 1,
		startView: 2,
		viewMode: "years",
		language: "ja",
		autoclose: true,
		changeYear: true,
		changeMonth: true,
		dateFormat: "yyyy/mm/dd",
	});
	$("#m_engineer_operation_begin").datepicker({
		weekStart: 1,
		viewMode: "dates",
		language: "ja",
		autoclose: true,
		changeYear: true,
		changeMonth: true,
		dateFormat: "yyyy/mm/dd",
	});
	$("#m_engineer_birth").on("hide", function() {
		updateAge();
	});
}


function validateCondition(reqObj){

	$("#m_project_term_begin").parent().parent().parent().parent().removeClass("has-error");
	$("#m_project_term_end").parent().parent().parent().parent().removeClass("has-error");
	if(reqObj.term_begin && reqObj.term_end){
		if(reqObj.term_begin > reqObj.term_end){
			alert("???????????????????????????????????????????????????????????????????????????");
			$("#m_project_term_end").focus();
			$("#m_project_term_begin").parent().parent().parent().parent().addClass("has-error");
			$("#m_project_term_end").parent().parent().parent().parent().addClass("has-error");
			return true;
		}
	}

	$("#m_project_age_from").parent().parent().parent().parent().removeClass("has-error");
	$("#m_project_age_to").parent().parent().parent().parent().removeClass("has-error");
	if(reqObj.age_from && reqObj.age_to){
		if(Number(reqObj.age_from) > Number(reqObj.age_to)){
			alert("??????????????????????????????????????????????????????????????????");
			$("#m_project_age_to").focus();
			$("#m_project_age_from").parent().parent().parent().parent().addClass("has-error");
			$("#m_project_age_to").parent().parent().parent().parent().addClass("has-error");
			return true;
		}
	}

	return false;
}

function validateOperationCondition(reqObj){

	$("#m_operation_term_begin").parent().parent().parent().parent().removeClass("has-error");
	$("#m_operation_term_end").parent().parent().parent().parent().removeClass("has-error");
	if(reqObj.term_begin && reqObj.term_end){
		if(reqObj.term_begin > reqObj.term_end){
			alert("???????????????????????????????????????????????????????????????????????????");
			$("#m_operation_term_end").focus();
			$("#m_operation_term_begin").parent().parent().parent().parent().addClass("has-error");
			$("#m_operation_term_end").parent().parent().parent().parent().addClass("has-error");
			return true;
		}
	}

	return false;
}

function stackUpdateEngineerClient(engineer_id, client_id) {
    unsaved = true;
    env.updateEngineerClientStackList = env.updateEngineerClientStackList || [];

    var targetEngineerId = engineer_id;
    env.updateEngineerClientStackList.some(function(v, i){
        if (v.engineer_id==targetEngineerId) env.updateEngineerClientStackList.splice(i,1);
    });
    var updateEngineerClientStack ={
        engineer_id : engineer_id,
        client_id : client_id
    };
    env.updateEngineerClientStackList.push(updateEngineerClientStack);
}

function stackUpdateEngineerChargingUser(engineer_id, charging_user_id) {
    unsaved = true;
    env.updateEngineerChargingUserStackList = env.updateEngineerChargingUserStackList || [];

    var targetEngineerId = engineer_id;
    env.updateEngineerChargingUserStackList.some(function(v, i){
        if (v.engineer_id==targetEngineerId) env.updateEngineerChargingUserStackList.splice(i,1);
    });
    var updateEngineerChargingUserStack ={
        engineer_id : engineer_id,
        charging_user_id : charging_user_id
    };
    env.updateEngineerChargingUserStackList.push(updateEngineerChargingUserStack);
}

function stackUpdateProjectChargingUser(project_id, charging_user_id) {
    unsaved = true;
    env.updateProjectChargingUserStackList = env.updateProjectChargingUserStackList || [];

    var targetProjectId = project_id;
    env.updateProjectChargingUserStackList.some(function(v, i){
        if (v.engineer_id==targetProjectId) env.updateProjectChargingUserStackList.splice(i,1);
    });
    var updateProjectChargingUserStack ={
        project_id : project_id,
        charging_user_id : charging_user_id
    };
    env.updateProjectChargingUserStackList.push(updateProjectChargingUserStack);
}



function showAddNewClientModal(mode) {

    c4s.clearValidate({
		"name": "new_client_name",
		"kana": "new_client_kana",
		"addr_vip": "new_client_addr_vip_container",
		"addr1": "new_client_addr1",
		"addr2": "new_client_addr2",
		"tel": "new_client_tel",
		"fax": "new_client_fax",
		"site": "new_client_site",
		"type_presentation": "new_client_type_presentation_container",
	});
	// [begin] Clear fields.
	$("#new_client_addr1_alert").html("");
	var textSymbols = [
		"#new_client_name",
		"#new_client_kana",
		"#new_client_addr_vip",
		"#new_client_addr1",
		"#new_client_addr2",
		"#new_client_tel",
		"#new_client_fax",
		"#new_client_site",
		"#new_client_note",
	];
	var checkSymbols = [
		"#new_client_type_presentation_0",
		"#new_client_type_presentation_1",
	];
	var comboSymbols = [
		"#new_client_type_dealing",
		"#new_client_charging_worker1",
		"#new_client_charging_worker2",
	];
	var radioSymbols = [
		/*"[name=m_client_gender_grp]",*/
	];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		if (textSymbols[i] instanceof Array) {
			$(textSymbols[i][0])[0].value = textSymbols[i][1];
		} else {
			$(textSymbols[i])[0].value = "";
		}
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = false;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$("#new_client_charging_worker1").val(env.userProfile.user.id);
	$("#new_client_type_dealing")[0].selectedIndex = 1;

	$("#add_new_client_modal").modal('show');
	$("#add_new_client_mode").val(mode);
}

function commitNewClient() {
	var reqObj = genCommitValueOfNewClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "new_client_name",
			"kana": "new_client_kana",
			"addr_vip": "new_client_addr_vip",
			"addr1": "new_client_addr1",
			"addr2": "new_client_addr2",
			"tel": "new_client_tel",
			"fax": "new_client_fax",
			"site": "new_client_site",
			"type_presentation": "new_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return false;
	}
	c4s.invokeApi_ex({
		location: "client.createClient",
		body: reqObj,
		onSuccess: function (data) {
			alert("1????????????????????????");
			setNewClientOption(data.data.id, reqObj.name);
			$("#add_new_client_modal").modal("hide");
		},
		onError: function (data) {
			alert("??????????????????????????????");
		}
	});
}

function genCommitValueOfNewClient () {
	var reqObj = {};
	var textSymbols = [
		["#new_client_id", Number],
		["#new_client_name", String, ""],
		["#new_client_kana", String, ""],
		["#new_client_addr_vip", String, ""],
		["#new_client_addr1", String, ""],
		["#new_client_addr2", String, ""],
		["#new_client_tel", String, ""],
		["#new_client_fax", String, ""],
		["#new_client_site", String, ""],
		["#new_client_note", String, ""],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [
		["#new_client_type_dealing", String],
		["#new_client_charging_worker1", Number],
		["#new_client_charging_worker2", Number],
	];
	var radioSymbols = [];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		if (tmpEl.val()) {
			reqObj[tmpEl.attr("id").replace("new_client_", "")] = textSymbols[i][1](tmpEl.val());
		} else if (tmpEl.val() === "" && textSymbols[i].length == 3) {
			reqObj[tmpEl.attr("id").replace("new_client_", "")] = textSymbols[i][1](textSymbols[i][2]);
		}
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("new_client_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("new_client_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("new_client_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("new_client_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	// [begin] Variable filters.
	reqObj.charging_worker1 = reqObj.charging_worker1 || null;
	reqObj.charging_worker2 = reqObj.charging_worker2 || null;
	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}
	reqObj.type_presentation = [];
	$("[id^=new_client_type_presentation_]").each(function (idx, el) {
		if (el.checked) {
			reqObj.type_presentation.push(el.value);
		}
	});
	// [end] Variable filters.
	env.debugOut(reqObj);
	return reqObj;
}

function setNewClientOption(client_id, client_name){

	var mode = $("#add_new_client_mode").val();

	$("#m_project_client_id").append('<option value="' + client_id + '">' + client_name + '</option>');
	$("#m_engineer_client_id").append('<option value="' + client_id + '">' + client_name + '</option>');
	$("#m_operation_update_engineer_client_id").append('<option value="' + client_id + '">' + client_name + '</option>');

	switch(mode){
		case "engineer":
			$('#m_engineer_client_id').val(client_id);
			$('#m_engineer_client_id').select2({allowClear: true});

			break;
		case "project":
			$('#m_project_client_id').val(client_id);
			$('#m_project_client_id').select2();
			break;
        case "operation":
			$('#m_operation_update_engineer_client_id').val(client_id);
			$('#m_operation_update_engineer_client_id').select2({allowClear: true});
			break;
	}

}

function triggerSearch(){
    /*if (unsaved == true) {
        $('#before_action').val('trigger_search');
		$('#modal-confirm-unsaved').modal("show");
		$('#btn-confirm-unsaved')
        return ;
    }*/
	$('#modal-confirm-unsaved').modal("hide");
	updateObject(triggerLeave, null);
	unsaved = false;
    updateObject(c4s.hdlClickSearchBtn,null);
}

function triggerSearchClear(){
    /*if (unsaved == true) {
        $('#before_action').val('trigger_search_clear');
        $('#modal-confirm-unsaved').modal("show");
        return ;
    }*/
	$('#modal-confirm-unsaved').modal("hide");
	updateObject(triggerLeave, null);
	unsaved = false;
    updateObject(c4s.hdlClickGnaviBtn,env.current);
}

function confirmAccountFlgPublic(current_flg_public){
	var flg_public_update = false;
	if(current_flg_public && !env.companyInfo.flg_public) {
		if (confirm("????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????????\n????????????????????????????????????????????????")) {
			flg_public_update = true;
		}
	}
	return flg_public_update;
}

function updateAccountFlgPublic(onSuccessFunc) {

	var reqObj = {};
	reqObj.value = 1;
	reqObj.prefix = env.prefix;
	c4s.invokeApi_ex({
		location: "manage.updateFlgPublic",
		body: reqObj,
		onSuccess: function(data) {
			alert("??????????????????");
			if(onSuccessFunc){
				onSuccessFunc();
			}
		},
	});
}


function overwriteModalForEditEngineer(objId) {

    $("#commitNewEngineerObjMode").val("NormalCreate");

    c4s.clearValidate({
		"client_id": "m_engineer_client_id",
		"client_name": "m_engineer_client_name",
		"name": "m_engineer_name",
		"kana": "m_engineer_kana",
		"visible_name": "m_engineer_visible_name",
		"tel": "m_engineer_tel",
		"mail1": "m_engineer_mail1",
		"mail2": "m_engineer_mail2",
		"birth": "m_engineer_birth",
		"age": "m_engineer_age",
		"gender": "m_engineer_gender_container",
		"state_work": "m_engineer_state_work",
		"fee": "m_engineer_fee",
		"station": "m_engineer_station",
		"skill": "m_engineer_skill",
		"note": "m_engineer_note",
		"charging_user_id": "m_engineer_charging_user_id",
		"employer": "m_engineer_employer",
		"operation_begin": "m_engineer_operation_begin",
        "addr_vip": "m_engineer_addr_vip",
		"addr1": "m_engineer_addr1",
		"addr2": "m_engineer_addr2",

	});
	var textSymbols = [
		["id", "#m_engineer_id"],
		["client_name", "#m_engineer_client_name"],
		["name", "#m_engineer_name"],
		["kana", "#m_engineer_kana"],
		["visible_name", "#m_engineer_visible_name"],
		["tel", "#m_engineer_tel"],
		["mail1", "#m_engineer_mail1"],
		["mail2", "#m_engineer_mail2"],
		["age", "#m_engineer_age"],
		["fee_comma", "#m_engineer_fee"],
		["station", "#m_engineer_station"],
		["note", "#m_engineer_note"],
		["skill", "#m_engineer_skill"],
		["state_work", "#m_engineer_state_work"],
		["employer", "#m_engineer_employer"],
		["operation_begin", "#m_engineer_operation_begin"],
		["station_cd", "#m_engineer_station_cd"],
		["station_pref_cd", "#m_engineer_station_pref_cd"],
		["station_line_cd", "#m_engineer_station_line_cd"],
		["station_lon", "#m_engineer_station_lon"],
		["station_lat", "#m_engineer_station_lat"],
        ["addr_vip", "#m_engineer_addr_vip"],
		["addr1", "#m_engineer_addr1"],
		["addr2", "#m_engineer_addr2"],
	];
	var datepickerSymbols = [
		["birth", "#m_engineer_birth"],
	];
	var checkSymbols = [
		["flg_caution", "#m_engineer_flg_caution"],
		["flg_registered", "#m_engineer_flg_registered"],
		["flg_assignable", "#m_engineer_flg_assignable"],
		["flg_public", "#m_engineer_flg_public"],
		["web_public", "#m_engineer_web_public"],
	];
	var comboSymbols = [
		["contract", "#m_engineer_contract"],
		["client_id", "#m_engineer_client_id"],
	];
	var radioSymbols = [
		["gender", "[name=m_engineer_gender_grp]"],
	];
	c4s.invokeApi("engineer.enumEngineers", {id: Number(objId)}, function (data) {
		env.recentAjaxResult = data;
		if (data && data.status && data.data
			&& data.status.code == 0
			&& data.data instanceof Array && data.data[0]) {
			var i;
			var tmpEl;
			var tgtData = data.data[0];
			for (i = 0; i < textSymbols.length; i++) {
				if (tgtData[textSymbols[i][0]]) {
					$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]];
				} else {
					$(textSymbols[i][1]).val("");
				}
			}
			for (i = 0; i < datepickerSymbols.length; i++) {
				if (tgtData[datepickerSymbols[i][0]]) {
					$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
				} else {
					$(datepickerSymbols[i][1]).val(null);
				}
			}
			for (i = 0; i < checkSymbols.length; i++) {
				$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
			}
			for (i = 0; i < comboSymbols.length; i++) {
				$(comboSymbols[i][1])[0].selectedIndex = 0;
				$(comboSymbols[i][1])[0].value = tgtData[comboSymbols[i][0]];
			}
			for (i = 0; i < radioSymbols.length; i++) {
				$(radioSymbols[i][1]).each(function (idx, el) {
					if (el.value === tgtData[radioSymbols[i][0]]) {
						el.checked = true;
					}
				});
			}
			if (tgtData.charging_user && tgtData.charging_user.id) {
				$("#m_engineer_charging_user_id").val(tgtData.charging_user.id);
			}
			$("input[type=checkbox][id^=m_engineer_skill_]").each(function (idx, el) {
				if (tgtSkillDict[el.id.replace("m_engineer_skill_", "")]) {
					el.checked = true;
				} else {
					el.checked = false;
				}
			});
			$('[name="m_engineer_skill[]"]').each(function (idx, el) {
				el.checked = false;
			});
			$('[name="m_engineer_skill_level[]"]').each(function (idx, el) {
				el.selectedIndex = 0;
			});
			$('[name="m_engineer_skill_level[]"]').addClass("hidden");
			$('[name="m_engineer_occupation[]"]').each(function (idx, el) {
				el.checked = false;
			});

			if(tgtData.skill_id_list){
				$('[name="m_engineer_skill[]"]').each(function (index) {
                    var setval = $(this).val();
                    var skillArr = tgtData.skill_id_list.split(",");
                    if (skillArr.indexOf(setval) >= 0) {
							$(this).val([setval]);
							$('#m_engineer_skill_level_' + setval).removeClass("hidden");
							tgtData.skill_level_list.forEach(function(e, i, a) {
								if(setval == e["skill_id"]){
									$("#m_engineer_skill_level_" + setval).val(e["level"]);
								}
							})
                    }
                });
			}
			viewSelectedEngineerSkill();
			if(tgtData.occupation_id_list){
				$('[name="m_engineer_occupation[]"]').each(function (index) {
                    var setval = $(this).val();
                    var occupationArr = tgtData.occupation_id_list.split(",");
                    if (occupationArr.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
			}
			!tgtData.age ? updateAge() : void(0);
			$("#attachment_id_0").val(tgtData.attachement && tgtData.attachement['id'] ? tgtData.attachement.id : null);
			var fileInputEl = $("#attachment_file_0");
			var fileIdEl = $("#attachment_id_0");
			var labelEl = $("#attachment_label_0");
			var commitBtnEl = $("#attachment_btn_commit_0");
			var deleteBtnEl = $("#attachment_btn_delete_0");
			if (tgtData.attachement) {
				var atmtObj = tgtData.attachement;
				fileInputEl.val(null);
				fileIdEl.val(atmtObj.id);
				fileInputEl.css("display", "none");
				labelEl.html(atmtObj.name + "&nbsp;(<span class='mono'>" + atmtObj.size + "bytes</span>)");
				labelEl.css("display", "inline");
				commitBtnEl.css("display", "inline");
				deleteBtnEl.css("display", "inline");
			} else {
				fileInputEl.val(null);
				fileInputEl.css("display", "inline");
				fileIdEl.val(null);
				labelEl.html("");
				labelEl.css("display", "none");
				commitBtnEl.css("display", "none");
				deleteBtnEl.css("display", "none");
			}
			if (tgtData.dt_created) {
				$("#m_engineer_dt_created").text(tgtData.dt_created.substr(0, 10));
				$("#m_engineer_dt_created").parent().css("display", "block");
			}
			if(tgtData.station_pref_cd && tgtData.station_line_cd && tgtData.station_cd){
				$("#es").val(tgtData.station_pref_cd);
				setEngineerMenuItem(0, tgtData.station_pref_cd, tgtData.station_line_cd, tgtData.station_cd);
				setEngineerMenuItem(1, tgtData.station_line_cd, tgtData.station_line_cd, tgtData.station_cd);
			}
			$("#edit_engineer_modal_title").replaceWith($("<span id='edit_engineer_modal_title'>????????????</span>"));
			$("#edit_engineer_modal").modal("show");
			$('#m_engineer_client_id').select2({allowClear: true});
		}
	});
}

function triggerUpdateEngineerObj(){
    updateObject(updateEngineerObj,null);
}
function updateEngineerObj () {
	var oldObj = env.recentAjaxResult.data[0];
	var newObj = genCommitValueOfEngineer();
	var reqObj = {};
	var i;
	for (i in newObj) {
		if (oldObj[i] !== undefined && newObj[i] != oldObj[i]) {
			reqObj[i] = newObj[i];
		}
	}
	if (newObj.charging_user_id) {
		reqObj.charging_user_id = newObj.charging_user_id;
	}
	reqObj.id = Number($("#m_engineer_id").val());

	if(newObj.skill_id_list){
		reqObj.skill_id_list = newObj.skill_id_list;
		reqObj.skill_level_list = newObj.skill_level_list;
	}
	if(newObj.occupation_id_list){
		reqObj.occupation_id_list = newObj.occupation_id_list;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.engineer,
		{
			"client_id": "m_engineer_client_id",
			"client_name": "m_engineer_client_name",
			"name": "m_engineer_name",
			"kana": "m_engineer_kana",
			"visible_name": "m_engineer_visible_name",
			"tel": "m_engineer_tel",
			"mail1": "m_engineer_mail1",
			"mail2": "m_engineer_mail2",
			"birth": "m_engineer_birth",
			"age": "m_engineer_age",
			"gender": "m_engineer_gender_container",
			"state_work": "m_engineer_state_work",
			"fee": "m_engineer_fee",
			"station": "m_engineer_station",
			"skill": "m_engineer_skill",
			"note": "m_engineer_note",
			"employer": "m_engineer_employer",
			"operation_begin": "m_engineer_operation_begin",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return;
	}
	c4s.invokeApi_ex({
		location: "engineer.updateEngineer",
		body: reqObj,
		onSuccess: function(data) {
			alert("1????????????????????????");
			var flg_public_update = confirmAccountFlgPublic(reqObj.flg_public);
			var onSuccessFunc = function () {
				$("#edit_engineer_modal").data("commitCompleted", true);
				$("#edit_engineer_modal").modal("hide");
				c4s.hdlClickSearchBtn();
			}
			if(flg_public_update){
				updateAccountFlgPublic(onSuccessFunc);
			}else{
				onSuccessFunc();
			}
		},
		onError: function(data) {
			alert("?????????????????????????????????" + data.status.description + "???")
		},
	});
}

function overwriteModalForEditProject(objId) {
	c4s.clearValidate({
		"id": "m_project_id",
		"client_id": "m_project_client_id",
		"client_name": "m_project_client_name",
		"title": "m_project_title",
		"term": "m_project_term",
		"term_begin": "m_project_term_begin",
		"term_end": "m_project_term_end",
		"age_from": "m_project_age_from",
		"age_to": "m_project_age_to",
		"fee_inbound": "m_project_fee_inbound",
		"fee_outbound": "m_project_fee_outbound",
		"expense": "m_project_expense",
		"process": "m_project_process",
		"interview": "m_project_interview_container",
		"station": "m_project_station_container",
		"scheme": "m_project_scheme_container",
		"skill_needs": "m_project_skill_needs",
		"skill_recommends": "m_project_skill_recommends",
		"rank_id": "m_project_rank_container",
	});
	var textSymbols = [
		["id", "#m_project_id"],
		["client_name", "#m_project_client_name"],
		["fee_inbound_comma", "#m_project_fee_inbound"],
		["fee_outbound_comma", "#m_project_fee_outbound"],
		["expense", "#m_project_expense"],
		["title", "#m_project_title"],
		["process", "#m_project_process"],
		["interview", "#m_project_interview"],
		["station", "#m_project_station"],
		["note", "#m_project_note"],
		["term", "#m_project_term"],
		["term_begin", "#m_project_term_begin"],
		["term_end", "#m_project_term_end"],
		["age_from", "#m_project_age_from"],
		["age_to", "#m_project_age_to"],
		["skill_needs", "#m_project_skill_needs"],
		["skill_recommends", "#m_project_skill_recommends"],
		["station_cd", "#m_project_station_cd"],
		["station_pref_cd", "#m_project_station_pref_cd"],
		["station_line_cd", "#m_project_station_line_cd"],
		["station_lon", "#m_project_station_lon"],
		["station_lat", "#m_project_station_lat"],
	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["flg_shared", "#m_project_flg_shared"],
		["flg_public", "#m_project_flg_public"],
		["web_public", "#m_project_web_public"],
	];
	var comboSymbols = [
		["scheme", "#m_project_scheme"],
		["charging_user_id", "#m_project_charging_user_id"],
	];
	var radioSymbols = [
		["rank_id", "[name=m_project_rank_grp]"],
	];
	c4s.invokeApi("project.enumProjects", {id: Number(objId)}, function (data) {
		env.recentAjaxResult = data;
		if (data && data.status && data.data
			&& data.status.code == 0
			&& data.data instanceof Array && data.data[0]) {
			var i;
			var tmpEl;
			var tgtData = data.data[0];
			tgtData.client_id = tgtData.client && tgtData.client.id || null;
			tgtData.charging_user_id = tgtData.charging_user.id;
			for (i = 0; i < textSymbols.length; i++) {
				$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
			}
			for (i = 0; i < datepickerSymbols.length; i++) {
				if (tgtData[datepickerSymbols[i][0]]) {
					$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
				} else {
					$(datepickerSymbols[i][1]).val(null);
				}
			}
			for (i = 0; i < checkSymbols.length; i++) {
				$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
			}
			for (i = 0; i < comboSymbols.length; i++) {
				$(comboSymbols[i][1])[0].selectedIndex = 0;
				$(comboSymbols[i][1] + " option").each(function (idx, el) {
					if (String(tgtData[comboSymbols[i][0]]) == el.value) {
						el.selected = true;
					}
				});
			}

			for (i = 0; i < radioSymbols.length; i++) {
				$(radioSymbols[i][1]).each(function (idx, el) {
					if (el.value == tgtData[radioSymbols[i][0]]) {
						el.checked = true;
					}
				});
			}
			if (tgtData.client_id) {
				$("#m_project_client_id").val(tgtData.client_id);
				$("#m_project_client_name").val(tgtData.client.name);
			}
			if (tgtData.dt_created) {
				$("#m_project_dt_created").text(tgtData.dt_created.substr(0, 10));
				$("#m_project_dt_created").parent().css("display", "block");
			}
			$('[name="m_project_skill[]"]').each(function (idx, el) {
				el.checked = false;
			});
            $('[name="m_project_skill_level[]"]').each(function (idx, el) {
				el.selectedIndex = 0;
			});
			$('[name="m_project_skill_level[]"]').addClass("hidden");
			$('[name="m_project_occupation[]"]').each(function (idx, el) {
				el.checked = false;
			});
			if(tgtData.skill_id_list){
				$('[name="m_project_skill[]"]').each(function (index) {
                    var setval = $(this).val();
                    var skillArr = tgtData.skill_id_list.split(",");
                    if (skillArr.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                        $('#m_project_skill_level_' + setval).removeClass("hidden");
                        tgtData.skill_level_list.forEach(function(e, i, a) {
                            if(setval == e["skill_id"]){
                                $("#m_project_skill_level_" + setval).val(e["level"]);
                            }
                        })
                    }
                });
			}
			viewSelectedProjectSkill();
			if(tgtData.occupation_id_list){
				$('[name="m_project_occupation[]"]').each(function (index) {
                    var setval = $(this).val();
                    var occupationArr = tgtData.occupation_id_list.split(",");
                    if (occupationArr.indexOf(setval) >= 0) {
                        $(this).val([setval]);
                    }
                });
			}
			if(tgtData.station_pref_cd && tgtData.station_line_cd && tgtData.station_cd){
				$("#ps").val(tgtData.station_pref_cd);
				setProjectMenuItem(0, tgtData.station_pref_cd, tgtData.station_line_cd, tgtData.station_cd);
				setProjectMenuItem(1, tgtData.station_line_cd, tgtData.station_line_cd, tgtData.station_cd);
			}
			$("#m_project_worker_container").removeClass("hidden");
			$("#edit_project_modal_title").html("????????????");
			$("#edit_project_modal").modal("show");
			// getRelatedEngineer(tgtData.id);
			$('#m_project_client_id').select2();
		}
	});
}

function overwriteClientModalForEdit(objId) {
	c4s.clearValidate({
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	$("#m_client_addr1_alert").html("");
	// objId is client id.
	var textSymbols = [
		["id", "#m_client_id"],
		["name", "#m_client_name"],
		["kana", "#m_client_kana"],
		["addr_vip", "#m_client_addr_vip"],
		["addr1", "#m_client_addr1"],
		["addr2", "#m_client_addr2"],
		["tel", "#m_client_tel"],
		["fax", "#m_client_fax"],
		["site", "#m_client_site"],
		["note", "#m_client_note"],
	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["type_presentation_0", "#m_client_type_presentation_0"],
		["type_presentation_1", "#m_client_type_presentation_1"],
	];
	var comboSymbols = [
		["type_dealing", "#m_client_type_dealing"],
		["charging_worker_1_id", "#m_client_charging_worker1"],
		["charging_worker_2_id", "#m_client_charging_worker2"],
	];
	var radioSymbols = [];
	c4s.invokeApi("client.enumClients", {id: Number(objId)}, function (data) {
		// [begin] Enable table containers.
		$("#m_client_branch_container").css("display", "inline");
		$("#m_client_worker_container").css("display", "inline");
		// [end] Enable table containers.
		env.recentAjaxResult = data;
		if (data && data.status && data.data
			&& data.status.code == 0
			&& data.data instanceof Array && data.data[0]) {
			var i;
			var tmpEl;
			var tgtData = data.data[0];
			tgtData.site = (tgtData.site == "" || tgtData.site == "null" || !tgtData.site) ? "" : tgtData.site;
			tgtData.type_presentation_0 = tgtData.type_presentation && tgtData.type_presentation.join("").indexOf("??????") > -1 ? true : false;
			tgtData.type_presentation_1 = tgtData.type_presentation && tgtData.type_presentation.join("").indexOf("??????") > -1 ? true : false;
			tgtData.charging_worker_1_id = tgtData.charging_worker1 ? tgtData.charging_worker1.id : null;
			tgtData.charging_worker_2_id = tgtData.charging_worker2 ? tgtData.charging_worker2.id : null;
			for (i = 0; i < textSymbols.length; i++) {
				$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
			}
			for (i = 0; i < datepickerSymbols.length; i++) {
				$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
			}
			for (i = 0; i < checkSymbols.length; i++) {
				$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
			}
			for (i = 0; i < comboSymbols.length; i++) {
				$(comboSymbols[i][1])[0].selectedIndex = 0;
				$(comboSymbols[i][1] + " option").each(function (idx, el) {
					if (String(tgtData[comboSymbols[i][0]]) == el.value) {
						el.selected = true;
					}
				});
			}

			for (i = 0; i < radioSymbols.length; i++) {
				$(radioSymbols[i][1]).each(function (idx, el) {
					if (el.value === tgtData[radioSymbols[i][0]]) {
						el.checked = true;
					}
				});
			}
			// [begin] Fetch branches.
			c4s.invokeApi_ex({
				location: "client.enumBranches",
				body: {client_id: objId},
				onSuccess: function(codata) {
					$("#m_client_branch_table tbody tr").remove();
					if (codata && codata.data && codata.data instanceof Array && codata.data.length > 0) {
						var i;
						for (i = 0; i < codata.data.length; i++) {
							var tmpTr = $("<tr></tr>");
							tmpTr.appendTo("#m_client_branch_table tbody");
							// ??????
							$("<td class='center'><span class='glyphicon glyphicon-pencil text-success pseudo-link-cursor' title='??????' onclick='overwriteBranchModalForEdit(" + objId + ", " + codata.data[i].id + ");'></span></td>").appendTo(tmpTr);
							// ?????????
							$("<td></td>").text(codata.data[i].name).appendTo(tmpTr);
							// ??????
							$("<td></td>").text("???" + codata.data[i].addr_vip + " " + codata.data[i].addr1 + " " + codata.data[i].addr2).appendTo(tmpTr);
							// Map
							if (env.limit.LMT_ACT_MAP) {
								if ((env.limit.LMT_CALL_MAP_EXTERN_M > env.mapLimit) || (env.limit.LMT_CALL_MAP_EXTERN_M == 0)) {
									var mapData = {
										target_id: codata.data[i].id,
										target_type: 'branch',
										name: codata.data[i].name,
										addr1: codata.data[i].addr1,
										addr2: codata.data[i].addr2,
										tel: codata.data[i].tel,
										modalId: 'edit_client_modal',
										isFloodLMT: false,
										current: env.current
									};
									for (var key in mapData){
										mapData[key] = typeof(mapData[key]) === "string" ? mapData[key].replace('"',"") : mapData[key];
									}
									var tmpTd = $("<td></td>").attr("class","center").css("width","35px");
									var tmpSpan = $("<span></span>").attr("class","glyphicon glyphicon-globe text-success pseudo-link-cursor").bind("click", function (option) { return function () { c4s.openMap(option); }; }(mapData));
									tmpSpan.appendTo(tmpTd);
									tmpTd.appendTo(tmpTr);
								} else {
									var tmpTd = $("<td></td>").attr("class","center").css("width","35px");
									var tmpSpan = $("<span></span>").attr("class","glyphicon glyphicon-globe text-muted pseudo-link-cursor").bind("click", function () { return function () { c4s.openMap({isFloodLMT: true}); }; }());
									tmpSpan.appendTo(tmpTd);
									tmpTd.appendTo(tmpTr);
								}
							}
							// ????????????/FAX??????
							$("<td class='center'>" +
								(
									codata.data[i].tel && codata.data[i].tel !== "" ? ("<span class='glyphicon glyphicon-phone-alt'></span>&nbsp;<a href='tel:" + codata.data[i].tel.replace(/-/g, "") + "'>" + codata.data[i].tel + "</a>") : ""
								) +
								(
									codata.data[i].fax && codata.data[i].fax !== "" ? ("<br/><span class='glyphicon glyphicon-print'></span>&nbsp;" + codata.data[i].fax) : ""
								) +
								"</td>").appendTo(tmpTr);
						}
					} else {
						$("#m_client_branch_container")[0].style.display = "none";
					}
				},
			});
			// [end] Fetch branches.
			// [begin] Fetch workers.
			$("#m_client_worker_table tbody tr").remove();
			$("#m_client_worker_container")[0].style.display = "none";
			c4s.invokeApi_ex({
				location: "client.enumWorkers",
				body: {client_id: objId},
				onSuccess: function(codata) {
					if (codata && codata.data && codata.data instanceof Array && codata.data.length > 0) {
						var i;
						for (i = 0; i < codata.data.length; i++) {
							var tmpTr = $("<tr id='iter_worker_sm_" + codata.data[i].id + "'/>");
							tmpTr.appendTo("#m_client_worker_table tbody");
							// ????????????????????????
							if ((codata.data[i].mail1 || codata.data[i].mail2) && codata.data[i].flg_sendmail) {
								$("<td class='center'><input type='checkbox' id='iter_mailto_worker_" + codata.data[i].id + "'/></td>").appendTo(tmpTr);
							} else {
								$("<td></td>").appendTo(tmpTr);
							}
							// ????????????
							$("<td><img src='/img/icon/key_man.jpg' title='????????????'" +
								(
									codata.data[i].flg_keyperson ? "" : " style='visibility: hidden;'"
								) + "/>&nbsp;<span class='pseudo-link' onclick='overwriteWorkerModalForEdit(" + codata.data[i].id + ");'>" +
								codata.data[i].name + "</span></td>").appendTo(tmpTr);
							// ????????????
							$("<td class='center'>" +
								(
									codata.data[i].tel && codata.data[i].tel !== "" ? ("<a href='tel:" + codata.data[i].tel.replace(/-/g, "") + "'>" + codata.data[i].tel + "</a>") : ""
								) +
								"</td>").appendTo(tmpTr);
							// ?????????????????????
							$("<td class=''>" +
								(
									codata.data[i].mail1 ? (
										env.limit.LMT_ACT_MAIL ? ("&nbsp;<span onclick='triggerMailOnClientModal([" + codata.data[i].id + "]);'><span class='glyphicon glyphicon-envelope text-warning pseudo-link-cursor'></span>&nbsp;<span class='pseudo-link'>" + codata.data[i].mail1 + "</span></span>") : ("&nbsp;" + codata.data[i].mail1)
									) : ""
								) +
								"</td>").appendTo(tmpTr);
							// ??????????????????
							// if (codata.data[i].charging_user.login_id && codata.data[i].charging_user.user_name) {
							// 	$("<td class='center'><span class='pseudo-link-cursor' title='" + codata.data[i].charging_user.login_id + "'>" + codata.data[i].charging_user.user_name + "</span></td>").appendTo(tmpTr);
							// } else {
							// 	$("<td></td>").appendTo(tmpTr);
							// }
							// ???????????????
							$("<td class='center'><span class='glyphicon glyphicon-trash text-danger pseudo-link-cursor' title='??????' onclick='c4s.hdlClickDeleteItem(\"worker_sm\", " + codata.data[i].id + ", true);'></span></td>").appendTo(tmpTr);
						}
						$("#m_client_worker_container")[0].style.display = "block";
					} else {
						$("#m_client_worker_container")[0].style.display = "none";
					}
				},
			});
			// [end] Fetch workers.
			$("#edit_client_modal_title").replaceWith($("<span id='edit_client_modal_title'>???????????????</span>"));
			$("#edit_client_modal").modal("show");
		}
	});
}

function genCommitValueOfClient () {
	var reqObj = {};
	var textSymbols = [
		["#m_client_id", Number],
		["#m_client_name", String, ""],
		["#m_client_kana", String, ""],
		["#m_client_addr_vip", String, ""],
		["#m_client_addr1", String, ""],
		["#m_client_addr2", String, ""],
		["#m_client_tel", String, ""],
		["#m_client_fax", String, ""],
		["#m_client_site", String, ""],
		["#m_client_note", String, ""],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [
		["#m_client_type_dealing", String],
		["#m_client_charging_worker1", Number],
		["#m_client_charging_worker2", Number],
	];
	var radioSymbols = [];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		if (tmpEl.val()) {
			reqObj[tmpEl.attr("id").replace("m_client_", "")] = textSymbols[i][1](tmpEl.val());
		} else if (tmpEl.val() === "" && textSymbols[i].length == 3) {
			reqObj[tmpEl.attr("id").replace("m_client_", "")] = textSymbols[i][1](textSymbols[i][2]);
		}
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("m_client_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_client_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_client_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_client_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	// [begin] Variable filters.
	reqObj.charging_worker1 = reqObj.charging_worker1 || null;
	reqObj.charging_worker2 = reqObj.charging_worker2 || null;
	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}
	reqObj.type_presentation = [];
	$("[id^=m_client_type_presentation_]").each(function (idx, el) {
		if (el.checked) {
			reqObj.type_presentation.push(el.value);
		}
	});
	// [end] Variable filters.
	env.debugOut(reqObj);
	return reqObj;
}

function triggerCommitClient(){
    updateObject(commitClient, null);
}

function commitClient(updateFlg) {
	var reqObj = genCommitValueOfClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return false;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "client.updateClient" : "client.createClient",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1????????????????????????" : "1????????????????????????");
			var tmpBody = {};
			var i;
			for(i in env.recentQuery) {
				if (i !== "id") {
					tmpBody[i] = env.recentQuery[i];
				}
			}
			$("#edit_client_modal").data("commitCompleted", true);
			$("#edit_client_modal").modal("hide");
			c4s.hdlClickSearchBtn();
		},
		onError: function (data) {
			alert(updateFlg ? "??????????????????????????????" : "??????????????????????????????");
		}
	});
}

function hdlClickAddWorkerBtn(workerId) {
	var reqObj = genCommitValueOfClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip_container",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return false;
	}
	c4s.invokeApi_ex({
		location: workerId ? "client.updateClient" : "client.createClient",
		body: reqObj,
		onSuccess: function (res) {
			$("#ms_client_id").val(res.data.id);
			$("#ms_worker_id").val(workerId);
			overwriteWorkerModalForEdit();
		},
	});
}

function hdlClickAddBranchBtn(updateFlg) {
	var reqObj = genCommitValueOfClient();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.client,
		{
			"name": "m_client_name",
			"kana": "m_client_kana",
			"addr_vip": "m_client_addr_vip_container",
			"addr1": "m_client_addr1",
			"addr2": "m_client_addr2",
			"tel": "m_client_tel",
			"fax": "m_client_fax",
			"site": "m_client_site",
			"type_presentation": "m_client_type_presentation_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return false;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "client.updateClient" : "client.createClient",
		body: reqObj,
		onSuccess: function (res) {
			$("#m_client_id").val(res.data.id);
			overwriteBranchModalForEdit(res.data.id);
		},
	});
}

function hdlClickAddMoreWorkerBtn(workerId) {
	var reqObj = genCommitValueOfWorker();
	if (!workerId) {
		delete reqObj.id;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.worker,
		{
			"id": "ms_worker_id",
			"client_id": "ms_worker_client_id",
			"name": "ms_worker_name",
			"kana": "ms_worker_kana",
			"section": "ms_worker_section",
			"title": "ms_worker_title",
			"tel": "ms_worker_tel",
			"tel2": "ms_worker_tel2",
			"mail1": "ms_worker_mail1",
			"mail2": "ms_worker_mail2",
			"flg_keyperson": "ms_worker_misc_container",
			"flg_sendmail": "ms_worker_misc_container",
			"recipient_priority": "ms_worker_misc_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return;
	}
	if (workerId) {
		c4s.invokeApi_ex({
			location: "client.updateWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1?????????????????????");
				overwriteClientModalForEdit(reqObj.client_id);
				overwriteWorkerModalForEdit();
			},
			onError: function (data) {
				alert("???????????????????????????");
			},
		});
	} else {
		c4s.invokeApi_ex({
			location: "client.createWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1?????????????????????");
				overwriteClientModalForEdit(reqObj.client_id);
				overwriteWorkerModalForEdit();
			},
			onError: function (data) {
				alert("???????????????????????????");
			},
		});
	}
}

function overwriteBranchModalForEdit(clientId, branchId) {
	c4s.clearValidate({
		"id": "m_branch_id",
		"client_id": "m_branch_client_id",
		"name": "m_branch_name",
		"addr_vip": "m_branch_addr_vip",
		"addr1": "m_branch_addr1",
		"addr2": "m_branch_addr2",
		"tel": "m_branch_tel",
		"fax": "m_branch_fax",
	});
	var textSymbols = [
		["id", "#m_branch_id"],
		["client_id", "#m_branch_client_id"],
		["client_name", "#m_branch_client_name"],
		["name", "#m_branch_name"],
		["addr_vip", "#m_branch_addr_vip"],
		["addr1", "#m_branch_addr1"],
		["addr2", "#m_branch_addr2"],
		["tel", "#m_branch_tel"],
		["fax", "#m_branch_fax"],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [

	];
	var radioSymbols = [];
	var tgtData;
	var i;
	if (branchId) {
		c4s.invokeApi_ex({
			location: "client.enumBranches",
			body: {client_id: clientId},
			onSuccess: function (data) {
				if (data && data.data && data.data instanceof Array && data.data.length > 0) {
					var tgtData = data.data.filter(function (val, idx, arr){ return val.id == branchId; })[0];
					for (i = 0; i < textSymbols.length; i++) {
						$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
					}
					for (i = 0; i < datepickerSymbols.length; i++) {
						$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
					}
					for (i = 0; i < checkSymbols.length; i++) {
						$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
					}
					for (i = 0; i < comboSymbols.length; i++) {
						$(comboSymbols[i][1] + " option").each(function (idx, el) {
							if (String(tgtData[comboSymbols[i][0]]) == el.value) {
								el.selected = true;
							}
						});
					}

					for (i = 0; i < radioSymbols.length; i++) {
						$(radioSymbols[i][1]).each(function (idx, el) {
							if (el.value === tgtData[radioSymbols[i][0]]) {
								el.checked = true;
							}
						});
					}
					$("#edit_branch_modal_title").replaceWith($("<span id='edit_branch_modal_title'>?????????????????????</span>"));
					$("#edit_branch_modal").modal("show");
				}
			},
		});
	} else {
		var i;
		tgtData = {
			client_id: clientId,
			client_name: $("#m_client_name").val(),
		};
		for (i = 0; i < textSymbols.length; i++) {
			$(textSymbols[i][1])[0].value = tgtData[textSymbols[i][0]] || "";
		}
		for (i = 0; i < datepickerSymbols.length; i++) {
			$(datepickerSymbols[i][1]).datepicker("setValue", tgtData[datepickerSymbols[i][0]]);
		}
		for (i = 0; i < checkSymbols.length; i++) {
			$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
		}
		for (i = 0; i < comboSymbols.length; i++) {
			$(comboSymbols[i][1] + " option").each(function (idx, el) {
				if (String(tgtData[comboSymbols[i][0]]) == el.value) {
					el.selected = true;
				}
			});
		}

		for (i = 0; i < radioSymbols.length; i++) {
			$(radioSymbols[i][1]).each(function (idx, el) {
				if (el.value === tgtData[radioSymbols[i][0]]) {
					el.checked = true;
				}
			});
		}
		$("#m_branch_addr1_alert").html("");
		$("#m_branch_client_id").val($("#m_client_id").val());
		$("#edit_branch_modal_title").replaceWith($("<span id='edit_branch_modal_title'>???????????????????????????</span>"));
		$("#edit_branch_modal").modal("show");
	}
}

function genCommitValueOfBranch () {
	var reqObj = {};
	var textSymbols = [
		["#m_branch_id", Number],
		["#m_branch_client_id", Number],
		["#m_branch_name", String],
		["#m_branch_addr_vip", String],
		["#m_branch_addr1", String],
		["#m_branch_addr2", String, ""],
		["#m_branch_tel", String, ""],
		["#m_branch_fax", String, ""],
	];
	var datepickerSymbols = [];
	var checkSymbols = [];
	var comboSymbols = [];
	var radioSymbols = [];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_branch_", "")] = textSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < datepickerSymbols.length; i++) {
		tmpEl = $(datepickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("m_branch_", "")] = datepickerSymbols[i][1](tmpEl.val());
		}
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_branch_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_branch_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_branch_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}
	// [begin] Variable filters.
	if (reqObj.addr_vip) {
		reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	}
	// [end] Variable filters.
	env.debugOut(reqObj);
	return reqObj;
}

function triggerCommitBranch(updateFlg){
    updateObject(commitBranch, updateFlg);
}
function commitBranch(updateFlg) {
	var reqObj = genCommitValueOfBranch();
	if (updateFlg !== true) {
	    updateFlg = false;
		delete reqObj.id;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.branch,
		{
			"id": "m_branch_id",
			"client_id": "m_branch_client_id",
			"name": "m_branch_name",
			"addr_vip": "m_branch_addr_vip",
			"addr1": "m_branch_addr1",
			"addr2": "m_branch_addr2",
			"tel": "m_branch_tel",
			"fax": "m_branch_fax",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return;
	}
	c4s.invokeApi_ex({
		location: updateFlg ? "client.updateBranch" : "client.createBranch",
		body: reqObj,
		onSuccess: function (data) {
			alert(updateFlg ? "1????????????????????????" : "1????????????????????????");
			// $("#edit_client_modal").data("commitCompleted", true);
			$("#edit_branch_modal").modal("hide");
			// $("#edit_client_modal").modal("hide");
			overwriteClientModalForEdit(reqObj.client_id);
		},
		onError: function (data) {
			alert(updateFlg ? "??????????????????????????????" : "??????????????????????????????");
		}
	});
}

function overwriteWorkerModalForEdit(workerId) {
	workerId = Number(workerId);
	c4s.clearValidate({
			"id": "ms_worker_id",
			"client_id": "ms_worker_client_id",
			"name": "ms_worker_name",
			"kana": "ms_worker_kana",
			"section": "ms_worker_section",
			"title": "ms_worker_title",
			"tel": "ms_worker_tel",
			"tel2": "ms_worker_tel2",
			"mail1": "ms_worker_mail1",
			"mail2": "ms_worker_mail2",
			"flg_keyperson": "ms_worker_misc_container",
			"flg_sendmail": "ms_worker_misc_container",
			"recipient_priority": "ms_worker_misc_container",
		});
	// objId is client id.
	var textSymbols = [
		["id", "#ms_worker_id"],
		["name", "#ms_worker_name"],
		["kana", "#ms_worker_kana"],
		["client_name", "#ms_worker_client_name"],
		["client_id", "#ms_worker_client_id"],
		["section", "#ms_worker_section"],
		["title", "#ms_worker_title"],
		["tel", "#ms_worker_tel"],
		["tel2", "#ms_worker_tel2"],
		["mail1", "#ms_worker_mail1"],
		["mail2", "#ms_worker_mail2"],
		["note", "#ms_worker_note"],
		["recipient_priority", "#ms_worker_recipient_priority", 5],
	];
	var datepickerSymbols = [];
	var checkSymbols = [
		["flg_keyperson", "#ms_worker_flg_keyperson", false],
		["flg_sendmail", "#ms_worker_flg_sendmail", true],
	];
	var comboSymbols = [];
	var radioSymbols = [];
	var i;
	var tgtData;
	$("#ms_worker_id").val(workerId);
	if (workerId) {
		c4s.invokeApi_ex({
			location: "client.enumWorkers",
			body: {id: workerId},
			onSuccess: function (res) {
				tgtData = res.data[0];
				for (i = 0; i < textSymbols.length; i++) {
					$(textSymbols[i][1]).val(tgtData[textSymbols[i][0]]);
				}
				for (i = 0; i < checkSymbols.length; i++) {
					$(checkSymbols[i][1])[0].checked = tgtData[checkSymbols[i][0]];
				}
				$("#ms_client_id").val(tgtData.client_id);
				$("#ms_worker_client_name").val(tgtData.client_name);
/*
				//?????????[106]
                if($("#m_client_tel").val() == ""){
                        var i,cid = Number($("#m_client_id").val());
                        for(i = 0; i < env.data.clients.length; i++){
                                if(env.data.clients[i]['id']  == cid){
                                        $("#ms_worker_tel2").val(env.data.clients[i]['tel']);
                                        break;
                                }
                        }
                }else{
                        $("#ms_worker_tel2").val($("#m_client_tel").val());
                }
*/
				$("#ms_worker_id").val(tgtData.id);
				$("#ms_worker_recipient_priority").val(tgtData.recipient_priority);
				$("#edit_worker_modal_title").replaceWith($("<span id='edit_worker_modal_title'>????????????????????????</span>"));
				$("#edit_worker_modal").modal("show");
			},
		});
	} else {
		for (i = 0; i < textSymbols.length; i++) {
			$(textSymbols[i][1]).val("");
		}
		for (i = 0; i < checkSymbols.length; i++) {
			$(checkSymbols[i][1])[0].checked = checkSymbols[i][2];
		}
		for (i = 0; i < comboSymbols.length; i++) {
			$(comboSymbols[i][1] + " option").each(function (idx, el) {
				if (el.value === env.login_id) {
					el.selected = true;
				} else {
					el.selected = false;
				}
			});
		}
		$("#ms_worker_client_id").val($("#m_client_id").val());
		$("#ms_client_id").val(null);
		$("#ms_worker_client_name").val($("#m_client_name").val());
		/*
		//?????????
		$("ms_worker_tel2").val(tgtData.tel);
		*/
		$("#ms_worker_tel2").val($("#ms_worker_tel2").val() || $("#m_client_tel").val());
		$("#ms_worker_recipient_priority").val(5);
		$("#edit_worker_modal_title").replaceWith($("<span id='edit_worker_modal_title'>????????????????????????</span>"));
		$("#edit_worker_modal").modal("show");
	}
}

function genCommitValueOfWorker () {
	var reqObj = {};
	var textSymbols = [
		["id", "#ms_worker_id", Number, null],
		["name", "#ms_worker_name", String],
		["kana", "#ms_worker_kana", String],
		["section", "#ms_worker_section", String, ""],
		["title", "#ms_worker_title", String, ""],
		["tel", "#ms_worker_tel", String, ""],
		["tel2", "#ms_worker_tel2", String, ""],
		["mail1", "#ms_worker_mail1", String, ""],
		["mail2", "#ms_worker_mail2", String, ""],
		["note", "#ms_worker_note", String],
		["client_id", "#ms_worker_client_id", Number],
		["recipient_priority", "#ms_worker_recipient_priority", Number, 5],
	];
	var checkSymbols = [
		["flg_keyperson", "#ms_worker_flg_keyperson", false],
		["flg_sendmail", "#ms_worker_flg_sendmail", true],
	];
	var i;
	var tgtVal;
	for (i = 0; i < textSymbols.length; i++) {
		tgtVal = $(textSymbols[i][1]).val();
		reqObj[textSymbols[i][0]] = textSymbols[i][2](tgtVal);
	}
	for (i = 0; i < checkSymbols.length; i++) {
		tgtVal = $(checkSymbols[i][1])[0].checked;
		reqObj[checkSymbols[i][0]] = tgtVal;
	}
	return reqObj;
}

function triggerCommitWorkerObj(workerId){
    updateObject(commitWorkerObj, workerId);
}

function commitWorkerObj (workerId) {
	var reqObj = genCommitValueOfWorker();
	if (isNaN(workerId)) {
		delete reqObj.id;
		workerId = null;
	}
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.worker,
		{
			"id": "ms_worker_id",
			"client_id": "ms_worker_client_id",
			"name": "ms_worker_name",
			"kana": "ms_worker_kana",
			"section": "ms_worker_section",
			"title": "ms_worker_title",
			"tel": "ms_worker_tel",
			"tel2": "ms_worker_tel2",
			"mail1": "ms_worker_mail1",
			"mail2": "ms_worker_mail2",
			"flg_keyperson": "ms_worker_misc_container",
			"flg_sendmail": "ms_worker_misc_container",
			"recipient_priority": "ms_worker_misc_container",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return;
	}
	if (workerId) {
		c4s.invokeApi_ex({
			location: "client.updateWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1?????????????????????");
				$("#edit_client_modal").data("commitCompleted", true);
				$("#edit_worker_modal").modal("hide");
				overwriteClientModalForEdit(reqObj.client_id);
			},
			onError: function (data) {
				alert("???????????????????????????");
			},
		});
	} else {
		c4s.invokeApi_ex({
			location: "client.createWorker",
			body: reqObj,
			onSuccess: function (data) {
				alert("1?????????????????????");
				$("#edit_client_modal").data("commitCompleted", true);
				$("#edit_worker_modal").modal("hide");
				overwriteClientModalForEdit(reqObj.client_id);
			},
			onError: function (data) {
				alert("???????????????????????????");
			},
		});
	}
}

function triggerMailOnClientModal(workerIdArr) {
    updateObject(sendMailOnClientModal, workerIdArr);
}

function sendMailOnClientModal(workerIdArr) {
	//[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.
	var reqObj = {};
	reqObj.type_recipient = "forWorker";
	reqObj.recipients = {engineers: [], workers: []};
	if (workerIdArr) {
		reqObj.recipients.workers = workerIdArr;
	} else {
		$("[id^=iter_mailto_worker_]").each(function (idx, el, arr) {
			if (el.checked) {
				reqObj.recipients.workers.push(Number(el.id.replace("iter_mailto_worker_", "")));
			}
		});
	}
	if (reqObj.recipients.workers.length == 0) {
		alert("?????????????????????????????????????????????");
	} else {
		c4s.invokeApi_ex({
			location: "mail.createMail",
			body: reqObj,
			pageMove: true,
			newPage: true,
		});
		// $("#edit_client_modal").modal("hide");
	}
}

function hdlClickNewOperationObj () {
    /*if (unsaved == true) {
        $('#before_action').val('new_operation');
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");

    $("#m_operation_project").val("");
    $("#m_operation_engineer").val("");

	c4s.clearValidate({
        "term_begin": "m_operation_term_begin",
        "term_end": "m_operation_term_end",
        "term_memo": "m_operation_term_memo",
        "transfer_member": "m_operation_transfer_member",
        "contract_date": "m_operation_contract_date",
        "demand_site": "m_operation_demand_site",
        "payment_site": "m_operation_payment_site",
		"other_memo": "m_operation_other_memo",
        "base_exc_tax": "base_exc_tax_0",
        "demand_wage_per_hour": "demand_wage_per_hour_0",
        "demand_working_time": "demand_working_time_0",
        "settlement_from": "settlement_from_0",
        "settlement_to": "settlement_to_0",
        "deduction": "deduction_0",
        "excess": "excess_0",
        "payment_base": "payment_base_0",
        "payment_wage_per_hour": "payment_wage_per_hour_0",
        "payment_working_time": "payment_working_time_0",
        "payment_settlement_from": "payment_settlement_from_0",
        "payment_settlement_to": "payment_settlement_to_0",
        "payment_deduction": "payment_deduction_0",
        "payment_excess": "payment_excess_0",
        "welfare_fee": "welfare_fee_0",
        "transportation_fee": "transportation_fee_0",
        "bonuses_division": "bonuses_division_0",
	});
	// [begin] Clear fields.
	var textSymbols = [
        "#m_operation_term_begin",
        "#m_operation_term_end",
        "#m_operation_term_memo",
        "#m_operation_transfer_member",
        "#m_operation_contract_date",
        "#m_operation_demand_site",
        "#m_operation_payment_site",
		"#m_operation_other_memo",
        "#base_exc_tax_0",
        "#demand_wage_per_hour_0",
        "#demand_working_time_0",
        "#settlement_from_0",
        "#settlement_to_0",
        "#deduction_0",
        "#excess_0",
        "#payment_base_0",
        "#payment_wage_per_hour_0",
        "#payment_working_time_0",
        "#payment_settlement_from_0",
        "#payment_settlement_to_0",
        "#payment_deduction_0",
        "#payment_excess_0",
        "#welfare_fee_0",
        "#transportation_fee_0",
        "#bonuses_division_0",
        "#m_operation_project_client_id",
        "#m_operation_update_engineer_client_id"
	];
	var checkSymbols = [
		"#m_operation_is_active",
	];
	var notCheckSymbols = [
        "#m_operation_is_fixed",
	];
	var comboSymbols = [
	    "#demand_unit_0",
        "#payment_unit_0",
        "#settlement_unit_0",
        "#payment_settlement_unit_0",
    ];
	var radioSymbols = [];
	var i;
	for (i = 0; i < textSymbols.length; i++) {
		if (textSymbols[i] instanceof Array) {
			$(textSymbols[i][0])[0].value = textSymbols[i][1];
		} else {
			$(textSymbols[i])[0].value = "";
		}
	}
	for (i = 0; i < checkSymbols.length; i++) {
		$(checkSymbols[i])[0].checked = true;
	}
	for (i = 0; i < notCheckSymbols.length; i++) {
		$(notCheckSymbols[i])[0].checked = false;
	}
	for (i = 0; i < comboSymbols.length; i++) {
		$(comboSymbols[i])[0].selectedIndex = 0;
	}
	for (i = 0; i < radioSymbols.length; i++) {
		$(radioSymbols[i])[0].checked = true;
	}
	$('[name="m_operation_skill[]"]').each(function (idx, el) {
		el.checked = false;
	});
	$('[name="m_operation_skill_level[]"]').each(function (idx, el) {
		el.selectedIndex = 0;
	});
	viewSelectedOperationSkill();
	$("#base_inc_tax_0_label").empty();
	$("#payment_inc_tax_0_label").empty();
	$("#gross_profit_0_label").empty();
	$("#gross_profit_rate_0_label").empty();
	$("#gross_profit_rate_0_label").html("?????????");
	// [end] Clear fields.
    $('#m_operation_engineer_charging_user_id option[selected="selected"]').each(function() {
        $(this).removeAttr('selected');
    });
    $("#m_operation_engineer_charging_user_id option:first").attr('selected','selected');
    $('#m_operation_project_charging_user_id option[selected="selected"]').each(function() {
        $(this).removeAttr('selected');
    });
    $("#m_operation_project_charging_user_id option:first").attr('selected','selected');

    // init value
    var now = new Date();
	var year = now.getFullYear();
	var month = now.getMonth() + 1;
	var day = now.getDate();
	var mm = ('0' + month).slice(-2);
    var dd = ('0' + day).slice(-2);
    $("#m_operation_contract_date").datepicker("setDate", (year +"/" + mm + "/" + dd));

    $("#settlement_unit_0").val(2);
    $("#payment_settlement_unit_0").val(2);

    $("#m_operation_update_engineer_contract").val("???????????????");
    changeCalcFormArea("???????????????");

	$("#edit_operation_modal_title").html("??????????????????");
	$("#edit_operation_modal").modal("show");
	$('#m_operation_project_client_id').select2();
	$('#m_operation_update_engineer_client_id').select2({allowClear: true});
	viewSettlementMiniArea(0);
	viewPaymentSettlementMiniArea(0);
	viewDemandMemoArea(0);
	viewPaymentMemoArea(0);
}


function genCommitValueOfOperation() {

	var reqObj = getInputValueOperationObj(0);
	if ($("#m_operation_id").val()) {
		reqObj.id = Number($("#m_operation_id").val());
	}
    reqObj.project_client_id = Number($("#m_operation_project_client_id").val());
    reqObj.project_id = Number($("#m_operation_project").val());
    reqObj.engineer_id = Number($("#m_operation_engineer").val());
    reqObj.engineer_client_id = Number($("#m_operation_update_engineer_client_id").val());

	var textSymbols = [
        ["#m_operation_project_name", String],
        ["#m_operation_engineer_name", String],
        ["#m_operation_transfer_member", String],
        ["#m_operation_term_memo", String],
        ["#m_operation_demand_site", String],
        ["#m_operation_payment_site", String],
        ["#m_operation_other_memo", String],
	];
	var datePickerSymbols = [
	    ["#m_operation_term_begin", String],
		["#m_operation_term_end", String],
	    ["#m_operation_contract_date", String],
    ];
	var checkSymbols = [];
	var comboSymbols = [];
	var radioSymbols = [];
	var i, tmpEl;
	for(i = 0; i < textSymbols.length; i++) {
		tmpEl = $(textSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_operation_", "")] = textSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < datePickerSymbols.length; i++) {
		tmpEl = $(datePickerSymbols[i][0]);
		if (tmpEl.val() !== "") {
			reqObj[tmpEl.attr("id").replace("m_operation_", "")] = datePickerSymbols[i][1](tmpEl.val());
		}else{
		    reqObj[tmpEl.attr("id").replace("m_operation_", "")] = null;
        }
	}
	for(i = 0; i < checkSymbols.length; i++) {
		tmpEl = $(checkSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_operation_", "")] = checkSymbols[i][1](tmpEl[0].checked);
	}
	for(i = 0; i < comboSymbols.length; i++) {
		tmpEl = $(comboSymbols[i][0]);
		reqObj[tmpEl.attr("id").replace("m_operation_", "")] = comboSymbols[i][1](tmpEl.val());
	}
	for(i = 0; i < radioSymbols.length; i++) {
		tmpEl = $(radioSymbols[i][0]);
		reqObj[tmpEl.attr("name").replace("m_operation_", "").split("_")[0]] = radioSymbols[i][1](tmpEl.val());
	}

	reqObj.is_active = $('#m_operation_is_active').is(':checked') ? 1:0;
    reqObj.is_fixed = $('#m_operation_is_fixed').is(':checked') ? 1:0;

	return reqObj;
}

function triggerCommitOperationObject(){
    updateObject(commitOperationObject,null);
}

function commitOperationObject(updateFlg) {
    updateFlg = false;
	var reqObj = genCommitValueOfOperation();
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.operation,
		{
            "project_client_id": "m_operation_project_client_id",
            "project_name": "m_operation_project_name",
            "engineer_name": "m_operation_engineer_name",
		    "term_begin": "m_operation_term_begin",
            "term_end": "m_operation_term_end",
            "is_active": "m_operation_is_active",
            "is_fixed": "m_operation_is_fixed",
            "base_exc_tax": "base_exc_tax_0",
            "demand_wage_per_hour": "demand_wage_per_hour_0",
            "demand_working_time": "demand_working_time_0",
            "settlement_from": "settlement_from_0",
            "settlement_to": "settlement_to_0",
            "deduction": "deduction_0",
            "excess": "excess_0",
            "payment_base": "payment_base_0",
            "payment_wage_per_hour": "payment_wage_per_hour_0",
            "payment_working_time": "payment_working_time_0",
            "payment_settlement_from": "payment_settlement_from_0",
            "payment_settlement_to": "payment_settlement_to_0",
            "payment_deduction": "payment_deduction_0",
            "payment_excess": "payment_excess_0",
            "welfare_fee": "welfare_fee_0",
            "transportation_fee": "transportation_fee_0",
            "bonuses_division": "bonuses_division_0",
            "transfer_member": "m_operation_transfer_member",
            "contract_date": "m_operation_contract_date",
            "demand_site": "m_operation_demand_site",
            "payment_site": "m_operation_payment_site",
            "other_memo": "m_operation_other_memo",
            "engineer_client_id": "m_operation_update_engineer_client_id",
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("?????????????????????????????????");
		return;
	}
	if(validateOperationCondition(reqObj)){
		return;
	}

	var createOperationFunc = function (nextFunc, val) {
        c4s.invokeApi_ex({
            location: updateFlg ? "operation.updateOperation" : "operation.createOperation",
            body: reqObj,
            onSuccess: function (data) {
                alert(updateFlg ? "1????????????????????????" : "1????????????????????????");
                var onSuccessFunc = function () {
                    $("#focus_new_record").val(1);
                    c4s.hdlClickSearchBtn();
                }
                onSuccessFunc();
            },
            onError: function (data) {
                alert((updateFlg ? "??????" : "??????") + "????????????????????????" + data.status.description + "???");
            }
        });
    };

	var updateProjectFunc = function (nextFunc, val) {
	    var reqProjectObj = {};
	    var location = "project.updateProject"
	    reqProjectObj.id = reqObj.project_id;
	    reqProjectObj.title = reqObj.project_name;
	    reqProjectObj.charging_user_id = $("#m_operation_project_charging_user_id").val();
        reqProjectObj.update_data_and_skill_only = true;
        reqProjectObj.skill_level_list = [];
        reqProjectObj.needs = $('[name="m_operation_skill[]"]:checked').map(function() {
            var skill_id = $(this).val();
            var skill_level = $("#m_operation_skill_level_" + skill_id).val();
            if(skill_level != ""){
                reqProjectObj.skill_level_list.push({"id": skill_id, "level":skill_level});
            }
            return skill_id;
        }).get();

        if (reqProjectObj.id == 0) {
            location = "project.createProject"
            delete reqProjectObj.id;
            reqProjectObj.age_from = 22;
            reqProjectObj.age_to = 65;
            reqProjectObj.client_id = reqObj.project_client_id;
            reqProjectObj.expense = "";
            reqProjectObj.fee_inbound = 0;
            reqProjectObj.fee_outbound = 0;
            reqProjectObj.flg_public = false;
			reqProjectObj.web_public = false;
            reqProjectObj.flg_shared = false;
            reqProjectObj.interview = 1;
            reqProjectObj.process = "";
            reqProjectObj.rank_id = 1;
            reqProjectObj.scheme = "?????????";
            reqProjectObj.station_cd = "";
            reqProjectObj.station_lat = 0;
            reqProjectObj.station_line_cd = "";
            reqProjectObj.station_lon = 0;
            reqProjectObj.station_pref_cd = "";
        }

        c4s.invokeApi_ex({
            location: location,
            body: reqProjectObj,
            onSuccess: function (data) {
                if (data && data.data && data.data.id) {
                    reqObj.project_id = data.data.id;
                }
                nextFunc(val);
            },
            onError: function (data) {
                alert("???????????????????????????????????????" + data.status.description + "???");
            }
        });
    };

    var updateEngineerFunc = function (nextFunc, val) {

        var reqEngineerObj = {};
	    var location = "engineer.updateEngineer"
        reqEngineerObj.id = reqObj.engineer_id;
	    reqEngineerObj.name = reqObj.engineer_name;
        if ($("#m_operation_update_engineer_client_id").val() != "") {
            reqEngineerObj.client_id = $("#m_operation_update_engineer_client_id").val();
        }
        reqEngineerObj.contract = $("#m_operation_update_engineer_contract").val();
        reqEngineerObj.charging_user_id = $("#m_operation_engineer_charging_user_id").val();
        reqEngineerObj.update_data_only = true;

        if (reqEngineerObj.id == 0) {
            location = "engineer.createEngineer"
            delete reqEngineerObj.id;
            reqEngineerObj.client_name = "";
            reqEngineerObj.fee = 0;
            reqEngineerObj.flg_assignable = false;
            reqEngineerObj.flg_caution = false;
            reqEngineerObj.flg_public = false;
			reqEngineerObj.web_public = false;
            reqEngineerObj.flg_registered = true;
            reqEngineerObj.gender = "???";
            reqEngineerObj.kana = "";
            reqEngineerObj.mail1 = "";
            reqEngineerObj.station_cd = "";
            reqEngineerObj.station_lat = 0;
            reqEngineerObj.station_line_cd = "";
            reqEngineerObj.station_lon = 0;
            reqEngineerObj.station_pref_cd = "";
            reqEngineerObj.tel = "";
            reqEngineerObj.visible_name = "";
        }

        c4s.invokeApi_ex({
            location: location,
            body: reqEngineerObj,
            onSuccess: function (data) {
                if (data && data.data && data.data.id) {
                    reqObj.engineer_id = data.data.id;
                }
                nextFunc(val);
            },
            onError: function (data) {
                alert("???????????????????????????????????????" + data.status.description + "???");
            }
        });

    };
    updateProjectFunc(updateEngineerFunc, createOperationFunc);

}

function searchZip2Addr(zipCode, destinationId, alertId) {
	var code = zipCode.replace("-", "");
	if(code.match ( /[^0-9]+/ )){
		alert("????????????(0???9)????????????????????????(-)????????????????????????");
		return;
	}
	var destEl = $(destinationId);
	var alertEl = $(alertId);
	if (code && destEl.length > 0) {
		c4s.invokeApi_ex({
			location: "zip.search",
			body: {code: code},
			onSuccess: function (res) {
				if (res.data.addr1) {
					destEl.val(res.data.addr1);
					alertEl.html("");
				} else {
					alertEl.html("????????????????????????????????????????????????" + zipCode + "???");
				}
			},
			onError: function (res) {
				alertEl.html("???????????????????????????????????????");
			}
		});
	}
}

function changeCalcFormArea(contract){
    $("#calc_payment_term_form_area_0").removeClass("hidden");
    $("#calc_allowance_form_area_0").removeClass("hidden");

    if(contract == "?????????" || contract == "????????????"){
        $("#calc_payment_term_form_area_0").addClass("hidden");
    }else{
        $("#calc_allowance_form_area_0").addClass("hidden");
	}
	//??????????????????
	updateGrossProfit(0);
}

function changeCalcFormAreaWithIndex(engineer_id, contract, index){
    unsaved = true;
    $("#calc_payment_term_form_area_" + index).removeClass("hidden");
    $("#calc_allowance_form_area_" + index).removeClass("hidden");

    if(contract == "?????????" || contract == "????????????"){
        $("#calc_payment_term_form_area_" + index).addClass("hidden");
    }else{
        $("#calc_allowance_form_area_" + index).addClass("hidden");
	}

		//??????????????????
		updateGrossProfit(index);

    env.updateEngineerContractStackList = env.updateEngineerContractStackList || [];

    var targetEngineerId = engineer_id;
    env.updateEngineerContractStackList.some(function(v, i){
        if (v.engineer_id==targetEngineerId) env.updateEngineerContractStackList.splice(i,1);
    });
    var updateEngineerContractStack ={
        engineer_id : engineer_id,
        contract : contract
    };
	env.updateEngineerContractStackList.push(updateEngineerContractStack);
}

$(function() {
   $('.input-file').on('change', function() {
	   var file_name = $(this).prop('files')[0].name;
	   if(file_name != ""){
		   $(".input-file-message").addClass("hidden");
	   }else{
		   $(".input-file-message").removeClass("hidden");
	   }
   });
});

function setMtClients(index) {
    var selectedId = $('#engineer_client_select_' + index + ' > option:selected').val();
    $('#engineer_client_select_' + index + ' > option').remove();
    if(env.data.clients){
        var appendTag = "";
        for(var idx in env.data.clients){
            appendTag += "<option value='" + env.data.clients[idx].id + "'>" + env.data.clients[idx].name + "</option>";
            // $('#engineer_client_select_' + index).append($('<option>').html(env.data.clients[idx].name).val(env.data.clients[idx].id));
        }
        $('#engineer_client_select_' + index).append(appendTag);
    }
    if(selectedId.trim() != ""){
        $('#engineer_client_select_' + index).val(selectedId);
    }
    $('#engineer_client_select_' + index).select2();
}

c4s.jumpToPagination = function (pageNumber) {
           /* if (unsaved == true) {
                $('#before_action').val('jump_page');
                $('#page_number').val(pageNumber);
                $('#modal-confirm-unsaved').modal("show");
                return ;
			}*/
			updateObject(triggerLeave, null);
			unsaved = false;
            $('#modal-confirm-unsaved').modal("hide");
            var jumpToPageOperation = function(){
                c4s.jumpToPage(env.current, {
				pageNumber: pageNumber,
				query: genFilterQuery(),
				});
            }
            updateObject(jumpToPageOperation,null);
		};

c4s.hdlClickGnaviBtn = function (loc, options) {
    /*if (unsaved == true) {
        $('#before_action').val('click_gnavi');
        $('#loc').val(loc);
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");
    var form = $("<form/>")[0];
    var json = $("<input type='hidden' name='json'/>")[0];
    var reqObj = {
        login_id: env.login_id,
        credential: env.credential,
    };
    if(loc == "matching.project" || loc == "matching.engineer"){
        c4s.loadSearchConditionFromCookie(reqObj, loc);
    }
    if (options) {
        var i;
        for (i in options) {
            reqObj[i] = options[i];
        }
    }
    form.appendChild(json);
    form.action = "/" + [env.prefix, "html", loc].join("/") + "/";
    form.method = "POST";
    form.enctype = "application/x-www-form-urlencoded";
    json.value = JSON.stringify(reqObj);
    $("body").append(form);
    form.submit();
};

c4s.jumpToPage = function(path, option) {
    /*if (unsaved == true) {
        $('#before_action').val('logout');
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");
    option = option || {};
    var reqObj = option.query || {};
    if (option.tab) {
        reqObj.ctrl_selectedTab = option.tab;
    }
    reqObj.ctrl_referer = {
        path: env.current,
        tab: env.currentTab || option.currentTab || null,
        modal: env.currentModal || option.currentModal || null,
        query: env.recentQuery,
    };
    if (reqObj.ctrl_referer.query && reqObj.ctrl_referer.query.login_id) {
        delete reqObj.ctrl_referer.query.login_id;
    }
    if (reqObj.ctrl_referer.query && reqObj.ctrl_referer.query.credential) {
        delete reqObj.ctrl_referer.query.credential;
    }
    if (reqObj.ctrl_referer.query && reqObj.ctrl_referer.query.ctrl_referer) {
        delete reqObj.ctrl_referer.query.ctrl_referer;
    }
    if (option.pageNumber) {
        reqObj.pageNumber = option.pageNumber;
    } else {
        reqObj.pageNumber = 1;
    }
    if (option.modal) {
        reqObj.ctrl_referer.modal = option.modal;
    }
    c4s.invokeApi_ex({
        location: path,
        body: reqObj,
        pageMove: true,
    });
};

c4s.searchAll = function(word) {
    /*if (unsaved == true) {
        $('#before_action').val('search_all');
        $('#modal-confirm-unsaved').modal("show");
        return ;
	}*/
	updateObject(triggerLeave, null);
	unsaved = false;
    $('#modal-confirm-unsaved').modal("hide");
    c4s.invokeApi_ex({
        location: "home.search",
        body: {word: word},
        pageMove: true,
    });
    return false;
}

function addComma(target) {

    var val = $(target).val();

    if (val === undefined || val === "") {
        return;
    }

    val = formatForCalc(val);

    $(target).val(formatForView(val));
}

function triggerLeave() {
    return ;
}

$(function() {
   $('#btn-confirm-unsaved').on('click', function() {
        updateObject(triggerLeave, null);
        unsaved = false;
        if ($('#before_action').val() == 'new_operation') {
            hdlClickNewOperationObj();
        }
        if ($('#before_action').val() == 'trigger_estimate') {
            triggerCreateQuotationEstimate();
        }
        if ($('#before_action').val() == 'trigger_order') {
            triggerCreateQuotationOrder();
        }
        if ($('#before_action').val() == 'trigger_purchase') {
            triggerCreateQuotationPurchase();
        }
        if ($('#before_action').val() == 'trigger_invoice') {
            triggerCreateQuotationInvoice();
        }
        if ($('#before_action').val() == 'trigger_search') {
            triggerSearch();
        }
        if ($('#before_action').val() == 'trigger_search_clear') {
            triggerSearchClear();
        }
        if ($('#before_action').val() == 'jump_page') {
            c4s.jumpToPagination(parseInt($('#page_number').val()));
        }
        if ($('#before_action').val() == 'click_gnavi') {
            c4s.hdlClickGnaviBtn($('#loc').val(), null);
        }
        if ($('#before_action').val() == 'logout') {
            c4s.jumpToPage('auth.logout', null);
        }
        if ($('#before_action').val() == 'search_all') {
            c4s.searchAll($('#all_search_ipt').val(), null);
        }
   });
});

$(document).on('click', '.video-operation-new', function() {
    c4s.hdlClickVideoBtn('operaion_new');
});

$(document).on('click', '.video-operation-quotation', function() {
    c4s.hdlClickVideoBtn('operaion_quotation');
});
