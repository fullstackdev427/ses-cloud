#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides contact logics.
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
from models.contact import Contact as Model
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
		"top": {\
			"logic": "html_top",\
		},\
		"commit": {\
			"logic": "commit",\
		},\
		"migrateInvoke": {\
			"logic": "migrate_invoke",\
		},\
	}
	
	def _fn_html_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		render_param = {}
		from logics.auth import Processor as P_AUTH
		from logics.manage import Processor as P_MANAGE
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#Fetch preferences.
		status_pref, render_param['manage.enumPrefs'] = P_MANAGE(self.__pref__)._fn_enum_prefs(chain_env)
		#[begin] Support objects.
		render_param['manage.enumPrefsDict'] = {}
		[render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
		#[end] Support objects.
		chain_env['response_body'] = flask.render_template(\
			"contact.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"お問合せ|SESクラウド",\
			current="contact.top")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_commit(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
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
			render_param = {}
			from logics.auth import Processor as P_AUTH
			from logics.manage import Processor as P_MANAGE
			#Fetch user profile.
			status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
			#Fetch preferences.
			status_pref, render_param['manage.enumPrefs'] = P_MANAGE(self.__pref__)._fn_enum_prefs(chain_env)
			#[begin] Store inquiry into database.
			param = {\
				"credential": args['credential'],\
				"prefix": chain_env['prefix'],\
				"login_id": args['login_id'],\
				"company_id": render_param['auth.userProfile']['company']['id'],\
				"type_inquire": args['type_inquire'],\
				"content": JSON.dumps(args['content']),\
			}
			try:
				dbcur.execute(Model.sql("inquire_commit"), param)
			except:
				chain_env['trace'].append(traceback.format_exc())
				pprint.pprint(traceback.format_exc())
				status['code'] = 2
				dbcon.rollback()
			else:
				dbcon.commit()
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
				mail_param = {\
					"client_name": render_param['auth.userProfile']['company']['name'],\
					"user_name": render_param['auth.userProfile']['user']['name'],\
					"user_mail": render_param['auth.userProfile']['user']['mail1'],\
					"user_tel1": render_param['auth.userProfile']['user']['tel1'],\
					"user_tel2": render_param['auth.userProfile']['user']['tel2'],\
					"credential": args['credential'],\
					"name_inquire": {\
						"UPGRADE": u"アップグレード",\
						"EXTEND": u"プラン変更",\
						"OJT": u"提案依頼",\
						"USAGE": u"利用方法質問",
						"TROUBLE": u"不具合報告",\
						"MISC": u"その他"}[args['type_inquire']],\
					"content": args['content'],\
				}
				# for User.
				context = self.__pref__['INQUIRE_MAIL']['user']
				msg = MIMEMultipart()
				msg['Subject'] = Header(Environment().from_string(context['subject']).render(**mail_param), self.__pref__['MAIL_CHARSET'])
				msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
				msg['To'] = email.utils.formataddr((Header(mail_param['user_name'], self.__pref__['MAIL_CHARSET']).encode(), mail_param['user_mail']))
				msg['Date'] = formatdate(localtime=True)
				msg.attach(MIMEText(Environment().from_string(context['body_tpl']).render(**mail_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET']))
				msg_pack_1 = mail_param['user_mail'], msg
				# for Goodworks.
				context = self.__pref__['INQUIRE_MAIL']['owner']
				msg = MIMEMultipart()
				msg['Subject'] = Header(Environment().from_string(context['subject']).render(**mail_param), self.__pref__['MAIL_CHARSET'])
				msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
				msg['To'] = email.utils.formataddr((Header(context['to']['name'], self.__pref__['MAIL_CHARSET']).encode(), context['to']['mail']))
				msg['Date'] = formatdate(localtime=True)
				msg.attach(MIMEText(Environment().from_string(context['body_tpl']).render(**mail_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET']))
				msg_pack_2 = context['to']['mail'], msg
				# for Maintainer.
				context = self.__pref__['INQUIRE_MAIL']['admin']
				msg = MIMEMultipart()
				msg['Subject'] = Header(Environment().from_string(context['subject']).render(**mail_param), self.__pref__['MAIL_CHARSET'])
				msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
				msg['To'] = email.utils.formataddr((Header(context['to']['name'], self.__pref__['MAIL_CHARSET']).encode(), context['to']['mail']))
				msg['Date'] = formatdate(localtime=True)
				msg.attach(MIMEText(Environment().from_string(context['body_tpl']).render(**mail_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET']))
				msg_pack_3 = context['to']['mail'], msg
				# send mails.
				svr = smtplib.SMTP()
				svr.connect("localhost")
				svr.set_debuglevel(0)
				for recipient, msg in (msg_pack_1, msg_pack_2, msg_pack_3,):
					svr.sendmail("noreply@si-cloud.jp", recipient, msg.as_string())
				#[end] Mail to Goodworks and Maintainer addresses.
			#[end] Store inquiry into database.
		status['code'] = status['code'] or 0
		chain_env['results'] = result
		chain_env['status'] = status
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
	
