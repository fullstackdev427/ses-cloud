#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides mailing logics.
"""

import re
import time
import copy
import hashlib
import smtplib
from smtplib import SMTPDataError
from email.Header import Header
from email.Utils import formatdate
import email.utils
import traceback
import pprint
import itertools
import multiprocessing
import datetime

import flask
from jinja2 import Environment

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
from errors import exceptions as EXC
from validators.base import ValidatorBase as Validator
from models.mail import Mail as Model
from base import ProcessorBase
from errors import exceptions as EXC
from flask import jsonify
class Processor(ProcessorBase):

	"""
		This class provides mail manipulation functionalities.
	"""

	__realms__ = {\
		"top": {\
			"logic": "html_top",\
		},\
		"createMail": {\
			"logic": "html_create_mail",\
		},\
		"createReminder": {\
			"logic": "html_create_reminder",\
		}, \
		"createQuotation": { \
			"logic": "html_create_quotation", \
			}, \
		"simulateMailBody": {\
			"logic": "simulate_mail_body",\
		},\
		"enumMailRequests": {\
			"valid_in": None,\
			"logic": "enum_mail_requests",
			"valid_out": None\
		},\
		"sendMailRequest": {\
			"valid_in": None,\
			"logic": "send_mail_request_ex",\
			"valid_out": None\
		}, \
		"sendMailReserve": {\
			"valid_in": None,\
			"logic": "send_mail_reserve",\
			"valid_out": None\
		}, \
		"getReservedMailsCount": {\
			"valid_in": None,\
			"logic": "get_reserved_mails_count",\
			"valid_out": None\
		}, \
		"sendMailRequestAsync": { \
			"valid_in": None, \
			"logic": "send_mail_request_ex_async", \
			"valid_out": None \
			}, \
		"simulateMailPerClient": {\
			"valid_in": None,\
			"logic": "simulate_mail_par_client",\
			"valid_out": None\
		},\
		"enumTemplates": {\
			"valid_in": None,\
			"logic": "enum_templates",\
			"valid_out": None\
		},\
		"createTemplate": {\
			"valid_in": "create_mail_template_in",
			"logic": "create_template",\
			"valid_out": None\
		},\
		"updateTemplate": {\
			"valid_in": "update_mail_template_in",\
			"logic": "update_template",\
			"valid_out": None\
		},\
		"deleteTemplate": {\
			"valid_in": "delete_mail_template_in",\
			"logic": "delete_template",\
			"valid_out": None\
		},\
		"enumReserve": {\
			"valid_in": None,\
			"logic": "enum_reserve",\
			"valid_out": None\
		},\
		"getReserveInfo": {\
			"valid_in": None,\
			"logic": "get_reserve_info",\
			"valid_out": None\
		},\
		"updateReserve": {\
			"valid_in": None,\
			"logic": "update_reserve",\
			"valid_out": None\
		},\
		"deleteReserve": {\
			"valid_in": None,\
			"logic": "delete_reserve",\
			"valid_out": None\
		},\
		"updateReserveSent": {\
			"valid_in": None,\
			"logic": "update_reserve_sent",\
			"valid_out": None\
		},\
	}

	__switch_replace_envelope = True

	def _fn_html_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.engineer import Processor as P_ENGINEER
		from logics.client import Processor as P_CLIENT
		from logics.project import Processor as P_PROJECT
		from logics.manage import Processor as P_MANAGE
		render_param = {}
		pprint.pprint(chain_env)
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch mail requests.
		status_mailreq, render_param['mail.enumMailRequests'] = self._fn_enum_mail_requests(chain_env)
		#Fetch mail reserves.
		status_mailres, render_param['mail.enumMailReserves'] = self._fn_enum_reserve(chain_env)
		#[begin] Support objects.
		#Fetch mail templates.
		status_tpl, render_param['mail.enumTemplates'] = self._fn_enum_templates(chain_env)
		# Joining.
		for mail_req in render_param['mail.enumMailRequests']:
			for mail_tpl in (render_param['mail.enumTemplates'] if render_param['mail.enumTemplates'] else []):
				if mail_req['template_id'] == mail_tpl['id']:
					mail_req['template'] = mail_tpl
		render_param.pop("mail.enumTemplates")
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] Support objects.
		chain_env['response_body'] = flask.render_template(\
			"mail.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"メール|SESクラウド",\
			current="mail.top")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_html_create_mail(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.engineer import Processor as P_ENGINEER
		from logics.client import Processor as P_CLIENT
		from logics.project import Processor as P_PROJECT
		from logics.manage import Processor as P_MANAGE
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch mail requests.
		status_mailreq, render_param['mail.enumMailRequests'] = self._fn_enum_mail_requests(chain_env)
		#Fetch mail templates.
		status_tpl, render_param['mail.enumTemplates'] = self._fn_enum_templates(chain_env)

		if ("type_recipient" in chain_env['argument'].data and chain_env['argument'].data['type_recipient'] == "forWorker"):
			render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in ((u"取引先担当者（既定）", u"取引先担当者")), render_param['mail.enumTemplates'])
		elif ("type_recipient" in chain_env['argument'].data and chain_env['argument'].data['type_recipient'] == "forEngineer"):
			render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in ((u"技術者（既定）", u"技術者")), render_param['mail.enumTemplates'])
		else :
			if ("engineers" in chain_env['argument'].data and chain_env['argument'].data["engineers"]):
				render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in ((u"マッチング")) and x['name'] in ((u"要員マッチング")), render_param['mail.enumTemplates'])
			else :
				render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in ((u"マッチング")) and x['name'] in ((u"案件マッチング")), render_param['mail.enumTemplates'])

		# render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in ((u"取引先担当者（既定）", u"取引先担当者") if ("type_recipient" in chain_env['argument'].data and chain_env['argument'].data['type_recipient'] == "forWorker") else (u"技術者（既定）", u"技術者")), render_param['mail.enumTemplates'])
		#[begin] Support objects.
		clean_env = copy.deepcopy(chain_env)
		clean_env['argument'].clear()
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(clean_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] Support_objects.
		chain_env['response_body'] = flask.render_template(\
			"mail_send2.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"メール作成|SESクラウド",\
			current="mail.createMail")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_html_create_reminder(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.engineer import Processor as P_ENGINEER
		from logics.client import Processor as P_CLIENT
		from logics.project import Processor as P_PROJECT
		from logics.manage import Processor as P_MANAGE
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch mail templates.
		status_tpl, render_param['mail.enumTemplates'] = self._fn_enum_templates(chain_env)
		render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in (u"リマインダー",), render_param['mail.enumTemplates'])
		#[begin] Support objects.
		clean_env = copy.deepcopy(chain_env)
		clean_env['argument'].clear()
		#status_engineer, render_param['engineer.enumEngineers'] = P_ENGINEER(self.__pref__)._fn_enum_engineers(clean_env)
		#status_worker, render_param['client.enumWorkers'] = P_CLIENT(self.__pref__)._fn_enum_workers(clean_env)
		#status_project, render_param['project.enumProjects'] = P_PROJECT(self.__pref__)._fn_enum_projects(clean_env)
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(clean_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] Support_objects.
		chain_env['response_body'] = flask.render_template(\
			"mail_send_reminder.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"リマインダー作成|SESクラウド",\
			current="mail.createReminder")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_html_create_quotation(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.manage import Processor as P_MANAGE
		from logics.engineer import Processor as P_ENGINEER
		from logics.project import Processor as P_PROJECT
		from logics.client import Processor as P_CLIENT
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch mail requests.
		status_mailreq, render_param['mail.enumMailRequests'] = self._fn_enum_mail_requests(chain_env)
		#Fetch mail templates.
		status_tpl, render_param['mail.enumTemplates'] = self._fn_enum_templates(chain_env)

		if ("type_recipient" in chain_env['argument'].data and chain_env['argument'].data['type_recipient'] == "forWorker") and ("quotation_type" in chain_env['argument'].data):
			if chain_env['argument'].data["quotation_type"] == "estimate":
				render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] == u"見積書", render_param['mail.enumTemplates'])
			if chain_env['argument'].data["quotation_type"] == "order":
				render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] == u"請求先注文書", render_param['mail.enumTemplates'])
			if chain_env['argument'].data["quotation_type"] == "invoice":
				render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] == u"請求書", render_param['mail.enumTemplates'])
			if chain_env['argument'].data["quotation_type"] == "purchase":
				render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] == u"注文書",render_param['mail.enumTemplates'])
		else:
			render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in ((u"見積書", u"請求先注文書", u"注文書", u"請求書")),render_param['mail.enumTemplates'])

		# render_param['mail.enumTemplates'] = filter(lambda x: x['type_recipient'] in ((u"取引先担当者（既定）", u"取引先担当者") if ("type_recipient" in chain_env['argument'].data and chain_env['argument'].data['type_recipient'] == "forWorker") else (u"技術者（既定）", u"技術者")), render_param['mail.enumTemplates'])
		#[begin] Support objects.
		clean_env = copy.deepcopy(chain_env)
		clean_env['argument'].clear()
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(clean_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(clean_env)

		status_projects, render_param['js.projects'] = P_PROJECT(self.__pref__)._fn_enum_projects_compact(chain_env)
		# status_projects, render_param['js.engineers'] = P_ENGINEER(self.__pref__)._fn_enum_engineers(chain_env)
		status_client, render_param['js.workers'] = P_CLIENT(self.__pref__)._fn_enum_workers_compact(clean_env)
		# status_client, render_param['js.users'] = P_MANAGE(self.__pref__)._fn_enum_user_companies()
		# status_client, render_param['js.members'] = render_param['manage.enumAccounts']

		# [begin] support objects.

		#[end] Support_objects.
		chain_env['response_body'] = flask.render_template(\
			"mail_send_quotation.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"メール作成|SESクラウド",\
			current="mail.createQuotation")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_simulate_mail_body(self, chain_env):

		"""
		Parameter(chain_env['argument'].data):
		  template_id(int): `id` field of `ft_mail_templates`.
		  type_title(unicode): "様" or "さま"
		  type_data(str): "engineers" or "projects"
		  data(list<int>): list has id of engineers or projects.
		"""
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		var_template = None
		var_data = None
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
			#Fetch template.
			param1 = (\
				args['template_id'],\
				chain_env['prefix'], args['login_id'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("simulate_enum_templates"), param1)
			except:
				chain_env['trace'].append(dbcur._executed)
				chain_env['trace'].append(traceback.format_exc())
			else:
				chain_env['trace'].append(dbcur._executed)
				var_template = dbcur.fetchone()[0] if dbcur.rowcount else None
			# Template replacement.
			#Fetch user profile.
			from logics.auth import Processor as P_AUTH
			status_profile, var_profile = P_AUTH(self.__pref__).read_user_profile(chain_env)
			#Fetch data.
			var_data = []
			var_bp_data = []
			var_data_sub = []
			var_bp_data_sub = []
			if "type_data" in args:
				tmp_datum = []
				clean_env = copy.deepcopy(chain_env)
				clean_env['argument'].clear()

				if args['type_data'] == "engineers":
					from logics.engineer import Processor as Logic
					tmp_status, tmp_datum = Logic(self.__pref__)._fn_enum_engineers(clean_env)
					var_data = [tmp_data for tmp_data in tmp_datum if tmp_data['id'] in args['data']]
					var_data_ids = [data["id"] for data in var_data]
					set_target_ids = set(args['data']) - set(var_data_ids)
					if len(set_target_ids) > 0:
						chain_env["argument"].data["engineer_ids"] = list(set_target_ids)
						tmp_bp_status, var_bp_data= Logic(self.__pref__)._fn_enum_bp_engineers(chain_env)
						var_data.extend(var_bp_data)
				elif args['type_data'] == "projects":
					from logics.project import Processor as Logic
					tmp_status, tmp_datum = Logic(self.__pref__)._fn_enum_projects(clean_env)
					var_data = [tmp_data for tmp_data in tmp_datum if tmp_data['id'] in args['data']]
					var_data_ids = [data["id"] for data in var_data]
					set_target_ids = set(args['data']) - set(var_data_ids)
					if len(set_target_ids) > 0:
						chain_env["argument"].data["project_ids"] = list(set_target_ids)
						tmp_bp_status, var_bp_data = Logic(self.__pref__)._fn_enum_bp_projects(chain_env)
						var_data.extend(var_bp_data)

				#add sub info
				if args['type_data'] == "projects" and len(args['engineer_ids'])!=0:
					from logics.engineer import Processor as Logic
					tmp_status, tmp_datum = Logic(self.__pref__)._fn_enum_engineers(clean_env)
					var_data_sub = [tmp_data for tmp_data in tmp_datum if tmp_data['id'] in args['engineer_ids']]
					if "type_recipient" in args and args['type_recipient'] == "forMatching" :
						var_data_ids = [data["id"] for data in var_data_sub]
					else :
						var_data_ids = [data["id"] for data in var_data]
					set_target_ids = set(chain_env["argument"].data["engineer_ids"]) - set(var_data_ids)
					if len(set_target_ids) > 0:
						chain_env["argument"].data["engineer_ids"] = list(set_target_ids)
						tmp_bp_status, var_bp_data_sub = Logic(self.__pref__)._fn_enum_bp_engineers(chain_env)
						var_data_sub.extend(var_bp_data_sub)

				elif args['type_data'] == "engineers" and len(args['project_ids'])!=0:
					from logics.project import Processor as Logic
					tmp_status, tmp_datum = Logic(self.__pref__)._fn_enum_projects(clean_env)
					var_data_sub = [tmp_data for tmp_data in tmp_datum if tmp_data['id'] in args['project_ids']]
					if "type_recipient" in args and args['type_recipient'] == "forMatching" :
						var_data_ids = [data["id"] for data in var_data_sub]
					else :
						var_data_ids = [data["id"] for data in var_data]
					set_target_ids = set(chain_env["argument"].data["project_ids"]) - set(var_data_ids)
					if len(set_target_ids) > 0:
						chain_env["argument"].data["project_ids"] = list(set_target_ids)
						tmp_bp_status, var_bp_data_sub = Logic(self.__pref__)._fn_enum_bp_projects(chain_env)
						var_data_sub.extend(var_bp_data_sub)
			pdffile_path = ""
			if "quotation_id" in args:
				chain_env['argument'].data["id"] = args["quotation_id"]
				if args["quotation_type"] == "estimate":
					from logics.estimate import Processor as Logic
					tmp_status, tmp_quotation_data = Logic(self.__pref__)._fn_enum_estimates_pdfinfo(chain_env)
					if tmp_quotation_data:
						pdffile_path = self.__pref__['DOMAIN'] +"/"+ chain_env['prefix']+ "/html/quotation.downloadPdfEstimate/" + tmp_quotation_data[0]["pdffile_path"]
				if args["quotation_type"] == "order":
					from logics.order import Processor as Logic
					tmp_status, tmp_quotation_data = Logic(self.__pref__)._fn_enum_orders_pdfinfo(chain_env)
					if tmp_quotation_data:
						pdffile_path = self.__pref__['DOMAIN'] + "/" + chain_env['prefix'] + "/html/quotation.downloadPdfOrder/" + tmp_quotation_data[0]["pdffile_path"]
				if args["quotation_type"] == "invoice":
					from logics.invoice import Processor as Logic
					tmp_status, tmp_quotation_data = Logic(self.__pref__)._fn_enum_invoices_pdfinfo(chain_env)
					if tmp_quotation_data:
						pdffile_path = self.__pref__['DOMAIN'] + "/" + chain_env['prefix'] + "/html/quotation.downloadPdfInvoice/" + tmp_quotation_data[0]["pdffile_path"]
				if args["quotation_type"] == "purchase":
					from logics.purchase import Processor as Logic
					tmp_status, tmp_quotation_data = Logic(self.__pref__)._fn_enum_purchases_pdfinfo(chain_env)
					if tmp_quotation_data:
						pdffile_path = self.__pref__['DOMAIN'] + "/" + chain_env['prefix'] + "/html/quotation.downloadPdfPurchase/" + tmp_quotation_data[0]["pdffile_path"]

			dbcur.close()
			dbcon.close()
			chain_env['logger']("webapi", ("PROCESSING",))
			#Convert database value to jinja2 template.
			cvt_rules = (\
				(re.compile(u"\[会社名\]"), """{{ profile.company.name }}"""),\
				(re.compile(u"\[営業担当者名\]"), """{{ profile.user.name }}"""),\
				(re.compile(u"\[技術者情報\]"), u"""\
{% if type_data == "engineers" -%}
{% for item in data -%}
【{{ loop.index }}】
  名前： {{ item.visible_name }}（{{ item.gender }}性{% if item.age %}・{{ item.age }}歳{% endif %}）
{% if item.station %}  最寄： {{ item.station }}
{% endif %}{% if item.fee %}  単価： {{ item.fee_comma }}
{% endif %}{% if item.skill_list %}  スキル： {{ item.skill_list }}
{% endif %}{% if item.skill %}  スキル(補足)： {{ item.skill }}
{% endif %}{% if item.operation_begin %}  稼働： {{ item.operation_begin }}
{% endif %}{% if item.contract %}  所属： {{ item.contract }}
{% endif %}{% if item.note %}  備考： {{ item.note or "" }}
{% endif %}
{% endfor %}
{% else %}
{% for item in data_sub -%}
【{{ loop.index }}】
  名前： {{ item.visible_name }}（{{ item.gender }}性{% if item.age %}・{{ item.age }}歳{% endif %}）
{% if item.station %}  最寄： {{ item.station }}
{% endif %}{% if item.fee %}  単価： {{ item.fee_comma }}
{% endif %}{% if item.skill_list %}  スキル： {{ item.skill_list }}
{% endif %}{% if item.skill %}  スキル(補足)： {{ item.skill }}
{% endif %}{% if item.operation_begin %}  稼働： {{ item.operation_begin }}
{% endif %}{% if item.contract %}  所属： {{ item.contract }}
{% endif %}{% if item.note %}  備考： {{ item.note or "" }}
{% endif %}
{% endfor %}
{% endif -%}
"""),\
(re.compile(u"\[技術者情報\(既定\)\]"), u"""\
{% if type_data == "engineers" -%}

以下、技術者向けの案件を探しております。
対応可能な案件がありましたら教えて頂きたく存じます。

{% for item in data -%}
【{{ loop.index }}】
  名前： {{ item.visible_name }}（{{ item.gender }}性{% if item.age %}・{{ item.age }}歳{% endif %}）
{% if item.station %}  最寄： {{ item.station }}
{% endif %}{% if item.fee %}  単価： {{ item.fee_comma }}
{% endif %}{% if item.skill_list %}  スキル： {{ item.skill_list }}
{% endif %}{% if item.skill %}  スキル(補足)： {{ item.skill }}
{% endif %}{% if item.operation_begin %}  稼働： {{ item.operation_begin }}
{% endif %}{% if item.contract %}  所属： {{ item.contract }}
{% endif %}{% if item.note %}  備考： {{ item.note or "" }}
{% endif %}
{% endfor %}
{% endif -%}
"""),\
(re.compile(u"\[リマインダー技術者情報\]"), u"""\
{% if type_data == "engineers" -%}
{% for item in data %}
【{{ loop.index }}】
  氏名： {{ item.name }}({{ item.visible_name }}：{{ item.gender }}性{% if item.age %}・{{ item.age }}歳{% endif %})
{% if item.station %}  最寄： {{ item.station }}
{% endif %}{% if item.fee %}  単価： {{ item.fee_comma }}
{% endif %}{% if item.skill_list %}  スキル： {{ item.skill_list }}
{% endif %}{% if item.skill %}  スキル(補足)： {{ item.skill }}
{% endif %}{% if item.contract %}  所属： {{ item.contract }}
{% endif %}{% if item.note %}  備考： {{ item.note or "" }}
{% endif %}
{% endfor %}
{% endif -%}
"""),\
(re.compile(u"\[案件情報\]"), u"""\
{% if type_data == "projects" -%}
{% for item in data -%}
【{{ loop.index }}】
{% if item.title %}  案件: {{ item.title }}
{% endif %}{% if item.process %}  工程: {{ item.process }}
{% endif %}{% if item.station %}  最寄: {{ item.station }}
{% endif %}{% if item.term_begin or item.term_end %}  期間: {% if item.term_begin %}{{ item.term_begin }}{% endif %} -  {% if item.term_end %}{{ item.term_end }}{% endif %}
{% endif %}{% if item.fee_outbound %}  単価: {{ item.fee_outbound_comma }}
{% endif %}{% if item.skill_list %}  要求スキル: {{ item.skill_list }}
{% endif %}{% if item.skill_needs %}  スキル補足: {{ item.skill_needs }}
{% endif %}{% if item.skill_recommends %}  スキル（尚可）補足: {{ item.skill_recommends }}
{% endif %}{% if item.expense %}  精算条件： {{ item.expense }}
{% endif %}{% if item.scheme %}  商流： {{ item.scheme }}
{% endif %}{% if item.interview %}  面談回数： {{ item.interview }}回
{% endif %}{% if (item.flg_foreign == 0 or item.flg_foreign == 1) %}  外国籍: {% endif %} {% if item.flg_foreign == 1 %} 可\n{% elif item.flg_foreign == 0 %} 不可\n
{% endif %}{% if item.note %}  備考： {{ item.note }}
{% endif %}
{% endfor %}
{% else %}
{% for item in data_sub -%}
【{{ loop.index }}】
{% if item.title %}  案件: {{ item.title }}
{% endif %}{% if item.process %}  工程: {{ item.process }}
{% endif %}{% if item.station %}  最寄: {{ item.station }}
{% endif %}{% if item.term_begin or item.term_end %}  期間: {% if item.term_begin %}{{ item.term_begin }}{% endif %} -  {% if item.term_end %}{{ item.term_end }}{% endif %}
{% endif %}{% if item.fee_outbound %}  単価: {{ item.fee_outbound_comma }}
{% endif %}{% if item.skill_list %}  要求スキル: {{ item.skill_list }}
{% endif %}{% if item.skill_needs %}  スキル補足: {{ item.skill_needs }}
{% endif %}{% if item.skill_recommends %}  スキル（尚可）補足: {{ item.skill_recommends }}
{% endif %}{% if item.expense %}  精算条件： {{ item.expense }}
{% endif %}{% if item.scheme %}  商流： {{ item.scheme }}
{% endif %}{% if item.interview %}  面談回数： {{ item.interview }}回
{% endif %}{% if item.note %}  備考： {{ item.note }}
{% endif %}
{% endfor %}
{% if type_recipient == "forMatching" %}【御社要員】
{% endif %}
{% endif -%}
"""),\
(re.compile(u"\[案件情報\(既定\)\]"), u"""\
{% if type_data == "projects" -%}

以下、案件に対応可能な技術者を探しております。
対応可能な方おりましたらご提案をお願いします。

{% for item in data -%}
【{{ loop.index }}】
{% if item.title %}  案件: {{ item.title }}
{% endif %}{% if item.process %}  工程: {{ item.process }}
{% endif %}{% if item.station %}  最寄: {{ item.station }}
{% endif %}{% if item.term_begin or item.term_end %}  期間: {% if item.term_begin %}{{ item.term_begin }}{% endif %} -  {% if item.term_end %}{{ item.term_end }}{% endif %}
{% endif %}{% if item.fee_outbound %}  単価: {{ item.fee_outbound_comma }}
{% endif %}{% if item.skill_list %}  要求スキル: {{ item.skill_list }}
{% endif %}{% if item.skill_needs %}  スキル補足: {{ item.skill_needs }}
{% endif %}{% if item.skill_recommends %}  スキル（尚可）補足: {{ item.skill_recommends }}
{% endif %}{% if item.expense %}  精算条件： {{ item.expense }}
{% endif %}{% if item.scheme %}  商流： {{ item.scheme }}
{% endif %}{% if item.interview %}  面談回数： {{ item.interview }}回
{% endif %}{% if (item.flg_foreign == 0 or item.flg_foreign == 1) %}  外国籍: {% endif %} {% if item.flg_foreign == 1 %} 可\n{% elif item.flg_foreign == 0 %} 不可\n
{% endif %}{% if item.note %}  備考： {{ item.note }}
{% endif %}
{% endfor %}
{% endif -%}
"""),\
(re.compile(u"\[帳票案件情報\]"), u"""\
{% if type_data == "projects" -%}
{% for item in data -%}
【{{ loop.index }}】
{% if item.title %}  案件: {{ item.title }}
{% endif %}{% if item.process %}  工程: {{ item.process }}
{% endif %}{% if item.station %}  最寄: {{ item.station }}
{% endif %}{% if item.term_begin or item.term_end %}  期間: {% if item.term_begin %}{{ item.term_begin }}{% endif %} -  {% if item.term_end %}{{ item.term_end }}{% endif %}
{% endif %}{% if item.fee_outbound %}  単価: {{ item.fee_outbound_comma }}
{% endif %}{% if item.skill_list %}  要求スキル: {{ item.skill_list }}
{% endif %}{% if item.skill_needs %}  スキル補足: {{ item.skill_needs }}
{% endif %}{% if item.skill_recommends %}  スキル（尚可）補足: {{ item.skill_recommends }}
{% endif %}{% if item.expense %}  精算条件： {{ item.expense }}
{% endif %}{% if item.scheme %}  商流： {{ item.scheme }}
{% endif %}{% if (item.flg_foreign == 0 or item.flg_foreign == 1) %}  外国籍: {% endif %} {% if item.flg_foreign == 1 %} 可\n{% elif item.flg_foreign == 0 %} 不可\n
{% endif %}{% if item.note %}  備考： {{ item.note }}
{% endif %}
{% endfor %}
{% else %}
{% for item in data_sub -%}
【{{ loop.index }}】
{% if item.title %}  案件: {{ item.title }}
{% endif %}{% if item.process %}  工程: {{ item.process }}
{% endif %}{% if item.station %}  最寄: {{ item.station }}
{% endif %}{% if item.term_begin or item.term_end %}  期間: {% if item.term_begin %}{{ item.term_begin }}{% endif %} -  {% if item.term_end %}{{ item.term_end }}{% endif %}
{% endif %}{% if item.fee_outbound %}  単価: {{ item.fee_outbound_comma }}
{% endif %}{% if item.skill_list %}  要求スキル: {{ item.skill_list }}
{% endif %}{% if item.skill_needs %}  スキル補足: {{ item.skill_needs }}
{% endif %}{% if item.skill_recommends %}  スキル（尚可）補足: {{ item.skill_recommends }}
{% endif %}{% if item.expense %}  精算条件： {{ item.expense }}
{% endif %}{% if item.scheme %}  商流： {{ item.scheme }}
{% endif %}{% if (item.flg_foreign == 0 or item.flg_foreign == 1) %}  外国籍: {% endif %} {% if item.flg_foreign == 1 %} 可\n{% elif item.flg_foreign == 0 %} 不可\n
{% endif %}{% if item.note %}  備考： {{ item.note }}
{% endif %}
{% endfor %}
{% if type_recipient == "forMatching" %}【御社要員】
{% endif %}
{% endif -%}
"""),\
(re.compile(u"\[リマインダー案件情報\]"), u"""\
{% if type_data == "projects" -%}
{% for item in data -%}
【{{ loop.index }}】
{% if item.title -%}  案件： {{ item.title }}
{% endif -%}{% if item.station -%}  最寄： {{ item.station }}
{% endif %}{% if item.term_begin or item.term_end %}  期間: {% if item.term_begin %}{{ item.term_begin }}{% endif %} -  {% if item.term_end %}{{ item.term_end }}{% endif %}
{% endif %}{% if item.skill_list %}  要求スキル: {{ item.skill_list }}
{% endif %}{% if item.skill_needs %}  スキル補足: {{ item.skill_needs }}
{% endif %}{% if item.skill_recommends %}  スキル（尚可）補足: {{ item.skill_recommends }}
{% endif -%}{% if item.fee_inbound -%}  単価： {{ item.fee_inbound_comma }}
{% endif -%}{% if item.expense -%}  精算条件： {{ item.expense }}
{% endif -%}{% if item.scheme -%}  商流： {{ item.scheme }}
{% endif -%}{% if item.interview -%}  面談回数： {{ item.interview }}回
{% endif -%}{% if (item.flg_foreign == 0 or item.flg_foreign == 1) %}  外国籍: {% endif %} {% if item.flg_foreign == 1 %} 可\n{% elif item.flg_foreign == 0 %} 不可\n
{% endif -%}{% if item.note -%}  備考： {{ item.note }}
{% endif -%}{% if item.client_name or item.client.name -%}  取引先： {{ item.client_name or item.client.name }}
{% endif %}
{% endfor %}
{% endif -%}
"""),\
(re.compile(u"\[署名\]"), """{{ signature }}"""),\
(re.compile(u"\[PDFダウンロードURL\]"), """{{ pdffile_path }}"""),\
				)
			#print var_template
			if var_template:
				for regex, tpl in cvt_rules:
					var_template = tpl.join(regex.split(var_template))
			#print var_template
			#Convert template.
			var_body = Environment().from_string(var_template, {
				"type_title": args['type_title'] if "type_title" in args else u"様",\
				"signature": chain_env['limit']['MAIL_SIGNATURE'] if "MAIL_SIGNATURE" in chain_env['limit'] else "", \
				"pdffile_path": pdffile_path if pdffile_path else "",\
				"profile": var_profile,\
				"data": var_data,\
				"data_sub": var_data_sub,\
				"type_data": args['type_data'] if "type_data" in args else "",\
				"type_recipient": args['type_recipient'] if "type_recipient" in args else "",\
			}).render()
			if "template_id" in args:
				result['template_id'] = args['template_id']
			result['type_title'] = args['type_title']
			result['type_data'] = args['type_data']
			result['profile'] = var_profile
			result['signature'] = chain_env['limit']['MAIL_SIGNATURE']
			result['data'] = var_data
			result['body'] = var_body
			status['code'] = 0
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_mail_requests(self, chain_env):
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
			param = (\
				chain_env['prefix'], args['login_id'], args['credential'],\
				chain_env['prefix'], args['login_id'],\
				chain_env['prefix'], args['login_id'],\
			)
			try:
				dbcur.execute(Model.sql("enum_mail_requests_compact") % (\
					("`R`.`id` IN (%s)" % ", ".join(map(str, args['id_list']))) if "id_list" in args else "TRUE", "LIMIT 20" if "id_list" not in args else "",)\
					, param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc())
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				chain_env['status']['code'] = 2
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				chain_env['logger']("webapi", ("PROCESSING", unicode(dbcur._executed, "utf8"),))
				res1 = Model.convert("enum_mail_request_compact", dbcur)
				self.my_log("__res1__" + JSON.dumps(res1))
				#Join users.
				user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['replyto']['id'] if entity['replyto'] else None,) for entity in res1] for e in p if e]))
				if user_list:
					dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
					chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
					res2 = Model.convert("enum_users", dbcur)
				else:
					res2 = []
				for tmp_obj in res2:
					[entity['creator'].update(tmp_obj) for entity in res1 if entity['creator']['id'] == tmp_obj['id']]
				for tmp_obj in res2:
					[entity['replyto'].update(tmp_obj) for entity in res1 if entity['replyto'] and entity['replyto']['id'] == tmp_obj['id']]
				chain_env['logger']("webapi", ("PROCESSING",))
				#Join clients.
				addr_to_worker_list = []
				for entity in res1:
					for addr_to in entity['addr_to']:
						if "worker_id" in addr_to:
							addr_to_worker_list.append(addr_to['worker_id'])
				addr_to_worker_list = set(addr_to_worker_list)
				chain_env['logger']("webapi", ("PROCESSING",))
				if addr_to_worker_list:
					try:
						dbcur.execute("""\
SELECT
  `W`.`id`,
  `C`.`id`,
  `C`.`name`
  FROM `mt_clients` AS `C`
  INNER JOIN `mt_client_workers` AS `W`
    ON `W`.`client_id` = `C`.`id`
  WHERE
    `W`.`id` IN (%s)
    AND `C`.`is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `C`.`creator_id`, `W`.`modifier_id`)
    AND valid_acl(%%s, %%s, `W`.`creator_id`, `W`.`modifier_id`)
    AND valid_user_id_read(%%s, %%s, %%s);""" % ", ".join(map(lambda x: str(x), addr_to_worker_list)), (\
							chain_env['prefix'], chain_env['login_id'],\
							chain_env['prefix'], chain_env['login_id'],\
							chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
						))
					except:
						print traceback.format_exc()
						res3 = []
					else:
						chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
						chain_env['logger']("webapi", ("PROCESSING", unicode(dbcur._executed, "utf8"),))
						res3 = Model.convert("enum_client_simple", dbcur)
					for entity in res1:
						for addr_to in entity['addr_to']:
							if "worker_id" in addr_to:
								addr_to['client'] = res3[addr_to['worker_id']] if addr_to['worker_id'] in res3 else None
				result = res1
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_send_mail_request_ex_async(self, chain_env):
		time_bg = time.time()
		# chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		print "### start _fn_send_mail_request_ex_async"
		result = {}
		status = {"code": None, "description": None}
		d = multiprocessing.Process(name='mail_daemon', target=self._fn_send_mail_request_ex,args=(chain_env,))
		d.daemon = True
		d.start()
		status['code'] = 0
		chain_env['results'] = result
		chain_env['status'] = status
		# chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		# pprint.pprint(chain_env['trace']) if chain_env['trace'] else None  # DEBUG CODE
		# self.perf_time(chain_env, time.time() - time_bg)
		print "### end _fn_send_mail_request_ex_async"
		return status, result

	def _fn_send_mail_request_ex(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		#[begin] Fetch user profile.
		from logics.auth import Processor as P_AUTH
		status_profile, userProfile = P_AUTH(self.__pref__).read_user_profile(chain_env)
		from logics.manage import Processor as P_MANAGE
		status_users, data_accounts = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#[end] Fetch user profile.
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
			mail_req_id = {"id": None}
			param1 = (\
				JSON.dumps(args['addr_to_list']),\
				JSON.dumps(args['addr_cc'] if "addr_cc" in args else []),\
				JSON.dumps(args['addr_bcc'] if "addr_bcc" in args else []),\
				args['id_replyto'] if "id_replyto" in args and args['id_replyto'] in map(lambda x: x['id'], data_accounts) else userProfile['user']['id'],\
				args['type_title'], args['tpl_id'], args['subject'], args['body'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("send_mail_request"), param1)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)
				dbcur.execute(Model.sql("last_insert_id"))
				mail_req_id = Model.convert("last_insert_id", dbcur)
				#[begin] attachments.
				if "attachments" in args and args['attachments']:
					attachment_id_list = ", ".join(map(lambda x: str(x), args['attachments']))
					param2 = (
						mail_req_id['id'],\
						chain_env['prefix'], args['login_id'],\
					)
					param3 = (
						chain_env['prefix'], args['login_id'],\
						chain_env['prefix'], args['login_id'], args['credential'],\
					)
					try:
						dbcur.execute(Model.sql("send_mail_request_insert_attachments") % attachment_id_list, param2)
					except Exception, err:
						status['code'] = 2
						chain_env['trace'].append(traceback.format_exc())
					try:
						dbcur.execute(Model.sql("send_mail_request_update_attachments") % attachment_id_list, param3)
					except Exception, err:
						status['code'] = 2
						chain_env['trace'].append(traceback.format_exc())
				#[end] attachments.
				if status['code'] is None:
					status['code'] = 0
					dbcon.commit()
				else:
					dbcon.rollback()
				#[begin] Generate mail messages into queue.
				if status['code'] == 0:
					msg_list, tmp_trace = self.__gen_mail_messages(dbcur, mail_req_id['id'], userProfile, chain_env)
					if tmp_trace:
						chain_env['trace'] += tmp_trace
					if msg_list:
						tmp_trace = self.__store_mail_messages(dbcon, dbcur, mail_req_id['id'], args['subject'], msg_list, chain_env['prefix'], chain_env['login_id'], chain_env['credential'], map(lambda x: x['worker_id'], args['addr_to_list']) if args['addr_to_list'] and "worker_id" in args['addr_to_list'][0] else None)
						if tmp_trace:
							chain_env['trace'] += tmp_trace
				#[end] Generate mail messages into queue.
				result = mail_req_id
				status['code'] = status['code'] or 0
			dbcur.close()
			dbcon.close()
		if "quotation_id" in args:
			self._fn_update_send_flg(chain_env)

		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		pprint.pprint(chain_env['trace']) if chain_env['trace'] else None#DEBUG CODE
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_send_mail_reserve(self, chain_env):
		time_bg = time.time()
		self.my_log('_fn_send_mail_reserve')
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		#[begin] Fetch user profile.
		from logics.auth import Processor as P_AUTH
		status_profile, userProfile = P_AUTH(self.__pref__).read_user_profile(chain_env)
		from logics.manage import Processor as P_MANAGE
		status_users, data_accounts = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#[end] Fetch user profile.
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
			mail_req_id = {"id": None}
			param1 = (\
				JSON.dumps(args['addr_to_list']),\
				JSON.dumps(args['addr_cc'] if "addr_cc" in args else []),\
				JSON.dumps(args['addr_bcc'] if "addr_bcc" in args else []),\
				args['id_replyto'] if "id_replyto" in args and args['id_replyto'] in map(lambda x: x['id'], data_accounts) else userProfile['user']['id'],\
				args['type_title'], args['tpl_id'], args['subject'], args['body'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("send_mail_request"), param1)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)
				dbcur.execute(Model.sql("last_insert_id"))
				mail_req_id = Model.convert("last_insert_id", dbcur)
				self.my_log('mail_req_id: ' + str(mail_req_id))
				#[begin] attachments.
				if "attachments" in args and args['attachments']:
					attachment_id_list = ", ".join(map(lambda x: str(x), args['attachments']))
					param2 = (
						mail_req_id['id'],\
						chain_env['prefix'], args['login_id'],\
					)
					param3 = (
						chain_env['prefix'], args['login_id'],\
						chain_env['prefix'], args['login_id'], args['credential'],\
					)
					self.my_log('before save attachment')
					try:
						dbcur.execute(Model.sql("send_mail_request_insert_attachments") % attachment_id_list, param2)
					except Exception, err:
						status['code'] = 2
						chain_env['trace'].append(traceback.format_exc())
						self.my_log(traceback.format_exc())
					try:
						dbcur.execute(Model.sql("send_mail_request_update_attachments") % attachment_id_list, param3)
					except Exception, err:
						status['code'] = 2
						chain_env['trace'].append(traceback.format_exc())
						self.my_log(traceback.format_exc())
				#[end] attachments.
				if status['code'] is None:
					status['code'] = 0
					dbcon.commit()
				else:
					dbcon.rollback()

				self.my_log('_fn_send_mail_reserve: before save time')
				#[begin] Save mail_req_id and scheduled_time.
				if status['code'] == 0:
					from logics.manage import Processor as P_MANAGE
					status_users, data_accounts = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
					msg = {}
					def add_replyto():
						#[begin] Reply-To.
						self.my_log('add_replyto')
						try:
							mail_req = {}
							dbcur.execute(Model.sql("gen_mail_messages_enum_mail_req"), (mail_req_id['id'],))
							for idx, tmp in enumerate(dbcur):
								if idx == 0:
									mail_req['id_replyto'] = int(tmp[13]) if tmp[13] else None

							if mail_req['id_replyto'] and mail_req['id_replyto'] in map(lambda x: x['id'], data_accounts):
								msg['Reply-To'] = email.utils.formataddr((Header(filter(lambda x: x['id'] == mail_req['id_replyto'], data_accounts)[0]['name'], self.__pref__['MAIL_CHARSET']).encode(), filter(lambda x: x['id'] == mail_req['id_replyto'], data_accounts)[0]['mail1']))
								msg['X-GWCUSTOM-REPLY'] = '1'
							else:
								msg['Reply-To'] = email.utils.formataddr((Header(userProfile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), userProfile['user']['mail1']))
								msg['X-GWCUSTOM-REPLY'] = '0'
						except Exception, err:
							self.my_log('add_replyto: Exception: ' + traceback.format_exc(err))
						#[end] Reply-To.
					add_replyto()

					self.my_log('_fn_send_mail_reserve: before param4')
					status['code'] = None
					self.my_log('req_id' + str(mail_req_id['id']))
					self.my_log('time' + args['schedule_time'][0])
					self.my_log('profile' + str(userProfile['user']))
					self.my_log('reply_to' + msg['Reply-To'])
					self.my_log('x_gwcustom_reply' + msg['X-GWCUSTOM-REPLY'])
					param4 = (
						str(mail_req_id['id']),\
						args['schedule_time'][0],\
						JSON.dumps(userProfile['user']),\
						msg['Reply-To'],\
						msg['X-GWCUSTOM-REPLY'],\
					)
					try:
						dbcur.execute(Model.sql("save_mail_reserve_time"), param4)
					except Exception, err:
						status['code'] = 2
						chain_env['trace'].append(traceback.format_exc())
						self.my_log('_fn_send_mail_reserve: exception: ' + traceback.format_exc())
					if status['code'] is None:
						status['code'] = 0
						dbcon.commit()
					else:
						dbcon.rollback()
				#[end] Save mail_req_id and scheduled_time.
				self.my_log('after Save mail_req_id and scheduled_time')

				result = mail_req_id
				status['code'] = status['code'] or 0

			dbcur.close()
			dbcon.close()
		if "quotation_id" in args:
			self._fn_update_send_flg(chain_env)

		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def send_current_mails(self):
		result = {}
		status = {"code": None, "description": None}
		dbcur = None
		dbcon, db_err_list = self.connect_db()

		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		
		if dbcur:
			try:
				now = datetime.datetime.now()
				param1 = (\
					now.strftime("%Y-%m-%d %H:%M:00"),\
				)
				dbcur.execute(Model.sql("get_current_reserve"), param1)
				result = Model.convert("get_current_reserve", dbcur)
			except Exception, err:
				status['code'] = 2
				self.my_log('send_current_mails:sql exception1:' + traceback.format_exc())
			else:
				if status['code'] is None:
					status['code'] = 0
					dbcon.commit()
				else:
					dbcon.rollback()
				
				if result:
					# self.my_log("before update")
					# sqlStr = """UPDATE `ft_mails_time` SET mail_sent = '1' WHERE id IN ("""
					# moreThanOneEntity = False
					# for entity in result:
					# 	sqlStr += "'" + str(entity['id']) + "',"
					# 	moreThanOneEntity = True
					
					# self.my_log(sqlStr)

					# if moreThanOneEntity:
					# 	sqlStr = sqlStr[:-1] + """);"""
					# 	self.my_log(sqlStr)
					# 	try:
					# 		dbcur.execute(sqlStr)
					# 	except Exception, err:
					# 		self.my_log('update sql exception:' + traceback.format_exc())
					# 	else:
					# 		dbcon.commit()

					try:
						for entity in result:
							msg_list, tmp_trace = self.__gen_mail_messages2(dbcur, entity['mail_req_id'], entity['user_profile'], entity['reply_to'], entity['x_gwcustom_reply'])
							if msg_list:
								tmp_trace = self.__store_mail_messages2(dbcon, dbcur, entity['mail_req_id'], entity['subject'], msg_list, map(lambda x: x['worker_id'], entity['addr_to_list']) if entity['addr_to_list'] and "worker_id" in entity['addr_to_list'][0] else None, None, entity['id'])

					except Exception, err:
						status['code'] = 2
						self.my_log('send_current_mails:sql exception2:' + traceback.format_exc())

			dbcur.close()
			dbcon.close()
		
		return status, result

	def _fn_get_reserved_mails_count(self, chain_env):
		status = {"code": None, "description": None}
		result = {}

		from logics.auth import Processor as P_AUTH
		status_profile, userProfile = P_AUTH(self.__pref__).read_user_profile(chain_env)

		dbcur = None
		dbcon, db_err_list = self.connect_db()

		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		
		if dbcur:
			try:
				param = (\
					userProfile['user']['id'],\
				)
				dbcur.execute(Model.sql("get_reserved_mails_count"), param)
				chain_env['results'] = result = {"body": str(Model.convert("get_reserved_mails_count", dbcur))}
				self.my_log('get_reserved_mails_count: ' + str(result))
			except Exception, err:
				chain_env['status']['code'] = 2
				self.my_log('sql exception:' + traceback.format_exc())
			else:
				if status['code'] is None:
					chain_env['status']['code'] = status['code'] = 0

			dbcur.close()
			dbcon.close()

		result = chain_env['results']
		
		return status, result

	def _fn_simulate_mail_par_client(self, chain_env):
		""" chain_env['argument'] = {
				"addr_to_list":[{"name":u"","mail":"","worker_id":0,"client_id":0,"recipient_priority":0},],
				"type_title":u"",
				"body":u""}
			"""
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		#[begin] Fetch user profile.
		from logics.auth import Processor as P_AUTH
		status_profile, userProfile = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#[end] Fetch user profile.
		result = {}
		status = {"code": 0, "description": None}
		args = chain_env['argument'].data
		result = self.__gen_simulate_mail_message_per_client(args['addr_to_list'], args['type_title'], args['body'])
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def __gen_simulate_mail_message_per_client(self, addr_to_list, type_title, body):
		result = {}
		result["addr_to_list"] = addr_to_list
		addr_to_str = ""
		client_group_strs = map(lambda (gname,to_str):"\n".join((gname,to_str) if gname else (to_str,))
			,map(lambda (gname,to_lst):(gname, "\n".join("%s %s"%(addr['name'], type_title) for addr in to_lst))
			,itertools.groupby(addr_to_list, key=lambda addr:addr.get('client_name', "") )))
		addr_to_str = "\n\n".join(client_group_strs)
		result["body"] = re.sub(u"\[宛名\]", addr_to_str , body)
		return result

	def __gen_mail_messages(self, cur, mail_req_id, profile, chain_env):
		import MySQLdb as DBS
		from email import encoders
		from email.header import Header
		from email.message import Message
		from email.mime.base import MIMEBase
		from email.mime.multipart import MIMEMultipart
		from email.mime.text import MIMEText
		def add_replyto():
			#[begin] Reply-To.
			if mail_req['id_replyto'] and mail_req['id_replyto'] in map(lambda x: x['id'], data_accounts):
				msg['Reply-To'] = email.utils.formataddr((Header(filter(lambda x: x['id'] == mail_req['id_replyto'], data_accounts)[0]['name'], self.__pref__['MAIL_CHARSET']).encode(), filter(lambda x: x['id'] == mail_req['id_replyto'], data_accounts)[0]['mail1']))
				msg['X-GWCUSTOM-REPLY'] = '1'
			else:
				msg['Reply-To'] = email.utils.formataddr((Header(profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), profile['user']['mail1']))
				msg['X-GWCUSTOM-REPLY'] = '0'
			#[end] Reply-To.
		mail_req = {}
		msg_list = []
		trace = []
		from logics.manage import Processor as P_MANAGE
		status_users, data_accounts = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		MYSQL_PREF = self.__pref__['MYSQL_HOSTS'][len(self.__pref__['MYSQL_HOSTS']) % self.__pref__['MYSQL_MODULO']]
		if "buffered" in MYSQL_PREF:
			del MYSQL_PREF['buffered']
		if "collation" in MYSQL_PREF:
			del MYSQL_PREF['collation']
		dbcon = DBS.connect(**MYSQL_PREF)
		dbcur = dbcon.cursor()
		try:
			dbcur.execute(Model.sql("gen_mail_messages_enum_mail_req"), (mail_req_id,))
		except:
			#trace.append(traceback.format_exc())
			trace.append(dbcur._executed)
			print traceback.format_exc()
		else:
			for idx, tmp in enumerate(dbcur):
				#if dbcur.rownumber == 1:
				if idx == 0:
					mail_req['id'] = tmp[0]
					mail_req['addr_to'] = JSON.loads(tmp[1])
					mail_req['addr_cc'] = JSON.loads(tmp[2])
					mail_req['addr_bcc'] = JSON.loads(tmp[3])
					mail_req['type_title'] = tmp[4]
					mail_req['subject'] = tmp[5]
					mail_req['body_tpl'] = tmp[6]
					mail_req['tpl_id'] = tmp[11]
					mail_req['tpl_type_recipient'] = tmp[12]
					mail_req['id_replyto'] = int(tmp[13]) if tmp[13] else None
					mail_req['attachments'] = []
				mail_req['attachments'].append({\
					"id": tmp[7],\
					"type_mime": tmp[8],\
					"name": tmp[9],\
					"value": tmp[10],\
				})
			mail_req['attachments'] = filter(lambda x: x['id'], mail_req['attachments'])
			#[begin] Generate MailMessage object.
			if mail_req['tpl_type_recipient'] == u"リマインダー":
				msg = MIMEMultipart()
				msg['Subject'] = Header(mail_req['subject'], self.__pref__['MAIL_CHARSET'])
				if mail_req['addr_cc']:
					mail_req['addr_to'] += mail_req['addr_cc']
				msg['To'] = ",".join(map(lambda x: email.utils.formataddr((Header(x['name'], self.__pref__['MAIL_CHARSET']).encode(), x['mail'])), mail_req['addr_to']))
				if self.__switch_replace_envelope:
					msg['From'] = email.utils.formataddr((Header(profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), profile['user']['mail1']))
				else:
					msg['From'] = email.utils.formataddr((Header(profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), self.__pref__['MAIL_SENDER_ADDR']))
				add_replyto()#Reply-To header construction.
				msg['Date'] = formatdate(localtime=True)
				msg_pt_txt = MIMEText(Environment().from_string(mail_req['body_tpl']).render().encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
				msg.attach(msg_pt_txt)
				for attachment in mail_req['attachments']:
					if attachment:
						if "type_mime" in attachment and attachment['type_mime']:
							type_main, type_sub = attachment['type_mime'].split("/")
						else:
							continue
						attachment_obj = MIMEBase(type_main, type_sub)
						attachment_obj.add_header('Content-Disposition', 'attachment', filename=Header(attachment['name'], self.__pref__['MAIL_CHARSET']).encode())
						attachment_obj.set_payload(attachment['value'])
						encoders.encode_base64(attachment_obj)
						msg.attach(attachment_obj)
				msg_list.append(msg)
			elif mail_req['tpl_type_recipient'] in (u"取引先担当者（既定）", u"取引先担当者", u"マッチング",u"見積書",u"請求先注文書",u"注文書",u"請求書",):
				sorted_list = sorted(mail_req['addr_to'], key=lambda addr:(addr['client_id'], addr['recipient_priority'],))
				for gid, lst in itertools.groupby(sorted_list, key=lambda addr:addr['client_id']):
					d = self.__gen_simulate_mail_message_per_client([addr for addr in lst], mail_req['type_title'], mail_req['body_tpl'])
					addr_list = d["addr_to_list"]
					body = d["body"]
					msg = MIMEMultipart()
					msg['Subject'] = Header(mail_req['subject'], self.__pref__['MAIL_CHARSET'])
					msg['To'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in addr_list)
					msg['Cc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_cc'])
					msg['Bcc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_bcc'])
					if self.__switch_replace_envelope:
						msg['From'] = email.utils.formataddr((Header(profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), profile['user']['mail1']))
					else:
						msg['From'] = email.utils.formataddr((Header(profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), self.__pref__['MAIL_SENDER_ADDR']))
					add_replyto()#Reply-To header construction.
					msg['Date'] = formatdate(localtime=True)
					msg_pt_txt = MIMEText(Environment().from_string(body).render().encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
					msg.attach(msg_pt_txt)
					for attachment in mail_req['attachments']:
						if attachment:
							if "type_mime" in attachment and attachment['type_mime']:
								type_main, type_sub = attachment['type_mime'].split("/")
							else:
								continue
							attachment_obj = MIMEBase(type_main, type_sub)
							attachment_obj.add_header('Content-Disposition', 'attachment', filename=Header(attachment['name'], self.__pref__['MAIL_CHARSET']).encode())
							attachment_obj.set_payload(attachment['value'])
							encoders.encode_base64(attachment_obj)
							msg.attach(attachment_obj)
					msg_list.append(msg)
			elif mail_req['tpl_type_recipient'] in (u"技術者（既定）", u"技術者",):
				for addr_to in mail_req['addr_to']:
					d = self.__gen_simulate_mail_message_per_client([addr_to,], mail_req['type_title'], mail_req['body_tpl'])
					addr_list = d["addr_to_list"]
					body = d["body"]
					msg = MIMEMultipart()
					msg['Subject'] = Header(mail_req['subject'], self.__pref__['MAIL_CHARSET'])
					msg['To'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in addr_list)
					msg['Cc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_cc'])
					msg['Bcc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_bcc'])
					if self.__switch_replace_envelope:
						msg['From'] = email.utils.formataddr((Header(profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), profile['user']['mail1']))
					else:
						msg['From'] = email.utils.formataddr((Header(profile['user']['name'], self.__pref__['MAIL_CHARSET']).encode(), self.__pref__['MAIL_SENDER_ADDR']))
					add_replyto()#Reply-To header construction.
					msg['Date'] = formatdate(localtime=True)
					msg_pt_txt = MIMEText(Environment().from_string(body).render().encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
					msg.attach(msg_pt_txt)
					for attachment in mail_req['attachments']:
						if attachment:
							if "type_mime" in attachment and attachment['type_mime']:
								type_main, type_sub = attachment['type_mime'].split("/")
							else:
								continue
							attachment_obj = MIMEBase(type_main, type_sub)
							attachment_obj.add_header('Content-Disposition', 'attachment', filename=Header(attachment['name'], self.__pref__['MAIL_CHARSET']).encode())
							attachment_obj.set_payload(attachment['value'])
							encoders.encode_base64(attachment_obj)
							msg.attach(attachment_obj)
					msg_list.append(msg)
			else:
				pass
			#[end] Generate mailMessage object.
		dbcon.close()
		return msg_list, trace

	def __store_mail_messages(self, con, cur, mail_req_id, mail_subject, msg_list, prefix, login_id, credential, worker_list=None):
		trace = []
		flg_commit = True
		#
		import MySQLdb as DBS2
		try:
			con = DBS2.connect(**self.__pref__['MYSQL_HOSTS'][len(self.__pref__['MYSQL_HOSTS']) % self.__pref__['MYSQL_MODULO']])
		except:
			con = None
		if con:
			cur = con.cursor()
		else:
			cur = None
		#
		for idx, msg in enumerate(msg_list):
			recipients = []
			recipients += map(lambda x: email.utils.parseaddr(x)[1], msg['To'].split(","))
			recipients += map(lambda x: email.utils.parseaddr(x)[1], msg['Cc'].split(",")) if "Cc" in msg else []
			recipients += map(lambda x: email.utils.parseaddr(x)[1], msg['Bcc'].split(",")) if "Bcc" in msg else []
			try:
				print "### start insert mail msg: " + str(idx)
				cur.execute(Model.sql("gen_mail_messages_insert_mail_msg"), (\
					mail_req_id,\
					idx + 1,\
					JSON.dumps(recipients),\
					mail_subject,\
					msg.as_string(),\
					'logics.mail.__store_mail_messages',\
				))
				print "### end insert mail msg: " + str(idx)
			except Exception, err:
				pprint.pprint(err)
				trace.append(traceback.format_exc())
				trace.append(cur._executed)
				con.rollback()
				flg_commit = flg_commit and False
			else:
				print "### start send mail msg: " + str(idx)
				self.__send_mail_messages(email.utils.parseaddr(msg['From'])[1], recipients, msg.as_string())
				print "### end send mail msg: " + str(idx)

		if worker_list and flg_commit:
			print "### start insert into ft_lient: "
			try:
				cur.execute("""\
INSERT INTO `ft_client_contacts`
  (`client_id`, `subject`, `note`, `creator_id`)
  SELECT
    DISTINCT `client_id`,
    %%s,
    %%s,
    valid_user_id_full('%s', '%s', '%s')
    FROM `mt_client_workers`
      WHERE
        `id` IN (%s);""" % (prefix, login_id, credential, ", ".join(map(str, worker_list)))
					, (u"メール", JSON.dumps({"request_id": mail_req_id, "message": mail_subject}),)
					)#(u"メール", mail_subject[:64],)
			except Exception, err:
				trace.append(traceback.format_exc())
				con.rollback()
				flg_commit = flg_commit and False
			else:
				pass

			print "### end insert into ft_client"

		if flg_commit:
			con.commit()
		con.close()
		print "### finish store_mail"
		return trace

	def __gen_mail_messages2(self, cur, mail_req_id, profile_user, reply_to, x_gwcustom_reply):
		import MySQLdb as DBS
		from email import encoders
		from email.header import Header
		from email.message import Message
		from email.mime.base import MIMEBase
		from email.mime.multipart import MIMEMultipart
		from email.mime.text import MIMEText
		#def add_replyto():
		#	#[begin] Reply-To.
		#	if mail_req['id_replyto'] and mail_req['id_replyto'] in map(lambda x: x['id'], data_accounts):
		#		msg['Reply-To'] = email.utils.formataddr((Header(filter(lambda x: x['id'] == mail_req['id_replyto'], data_accounts)[0]['name'], self.__pref__['MAIL_CHARSET']).encode(), filter(lambda x: x['id'] == mail_req['id_replyto'], data_accounts)[0]['mail1']))
		#		msg['X-GWCUSTOM-REPLY'] = '1'
		#	else:
		#		msg['Reply-To'] = email.utils.formataddr((Header(profile_user['name'], self.__pref__['MAIL_CHARSET']).encode(), profile_user['mail1']))
		#		msg['X-GWCUSTOM-REPLY'] = '0'
			#[end] Reply-To.
		mail_req = {}
		msg_list = []
		trace = []
		#from logics.manage import Processor as P_MANAGE
		#status_users, data_accounts = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		MYSQL_PREF = self.__pref__['MYSQL_HOSTS'][len(self.__pref__['MYSQL_HOSTS']) % self.__pref__['MYSQL_MODULO']]
		if "buffered" in MYSQL_PREF:
			del MYSQL_PREF['buffered']
		if "collation" in MYSQL_PREF:
			del MYSQL_PREF['collation']
		dbcon = DBS.connect(**MYSQL_PREF)
		dbcur = dbcon.cursor()
		try:
			dbcur.execute(Model.sql("gen_mail_messages_enum_mail_req"), (mail_req_id,))
		except:
			#trace.append(traceback.format_exc())
			trace.append(dbcur._executed)
			print traceback.format_exc()
		else:
			for idx, tmp in enumerate(dbcur):
				#if dbcur.rownumber == 1:
				if idx == 0:
					mail_req['id'] = tmp[0]
					mail_req['addr_to'] = JSON.loads(tmp[1])
					mail_req['addr_cc'] = JSON.loads(tmp[2])
					mail_req['addr_bcc'] = JSON.loads(tmp[3])
					mail_req['type_title'] = tmp[4]
					mail_req['subject'] = tmp[5]
					mail_req['body_tpl'] = tmp[6]
					mail_req['tpl_id'] = tmp[11]
					mail_req['tpl_type_recipient'] = tmp[12]
					mail_req['id_replyto'] = int(tmp[13]) if tmp[13] else None
					mail_req['attachments'] = []
				mail_req['attachments'].append({\
					"id": tmp[7],\
					"type_mime": tmp[8],\
					"name": tmp[9],\
					"value": tmp[10],\
				})
			mail_req['attachments'] = filter(lambda x: x['id'], mail_req['attachments'])
			#[begin] Generate MailMessage object.
			if mail_req['tpl_type_recipient'] == u"リマインダー":
				msg = MIMEMultipart()
				msg['Subject'] = Header(mail_req['subject'], self.__pref__['MAIL_CHARSET'])
				if mail_req['addr_cc']:
					mail_req['addr_to'] += mail_req['addr_cc']
				msg['To'] = ",".join(map(lambda x: email.utils.formataddr((Header(x['name'], self.__pref__['MAIL_CHARSET']).encode(), x['mail'])), mail_req['addr_to']))
				if self.__switch_replace_envelope:
					msg['From'] = email.utils.formataddr((Header(profile_user['name'], self.__pref__['MAIL_CHARSET']).encode(), profile_user['mail1']))
				else:
					msg['From'] = email.utils.formataddr((Header(profile_user['name'], self.__pref__['MAIL_CHARSET']).encode(), self.__pref__['MAIL_SENDER_ADDR']))
				#add_replyto()#Reply-To header construction.
				#msg['Reply-To'] = '=?utf-8?b?6YeR5rKi?= <bear_star713@hotmail.com>'
				#msg['X-GWCUSTOM-REPLY'] = '1'
				msg['Reply-To'] = reply_to
				msg['X-GWCUSTOM-REPLY'] = x_gwcustom_reply

				self.my_log('__gen_mail: option 1')
				msg['Date'] = formatdate(localtime=True)
				msg_pt_txt = MIMEText(Environment().from_string(mail_req['body_tpl']).render().encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
				msg.attach(msg_pt_txt)
				for attachment in mail_req['attachments']:
					if attachment:
						if "type_mime" in attachment and attachment['type_mime']:
							type_main, type_sub = attachment['type_mime'].split("/")
						else:
							continue
						attachment_obj = MIMEBase(type_main, type_sub)
						attachment_obj.add_header('Content-Disposition', 'attachment', filename=Header(attachment['name'], self.__pref__['MAIL_CHARSET']).encode())
						attachment_obj.set_payload(attachment['value'])
						encoders.encode_base64(attachment_obj)
						msg.attach(attachment_obj)
				msg_list.append(msg)
			elif mail_req['tpl_type_recipient'] in (u"取引先担当者（既定）", u"取引先担当者", u"マッチング",u"見積書",u"請求先注文書",u"注文書",u"請求書",):
				sorted_list = sorted(mail_req['addr_to'], key=lambda addr:(addr['client_id'], addr['recipient_priority'],))
				for gid, lst in itertools.groupby(sorted_list, key=lambda addr:addr['client_id']):
					d = self.__gen_simulate_mail_message_per_client([addr for addr in lst], mail_req['type_title'], mail_req['body_tpl'])
					addr_list = d["addr_to_list"]
					body = d["body"]
					msg = MIMEMultipart()
					msg['Subject'] = Header(mail_req['subject'], self.__pref__['MAIL_CHARSET'])
					msg['To'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in addr_list)
					msg['Cc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_cc'])
					msg['Bcc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_bcc'])
					if self.__switch_replace_envelope:
						msg['From'] = email.utils.formataddr((Header(profile_user['name'], self.__pref__['MAIL_CHARSET']).encode(), profile_user['mail1']))
					else:
						msg['From'] = email.utils.formataddr((Header(profile_user['name'], self.__pref__['MAIL_CHARSET']).encode(), self.__pref__['MAIL_SENDER_ADDR']))
					#add_replyto()#Reply-To header construction.
					#msg['Reply-To'] = '=?utf-8?b?6YeR5rKi?= <bear_star713@hotmail.com>'
					#msg['X-GWCUSTOM-REPLY'] = '1'
					msg['Reply-To'] = reply_to
					msg['X-GWCUSTOM-REPLY'] = x_gwcustom_reply

					#self.my_log('__gen_mail: option 2')
					msg['Date'] = formatdate(localtime=True)
					msg_pt_txt = MIMEText(Environment().from_string(body).render().encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
					msg.attach(msg_pt_txt)
					for attachment in mail_req['attachments']:
						if attachment:
							if "type_mime" in attachment and attachment['type_mime']:
								type_main, type_sub = attachment['type_mime'].split("/")
							else:
								continue
							attachment_obj = MIMEBase(type_main, type_sub)
							attachment_obj.add_header('Content-Disposition', 'attachment', filename=Header(attachment['name'], self.__pref__['MAIL_CHARSET']).encode())
							attachment_obj.set_payload(attachment['value'])
							encoders.encode_base64(attachment_obj)
							msg.attach(attachment_obj)
					msg_list.append(msg)
			elif mail_req['tpl_type_recipient'] in (u"技術者（既定）", u"技術者",):
				for addr_to in mail_req['addr_to']:
					d = self.__gen_simulate_mail_message_per_client([addr_to,], mail_req['type_title'], mail_req['body_tpl'])
					addr_list = d["addr_to_list"]
					body = d["body"]
					msg = MIMEMultipart()
					msg['Subject'] = Header(mail_req['subject'], self.__pref__['MAIL_CHARSET'])
					msg['To'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in addr_list)
					msg['Cc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_cc'])
					msg['Bcc'] = ",".join(email.utils.formataddr((Header(addr['name'], self.__pref__['MAIL_CHARSET']).encode(), addr['mail'])) for addr in mail_req['addr_bcc'])
					if self.__switch_replace_envelope:
						msg['From'] = email.utils.formataddr((Header(profile_user['name'], self.__pref__['MAIL_CHARSET']).encode(), profile_user['mail1']))
					else:
						msg['From'] = email.utils.formataddr((Header(profile_user['name'], self.__pref__['MAIL_CHARSET']).encode(), self.__pref__['MAIL_SENDER_ADDR']))
					#add_replyto()#Reply-To header construction.
					#msg['Reply-To'] = '=?utf-8?b?6YeR5rKi?= <bear_star713@hotmail.com>'
					#msg['X-GWCUSTOM-REPLY'] = '1'
					msg['Reply-To'] = reply_to
					msg['X-GWCUSTOM-REPLY'] = x_gwcustom_reply

					self.my_log('__gen_mail: option 3')
					msg['Date'] = formatdate(localtime=True)
					msg_pt_txt = MIMEText(Environment().from_string(body).render().encode(self.__pref__['MAIL_CHARSET'], "ignore"), "plain", self.__pref__['MAIL_CHARSET'])
					msg.attach(msg_pt_txt)
					for attachment in mail_req['attachments']:
						if attachment:
							if "type_mime" in attachment and attachment['type_mime']:
								type_main, type_sub = attachment['type_mime'].split("/")
							else:
								continue
							attachment_obj = MIMEBase(type_main, type_sub)
							attachment_obj.add_header('Content-Disposition', 'attachment', filename=Header(attachment['name'], self.__pref__['MAIL_CHARSET']).encode())
							attachment_obj.set_payload(attachment['value'])
							encoders.encode_base64(attachment_obj)
							msg.attach(attachment_obj)
					msg_list.append(msg)
			else:
				pass
			#[end] Generate mailMessage object.
		dbcon.close()
		return msg_list, trace

	def __store_mail_messages2(self, con, cur, mail_req_id, mail_subject, msg_list, worker_list=None, reserve_time=None, mail_id=None):
		trace = []
		flg_commit = True
		#
		import MySQLdb as DBS2
		try:
			con = DBS2.connect(**self.__pref__['MYSQL_HOSTS'][len(self.__pref__['MYSQL_HOSTS']) % self.__pref__['MYSQL_MODULO']])
		except:
			con = None
		if con:
			cur = con.cursor()
		else:
			cur = None
		
		if mail_id:
			sqlStr = """UPDATE `ft_mails_time` SET mail_sent = '1' WHERE id = '%s';""" % str(mail_id)
			self.my_log(sqlStr)

			try:
				cur.execute(sqlStr)
			except Exception, err:
				self.my_log('update sql exception:' + traceback.format_exc())
			else:
				con.commit()
				
		for idx, msg in enumerate(msg_list):
			recipients = []
			recipients += map(lambda x: email.utils.parseaddr(x)[1], msg['To'].split(","))
			recipients += map(lambda x: email.utils.parseaddr(x)[1], msg['Cc'].split(",")) if "Cc" in msg else []
			recipients += map(lambda x: email.utils.parseaddr(x)[1], msg['Bcc'].split(",")) if "Bcc" in msg else []
			try:
				cur.execute(Model.sql("gen_mail_messages_insert_mail_msg"), (\
					mail_req_id,\
					idx + 1,\
					JSON.dumps(recipients),\
					mail_subject,\
					msg.as_string(),\
					'logics.mail.__store_mail_messages',\
				))
			except Exception, err:
				pprint.pprint(err)
				trace.append(traceback.format_exc())
				trace.append(cur._executed)
				con.rollback()
				flg_commit = flg_commit and False
			else:
				self.my_log('__store_mail_messages2:from: ' + email.utils.parseaddr(msg['From'])[1])
				self.my_log('__store_mail_messages2:recips: ' + JSON.dumps(recipients))
				#self.my_log('__store_mail_messages2:msg: ' + msg.as_string())
				self.send_mail_messages(email.utils.parseaddr(msg['From'])[1], recipients, msg.as_string())

		if flg_commit:
			con.commit()
		con.close()
		return trace

	def __send_mail_messages(self, from_addr, recipient_list, msg_str):
		trace = []
		#Prepare SMTP connection.
		svr = smtplib.SMTP()
		svr.connect("localhost")
		svr.set_debuglevel(0)
		#[begin] Iter queued mail messages.
		try:
			print recipient_list
			if self.__switch_replace_envelope:
				smtp_res = svr.sendmail(self.__pref__['MAIL_SENDER_ADDR'], recipient_list, msg_str)
			else:
				smtp_res = svr.sendmail(from_addr, recipient_list, msg_str)
		except SMTPDataError, err:
			print "SMTPDataError occured"
			print traceback.format_exc()
		else:
			pass
		svr.quit()
		return trace

	def send_mail_messages(self, from_addr, recipient_list, msg_str):
		self.my_log('before send')
		trace = self.__send_mail_messages(from_addr, recipient_list, msg_str)
		self.my_log('after send')
		return trace

	def _fn_enum_templates(self, chain_env):
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
				chain_env['prefix'], args['login_id'], args['credential'],\
				chain_env['prefix'], args['login_id']\
			)
			try:
				dbcur.execute(Model.sql("enum_mail_template"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				status['code'] = 2
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_mail_template", dbcur)
				#[begin] Joining creator and modifier.
				user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id']) for entity in result] for e in p]))
				if user_list:
					dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
					tmp_res = Model.convert("enum_users", dbcur)
				else:
					tmp_res = []
				for tmp_obj in tmp_res:
					[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
					[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
				#[end] Joining creator and modifier.
				#[begin] Joining attachments.
				key_list = map(lambda x: x['id'], result)
				if key_list:
					dbcur.execute(Model.sql("enum_attachments") % ("cr_fmt_bin", ", ".join(map(str, key_list))))
					chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
					tmp_res = Model.convert("enum_attachments", dbcur)
				else:
					tmp_res = [entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				for tmp_key, tmp_list in tmp_res.iteritems():
					for res in result:
						if res['id'] == tmp_key:
							res['attachments'] = tmp_list
							break
				#[end] Joining attachments.
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_create_template(self, chain_env):
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
				args['name'], args['subject'], args['body'],\
				args['type_recipient'], ",".join(list(set(args['type_iterator']))) if args['type_iterator'] else None,\
				chain_env['prefix'], args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("create_mail_template"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
			else:
				dbcur.execute(Model.sql("last_insert_id"))
				chain_env['results'] = Model.convert("last_insert_id", dbcur)
				print dbcur.fetchall()
				dbcon.commit()
				chain_env['status']['code'] = 0
			#[begin] attachments.
			if "id" in chain_env['results'] and "attachments" in args:
				for at_id in args['attachments']:
					param2 = (\
						chain_env['results']['id'],\
						chain_env['prefix'], chain_env['login_id'],\
						chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
						at_id,\
						chain_env['prefix'], chain_env['login_id'],\
						chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
					)
					try:
						dbcur.execute("""\
INSERT INTO `cr_fmt_bin` (`key_id`, `bin_id`) VALUES (
  (
    SELECT `id` FROM `ft_mail_templates`
      WHERE
        `id` = %s
        AND `is_enabled`
        AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
        AND valid_user_id_full(%s, %s, %s)
  ),
  (
    SELECT `id` FROM `ft_binaries`
      WHERE
        `id` = %s
        AND `is_enabled`<>FALSE
        AND `is_temp`=TRUE
        AND valid_acl(%s, %s, `creator_id`, NULL)
        AND valid_user_id_read(%s, %s, %s)
  )
);""", param2)
						dbcur.execute("""UPDATE `ft_binaries` SET `is_temp`=FALSE WHERE `id`=%s;""", (at_id,))
					except Exception, err:
						chain_env['trace'].append(traceback.format_exc())
						chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
					else:
						chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
						dbcon.commit()
			#[end] attachments.
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_update_template(self, chain_env):
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
			ACCEPTABLE_COLS = ("name", "subject", "body", "type_iterator")
			cols = [k for k in sorted(args.keys()) if k in ACCEPTABLE_COLS]
			vals = [args[k] if k not in ("type_iterator") else ",".join(args[k]) for k in cols]
			param = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[args['id']] +\
				[chain_env['prefix'], args['login_id']]
			if cols:
				try:
					dbcur.execute(Model.sql("update_mail_template") % ",\n    ".join(map(lambda x: "`%s` = %%s" % x, cols)), param)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					chain_env['status']['code'] = 2
				else:
					dbcon.commit()
					chain_env['status']['code'] = 0
			#[begin] attachments.
			dbcur.execute("""\
DELETE
  FROM `ft_binaries`
  WHERE
    `id`=(
      SELECT `bin_id` FROM `cr_fmt_bin` WHERE `key_id`=%s
    );""", (args['id'],))
			dbcon.commit()
			chain_env['trace'].append(dbcur._executed)
			if "id" in args and "attachments" in args:
				for at_id in args['attachments']:
					param2 = (\
						args['id'],\
						chain_env['prefix'], chain_env['login_id'],\
						chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
						at_id,\
						chain_env['prefix'], chain_env['login_id'],\
						chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
					)
					try:
						dbcur.execute("""\
INSERT INTO `cr_fmt_bin` (`key_id`, `bin_id`) VALUES (
  (
    SELECT `id` FROM `ft_mail_templates`
      WHERE
        `id` = %s
        AND `is_enabled`
        AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
        AND valid_user_id_full(%s, %s, %s)
  ),
  (
    SELECT `id` FROM `ft_binaries`
      WHERE
        `id` = %s
        AND `is_enabled`<>FALSE
        AND `is_temp`=TRUE
        AND valid_acl(%s, %s, `creator_id`, NULL)
        AND valid_user_id_read(%s, %s, %s)
  )
);""", param2)
						dbcur.execute("""UPDATE `ft_binaries` SET `is_temp`=FALSE WHERE `id`=%s;""", (at_id,))
					except Exception, err:
						chain_env['trace'].append(traceback.format_exc())
						chain_env['trace'].append(dbcur._executed)
					else:
						chain_env['trace'].append(dbcur._executed)
						dbcon.commit()
			#[end] attachments.
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_delete_template(self, chain_env):
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
				chain_env['prefix'], args['login_id']\
			)
			try:
				rows = dbcur.execute(Model.sql("delete_mail_template") % ", ".join(map(str, set(args['id_list']))), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				chain_env['status']['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)
				dbcon.commit()
				chain_env['results']['rows'] = dbcur.rowcount
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_update_send_flg(self, chain_env):
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
			if "quotation_type" in args:
				quotation_sql = ""
				if args["quotation_type"] == "estimate":
					quotation_sql = "update_quotation_send_flg_estimate"
				if args["quotation_type"] == "order":
					quotation_sql = "update_quotation_send_flg_order"
				if args["quotation_type"] == "invoice":
					quotation_sql = "update_quotation_send_flg_invoice"
				if args["quotation_type"] == "purchase":
					quotation_sql = "update_quotation_send_flg_purchase"

				param = [args['quotation_id']]
				try:
					dbcur.execute(Model.sql(quotation_sql), param)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					chain_env['status']['code'] = 2
					print traceback.format_exc(err)
				else:
					pprint.pprint(dbcur._executed)
					dbcon.commit()
					chain_env['status']['code'] = 0
				dbcur.close()
				dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_enum_reserve(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = None
		if not chain_env['propagate']:
			return

		from logics.auth import Processor as P_AUTH
		status_profile, userProfile = P_AUTH(self.__pref__).read_user_profile(chain_env)

		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			try:
				param = (\
					userProfile['user']['id'],\
				)
				dbcur.execute(Model.sql("enum_reserve"), param)
				result = Model.convert("enum_reserve", dbcur)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				self.my_log(traceback.format_exc(err))
				status['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)

			if status['code'] is None:
				status['code'] = 0

			dbcur.close()
			dbcon.close()
		self.my_log("enum_reserve: result: " + str(result))
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

		return status, result

	def _fn_get_reserve_info(self, chain_env):
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
				args['id'],\
			)

			try:
				dbcur.execute(Model.sql("get_reserve_info"), param)
				result = Model.convert("get_reserve_info", dbcur)
				#self.my_log("_fn_get_reserve_info:result: " + str(result))
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				self.my_log(traceback.format_exc(err))
				status['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)

			if status['code'] is None:
				status['code'] = 0

			dbcur.close()
			dbcon.close()

		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

		return status, result

	def _fn_update_reserve(self, chain_env):
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
			self.my_log("_fn_update_reserve: args: " + str(args))
			
			result1 = True
			result2 = True
			if 'subject' in args or 'body' in args:
				sql = u"""UPDATE `ft_mails` SET"""
				if 'subject' in args:
					sql += """ `subject` = '""" + args['subject'] + """'"""
				if 'body' in args:
					sql += """ `body` = '""" + args['body'] +  """'"""
				sql += """ WHERE `id` = """ + args['mail_req_id'] + """;"""
				try:
					dbcur.execute(sql)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					self.my_log(traceback.format_exc(err))
					chain_env['status']['code'] = 2
					print traceback.format_exc(err)
					result1 = False
				else:
					pprint.pprint(dbcur._executed)
					dbcon.commit()
					chain_env['status']['code'] = 0

			if 'send_time' in args:
				result = 'false'
				sql = u"""UPDATE `ft_mails_time` SET `send_time` = '""" + \
					args['send_time'] + """' WHERE `id` = """ + args['id'] + """;"""
				try:
					dbcur.execute(sql)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					self.my_log(traceback.format_exc(err))
					chain_env['status']['code'] = 2
					print traceback.format_exc(err)
					result2 = False
				else:
					pprint.pprint(dbcur._executed)
					dbcon.commit()
					chain_env['status']['code'] = 0

			dbcur.close()
			dbcon.close()

			if result1 and result2:
				result = 'true'

		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_delete_reserve(self, chain_env):
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
				args['id'],\
			)
			try:
				dbcur.execute(Model.sql("delete_reserve"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				self.my_log(traceback.format_exc(err))
				chain_env['status']['code'] = 2
				print traceback.format_exc(err)
			else:
				pprint.pprint(dbcur._executed)
				dbcon.commit()
				chain_env['status']['code'] = 0
				result = 'true'

			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_update_reserve_sent(self, chain_env):
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
				args['id'],\
			)
			try:
				dbcur.execute(Model.sql("update_reserve_sent"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
				self.my_log(traceback.format_exc(err))
				chain_env['status']['code'] = 2
				print traceback.format_exc(err)
			else:
				pprint.pprint(dbcur._executed)
				dbcon.commit()
				chain_env['status']['code'] = 0
				result = 'true'

			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result