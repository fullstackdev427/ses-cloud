#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides client logics.
"""

import time
import copy
import hashlib
import re
import traceback
import pprint
import json

import flask

from datetime import datetime
from datetime import timedelta
from providers.limitter import Limitter
from validators.base import ValidatorBase as Validator
from models.operation import Operation as Model
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
		"enumInvoices": {\
			"valid_in": None,\
			"logic": "enum_invoices",\
			"valid_out": None\
		}, \
		"getInvoices": {\
			"valid_in": None,\
			"logic": "get_invoices_by_id_array",\
			"valid_out": None\
		}, \
			
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
		#Fetch engineers.
		status_engineer, render_param['invoice.enumInvoices'], render_param['invoice.count'], render_param['invoice.total'] = self._fn_enum_invoices(chain_env)
		#[begin] support objects.
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"invoice.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"請求書|SESクラウド",\
			current="invoice.top")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_invoices(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}

		import locale
		locale.setlocale(locale.LC_NUMERIC, 'ja_JP')
		locale.setlocale(locale.LC_MONETARY, 'en_US')

		from models.project import Project as P_Model
		from models.quotation import Quotation as Q_Model

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
				"visible_name": "`FQ`.`visible_name`",\
				"station": "`FQ`.`station`",\
				"skill": "`FQ`.`skill`",\
				"employer": "`FQ`.`employer`",\
			}
			FILTERS_SERIOUS = { \
				"quotation_id": "`FQ`.`id`", \
				"id": "`FQ`.`id`",\
				"project_id": "`FQ`.`project_id`", \
				}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.

			if ("quotation_name" in args):
				whereClause.append("(`FQ`.`quotation_name` REGEXP \'^.*" + args['quotation_name'] + ".*$\')")
			if ("client_name" in args):
				whereClause.append("(`CL`.`name` REGEXP \'^.*" + args['client_name'] + ".*$\')")
			if ("project_title" in args):
				whereClause.append("(`MT`.`title` REGEXP \'^.*" + args['project_title'] + ".*$\')")
			if ("charging_user_name" in args):
				whereClause.append("`MT`.`charging_user_id` in (SELECT id FROM mt_user_persons as pmup WHERE pmup.name REGEXP \'^.*" + args['charging_user_name'] + ".*$\')")
			if ("quotation_month" in args):
				whereClause.append("(FQ.quotation_date >= \'" + args['quotation_month'] + "/01\' AND FQ.quotation_date < DATE_ADD(\'" + args['quotation_month'] + "/01\',INTERVAL 1 MONTH) )")
			if ("office_memo" in args):
				whereClause.append("(`FQ`.`office_memo` REGEXP \'^.*" + args['office_memo'] + ".*$\')")

			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"client_name": "`CL`.`name`", \
				"project_title": "`MT`.`title`", \
				"charging_user_id": "`MT`.`charging_user_id`", \
				"quotation_no": "`FQ`.`quotation_no`", \
				"total_including_tax": "`FQ`.`total_including_tax`", \
				"quotation_name": "`FQ`.`quotation_name`", \
				"quotation_date": "`FQ`.`quotation_date`", \
				"creator_id": "`FQ`.`creator_id`", \
				"dt_created": "`FQ`.`dt_created`",\
			}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			if "sort_keys" in args and "dt_created" in args['sort_keys']:
				pass
			else:
				orderClause += ["COALESCE(`FQ`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param1 = \
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] + \
				whereValues
			try:
				dbcur.execute(Q_Model.sql("enum_invoices") % (("AND " + "\n AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param1)
				# dbcur.execute(Q_Model.sql("enum_estimates"))
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				result = []
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Q_Model.convert("enum_invoices", dbcur)
				status['code'] = 0
			# [begin] Joining charging_user_id.
			user_list = set(filter(lambda x: x is not None and x, [e for p in [
				( entity['creator']['id'], entity['charging_user']['id']) for entity in
				result] for e in p]))
			if user_list:
				dbcur.execute(P_Model.sql("enum_users") % ", ".join(map(str, user_list)))
				res2 = P_Model.convert("enum_users", dbcur)
			else:
				res2 = []
			for tmp_obj in res2:
				[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				[entity['charging_user'].update(tmp_obj) for entity in result if entity['charging_user']['id'] == tmp_obj['id']]
			# [end] Joining charging_user_id.

			status['code'] = 0
			dbcur.close()
			dbcon.close()

		count = len(result)
		total = 0
		for invoice in result:
			total += int(invoice['subtotal_num'])
		
		total = locale.format("%d", total, grouping=True)
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result, count, total
	
	def _fn_get_invoices_by_id_array(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		
		import locale
		locale.setlocale(locale.LC_NUMERIC, 'ja_JP')
		locale.setlocale(locale.LC_MONETARY, 'en_US')

		from models.project import Project as P_Model
		from models.quotation import Quotation as Q_Model

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
			param1 = \
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']]
			try:
				dbcur.execute(Q_Model.sql("get_invoices") %  ("AND " + args["where"]), param1)
			except:
				self.my_log("-- _fn_get_invoices_by_id_array except " + traceback.format_exc())
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				result = []
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Q_Model.convert("enum_invoices", dbcur)
				status['code'] = 0
				
			# [begin] Joining charging_user_id.
			user_list = set(filter(lambda x: x is not None and x, [e for p in [
				( entity['creator']['id'], entity['charging_user']['id']) for entity in
				result] for e in p]))
			if user_list:
				dbcur.execute(P_Model.sql("enum_users") % ", ".join(map(str, user_list)))
				res2 = P_Model.convert("enum_users", dbcur)
			else:
				res2 = []
			for tmp_obj in res2:
				[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				[entity['charging_user'].update(tmp_obj) for entity in result if entity['charging_user']['id'] == tmp_obj['id']]
			# [end] Joining charging_user_id.

			status['code'] = 0
			dbcur.close()
			dbcon.close()

		count = len(result)
		total = 0
		for invoice in result:
			total += int(invoice['subtotal_num'])
		
		total = locale.format("%d", total, grouping=True)
		try:	
			from logics.manage import Processor as P_MANAGE
			_, user_profile = P_MANAGE(self.__pref__)._fn_read_user_profile(chain_env)
			chain_env['results'] = {\
				"results": result, \
				"bank_account1": user_profile["company"]["bank_account1"], \
				"bank_account2": user_profile["company"]["bank_account2"], \
			}
		except Exception, err:
			self.my_log("--user_profile except " + traceback.format_exc())

		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result, count, total

	def _fn_enum_invoices_pdfinfo(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}

		from models.quotation import Quotation as Q_Model

		# if not chain_env['propagate']:
		# 	return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data

			if "query" in chain_env and chain_env['query']:
				args['pdffile_path'] = chain_env['query']

			#[begin] Build where clause conditions.
			FILTERS_LIKE = {\
				"visible_name": "`FQ`.`visible_name`",\
				"station": "`FQ`.`station`",\
				"skill": "`FQ`.`skill`",\
				"employer": "`FQ`.`employer`",\
			}
			FILTERS_SERIOUS = { \
				"quotation_id": "`FQ`.`id`", \
				"id": "`FQ`.`id`",\
				"project_id": "`FQ`.`project_id`", \
				"pdffile_path": "`FQ`.`pdffile_path`", \
				}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.

			if ("client_name" in args):
				whereClause.append(
					"(`CL`.`name` REGEXP \'^.*" + args['client_name'] + ".*$\')")
			if ("project_title" in args):
				whereClause.append(
					"(`MT`.`title` REGEXP \'^.*" + args['project_title'] + ".*$\')")

			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"client_name": "`CL`.`name`", \
				"project_title": "`MT`.`title`", \
				"charging_user_id": "`MT`.`charging_user_id`", \
				"quotation_no": "`FQ`.`quotation_no`", \
				"total_including_tax": "`FQ`.`total_including_tax`", \
				"quotation_name": "`FQ`.`quotation_name`", \
				"quotation_date": "`FQ`.`quotation_date`", \
				"creator_id": "`FQ`.`creator_id`", \
				"dt_created": "`FQ`.`dt_created`", \
				}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			if "sort_keys" in args and "dt_created" in args['sort_keys']:
				pass
			else:
				orderClause += ["COALESCE(`FQ`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param1 = whereValues
			print whereClause
			print whereValues
			try:
				dbcur.execute(Q_Model.sql("enum_invoices_pdf_info") % (("AND " + "\n AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param1)
				# dbcur.execute(Q_Model.sql("enum_estimates"))
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				result = []
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Q_Model.convert("enum_invoices", dbcur)
				status['code'] = 0

			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result