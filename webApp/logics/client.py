#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides client logics.
"""

import copy
import time
import datetime
import hashlib
import traceback
import pprint
import re
import flask

from validators.base import ValidatorBase as Validator
from models.client import Client as Model
from base import ProcessorBase
from errors import exceptions as EXC
from providers.limitter import Limitter

class Processor(ProcessorBase):
	
	"""
		This class provides client object manipulation functionalities.
	"""
	
	__realms__ = {\
		"clientTop": {\
			"logic": "html_client_top",\
		},\
		"workerTop": {\
			"logic": "html_worker_top",\
		},\
		"mapClient": {\
			"logic": "html_map_client",\
		},\
		"enumClients": {\
			"valid_in": None,\
			"logic": "enum_clients",\
			"valid_out": None\
		},\
		"createClient": {\
			"valid_in": "create_client_in",\
			"logics": [\
				"check_item_cap_client",\
				"create_client",\
			],\
			"valid_out": None\
		},\
		"updateClient": {\
			"valid_in": "update_client_in",\
			"logic": "update_client",\
			"valid_out": None\
		},\
		"deleteClient": {\
			"valid_in": "delete_client_in",\
			"logic": "delete_client",\
			"valid_out": None\
		},\
		"enumBranches": {\
			"valid_in": None,\
			"logic": "enum_branches",\
			"valid_out": None\
		},\
		"createBranch": {\
			"valid_in": "create_branch_in",\
			"logic": "create_branch",\
			"valid_out": None\
		},\
		"updateBranch": {\
			"valid_in": "update_branch_in",\
			"logic": "update_branch",\
			"valid_out": None\
		},\
		"deleteBranch": {\
			"valid_in": "delete_branch_in",\
			"logic": "delete_branch",\
			"valid_out": None\
		},\
		"enumWorkers": {\
			"valid_in": None,\
			"logic": "enum_workers",\
			"valid_out": None\
		},\
		"enumWorkersCompact": { \
			"valid_in": None, \
			"logic": "enum_workers_compact", \
			"valid_out": None \
			},\
		"createWorker": {\
			"valid_in": "create_worker_in",\
			"logics": [\
				"check_item_cap_worker",\
				"create_worker",\
			],\
			"valid_out": "create_worker_out"\
		},\
		"updateWorker": {\
			"valid_in": "update_worker_in",\
			"logic": "update_worker",\
			"valid_out": None\
		},\
		"deleteWorker": {\
			"valid_in": "delete_worker_in",\
			"logic": "delete_worker",\
			"valid_out": None\
		},\
		"enumContacts": {\
			"valid_in": "enum_contacts_in",\
			"logic": "enum_contacts",\
			"valid_out": None\
		},\
		"createContact": {\
			"valid_in": "create_contact_in",\
			"logic": "create_contact",\
			"valid_out": None\
		},\
		"deleteContact": {\
			"valid_in": "delete_contact_in",\
			"logic": "delete_contact",\
			"valid_out": None\
		}\
	}
	
	def _fn_check_item_cap_client(self, chain_env):
		self.check_limit(chain_env, ("LMT_LEN_CLIENT",))
	
	def _fn_check_item_cap_worker(self, chain_env):
		self.check_limit(chain_env, ("LMT_LEN_WORKER",))
	
	def _fn_html_client_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.manage import Processor as P_MANAGE
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch client companies.
		status_clients, render_param['client.enumClients'] = self._fn_enum_clients(chain_env)
		#[begin] support objects.
		clean_env = copy.deepcopy(chain_env)
		clean_env['argument'].clear()
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"client.tpl",\
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"取引先|SESクラウド",\
			current="client.clientTop")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_html_worker_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.manage import Processor as P_MANAGE
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch client workers.
		status_clients, render_param['client.enumWorkers'] = self._fn_enum_workers(chain_env)
		#[begin] support objects.
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"worker.tpl",\
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"取引先担当者|SESクラウド",\
			current="client.workerTop")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_html_map_client(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.manage import Processor as P_MANAGE
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		render_param['zenrin_id'] = self.__pref__['ZENRIN_ID']
		chain_env['response_body'] = flask.render_template(\
			"map.tpl",\
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"地図",\
			current="client.mapClient")
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_clients(self, chain_env):
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
				"name": "`MCLI`.`name`",\
				"kana": "`MCLI`.`kana`",\
				"note": "`FCLN`.`note`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`MCLI`.`id`", \
				"client_id": "`MCLI`.`id`", \
				"type_dealing": "`MCLI`.`type_dealing`",\
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			if "charging_worker" in args:
				whereClause += [\
					"%s IN (`MCLI`.`charging_worker1`, `MCLI`.`charging_worker2`)"\
				]
				whereValues += [args['charging_worker']]
			if "type_presentation" in args:
				if args['type_presentation'] in (u"案件", u"人材"):
					whereClause += [\
						"FIND_IN_SET(%s, `MCLI`.`type_presentation`) > 0"\
					]
					whereValues += [args['type_presentation']]
				else:
					whereClause += [\
						"FIND_IN_SET('案件', `MCLI`.`type_presentation`) > 0",\
						"FIND_IN_SET('人材', `MCLI`.`type_presentation`) > 0",\
					]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"kana": "`MCLI`.`kana`",\
				"type_presentation": "`MCLI`.`type_presentation`",\
				"charging_worker_1": "`MCW1`.`name`",\
			}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			orderClause += ["COALESCE(`MCLI`.`dt_modified`, `MCLI`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_clients") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
				#self.my_log("__enum_clients " + Model.sql("enum_clients") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)))
				#import json as JSON
				#self.my_log("__enum_clients_param " + JSON.dumps(param))
			except:
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				try:
					dbcur.execute(dbcur._executed.replace("\'\'", "\'"))
				except:
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
					chain_env['trace'].append(unicode(dbcur._executed, "utf8")) if dbcur._executed else None
				else:
					chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
					result = Model.convert("enum_clients", dbcur)
			else:
				chain_env['logger']("webapi", ("PROCESSING", unicode(dbcur._executed, "utf8"),))
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_clients", dbcur)
				chain_env['logger']("webapi", ("PROCESSING",))
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id']) for entity in result] for e in p]))
			if user_list:
				dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))		
				res2 = Model.convert("enum_users", dbcur)
			
			else:
				res2 = []
			for tmp_obj in res2:
				[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			chain_env['logger']("webapi", ("PROCESSING",))
			chain_env['results'] = result
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_create_client(self, chain_env):
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
			param = (\
				args['name'], args['kana'], args['addr_vip'], args['addr1'], args['addr2'] if args['addr2'] else "",\
				args['tel'],\
				args['fax'] if args['fax'] else "",\
				args['site'] if "site" in args else "",\
				",".join(list(set(args['type_presentation']))), args['type_dealing'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
				args['charging_worker1'], args['charging_worker2'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
			)
			try:
				self.my_log("before")
				#self.my_log("__type_presentation " + ",".join(list(set(args['type_presentation']))))
				dbcur.execute(Model.sql("create_client"), param)
			except Exception, err:
				chain_env['propagate'] = False
				result = {"id": None}
				self.my_log("__createClient Excep " + traceback.format_exc(err))
				try:
					if err.errno == 1048 and err.sqlstate == "23000":
						status['code'] = 2
					else:
						chain_env['trace'].append(traceback.format_exc(err))
				except:
					status['code'] = 2
					chain_env['trace'].append(traceback.format_exc(err))
					pprint.pprint(err)
			else:
				try:
					dbcur.execute(Model.sql("last_insert_id"))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					status['code'] = 1
					dbcon.rollback()
				else:
					result = Model.convert("last_insert_id", dbcur)
					self.my_log("after ")
					status['code'] = 0
					if "note" in args:
						try:
							dbcur.execute(Model.sql("create_client_note"), (result['id'], args['note']))
						except Exception, err:
							chain_env['trace'].append(traceback.format_exc(err))
							status['code'] = 5
							dbcon.rollback()
						else:
							status['code'] = 0
			if status['code'] == 0:
				dbcon.commit()
			else:
				dbcon.rollback()
			dbcur.close()
			dbcon.close()
		chain_env['status']['code'] = status['code'] or 0
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_update_client(self, chain_env):
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
			ACCEPT_FIELDS = ("name", "kana", "addr_vip", "addr1", "addr2", "tel", "fax", "site", "type_presentation", "type_dealing", "charging_worker1", "charging_worker2")
			args = chain_env['argument'].data
			cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
			vals = [args[k] if k not in ("type_presentation") else ",".join(args[k]) for k in cols]
			cols += ["dt_modified"]
			vals += [datetime.datetime.now()]
			cvt = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[args['id'], chain_env['prefix'], args['login_id']\
			]
			#[end] SQL preparation.
			print cols
			print cvt
			try:
				dbcur.execute(Model.sql("update_client") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				if err.errno == 1048 and err.sqlstate == "23000":
					chain_env['status']['code'] = 2
				else:
					chain_env['trace'].append(traceback.format_exc(err))
				dbcon.rollback()
			else:
				chain_env['results'] = {"id": args['id']}
				if "note" in args:
					try:
						dbcur.execute(Model.sql("update_client_note"), (args['id'], args['note'], args['note']))
					except Exception, err:
						chain_env['trace'].append(traceback.format_exc(err))
						chain_env['propagate'] = False
						chain_env['status']['code'] = 2
						dbcon.rollback()
					else:
						chain_env['status']['code'] = 0
						dbcon.commit()
				else:
					chain_env['status']['code'] = 0
					dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_delete_client(self, chain_env):
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
				#Ryo_Add 0401 delete worker that connected with client
				dbcur.execute(Model.sql("delete_worker_by_client_id") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
				dbcur.execute(Model.sql("delete_client") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				chain_env['trace'].append(traceback.format_exc(err))
				dbcon.rollback()
			else:
				chain_env['results']['rows'] = dbcur.rowcount
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_branches(self, chain_env):
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
			FILTERS_LIKE = {\
				"name": "`B`.`name`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`id`",\
				"client_id": "`B`.`client_id`"
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], con.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			orderClause = ["COALESCE(`B`.`dt_modified`, `B`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_branches") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_branches", dbcur)
				status['code'] = 0
			if result:
				user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id']) for entity in result] for e in p]))
				if user_list:
					dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
					res2 = Model.convert("enum_users", dbcur)
				else:
					res2 = []
				for tmp_obj in res2:
					[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
					[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			chain_env['results'] = result
			chain_env['status'] = status
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_create_branch(self, chain_env):
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
				args['client_id'], chain_env['prefix'], args['login_id'],\
				args['name'], args['addr_vip'], args['addr1'], args['addr2'] or "", args['tel'], args['fax'] or "",\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("create_branch"), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = None
				if err.errno == 1048 and err.sqlstate == "23000":
					chain_env['status']['code'] = 2
					chain_env['trace'].append(traceback.format_exc(err))
				else:
					chain_env['trace'].append(traceback.format_exc(err))
			else:
				try:
					dbcur.execute(Model.sql("last_insert_id"))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['status']['code'] = 1
					dbcon.rollback()
				else:
					chain_env['status']['code'] = 0
					chain_env['results'] = Model.convert("create_branch", dbcur)
					dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_update_branch(self, chain_env):
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
			ACCEPT_FIELDS = ("name", "addr_vip", "addr1", "addr2", "tel", "fax")
			args = chain_env['argument'].data
			cols = filter(lambda x: x in ACCEPT_FIELDS and args[x] is not None, args.keys())
			vals = [args[k] for k in cols]
			cols += ["dt_modified"]
			vals += [datetime.datetime.now()]
			cvt = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[args['id'], chain_env['prefix'], args['login_id']\
			]
			#[end] SQL preparation.
			try:
				dbcur.execute(Model.sql("update_branch") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
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
	
	def _fn_delete_branch(self, chain_env):
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
				dbcur.execute(Model.sql("delete_branch") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				chain_env['trace'].append(traceback.format_exc(err))
				dbcon.rollback()
			else:
				chain_env['results']['rows'] = dbcur.rowcount
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_workers(self, chain_env):
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
				"client_name": "`C`.`name`",\
				"name": "`W`.`name`",\
				"kana": "`W`.`kana`",\
				"section": "`W`.`section`",\
				"title": "`MT`.`title`",\
				"note": "`MT`.`note`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`W`.`id`",\
				"client_id": "`W`.`client_id`",\
				"flg_keyperson": "`W`.`flg_keyperson`",\
				"flg_sendmail": "`W`.`flg_sendmail`",\
				"type_dealing": "`C`.`type_dealing`",\
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			if "charging_user_id" in args:
				whereClause += [
					"(`C`.`charging_worker1` = %s OR `C`.`charging_worker2` = %s)"
				]
				whereValues += [args['charging_user_id'], args['charging_user_id']]
			if "type_presentation" in args:
				if args['type_presentation'] in (u"案件", u"人材"):
					whereClause += [\
						"FIND_IN_SET(%s, `C`.`type_presentation`) > 0"\
					]
					whereValues += [args['type_presentation']]
				else:
					whereClause += [\
						"FIND_IN_SET('案件', `C`.`type_presentation`) > 0",\
						"FIND_IN_SET('人材', `C`.`type_presentation`) > 0",\
					]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"kana": "`W`.`kana`",\
				"client_name": "`C`.`kana`",\
				"charging_user": "`W`.`charging_user_id`",\
			}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			orderClause += ["COALESCE(`W`.`dt_modified`, `W`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_workers") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
			except:
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_workers", dbcur)
		if result:
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id'],) for entity in result] for e in p]))
			if user_list:
				dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
				res2 = Model.convert("enum_users", dbcur)
			else:
				res2 = []
			for tmp_obj in res2:
				[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_workers_compact(self, chain_env):
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
				"client_name": "`C`.`name`",\
				"name": "`W`.`name`",\
				"kana": "`W`.`kana`",\
				"section": "`W`.`section`",\
				"title": "`MT`.`title`",\
				"note": "`MT`.`note`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`W`.`id`",\
				"client_id": "`W`.`client_id`",\
				"flg_keyperson": "`W`.`flg_keyperson`",\
				"flg_sendmail": "`W`.`flg_sendmail`",\
				"type_dealing": "`C`.`type_dealing`",\
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			if "charging_user_id" in args:
				whereClause += [
					"(`C`.`charging_worker1` = %s OR `C`.`charging_worker2` = %s)"
				]
				whereValues += [args['charging_user_id'], args['charging_user_id']]
			if "type_presentation" in args:
				if args['type_presentation'] in (u"案件", u"人材"):
					whereClause += [\
						"FIND_IN_SET(%s, `C`.`type_presentation`) > 0"\
					]
					whereValues += [args['type_presentation']]
				else:
					whereClause += [\
						"FIND_IN_SET('案件', `C`.`type_presentation`) > 0",\
						"FIND_IN_SET('人材', `C`.`type_presentation`) > 0",\
					]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"kana": "`W`.`kana`",\
				"client_name": "`C`.`kana`",\
				"charging_user": "`W`.`charging_user_id`",\
			}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			orderClause += ["COALESCE(`W`.`dt_modified`, `W`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_workers") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
			except:
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_workers", dbcur)
		if result:
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_create_worker(self, chain_env):
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
				args['client_id'], args['name'], args['kana'], args['section'], args['title'],\
				args['tel'], args['tel2'], args['mail1'], args['mail2'] , args['flg_keyperson'], args['flg_sendmail'],\
				args['charging_user_login_id'] if "charging_user_login_id" in args else None,\
				chain_env['prefix'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
				args['recipient_priority'] if "recipient_priority" in args else 5,\
				chain_env['prefix'], args['login_id'], args['credential'],\
			)
			try:
				dbcur.execute(Model.sql("create_worker"), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}#Model.convert("create_worker", dbcur)
				print traceback.format_exc()
				print dbcur._executed
				if err.errno == 1048 and err.sqlstate == "23000":
					chain_env['status']['code'] = 2
				else:
					chain_env['trace'].append(traceback.format_exc(err))
			else:
				try:
					dbcur.execute(Model.sql("last_insert_id"))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['status']['code'] = 1
					dbcon.rollback()
				else:
					chain_env['status']['code'] = 0
					chain_env['results'] = {"id": dbcur.fetchone()[0]}
					dbcon.commit()
			if "note" in args and "id" in chain_env['results']:
				dbcur.execute(Model.sql("create_worker_note"), (chain_env['results']['id'], args['note'], args['note']))
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_update_worker(self, chain_env):
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
			ACCEPT_FIELDS = ("name", "kana", "section", "title", "tel", "tel2", "mail1", "mail2", "flg_keyperson", "flg_sendmail", "recipient_priority")
			args = chain_env['argument'].data
			cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
			vals = [args[k] for k in cols]
			cols += ["dt_modified"]
			vals += [datetime.datetime.now()]
			cvt = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				[args['charging_user_login_id'] if "charging_user_login_id" in args and args['charging_user_login_id'] else None] +\
				[chain_env['prefix'],] +\
				vals +\
				[args['id'], chain_env['prefix'], args['login_id']]
			#[end] SQL preparation.
			try:
				dbcur.execute(Model.sql("update_worker") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				if err.errno == 1048 and err.sqlstate == "23000":
					chain_env['status']['code'] = 2
				else:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
				dbcon.rollback()
			else:
				chain_env['trace'].append(dbcur._executed)
				chain_env['results'] = {}
				dbcon.commit()
				chain_env['status']['code'] = chain_env['status']['code'] or 0
			if "note" in args and "id" in args:
				dbcur.execute(Model.sql("create_worker_note"), (args['id'], args['note'], args['note']))
				dbcon.commit()
			chain_env['status']['code'] = chain_env['status']['code'] or 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_delete_worker(self, chain_env):
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
				dbcur.execute(Model.sql("delete_worker") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				chain_env['trace'].append(traceback.format_exc(err))
				dbcon.rollback()
			else:
				chain_env['results']['rows'] = dbcur.rowcount
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_contacts(self, chain_env):
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
			#[begin] Build where clause conditions.
			FILTERS_LIKE = {\
				\
			}
			FILTERS_SERIOUS = {\
				"subject": "`C`.`subject`",\
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], con.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			orderClause = ["`C`.`dt_created` DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_contacts") % (\
						", ".join(map(str, set(args['client_id_list']))),\
						("AND " + "\n    AND ".join(whereClause)) if whereClause else "",\
						", ".join(orderClause)\
					), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_contacts", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_create_contact(self, chain_env):
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
				args['client_id'], chain_env['prefix'], args['login_id'],\
				args['subject'], args['note'],\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			try:
				dbcur.execute(Model.sql("create_contact"), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = Model.convert("create_worker", dbcur)
				if err.errno == 1048 and err.sqlstate == "23000":
					chain_env['status']['code'] = 2
				else:
					chain_env['trace'].append(traceback.format_exc(err))
			else:
				try:
					dbcur.execute(Model.sql("last_insert_id"))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['status']['code'] = 1
					dbcon.rollback()
				else:
					chain_env['status']['code'] = 0
					chain_env['results'] = Model.convert("create_contact", dbcur)
					dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_delete_contact(self, chain_env):
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
				dbcur.execute(Model.sql("delete_contact") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
			except Exception, err:
				chain_env['propagate'] = False
				chain_env['results'] = {"id": None}
				chain_env['trace'].append(traceback.format_exc(err))
				dbcon.rollback()
			else:
				chain_env['results']['rows'] = dbcur.rowcount
				dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
