#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	[DEPLICATED]
	This module provides skills logics.
"""

import time
import hashlib

import flask

from validators.base import ValidatorBase as Validator
from models.skill import Skill as Model
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
		"enumSkills": {\
			"logic": "enum_skills",\
		},\
		"searchSkill": {\
			"logic": "search_skill",\
		},\
		"createSkill": {\
			"logic": "create_skill",\
		}, \
		"enumSkillCategories": { \
			"logic": "enum_skill_categories", \
			}, \
		}
	
	def _fn_enum_skills(self, chain_env):
		time_bg = time.time()
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
			param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
			args = chain_env['argument'].data
			#[begin] Build order by clause.
			ORDER_KEYS = {\
				"id": "`MTC`.`id`",\
				"sort_number": "`MT`.`sort_number`",\
			}
			orderClause = []
			if "is_sort" in args and args['is_sort'] == 1:
				orderClause.append(u"CASE WHEN `MTC`.`name`='工程' THEN `MT`.`id` end ASC, CASE WHEN `MTC`.`name`!='工程' THEN `MT`.`name` end ASC")
			else:
				orderClause.append("`MTC`.`id`, `MT`.`sort_number`")

			dbcur.execute(Model.sql("enum_skills") % (", ".join(orderClause)))
			result = Model.convert("enum_skills", dbcur)
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_search_skill(self, chain_env):
		time_bg = time.time()
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'], chain_env['argument'].data['partial'] + "%")
			dbcur.execute(Model.sql("search_skill"), params=param)
			chain_env['results'] = Model.convert("search_skill", dbcur)
			chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", chain_env['argument'].data)
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_create_skill(self, chain_env):
		time_bg = time.time()
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur:
			conflicts = set()
			inserted = set()
			for nm in set(chain_env['argument'].data['names']):
				param = (nm, chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
				try:
					dbcur.execute(Model.sql("create_skill"), params=param)
				except Exception, err:
					if err.errno == 1022 and err.sqlstate == "23000":
						conflicts.add(param[0])
					else:
						chain_env['trace'].append(err)
				else:
					inserted.add(param[0])
			dbcon.commit() if inserted else None
			chain_env['results'] = {"conflicts": tuple(conflicts), "inserted": tuple(inserted)}
			chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", chain_env['argument'].data)
		self.perf_time(chain_env, time.time() - time_bg)

	def _fn_enum_skill_categories(self, chain_env):
		time_bg = time.time()
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
			param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
			dbcur.execute(Model.sql("enum_skills") % ("`MTC`.`id`, `MT`.`sort_number`"))
	
			result = Model.convert("enum_skills", dbcur)
			status['code'] = 0
			dbcur.close()
			dbcon.close()

		categories = []
		for skill in result:
			if skill['category_name'] not in categories:
				categories.append(skill['category_name'])

		result = categories
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

	def _fn_enum_skill_levels(self, chain_env):
		time_bg = time.time()
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
			param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
			dbcur.execute(Model.sql("enum_skill_levels"))
			result = Model.convert("enum_skill_levels", dbcur)
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result

