function download(id) {
	window.console.log("[Deplicated] OLD download() on manage.js is used.");
	c4s.download(id);
}

function uploadFile(fileInputId, fileIdEl, labelEl) {
	if (window.FormData) {
		var fd = new FormData();
		var fi = $(fileInputId)[0];
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
					console.log(data);
					if (data && data.data && data.data.id && data.status.code == 0) {
						$(fileIdEl).val(data.data.id);
						$(labelEl).html(data.data.filename + "(" + data.data.size + "bytes)");
					} else if (data && data.status.code == 13 && data.data && data.data.size && data.data.limit) {
						window.alert(data.status.description + "制限値が" + data.data.limit + "bytesのところ、アップロードしようとしたサイズは" + data.data.size + "bytesでした（" + String((data.data.size / data.data.limit - 1) * 100).split(".")[0] + "％超過）。");
					} else if (data && data.status.code) {
						window.alert(data.status.description);
						$(fileInputId).val(null);
						$(fileIdEl).val(null);
					} else {
						window.console ? console.log("file upload error.") : void(0);
					}
				},
				error: function (data) {
					
				}
			});
		}
	} else {
		alert("FormDataに非対応のWebブラウザです。Webブラウザのバージョンを最新に保ってください。");
	}
}

function hdlClickMigrateInvokeBtn(mode) {
	var reqObj = {};
	reqObj.attachment = $("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_id").val();
	reqObj.memo = $("#input_migrate" + (mode === "full" ? "_full" : "") + "_memo").val();
	if (reqObj.attachment) {
		reqObj.attachment = Number(reqObj.attachment);
	} else {
		window.alert("Excel（XLS形式）ファイルを指定してください。");
		return;
	}
	if (reqObj.memo) {
		reqObj.memo = reqObj.memo.substring(0, 512);
	}
	c4s.invokeApi_ex({
		location: "contact.migrateInvoke",
		body: reqObj,
		onSuccess: function (data) {
			window.alert("ファイルを登録しました。");
			$("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_id").val(null);
			$("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_file").val(null);
			$("#input_attachment_migrate" + (mode === "full" ? "_full" : "") + "_label").text("");
			$("#input_migrate" + (mode === "full" ? "_full" : "") + "_memo").val(null);
			//hdlClickRefreshMigrateRequests();
		},
	});
}

function hdlClickInquireBtn(type, content) {
	var content = content || {};
	if (content) {
		c4s.invokeApi_ex({
			location: "contact.commit",
			body: {
				type_inquire: type,
				content: content,
			},
			onSuccess: function (data) {
				if (data.status.code == 0) {
					window.alert("お問合せを受け付けました");
					c4s.invokeApi_ex({
						location: "home.enum",
						body: {},
						pageMove: true,
						newPage: false,
					});
				}
			},
		});
	}
}