#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides authentication logics.
"""


import time
import datetime
import hashlib
import traceback

import werkzeug
import flask

from validators.base import ValidatorBase as Validator
from models.auth import Auth as Model
from base import ProcessorBase
from errors import exceptions as EXC

class Processor(ProcessorBase):
	
	"""
		This method is selector of functions which is members of the method chain, contains:
			preludium   : validation-input.(if need)
			main logic  : _fn_ functions.(must)
			postludium  : validation-output.(if need)
	"""
	
	__realms__ = {\
		"home": {\
			"logic": "html_home",\
		},\
		"logout": {\
			"logic": "html_logout",\
		},\
		"login": {\
			"valid_in": "login_in",\
			"logic": "login",\
			"valid_out": None\
		},\
	}
	
	def _fn_html_home(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		status['code'] = 0
		from logics.auth import Processor as P_AUTH
		from logics.manage import Processor as P_MANAGE
		from logics.project import Processor as P_PROJECT
		from logics.engineer import Processor as P_ENGINEER

		cookie = None
		login_id = None
		if "cred" in flask.request.cookies:
			cookie = flask.request.cookies['cred']
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			#Fetch user profile.
			status_profile, result['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
			try:
				dbcur.execute(Model.sql("fetch_login_id"), (chain_env['prefix'], cookie))
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
			else:
				tmp = dbcur.fetchone()
				cookie = tmp[0] if tmp else None

		render_param = {}
		status_project, render_param['project.countProject'] = P_PROJECT(self.__pref__)._fn_last_three_days(chain_env)
		status_engineer, render_param['engineer.countEngineer'] = P_ENGINEER(self.__pref__)._fn_last_three_days(chain_env)
		status_information, render_param['manage.information'] = P_MANAGE(self.__pref__)._fn_enum_new_information(chain_env)
		chain_env['response_body'] = flask.render_template(
			"login.tpl",\
			env=chain_env,\
			login_id = login_id,\
			data = render_param,\
			title=u"ログイン|SESクラウド"\
		)
		chain_env['status'] = status
		self.perf_time(chain_env, time.time() - time_bg)
		chain_env['logger']("webhtml", ("END", None))
		return status, result

	def _fn_html_logout(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		result = None
		status = {"code": None, "description": None}
		login_id = None
		if "cred" in flask.request.cookies:
			cookie = flask.request.cookies['cred']
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			try:
				dbcur.execute(Model.sql("logout"), (chain_env['prefix'], chain_env['login_id'], chain_env['credential'], chain_env['login_id'], chain_env['credential'],))
			except Exception, err:
				dbcon.rollback()
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
			else:
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['status']['code'] = 11
		self.perf_time(chain_env, time.time() - time_bg)
		chain_env['logger']("webhtml", ("END", None))
		return status, result

	def _fn_login(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = None
		status = {"code": None, "description": None}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			#↓要検証
			#param = (chain_env['prefix'], args['login_id'], hashlib.md5(args['password']).hexdigest())
			#param = (args['login_id'], hashlib.md5(args['password']).hexdigest(), chain_env['prefix'])
			#sql_tmp = str(Model.sql("login"), param)
			sql_tmp = str(Model.sql("login"))
			sql_tmp = sql_tmp.replace('rep1', args['login_id'])
			sql_tmp = sql_tmp.replace('rep2', hashlib.md5(args['password']).hexdigest())
			sql_tmp = sql_tmp.replace('rep3', chain_env['prefix'])
			new_credential = ""
			try:
				dbcur.execute(sql_tmp)
				chain_env['trace'].append(dbcur._executed)
			except Exception, err:
				print dbcur._executed
				dbcon.rollback()
				chain_env['trace'].append(err)
				status['code'] = 2
			else:
				result = Model.convert("login", dbcur)
				if len(result) == 0:
					dbcon.rollback()
					status['code'] = 4
					#status['description'] = u"ログインに失敗しました"
					print "code:4", dbcur._executed
				else:
					sql_tmp = str(Model.sql("update_cred"))
					sql_tmp = sql_tmp.replace('rep1', str(result[0]['cred']))
					sql_tmp = sql_tmp.replace('rep2', str(result[0]['id']))
					new_credential = str(result[0]['cred'])
					chain_env['trace'].append(sql_tmp)
					try:
						dbcur.execute(sql_tmp)
						#↓要検証
						#param = (str(result[0]['cred']), str(result[0]['id']))
						#dbcur.execute(Model.sql("update_cred"), param)
						chain_env['trace'].append(dbcur._executed)
						#new_credential = dbcur.fetchone()[0]
					except Exception, err:
						print dbcur._executed
						dbcon.rollback()
						chain_env['trace'].append(err)
						status['code'] = 2
					else:
						if new_credential is None:
							dbcon.rollback()
							status['code'] = 4
							#status['description'] = u"ログインに失敗しました"
							print "code:4", dbcur._executed
						else:
							dbcon.commit()
							try:
								dbcur.execute(Model.sql("read_user_profile"), (chain_env['prefix'], chain_env['login_id']))
							except Exception, err:
								chain_env['trace'].append(traceback.format_exc(err))
								status['code'] = 8
								#status['description'] = u"ユーザー情報の取得に失敗しました"
							else:
								result = Model.convert("user_profile", dbcur)
								import json as JSON
								result['user']['credential'] = new_credential
								status['code'] = 0
								chain_env['credential'] = new_credential
								chain_env['headers']['Set-Cookie'] = werkzeug.dump_cookie(\
									"cred",\
									value=new_credential,\
									max_age=chain_env['conf']['REDIS_AUTH_TTL'],\
									expires=datetime.datetime.now() + datetime.timedelta(seconds=chain_env['conf']['REDIS_AUTH_TTL']),\
									path="/%s/" % chain_env['prefix'])
			dbcon.close()
			chain_env['results']['%s.%s' % (chain_env['logic'], chain_env['realm'])] = result
			chain_env['status']['code'] = status['code']
			chain_env['status']['description'] = status['description']
		self.perf_time(chain_env, time.time() - time_bg)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status'], chain_env['headers']))
		return status, result
	
	def read_user_profile(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = None
		status = {"code": None, "description": None}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
			status['code'] = 5
		if dbcur:
			try:
				dbcur.execute(Model.sql("read_user_profile"), (chain_env['prefix'], chain_env['login_id']))
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				status['code'] = 8
			else:
				chain_env['trace'].append(dbcur._executed)
				result = Model.convert("user_profile", dbcur)
		self.perf_time(chain_env, time.time() - time_bg)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		return status, result
		

	
def auth_cache_key(prefix, login_id):
	return "%s_%s" % (prefix, login_id)