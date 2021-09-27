#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides negotiation logics.
"""

import time
import datetime
import hashlib
import copy
import traceback
import pprint
import re
import flask

from validators.base import ValidatorBase as Validator
from models.negotiation import Negotiation as Model
from base import ProcessorBase
from errors import exceptions as EXC
from providers.limitter import Limitter

class Processor(ProcessorBase):
	
	"""
		This class provides negotiation object manipulation functionalities.
	"""
	
	__realms__ = {\
		"top": {\
			"logic": "html_top",\
		},
		"enumNegotiations": {\
			"logic": "enum_negotiations",\
		},\
		"createNegotiation": {\
			"valid_in": "create_negotiation_in",\
			"logic": "create_negotiation",\
		},\
		"updateNegotiation": {\
			"valid_in": "update_negotiation_in",\
			"logic": "update_negotiation",\
		},\
		"deleteNegotiation": {\
			"valid_in": "delete_negotiation_in",\
			"logic": "delete_negotiation",\
		},\
		"sendReminderMail": {\
			"valid_in": "send_reminder_mail_in",\
			"logic": "send_reminder_mail",\
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
		from logics.client import Processor as P_CLIENT
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch negotiations.
		status_clients, render_param['negotiation.enumNegotiations'] = self._fn_enum_negotiations(chain_env)
		#[begin] Support objects.
		#Fetch user accounts.
		clean_env = copy.deepcopy(chain_env)
		clean_env['argument'].clear()
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(clean_env)
		#Fetch client companies.
		status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		render_param['js.clients'] = []
		for item in render_param['client.enumClients']:
			tmp = {}
			tmp['label'] = item['name']
			tmp['id'] = item['id']
			render_param['js.clients'].append(tmp)
		#[end] Support objects.
		chain_env['response_body'] = flask.render_template(\
			"negotiation.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"商談|SESクラウド",\
			current="negotiation.top")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_negotiations(self, chain_env):
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
			#[begin] Build where clause conditions.
			FILTERS_LIKE = {\
				"client_name": "CONCAT(COALESCE(`N`.`client_name`, ''''), COALESCE(`C`.`name`, ''''))",\
				"name": "`N`.`name`",\
				"note": "`N`.`note`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`N`.`id`",\
				"client_id": "`N`.`client_id`",\
				"charging_user_id": "`N`.`charging_user_id`",\
				"business_type": "`N`.`business_type`",\
				"phase": "`N`.`phase`",\
				"status": "`N`.`status`",\
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			orderClause = ["COALESCE(`N`.`dt_modified`, `N`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_negotiations") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_negotiations", dbcur)
			#[begin] Joining user list.
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id'], entity['charging_user']['id']) for entity in result] for e in p]))
			if user_list:
				try:
					dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
				except:
					print dbcur._executed
					chain_env['trace'].append(dbcur._executed)
					chain_env['trace'].append(traceback.format_exc())
				else:
					res2 = Model.convert("enum_users", dbcur)
					for tmp_obj in res2:
						[entity['charging_user'].update(tmp_obj) for entity in result if entity['charging_user']['id'] == tmp_obj['id']]
						[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
						[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			#[end] Joining user list.
			#[begin] Joining clients.
			cid_list = set([e['client']['id'] for e in result if e['client']['id'] is not None])
			if cid_list:
				param2 = (\
					chain_env['prefix'], chain_env['login_id'],\
					chain_env['prefix'], chain_env['login_id'], chain_env['credential']\
				)
				dbcur.execute(Model.sql("enum_clients") % ", ".join(map(str, cid_list)), param2)
				res3 = Model.convert("enum_clients", dbcur)
				for tmp_obj in res3:
					[entity['client'].update(tmp_obj) for entity in result if entity['client']['id'] == tmp_obj['id']]
			#[end] Joining clients.
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_create_negotiation(self, chain_env):
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
				args['client_id'] if "client_id" in args else None,\
				args['client_name'] if "client_name" in args else None,\
				args['name'],\
				args['charging_user_id'],\
				chain_env['prefix'], chain_env['login_id'],\
				args['business_type'],\
				args['phase'],\
				args['status'],\
				args['note'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
				args['dt_negotiation'],\
			)
			try:
				dbcur.execute(Model.sql("create_negotiation"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				dbcon.commit()
				dbcur.execute(Model.sql("last_insert_id"))
				chain_env['results'] = Model.convert("last_insert_id", dbcur)
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_update_negotiation(self, chain_env):
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
			#[begin] SQL preparation.
			ACCEPT_FIELDS = ("client_id", "client_name", "name", "business_type", "phase", "status", "note", "dt_negotiation")
			args = chain_env['argument'].data
			cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
			vals = [(self.str2datetime(args[k]) or None) if k.startswith("term_") else args[k] for k in cols]
			cols += ["dt_modified"]
			vals += [datetime.datetime.now()]
			if "client_name" in cols:
				cols += ["client_id"]
				vals += [None]
			cvt = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				[args['charging_user_login_id'] if "charging_user_login_id" in args else None] +\
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				[args['charging_user_id'] if "charging_user_id" in args else None]+\
				vals +\
				[args['id'], chain_env['prefix'], args['login_id']]
			#[end] SQL preparation.
			try:
				dbcur.execute(Model.sql("update_negotiation") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				if err.errno == 1048 and err.sqlstate == "23000":
					chain_env['status']['code'] = 2
				else:
					chain_env['trace'].append(traceback.format_exc(err))
				dbcon.rollback()
			else:
				chain_env['results'] = {}
				dbcon.commit()
				chain_env['status']['code'] = chain_env['status']['code'] or 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_delete_negotiation(self, chain_env):
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
				chain_env['prefix'], args['login_id'],\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("delete_negotiation") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				chain_env['trace'].append(err)
				dbcon.rollback()
			else:
				chain_env['results']['rows'] = dbcur.rowcount
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_send_reminder_mail(self, chain_env):
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
			#[begin] Fetch negotiation object.
			negotiation_obj = None
			param = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				[args['negotiationId']]
			try:
				dbcur.execute(Model.sql("enum_negotiations_for_reminder") % ("AND `N`.`id` = %s", "`N`.`id`"), param)
			except:
				chain_env['trace'].append(traceback.format_exc())
				pprint.pprint(traceback.format_exc())
				status['code'] = 2
			else:
				negotiation_obj = Model.convert("enum_negotiations_for_reminder", dbcur)
				negotiation_obj = negotiation_obj[0] if negotiation_obj else None
			#[end] Fetch negotiation object.
			#[begin] Fetch recipient list.
			recipient_list = []
			try:
				dbcur.execute(Model.sql("enum_users_for_mail") % (", ".join(map(str, args['recipientIdList'])),))
			except:
				chain_env['trace'].append(traceback.format_exc())
				pprint.pprint(traceback.format_exc())
				status['code'] = 2
			else:
				recipient_list = Model.convert("enum_users_for_mail", dbcur)
			#[end] Fetch recipient list.
			if negotiation_obj and recipient_list:
				#[begin] Send mail.
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
				render_param = negotiation_obj
				#[begin] Fetch user profile.
				from logics.auth import Processor as P_AUTH
				status_profile, user_profile = P_AUTH(self.__pref__).read_user_profile(chain_env)
				#[end] Fetch user profile.
				#[begin] Make message list.
				msg_list = []
				for recipient in recipient_list:
					context = self.__pref__['NEGOTIATION_REMIND_MAIL']
					msg = MIMEText(Environment().from_string(context['body_tpl']).render(**render_param).encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
					msg['Subject'] = Header(Environment().from_string(context['subject']).render(**render_param), self.__pref__['MAIL_CHARSET'])
					#msg['From'] = email.utils.formataddr((Header("SESクラウド", self.__pref__['MAIL_CHARSET']).encode(), "noreply@si-cloud.jp"))
					msg['From'] = email.utils.formataddr((Header(user_profile ['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), user_profile ['user']['mail1']))
					msg['To'] = email.utils.formataddr((Header(recipient['name'], self.__pref__['MAIL_CHARSET']).encode(), recipient['mail']))
					msg['Date'] = formatdate(localtime=True)
					msg_list.append((recipient['mail'], msg,))
				#[end] Make message list.
				svr = smtplib.SMTP()
				svr.connect("localhost")
				svr.set_debuglevel(0)
				for recipient, msg in msg_list:
					svr.sendmail("noreply@si-cloud.jp", recipient, msg.as_string())
				status['code'] = 0
				#[end] Send mails.
			else:
				status['code'] = 6
				status['description'] = u"商談か送信先が有効ではありません"
		status['code'] = status['code'] or 0
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		chain_env['performance']['logic_time'] = time.time() - time_bg
	
