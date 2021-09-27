<!DOCTYPE HTML>
{% if env.prod_level != "prod" -%}
	{% set API_URL = "http://test.api.its-mo.com/cgi/loader.cgi?key=" + data['zenrin_id'] + "&ver=2.0&api=zdcmap.js,search.js&force=1&alert=1" -%}
{% else -%}
	{% set API_URL = "http://api.its-mo.com/cgi/loader.cgi?key=" + data['zenrin_id'] + "&ver=2.0&api=zdcmap.js,search.js&force=1" -%}
{% endif -%}
{% set SMART_DEVICE = ("Android" in env.UA) or ("iPhone" in env.UA) %}
{% if SMART_DEVICE -%}
	{% set ZMAP_CSS = "width:100%; height:100%;" -%}
{% else -%}
	{% set ZMAP_CSS = "border:1px solid #777777; width:700px; height:1000px;" -%}
{% endif -%}
<html lang = "ja">
	{% include "cmn_head.tpl" %}
	<body>
		<script type="text/javascript" src="{{ API_URL }}"></script>
		<div id="ZMap" style="{{ ZMAP_CSS }}"></div>
{% include "cmn_debug_vars.tpl" %}
{% include "cmn_footer.tpl" %}
		<script type="text/javascript">
			env.mapCalledCount = {{ data['limit.count_records']['LMT_CALL_MAP_EXTERN_M'] }};
			env.smartDeviceAccess = {% if SMART_DEVICE %}true{% else %}false{% endif %};
		</script>
		<script type="text/javascript" src="/js/map.js"></script>
	</body>
</html>
