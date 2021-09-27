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

	return reqObj;
}

function genOrderQuery (reqObj) {
	reqObj = reqObj || {};
	return reqObj;
}

function editQuotation(quotation_id, project_id) {

    c4s.invokeApi_ex({
        location: "quotation.topPurchase",
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
        location: "quotation.topPurchase",
        body: {
        	action_type: "COPY",
            quotation_id: quotation_id,
            project_id: project_id,
        },
        pageMove: true,
        newPage: true
    });
}

function triggerCreateQuotationPurchase() {

	c4s.invokeApi_ex({
		location: "quotation.topPurchase",
		body: {
			action_type: "CREATE",
			project_id: 0,
		},
		pageMove: true,
		newPage: true
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
			location: "quotation.createPurchase",
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

function updateQuotationIsSend(quotation_id, is_send){

    var reqObj = {
	    prefix: env.prefix,
        quotation_id: quotation_id,
		is_send: is_send,
    };

	c4s.invokeApi_ex({
		location: "quotation.createPurchaseSend",
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
