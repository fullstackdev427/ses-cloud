#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides Groupware logics.
"""

import time
import datetime
import copy
import hashlib
import datetime
import traceback
import pprint
import re
import flask

from providers.limitter import Limitter
from validators.base import ValidatorBase as Validator
from models.misc import Misc as Model
from base import ProcessorBase
from errors import exceptions as EXC

class Processor(ProcessorBase):
	
	"""
		This class provides miscellaneous Groupware object manipulation functionalities.
	"""
	
	__realms__ = {\
		"scheduleTop": {\
			"logic": "html_schedule_top",\
		},\
		"todoTop": {\
			"logic": "html_todo_top",\
		},\
		"enumSchedules": {\
			"logic": "enum_schedules",\
		},\
		"createSchedule": {\
			"valid_in": "create_schedule_in",\
			"logic": "create_schedule",\
		},\
		"updateSchedule": {\
			"valid_in": "update_schedule_in",\
			"logic": "update_schedule",\
		},\
		"deleteSchedule": {\
			"valid_in": "delete_schedule_in",\
			"logic": "delete_schedule",\
		},\
		"enumTodos": {\
			"valid_in": None,\
			"logic": "enum_todos",\
		},\
		"createTodo": {\
			"valid_in": None,\
			"logic": "create_todo",\
		},\
		"updateTodo": {\
			"valid_in": None,\
			"logic": "update_todo",\
		},\
		"deleteTodo": {\
			"valid_in": None,\
			"logic": "delete_todo",\
		},\
	}
	
	def _fn_html_todo_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch negotiations.
		status_clients, render_param['misc.enumTodos'] = self._fn_enum_todos(chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		chain_env['response_body'] = flask.render_template(\
			"todo.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"ToDo|SESクラウド",\
			current="misc.todoTop")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_html_schedule_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		from logics.auth import Processor as P_AUTH
		from logics.manage import Processor as P_MANAGE
		def gen_dates(datum, account_list, distance_w=0):
			dt_local = time.localtime()
			dt_now = datetime.datetime(dt_local.tm_year, dt_local.tm_mon, dt_local.tm_mday)
			DAY_DIFF = datetime.timedelta(1)
			DAYS = (u"月", u"火", u"水", u"木", u"金", u"土", u"日")
			dt_list = [(dt_now + DAY_DIFF * 7 * distance_w + DAY_DIFF * i).strftime("%Y/%m/%d") for i in xrange(0, 7)]
			data_list = {}
			day_list = []
			for account in account_list:
				tmp = {}
				[tmp.update({dt_str: []}) for dt_str in dt_list]
				for data in datum:
					if data['creator']['id'] == account:
						tmp[data['dt_scheduled'].split(" ")[0]].append(data) if data['dt_scheduled'].split(" ")[0] in dt_list else None
				data_list[account] = tmp
			[day_list.append(DAYS[time.strptime(dt_str, "%Y/%m/%d").tm_wday]) for dt_str in dt_list]
			return day_list, data_list
		def gen_group(datum):
			dt_local = time.localtime()
			dt_now = datetime.datetime(dt_local.tm_year, dt_local.tm_mon, dt_local.tm_mday)
			data_list = {}
			data_list['group'] = [data for data in datum if data['dt_scheduled'].split(" ")[0] == dt_now.strftime("%Y/%m/%d")]
			return data_list
		render_param = {}
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch schedules.
		status_clients, render_param['misc.enumSchedules'] = self._fn_enum_schedules(chain_env)
		render_param['js.schedules'] = render_param['misc.enumSchedules']
		#[begin] support objects.
		clean_env = copy.deepcopy(chain_env)
		clean_env['argument'].clear()
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#Bind schedules.
		render_param['manage.enumSchedules:day_list'], render_param['manage.enumSchedules:data_dict'] = gen_dates(\
			render_param['misc.enumSchedules'],\
			[account['id'] for account in render_param['manage.enumAccounts']],\
			chain_env['argument'].data['week'] if "week" in chain_env['argument'].data else 0\
		)
		if "week" in chain_env['argument'].data:
			dummy, curr_week_schedule = self._fn_enum_schedules(clean_env)
			render_param['manage.enumSchedules:data_dict'].update(gen_group(curr_week_schedule))
		else:
			render_param['manage.enumSchedules:data_dict'].update(gen_group(render_param['misc.enumSchedules']))
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"schedule.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"スケジュール|SESクラウド",\
			current="misc.scheduleTop")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_enum_schedules(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		status = {"code": None, "description": None}
		result = []
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
				args['week'] if "week" in args else 0, (args['week'] + 1) if "week" in args else 1,\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			)
			dbcur.execute(Model.sql("enum_schedules"), param1)
			result = Model.convert("enum_schedules", dbcur)
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id']) for entity in result] for e in p]))
			if result:
				try:
					dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
				except:
					raise Exception(dbcur._executed)
				res2 = Model.convert("enum_users", dbcur)
				for tmp_obj in res2:
					[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
					[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_create_schedule(self, chain_env):
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
				args['title'], args['note'] if "note" in args else "", self.str2datetime_ex(args['dt_scheduled']),\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential']\
			)
			try:
				dbcur.execute(Model.sql("create_schedule"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
			else:
				dbcon.commit()
				dbcur.execute(Model.sql("last_insert_id"))
				chain_env['status']['code'] = 0
				chain_env['results'] = {"id": Model.convert("last_insert_id", dbcur)}
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_update_schedule(self, chain_env):
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
			ACCEPT_FIELDS = ("title", "note", "dt_scheduled")
			args = chain_env['argument'].data
			cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
			vals = [(self.str2datetime_ex(args[k]) or None) if k == "dt_scheduled" else args[k] for k in cols]
			cols += ["dt_modified"]
			vals += [datetime.datetime.now()]
			cvt = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[args['id'], chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				[chain_env['prefix'], chain_env['login_id']]
			#[end] SQL preparation.
			try:
				dbcur.execute(Model.sql("update_schedule") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
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
	
	def _fn_delete_schedule(self, chain_env):
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
				dbcur.execute(Model.sql("delete_schedule") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
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
	
	def _fn_enum_todos(self, chain_env):
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
				"note": "`note`",\
			}
			FILTERS_SERIOUS = {\
				"priority": "`priority`",\
				"status": "`status`",
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			orderClause = [\
				"`priority` ASC",\
				"COALESCE(`dt_modified`, `dt_created`) DESC",\
			]
			#[end] Build order by clause.
			param1 = \
				[chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_todos") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param1)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				result = Model.convert("enum_todos", dbcur)
				status['code'] = 0
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id']) for entity in result] for e in p]))
			if result:
				try:
					dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
				except:
					raise Exception(dbcur._executed)
				res2 = Model.convert("enum_users", dbcur)
				for tmp_obj in res2:
					[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
					[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			dbcur.close()
			dbcon.close()
			status['code'] = 0
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_create_todo(self, chain_env):
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
				args['note'], args['priority'], args['status'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			)
			try:
				dbcur.execute(Model.sql("create_todo"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed)
			else:
				dbcon.commit()
				dbcur.execute(Model.sql("last_insert_id"))
				chain_env['result'] = {"id": Model.convert("last_insert_id", dbcur)}
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_update_todo(self, chain_env):
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
			ACCEPT_FIELDS = ("note", "priority", "status")
			args = chain_env['argument'].data
			cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
			vals = [args[k] for k in cols]
			cols += ["dt_modified"]
			vals += [datetime.datetime.now()]
			cvt = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[args['id'], chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				[chain_env['prefix'], chain_env['login_id']]
			#[end] SQL preparation.
			try:
				dbcur.execute(Model.sql("update_todo") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
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
	
	def _fn_delete_todo(self, chain_env):
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
				dbcur.execute(Model.sql("delete_todo") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
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
	
