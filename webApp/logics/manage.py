#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import time
import datetime
import pprint
import traceback

import flask
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

from providers.limitter import Limitter
from base import ProcessorBase
from errors import exceptions as EXC
from models.manage import Manage as Model

from threading import Event, Thread

class Processor(ProcessorBase):
	
	__realms__ = {\
		"top": {\
			"logic": "html_top",\
		},\
		"env": {\
			"logic": "env"\
		},\
		"enumPrefs": {\
			"logic": "enum_prefs",\
		},\
		"reload": {\
			"logic": "reload"\
		},\
		"uwsgi_env": {\
			"logic": "uwsgi_env"\
		},\
		"echo": {\
			"logic": "echo"\
		},\
		"echo_chain_env": {\
			"logic": "echo_chain_env"\
		},\
		"readMailSignature": {\
			"logic": "read_mail_signature",\
		},\
		"writeMailSignature": {\
			"logic": "write_mail_signature",\
		},\
		"writeUseHelp": {
			"logic": "write_use_help",\
		},
		"writeRowLength": {
			"logic": "write_row_length",\
		},
		"updateFlgPublic": {
			"logic": "update_flg_public", \
			},
		"readMailReceiver": {\
			"logic": "read_mail_receiver",\
		},\
		"readMailReplyTo": {\
			"logic": "read_mail_reply_to",\
		},\
		"writeMailReceiver": {\
			"valid_in": "write_mail_receiver_in",\
			"logic": "write_mail_receiver",\
		},\
		"writeMailReplyTo": {\
			"valid_in": "write_mail_reply_to_in",\
			"logic": "write_mail_reply_to",\
		},\
		"readUserProfile": {\
			"logic": "read_user_profile",\
		},\
		"updateUserProfile": {\
			"valid_in": "update_user_profile_in",\
			"logic": "update_user_profile",\
		},\
		"enumAccounts": {\
			"logic": "enum_accounts", \
		}, \
		"enumUserCompanies": { \
				"logic": "enum_user_companies", \
		}, \
		"enumBpCompanies": { \
			"logic": "enum_bp_companies", \
			}, \
		"enumBpCompanyUsers": { \
			"logic": "enum_bp_company_users", \
			}, \
		"createAccount": {\
			"valid_in": "create_user_account_in",\
			"logics": [\
				"check_item_cap",\
				"create_account",\
			],\
		},\
		"updateAccount": {\
			"valid_in": "update_user_account_in",\
			"logic": "update_account",\
		},\
		"deleteAccount": {\
			"valid_in": "delete_user_account_in",\
			"logic": "delete_account",\
		},\
		"unlockAccount": {\
			"valid_in": "unlock_user_account_in",\
			"logic": "unlock_account",\
		}, \
		"createUserCompany": { \
			"valid_in": "create_user_company_in", \
			"logic": "create_user_company", \
			}, \
		"updateUserCompany": { \
			"valid_in": "update_user_company_in", \
			"logic": "update_user_company", \
			}, \
		"enumPrefsById": { \
			"logic": "enum_prefs_by_id", \
			}, \
		"updatePref": { \
			"valid_in": "update_pref_in", \
			"logic": "update_pref", \
			}, \
		"insertMapCalledLog": {\
			"valid_in": "insert_map_called_log_in",\
			"logic": "insert_map_called_log",\
		},\
		"migrateInvoke": {\
			"logic": "migrate_invoke",\
		},\
		"migrateEnumRequests": {\
			"logic": "migrate_enum_requests",\
		},\
		"migrateCancelRequest": {\
			"logic": "migrate_cancel_requests",\
		},\
		"migrateEnumMessages": {\
			"logic": "migrate_enum_messages",\
		}, \
		"setQuotationConfig": { \
			"logic": "set_quotation_config", \
			}, \
		"enumNewInformation": { \
			"logic": "enum_new_information", \
		}, \
		"updateNewInformation": { \
			"logic": "update_new_information", \
		}, \

	}
	
	def _fn_check_item_cap(self, chain_env):
		self.check_limit(chain_env, ("LMT_LEN_ACCOUNT",))
	
	def _fn_html_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		render_param = {}
		from logics.auth import Processor as P_AUTH
		from logics.mail import Processor as P_MAIL
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch signature.
		status_signature, render_param['manage.readMailSignature'] = self._fn_read_mail_signature(chain_env)
		#Fetch profile.
		status_profile, render_param['manage.readUserProfile'] = self._fn_read_user_profile(chain_env)
		#Fetch accounts.
		status_account, render_param['manage.enumAccounts'] = self._fn_enum_accounts(chain_env)
		render_param['js.accounts'] = render_param['manage.enumAccounts']
		# Fetch user_companies.
		status_user_companies, render_param['manage.enumUserCompanies'] = self._fn_enum_user_companies(chain_env)
		render_param['js.companies'] = render_param['manage.enumUserCompanies']
		#Fetch templates.
		status_template, render_param['mail.enumTemplates'] = P_MAIL(self.__pref__)._fn_enum_templates(chain_env)
		#Fetch receivers.
		status_receiver, render_param['manage.readMailReceiver'] = self._fn_read_mail_receiver(chain_env)
		#Fetch reply-to email address.
		status_receiver, render_param['manage.readMailReplyTo'] = self._fn_read_mail_reply_to(chain_env)
		#Fetch preferences.
		status_pref, render_param['manage.enumPrefs'] = self._fn_enum_prefs(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[begin] Support objects.
		render_param['manage.enumPrefsDict'] = {}
		[render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
		status_information, render_param['manage.information'] = self._fn_enum_new_information(chain_env)
		#[end] Support objects.
		chain_env['response_body'] = flask.render_template(\
			"manage.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"設定|SESクラウド",\
			current="manage.top")
		chain_env['logger']("webhtml", ("END", None))

		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_unlock_account(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential'],\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("unlock_user_account") % ", ".join(map(str, set(args['id_list']))), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)
				dbcur.execute(Model.sql("last_insert_id"))
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_delete_account(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential'],\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("delete_user_account") % ", ".join(map(str, set(args['id_list']))), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)
				dbcur.execute(Model.sql("last_insert_id"))
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_create_account(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
				args['name'], args['new_login_id'], args['password'], args['mail1'],\
				args['tel1'] if "tel1" in args else "",\
				args['tel2'] if "tel2" in args else "",\
				args['fax'] if "fax" in args else "",\
				args['is_admin'] if "is_admin" in args else False,\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("create_user_account"), param)
			except Exception, err:
				dbcon.rollback()
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				dbcur.execute(Model.sql("last_insert_id"))
				chain_env['results'] = Model.convert("last_insert_id", dbcur)
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_update_account(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			ACCEPTABLE_COLS = ("mail1", "tel1", "tel2", "fax", "is_locked", "is_admin", "is_enabled")
			cols = [k for k in sorted(args.keys()) if k in ACCEPTABLE_COLS]
			vals = [args[k] for k in cols]
			param = \
				[args['password'] if "password" in args and args['password'] else None, args['password'] if "password" in args else None] +\
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[args['id']] +\
				[chain_env['prefix'], args['login_id']]
			if cols:
				try:
					dbcur.execute(Model.sql("update_user_account") % ",\n    ".join(map(lambda x: "`%s` = %%s" % x, cols)), param)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					chain_env['status']['code'] = 2
				else:
					pprint.pprint(dbcur._executed)
					dbcon.commit()
					chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_read_user_profile(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = None
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("read_user_profile"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				result = Model.convert("read_user_profile", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_update_user_profile(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			ACCEPTABLE_COLS = ("mail1", "tel1", "tel2", "fax")
			cols = [k for k in sorted(args.keys()) if k in ACCEPTABLE_COLS]
			vals = [args[k] for k in cols]
			param = \
				[args['password'] if "password" in args and args['password'] else None, args['password'] if "password" in args else None] +\
				[args['is_admin'] if "is_admin" in args else None, args['is_admin'] if "is_admin" in args else None] +\
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[chain_env['prefix'], args['login_id'], args['credential']]
			if cols:
				try:
					dbcur.execute(Model.sql("update_user_profile") % ",\n    ".join(map(lambda x: "`%s` = %%s" % x, cols)), param)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					chain_env['status']['code'] = 2
				else:
					dbcon.commit()
					chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_prefs(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = None
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("enum_prefs"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				result = Model.convert("enum_prefs", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
			# Fetch statistics.
			status_count, result_count = Limitter.count_records(self.__pref__, chain_env)
			for lk in result_count:
				for res in result:
					if res['key'] == lk:
						res['current'] = result_count[lk]
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_prefs_by_id(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = None
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = ( \
				args['id'], chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("enum_prefs_by_id"), param)
				print Model.sql("enum_prefs_by_id")
				print param
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				result = Model.convert("enum_prefs", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
			# Fetch statistics.
			status_count, result_count = Limitter.count_records(self.__pref__, chain_env)
			for lk in result_count:
				for res in result:
					if res['key'] == lk:
						res['current'] = result_count[lk]
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_update_pref(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data

			try:
				param = (args['max_account'], args['id'], 'LMT_LEN_ACCOUNT', args['login_prefix'], chain_env['login_id'],
						 chain_env['credential'],)
				dbcur.execute(Model.sql("update_pref"), param)
				dbcur.execute(Model.sql("update_pref_sub"), param)
				print Model.sql("update_pref")
				print param
				print Model.sql("update_pref_sub")
				print param
				param = (args['max_client'], args['id'], 'LMT_LEN_CLIENT', args['login_prefix'], chain_env['login_id'],
						 chain_env['credential'],)
				dbcur.execute(Model.sql("update_pref"), param)
				dbcur.execute(Model.sql("update_pref_sub"), param)
				param = (args['max_worker'], args['id'], 'LMT_LEN_WORKER', args['login_prefix'], chain_env['login_id'],
						 chain_env['credential'],)
				dbcur.execute(Model.sql("update_pref"), param)
				dbcur.execute(Model.sql("update_pref_sub"), param)
				param = (args['max_project'], args['id'], 'LMT_LEN_PROJECT', args['login_prefix'], chain_env['login_id'],
						 chain_env['credential'],)
				dbcur.execute(Model.sql("update_pref"), param)
				dbcur.execute(Model.sql("update_pref_sub"), param)
				param = (args['max_engineer'], args['id'], 'LMT_LEN_ENGINEER', args['login_prefix'], chain_env['login_id'],
						 chain_env['credential'],)
				dbcur.execute(Model.sql("update_pref"), param)
				dbcur.execute(Model.sql("update_pref_sub"), param)
				param = (args['max_mail_tpl'], args['id'], 'LMT_LEN_MAIL_TPL', args['login_prefix'], chain_env['login_id'],
						 chain_env['credential'],)
				dbcur.execute(Model.sql("update_pref"), param)
				dbcur.execute(Model.sql("update_pref_sub"), param)

			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
				print "Exception:" + traceback.format_exc(err)
			else:
				pprint.pprint(dbcur._executed)
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_read_mail_receiver(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = None
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("read_mail_receiver"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				result = Model.convert("read_mail_receiver", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_read_mail_reply_to(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = None
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("read_mail_reply_to"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				result = Model.convert("read_mail_reply_to", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_write_mail_receiver(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param1 = (\
				chain_env['prefix'], args['login_id'], args['credential'],\
				"MAIL_RECEIVER_CC", JSON.dumps(args['cc']), JSON.dumps(args['cc'])\
			)
			param2 = (\
				chain_env['prefix'], args['login_id'], args['credential'],\
				"MAIL_RECEIVER_BCC", JSON.dumps(args['bcc']), JSON.dumps(args['bcc'])\
			)
			try:
				dbcur.execute(Model.sql("write_mail_receiver"), param1)
				dbcur.execute(Model.sql("write_mail_receiver"), param2)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				try:
					chain_env['trace'].append(dbcur._executed)
				except:
					pass
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		from providers.limitter import Limitter
		Limitter.refresh_settings(chain_env)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_write_mail_reply_to(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				chain_env['prefix'], args['login_id'], args['credential'],\
				"MAIL_REPLY_TO", JSON.dumps(args['replyTo']), JSON.dumps(args['replyTo'])\
			)
			try:
				dbcur.execute(Model.sql("write_mail_reply_to"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				try:
					chain_env['trace'].append(dbcur._executed)
				except:
					pass
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		from providers.limitter import Limitter
		Limitter.refresh_settings(chain_env)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_read_mail_signature(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = {}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("read_mail_signature"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				result = Model.convert("read_mail_signature", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_write_mail_signature(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			
			param = (\
				args['value'],\
				args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("write_mail_signature"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				try:
					chain_env['trace'].append(dbcur._executed)
				except:
					pass
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		from providers.limitter import Limitter
		Limitter.load_settings(chain_env)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_write_use_help(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			
			param = (\
				args['value'],\
				args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("write_use_help"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				try:
					chain_env['trace'].append(dbcur._executed)
				except:
					pass
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		from providers.limitter import Limitter
		Limitter.load_settings(chain_env)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_write_row_length(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			
			param = (\
				args['value'],\
				args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("write_row_length"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				try:
					chain_env['trace'].append(dbcur._executed)
				except:
					pass
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		from providers.limitter import Limitter
		Limitter.load_settings(chain_env)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_update_flg_public(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			print "_fn_update_flg_public !!"
			param = ( \
				args['value'], \
				args['prefix'], args['login_id'], args['credential'], \
				)
			try:
				dbcur.execute(Model.sql("update_flg_public"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				try:
					chain_env['trace'].append(dbcur._executed)
				except:
					print err
					pass
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_enum_accounts(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			param = (\
				chain_env['prefix'], chain_env['login_id']\
			)
			try:
				dbcur.execute(Model.sql("enum_user_accounts"), param)
				#self.my_log("__enum_user_accounts"+Model.sql("enum_user_accounts"))
				#import json as JSON
				#self.my_log("__param"+JSON.dumps(param))
			except Exception, err:
				self.my_log(traceback.format_exc(err))
			else:
				chain_env['trace'].append(dbcur._executed)
				result = Model.convert("enum_user_accounts", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		return status, result

	def _fn_enum_user_companies(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			param = (\
				chain_env['prefix'], chain_env['login_id']\
			)
			try:
				dbcur.execute(Model.sql("enum_user_companies"))
				result = Model.convert("enum_user_companies", dbcur)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				self.my_log(traceback.format_exc(err))
				status['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 0

			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		return status, result

	def _fn_create_user_company(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = ( \
				args['name'], args['owner_name'], \
				args['tel'] if "tel" in args else "", \
				args['fax'] if "fax" in args else "", \
				args['addr_vip'], args['addr1'], args['addr2'], \
				args['prefix'], args['dt_use_begin'], args['dt_use_end'], \
				)
			param2 = ( \
				args['admin_name'], \
				args['admin_login_id'], \
				args['admin_password'], \
				args['admin_mail'], \
				args['admin_tel'], \
				args['login_prefix'], chain_env['login_id'], chain_env['credential'], \
				)
			try:
				dbcur.execute(Model.sql("create_user_company"), param)
				dbcur.execute(Model.sql("set_last_insert_company_id"))
				dbcur.execute(Model.sql("create_user_group"))
				dbcur.execute(Model.sql("set_last_insert_group_id"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_ACT_MAIL", "true"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_ACT_MAP", "false"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_CLIENT", "5000"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_WORKER", "5000"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_PROJECT", "1000"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_ENGINEER", "1000"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_ACCOUNT", "3"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_MAIL_TPL", "18"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_MAIL_ATTACHMENT", "6"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_MAIL_PER_DAY", "0"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_MAIL_PER_MONTH", "0"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_SIZE_BIN", "3145728"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "LMT_LEN_STORE_DATE", "30"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "MAIL_RECEIVER_CC", "[]"))
				dbcur.execute(Model.sql("call_renew_pref"), (args['prefix'], "MAIL_RECEIVER_BCC", "[]"))

				dbcur.execute(Model.sql("create_admin_account"), param2)
				dbcur.execute(Model.sql("set_last_insert_account_id"))
				dbcur.execute(Model.sql("init_account_mail_template"))

			except Exception, err:
				dbcon.rollback()
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
				print "Exception:" + traceback.format_exc(err)
			else:
				dbcon.commit()
				dbcur.execute(Model.sql("last_insert_id"))
				chain_env['results'] = Model.convert("last_insert_id", dbcur)
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_update_user_company(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = ( \
				args['name'], args['owner_name'], \
				args['tel'] if "tel" in args else "", \
				args['fax'] if "fax" in args else "", \
				args['addr_vip'], args['addr1'], args['addr2'], \
				args['prefix'], args['dt_use_begin'], args['dt_use_end'], \
				args['is_enabled'], args['id'], \
				args['login_prefix'], chain_env['login_id'], chain_env['credential'], \
				)
			param2 = ( \
				args['id'], args['id'], \
				args['login_prefix'], chain_env['login_id'], chain_env['credential'], \
				)
			try:
				dbcur.execute(Model.sql("update_user_company"), param)
				dbcur.execute(Model.sql("update_user_company_cap_id"), param2)
				dbcur.execute(Model.sql("update_user_company_cap_id_sub"), param2)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
				print "Exception:" + traceback.format_exc(err)
			else:
				pprint.pprint(dbcur._executed)
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_bp_companies(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			param = (chain_env['prefix'], )
			dbcur.execute(Model.sql("enum_bp_companies"), param)
			chain_env['trace'].append(dbcur._executed)
			result = Model.convert("enum_bp_companies", dbcur)
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		return status, result

	def _fn_enum_bp_company_users(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			param = (chain_env['prefix'], )
			dbcur.execute(Model.sql("enum_bp_company_users"), param)
			chain_env['trace'].append(dbcur._executed)
			result = Model.convert("enum_bp_company_users", dbcur)
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		return status, result

	def _fn_env(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		res_dict = {}
		[res_dict.update({"flask.request.%s" % k: getattr(flask.request, k) if isinstance(getattr(flask.request, k), basestring) else type(getattr(flask.request, k))}) for k in dir(flask.request)]
		res_dict['flask.request.environ'] = {}
		[res_dict['flask.request.environ'].update({k: flask.request.environ[k] if isinstance(flask.request.environ[k], basestring) else repr(flask.request.environ[k])}) for k in flask.request.environ]
		res_dict['flask.request.files'] = {}
		res_dict['flask.request.files'] = {}
		[res_dict['flask.request.files'].update({f: {\
			"filename": flask.request.files[f].filename,\
			"name": flask.request.files[f].name,\
			"content_type": flask.request.files[f].content_type,\
			"content_length": flask.request.files[f].content_length,\
			"mimetype": flask.request.files[f].mimetype,\
			"mimetype_params": flask.request.files[f].mimetype_params,\
			"headers": flask.request.files[f].headers,\
			"stream": flask.request.files[f].stream,\
		}}) for f in flask.request.files]
		res_dict['flask.request.form'] = repr(flask.request.form)
		res_dict['flask.request.cookies'] = repr(flask.request.cookies)
		res_dict['chain_env'] = {}
		res_dict['chain_env']['argument.data'] = chain_env['argument'].data
		chain_env['results'] = res_dict
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_reload(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		try:
			import uwsgi
		except ImportError:
			EXC.DeployError("This method allowed on uWSGI container ONLY.", 1001)
		else:
			uwsgi.reload()
			chain_env['results'] = "uWSGI application has been reloaded gracefully."
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_uwsgi_env(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		try:
			import uwsgi
		except ImportError:
			EXC.DeployError("This method allowed on uWSGI container ONLY.", 1001)
		else:
			chain_env['result'] = dir(uwsgi)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_echo(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		chain_env['results'] = chain_env['argument'].data
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_echo_chain_env(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		import copy
		chain_env['results'] = copy.deepcopy(chain_env)
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_insert_map_called_log(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		chain_env['logger'].map_called(chain_env, "webapi")
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_migrate_invoke(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		from logics.auth import Processor as P_AUTH
		#Fetch user profile.
		status_profile, user_profile = P_AUTH(self.__pref__).read_user_profile(chain_env)
		result = ""
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = {\
				"prefix": chain_env['prefix'],\
				"login_id": args['login_id'],\
				"credential": args['credential'],\
				"attachment": args['attachment'],\
				"memo": args['memo'],\
			}
			for stmt in Model.sql("migrate_invoke"):
				try:
					dbcur.execute(stmt, param)
				except:
					chain_env['trace'].append(stmt)
					chain_env['trace'].append(traceback.format_exc())
					pprint.pprint(traceback.format_exc())
					status['code'] = 2
					dbcon.rollback()
					break
			try:
				dbcon.commit()
			except:
				pass
			else:
				import subprocess
				import shlex
				prod_level = flask.request.environ['PROD_LEVEL']
				dbcur.execute(Model.sql("migrate_invoked_tr_id"))
				tr_id = dbcur.fetchone()[0]
				schedule = datetime.datetime.now()
				schedule = schedule + datetime.timedelta(0, 0, 60)
				cmdline = '''echo "/usr/local/bin/python %s -p %s -t %s -s validate" | at "%s"''' % (self.__pref__['DATA_MIGRATE_CMD'], prod_level, tr_id, schedule.strftime("%H:%M %d.%m.%y"),)
				#subprocess.Popen(shlex.split(cmdline))
				import os
				os.system(cmdline)
			finally:
				#[begin] Mail to Goodworks and Maintainer addresses.
				import email.utils
				from email import encoders
				from email.header import Header
				from email.message import Message
				from email.Header import Header
				from email.Utils import formatdate
				from email.mime.base import MIMEBase
				from email.mime.multipart import MIMEMultipart
				from email.mime.text import MIMEText
				import smtplib
				from jinja2 import Environment
				# generate attachment part.
				dbcur.execute(Model.sql("migrate_fetch_attachment"), {"attachment_id": param['attachment']})
				atmt_mime, atmt_name, atmt_value = dbcur.fetchone()
				dbcon.close()
				attachment_obj = MIMEBase(*(tuple(atmt_mime.split("/"))))
				attachment_obj.add_header('Content-Disposition', 'attachment', filename=Header(atmt_name, self.__pref__['MAIL_CHARSET']).encode())
				attachment_obj.set_payload(atmt_value)
				encoders.encode_base64(attachment_obj)
				render_param = {\
					"client_name": user_profile['company']['name'],\
					"worker_name": user_profile['user']['name'],\
					"transaction_id": tr_id,\
					"filename": atmt_name,\
					"filesize": len(atmt_value),\
					"memo": args['memo'],\
					"status": u"受理",\
				}
				# for User.
				context = self.__pref__['DATA_MIGRATE_MAIL']['user']
				msg = MIMEMultipart()
				msg['Subject'] = Header(Environment().from_string(context['subject']).render(**render_param), self.__pref__['MAIL_CHARSET'])
				msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
				msg['To'] = email.utils.formataddr((Header(user_profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), user_profile['user']['mail1']))
				msg['Date'] = formatdate(localtime=True)
				msg.attach(MIMEText(Environment().from_string(context['body_tpl']).render(**render_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET']))
				msg_pack_1 = user_profile['user']['mail1'], msg
				# for Goodworks.
				context = self.__pref__['DATA_MIGRATE_MAIL']['owner']
				msg = MIMEMultipart()
				msg['Subject'] = Header(Environment().from_string(context['subject']).render(**render_param), self.__pref__['MAIL_CHARSET'])
				msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
				msg['To'] = email.utils.formataddr((Header(context['to']['name'], self.__pref__['MAIL_CHARSET']).encode(), context['to']['mail']))
				msg['Date'] = formatdate(localtime=True)
				msg.attach(MIMEText(Environment().from_string(context['body_tpl']).render(**render_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET']))
				msg.attach(attachment_obj)
				msg_pack_2 = context['to']['mail'], msg
				# for Maintainer.
				context = self.__pref__['DATA_MIGRATE_MAIL']['admin']
				msg = MIMEMultipart()
				msg['Subject'] = Header(Environment().from_string(context['subject']).render(**render_param), self.__pref__['MAIL_CHARSET'])
				msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
				msg['To'] = email.utils.formataddr((Header(context['to']['name'], self.__pref__['MAIL_CHARSET']).encode(), context['to']['mail']))
				msg['Date'] = formatdate(localtime=True)
				msg.attach(MIMEText(Environment().from_string(context['body_tpl']).render(**render_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET']))
				msg_pack_3 = context['to']['mail'], msg
				# send mails.
				svr = smtplib.SMTP()
				svr.connect("localhost")
				svr.set_debuglevel(0)
				for recipient, msg in (msg_pack_1, msg_pack_2, msg_pack_3,):
					svr.sendmail("noreply@si-cloud.jp", recipient, msg.as_string())
				#[end] Mail to Goodworks and Maintainer addresses.
		status['code'] = status['code'] or 0
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_migrate_enum_requests(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = {\
				"prefix": chain_env['prefix'],\
				"login_id": args['login_id'],\
				"credential": args['credential'],\
			}
			try:
				dbcur.execute(Model.sql("migrate_enum_requests"), param)
			except:
				chain_env['trace'].append(traceback.format_exc())
				pprint.pprint(traceback.format_exc())
				status['code'] = 2
			else:
				result = Model.convert("migrate_enum_requests", dbcur)
				status['code'] = 0
			finally:
				dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_migrate_cancel_requests(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = {\
				"prefix": chain_env['prefix'],\
				"login_id": args['login_id'],\
				"credential": args['credential'],\
				"transaction_id": args['tr_id'],\
			}
			try:
				dbcur.execute(Model.sql("migrate_cancel_request"), param)
			except Exception, err:
				dbcon.rollback()
				chain_env['trace'].append(traceback.format_exc())
				pprint.pprint(dbcur._executed)
				pprint.pprint(traceback.format_exc())
				status['code'] = 0
				status['description'] = u"キャンセルできませんでした。" if dbcur.rowcount != 1 else None
			else:
				dbcon.commit()
				result = Model.convert("migrate_enum_requests", dbcur)
				status['code'] = 0
				if args['status'] in (u"検証中", u"検証済", u"本投入待機"):
					try:
						for stmt in Model.sql("migrate_drop_tmp_tables"):
							try:
								dbcur.execute(stmt % args['tr_id'])
							except Exception, err:
								if err.args[0] == 1051L:
									status['code'] = 0
					except:
						chain_env['trace'].append(traceback.format_exc())
						pprint.pprint(traceback.format_exc())
						status['code'] = 2
						status['description'] = u"一時テーブルの削除に失敗しました。"
					else:
						dbcon.commit()
			finally:
				dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_migrate_enum_messages(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = {\
				"prefix": chain_env['prefix'],\
				"login_id": args['login_id'],\
				"credential": args['credential'],\
				"transaction_id": args['tr_id'],\
			}
			try:
				dbcur.execute(Model.sql("migrate_enum_messages"), param)
			except:
				chain_env['trace'].append(traceback.format_exc())
				pprint.pprint(traceback.format_exc())
				status['code'] = 2
			else:
				result = Model.convert("migrate_enum_messages", dbcur)
				status['code'] = 0
			finally:
				dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg


	def _fn_set_quotation_config(self, chain_env):
		time_bg = time.time()
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			conflicts = set()
			deleted = set()
			if "company_seal" not in args:
				args['company_seal'] = None
			if "company_version" not in args:
				args['company_version'] = None
			param1 = (chain_env['prefix'],)
			param2 = (chain_env['prefix'],args['company_seal'],args['company_version'], \
					  args['bank_account1'], \
					  args['bank_account2'], \
					  args['estimate_charging_user_id'] if args['estimate_charging_user_id'] else None, \
					  args['order_charging_user_id'] if args['order_charging_user_id'] else None, \
					  args['purchase_charging_user_id'] if args['purchase_charging_user_id'] else None, \
					  args['invoice_charging_user_id'] if args['invoice_charging_user_id'] else None, \
					  )
			try:
				dbcur.execute(Model.sql("delete_mt_quotation_config"), param1)
				dbcur.execute(Model.sql("insert_mt_quotation_config"), param2)
			except Exception, err:
				chain_env['trace'].append(err)
				chain_env['status']['code'] = 2
				print err
			else:
				deleted.add(param1)

			dbcon.commit() if deleted else None
			chain_env['results'] = {"conflicts": tuple(conflicts), "deleted": tuple(deleted)}
			chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", chain_env['argument'].data)
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_enum_new_information(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = 0
		status = {"code": None, "description": None}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			try:
				dbcur.execute(Model.sql("enum_new_information"))
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				result = Model.convert("enum_new_information", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_update_new_information(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				args['value'],\
				args['id'],\
			)
			try:
				dbcur.execute(Model.sql("update_new_information"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				try:
					chain_env['trace'].append(dbcur._executed)
				except:
					pass
				chain_env['status']['code'] = 2
			else:
				dbcon.commit()
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)