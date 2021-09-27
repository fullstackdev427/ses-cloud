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

import flask

from serialize import SerializerBase
from errors import exceptions as EXC
from errors.status import Status

class HtmlRenderer(SerializerBase):
	
	"""
		This class provides rendering template functionality.
	"""
	def marshall(self, chain_env):
		chain_env['mime'] = "text/html"
		chain_env['headers']['Content-type'] = "text/html; charset=UTF-8"
		chain_env['status']['code'] = 0 if chain_env['status']['code'] is None else chain_env['status']['code']
		if chain_env['status']['code'] == 0:
			if not chain_env['response_body']:
				chain_env['status']['code'] = 1
				self.render_errorpage(chain_env)
			else:
				pass
		elif chain_env['status']['code'] == 11:
			# for redirect
			chain_env['headers']['Location'] = flask.request.host_url + chain_env['prefix'] + "/html/"
		else:
			self.render_errorpage(chain_env)
		chain_env['http_status'] = chain_env['http_status'] if chain_env['http_status'] else Status.http_status(chain_env['status']['code'])
	
	def render_errorpage(self, chain_env):
		from logics.manage import Processor as P_MANAGE
		from logics.project import Processor as P_PROJECT
		from logics.engineer import Processor as P_ENGINEER
		chain_env['status']['description'] = chain_env['status']['description'] or Status.desc(chain_env['status']['code'])
		render_param = {}
		status_project, render_param['project.countProject'] = P_PROJECT(self.__pref__)._fn_last_three_days(chain_env)
		status_engineer, render_param['engineer.countEngineer'] = P_ENGINEER(self.__pref__)._fn_last_three_days(chain_env)
		status_information, render_param['manage.information'] = P_MANAGE(self.__pref__)._fn_enum_new_information(chain_env)
		chain_env['response_body'] = flask.render_template(\
			"login.tpl",\
			env=chain_env,\
			data=render_param,\
			title=u"エラーページ|SESクラウド")

