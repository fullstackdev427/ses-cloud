$(document).ready(
	function () {
		if (env.limit.LMT_CALL_MAP_EXTERN_M && (env.mapCalledCount >= env.limit.LMT_CALL_MAP_EXTERN_M)) {
			var msg = "月間利用可能回数が上限を超えています。詳細は担当者にご確認下さい";
			alert(msg);
			window.close();
		} else if (ZDC._LOAD_ERR_MSG) {
			insertMapLog({
				request_body: JSON.stringify("Load_ZDC"),
				response_body: JSON.stringify(ZDC._LOAD_ERR_MSG),
				api_status: "NG"
			});
			alert("読み込みエラーが発生しました。");
			window.close();
		} else {
			/* 地図にバルーンを表示 */
			function appendBalloon (map, latlon, prefs) {
				var labelhtml = "<div><div><span style='font-weight: bold;'>" + prefs.companyName + "</span></div>";
				labelhtml += "<table cellspacing='0'>";
				labelhtml += "<tr><td><span style='text-decoration: underline;'>住所：" + prefs.zenrinAddress + "</span></td></tr>";
				labelhtml += "<tr><td><span style='text-decoration: underline;'>電話番号：" + prefs.phoneNumber + "</span></td></tr>";
				labelhtml += "</table>";
				var balloon = new ZDC.MsgInfo(
						latlon,
						{
							html: labelhtml
						}
				);
				map.addWidget(balloon);
				balloon.open();
				ZDC.addListener(balloon, ZDC.MSGINFO_CLOSE, function (m, l, b, p) { return function () { map.removeWidget(b); appendMarker(m, l, p); }; }(map, latlon, balloon, prefs));
			}

			/* 地図にマーカを表示 */
			function appendMarker (map, latlon, prefs) {
				var icon = new ZDC.Marker(
					latlon,
					{
						color: ZDC.MARKER_COLOR_ID_BLUE_S,
						number: ZDC.MARKER_NUMBER_ID_STAR_S
					}
				);
				map.addWidget(icon);
				if (env.smartDeviceAccess) {
					ZDC.addListener(icon, ZDC.MARKER_MOUSEDOWN, function (m, l, i, p) { return function () { map.removeWidget(i); appendBalloon(m, l, p); }; }(map, latlon, icon, prefs));
				}
			}

			/* Map表示回数ログに書き込む */
			function insertMapLog(options){
				var reqObj = {
					login_id: env.login_id,
					target_id: env.recentQuery.target_id,
					target_type: env.recentQuery.target_type,
					called_api: "",
					request_body: null,
					response_body: null,
					api_status: null,
					current: env.recentQuery.current,
					modalId: env.recentQuery.modalId,
					credential: env.credential,
				};
				for (var key in options) {
					reqObj[key] = options[key];
				}
				c4s.invokeApi_ex({
					location: "manage.insertMapCalledLog",
					body: reqObj,
					pageMove: false,
					newPage: false,
				});
			}

			var preferences = {
				companyName: env.recentQuery.name,
				phoneNumber: env.recentQuery.tel,
				address: env.recentQuery.addr1 + env.recentQuery.addr2,
			};
			var options = {
				address: preferences.address,
				datum: 'TOKYO',
				level: null,
			};
			/* LatLonの取得 */
			var search = new ZDC.Search.getLatLonByAddr(
				options,
				function(status, res) {
					var success = ((status.code === '000') && res &&
					               (typeof res === "object") && res[0]);
					if (!success) {
						insertMapLog({
							called_api: "ZDC.Search.getLatLonByAddr",
							request_body: JSON.stringify(options),
							response_body: res ? JSON.stringify(res) : null,
							api_status: status.code
						});
						alert("該当する住所がありません");
						window.close();
					} else {
						insertMapLog({
							called_api: "ZDC.Search.getLatLonByAddr" ,
							request_body: JSON.stringify(options),
							response_body: JSON.stringify(res),
							api_status: status.code
						});
						preferences.zenrinAddress = res[0].text;
						var mapReq = {
								latlon: res[0].latlon,
								mapType: ZDC.MAPTYPE_TOWNWALK,
								zoom: 10
						};
						var map = new ZDC.Map(
							$("#ZMap").get(0),
							mapReq
						);
						// 地図に縮尺を表示する
						var scalebar = new ZDC.ScaleBar();
						map.addWidget(scalebar);
						if (env.smartDeviceAccess) {
							appendBalloon(map, res[0].latlon, preferences);
						}else {
							// PCには印刷モードのページを表示する
							map.setPrintModeOn();
							$("body").prepend("<div id='parent'></div>");
							$("#parent").prepend("<p>電話番号: " + preferences.phoneNumber + "</p>");
							$("#parent").prepend("<p style='margin-bottom:0px;'>住所: " + preferences.zenrinAddress + "</p>");
							$("#parent").prepend("<p style='margin-bottom:0px;'>会社: " + preferences.companyName + "</p>");
							appendMarker(map, res[0].latlon, preferences);
						}
						insertMapLog({
							called_api: "ZDC.Map",
							request_body: JSON.stringify(mapReq),
							api_status: "OK"
						});
					}
				}
			);
		}
	});
