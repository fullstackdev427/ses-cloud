#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

try:
	import ujson as JSON
except ImportError:
	try:
		import czjson as JSON
	except ImportError:
		try:
			import json as JSON
		except ImportError:
			try:
				import simplejson as JSON
			except ImportError:
				raise EXC.DeployError("No JSON module has been found.", 1001)

from serialize import SerializerBase
from errors import exceptions as EXC
from errors.status import Status

class JsonSerializer(SerializerBase):
	
	"""
		This class provides JSONize functionality.
	"""
	def marshall(self, chain_env):
		chain_env['status']['code'] = 0 if chain_env['status']['code'] is None else chain_env['status']['code']
		if chain_env['status']['code'] == 12:
			code = int(chain_env['status']['description'])
			desc = Status.desc(code)
			chain_env['response_body'] = "%s (ERR_CODE:%d)"%(desc, code)
			chain_env['mime'] = "text/plain"
			chain_env['headers']['Content-type'] = "text/plain; charset=UTF-8"
		else:
			chain_env['status']['description'] = chain_env['status']['description'] or Status.desc(chain_env['status']['code'])
			chain_env['response_body'] = JSON.dumps({\
				"credential": chain_env['credential'],\
				"entity": {\
					"logic": chain_env['logic'],\
					"realm": chain_env['realm']\
				},\
				"status": chain_env['status'],\
				"trace": chain_env['trace'] if "trace" in chain_env else [],\
				"validate": chain_env['validate'] if "validate" in chain_env else {},\
				"data": chain_env['results'] if "results" in chain_env else None
			})
			chain_env['mime'] = "application/json"
			chain_env['headers']['Content-type'] = "application/json; charset=UTF-8"