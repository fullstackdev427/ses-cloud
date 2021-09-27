#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides client logics.
"""

import time
import hashlib
import traceback

import flask
import mysql.connector.errors as DBERR

from validators.base import ValidatorBase as Validator
from models.file import File as Model
from base import ProcessorBase
from errors import exceptions as EXC

class Processor(ProcessorBase):
	
	"""
		This class provides file object manipulation functionalities.
	"""
	
	__realms__ = {\
		"enum": {\
			"logic": "enum",\
		},\
		"upload": {\
			"logic": "upload",\
		},\
		"rename": {\
			"logic": "rename",\
		},\
		"download": {\
			"logic": "download",\
		}, \
		"downloadAll": { \
			"logic": "download_all", \
			}, \
		"delete": {\
			"logic": "delete",\
		}\
	}
	
	def _fn_enum(self, chain_env):
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
				dbcur.execute(Model.sql("enum"), param)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc(err))
				chain_env['trace'].append(dbcur._executed if dbcur else None)
				chain_env['status']['code'] = 2
			else:
				res1 = Model.convert("enum", dbcur)
				user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'],) for entity in res1] for e in p]))
				if user_list:
					dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
					res2 = Model.convert("enum_users", dbcur)
				else:
					res2 = []
				for tmp_obj in res2:
					[entity['creator'].update(tmp_obj) for entity in res1 if entity['creator']['id'] == tmp_obj['id']]
				chain_env['results'] = res1
				chain_env['status']['code'] = 0
			dbcur.close()
			dbcon.close()
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
	
	def _fn_upload(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		args = chain_env['argument'].data
		file_obj = chain_env['argument'].files['attachement'] if "attachement" in chain_env['argument'].files else None
		if not chain_env['propagate']:
			return
		dbcur = None
		dbcon, db_err_list = self.connect_db()
		if dbcon and not db_err_list:
			dbcur = dbcon.cursor()
		else:
			chain_env['trace'] += db_err_list
		if dbcur and file_obj:
			#[begin] Prepare file attributes.
			f_mime = file_obj.content_type
			f_name = file_obj.filename
			f_buf = file_obj.stream.read()
			f_size = len(f_buf)
			f_digest = hashlib.md5(f_buf).hexdigest()
			#[end] Prepare file attributes.
			if f_size <= chain_env['limit']['LMT_SIZE_BIN']:
				param = (\
					f_mime, f_name,\
					f_buf,\
					f_size, f_digest,\
					chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
				)
				try:
					dbcur.execute(Model.sql("upload"), param)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc())
					self.write_err(dbcur._executed)
				else:
					dbcon.commit()
					dbcur.execute(Model.sql("last_insert_id"))
					result = Model.convert("last_insert_id", dbcur)
					status['code'] = 0
				finally:
					result['filename'] = f_name
					result['size'] = f_size
					status['code'] = status['code'] if status['code'] is not None else 14
			else:
				result = {}
				result['size'] = f_size
				result['limit'] = chain_env['limit']['LMT_SIZE_BIN']
				status['code'] = 13
			dbcur.close()
			dbcon.close()
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
		self.perf_time(chain_env, time.time() - time_bg)
		return status, result
	
	def _fn_rename(self, chain_env):
		pass
	
	def _fn_download(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		tmp_res = None
		if not chain_env['propagate']:
			code = 0 if chain_env['status']['code'] is None else chain_env['status']['code']
			chain_env['status']['code'] = 12
			chain_env['status']['description'] = str(code)
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
				chain_env['prefix'], chain_env['login_id'],\
				chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			)
			try:
				dbcur.execute(Model.sql("download"), param)
			except Exception:
				chain_env['trace'].append(traceback.format_exc())
				chain_env['trace'].append(dbcur._executed)
			else:
				tmp_res = Model.convert("download", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
			if tmp_res:
				chain_env['sendfile_content'] = tmp_res['value']
				chain_env['sendfile_params'] = {\
					"mimetype": tmp_res['type_mime'],\
					"as_attachment": True,\
					"attachment_filename": tmp_res['name'].encode("utf8"),\
				}
		self.perf_time(chain_env, time.time() - time_bg)
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
		return status, result

	def _fn_download_all(self, chain_env):
		time_bg = time.time()
		chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
		result = {}
		status = {"code": None, "description": None}
		tmp_res = None
		if not chain_env['propagate']:
			code = 0 if chain_env['status']['code'] is None else chain_env['status']['code']
			chain_env['status']['code'] = 12
			chain_env['status']['description'] = str(code)
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
				# chain_env['prefix'], chain_env['login_id'],\
				# chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
			)
			try:
				dbcur.execute(Model.sql("download_all"), param)
			except Exception:
				chain_env['trace'].append(traceback.format_exc())
				chain_env['trace'].append(dbcur._executed)
			else:
				tmp_res = Model.convert("download", dbcur)
				status['code'] = 0
			dbcur.close()
			dbcon.close()
			if tmp_res:
				chain_env['sendfile_content'] = tmp_res['value']
				chain_env['sendfile_params'] = {\
					"mimetype": tmp_res['type_mime'],\
					"as_attachment": True,\
					"attachment_filename": tmp_res['name'].encode("utf8"),\
				}
		self.perf_time(chain_env, time.time() - time_bg)
		chain_env['results'] = result
		chain_env['status'] = status
		chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
		return status, result
	
	def _fn_delete(self, chain_env):
		pass