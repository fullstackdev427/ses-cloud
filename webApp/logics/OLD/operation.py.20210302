#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides client logics.
"""

import time
import copy
import datetime
import hashlib
import re
import traceback
import pprint
import json


import flask

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
		"enumOperations": {\
			"valid_in": None,\
			"logic": "enum_operations",\
			"valid_out": None\
		}, \
		"enumOperationsSummary": { \
			"valid_in": None, \
			"logic": "enum_operations_summary", \
			"valid_out": None \
			}, \
		"createOperation": { \
			"valid_in": "None", \
			"logic": "create_operation", \
			"valid_out": None \
			}, \
		"updateOperation": { \
			"valid_in": "None", \
			"logic": "update_operation", \
			"valid_out": None \
			}, \
		"copyOperation": { \
			"valid_in": "None", \
			"logic": "copy_operation", \
			"valid_out": None \
			}, \
		"deleteOperation": { \
			"valid_in": "None", \
			"logic": "delete_operation", \
			"valid_out": None \
			}, \
		"enumOperationsTotal": { \
			"valid_in": "None", \
			"logic": "enum_operations_total", \
			"valid_out": None \
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
		from logics.client import Processor as P_CLIENT
		from logics.skill import Processor as P_SKILL
		from logics.occupation import Processor as P_OCCUPATION

		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch engineers.
		status_operation, render_param['operation.enumOperations'] = self._fn_enum_operations(chain_env)

		# status_operation, render_param['operation.enumOperationsSummary'] = self._fn_enum_operations_summary(chain_env)
		status_total, render_param['operation.total'] = self._fn_enum_operations_total(chain_env)
		#[begin] support objects.
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)

		clean_env = copy.deepcopy(chain_env)
		if "name" in clean_env['argument'].data:
			clean_env['argument'].data['name'] = u''

		status_client, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
		render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in
									  render_param['client.enumClients']]

		status_skills, render_param['skill.enumSkills'] = P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
		status_skills, render_param['skill.enumSkillCategories'] = P_SKILL(self.__pref__)._fn_enum_skill_categories(
			chain_env)
		status_skills, render_param['skill.enumSkillLevels'] = P_SKILL(self.__pref__)._fn_enum_skill_levels(
			chain_env)
		status_projects, render_param['occupation.enumOccupations'] = P_OCCUPATION(
			self.__pref__)._fn_enum_occupations(
			chain_env)

		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"operation.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"稼働|SESクラウド",\
			current="operation.top")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_enum_operations(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}

		from models.project import Project as P_Model

		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			querySet, param1 = self._fn_query_set(chain_env, True)
			# print Model.sql("enum_operations") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)
			try:
				dbcur.execute(Model.sql("enum_operations") % querySet, param1)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				result = []
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_operations", dbcur)
				status['code'] = 0
			# [begin] Joining charging_user_id.
			user_list = set(filter(lambda x: x is not None and x, [e for p in [
				(entity['charging_user']['id'], entity['engineer_charging_user']['id'], entity['creator']['id'], entity['modifier']['id']) for entity in
				result] for e in p]))
			if user_list:
				dbcur.execute(P_Model.sql("enum_users") % ", ".join(map(str, user_list)))
				res2 = P_Model.convert("enum_users", dbcur)
			else:
				res2 = []
			for tmp_obj in res2:
				[entity['charging_user'].update(tmp_obj) for entity in result if
				 entity['charging_user']['id'] == tmp_obj['id']]
				[entity['engineer_charging_user'].update(tmp_obj) for entity in result if
				 entity['engineer_charging_user']['id'] == tmp_obj['id']]
				[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				[entity['modifier'].update(tmp_obj) for entity in result if
				 entity['modifier']['id'] == tmp_obj['id']]
			# [end] Joining charging_user_id.

			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_operations_summary(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}

		from models.project import Project as P_Model

		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			querySet, param1 = self._fn_query_set(chain_env, False)
			# print param1
			# print whereClause
			# print (Model.sql("enum_operations") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)))
			try:
				dbcur.execute(Model.sql("enum_operations_summary") % querySet, param1)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				result = []
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_operations_summary", dbcur)
				status['code'] = 0

			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_operations_total(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}

		from models.project import Project as P_Model

		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			querySet, param1 = self._fn_query_set(chain_env, False)
			# print param1
			# print whereClause
			# print (Model.sql("enum_operations") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)))
			try:
				dbcur.execute(Model.sql("enum_operations_total") % querySet, param1)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				result = []
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_operations_total", dbcur)
				status['code'] = 0

			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_create_operation(self, chain_env):
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
			# [begin] SQL preparation.
			args = chain_env['argument'].data
			param = (args['project_id'], args['engineer_id'], args['term_memo'], args['base_exc_tax'], \
					 args['excess'], args['deduction'],args['demand_exc_tax'], args['demand_inc_tax'], \
					 args['payment_exc_tax'], args['payment_inc_tax'], args['welfare_fee'], args['transportation_fee'], \
					 args['gross_profit'], args['gross_profit_rate'], args['tax'], args['settlement_from'], \
					 args['settlement_to'], args['contract_date'], args['demand_site'], args['payment_site'], \
					 args['other_memo'], args['is_active'], args['is_fixed'], args['base_inc_tax'], \
					 args['transfer_member'], args['term_begin'], args['term_end'], args['settlement_unit'], \
					 args['demand_unit'], args['payment_unit'], args['bonuses_division'], args['payment_base'], \
					 args['payment_excess'], args['payment_deduction'],args['payment_settlement_unit'], args['demand_wage_per_hour'], \
					 args['demand_working_time'], args['payment_wage_per_hour'], args['payment_working_time'],\
					 args['payment_settlement_from'], args['payment_settlement_to'], \
					 args['demand_memo'], args['payment_memo'], \
					 chain_env['prefix'], args['login_id'], args['credential'], \
					 )
			flg_ok = True
			try:
				dbcur.execute(Model.sql("create_operation"), param)
			except Exception, err:
				print err
				chain_env['propagate'] = False
				status['code'] = 2
				dbcon.rollback()
				flg_ok = False
			else:
				try:
					dbcur.execute(Model.sql("last_insert_id"))
				except Exception, err:
					chain_env['trace'].append(err)
					status['code'] = 1
				else:
					result = Model.convert("last_insert_id", dbcur)
					status['code'] = 0
			if flg_ok:
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_update_operation(self, chain_env):
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
			# [begin] SQL preparation.
			ACCEPT_FIELDS = (
				"term_memo", "demand_exc_tax", "demand_inc_tax", "payment_exc_tax", "payment_inc_tax",
				"gross_profit", "gross_profit_rate", "settlement_from", "settlement_to", "contract_date",
				"tax", "welfare_fee", "transportation_fee", "excess", "deduction",
				"demand_memo", "payment_memo", "demand_site", "payment_site", "cutoff_date",
				"other_memo", "is_active", "is_fixed", "base_inc_tax", "base_exc_tax", "transfer_member",
				"term_begin", "term_end","term_begin_exp", "term_end_exp",
				"settlement_exp","settlement_unit","demand_unit","payment_unit","bonuses_division",
				"payment_base", "payment_excess", "payment_deduction", "payment_exp", "payment_settlement_unit",
				"demand_wage_per_hour","demand_working_time","payment_wage_per_hour","payment_working_time",
				"payment_settlement_from", "payment_settlement_to",
				"engineer_id"
			)

			for args in chain_env['argument'].data['operationObjList']:
				cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
				vals= []
				# for k in cols:
				# 	if args[k] is None:
				# 		v = 'null'
				# 	else:
				# 		v = args[k]
				# 	vals.append(v)
				vals = [ args[k] for k in cols]
				cols += ["dt_modified"]
				vals += [datetime.datetime.now()]
				cvt = \
					[chain_env['prefix'], chain_env['argument'].data['login_id'], chain_env['argument'].data['credential']] + \
					vals + \
					[args['id']]
				flg_ok = True
				print Model.sql("update_operation") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt
				# [end] SQL preparation.

				try:
					dbcur.execute(Model.sql("update_operation") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
				except Exception, err:
					print err
					chain_env['propagate'] = False
					status['code'] = 2
					dbcon.rollback()
					flg_ok = False
				else:
					status['code'] = 0
			if flg_ok:
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_copy_operation(self, chain_env):
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
			# [begin] SQL preparation.
			args = chain_env['argument'].data
			param = (args['operation_id'],)
			flg_ok = True

			try:
				dbcur.execute(Model.sql("copy_operation"), param)
			except Exception, err:
				print err
				chain_env['propagate'] = False
				status['code'] = 2
				dbcon.rollback()
				flg_ok = False
			else:
				status['code'] = 0
			if flg_ok:
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_delete_operation(self, chain_env):
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
			# [begin] SQL preparation.
			args = chain_env['argument'].data
			param = (args['operation_id'],)
			flg_ok = True

			try:
				dbcur.execute(Model.sql("delete_operation_from_id"), param)
			except Exception, err:
				print err
				chain_env['propagate'] = False
				status['code'] = 2
				dbcon.rollback()
				flg_ok = False
			else:
				status['code'] = 0
			if flg_ok:
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_query_set(self, chain_env, order):
		MAX_SIZE_OPERATION = 30
		args = chain_env['argument'].data
		if not "from_operation" in chain_env['argument'].data :
			args['is_active'] = 1

		dbcon, db_err_list = self.connect_db()
		#[begin] Build where clause conditions.
		FILTERS_LIKE = {\
			"visible_name": "`FO`.`visible_name`",\
			"station": "`FO`.`station`",\
			"skill": "`FO`.`skill`",\
			"employer": "`FO`.`employer`",\
		}
		FILTERS_SERIOUS = {\
			"id": "`FO`.`id`",\
			"gender": "`FO`.`gender`",\
			"is_active": "`FO`.`is_active`",\
			"is_fixed": "`FO`.`is_fixed`", \
			"project_id": "`FO`.`project_id`", \
			"scheme": "`MTP`.`scheme`", \
			"term_begin_exp": "`FO`.`term_begin`", \
			"term_end_exp": "`FO`.`term_end`", \
			"engineer_client_id": "`MTE`.`client_id`", \
			"engineer_company_id": "`MTE`.`owner_company_id`", \
			}
		whereClause = []
		whereValues = []
		[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
		[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
		#[end] Build where clause conditions.

		if ("name" in args):
			whereClause.append("(`MTE`.`name` REGEXP \'^.*" + args['name'] + ".*$\' or `MTE`.`kana` REGEXP \'^.*" + args['name'] + ".*$\' or `MTEC`.`name` REGEXP \'^.*" + args['name'] + ".*$\')")
		if ("client_name" in args):
			whereClause.append("(`MTC`.`name` REGEXP \'^.*" + args['client_name'] + ".*$\')")
		if ("project_title" in args):
			whereClause.append("(`MTP`.`title` REGEXP \'^.*" + args['project_title'] + ".*$\')")
		if ("charging_user_name" in args):
			whereClause.append("`MTP`.`charging_user_id` in (SELECT id FROM mt_user_persons as pmup WHERE pmup.name REGEXP \'^.*" + args['charging_user_name'] + ".*$\')")
		if ("engineer_charging_user_name" in args):
			whereClause.append("`MTE`.`charging_user_id` in (SELECT id FROM mt_user_persons as emup WHERE emup.name REGEXP \'^.*" +args['engineer_charging_user_name'] + ".*$\')")
		if ("transfer_member" in args):
			whereClause.append("(`FO`.`transfer_member` REGEXP \'^.*" + args['transfer_member'] + ".*$\')")
		if ("contract_month" in args):
			whereClause.append("(FO.contract_date >= \'" + args['contract_month'] + "/01\' AND FO.contract_date < DATE_ADD(\'" + args['contract_month'] + "/01\',INTERVAL 1 MONTH) )")
		if ("operation_ids" in args):
			whereClause.append("`FO`.`id` in (" + ",".join(args['operation_ids']) + " ) ")
		if ("term_begin" in args):
			whereClause.append("(`MTP`.`term_begin` = \'" + args['term_begin'] + "\' or `FO`.`term_begin` = \'" + args['term_begin'] + "\')")
		if ("term_end" in args):
			whereClause.append("(`MTP`.`term_end` = \'" + args['term_end'] + "\' or `FO`.`term_end` = \'" + args['term_end'] + "\')")
		if ("contract" in args):
			if (args['contract'] == u"正社員(契約社員)"):
				whereClause.append(u"`MTE`.`contract` IN ('正社員', '契約社員')")
			else :
				whereClause.append("`MTE`.`contract` = \'" + args["contract"] + "\'")

		#[begin] Build order by clause.
		ORDER_KEYS = {\
			"kana": "`FO`.`kana`",\
			"contract": "`FO`.`contract`",\
			"fee": "`FO`.`fee`",\
			"dt_created": "`FO`.`dt_created`", \
			"company_name":"`MTC`.`name`",
			"title": "`MTP`.`title`",
			"name": "`MTE`.`name`",
		}
		orderClause = []
		if "sort_keys" in args:
			for k in args['sort_keys']:
				if k in ORDER_KEYS:
					orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
		if "sort_keys" in args and "dt_created" in args['sort_keys']:
			pass
		elif ("is_sort_name" in args or "is_sort_client" in args):
		#elif (args["is_sort_name"] == 1 or args["is_sort_client"] == 1):
			is_args = 0
			if "is_sort_name" in args:
				if args["is_sort_name"] == 1:
					orderClause += ["`MTC`.`name` ASC"]
					orderClause += ["`FO`.`base_exc_tax` DESC"]
					is_args += 1
			if "is_sort_client" in args:
				if args["is_sort_client"] == 1:
					orderClause += ["IF(ISNULL(`MTEC`.`name`),1,0)"]
					orderClause += ["`MTEC`.`name` ASC"]
					orderClause += ["`FO`.`base_exc_tax` DESC"]
					is_args += 1
			if is_args == 0:
				orderClause += ["`FO`.`dt_created` DESC"]
		else:
			orderClause += ["`FO`.`dt_created` DESC"]
		#[end] Build order by clause.
		param1 = \
			[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] + \
			whereValues
		pageNumber = 1
		if ("pageNumber" in args):
			pageNumber = args['pageNumber']

		limitClause = " LIMIT %s OFFSET %s" % (str(MAX_SIZE_OPERATION), str((pageNumber - 1)*MAX_SIZE_OPERATION)) if order else ""

		return (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause) + limitClause), param1
