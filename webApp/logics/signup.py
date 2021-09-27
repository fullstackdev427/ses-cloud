#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides Sign up logics.
"""

import time
import copy
import datetime
import hashlib
import re
import random
import traceback
import pprint

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
from providers import sixtytwo as N62
from validators.base import ValidatorBase as Validator
from models.signup import Signup as Model
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
		"r": {\
			"logic": "html_r",\
		},\
		"company": {\
			"logic": "html_company",\
		},\
		"user": {\
			"logic": "html_user",\
		},\
		"resetpwd": {\
			"logic": "resetpwd",\
		},\
		"adduser": {\
			"logic": "adduser",\
		},\
		"flushpwd": {\
			"logic": "html_flushpwd",\
		},\
		"setpwd": {\
			"logic": "setpwd",\
		},\
		"freemium": {\
			"logic": "html_freemium",\
		},\
	}
	
	def _fn_html_r(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		unique_code = flask.request.args.get("inv", "")
		query = {}
		location = ""
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			try:
				dbcur.execute(Model.sql("load_invitation"), {"unique_code": unique_code,})
			except:
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
			else:
				query = Model.convert("load_invitation", dbcur)
		query['step'] = query['step'] if "step" in query else "input"
		if query and "type_signup" in query and query['type_signup'] in ("ADD_COMPANY", "ADD_USER", "RESET_PWD"):
			if query['type_signup'] == "ADD_COMPANY":
				location = "signup.company"
			elif query['type_signup'] == "ADD_USER":
				location = "signup.user"
			elif query['type_signup'] == "RESET_PWD":
				location = "signup.flushpwd"
			else:
				unique_code = None
		render_param = {
			"unique_code": unique_code,\
			"location": location,\
			"parameter": query,\
		}
		chain_env['response_body'] = flask.render_template(\
			"signup_context_switcher.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"サインアップ|SESクラウド",\
		)
		chain_env['status'] = {\
			"code": 0,\
			"description": "OK",\
		}
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_html_company(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		chain_env['status'] = {\
			"code": 0,\
			"description": "OK",\
		}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			render_param = {}
			if args and "code" in args and args['code']:
				#[begin] Merge step.
				try:
					dbcur.execute(Model.sql("load_invitation"), {"unique_code": args['code'],})
				except:
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				else:
					render_param = Model.convert("load_invitation", dbcur)
					render_param['step'] = "confirm" if "step" in args and args['step'] == "confirm" else "input"
				render_param['step'] = render_param['step'] if render_param and "step" in render_param and render_param['step'] in ("input", "confirm", "thanks",) else "input"
				#[end] Merge step.
				if render_param['step'] == "confirm" or args['step'] == "confirm":
					render_param['val'] = render_param['val'] if "val" in render_param else {}
					render_param['val'].update({\
						"name": args['name'],\
						"owner_name": args['owner_name'],\
						"tel": args['tel'],\
						"fax": args['fax'] or None,\
						"addr_vip": args['addr_vip'].replace("-", ""),\
						"addr1": args['addr1'],\
						"addr2": args['addr2'] or "",\
						"step": "confirm",\
					})
					try:
						dbcur.execute(Model.sql("update_val"), {\
							"id": args['id'],\
							"code": args['code'],\
							"val": JSON.dumps(render_param['val']),\
							"mail": render_param['val']['mail'] if "val" in render_param and "mail" in render_param['val'] else None,\
						})
					except:
						pprint.pprint(traceback.format_exc())
						chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
						chain_env['status']['code'] = 6
						chain_env['status']['validation_messages'] = []
					else:
						dbcon.commit()
				elif render_param['step'] == "thanks" or args['step'] == "thanks":
					#[begin] Create company and group.
					param_c = {\
						"name": render_param['val']['name'],\
						"owner_name": render_param['val']['owner_name'],\
						"tel": render_param['val']['tel'],\
						"fax": render_param['val']['fax'],\
						"addr_vip": render_param['val']['addr_vip'],\
						"addr1": render_param['val']['addr1'],\
						"addr2": render_param['val']['addr2'],\
						"prefix": N62.encode(random.Random().randint(pow(62, 6), pow(62, 7) - 1)),\
					}
					param_invi = {}
					tmp = self.create_company(dbcur, param_c)
					trace = []
					if not tmp[0]:
						trace += tmp[1]
					else:
						cid = tmp[0]['id']
						tmp = self.create_group(dbcur, {"cid": cid})
						if not tmp[0]:
							trace += tmp[1]
						else:
							gid = tmp[0]['id']
							param_invi.update({\
								"cid": cid,\
								"gid": gid,\
								"prefix": param_c['prefix'],\
								"code": N62.encode(random.Random().randint(pow(62, 6), pow(62, 7) - 1)),\
								"type_signup": "ADD_USER",\
								"target_user": None,\
								"creator": None,\
								"mail": render_param['val']['mail'],\
								"flg_admin": True,\
							})
							tmp = self.create_invitation_after_company_created(dbcur, param_invi)
					#[end] Create company and group.
					if not trace:
						#[begin] Set preferences.
						_, tmp_trace = self.create_prefs(dbcur, param_invi)
						#[end] Set preferences.
						if not tmp_trace:
							#[begin] Send invitation mail.
							self.sendmail_add_user("SIGNUP_INV_ADD_USER", {\
								"code": tmp[0]['code'],\
								"name": "",\
								"mail": render_param['val']['mail'],\
							}, param_invi)
							#[end] Send invitation mail.
							#[begin] Disable signup request.
							self.disable_invitation(dbcur, render_param['id'])
							#[end] Disable signup request.
							dbcon.commit()
					else:
						pprint.pprint(trace)
						dbcon.rollback()
						chain_env['status']['code'] = 6
						chain_env['trace'] += trace
				else:
					pass#Do nothing.
			else:
				chain_env['status']['code'] = 16
		chain_env['response_body'] = flask.render_template(\
			"signup_company.tpl",
			data = render_param,\
			env = chain_env,\
			query = args,\
			trace = chain_env['trace'],\
			title = u"サインアップ（会社登録）|SESクラウド",\
		)
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_html_user(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		chain_env['status'] = {\
			"code": 0,\
			"description": "OK",\
		}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			render_param = {}
			if args and "code" in args and args['code']:
				#[begin] Merge step.
				try:
					dbcur.execute(Model.sql("load_invitation"), {"unique_code": args['code'],})
				except:
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				else:
					render_param = Model.convert("load_invitation", dbcur)
					render_param['step'] = "confirm" if "step" in args and args['step'] == "confirm" else "input"
				render_param['step'] = render_param['step'] if render_param and "step" in render_param and render_param['step'] in ("input", "confirm", "thanks",) else "input"
				#[end] Merge step.
				if render_param['step'] == "confirm" or args['step'] == "confirm":
					render_param['val'] = render_param['val'] if "val" in render_param else {}
					render_param['val'].update({\
						"name": args['name'],\
						"login_id": args['prefer_login_id'],\
						"mail1": args['mail1'],\
						"tel1": args['tel1'],\
						"tel2": args['tel2'] or None,\
						"fax": args['fax'] or None,\
						"pwd": args['pwd'],\
						"step": "confirm",\
					})
					try:
						dbcur.execute(Model.sql("update_val"), {\
							"id": args['id'],\
							"code": args['code'],\
							"val": JSON.dumps(render_param['val']),\
							"mail": render_param['val']['mail1'],\
						})
					except:
						chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
						chain_env['status']['code'] = 6
						chain_env['status']['validation_messages'] = []
					else:
						dbcon.commit()
				elif render_param['step'] == "thanks" or args['step'] == "thanks":
					param_c = {\
						"name": render_param['val']['name'],\
						"login_id": render_param['val']['login_id'],\
						"mail1": render_param['val']['mail1'],\
						"tel1": render_param['val']['tel1'],\
						"tel2": render_param['val']['tel2'],\
						"fax": render_param['val']['fax'],\
						"pwd": render_param['val']['pwd'],\
						"cid": render_param['val']['cid'],\
						"gid": render_param['val']['gid'],\
						"flg_admin": "flg_admin" in render_param['val'] and render_param['val']['flg_admin'],\
					}
					param_invi = {}
					tmp = self.create_user(dbcur, param_c)
					trace = []
					if not tmp[0]:
						trace += tmp[1]
					else:
						uid = tmp[0]['id']
						tmp = self.insert_mail_templates(dbcur, {"uid": uid, "cid": param_c['cid'],})
						if not tmp[0]:
							trace += tmp[1]
					if not trace:
						#[begin] Send invitation mail.
						self.sendmail_add_user("SIGNUP_FINISH_ADD_USER", {\
							"name": render_param['val']['name'],\
							"mail": render_param['val']['mail1'],\
						}, {\
							"name": param_c['name'],\
							"prefix": chain_env['prefix'],\
						})
						#[end] Send invitation mail.
						#[begin] Disable signup request.
						self.disable_invitation(dbcur, render_param['id'])
						#[end] Disable signup request.
						dbcon.commit()
						chain_env['status']['code'] = 0
					else:
						pprint.pprint(trace)
						dbcon.rollback()
						chain_env['status']['code'] = 6
						chain_env['trace'] += trace
				else:
					pass#Do nothing.
			else:
				chain_env['status']['code'] = 16
		chain_env['response_body'] = flask.render_template(\
			"signup_user.tpl",
			data = render_param,\
			env = chain_env,\
			query = args,\
			trace = chain_env['trace'],\
			title = u"サインアップ（ユーザー登録）|SESクラウド",\
		)
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_resetpwd(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			render_param = {}
			#[begin] Store inquiry into database.
			param = {\
				"prefix": chain_env['prefix'],\
				"mail": args['mail'],\
				"code": N62.encode(random.Random().randint(pow(62, 6), pow(62, 7) - 1)),\
				"type_signup": "RESET_PWD",\
				"target_user": None,\
				"creator": None,\
				"login_id": args['loginid'],\
				"tmp_pwd": N62.encode(random.Random().randint(pow(62, 6), pow(62, 7) - 1)),\
			}
			try:
				dbcur.execute(Model.sql("fetch_reset_target_user"), param)
			except:
				chain_env['trace'].append(traceback.format_exc())
				pprint.pprint(traceback.format_exc())
				status['code'] = 2
			else:
				param['uid'] = dbcur.fetchone()
				param['uid'] = param['uid'][0] if param['uid'] else None
			if param['uid'] is not None:
				try:
					dbcur.execute(Model.sql("resetpwd"), param)
				except:
					chain_env['trace'].append(traceback.format_exc())
					pprint.pprint(traceback.format_exc())
					status['code'] = 2
					dbcon.rollback()
				else:
					try:
						dbcur.execute(Model.sql("create_invitation"), param)
					except:
						chain_env['trace'].append(traceback.format_exc())
						pprint.pprint(traceback.format_exc())
						status['code'] = 2
						dbcon.rollback()
					else:
						dbcur.execute(Model.sql("fetch_new_invitation"))
						result = Model.convert("fetch_new_invitation", dbcur)
						dbcur.execute(Model.sql("update_val"), {\
							"id": result['id'],\
							"code": result['code'],\
							"val": JSON.dumps({"uid": param['uid']}),\
							"mail": param['mail'],\
						})
						dbcon.commit()
						#[begin] Mail to user.
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
						# generate mail content.
						mail_param = {\
							"user_mail": param['mail'],\
							"prefix": chain_env['prefix'],\
							"code": result['code'],\
						}
						context = self.__pref__['SIGNUP_RESET_PWD']
						msg = MIMEMultipart()
						msg['Subject'] = Header(Environment().from_string(context['subject']).render(**mail_param), self.__pref__['MAIL_CHARSET'])
						msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
						msg['To'] = mail_param['user_mail']
						msg['Date'] = formatdate(localtime=True)
						msg.attach(MIMEText(Environment().from_string(context['body_tpl']).render(**mail_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET']))
						recipient = mail_param['user_mail']
						svr = smtplib.SMTP()
						svr.connect("localhost")
						svr.set_debuglevel(0)
						svr.sendmail("noreply@si-cloud.jp", recipient, msg.as_string())
						#[end] Mail to user.
		status['code'] = status['code'] or 0
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_setpwd(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			pprint.pprint(args)
			render_param = {}
			try:
				dbcur.execute(Model.sql("load_invitation"), {"unique_code": args['code'],})
			except:
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
			else:
				render_param = Model.convert("load_invitation", dbcur)
				#[begin] Store inquiry into database.
				param = {\
					"uid": args['uid'],\
					"pwd": args['pwd'],\
				}
				try:
					dbcur.execute(Model.sql("overwrite_pwd"), param)
				except:
					chain_env['trace'].append(traceback.format_exc())
					pprint.pprint(traceback.format_exc())
					status['code'] = 2
					dbcon.rollback()
				else:
					#[begin] Disable signup request.
					self.disable_invitation(dbcur, render_param['id'])
					#[end] Disable signup request.
					dbcon.commit()
		pprint.pprint(chain_env['trace'])
		status['code'] = status['code'] or 0
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
	def _fn_adduser(self, chain_env):
		pass
	
	def _fn_html_flushpwd(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		chain_env['status'] = {\
			"code": 0,\
			"description": "OK",\
		}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			render_param = {}
			if args and "code" in args and args['code']:
				#[begin] Merge step.
				try:
					dbcur.execute(Model.sql("load_invitation"), {"unique_code": args['code'],})
				except:
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				else:
					render_param = Model.convert("load_invitation", dbcur)
					render_param['step'] = "confirm" if "step" in args and args['step'] == "confirm" else "input"
				render_param['step'] = render_param['step'] if render_param and "step" in render_param and render_param['step'] in ("input", "confirm", "thanks",) else "input"
				#[end] Merge step.
				if render_param['step'] == "confirm" or args['step'] == "confirm":
					render_param['val'] = render_param['val'] if "val" in render_param else {}
					render_param['val'].update({\
						"name": args['name'],\
						"login_id": args['prefer_login_id'],\
						"mail1": args['mail1'],\
						"tel1": args['tel1'],\
						"tel2": args['tel2'] or None,\
						"fax": args['fax'] or None,\
						"pwd": args['pwd'],\
						"flg_admin": "flg_admin" in args and args['flg_admin'],\
						"step": "confirm",\
					})
					try:
						dbcur.execute(Model.sql("update_val"), {\
							"id": args['id'],\
							"code": args['code'],\
							"val": JSON.dumps(render_param['val']),\
							"mail": rende_param['val']['mail1'],\
						})
					except:
						pprint.pprint(traceback.format_exc())
						chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
						chain_env['status']['code'] = 6
						chain_env['status']['validation_messages'] = []
					else:
						dbcon.commit()
				elif render_param['step'] == "thanks" or args['step'] == "thanks":
					param_c = {\
						"name": render_param['val']['name'],\
						"login_id": render_param['val']['login_id'],\
						"mail1": render_param['val']['mail1'],\
						"tel1": render_param['val']['tel1'],\
						"tel2": render_param['val']['tel2'],\
						"fax": render_param['val']['fax'],\
						"pwd": render_param['val']['pwd'],\
						"cid": render_param['val']['cid'],\
						"gid": render_param['val']['gid'],\
						"flg_admin": "flg_admin" in args and args['flg_admin'],\
					}
					param_invi = {}
					tmp = self.create_user(dbcur, param_c)
					trace = []
					if not tmp[0]:
						trace += tmp[1]
					else:
						uid = tmp[0]['id']
						tmp = self.insert_mail_templates(dbcur, {"uid": uid, "cid": param_c['cid'],})
						if not tmp[0]:
							trace += tmp[1]
					if not trace:
						dbcon.commit()
						#[begin] Send invitation mail.
						self.sendmail_add_user("SIGNUP_FINISH_ADD_USER", {\
							"name": render_param['val']['name'],\
							"mail": render_param['val']['mail1'],\
						}, {\
							"name": param_c['name'],\
							"prefix": chain_env['prefix'],\
						})
						#[end] Send invitation mail.
					else:
						pprint.pprint(trace)
						dbcon.rollback()
						chain_env['status']['code'] = 6
						chain_env['trace'] += trace
				else:
					pass#Do nothing.
			else:
				chain_env['status']['code'] = 16
		chain_env['response_body'] = flask.render_template(\
			"signup_setpwd.tpl",
			data = render_param,\
			env = chain_env,\
			query = args,\
			trace = chain_env['trace'],\
			title = u"サインアップ（パスワード再登録）|SESクラウド",\
		)
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_html_freemium(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		chain_env['status'] = {\
			"code": 0,\
			"description": "OK",\
		}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		args = chain_env['argument'].data
		render_param = {}
		if args and "step" in args and args['step'] == "input":
			render_param['step'] = "input"
		elif args and "step" in args and args['step'] == "thanks":
			render_param['step'] = "thanks"
		else:
			render_param['step'] = "input"
		if dbcur:
			if render_param['step'] == "input":
				pass
			elif render_param['step'] == "thanks":
				#[begin] Register invitation to the database.
				param_invi = {\
					"code": N62.encode(random.Random().randint(pow(62, 6), pow(62, 7) - 1)),\
					"type_signup": "ADD_COMPANY",\
					"target_user": None,\
					"creator": None,\
					"mail": args['mail'],\
				}
				#[begin] History check.
				try:
					dbcur.execute(Model.sql("check_history"), param_invi)
				except:
					chain_env['trace'].append(traceback.format_exc())
					print traceback.format_exc()
					flg_already_registered = None
				else:
					#flg_already_registered = bool(len(dbcur.fetchall()))
					pass
				#[CAUTION] False is for TEST use only.
				flg_already_registered = False
				render_param['flg_already'] = flg_already_registered
				#[end] history check.
				if not flg_already_registered:
					tmp = self.create_invitation_for_create_company(dbcur, param_invi)
					#[end] Register invitation to the database.
					if tmp:
						dbcon.commit()
						param_invi['code'] = tmp[0]['code']
						#[begin] Send invitation mail.
						self.sendmail_add_company({\
							"mail": args['mail'],\
						}, param_invi)
						#[end] Send invitation mail.
					else:
						dbcon.rollback()
			else:
				chain_env['status']['code'] = 16
		chain_env['response_body'] = flask.render_template(\
			"signup_freemium.tpl",
			data = render_param,\
			env = chain_env,\
			query = args,\
			trace = chain_env['trace'],\
			title = u"サインアップ（フリー利用）|SESクラウド",\
		)
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def disable_invitation(self, dbcur, inv_id):
		result = None
		trace = []
		try:
			dbcur.execute(Model.sql("disable_invitation"), {"id": inv_id})
		except:
			trace.append(traceback.format_exc())
			print Model.sql("disable_invitation")
		else:
			pass
		return result, trace

	def create_company(self, dbcur, param):
		result = None
		trace = []
		try:
			dbcur.execute(Model.sql("create_company"), param)
		except:
			trace.append(traceback.format_exc())
			print Model.sql("create_company")
		else:
			dbcur.execute(Model.sql("last_insert_id"))
			result = Model.convert("last_insert_id", dbcur)
		return result, trace
	
	def create_group(self, dbcur, param):
		result = None
		trace = []
		try:
			dbcur.execute(Model.sql("create_group"), param)
		except:
			trace.append(traceback.format_exc())
			print Model.sql("create_group")
		else:
			dbcur.execute(Model.sql("last_insert_id"))
			result = Model.convert("last_insert_id", dbcur)
		return result, trace
	
	def create_user(self, dbcur, param):
		result = None
		trace = []
		try:
			dbcur.execute(Model.sql("create_user"), param)
		except:
			trace.append(traceback.format_exc())
			print Model.sql("create_user")
			pprint.pprint(param)
		else:
			dbcur.execute(Model.sql("last_insert_id"))
			result = Model.convert("last_insert_id", dbcur)
		return result, trace
	
	def create_prefs(self, dbcur, param):
		result = None
		trace = []
		for k, v in (\
				("LMT_ACT_MAIL", "true",),\
				("LMT_ACT_MAP", "false",),\
				("LMT_CALL_MAP_EXTERN_M", "1"),\
				("LMT_SIZE_BIN", str(1 * 1024 * 1024),),\
				("LMT_SIZE_STORAGE", str(100 * 1024 * 1024),),\
				("LMT_LEN_MAIL_ATTACHMENT", "1",),\
				("LMT_LEN_MAIL_PER_DAY", "10",),\
				("LMT_LEN_MAIL_PER_MONTH", "50",),\
				("LMT_LEN_STORE_DATE", "30",),\
				("LMT_LEN_ACCOUNT", "3",),\
				("LMT_LEN_CLIENT", "10",),\
				("LMT_LEN_ENGINEER", "10",),\
				("LMT_LEN_INQUIRE", "0",),\
				("LMT_LEN_MAIL_TPL", "10",),\
				("LMT_LEN_PROJECT", "10",),\
				("LMT_LEN_WORKER", "10",),\
				("MAIL_RECEIVER_CC", "[]",),\
				("MAIL_RECEIVER_BCC", "[]",),\
			):
			try:
				dbcur.callproc("renew_pref", (param['prefix'], k, v,))
			except:
				trace.append(traceback.format_exc())
				print (param['prefix'], k, v,)
			else:
				pass
		return result, trace
	
	def insert_mail_templates(self, dbcur, param):
		result = None
		trace = []
		try:
			dbcur.execute(Model.sql("check_mail_tpl"), param)
		except:
			trace.append(traceback.format_exc())
			pprint.pprint(trace)
		else:
			result = Model.convert("has_mail_template", dbcur)
			pprint.pprint(result)
			if not result:
				try:
					dbcur.execute(Model.sql("insert_mail_tpl"), param)
				except:
					trace.append(traceback.format_exc())
					pprint.pprint(trace)
				else:
					pass
		return result, trace
	
	def create_invitation_after_company_created(self, dbcur, param):
		result = None
		trace = []
		try:
			dbcur.execute(Model.sql("create_invitation"), param)
		except:
			trace.append(traceback.format_exc())
			print Model.sql("create_invitation")
		else:
			dbcur.execute(Model.sql("fetch_new_invitation"))
			result = Model.convert("fetch_new_invitation", dbcur)
			try:
				dbcur.execute(Model.sql("update_val"), {\
					"id": result['id'],\
					"code": result['code'],\
					"val": JSON.dumps({\
						"cid": param['cid'],\
						"gid": param['gid'],\
						"mail": param['mail'],\
						"prefix": param['prefix'],\
						"flg_admin": param['flg_admin'] if "flg_admin" in param else False,\
					}),\
					"mail": param['mail'],\
				})
			except:
				trace.append(traceback.format_exc())
				print Model.sql("update_val")
		return result, trace
	
	def create_invitation_for_create_company(self, dbcur, param):
		result = None
		trace = []
		try:
			dbcur.execute(Model.sql("create_invitation"), param)
		except:
			trace.append(traceback.format_exc())
			print Model.sql("create_invitation")
		else:
			dbcur.execute(Model.sql("fetch_new_invitation"))
			result = Model.convert("fetch_new_invitation", dbcur)
			try:
				dbcur.execute(Model.sql("update_val"), {\
					"id": result['id'],\
					"code": result['code'],\
					"val": JSON.dumps({\
						"mail": param['mail'],\
					}),\
					"mail": param['mail'],\
				})
			except:
				trace.append(traceback.format_exc())
				print Model.sql("update_val")
		return result, trace
	
	def sendmail_add_user(self, template, recipient, render_param, sender = {}):
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
		#[begin] Make message.
		context = self.__pref__[template]
		msg = MIMEText(Environment().from_string(context['body_tpl']).render(**render_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
		msg['Subject'] = Header(Environment().from_string(context['subject']).render(**render_param), self.__pref__['MAIL_CHARSET'])
		if sender:
			msg['From'] = email.utils.formataddr((Header(sender['name'], self.__pref__['MAIL_CHARSET']).encode(), sender['mail']))
		else:
			msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
		msg['To'] = email.utils.formataddr((Header(recipient['name'], self.__pref__['MAIL_CHARSET']).encode(), recipient['mail']))
		msg['Date'] = formatdate(localtime=True)
		#[end] Make message.
		svr = smtplib.SMTP()
		svr.connect("localhost")
		svr.set_debuglevel(0)
		svr.sendmail("noreply@si-cloud.jp", recipient['mail'], msg.as_string())
		
	def sendmail_add_company(self, recipient, render_param, sender = {}):
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
		#[begin] Make message.
		context = self.__pref__['SIGNUP_INV_ADD_COMPANY']
		msg = MIMEText(Environment().from_string(context['body_tpl']).render(**render_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
		msg['Subject'] = Header(Environment().from_string(context['subject']).render(**render_param), self.__pref__['MAIL_CHARSET'])
		if sender:
			msg['From'] = email.utils.formataddr((Header(sender['name'], self.__pref__['MAIL_CHARSET']).encode(), sender['mail']))
		else:
			msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
		msg['To'] = recipient['mail']
		msg['Date'] = formatdate(localtime=True)
		#[end] Make message.
		svr = smtplib.SMTP()
		svr.connect("localhost")
		svr.set_debuglevel(0)
		svr.sendmail("noreply@si-cloud.jp", recipient['mail'], msg.as_string())
		
