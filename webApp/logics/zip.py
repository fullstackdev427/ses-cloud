#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides client logics.
"""

import time
import hashlib

import flask
import mysql.connector.errors as DBERR

from validators.base import ValidatorBase as Validator
from models.zip import Zip as Model
from base import ProcessorBase
from errors import exceptions as EXC

class Processor(ProcessorBase):
	
	"""
		This class provides address searching functionalities.
	"""
	
	__realms__ = {\
		"search": {\
			"logic": "search",\
		}
	}
	
	def _fn_search(self, chain_env):
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
			param1 = (\
				args['code'],\
			)
			dbcur.execute(Model.sql("search"), param1)
			result = Model.convert("search", dbcur)
			result['zip_code'] = result['zip_code'] or args['code']
			status['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['status'] = status
		chain_env['results'] = result
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
