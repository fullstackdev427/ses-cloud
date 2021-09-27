/* functions for quotation. */

// [begin] onload functions.
$(document).ready(function(evt) {
	var ROW_MAX_DEFAULT = 5;
	var FREE_ROW_MAX_DEFAULT = 3;
    rowMax = ROW_MAX_DEFAULT;
    freeRowMax = FREE_ROW_MAX_DEFAULT;

    //operation.jsを使うためのダミー値
    row_length = 0;

});
// [end] onload functions.

function updateCalcResult(rowId) {
    calcSubtotal(rowId);
    calcSubtotal("" + rowId + "_1");
    calcSubtotal("" + rowId + "_2");
    calcTotal();
}

function calcSubtotal(rowId) {

   var isMinus = false;
   var quantity = $("#quantity_" + rowId).val();
   var price = $("#price_" + rowId).val();
   var isIncludingTax = $("#is_including_tax_" + rowId).prop('checked');
   var tax = $("#tax_" + rowId).val();

   if (quantity === undefined || quantity === "") {
       return;
   }
   if (price === undefined || price === "") {
       return;
   }

   if(price.slice(0,1) == "-"){
        isMinus = true;
   }
   if(typeof rowId == "string"){
       if(rowId.slice(-1) == "2"){
           isMinus = true;
       }
   }
   quantity = quantity.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
    return String.fromCharCode(s.charCodeAt(0) - 65248);
   });
   price = price.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
    return String.fromCharCode(s.charCodeAt(0) - 65248);
   });
   price = price.replace(/,/g, '');
   quantity = quantity.replace(/[^0-9.]/g, '');
   price = price.replace(/[^0-9]/g, '');

   if (quantity === undefined || quantity === "") {
       return;
   }
   if (price === undefined || price === "") {
       return;
   }

   // var subtotal_no_tax = parseFloat(quantity) * parseInt(price);
   var subtotal_no_tax = new BigNumber(parseFloat(quantity)).times(parseInt(price)).toFixed(0);

   if(isMinus){
       price = price * -1;
       subtotal_no_tax = subtotal_no_tax * -1;
   }

   price = price.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
   subtotal_no_tax = subtotal_no_tax.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

   $("#quantity_" + rowId).val(quantity);
   $("#price_" + rowId).val(price);
   $("#subtotal_" + rowId).val(subtotal_no_tax);
}

function updateFreeCalcResult(freeRowId) {
    calcFreeSubtotal(freeRowId);
    calcTotal();
}

function calcFreeSubtotal(freeRowId) {

   var quantity = $("#free_quantity_" + freeRowId).val();
   var price = $("#free_price_" + freeRowId).val();
   var isIncludingTax = $("#free_is_including_tax_" + freeRowId).prop('checked');
   var tax = $("#free_tax_" + freeRowId).val();

   if (quantity === undefined || quantity === "") {
       return;
   }
   if (price === undefined || price === "") {
       return;
   }

   quantity = quantity.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
    return String.fromCharCode(s.charCodeAt(0) - 65248);
   });
   price = price.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
    return String.fromCharCode(s.charCodeAt(0) - 65248);
   });
   price = price.replace(/,/g, '');
   quantity = quantity.replace(/[^0-9.]/g, '');
   price = price.replace(/[^0-9]/g, '');

   if (quantity === undefined || quantity === "") {
       return;
   }
   if (price === undefined || price === "") {
       return;
   }

   // var subtotal_no_tax = parseFloat(quantity) * parseInt(price);
   var subtotal_no_tax = new BigNumber(parseFloat(quantity)).times(parseInt(price)).toFixed(0);


   price = price.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
   subtotal_no_tax = subtotal_no_tax.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

   $("#free_quantity_" + freeRowId).val(quantity);
   $("#free_price_" + freeRowId).val(price);
   $("#free_subtotal_" + freeRowId).val(subtotal_no_tax);
}

function calcTotal() {

    var subtotal = 0;
    var tax = 0;
    var totalIncludingTax = 0;

    for(var rowId = 1; rowId <= rowMax; rowId++) {

        var subtotalRow = calcSubtotalRow(rowId);
        subtotal += subtotalRow;
        var subtotalIncludingTaxRow = calcSubtotalIncludingTaxRow(subtotalRow, rowId);
        totalIncludingTax += subtotalIncludingTaxRow;

        var subtotalRow = calcSubtotalRow("" + rowId + "_1");
        subtotal += subtotalRow;
        var subtotalIncludingTaxRow = calcSubtotalIncludingTaxRow(subtotalRow, "" + rowId + "_1");
        totalIncludingTax += subtotalIncludingTaxRow;

        var subtotalRow = calcSubtotalRow("" + rowId + "_2");
        subtotal += subtotalRow;
        var subtotalIncludingTaxRow = calcSubtotalIncludingTaxRow(subtotalRow, "" + rowId + "_2");
        totalIncludingTax += subtotalIncludingTaxRow;
    }

    for(var freeRowId = 1; freeRowId <= freeRowMax; freeRowId++){
        var subtotalRow = calcFreeSubtotalRow(freeRowId);
        subtotal += subtotalRow;
        var subtotalIncludingTaxRow = calcFreeSubtotalIncludingTaxRow(subtotalRow, freeRowId);
        totalIncludingTax += subtotalIncludingTaxRow;
    }

    tax = totalIncludingTax - subtotal;

    subtotal = subtotal.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
    tax = tax.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
    totalIncludingTax = totalIncludingTax.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

    $("#subtotal").val(subtotal);
    $("#tax").val(tax);
    $("#total_including_tax").val(totalIncludingTax);
    $("#total_including_tax_view").html(totalIncludingTax);

}

function calcSubtotalRow(rowId){
    var subtotalRow = $("#subtotal_" + rowId).val();
    if (subtotalRow === undefined || subtotalRow === "") {
        return 0;
    }else{
        return parseInt(subtotalRow.replace(/,/g, ''));
    }
}

function calcSubtotalIncludingTaxRow(subtotalRow, rowId){
    var isIncludingTax = $("#is_including_tax_" + rowId).prop('checked');
    var taxRow = $("#tax_" + rowId).val();
    if(subtotalRow != 0){
        if(isIncludingTax){
            return subtotalIncludingTaxRow = parseInt(subtotalRow);
        }else{
            return subtotalIncludingTaxRow = Math.round(parseInt(subtotalRow) * (100 + parseInt(taxRow)) / 100 );
        }
    }else{
       return 0;
    }
}
function calcFreeSubtotalRow(rowId){
    var subtotalRow = $("#free_subtotal_" + rowId).val();
    if (subtotalRow === undefined || subtotalRow === "") {
        return 0;
    }else{
        return parseInt(subtotalRow.replace(/,/g, ''));
    }
}

function calcFreeSubtotalIncludingTaxRow(subtotalRow, rowId){
    var isIncludingTax = $("#free_is_including_tax_" + rowId).prop('checked');
    var taxRow = $("#free_tax_" + rowId).val();
    if(subtotalRow != 0){
        if(isIncludingTax){
            return subtotalIncludingTaxRow = parseInt(subtotalRow);
        }else{
            return subtotalIncludingTaxRow = Math.round(parseInt(subtotalRow) * (100 + parseInt(taxRow)) / 100 );
        }
    }else{
       return 0;
    }
}

function updateExcessAndDeduction(rowId){
    var settlement_exp = $("#settlement_exp_" + rowId).val();
    var excess_time = $("#summary_" + rowId + "_1").val();
    var deduction_time = $("#summary_" + rowId + "_2").val();


    if (settlement_exp === undefined || settlement_exp === "") {
        return;
    }


   settlement_exp = settlement_exp.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
    return String.fromCharCode(s.charCodeAt(0) - 65248);
   });
   excess_time = excess_time.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
    return String.fromCharCode(s.charCodeAt(0) - 65248);
   });
   deduction_time = deduction_time.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
    return String.fromCharCode(s.charCodeAt(0) - 65248);
   });


   settlement_exp = settlement_exp.replace(/,/g, '');
   excess_time = excess_time.replace(/,/g, '');
   deduction_time = deduction_time.replace(/,/g, '');

   settlement_exp = settlement_exp.replace(/[^0-9.]/g, '');
   excess_time = excess_time.replace(/[^0-9.]/g, '');
   deduction_time = deduction_time.replace(/[^0-9.]/g, '');

   if (settlement_exp === undefined || settlement_exp === "") {
       return;
   }

   settlement_exp = c4s.floor(parseFloat(settlement_exp),2);
   excess_time = c4s.floor(parseFloat(excess_time),2);
   deduction_time = c4s.floor(parseFloat(deduction_time),2);

   if(isNaN(settlement_exp)){
       settlement_exp = 0;
   }
   if(isNaN(excess_time)){
       excess_time = 0;
   }
   if(isNaN(deduction_time)){
       deduction_time = 0;
   }

   // settlement_exp = new BigNumber(parseFloat(settlement_exp)).toPrecision();
   // excess_time = new BigNumber(parseFloat(excess_time)).toPrecision();
   // deduction_time = new BigNumber(parseFloat(deduction_time)).toPrecision();


   var excess_quantity = 0;
   var deduction_quantity = 0;

   if(settlement_exp > excess_time){
       // excess_quantity = settlement_exp - excess_time;
       excess_quantity = new BigNumber(settlement_exp).minus(excess_time).toPrecision();
   }
   if(settlement_exp < deduction_time){
       // deduction_quantity = deduction_time - settlement_exp;
       deduction_quantity = new BigNumber(deduction_time).minus(settlement_exp).toPrecision();
   }

   // var subtotal_no_tax = parseInt(quantity) * parseInt(price);


   settlement_exp = settlement_exp.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
   excess_time = excess_time.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
   deduction_time = deduction_time.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');

   $("#settlement_exp_" + rowId).val(settlement_exp);
   $("#summary_" + rowId + "_1").val(excess_time);
   $("#summary_" + rowId + "_2").val(deduction_time);
   $("#quantity_" + rowId + "_1").val(excess_quantity);
   $("#quantity_" + rowId + "_2").val(deduction_quantity);

   updateCalcResult(rowId);

}

function reformatSubtotal(rowId){
    var subtotal_no_tax = $("#subtotal_" + rowId).val();
    if (subtotal_no_tax === undefined || subtotal_no_tax === "") {
       return;
    }
    subtotal_no_tax = subtotal_no_tax.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
        return String.fromCharCode(s.charCodeAt(0) - 65248);
    });
    subtotal_no_tax = subtotal_no_tax.replace(/,/g, '');
    subtotal_no_tax = subtotal_no_tax.replace(/[^0-9]/g, '');
    if (subtotal_no_tax === undefined || subtotal_no_tax === "") {
       return;
    }
    subtotal_no_tax = parseInt(subtotal_no_tax);

    subtotal_no_tax = subtotal_no_tax.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
    $("#subtotal_" + rowId).val(subtotal_no_tax);
}

function reformatFreeSubtotal(rowId){
    var subtotal_no_tax = $("#free_subtotal_" + rowId).val();
    if (subtotal_no_tax === undefined || subtotal_no_tax === "") {
       return;
    }
    subtotal_no_tax = subtotal_no_tax.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
        return String.fromCharCode(s.charCodeAt(0) - 65248);
    });
    subtotal_no_tax = subtotal_no_tax.replace(/,/g, '');
    subtotal_no_tax = subtotal_no_tax.replace(/[^0-9]/g, '');
    if (subtotal_no_tax === undefined || subtotal_no_tax === "") {
       return;
    }
    subtotal_no_tax = parseInt(subtotal_no_tax);
    subtotal_no_tax = subtotal_no_tax.toString().replace(/(\d)(?=(\d{3})+(?!\d))/g, '$1,');
    $("#free_subtotal_" + rowId).val(subtotal_no_tax);
}

function appendColumn() {

    rowMax++;

    var column_str = "";
    column_str += '<tr>';

    column_str += '<td style="width: 51%;">';
    column_str += '<input type="text" style="width: 100%;" id="summary_' + rowMax + '"><br>';
    column_str += '超過単価 (<input type="text" style="width: 10%;"pattern="^([1-9]\\d*|0)(\\.\\d+)?$" id="summary_' + rowMax + '_1" onchange="updateExcessAndDeduction(' + rowMax + ')">h)<br>';
    column_str += '控除単価 (<input type="text" style="width: 10%;"pattern="^([1-9]\\d*|0)(\\.\\d+)?$" id="summary_' + rowMax + '_2" onchange="updateExcessAndDeduction(' + rowMax + ')">h)';
    column_str += '</td>';

    column_str += '<td style="width: 5%;">';
    column_str += '<input type="text"style="text-align: right;width: 100%;" id="quantity_' + rowMax + '" onchange="updateCalcResult(' + rowMax + ')"><br>';
    column_str += '<input type="text"style="text-align: right;width: 100%;" id="quantity_' + rowMax + '_1" onchange="updateCalcResult(' + rowMax + ')"><br>';
    column_str += '<input type="text"style="text-align: right;width: 100%;" id="quantity_' + rowMax + '_2" onchange="updateCalcResult(' + rowMax + ')">';
    column_str += '</td>';


    column_str += '<td style="width: 5%;">';
    column_str += '<select id="unit_' + rowMax + '" style="margin: 2px 0px 2px 0px;">';
    column_str += '<option value="1" selected>件</option>';
    column_str += '<option value="2">時間</option>';
    column_str += '<option value="3">人時</option>';
    column_str += '<option value="4">人日</option>';
    column_str += '<option value="5">人月</option>';
    column_str += '</select><br>';
    column_str += '<select id="unit_' + rowMax + '_1" style="margin: 2px 0px 2px 0px;">';
    column_str += '<option value="1" selected>件</option>';
    column_str += '<option value="2">時間</option>';
    column_str += '<option value="3">人時</option>';
    column_str += '<option value="4">人日</option>';
    column_str += '<option value="5">人月</option>';
    column_str += '</select><br>';
    column_str += '<select id="unit_' + rowMax + '_2" style="margin: 2px 0px 2px 0px;">';
    column_str += '<option value="1" selected>件</option>';
    column_str += '<option value="2">時間</option>';
    column_str += '<option value="3">人時</option>';
    column_str += '<option value="4">人日</option>';
    column_str += '<option value="5">人月</option>';
    column_str += '</select>';
    column_str += '</td>';

    column_str += '<td style="width: 5%;">';
    column_str += '<input type="text"style="width: 100%;text-align: right;margin-top: 0px" id="settlement_exp_' + rowMax + '" onchange="updateExcessAndDeduction(' + rowMax + ')">';
    column_str += '<span style="font-size: large;">　</span><br><span style="font-size: large;">　</span>';
    column_str += '</td>';

    column_str += '<td style="width: 9%;">';
    column_str += '<input type="text" style="text-align: right;width: 100%;" id="price_' + rowMax + '" onchange="updateCalcResult(' + rowMax + ')"><br>';
    column_str += '<input type="text" style="text-align: right;width: 100%;" id="price_' + rowMax + '_1" onchange="updateCalcResult(' + rowMax + ')"><br>';
    column_str += '<input type="text" style="text-align: right;width: 100%;" id="price_' + rowMax + '_2" onchange="updateCalcResult(' + rowMax + ')">';
    column_str += '</td>';

    column_str += '<td style="width: 5%;" class="center">';
    column_str += '<input type="checkbox" name="" style="margin:  7px;" id="is_including_tax_' + rowMax + '" onchange="updateCalcResult(' + rowMax + ')"><br>';
    column_str += '<input type="checkbox" name="" style="margin:  7px;" id="is_including_tax_' + rowMax + '_1" onchange="updateCalcResult(' + rowMax + ')"><br>';
    column_str += '<input type="checkbox" name="" style="margin:  7px;" id="is_including_tax_' + rowMax + '_2" onchange="updateCalcResult(' + rowMax + ')">';
    column_str += '</td>';

    column_str += '<td style="width: 5%;" class="center">';
    column_str += '<select id="tax_' + rowMax + '" style="margin: 2px 0px 2px 0px;" onchange="updateCalcResult(' + rowMax + ')">';
    column_str += '<option value="10" selected>10</option>';
    column_str += '<option value="8">8</option>';
    column_str += '</select><br>';
    column_str += '<select id="tax_' + rowMax + '_1" style="margin: 2px 0px 2px 0px;" onchange="updateCalcResult(' + rowMax + ')">';
    column_str += '<option value="10" selected>10</option>';
    column_str += '<option value="8">8</option>';
    column_str += '</select><br>';
    column_str += '<select id="tax_' + rowMax + '_2" style="margin: 2px 0px 2px 0px;" onchange="updateCalcResult(' + rowMax + ')">';
    column_str += '<option value="10" selected>10</option>';
    column_str += '<option value="8">8</option>';
    column_str += '</select>';
    column_str += '</td>';

    column_str += '<td style="width: 10%;" >';
    column_str += '<input type="text"  style="text-align: right;width: 100%;" id="subtotal_' + rowMax + '" onchange="reformatSubtotal(' + rowMax + ');calcTotal()"><br>';
    column_str += '<input type="text"  style="text-align: right;width: 100%;" id="subtotal_' + rowMax + '_1" onchange="reformatSubtotal(\'' + rowMax + '_1\');calcTotal()"><br>';
    column_str += '<input type="text"  style="text-align: right;width: 100%;" id="subtotal_' + rowMax + '_2" onchange="reformatSubtotal(\'' + rowMax + '_2\');calcTotal()">';
    column_str += '</td>';

    column_str += '<td style="width: 5%; border-bottom-style: hidden; border-right-style: hidden;" class="center">';
    column_str += '<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor" title="削除" onclick="resetColumn(' + rowMax + ')"></span>';
    column_str += '</td>';

    column_str += '</tr>';

    $('#detail-table-body').append(column_str);

}

function resetColumn(rowId) {

    $("#summary_" + rowId).val("");
    $("#unit_" + rowId).val("1");
    $("#quantity_" + rowId).val("");
    $("#price_" + rowId).val("");
    $("#is_including_tax_" + rowId).prop("checked", false);
    $("#subtotal_" + rowId).val("");

    $("#settlement_exp_" + rowId).val("");

    $("tax_" + rowId + ' option').removeAttr('selected');
    $("tax_" + rowId + ' option[value="10"]').attr('selected','selected');

    $("#summary_" + rowId + "_1").val("");
    $("#unit_" + rowId + "_1").val("1");
    $("#quantity_" + rowId + "_1").val("");
    $("#price_" + rowId + "_1").val("");
    $("#is_including_tax_" + rowId + "_1").prop("checked", false);
    $("#subtotal_" + rowId + "_1").val("");

    $("tax_" + rowId + '_1 option').removeAttr('selected');
    $("tax_" + rowId + '_1 option[value="10"]').attr('selected','selected');

    $("#summary_" + rowId + "_2").val("");
    $("#unit_" + rowId + "_2").val("1");
    $("#quantity_" + rowId + "_2").val("");
    $("#price_" + rowId + "_2").val("");
    $("#is_including_tax_" + rowId + "_2").prop("checked", false);
    $("#subtotal_" + rowId + "_2").val("");

    $("tax_" + rowId + '_2 option').removeAttr('selected');
    $("tax_" + rowId + '_2 option[value="10"]').attr('selected','selected');

    calcTotal();
}

function appendFreeColumn() {

    freeRowMax++;

    var column_str = "";
    column_str += '<tr>';

    column_str += '<td style="width: 51%;">';
    column_str += '<input type="text" style="width: 100%;" id="free_summary_' + freeRowMax + '">';
    column_str += '</td>';

    column_str += '<td style="width: 5%;">';
    column_str += '<input type="text"style="text-align: right;width: 100%;" id="free_quantity_' + freeRowMax + '" onchange="updateFreeCalcResult(' + freeRowMax + ')">';
    column_str += '</td>';


    column_str += '<td style="width: 5%;">';
    column_str += '<select id="free_unit_' + freeRowMax + '" style="margin: 2px 0px 2px 0px;">';
    column_str += '<option value="1" selected>件</option>';
    column_str += '<option value="2">時間</option>';
    column_str += '<option value="3">人時</option>';
    column_str += '<option value="4">人日</option>';
    column_str += '<option value="5">人月</option>';
    column_str += '</select>';
    column_str += '</td>';

    column_str += '<td style="width: 5%;">';
    // column_str += '<input type="text"style="width: 100%;text-align: right;margin-top: 0px" id="settlement_exp_' + rowMax + '" onchange="updateExcessAndDeduction(' + rowMax + ')">';
    // column_str += '<span style="font-size: large;">　</span><br><span style="font-size: large;">　</span>';
    column_str += '</td>';

    column_str += '<td style="width: 9%;">';
    column_str += '<input type="text" style="text-align: right;width: 100%;" id="free_price_' + freeRowMax + '" onchange="updateFreeCalcResult(' + freeRowMax + ')">';
    column_str += '</td>';

    column_str += '<td style="width: 5%;" class="center">';
    column_str += '<input type="checkbox" name="" style="margin:  7px;" id="free_is_including_tax_' + freeRowMax + '" onchange="updateFreeCalcResult(' + freeRowMax + ')" checked="checked">';
    column_str += '</td>';

    column_str += '<td style="width: 5%;" class="center">';
    column_str += '<select id="free_tax_' + freeRowMax + '" style="margin: 2px 0px 2px 0px;" onchange="updateFreeCalcResult(' + freeRowMax + ')">';
    column_str += '<option value="10" selected>10</option>';
    column_str += '<option value="8">8</option>';
    column_str += '</select>';

    column_str += '<td style="width: 10%;" >';
    column_str += '<input type="text" style="text-align: right;width: 100%;" id="free_subtotal_' + freeRowMax + '" onchange="reformatFreeSubtotal('+ freeRowMax + ');calcTotal()">';
    column_str += '</td>';

    column_str += '<td style="width: 5%; border-bottom-style: hidden; border-right-style: hidden;" class="center">';
    column_str += '<span class="glyphicon glyphicon-trash text-danger pseudo-link-cursor" title="削除" onclick="resetFreeColumn(' + freeRowMax + ')"></span>';
    column_str += '</td>';

    column_str += '</tr>';

    $('#free-detail-table-body').append(column_str);

}

function resetFreeColumn(freeRowId) {

    $("#free_summary_" + freeRowId).val("");
    $("#free_unit_" + freeRowId).val("1");
    $("#free_quantity_" + freeRowId).val("");
    $("#free_price_" + freeRowId).val("");
    $("#free_is_including_tax_" + freeRowId).prop("checked", false);
    $("#free_subtotal_" + freeRowId).val("");

    // $("#free_settlement_exp_" + freeRowId).val("");

    $("free_tax_" + freeRowId + ' option').removeAttr('selected');
    $("free_tax_" + freeRowId + ' option[value="10"]').attr('selected','selected');

    calcTotal();
}




function triggerDownLoadQuotation() {
    if(env.current != "quotation.topPurchase") {
        var set_client_id = $("#client_id").val();
        if (!set_client_id || set_client_id.trim() == "" || set_client_id == "0") {
            alert("宛先が設定されていません。\n はじめに「既存データから作成」または「稼働情報を入力して作成」を選択し、対応する案件と稼働情報を設定してください。");
            return;
        }
    }

    var reqObj = setQuotationPram();

    var downloadLocation = "";
    switch (env.current){
        case "quotation.topEstimate":
            downloadLocation = "quotation.downloadEstimate";
            createLocation = "quotation.createEstimate";
            break;
        case "quotation.topOrder":
            downloadLocation = "quotation.downloadOrder";
            createLocation = "quotation.createOrder";
            break;
        case "quotation.topInvoice":
            downloadLocation = "quotation.downloadInvoice";
            createLocation = "quotation.createInvoice";
            break;
        case "quotation.topPurchase":
            downloadLocation = "quotation.downloadPurchase";
            createLocation = "quotation.createPurchase";
            break;
    }

    if (reqObj && createLocation != "") {

		c4s.invokeApi_ex({
			location: createLocation,
			body: reqObj,
			onSuccess: function (res) {
			    if(env.quotation_id == 0){
			        env.quotation_id = res.data.id;
                }
                if (reqObj && downloadLocation != "") {
                    var h = $(window).height();
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
                        }
                    }, 100);

                    c4s.invokeApi_ex({
                        location: downloadLocation,
                        body: reqObj,
                        pageMove: true,
                        newPage: false
                    });

                } else {
                    return false;
                }
			},
		});

	} else {
		return false;
	}

}

function saveQuotation(){

    if(env.current != "quotation.topPurchase"){
        var set_client_id = $("#client_id").val();
        if(!set_client_id || set_client_id.trim() == "" || set_client_id == "0"){
            alert("宛先が設定されていません。\n はじめに「既存データから作成」または「稼働情報を入力して作成」を選択し、対応する案件と稼働情報を設定してください。");
            return;
        }
    }


    var reqObj = setQuotationPram();
    var createLocation = "";
    var returnLocation = "";
    switch (env.current){
        case "quotation.topEstimate":
            createLocation = "quotation.createEstimate";
            returnLocation = "estimate.top";
            break;
        case "quotation.topOrder":
            createLocation = "quotation.createOrder";
            returnLocation = "order.top";
            break;
        case "quotation.topInvoice":
            createLocation = "quotation.createInvoice";
            returnLocation = "invoice.top";
            break;
        case "quotation.topPurchase":
            createLocation = "quotation.createPurchase";
            returnLocation = "purchase.top";
            break;
    }

    if (reqObj && createLocation != "") {

		c4s.invokeApi_ex({
			location: createLocation,
			body: reqObj,
			onSuccess: function (res) {
			    var returnObj ={};
			    if(env.quotation_id == 0){
			        env.quotation_id = res.data.id;
			        returnObj.focus_new_record_id = res.data.id;

                }
                alert("保存しました。");
			    if(confirm("一覧にもどりますか。")){
                    c4s.invokeApi_ex({
                        location: returnLocation,
                        body: returnObj,
                        pageMove: true,
                        newPage: false,
                    });
                }
			},
		});

	} else {
		return false;
	}

}

function sendMailwithPdf(){

    if(env.current != "quotation.topPurchase") {
        var set_client_id = $("#client_id").val();
        if (!set_client_id || set_client_id.trim() == "" || set_client_id == "0") {
            alert("宛先が設定されていません。\n はじめに「既存データから作成」または「稼働情報を入力して作成」を選択し、対応する案件と稼働情報を設定してください。");
            return;
        }
    }


    //[begin] Limitation of Mailing capacity per month.
	if (env.records.LMT_LEN_MAIL_PER_MONTH > env.limit.LMT_LEN_MAIL_PER_MONTH && env.limit.LMT_LEN_MAIL_PER_MONTH != 0) {
		$("#alert_cap_mail_modal").modal("show");
		return;
	}
	//[end] Limitation of Mailing capacity per month.

    var h = $(window).height();
    $('#loader-bg ,#loader').height(h).css('display','block');

    var reqObj = setQuotationPram();

	reqObj.make_pdf = true;
    var createLocation = "";
    switch (env.current){
        case "quotation.topEstimate":
            createLocation = "quotation.createEstimate";
            quotation_type = "estimate";
            break;
        case "quotation.topOrder":
            createLocation = "quotation.createOrder";
            quotation_type = "order";
            break;
        case "quotation.topInvoice":
            createLocation = "quotation.createInvoice";
            quotation_type = "invoice";
            break;
        case "quotation.topPurchase":
            createLocation = "quotation.createPurchase";
            quotation_type = "purchase";
            break;
    }

    if (reqObj && createLocation != "") {

		c4s.invokeApi_ex({
			location: createLocation,
			body: reqObj,
            async: true,
            timeout: 1000000,
			onSuccess: function (res) {
                // $('#loader-bg').delay(150).fadeOut(130);
                // $('#loader').delay(100).fadeOut(50);
                reqObj = {
                    back_page_quotation_location: env.current,
                    back_page_reqObj: env.recentQuery
                };
                if(env.quotation_id == 0){
			        env.quotation_id = res.data.id;
			        reqObj.quotation_id = res.data.id;
                }
                reqObj.type_data = "projects";
                reqObj.type_recipient = "forWorker";
                reqObj.projects = [];
                if($("#project_id").val() != ""){
                    reqObj.projects.push(Number($("#project_id").val()));
                }
                reqObj.recipients = {engineers: [], workers: [], users:[]};
                var worker_ids = $("#client_worker_ids").val();
                if (worker_ids != "") {
                    worker_id_list = worker_ids.split(',');
                    for (var j = 0; j < worker_id_list.length; j++) {
                        reqObj.recipients.workers.push(Number(worker_id_list[j]));
                    }
                }
                var user_ids = $("#company_user_ids").val();
                if (user_ids != "") {
                    user_id_list = user_ids.split(',');
                    for (var j = 0; j < user_id_list.length; j++) {
                        reqObj.recipients.users.push(Number(user_id_list[j]));
                    }
                }
                reqObj.quotation_id = env.quotation_id;
                reqObj.quotation_type = quotation_type;

                if($("#engineer_id").val() != ""){
                    reqObj.engineer_user_id = Number($("#engineer_id").val());
                }

                env.debugOut(reqObj);

                c4s.invokeApi_ex({
                    location: "mail.createQuotation",
                    body: reqObj,
                    pageMove: true,
                    newPage: false,
                });
			},
            onError: function (res) {
                $('#loader-bg').delay(150).fadeOut(130);
                $('#loader').delay(100).fadeOut(50);
                alert("エラーが発生しました。再度実行してください。");
            }
		});

	} else {
		return false;
	}

}

function setQuotationPram(){
    var reqObj = {
	    prefix: env.prefix,
        quotation_id: env.quotation_id
    };
	reqObj.project_id = $("#project_id").val();
	if(reqObj.project_id.length == 0){
		delete　reqObj.project_id ;
	}

	reqObj.client_id = $("#client_id").val();
	if(reqObj.client_id.length == 0){
		delete　reqObj.client_id ;
	}

	reqObj.company_id = $("#company_id").val();
	if(reqObj.company_id == ""){
	    reqObj.company_id = null;
    }

	reqObj.quotation_no = $("#quotation_no").val();
	reqObj.quotation_name = $("#quotation_name").val();
	reqObj.quotation_date = $("#quotation_date").val() + '/01';
	reqObj.quotation_month = $("#quotation_date").val();
	total_including_tax = $("#total_including_tax").val();
	reqObj.total_including_tax = total_including_tax.replace(/,/g, '');
	reqObj.is_view_window = $("#is_view_window").prop("checked");
	reqObj.is_view_excluding_tax = $("#is_view_excluding_tax").prop("checked");
    reqObj.office_memo = $("#office_memo").val();

    if(env.current == "quotation.topPurchase") {
        reqObj.engineer_id = $("#engineer_id").val();
        if(reqObj.engineer_id.length == 0){
            delete　reqObj.engineer_id ;
        }
				reqObj.client_id = $("#addr_name").val();
        reqObj.addr_name = $("#addr_name option:selected").text();
        reqObj.addr_vip = $("#addr_vip").val();
        reqObj.addr1 = $("#addr1").val();
        reqObj.addr2 = $("#addr2").val();
        reqObj.type_honorific = $("#honorific").val();
        if (reqObj.addr_vip) {
		    reqObj.addr_vip = reqObj.addr_vip.replace("-", "");
	    }
    }

	reqObj.output =  {
	    "client_id" : $("#client_id").val(),
	    "quotation_no" : $("#quotation_no").val(),
        "quotation_date" : $("#quotation_date").val() + '/01',
        "quotation_month" : $("#quotation_date").val(),
	    "quotation_name" : $("#quotation_name").val(),
        "payment_condition" : $("#payment_condition").val(),
        "expiration_date" : $("#expiration_date").val(),
	    "subtotal" : $("#subtotal").val(),
        "tax" : $("#tax").val(),
        "total_including_tax" : $("#total_including_tax").val(),
        "memo" : $("#memo").val(),
        "row_max" : rowMax,
        "rows" : [],
        "free_rows" : [],
        "is_view_window" : $("#is_view_window").prop("checked"),
        "is_view_excluding_tax" : $("#is_view_excluding_tax").prop("checked"),
        "office_memo" : $("#office_memo").val(),
    };

    if(env.current == "quotation.topPurchase") {
        reqObj.output.addr_name = $("#addr_name option:selected").text();
        reqObj.output.client_id = $("#addr_name").val();
        reqObj.output.addr_vip = $("#addr_vip").val();
        reqObj.output.addr1 = $("#addr1").val();
        reqObj.output.addr2 = $("#addr2").val();
        reqObj.output.type_honorific = $("#honorific").val();
        if (reqObj.output.addr_vip) {
		    reqObj.output.addr_vip = reqObj.output.addr_vip.replace("-", "");
	    }
    }



	for(var rowId = 1; rowId <= rowMax; rowId++) {

	    var row = {};
	    if($("#summary_" + rowId).val() != ""){
	        row.settlement_exp = $("#settlement_exp_" + rowId).val();
	        row.summary = $("#summary_" + rowId).val();
	        row.quantity = $("#quantity_" + rowId).val();
	        row.unit = $("#unit_" + rowId).val();
	        row.price = $("#price_" + rowId).val();
	        row.isIncludingTax = $("#is_including_tax_" + rowId).prop('checked');
	        row.tax = $("#tax_" + rowId).val();
            row.subtotal = $("#subtotal_" + rowId).val();

            if(row.unit != undefined) {
                switch (row.unit) {
                    case "1":
                        row.unit = "件";
                        break;
                    case "2":
                        row.unit = "時間";
                        break;
                    case "3":
                        row.unit = "人時";
                        break;
                    case "4":
                        row.unit = "人日";
                        break;
                    case "5":
                        row.unit = "人月";
                        break;

                    default:
                        row.unit = "";
                }
            }

            row.summary_1 = $("#summary_" + rowId + "_1").val();
	        row.quantity_1 = $("#quantity_" + rowId + "_1").val();
	        row.unit_1 = $("#unit_" + rowId + "_1").val();
	        row.price_1 = $("#price_" + rowId + "_1").val();
	        row.isIncludingTax_1 = $("#is_including_tax_" + rowId + "_1").prop('checked');
	        row.tax_1 = $("#tax_" + rowId + "_1").val();
            row.subtotal_1 = $("#subtotal_" + rowId + "_1").val();

            if(row.unit_1 != undefined) {
                switch (row.unit_1) {
                    case "1":
                        row.unit_1 = "件";
                        break;
                    case "2":
                        row.unit_1 = "時間";
                        break;
                    case "3":
                        row.unit_1 = "人時";
                        break;
                    case "4":
                        row.unit_1 = "人日";
                        break;
                    case "5":
                        row.unit_1 = "人月";
                        break;

                    default:
                        row.unit_1 = "";
                }
            }

            row.summary_2 = $("#summary_" + rowId + "_2").val();
	        row.quantity_2 = $("#quantity_" + rowId + "_2").val();
	        row.unit_2 = $("#unit_" + rowId + "_2").val();
	        row.price_2 = $("#price_" + rowId + "_2").val();
	        row.isIncludingTax_2 = $("#is_including_tax_" + rowId + "_2").prop('checked');
	        row.tax_2 = $("#tax_" + rowId + "_2").val();
            row.subtotal_2 = $("#subtotal_" + rowId + "_2").val();

            if(row.unit_2 != undefined) {
                switch (row.unit_2) {
                    case "1":
                        row.unit_2 = "件";
                        break;
                    case "2":
                        row.unit_2 = "時間";
                        break;
                    case "3":
                        row.unit_2 = "人時";
                        break;
                    case "4":
                        row.unit_2 = "人日";
                        break;
                    case "5":
                        row.unit_2 = "人月";
                        break;

                    default:
                        row.unit_2 = "";
                }
            }
            reqObj.output.rows.push(row);
        }
    }

    for(var freeRowId = 1; freeRowId <= freeRowMax; freeRowId++) {
	    var row = {};
	    if($("#free_summary_" + freeRowId).val() != ""){
	        row.summary = $("#free_summary_" + freeRowId).val();
	        row.quantity = $("#free_quantity_" + freeRowId).val();
	        row.unit = $("#free_unit_" + freeRowId).val();
	        row.price = $("#free_price_" + freeRowId).val();
	        row.isIncludingTax = $("#free_is_including_tax_" + freeRowId).prop('checked');
	        row.tax = $("#free_tax_" + freeRowId).val();
            row.subtotal = $("#free_subtotal_" + freeRowId).val();
            if(row.unit != undefined) {
                switch (row.unit) {
                    case "1":
                        row.unit = "件";
                        break;
                    case "2":
                        row.unit = "時間";
                        break;
                    case "3":
                        row.unit = "人時";
                        break;
                    case "4":
                        row.unit = "人日";
                        break;
                    case "5":
                        row.unit = "人月";
                        break;

                    default:
                        row.unit = "";
                }
            }
	        reqObj.output.free_rows.push(row);
        }
    }

    return reqObj;
}


// $(function() {
//     $('#detail-table').sortable({
//         items: 'tr',
//         cursor: 'move',
//         opacity: 0.5
//     });
//     $('#detail-table-first').disableSelection();
// });

function renderOperationModal(type, checked){

    if(type == "clear"){
        env.newOperationStackList = [];
        $("query_client_name").val("");
        $("query_title").val("");
        $("query_fee_inbound").val("");
        $("query_term").val("");
        $("query_interview").val("");
        $("query_scheme").val("");
        $("query_flg_shared").val("");
    }

    if(checked){
        checked = true;
    }else{
        checked = false;
    }

    c4s.invokeApi_ex({
			location: "operation.enumOperations",
			body: genOperationModalFilterQuery(),
			onSuccess: function (res) {
				env.data = env.data || {};
				if (res.data && res.data.length > 0) {
					env.data.operations = res.data;
				} else {
					env.data.operations = [];
				}
				renderOperationModalTable(env.data.operations, checked)
			},
		});
}


function renderOperationModalTable(datum,checked) {
	var tbody;
	var tmp_tr;
	var company_id = env.companyInfo.id;
	$("#row_count").html(datum.length+"件");

    tbody = $("#modal_search_result_operation tbody");
    tbody.html("");

    // if(env.current == "quotation.topPurchase"){
    //     if(datum && datum instanceof Array && datum.length > 0){
    //         datum = datum.filter(function(element, index, array) {
    //             return (element.engineer_client_id != null || company_id != element.engineer_company_id);
    //         });
    //     }
    // }

    if (datum && datum instanceof Array && datum.length > 0) {

        datum.map(function (val, idx) {
            tmp_tr = $("<tr></tr>");
            tmp_tr.append($("<td class='center'><a class='pseudo-link-cursor' onclick='triggerCreateQuotation(" + val.id + "," + val.project_id + ");'>選択</a></td>"));
            tmp_tr.append($("<td class='center' >" + val.client_name + "</td>"));
            tmp_tr.append($("<td class='center' ><label>" + val.project_title + "</label></td>"));
            tmp_tr.append($("<td class='center' >" + val.charging_user.user_name + "</td>"));
            if(env.current == "quotation.topPurchase") {
                tmp_tr.append($("<td >" + "" + "</td>"));
            }else{
                if (company_id != val.engineer_company_id) {
                    tmp_tr.append($("<td >" + val.engineer_company_name + "</td>"));
                } else {
                    tmp_tr.append($("<td >" + val.engineer_client_name + "</td>"));
                }
            }
            tmp_tr.append($("<td><label>" + val.engineer_name + "</label></td>"));
            tmp_tr.append($("<td style='text-align: center'>" + (val.term_begin || "") + "</td>"));
            tmp_tr.append($("<td style='text-align: center'>" + (val.term_end || "") + "</td>"));
            tbody.append(tmp_tr);
        });

    } else {
        tmp_tr = $("<tr></tr>");
        tmp_tr.append($("<td class='center' colspan='8'>（有効な稼働データがありません）</td>"));
        tbody.append(tmp_tr);
    }

}

function genOperationModalFilterQuery() {
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
	env.newOperationStackList = env.newOperationStackList || [];
	if(env.newOperationStackList.length > 0){
	    queryObj['operation_ids'] = env.newOperationStackList;
    }

	return queryObj;
}

$("#query_term").datepicker({
	weekStart: 1,
	viewMode: "dates",
	language: "ja",
	autoclose: true,
	changeYear: true,
	changeMonth: true,
	dateFormat: "yyyy/mm/dd",
});

function triggerCreateQuotation(operation_id, project_id) {

    operations = [];
    operations.push(String(operation_id));

    var createLocation = "";
    var reqObj = {};
    switch (env.current){
        case "quotation.topEstimate":
            createLocation = "quotation.topEstimate";
            break;
        case "quotation.topOrder":
            createLocation = "quotation.topOrder";
            break;
        case "quotation.topInvoice":
            createLocation = "quotation.topInvoice";
            break;
        case "quotation.topPurchase":
            createLocation = "quotation.topPurchase";
    }

    reqObj.action_type = "CREATE";
    reqObj.project_id = project_id;
    reqObj.operation_ids = operations;

	c4s.invokeApi_ex({
		location: createLocation,
		body: reqObj,
		pageMove: true,
		newPage: false
	});
}

$("#quotation_date").datepicker({
        viewMode: "months",
        minViewMode: "months",
        language: "ja",
        autoclose: true,
        changeYear: true,
        changeMonth: true,
        format: "yyyy/mm",
});


function openEngineerClientModal(project_id, project_title){

    //projectに紐づく稼働リストを取得
    renderProjectEngineerModal(project_id);
    $("#search_project_engineer_modal_select_title").html(project_title);
    $("#search_project_engineer_modal").modal("show");

}


function renderProjectEngineerModal(){

    c4s.invokeApi_ex({
			location: "operation.enumOperations",
			body: genOperationModalFilterQuery(),
			onSuccess: function (res) {
				env.data = env.data || {};
				if (res.data && res.data.length > 0) {
					env.data.operations = res.data;
				} else {
					env.data.operations = [];
				}
                renderProjectEngineerModalTable(env.data.operations)
			},
		});
}

function renderProjectEngineerModalTable(datum) {
	var tbody;
	var tmp_tr;
	var company_id = env.companyInfo.id;
    tbody = $("#modal_search_result_project_engineer tbody");
    tbody.html("");

    if(datum && datum instanceof Array && datum.length > 0){
        datum = datum.filter(function(element, index, array) {
            return (element.engineer_client_id != null || company_id != element.engineer_company_id);
        });
    }

    if (datum && datum instanceof Array && datum.length > 0) {

        var tmp_project_operation_block = [];
        datum.map(function (val, idx) {
            tmp_project_operation_block[val.project_id] = tmp_project_operation_block[val.project_id] || [];
            tmp_project_operation_block[val.project_id].push(val);
        });
        tmp_project_operation_block.map(function (project_operations, idx) {
            renderBpCompanyEngineer(tbody, project_operations);
            renderClientEngineer(tbody, project_operations);
        });

    } else {
        tmp_tr = $("<tr></tr>");
        tmp_tr.append($("<td class='center' colspan='8'>（選択された案件に有効な稼働データがありません）</td>"));
        tbody.append(tmp_tr);
    }

}

function renderBpCompanyEngineer(tbody, datum){
    var company_id = env.companyInfo.id;
    var tmp_tr;
    var bp_datum = datum.filter(function(element, index, array) {
            return (company_id != element.engineer_company_id);
        });

        var tmp_bp_datum_block = [];
        bp_datum.map(function (val, idx) {
            tmp_bp_datum_block[val.engineer_company_id] = tmp_bp_datum_block[val.engineer_company_id] || [];
            tmp_bp_datum_block[val.engineer_company_id].push(val);
        });

        tmp_bp_datum_block.map(function (v, i) {
            v.map(function (val, idx) {
                tmp_tr = $("<tr></tr>");
                if(idx == 0){
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'><a class='pseudo-link-cursor' onclick='triggerCreateQuotationForPurchase(" + val.project_id + "," + null + "," + val.engineer_company_id + ");'>選択</a></td>"));
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'>" + val.client_name + "</td>"));
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'><label>" + val.project_title + "</label></td>"));
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'>" + val.charging_user.user_name + "</td>"));
                    tmp_tr.append($("<td rowspan='"+ v.length + "'>" + val.engineer_company_name + "</td>"));
                }
                tmp_tr.append($("<td><label>" + val.engineer_name + "</label></td>"));
                tmp_tr.append($("<td style='text-align: center'>" + (val.term_begin || "") + "</td>"));
                tmp_tr.append($("<td style='text-align: center'>" + (val.term_end || "") + "</td>"));
                tbody.append(tmp_tr);
            });
        });
}

function renderClientEngineer(tbody, datum){
    var company_id = env.companyInfo.id;
    var tmp_tr;
    var my_datum = datum.filter(function(element, index, array) {
            return (company_id == element.engineer_company_id);
        });

        var tmp_datum_block = [];
        my_datum.map(function (val, idx) {
            tmp_datum_block[val.engineer_client_id] = tmp_datum_block[val.engineer_client_id] || [];
            tmp_datum_block[val.engineer_client_id].push(val);
        });

        tmp_datum_block.map(function (v, i) {
            v.map(function (val, idx) {
                tmp_tr = $("<tr></tr>");
                if(idx == 0){
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'><a class='pseudo-link-cursor' onclick='triggerCreateQuotationForPurchase(" + val.project_id + "," + val.engineer_client_id + "," + null + ");'>選択</a></td>"));
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'>" + val.client_name + "</td>"));
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'><label>" + val.project_title + "</label></td>"));
                    tmp_tr.append($("<td class='center' rowspan='"+ v.length + "'>" + val.charging_user.user_name + "</td>"));
                    tmp_tr.append($("<td rowspan='"+ v.length + "'>" + val.engineer_client_name + "</td>"));
                }
                tmp_tr.append($("<td><label>" + val.engineer_name + "</label></td>"));
                tmp_tr.append($("<td style='text-align: center'>" + (val.term_begin || "") + "</td>"));
                tmp_tr.append($("<td style='text-align: center'>" + (val.term_end || "") + "</td>"));
                tbody.append(tmp_tr);
            });
        });
}

function triggerCreateQuotationForPurchase(project_id, engineer_client_id, engineer_company_id) {

    var createLocation = "quotation.topPurchase";
    var reqObj = {
            action_type: "CREATE",
            project_id: project_id
        };

    if(engineer_client_id){
        reqObj.client_id = engineer_client_id;
        reqObj.engineer_client_id = engineer_client_id;
    }else{
        reqObj.company_id = engineer_company_id;
        reqObj.engineer_company_id = engineer_company_id;
    }

	c4s.invokeApi_ex({
		location: createLocation,
		body: reqObj,
		pageMove: true,
		newPage: false
	});
}

function loadClientInfo(set_name){

    var client_id = $("#client_id").val();

    if(client_id == undefined || client_id === ""){
        return;
    }
    c4s.invokeApi("client.enumClients", {id: Number(client_id)}, function (data) {
        if (data && data.status && data.data&& data.status.code == 0 && data.data instanceof Array && data.data[0]) {

            var tgtData = data.data[0];
            var order_client_name = (tgtData.name == "" || tgtData.name == "null" || !tgtData.name) ? "" : tgtData.name;
            var order_client_addr_vip = (tgtData.addr_vip == "" || tgtData.addr_vip == "null" || !tgtData.addr_vip) ? "" : tgtData.addr_vip;
            var order_client_addr1 = (tgtData.addr1 == "" || tgtData.addr1 == "null" || !tgtData.addr1) ? "" : tgtData.addr1;
            var order_client_addr2 = (tgtData.addr2 == "" || tgtData.addr2 == "null" || !tgtData.addr2) ? "" : tgtData.addr2;
            var order_client_tel = (tgtData.tel == "" || tgtData.tel == "null" || !tgtData.tel) ? "" : tgtData.tel;
            var order_client_fax = (tgtData.fax == "" || tgtData.fax == "null" || !tgtData.fax) ? "" : tgtData.fax;
            var client_worker_ids = (tgtData.worker_id_list == "" || tgtData.worker_id_list == "null" || !tgtData.worker_id_list) ? "" : tgtData.worker_id_list;

            $("#order_client_name").html(order_client_name);
            $("#order_client_addr_vip").html(order_client_addr_vip);
            $("#order_client_addr1").html(order_client_addr1);
            $("#order_client_addr2").html(order_client_addr2);
            $("#order_client_tel").html(order_client_tel);
            $("#order_client_fax").html(order_client_fax);
            $("#client_worker_ids").val(client_worker_ids);

            if(env.current == "quotation.topPurchase"){
                if(set_name){
                    $("#addr_name").val(order_client_name);
                }
                $("#addr_vip").val(order_client_addr_vip);
                $("#addr1").val(order_client_addr1);
                $("#addr2").val(order_client_addr2);
                viewAddrFormArea();
            }
        }
    });
}

function loadEngineerInfo(){

    var engineer_id = $("#engineer_id").val();

    if(engineer_id == undefined || engineer_id === ""){
        return;
    }
    c4s.invokeApi("engineer.enumEngineers", {id: Number(engineer_id)}, function (data) {
        if (data && data.status && data.data&& data.status.code == 0 && data.data instanceof Array && data.data[0]) {

            var tgtData = data.data[0];
            var order_engineer_name = (tgtData.name == "" || tgtData.name == "null" || !tgtData.name) ? "" : tgtData.name;
            var order_engineer_addr_vip = (tgtData.addr_vip == "" || tgtData.addr_vip == "null" || !tgtData.addr_vip) ? "" : tgtData.addr_vip;
            var order_engineer_addr1 = (tgtData.addr1 == "" || tgtData.addr1 == "null" || !tgtData.addr1) ? "" : tgtData.addr1;
            var order_engineer_addr2 = (tgtData.addr2 == "" || tgtData.addr2 == "null" || !tgtData.addr2) ? "" : tgtData.addr2;

            if(env.current == "quotation.topPurchase"){
                $("#addr_name").val(order_engineer_name);
                $("#addr_vip").val(order_engineer_addr_vip);
                $("#addr1").val(order_engineer_addr1);
                $("#addr2").val(order_engineer_addr2);
                $("#honorific").val("様");
                viewAddrFormArea();
            }
        }
    });
}

function initLabel(){
	switch (env.current){
        case "quotation.topEstimate":
            $("#quotation_header_label").html("見積書");
            $("#quotation_title_label").html("見積書");
            $("#quotation_sentence_label").html("下記の通り、お見積申し上げます。");
            $("#quotation_date_label").html("見積月");
						$("#quotation_date_label2").html("見積月");
            break;
        case "quotation.topOrder":
            $("#quotation_header_label").html("請求先注文書");
            $("#quotation_title_label").html("注文書");
            $("#quotation_sentence_label").html("下記の通り、注文致します。");
            $("#quotation_date_label").html("注文月");
						$("#quotation_date_label2").html("注文月");
            $("#quotation_annotation_label").html("※発行時に注文書と注文請書が作成されます。");
            break;
        case "quotation.topInvoice":
            $("#quotation_header_label").html("請求書");
            $("#quotation_title_label").html("請求書");
            $("#quotation_sentence_label").html("下記の通り、ご請求申し上げます。");
            $("#quotation_date_label").html("請求月");
						$("#quotation_date_label2").html("請求月");
            break;
        case "quotation.topPurchase":
            $("#quotation_header_label").html("注文書");
            $("#quotation_title_label").html("注文書");
            $("#quotation_sentence_label").html("下記の通り、注文致します。");
            $("#quotation_date_label").html("注文月");
						$("#quotation_date_label2").html("注文月");
            break;
    }
}

function loadDataFromHistory(){
    $('#client_id').val(rec_history_json.client_id);
    var quotation_date = env.history.quotation_date.split('/');
    $('#quotation_date').val(quotation_date[0] + '/' + quotation_date[1]);
		$('#quotation_month').val(quotation_date[0] + '/' + quotation_date[1]);
    if (env.history.expiration_date) {
      $('#expiration_date').val(env.history.expiration_date);
    } else {
      $('#expiration_date').val('書類発行から一ヶ月');
    }
    $('#memo').val(env.history.memo);
    $("#payment_condition").val(env.history.payment_condition);
    $('#quotation_name').val(env.history.quotation_name);
    $('#quotation_no').val(env.history.quotation_no);
    $('#subtotal').val(env.history.subtotal);
    $('#tax').val(env.history.tax);
    $('#total_including_tax').val(env.history.total_including_tax);
    $('#office_memo').val(env.history.office_memo);
    $('#honorific').val(env.history.type_honorific);
    $('#engineer_id').val(rec_history_json.engineer_id);

    if(env.history.is_view_window){
        $("#is_view_window").prop("checked",true);
    }
    if(env.history.is_view_excluding_tax){
        $("#is_view_excluding_tax").prop("checked",true);
    }

    if(env.history.rows.length > rowMax){
        var addRowNumber = env.history.rows.length - rowMax;
        for (var i = 0; i < addRowNumber; i++) {
            appendColumn();
        }
    }

    var row = 1;
    for (var i = 0; i < env.history.rows.length; i++) {

        if(env.history.rows[i].length == 0){
            continue;
        }
        $("#settlement_exp_" + row).val(env.history.rows[i].settlement_exp);

        $("#summary_" + row).val(env.history.rows[i].summary);
        $("#quantity_" + row).val(env.history.rows[i].quantity);
        $("#price_" + row).val(env.history.rows[i].price);
	$("#tax_" + row).val(env.history.rows[i].tax);

        var select = 1;
        switch (env.history.rows[i].unit){
            case "件":
                select = 1;
                break;
            case "時間":
                select = 2;
                break;
            case "人時":
                select = 3;
                break;
            case "人日":
                select = 4;
                break;
            case "人月":
                select = 5;
                break;
        }
        $("#unit_" + row).val(select);
        $("#is_including_tax_" + row).prop("checked",env.history.rows[i].isIncludingTax);

        $("#summary_" + row + "_1").val(env.history.rows[i].summary_1);
        $("#quantity_" + row + "_1").val(env.history.rows[i].quantity_1);
        $("#price_" + row + "_1").val(env.history.rows[i].price_1);
	$("#tax_" + row + "_1").val(env.history.rows[i].tax_1);

        var select = 1;
        switch (env.history.rows[i].unit_1){
            case "件":
                select = 1;
                break;
            case "時間":
                select = 2;
                break;
            case "人時":
                select = 3;
                break;
            case "人日":
                select = 4;
                break;
            case "人月":
                select = 5;
                break;
        }
        $("#unit_" + row + "_1").val(select);
        $("#is_including_tax_" + row + "_1").prop("checked",env.history.rows[i].isIncludingTax_1);

        $("#summary_" + row + "_2").val(env.history.rows[i].summary_2);
        $("#quantity_" + row + "_2").val(env.history.rows[i].quantity_2);
        $("#price_" + row + "_2").val(env.history.rows[i].price_2);
	$("#tax_" + row + "_2").val(env.history.rows[i].tax_2);

        var select = 1;
        switch (env.history.rows[i].unit_2){
            case "件":
                select = 1;
                break;
            case "時間":
                select = 2;
                break;
            case "人時":
                select = 3;
                break;
            case "人日":
                select = 4;
                break;
            case "人月":
                select = 5;
                break;
        }
        $("#unit_" + row + "_2").val(select);
        $("#is_including_tax_" + row + "_2").prop("checked",env.history.rows[i].isIncludingTax_2);

        updateCalcResult(row);
        row++;

    }

    if(env.history.free_rows.length > freeRowMax){
        var addRowNumber = env.history.free_rows.length - freeRowMax;
        for (var i = 0; i < addRowNumber; i++) {
            appendFreeColumn();
        }
    }

    var freeRow = 1;
    for (var i = 0; i < env.history.free_rows.length; i++) {

        if(env.history.free_rows[i].length == 0){
            continue;
        }
        // $("#free_settlement_exp_" + row).val(env.history.rows[i].settlement_exp);

        $("#free_summary_" + freeRow).val(env.history.free_rows[i].summary);
        $("#free_quantity_" + freeRow).val(env.history.free_rows[i].quantity);
        $("#free_price_" + freeRow).val(env.history.free_rows[i].price);
	    $("#free_tax_" + freeRow).val(env.history.free_rows[i].tax);

        var select = 1;
        switch (env.history.free_rows[i].unit){
            case "件":
                select = 1;
                break;
            case "時間":
                select = 2;
                break;
            case "人時":
                select = 3;
                break;
            case "人日":
                select = 4;
                break;
            case "人月":
                select = 5;
                break;
        }
        $("#free_unit_" + freeRow).val(select);
        $("#free_is_including_tax_" + freeRow).prop("checked",env.history.free_rows[i].isIncludingTax);

        updateFreeCalcResult(freeRow);
        freeRow++;

    }
}

function loadDataFromOperation(){
    var now = new Date();
    var y = now.getFullYear();
    var m = now.getMonth() + 1;
    if (env.current == "quotation.topInvoice") {
      if (m == 1) {
        m = 12;
        y = y - 1;
      } else {
        m = m - 1;
        y = y;
      }
    }
    var d = now.getDate();
    var mm = ('0' + m).slice(-2);
    var dd = ('0' + d).slice(-2);
    $('#quotation_date').val(y + '/' + mm);
		$('#quotation_month').val(y + '/' + mm);
    $('#expiration_date').val('書類発行から一ヶ月');

    if(env.operations.length > rowMax){
        var addRowNumber = env.operations.length - rowMax;
        for (var i = 0; i < addRowNumber; i++) {
            appendColumn();
        }
    }


    var row = 1;
    for (var i = 0; i < env.operations.length; i++) {

        if(env.current != "quotation.topPurchase"){
            if (i == 0) {
                $("#client_id").val(env.operations[i].client_id);
                $("#client_name").val(env.operations[i].client_name);
                $("#quotation_name").val(env.operations[i].project_title);
                $("#payment_condition").val(env.operations[i].demand_site);
            }

            $("#summary_" + row).val("基本月給 (" + env.operations[i].engineer_name + ")");
            $("#quantity_" + row).val(1);
            $("#price_" + row).val(env.operations[i].base_exc_tax);
            $("#unit_" + row).val("5");
            updateCalcResult(row);

            if (env.operations[i].excess > 0) {
                $("#summary_" + row + "_1").val(env.operations[i].settlement_to);
                $("#quantity_" + row + "_1").val(0);
                $("#price_" + row + "_1").val(env.operations[i].excess);
                $("#unit_" + row + "_1").val("2");
                updateCalcResult(row);
            }

            if (env.operations[i].deduction > 0) {
                $("#summary_" + row + "_2").val(env.operations[i].settlement_from);
                $("#quantity_" + row + "_2").val(0);
                $("#price_" + row + "_2").val(-env.operations[i].deduction);
                $("#unit_" + row + "_2").val("2");
                updateCalcResult(row);
            }
        }else{
            if (i == 0) {
                if(env.userCompany){
                    $("#client_name").val(env.userCompany.name);
                }else{
                    $("#client_name").val(env.operations[i].engineer_client_name);
                }
                $("#quotation_name").val(env.operations[i].project_title);
                $("#payment_condition").val(env.operations[i].payment_site);
                $("#client_id").val(env.operations[i].engineer_client_id || 0);
            }

            $("#summary_" + row).val("基本月給 (" + env.operations[i].engineer_name + ")");
            $("#quantity_" + row).val(1);
            $("#price_" + row).val(env.operations[i].payment_base);
            $("#unit_" + row).val("5");
            updateCalcResult(row);

            if (env.operations[i].payment_excess > 0) {
                $("#summary_" + row + "_1").val(env.operations[i].payment_settlement_to);
                $("#quantity_" + row + "_1").val(0);
                $("#price_" + row + "_1").val(env.operations[i].payment_excess);
                $("#unit_" + row + "_1").val("2");
                updateCalcResult(row);
            }

            if (env.operations[i].payment_deduction > 0) {
                $("#summary_" + row + "_2").val(env.operations[i].payment_settlement_from);
                $("#quantity_" + row + "_2").val(0);
                $("#price_" + row + "_2").val(-env.operations[i].payment_deduction);
                $("#unit_" + row + "_2").val("2");
                updateCalcResult(row);
            }
        }
        row++;
    }
    if(env.operations.length == 0){
        calcTotal();
    }
}

function resetDataForCopy(){
    env.quotation_id = 0;

    var now = new Date();
    var y = now.getFullYear();
    var m = now.getMonth() + 1;
    var d = now.getDate();
    var mm = ('0' + m).slice(-2);
    var dd = ('0' + d).slice(-2);
    $('#quotation_date').val(y + '/' + mm);
		$('#quotation_month').val(y + '/' + mm);

    if(env.quotation_default_no != ""){
        $('#quotation_no').val(env.quotation_default_no);
    }
}

function pushOperationObjectList(nextFlg) {

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
		});
	if (validLog.length) {
		env.debugOut(validLog);
		alert("入力を修正してください");
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
                alert(updateFlg ? "1件更新しました。" : "1件登録しました。");
                pushNewOperationStackList(data.data.id);
                if(nextFlg){
                    hdlClickNewOperationObj();
                }else{
                    //新規登録モーダルを非表示にして稼働検索モーダルを表示
                    $('#edit_operation_modal').modal('hide');
                    var operation_id = data.data.id;
                    var project_id = reqObj.project_id;
                    triggerCreateQuotation(operation_id, project_id);
                }
            },
            onError: function (data) {
                alert((updateFlg ? "更新" : "登録") + "に失敗しました（" + data.status.description + "）");
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
            reqProjectObj.flg_shared = true;
            reqProjectObj.interview = 1;
            reqProjectObj.process = "";
            reqProjectObj.rank_id = 1;
            reqProjectObj.scheme = "エンド";
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
                alert("案件の更新に失敗しました（" + data.status.description + "）");
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
            reqEngineerObj.flg_assignable = true;
            reqEngineerObj.flg_caution = false;
            reqEngineerObj.flg_public = false;
            reqEngineerObj.web_public = false;
            reqEngineerObj.flg_registered = true;
            reqEngineerObj.gender = "男";
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
                alert("要員の更新に失敗しました（" + data.status.description + "）");
            }
        });

    };
    updateProjectFunc(updateEngineerFunc, createOperationFunc);
}

function pushNewOperationStackList(operation_id){
    env.newOperationStackList = env.newOperationStackList || [];
    env.newOperationStackList.push(String(operation_id));
}

function redirectConfig(){

    if(validateQuotationConfig()){
        return;
    }else{

        if(confirm("各種帳票の設定を行って下さい")){
            c4s.invokeApi_ex({
                location: "manage.top",
                body: {
                    ctrl_selectedTab: "ct_form",
                    back_page_quotation_location: env.current,
                    back_page_reqObj: env.recentQuery
                },
                pageMove: true,
            });
        }else{
            return;
        }
    }
}

function validateQuotationConfig(){

    var companyConfig = env.manageUserProfile.company;
    // if(companyConfig.company_seal == undefined || companyConfig.company_seal == ""){
    //     return false;
    // }
    if(companyConfig.bank_account1 == undefined || companyConfig.bank_account1 == ""){
        return false;
    }
    if(env.current == "quotation.topEstimate" && companyConfig.estimate_charging_user_id == undefined){
        return false;
    }
    if(env.current == "quotation.topOrder" && companyConfig.order_charging_user_id == undefined){
        return false;
    }
    if(env.current == "quotation.topInvoice" && companyConfig.invoice_charging_user_id == undefined){
        return false;
    }
    if(env.current == "quotation.topPurchase" && companyConfig.purchase_charging_user_id == undefined){
        return false;
    }

    return true;
}

function viewAddrFormArea() {

    var is_view_window = $("#is_view_window").is(':checked');
    if(is_view_window){
        $("#addr_form_area").show();
    }else{
        $("#addr_form_area").hide();
    }
}
