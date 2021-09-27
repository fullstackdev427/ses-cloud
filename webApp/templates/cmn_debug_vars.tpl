			{% if env['prod_level'] == "develop" %}
			<div class="container" style="clear: both;">
(chain_env['logic'] + chain_env['realm']) as current:
<pre>
{{ current }}
</pre>
chain_env['argument'].data as query:
<pre><code>{{ query|pprint(verbose=True)|e }}</code></pre>
chain_env['trace'] as trace:
<pre>
{% if trace %}
{% for item in trace %}
{{ loop.index }}:
{{ item|e }}
{% endfor %}
{% endif %}
</pre>
result as data:
<pre>
{{ data|pprint(verbose=True)|e }}
</pre>
chain_env as env:
<pre>
prefix: {{ env['prefix']|e }}
login_id: {{ env['login_id']|e }}
credential: {{ env['prefix']|e }}
UA: {{ env['UA']|e }}
performance: {{ env['performance']|pprint(verbose=True)|e }}
prod_level: {{ env['prod_level']|e }}
logic: {{ env['logic']|e }}
realm: {{ env['realm']|e }}
limit: {{ env['limit']|pprint(verbose=True)|e }}
argument: {{ env['argument'].data|pprint(verbose=True)|e }}
http_status: {{ env['http_status']|e }}
status: {{ env['status']|pprint(verbose=True)|e }}
mime: {{ env['mime']|e }}
headers: {{ env['headers']|pprint(verbose=True)|e }}
</pre>
			</div>
			{% endif %}
