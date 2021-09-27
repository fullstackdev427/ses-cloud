#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides project logics.
"""

import time
import datetime
import hashlib
import re
import pprint
import traceback
import copy

import flask

from providers.limitter import Limitter
from validators.base import ValidatorBase as Validator
from models.project import Project as Model
from base import ProcessorBase
from errors import exceptions as EXC
from providers.limitter import Limitter

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
		"enumProjects": {\
			"logic": "enum_projects",\
		}, \
		"enumBpProjects": { \
			"logic": "enum_bp_projects", \
			}, \
		"enumProjectsCompact": { \
			"logic": "enum_projects_compact", \
			},\
		"createProject": {\
			"valid_in": "create_project_in",\
			"logics": [\
				"check_item_cap",\
				"create_project",\
			],\
		},\
		"updateProject": {\
			"valid_in": "update_project_in",\
			"logic": "update_project",\
		},\
		"deleteProject": {\
			"valid_in": "delete_project_in",\
			"logic": "delete_project",\
		}, \
		"searchProjects": { \
			"logic": "search_projects", \
		}, \
		"setSkills": {\
			"logic": "set_skills",\
		},\
		"lastThreeDays": { \
			"logic": "last_three_days"
		},\
		"updateMatchingProject": { \
            "logic": "update_matching_project"
        }, \
	}

	def _fn_check_item_cap(self, chain_env):
		self.check_limit(chain_env, ("LMT_LEN_PROJECT",))

	def _fn_html_top(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		render_param = {}
		from logics.auth import Processor as P_AUTH
		from logics.client import Processor as P_CLIENT
		from logics.manage import Processor as P_MANAGE
		from logics.skill import Processor as P_SKILL
		from logics.occupation import Processor as P_OCCUPATION
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		#Fetch projects.
		status_projects, render_param['project.enumProjects'] = self._fn_enum_projects(chain_env)
		#[begin] support objects.
		clean_env = copy.deepcopy(chain_env)
		clean_env['argument'].clear()
		#Fetch clients.
		status_client, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
		render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in render_param['client.enumClients']]
		#Fetch user accounts.
		status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
		#Fetch skills.
		status_skills, render_param['skill.enumSkills'] = P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
		status_skills, render_param['skill.enumSkillCategories'] = P_SKILL(self.__pref__)._fn_enum_skill_categories(chain_env)
		status_skills, render_param['skill.enumSkillLevels'] = P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
		status_projects, render_param['occupation.enumOccupations'] = P_OCCUPATION(self.__pref__)._fn_enum_occupations(
			chain_env)

		#Count projects.
		status_count, render_count = Limitter.count_records(self.__pref__, chain_env)
		#Fetch current status for Limit.
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"project.tpl",
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"案件|SESクラウド",\
			current="project.top")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_enum_projects(self, chain_env):
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
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"note": "`NOTE`.`note`",\
				# "term": "`MT`.`term`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
			}
			
			FILTERS_SERIOUS = {\
				"id": "`MT`.`id`", \
				"project_id": "`MT`.`id`", \
				"scheme": "`MT`.`scheme`",\
				"interview": "`MT`.`interview`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"is_enabled": "`MT`.`is_enabled`", \
				"flg_public": "`MT`.`flg_public`", \
				}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.

			if ("term" in args):
				whereClause.append("(MT.term_begin <= \'" + args['term'] + "\' AND MT.term_end >= \'" + args['term'] + "\' )")

			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"scheme": "`MT`.`scheme`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
				"fee_outbound": "`MT`.`fee_outbound`",\
				"expense": "`MT`.`expense`",\
				"station": "`MT`.`station`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"dt_created": "`MT`.`dt_created`", \
				"flg_public": "`MT`.`flg_public`", \
				}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			if "sort_keys" in args and "dt_created" in args['sort_keys']:
				pass
			else:
				orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id'], chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_projects") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
				#self.my_log(Model.sql("enum_projects") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)))
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_projects", dbcur)
			#[begin] Joining client.
			client_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['client']['id'],) for entity in result] for e in p]))
			if client_list:
				dbcur.execute(Model.sql("enum_related_clients") % ", ".join(map(str, client_list)), (chain_env['prefix'], chain_env['login_id'], chain_env['credential']))
				res3 = Model.convert("enum_clients", dbcur)
				for tmp_obj in res3:
					[entity['client'].update(tmp_obj) for entity in result if entity['client']['id'] == tmp_obj['id']]
			#[end] Joining client.
			#[begin] Joining charging_user_id.
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['charging_user']['id'], entity['creator']['id'], entity['modifier']['id']) for entity in result] for e in p]))
			if user_list:
				dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
				res2 = Model.convert("enum_users", dbcur)
			else:
				res2 = []
			for tmp_obj in res2:
				[entity['charging_user'].update(tmp_obj) for entity in result if entity['charging_user']['id'] == tmp_obj['id']]
				[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			#[end] Joining charging_user_id.
			pid_list = set([p['id'] for p in result])
			if pid_list:
				dbcur.execute(Model.sql("enum_project_skill_levels") % (
				"`P`.`project_id` IN (%s)" % ", ".join(map(str, pid_list))))
				chain_env['trace'].append(dbcur._executed)
				level_list = Model.convert("enum_project_skill_levels", dbcur)
				for level in level_list:
					for res in result:
						if res['id'] == level['project_id']:
							res['skill_level_list'].append(level)
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_projects_compact(self, chain_env):
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
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"note": "`NOTE`.`note`",\
				"term": "`MT`.`term`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`MT`.`id`",\
				"scheme": "`MT`.`scheme`",\
				"interview": "`MT`.`interview`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"is_enabled": "`MT`.`is_enabled`",\
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"scheme": "`MT`.`scheme`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
				"fee_outbound": "`MT`.`fee_outbound`",\
				"expense": "`MT`.`expense`",\
				"station": "`MT`.`station`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"dt_created": "`MT`.`dt_created`",\
			}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			if "sort_keys" in args and "dt_created" in args['sort_keys']:
				pass
			else:
				orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id'], chain_env['prefix'], chain_env['login_id']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_projects") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_projects", dbcur)
				status['code'] = 0
				dbcur.close()
				dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_bp_projects(self, chain_env):
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
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"note": "`NOTE`.`note`",\
				"term": "`MT`.`term`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`MT`.`id`",\
				"scheme": "`MT`.`scheme`",\
				"interview": "`MT`.`interview`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"is_enabled": "`MT`.`is_enabled`",\
			}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
			#[end] Build where clause conditions.

			if ("project_ids" in args):
				whereClause.append("`MT`.`id` in(" + ", ".join(map(str, args["project_ids"])) + ")")

			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"scheme": "`MT`.`scheme`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
				"fee_outbound": "`MT`.`fee_outbound`",\
				"expense": "`MT`.`expense`",\
				"station": "`MT`.`station`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"dt_created": "`MT`.`dt_created`",\
			}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			if "sort_keys" in args and "dt_created" in args['sort_keys']:
				pass
			else:
				orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
			#[end] Build order by clause.
			param = \
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues
			try:
				dbcur.execute(Model.sql("enum_bp_projects") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("enum_bp_projects", dbcur)
				status['code'] = 0
				dbcur.close()
				dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_create_project(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		if not chain_env['propagate']:
			return
		def str2datetime(text):
			matched = re.compile("^(([0-9]{4})([0-9]{2})([0-9]{2}))|(([0-9]{4})[\-/]([0-9]{2})[\-/]([0-9]{2}))$").findall(text)
			return datetime.datetime(*(map(int, (matched[0][1:4] if matched[0][1] else matched[0][5:8]))))
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
			param = (\
				args['client_id'] if "client_id" in args else None, chain_env['prefix'], chain_env['login_id'],\
				args['client_name'] if "client_name" in args else None, args['fee_inbound'], args['fee_outbound'],\
				args['term_begin'] if ("term_begin" in args and args["term_begin"] != "") else None,\
				args['term_end'] if ("term_end" in args and args["term_end"] != "") else None,\
				args['title'], args['station'] if "station" in args else None, args['process'], args['expense'],\
				args['interview'],\
				args['scheme'] if "scheme" in args and args['scheme'].strip() else None, args['flg_shared'],\
				args['charging_user_id'], chain_env['prefix'], chain_env['login_id'], args['charging_user_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
				args['term'] if "term" in args else "",\
				args['skill_needs'] if "skill_needs" in args else "",\
				args['skill_recommends'] if "skill_recommends" in args else "",\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'], \
				args['age_from'],args['age_to'], args['rank_id'], \
				args['station_cd'], args['station_pref_cd'], args['station_line_cd'], \
				args['station_lon'], args['station_lat'], \
				args['flg_public'], args.get('web_public', 0), args['flg_foreign'] if "flg_foreign" in args and args['flg_foreign'].strip() else None, \
				)
			try:
				dbcur.execute(Model.sql("create_project"), param)
			except Exception, err:
				chain_env['propagate'] = False
				result = {"id": None}
				if err.errno == 1048 and err.sqlstate == "23000":
					status['code'] = 2
				else:
					chain_env['trace'].append(err)
			else:
				try:
					dbcur.execute(Model.sql("last_insert_id"))
				except Exception, err:
					chain_env['trace'].append(err)
					status['code'] = 1
				else:
					result = Model.convert("last_insert_id", dbcur)
					status['code'] = 0
			if "note" in args and status['code'] == 0:
				try:
					dbcur.execute("""\
INSERT INTO `ft_project_notes` (`project_id`, `note`) VALUES (
  %s, %s);""", (result['id'], args['note']))
				except:
					status['code'] = 2
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
					chain_env['trace'].append(unicode(dbcur._executed)) if dbcur._executed else None
				else:
					status['code'] = 0
			if "internal_note" in args and status['code'] == 0:
				try:
					dbcur.execute("""\
INSERT INTO `ft_project_internal_notes` (`project_id`, `internal_note`) VALUES (
  %s, %s);""", (result['id'], args['internal_note']))
				except:
					status['code'] = 2
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
					chain_env['trace'].append(unicode(dbcur._executed)) if dbcur._executed else None
				else:
					status['code'] = 0
			dbcon.commit() if status['code'] == 0 else dbcon.rollback()
			dbcur.close()
			dbcon.close()
			if status['code'] == 0:
				chain_env['argument'].data["id"] = result['id']
				self._fn_set_skills(chain_env)
				self._fn_set_occupations(chain_env)
		chain_env['results'] = result
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_update_project(self, chain_env):
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
			#[begin] SQL preparation.
			ACCEPT_FIELDS = (\
				"client_id", "client_name", "fee_inbound", "fee_outbound", "title", "station", "process", "expense", \
				"interview", "scheme", "flg_shared", "charging_user_id", "term", "skill_needs", "skill_recommends", \
				"age_from", "age_to","rank_id", \
				"station_cd", "station_pref_cd", "station_line_cd","station_lon","station_lat","flg_public","web_public","flg_foreign",)
			args = chain_env['argument'].data
			if "scheme" in args and args['scheme'] == "":
				args['scheme'] = None
			if "flg_foreign" in args and args['flg_foreign'] == "":
				args['flg_foreign'] = None
			import json as JSON
			self.my_log("__args " + JSON.dumps(args))

			cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
			# vals = [(self.str2datetime(args[k]) or None) if k.startswith("term_") else args[k] for k in cols]
			vals = [args[k] for k in cols]
			if "term_begin" in args:
				cols += ["term_begin"]
				vals += [args['term_begin'] if (args['term_begin'] and args['term_begin'] != "")  else None]
			if "term_end" in args:
				cols += ["term_end"]
				vals += [args['term_end'] if (args['term_end'] and args['term_end'] != "")  else None]
			if "flg_public" in args and args['flg_public'] == True:
				cols += ["is_show_matching"]
				vals += [1]
			cols += ["dt_modified"]
			vals += [datetime.datetime.now()]
			if "client_name" in cols:
				cols += ["client_id"]
				vals += [None]
			cvt = \
				[chain_env['prefix'], args['login_id'], args['credential']] +\
				vals +\
				[args['id'], chain_env['prefix'], args['login_id']]
			#[end] SQL preparation.
			try:
				dbcur.execute(Model.sql("update_project") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc())
				chain_env['trace'].append(dbcur._executed)
				chain_env['propagate'] = False
				print err
				result = {"id": None}
				if err.errno == 1048 and err.sqlstate == "23000":
					status['code'] = 2
				else:
					chain_env['trace'].append(traceback.format_exc(err))
					status['code'] = 2
			else:
				chain_env['trace'].append(dbcur._executed)
				result = {}
				status['code'] = status['code'] or 0
			if "note" in args and status['code'] == 0:
				try:
					dbcur.execute("""\
INSERT INTO `ft_project_notes` (`project_id`, `note`) VALUES (
  %s, %s) ON DUPLICATE KEY UPDATE `note`=%s;""", (args['id'], args['note'], args['note']))
				except:
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
					chain_env['trace'].append(unicode(dbcur._executed)) if dbcur._executed else None
				else:
					status['code'] = 0
			if "internal_note" in args and status['code'] == 0:
				try:
					dbcur.execute("""\
INSERT INTO `ft_project_internal_notes` (`project_id`, `internal_note`) VALUES (
  %s, %s) ON DUPLICATE KEY UPDATE `internal_note`=%s;""", (args['id'], args['internal_note'], args['internal_note']))
				except:
					chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
					chain_env['trace'].append(unicode(dbcur._executed)) if dbcur._executed else None
				else:
					status['code'] = 0
			dbcon.commit() if status['code'] == 0 else dbcon.rollback()
			dbcur.close()
			dbcon.close()
			if status['code'] == 0 and "update_data_only" not in args:
				self._fn_set_skills(chain_env)
				if status['code'] == 0 and "update_data_and_skill_only" not in args:
					self._fn_set_occupations(chain_env)
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_delete_project(self, chain_env):
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
				dbcur.execute(Model.sql("delete_project") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
			except Exception, err:
				chain_env['trace'].append(dbcur._executed)
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

	def _fn_search_projects(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = []
		status = {"code": None, "description": None}
		self.my_log("__search_projects__ ")
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
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"term": "`MT`.`term`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
			}
			FILTERS_SERIOUS = {\
				"id": "`MT`.`id`",\
				"scheme": "`MT`.`scheme`",\
				"interview": "`MT`.`interview`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"is_enabled": "`MT`.`is_enabled`", \
				"flg_public": "`MT`.`flg_public`", \
				"flg_foreign": "`MT`.`flg_foreign`", \
				}
			whereClause = []
			whereValues = []
			[whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
			[whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]

			if("rank_id" in args):
				whereClause.append("MT.rank_id in (" + ",".join(args['rank_id']) + " ) ")
			if ("occupation_id" in args):
				whereClause.append("CRO.occupation_id in (" + ",".join(args['occupation_id']) + " ) ")
			if ("skill_id" in args):
				whereClause.append("CRS.skill_id in (" + ",".join(args['skill_id']) + " ) ")
			if ("flg_skill_level" in args):
				if ( "skill_level_list" in args and args["flg_skill_level"] == "1"):
					skillWhere =[]
					for tmpSkill in args["skill_level_list"]:
						skillWhere.append("CRS.skill_id = " + tmpSkill["skill_id"] + " and CRS.level <= " + tmpSkill["level"])
					whereClause.append("((" + " )OR( ".join(skillWhere) + "))")
			if ("client_id" in args and "company_id" in args):
				whereClause.append("(MT.client_id in (" + ",".join(args['client_id']) + ") OR MT.owner_company_id in (" + ",".join(args['company_id']) + ")) ")
			if ("client_id" in args and "company_id" not in args):
				whereClause.append("MT.client_id in (" + ",".join(args['client_id']) + " ) ")
			if ("company_id" in args and "client_id" not in args):
				whereClause.append("MT.owner_company_id in (" + ",".join(args['company_id']) + " ) ")
			if ("not_company_id" in args):
				whereClause.append("MT.owner_company_id not in (" + ",".join(args['not_company_id']) + " ) ")
			if ("term_begin" in args):
				whereClause.append("(MT.term_begin >= \'" + args['term_begin'] + "\' OR MT.term_end >= \'" + args['term_begin'] + "\' )")
			else:
				whereClause.append("(MT.term_begin IS NULL OR ADDDATE(CURDATE(), INTERVAL 1 MONTH) >= MT.term_begin)")
			if ("term_end" in args):
				whereClause.append("(MT.term_begin <= \'" + args['term_end'] + "\' OR MT.term_end <= \'" + args['term_end'] + "\' )")
			else:
				whereClause.append("(MT.term_end IS NULL OR ADDDATE(CURDATE(), INTERVAL -1 MONTH) <= MT.term_end)")
			if ("amount_from" in args):
				whereClause.append("(MT.fee_outbound >= (" + args['amount_from'] + " * 10000))" )
			if ("amount_to" in args):
				whereClause.append("(MT.fee_outbound <= (" + args['amount_to'] + " * 10000))"  )
			if ("age_from" in args):
				whereClause.append("(MT.age_from >= " + args['age_from'] + " OR MT.age_to >= " + args['age_from'] + " )")
			if ("age_to" in args):
				whereClause.append("(MT.age_from <= " + args['age_to'] + " OR MT.age_to <= " + args['age_to'] + " )")
			if ("travel_time" in args and "station_lat" in args and "station_lon" in args):
				if (int(args['travel_time'][0]) < 90):
					whereClause.append("`MT`.`station_lat` is not null and travel_time_from_distance(" + args['station_lat'] + "," + args['station_lon'] + ",`MT`.`station_lat`,`MT`.`station_lon`) <= " + args['travel_time'][0])


			#[end] Build where clause conditions.
			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))",\
				"title": "`MT`.`title`",\
				"scheme": "`MT`.`scheme`",\
				"fee_inbound": "`MT`.`fee_inbound`",\
				"fee_outbound": "`MT`.`fee_outbound`",\
				"expense": "`MT`.`expense`", \
				"interview": "`MT`.`interview`", \
				"station": "`MT`.`station`",\
				"flg_shared": "`MT`.`flg_shared`",\
				"dt_created": "`MT`.`dt_created`", \
				"dt_modified": "`MT`.`dt_modified`", \
				"charging_user_id": "`MT`.`charging_user_id`", \
				"rank_id": "`MT`.`rank_id`",
				"occupation_count": "`occupation_count`", \
				"skill_count": "`skill_count`", \
				"term_begin": "`MT`.`term_begin`", \
				"term_end": "`MT`.`term_end`", \
				"age_from": "`MT`.`age_from`", \
				"age_to": "`MT`.`age_to`", \
				"travel_time": "`travel_time`", \
				}
			orderClause = []
			if "sort_keys" in args:
				for k in args['sort_keys']:
					if k in ORDER_KEYS:
						orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
			if "sort_keys" in args and "dt_created" in args['sort_keys']:
				pass
			else:
				orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
			#[end] Build order by clause.

			station_lat = 0
			station_lon = 0
			station_flg = 0
			if ("station_lat" in args):
				station_lat = args['station_lat']
			if ("station_lon" in args):
				station_lon = args['station_lon']
			if ("station_lat" in args or "station_lon" in args):
				station_flg = 1

			param = \
				[station_flg, station_lat, station_lon] +\
				[chain_env['prefix'], chain_env['login_id'], chain_env['credential']] +\
				whereValues

			try:
				string = Model.sql("search_projects") % (("AND " + "\n	    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause))
				dbcur.execute(string, param)
				#self.my_log("__search_projects__ " + Model.sql("search_projects") % (("AND " + "\n	    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)))
				#import json as JSON
				#self.my_log("__param " + JSON.dumps(param))
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				self.my_log("__search_projects_exception__ " + traceback.format_exc())
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("search_projects", dbcur)
			#[begin] Joining client.
			client_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['client']['id'],) for entity in result] for e in p]))
			if client_list:
				dbcur.execute(Model.sql("enum_related_clients") % ", ".join(map(str, client_list)), (chain_env['prefix'], chain_env['login_id'], chain_env['credential']))
				res3 = Model.convert("enum_clients", dbcur)
				for tmp_obj in res3:
					[entity['client'].update(tmp_obj) for entity in result if entity['client']['id'] == tmp_obj['id']]
			#[end] Joining client.
			#[begin] Joining charging_user_id.
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['charging_user']['id'], entity['creator']['id'], entity['modifier']['id']) for entity in result] for e in p]))
			if user_list:
				dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
				res2 = Model.convert("enum_users", dbcur)
			else:
				res2 = []
			for tmp_obj in res2:
				[entity['charging_user'].update(tmp_obj) for entity in result if entity['charging_user']['id'] == tmp_obj['id']]
				[entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
				[entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
			#[end] Joining charging_user_id.
			pid_list = set([p['id'] for p in result])
			if pid_list:
				dbcur.execute(Model.sql("enum_project_skill_levels") % (
					"`P`.`project_id` IN (%s)" % ", ".join(map(str, pid_list))))
				chain_env['trace'].append(dbcur._executed)
				level_list = Model.convert("enum_project_skill_levels", dbcur)
				for level in level_list:
					for res in result:
						if res['id'] == level['project_id']:
							res['skill_level_list'].append(level)
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_set_skills(self, chain_env):
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
			param_needs = (\
				"cr_prj_skill_needs",\
				", ".join(map(str, set(args['needs']))) if "needs" in args else ""
			)
			# param_recommends= (\
			# 	"cr_prj_skill_recommends",\
			# 	", ".join(map(str, set(args['recommends']))) if "recommends" in args else ""
			# )
			param = (\
				args['id'],\
				chain_env['prefix'], args['login_id'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			result = {"needs": 0, "recommends": 0}
			# if not args['needs'] or not args['recommends']:
			# 	chain_env['status']['code'] = chain_env['status']['code'] or 0
			# 	self.perf_time(chain_env, time.time() - time_bg)
			# 	return
			flg_ok = True
			if flg_ok:
				try:#Delete all.
					#ACL checking is skipped because following SQL statement checks
					#and if invalid access, you get user defined exception.
					dbcur.execute("""DELETE FROM `%s` WHERE `project_id`=%%s;""" % ("cr_prj_skill_needs",), (args['id'],))
					# dbcur.execute("""DELETE FROM `%s` WHERE `project_id`=%%s;""" % ("cr_prj_skill_recommends",), (args['id'],))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['propagate'] = False
					dbcon.rollback()
					flg_ok = False
			if flg_ok and "needs" in args:
				try:#Insert needs.
					dbcur.execute(Model.sql("set_skills") % param_needs, param)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					chain_env['propagate'] = False
					dbcon.rollback()
					print err
					flg_ok = False
				else:
					result['needs'] = dbcur.rowcount
			if flg_ok and "skill_level_list" in args:
				try:
					for levelObj in args['skill_level_list']:
						param_levels = (levelObj['level'], args['id'], levelObj['id']);
						dbcur.execute(Model.sql("update_skill_level"), param_levels)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					chain_env['propagate'] = False
					dbcon.rollback()
					print err
					flg_ok = False
				else:
					result['skill_id_list'] = dbcur.rowcount
			# if flg_ok:
			# 	try:#Insert recommends.
			# 		dbcur.execute(Model.sql("set_skills") % param_recommends, param)
			# 	except Exception, err:
			# 		chain_env['trace'].append(traceback.format_exc(err))
			# 		chain_env['trace'].append(dbcur._executed)
			# 		chain_env['propagate'] = False
			# 		dbcon.rollback()
			# 		flg_ok = False
			# 	else:
			# 		result['recommends'] = dbcur.rowcount
			dbcon.commit()
			# dbcon.commit() if sum(result.values()) else None
			dbcur.close()
			dbcon.close()
		chain_env['results']['rows'] = result
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_set_occupations(self, chain_env):
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
			param_needs = (\
				"cr_prj_ocp_needs",\
				", ".join(map(str, set(args['occupations']))) if "occupations" in args else ""
			)
			param = (\
				args['id'],\
				chain_env['prefix'], args['login_id'],\
				chain_env['prefix'], args['login_id'], args['credential'],\
				chain_env['prefix'], args['login_id'], args['credential']\
			)
			result = {"occupations": 0, }

			flg_ok = True
			if flg_ok:
				try:#Delete all.
					#ACL checking is skipped because following SQL statement checks
					#and if invalid access, you get user defined exception.
					dbcur.execute("""DELETE FROM `%s` WHERE `project_id`=%%s;""" % ("cr_prj_ocp_needs",), (args['id'],))
					# dbcur.execute("""DELETE FROM `%s` WHERE `project_id`=%%s;""" % ("cr_prj_skill_recommends",), (args['id'],))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['propagate'] = False
					print err
					dbcon.rollback()
					flg_ok = False
			if flg_ok and "occupations" in args:
				try:#Insert .
					dbcur.execute(Model.sql("set_occupations") % param_needs, param)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					chain_env['trace'].append(dbcur._executed)
					chain_env['propagate'] = False
					dbcon.rollback()
					print err
					flg_ok = False
				else:
					result['occupations'] = dbcur.rowcount
			dbcon.commit()
			dbcur.close()
			dbcon.close()
		chain_env['results']['rows'] = result
		chain_env['status']['code'] = chain_env['status']['code'] or 0
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_last_three_days(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {"count": 0, "date": None}
		status = {"code": None, "description": None}
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			try:
				dbcur.execute(Model.sql("count_last_three_days"))
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
				return status, result
			else:
				chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
				result = Model.convert("count_last_three_days", dbcur)
				status['code'] = 0
				dbcur.close()
				dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_update_matching_project(self, chain_env):
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
			flg_ok = True
			try:
				dbcur.execute(Model.sql("update_matching_project") % args['id'])
			except:
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
