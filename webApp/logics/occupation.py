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
from models.occupation import Occupation as Model
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
		"enumOccupations": {\
			"logic": "enum_occupations",\
		},\

		"createOccupation": {\
			"logic": "create_occupation",\
		},\
	}
	
	def _fn_enum_occupations(self, chain_env):
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
			dbcur.execute(Model.sql("enum_occupations"))
			#self.my_log("__enum_occupations"+Model.sql("enum_occupations"))
			result = Model.convert("enum_occupations", dbcur)
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", chain_env['argument'].data)
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_create_occupation(self, chain_env):
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
					dbcur.execute(Model.sql("create_occupation"), params=param)
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

