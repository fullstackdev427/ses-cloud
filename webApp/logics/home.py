#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides home logics.
	Also this module contains functions HTML rendering.
"""


import copy
import time
import hashlib
import traceback
import pprint

import flask
import redis
import re
from providers.re import Re

from validators.base import ValidatorBase as Validator
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
		"enum": {\
			"logic": "html_home",\
		},\
		"search": {\
			"logic": "html_search",\
		},\
		"direction": {\
			"logic": "html_direction",\
		},\
		"video": {\
			"logic": "html_video",\
		},\
	}
	
	def _fn_html_home(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		render_param = {}
		from logics.auth import Processor as P_AUTH
		from logics.engineer import Processor as P_ENGINEER
		from logics.project import Processor as P_PROJECT
		from logics.manage import Processor as P_MANAGE
		from logics.misc import Processor as P_MISC
		from logics.client import Processor as P_CLIENT
		from logics.skill import Processor as P_SKILL
		from logics.occupation import Processor as P_OCCUPATION
		#Login.
		if "password" in chain_env['argument'].data:
			status_auth, render_param['auth.login'] = P_AUTH(self.__pref__)._fn_login(chain_env)
		else:
			status_auth, render_param['auth.login'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
			status_auth['code'] = 0
		if status_auth['code'] == 0:
			#Fetch user profile.
			status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
			#Fetch engineers.
			tmp = P_ENGINEER(self.__pref__)._fn_enum_engineers(chain_env)
			status_engineer, render_param['engineer.enumEngineers'] = tmp if tmp else (None, [])
			#Fetch projects.
			tmp = P_PROJECT(self.__pref__)._fn_enum_projects(chain_env)
			status_project, render_param['project.enumProjects'] = tmp or (None, [])
			#[begin] support objects.
			clean_env = copy.deepcopy(chain_env)
			#Fetch user accounts.
			status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
			render_param['enumAccounts'] = self.__gen_account_dict(render_param['manage.enumAccounts'])
			#Fetch Schedules.
			status_schedule, render_param['misc.enumSchedules'] = P_MISC(self.__pref__)._fn_enum_schedules(chain_env)
			today_str = time.strftime("%Y/%m/%d")
			now_str = time.strftime("%H:%M:%S")
			render_param['misc.enumSchedules'] = filter(lambda x: x['dt_scheduled'][:10] == today_str, render_param['misc.enumSchedules'])
			render_param['today_str'] = today_str
			render_param['now_str'] = now_str
			render_param['enumGroupSchedules'] = self.__gen_group_schedule(render_param['misc.enumSchedules'], render_param['manage.enumAccounts'])
			#Fetch Todos.
			status_todo, render_param['misc.enumTodos'] = P_MISC(self.__pref__)._fn_enum_todos(chain_env)
			#Fetch Clients(compact).
			status_client, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
			render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in render_param['client.enumClients']]
			del render_param['client.enumClients']
			status_client, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
			#Fetch current status for Limit.
			status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
			#[end] support objects.
			status_skills, render_param['skill.enumSkills'] = P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
			status_skills, render_param['skill.enumSkillCategories'] = P_SKILL(self.__pref__)._fn_enum_skill_categories(chain_env)
			status_skills, render_param['skill.enumSkillLevels'] = P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
			status_projects, render_param['occupation.enumOccupations'] = P_OCCUPATION(
				self.__pref__)._fn_enum_occupations(
				chain_env)

			#Bug fix for right after login.
			Limitter.load_settings(chain_env)
			chain_env['response_body'] = flask.render_template(\
				"home.tpl",\
				data=render_param,\
				env=chain_env,\
				query=chain_env['argument'].data,\
				trace=chain_env['trace'],\
				title=u"ホーム|SESクラウド",\
				current="home.enum")
		else:
			chain_env['status'] = status_auth
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def __gen_account_dict(self, accounts):
		result = {}
		[result.update({acc['id']: acc}) for acc in accounts if acc['is_enabled']]
		return result
	
	def __gen_group_schedule(self, schedules, accounts):
		result = {}
		TIME_TABLE = (\
			{"min": "00:00:00", "max": "09:00:00"},\
			{"min": "09:00:00", "max": "10:00:00"},\
			{"min": "10:00:00", "max": "11:00:00"},\
			{"min": "11:00:00", "max": "12:00:00"},\
			{"min": "12:00:00", "max": "13:00:00"},\
			{"min": "13:00:00", "max": "14:00:00"},\
			{"min": "14:00:00", "max": "15:00:00"},\
			{"min": "15:00:00", "max": "16:00:00"},\
			{"min": "16:00:00", "max": "17:00:00"},\
			{"min": "17:00:00", "max": "18:00:00"},\
			{"min": "18:00:00", "max": "19:00:00"},\
			{"min": "19:00:00", "max": "20:00:00"},\
			{"min": "20:00:00", "max": "21:00:00"},\
			{"min": "21:00:00", "max": "24:00:00"},\
		)
		for tt in TIME_TABLE:
			tmp = {}
			for acc in filter(lambda x: x['is_enabled'], accounts):
				tmp[acc['id']] = filter(lambda y: tt['min'] <= y['dt_scheduled'][11:] and y['dt_scheduled'][11:] < tt['max'] and y['creator']['id'] == acc['id'], schedules)
			result["%s - %s" % (tt['min'], tt['max'])] = tmp
		return result
	
	def _fn_html_search(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		render_param = {}
		from logics.auth import Processor as P_AUTH
		from logics.client import Processor as P_CLIENT
		from models.client import Client as M_CLIENT
		from models.project import Project as M_PROJECT
		from models.engineer import Engineer as M_ENGINEER
		from models.negotiation import Negotiation as M_NEGOTIATION
		from logics.manage import Processor as P_MANAGE
		from logics.skill import Processor as P_SKILL
		from logics.occupation import Processor as P_OCCUPATION
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			args = chain_env['argument'].data
		else:
			chain_env['trace'].append("Database is not connected.")
			args = None
		if args:
			regexp_word = re.escape(args['word']).replace('%', '%%')
			#Fetch clients.
			whereClause = map(lambda x: "%s REGEXP '^.*%s.*$'" % (x, dbcon.literal(regexp_word)[1:-1]), (\
				"`MCLI`.`name`", "`MCLI`.`kana`",\
				"`MCLI`.`addr1`", "`MCLI`.`addr2`",\
				"`MCW1`.`name`", "`MCW2`.`name`",\
				"`FCLN`.`note`",\
			))
			orderClause = (\
				"COALESCE(`MCLI`.`dt_modified`, `MCLI`.`dt_created`) DESC",\
			)
			param = [\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			]# + ["%%%s%%" % args['word']] * len(whereClause)
			try:
				dbcur.execute(M_CLIENT.sql("enum_clients") % ("AND (%s)" % " OR ".join(whereClause), ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				pprint.pprint(dbcur._last_executed)
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
			render_param['client.enumClients'] = M_CLIENT.convert("enum_clients", dbcur)
			status_client, render_param['client.enumClientEngineers'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
			#Fetch client workers.
			whereClause = map(lambda x: "%s REGEXP '^.*%s.*$'" % (x, dbcon.literal(regexp_word)[1:-1]), (\
				"`W`.`name`", "`W`.`kana`",\
				"`W`.`section`", "`W`.`title`",\
				"`C`.`name`", "`N`.`note`",\
			))
			orderClause = (\
				"COALESCE(`W`.`dt_modified`, `W`.`dt_created`) DESC",\
			)
			param = [\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			]
			try:
				dbcur.execute(M_CLIENT.sql("enum_workers") % ("AND (%s)" % " OR ".join(whereClause), ", ".join(orderClause)), param)
			except:
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
			render_param['client.enumWorkers'] = M_CLIENT.convert("enum_workers", dbcur)
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['charging_user']['id'], entity['creator']['id'], entity['modifier']['id']) for entity in render_param['client.enumWorkers']] for e in p]))
			if user_list:
				dbcur.execute(M_ENGINEER.sql("enum_users") % ", ".join(map(str, user_list)))
				tmp_res = M_ENGINEER.convert("enum_users", dbcur)
			else:
				tmp_res = []
			for tmp_obj in tmp_res:
				[entity['charging_user'].update(tmp_obj) for entity in render_param['client.enumWorkers'] if entity['charging_user']['id'] == tmp_obj['id']]
				[entity['creator'].update(tmp_obj) for entity in render_param['client.enumWorkers'] if entity['creator']['id'] == tmp_obj['id']]
				[entity['modifier'].update(tmp_obj) for entity in render_param['client.enumWorkers'] if entity['modifier']['id'] == tmp_obj['id']]
			#Fetch projects.
			whereClause = map(lambda x: "%s REGEXP '^.*%s.*$'" % (x, dbcon.literal(regexp_word)[1:-1]), (\
				"`MT`.`client_name`",\
				"`CL`.`name`",\
				"`MT`.`fee_inbound`", "`MT`.`fee_outbound`",\
				"`MT`.`title`", "`MT`.`station`",\
				"`MT`.`process`", "`MT`.`expense`",\
				"`NOTE`.`note`", "`MT`.`term`",\
				"`MT`.`skill_needs`", "`MT`.`skill_recommends`",\
			))
			whereClause.extend(map(lambda x: "%s REGEXP '^.*%s.*$')" % (x, dbcon.literal(regexp_word)[1:-1]), ( \
				"exists (select 1 from cr_prj_skill_needs es join mt_skills s on  s.id = es.skill_id where `MT`.id = es.project_id and s.name ", \
			)))

			orderClause = (\
				"COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC",\
			)
			param = [\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			]# + ["%%%s%%" % args['word']] * len(whereClause)
			try:
				dbcur.execute(M_PROJECT.sql("enum_projects") % ("AND (%s)" % " OR ".join(whereClause), ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
			render_param['project.enumProjects'] = M_PROJECT.convert("enum_projects", dbcur)
			#[begin] Joining client.
			client_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['client']['id'],) for entity in render_param['project.enumProjects']] for e in p]))
			if client_list:
				dbcur.execute(M_PROJECT.sql("enum_related_clients") % ", ".join(map(str, client_list)), (chain_env['prefix'], chain_env['login_id'], chain_env['credential']))
				tmp_res = M_PROJECT.convert("enum_clients", dbcur)
				for tmp_obj in tmp_res:
					[entity['client'].update(tmp_obj) for entity in render_param['project.enumProjects'] if entity['client']['id'] == tmp_obj['id']]
			#[end] Joining client.
			#[begin] Joining charging_user_id.
			user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['charging_user']['id'], entity['creator']['id'], entity['modifier']['id']) for entity in render_param['project.enumProjects']] for e in p]))
			if user_list:
				dbcur.execute(M_PROJECT.sql("enum_users") % ", ".join(map(str, user_list)))
				tmp_res = M_PROJECT.convert("enum_users", dbcur)
			else:
				tmp_res = []
			for tmp_obj in tmp_res:
				[entity['charging_user'].update(tmp_obj) for entity in render_param['project.enumProjects'] if entity['charging_user']['id'] == tmp_obj['id']]
				[entity['creator'].update(tmp_obj) for entity in render_param['project.enumProjects'] if entity['creator']['id'] == tmp_obj['id']]
				[entity['modifier'].update(tmp_obj) for entity in render_param['project.enumProjects'] if entity['modifier']['id'] == tmp_obj['id']]
			#[end] Joining charging_user_id.
			#Fetch engineers.
			whereClause = map(lambda x: "%s REGEXP '^.*%s.*$'" % (x, dbcon.literal(regexp_word)[1:-1]), (\
				"`MT`.`visible_name`", "`MT`.`name`", "`MT`.`kana`",\
				"`MT`.`fee`", "`FT`.`note`", "`MT`.`station`", "`MT`.`skill`", "`MT`.`employer`",\
			))
			whereClause.extend(map(lambda x: "%s REGEXP '^.*%s.*$')" % (x, dbcon.literal(regexp_word)[1:-1]), ( \
					"exists (select 1 from cr_engineer_skill es join mt_skills s on  s.id = es.skill_id where `MT`.id = es.engineer_id and s.name ", \
			)))

			orderClause = (\
				"COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC",\
			)
			param = [\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			]# + ["%%%s%%" % args['word']] * len(whereClause)
			try:
				dbcur.execute(M_ENGINEER.sql("enum_engineers") % ("AND (%s)" % " OR ".join(whereClause), ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
			render_param['engineer.enumEngineers'] = M_ENGINEER.convert("enum_engineers", dbcur)
			eid_list = set([e['id'] for e in render_param['engineer.enumEngineers']])
			uid_list = set([e['charging_user']['id'] for e in render_param['engineer.enumEngineers'] if e['charging_user'] and e['charging_user']['id']])
			try:
				dbcur.execute(M_ENGINEER.sql("enum_users") % ", ".join(map(str, uid_list)))
				tmp_res = M_ENGINEER.convert("enum_users", dbcur)
			except:
				tmp_res = []
			if uid_list:
				for tmp_obj in tmp_res:
					[entity['charging_user'].update(tmp_obj) for entity in render_param['engineer.enumEngineers'] if entity['charging_user']['id'] == tmp_obj['id']]
			if eid_list:
				param2 = (\
					chain_env['prefix'], chain_env['login_id'],\
					chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
				)
				dbcur.execute(M_ENGINEER.sql("enum_files") % ", ".join(map(str, eid_list)), param2)
				file_dict = M_ENGINEER.convert("enum_file_dict", dbcur)
				[e_obj.update({"attachement": file_dict[e_obj['id']] if e_obj['id'] in file_dict else None}) for e_obj in render_param['engineer.enumEngineers']]
			if eid_list:
				param3 = (\
					chain_env['prefix'], chain_env['login_id'],\
					chain_env['prefix'], chain_env['login_id'],\
					chain_env['prefix'], chain_env['login_id'],\
					chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
				)
				dbcur.execute(M_ENGINEER.sql("enum_preparations") % ("`P`.`engineer_id` IN (%s)" % ", ".join(map(str, eid_list))), param3)
				prep_list = M_ENGINEER.convert("enum_preparations", dbcur)
				for prep in prep_list:
					for res in render_param['engineer.enumEngineers']:
						if res['id'] == prep['engineer_id']:
							res['preparations'].append(prep)
			#Fetch negotiations.
			whereClause = map(lambda x: "%s REGEXP '^.*%s.*$'" % (x, dbcon.literal(regexp_word)[1:-1]), (\
				"`N`.`client_name`", "`N`.`name`",\
				"`N`.`note`", "`C`.`name`",\
			))
			orderClause = (\
				"COALESCE(`N`.`dt_modified`, `N`.`dt_created`) DESC",\
			)
			param = [\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			]# + ["%%%s%%" % args['word']] * len(whereClause)
			try:
				dbcur.execute(M_NEGOTIATION.sql("enum_negotiations") % ("AND (%s)" % " OR ".join(whereClause), ", ".join(orderClause)), param)
			except:
				pprint.pprint(traceback.format_exc())
				chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
			render_param['negotiation.enumNegotiations'] = M_NEGOTIATION.convert("enum_negotiations", dbcur)
			[negotiation['client'].update({"name": negotiation['client']['name'] or ""}) for negotiation in render_param['negotiation.enumNegotiations'] if ("client" in negotiation and "name" in negotiation['client'] and negotiation['client']['name'] is not None)]
			#[begin] support objects.
			clean_env = copy.deepcopy(chain_env)
			#Fetch user profile.
			status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
			#Fetch user accounts.
			status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
			render_param['enumAccounts'] = self.__gen_account_dict(render_param['manage.enumAccounts'])
			#Join negotiation and user accounts.
			for tmp_obj in render_param['manage.enumAccounts']:
				[entity['charging_user'].update(tmp_obj) for entity in render_param['negotiation.enumNegotiations'] if entity['charging_user']['id'] == tmp_obj['id']]
			#Fetch Clients(compact).
			status_client, render_param['client.enumAllClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
			render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in render_param['client.enumAllClients']]
			#Fetch current status for Limit.
			status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
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
				"search.tpl",\
				data=render_param,\
				env=chain_env,\
				query=chain_env['argument'].data,\
				trace=chain_env['trace'],\
				title=u"検索結果|SESクラウド",\
				current="home.search")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_html_direction(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		render_param = {}
		from logics.auth import Processor as P_AUTH
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)

		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"direction.tpl",\
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"検索結果|SESクラウド",\
			current="home.direction")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_html_video(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
		if not chain_env['propagate']:
			return
		LIST_VIDEO = {\
			"home": {
				"title": u"マッチング検索",\
				"url": "https://www.youtube.com/embed/qKNoDQZSUs8",\
			},\
			"matching_project": {
				"title": u"案件マッチング",\
				"url": "https://www.youtube.com/embed/v4O2sybuxuI",\
			},\
			"matching_engineer": {
				"title": u"要員マッチング",\
				"url": "https://www.youtube.com/embed/U9xR1rN3_pU",\
			},\
			"operaion_new": {
				"title": u"稼働新規登録",\
				"url": "https://www.youtube.com/embed/Pt3A-lmQsC0",\
			},\
			"operaion_quotation": {
				"title": u"稼働見積書作成",\
				"url": "https://www.youtube.com/embed/x70SPxrDQv4",\
			},\
			"estimate_new_1": {
				"title": u"請求書新規作成①",\
				"url": "https://www.youtube.com/embed/jKaJ7Uo0MU8",\
			},\
			"estimate_new_2": {
				"title": u"請求書新規作成②",\
				"url": "https://www.youtube.com/embed/hAPPeiPW9Bo",\
			},\
			"estimate_form": {
				"title": u"帳票設定",\
				"url": "https://www.youtube.com/embed/u5dYICRzUdk",\
			},\
		}
		args = chain_env['argument'].data
		render_param = {}
		from logics.auth import Processor as P_AUTH
		#Fetch user profile.
		status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
		status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
		render_param['video'] = LIST_VIDEO[args['video']]

		#[end] support objects.
		chain_env['response_body'] = flask.render_template(\
			"video.tpl",\
			data=render_param,\
			env=chain_env,\
			query=chain_env['argument'].data,\
			trace=chain_env['trace'],\
			title=u"検索結果|SESクラウド",\
			current="home.video")
		chain_env['logger']("webhtml", ("END", None))
		self.perf_time(chain_env, time.time() - time_bg)

def auth_cache_key(prefix, login_id):
	return "%s_%s" % (prefix, login_id)