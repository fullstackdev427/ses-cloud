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
    reqObj['check_init'] = 1;
	// [end] common.

	return reqObj;
}

function genOrderQuery (reqObj) {
	reqObj = reqObj || {};
	return reqObj;
}

function editQuotation(quotation_id, project_id) {

    c4s.invokeApi_ex({
        location: "quotation.topInvoice",
        body: {
            action_type: "EDIT",
        	quotation_id: quotation_id,
            project_id: project_id,
        },
        pageMove: true,
        newPage: true
    });
}

function copyQuotation(quotation_id, project_id) {


    c4s.invokeApi_ex({
        location: "quotation.topInvoice",
        body: {
            action_type: "COPY",
        	quotation_id: quotation_id,
            project_id: project_id,
        },
        pageMove: true,
        newPage: true
    });
}

function triggerCreateQuotationInvoice() {

	c4s.invokeApi_ex({
		location: "quotation.topInvoice",
		body: {
		    action_type: "CREATE",
			project_id: 0
		},
		pageMove: true,
		newPage: true
	});

}

function triggerExportExcel() {
    var checked = [];
    var id_array = [];
    $("input:checkbox").each(function(){
        var $this = $(this);

        if($this.is(":checked")){
            var id_str = $this.attr("id");
            if (id_str && typeof(id_str) == "string" && id_str.indexOf("iter_estimate_selected_cb_") >= 0)
            {
                var num = id_str.replace("iter_estimate_selected_cb_", "");
                if (num > 0) {
                    checked.push(num);

                    var onclick = $("#iter_" + num + " td:nth-child(12) span").attr("onclick");
                    onclick = onclick.replace("copyQuotation(", "");
                    onclick = onclick.replace(");", "");

                    id_array.push(onclick.split(','));
                }                
            }
        }
    });

    if (checked.length == 0) {
        alert("1つ以上のアイテムを選択してください。");
        return;
    }
	//window.open("https://promo.ses-cloud-stg.jp/prmnew/mypage/export?ids=" + JSON.stringify(checked), "_blank");
    // var person = new Object();
    // person.Name = "George";
    // person.EmailAddress = "aaa@aa.com";

    // console.log(env);
    // $.ajax({
    //     url: 'https://promo.ses-cloud-stg.jp/api/prmnew/mypage/test2',
    //     type: "POST",
    //     dataType: 'text',
    //     data: JSON.stringify(person),
    //     processData: false,
    //     contentType: 'application/json',
    //     CrossDomain:true,
    //     async: false,
    //     success: function(data,textStatus,xhr){
    //         console.log(data);
    //     },
    //     error: function(xhr,textStatus,errorThrown){
    //         console.log('Error Something');
    //         console.log(xhr);
    //         console.log(xtextStatusr);
    //         console.log(errorThrown);
    //     }
    // });
    
    var reqObj = {
	    prefix: env.prefix,
        quotation_id: JSON.stringify(checked),
    };

    // c4s.invokeApi_ex({
    //     location: "quotation.getDataForExcel",
    //     body: reqObj,
    //     onSuccess: function (res) {
    //         console.log(res);
    //     },
    // });
    var where = "(";
    for (var i=0; i<id_array.length; i++){
        var item = id_array[i];
        where += ("(`FQ`.`id`=" + item[0] + " AND " + "`FQ`.`project_id`=" + item[1] + ") OR ");
    }

    where = where.substr(0, where.length - 4);
    where += ")";

    c4s.invokeApi_ex({
        location: "quotation.getDataForExcel",
        body: {
            action_type: "COPY",
            where: where
        },
        onSuccess: function (result) {
            //console.log(JSON.stringify(result));
            var param = [];
            for (var i in result.data.results) {
                var data = null;
                for (var j in result.data.results)
                    if (result.data.results[j].id == checked[i]) {
                        data = result.data.results[j];
                        continue;
                    }
                
                if (data != null) {
                    console.log(data);
                    var output_val = JSON.parse(data.output_val.replace(/^"/g,'¥"').replace(/"$/g,'¥"'));
                    param.push({
                        "quotation_id": checked[i],
                        "client_name": data.client_name,
                        "quotation_no": output_val.quotation_no,
                        "quotation_name": output_val.quotation_name,
                        "subtotal": output_val.output.subtotal,
                        "total_including_tax": output_val.total_including_tax,
                        "quotation_month": output_val.quotation_month,
                        "payment_condition": output_val.output.payment_condition,
                        "expiration_date": output_val.output.expiration_date,
                        "rows": JSON.stringify(output_val.output.rows),
                        "bank_account1": result.data.bank_account1,
                        "bank_account2": result.data.bank_account2,
                        "free_rows": JSON.stringify(output_val.output.free_rows),
                        "memo": output_val.output.memo,
                        "office_memo": data.office_memo,
                    });
                }
            }

            console.log(param);
            var form = document.createElement("form");
            
            form.method = "POST";
            form.action = "https://promo.ses-cloud-stg.jp/api/prmnew/mypage/test2";
            form.target = "_blank";

            var element1 = document.createElement("input");

            element1.value=JSON.stringify(param);
            element1.name="param";

            form.appendChild(element1);

            document.body.appendChild(form);
        
            form.submit();

            document.body.removeChild(form);
        }
    });
    
}

function deleteQuotation(quotation_id){

    var reqObj = {
	    prefix: env.prefix,
        quotation_id: quotation_id,
		is_enabled: 0,
    };

    if (confirm("削除してよろしいですか。")) {

		c4s.invokeApi_ex({
			location: "quotation.createInvoice",
			body: reqObj,
			onSuccess: function (res) {
				alert("１件削除しました。");
                c4s.hdlClickSearchBtn();
			},
		});

	} else {
		return false;
	}

}

function updateQuotationIsSend(quotation_id, is_send) {

    var reqObj = {
        prefix: env.prefix,
        quotation_id: quotation_id,
        is_send: is_send,
    };

    c4s.invokeApi_ex({
        location: "quotation.createInvoiceSend",
        body: reqObj,
        onSuccess: function (res) {
            alert("１件更新しました。");
            c4s.hdlClickSearchBtn();
        },
    });
}

$("#query_quotation_month").datepicker({
        startView: 1,
        viewMode: "months",
        minViewMode: 'months',
        language: "ja",
        autoclose: true,
        changeYear: true,
        changeMonth: true,
        dateFormat: "yyyy/mm",
    });

$(document).on('click', '.video-estimate-new-1', function() {
    c4s.hdlClickVideoBtn('estimate_new_1');
});

$(document).on('click', '.video-estimate-new-2', function() {
    c4s.hdlClickVideoBtn('estimate_new_2');
});

$(document).on('click', '.video-estimate-form', function() {
    c4s.hdlClickVideoBtn('estimate_form');
});
