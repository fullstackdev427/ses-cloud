function toggleEditRow(id) {
	var tgtEditIcon = $("#iter_todo_edit_btn_" + id)[0];
	var tgtCommitIcon = $("#iter_todo_commit_btn_" + id)[0];
	var tgtNoteEl = $("#iter_todo_note_" + id)[0];
	var tgtPriorityReadEl = $("#iter_todo_priority_read_" + id)[0];
	var tgtPriorityWriteEl = $("#iter_todo_priority_write_" + id)[0];
	var currentState = tgtCommitIcon.style.display == "none" ? "READ" : "WRITE";
	switch (currentState) {
		case "READ":
			tgtCommitIcon.style.display = "inline";
			tgtEditIcon.style.display = "none";
			tgtNoteEl.readOnly = false;
			tgtPriorityReadEl.style.display = "none";
			tgtPriorityWriteEl.style.display = "block";
			break;
		case "WRITE":
			tgtCommitIcon.style.display = "none";
			tgtEditIcon.style.display = "inline";
			tgtNoteEl.readOnly = true;
			tgtPriorityReadEl.style.display = "inline";
			tgtPriorityWriteEl.style.display = "none";
			break;
		default:
			break;
	}
}

function genFilterQuery() {
	var queryObj = {};
	var statusVal = $("#query_status").val();
	if (statusVal !== "すべて") {
		queryObj['status'] = statusVal;
	}
	return queryObj;
}

function genOrderQuery() {
	return {};
}

function hdlClickCompleteBtn(id, status) {
	var reqObj = {};
	reqObj.id = id;
	reqObj.status = status || "完了";
	updateItem(reqObj);
}

function hdlClickCommitBtn(id) {
	var reqObj = {};
	reqObj.id = id;
	reqObj.note = $("#iter_todo_note_" + id).val();
	reqObj.priority = $("#iter_todo_priority_write_" + id).val();
	updateItem(reqObj);
}

function updateItem(reqObj, promptFlag) {
	c4s.invokeApi_ex({
		location: "misc.updateTodo",
		body: reqObj,
		onSuccess: function (res) {
			if (promptFlag && res.status.code == 0) {
				alert("更新しました。");
			}
			c4s.invokeApi_ex({
				location: env.current,
				body: env.recentQuery,
				pageMove: true,
			});
		},
	});
}

function hdlClickCreateBtn() {
	var reqObj = {};
	reqObj.note = $("#input_0_todo_note").val();
	reqObj.priority = $("#input_0_todo_priority").val();
	reqObj.status = "未完";
	var validLog = c4s.validate(
		reqObj,
		c4s.validateRules.todo,
		{
			note: "input_0_todo_note",
		}
	);
	if (validLog.length) {
		alert("未入力項目があります");
		return;
	}
	c4s.invokeApi("misc.createTodo", reqObj, function (data) {
		if (data && data.status && data.status.code == 0) {
			alert("登録しました。");
			c4s.invokeApi_ex({
				location: "misc.todoTop",
				body: {
					status: "未完"
				},
				pageMove: true,
			});
		} else {
			alert("登録に失敗しました。");
		}
	});
}
