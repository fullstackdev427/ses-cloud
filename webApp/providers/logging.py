#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import inspect
import pprint
import traceback
import flask
from datetime import datetime

try:
	import ujson as JSON
except ImportError:
	try:
		import czjson as JSON
	except ImportError:
		try:
			import json as JSON
		except ImportError:
			try:
				import simplejson as JSON
			except ImportError:
				raise EXC.DeployError("No JSON module has been found.", 1001)

import MySQLdb as DBS

class Logger(object):
	__pref__ = None
	__application_hash__ = None
	__seq_no__ = None
	def __init__(self, pref={}, ref_application=None):
		self.__con__ = None
		self.__pref__ = None
		self.__application_hash__ = None
		self.__seq_no__ = 0
		if pref and isinstance(pref, dict):
			self.__pref__ = pref
			self.__connect__()
		if ref_application:
			self.__application_hash__ = ref_application
	
	def __connect__(self):
		if self.__pref__:
			try:
				self.__con__ = DBS.connect(**self.__pref__)
			except:
				print traceback.format_exc()
	
	def __delete__(self):
		if self.__con__:
			self.__con__.close()
			self.__con__ = None
	
	@property
	def instance_id(self):
		return self.__application_hash__

	def __call__(self, type_record="appglobal", content=None):
		cur = self.__con__.cursor() if self.__con__ else (self.__connect__() or self.__con__.cursor())
		frame = inspect.currentframe()
		self.__seq_no__ += 1
		log_record = {\
			"instance_id": self.__application_hash__,\
			"seq_no": self.__seq_no__,\
			"type_record": type_record,\
			"prod_level": None,\
			"prefix": None,\
			"app_switch": None,
			"login_id": None,\
			"credential": None,\
			"module": None,\
			"function": None,\
			"lineno": None,\
			"content": None,\
		}
		if frame:
			target_frame = frame.f_back# target frame must be running frame of caller.
			if target_frame:
				log_record['module'], log_record['lineno'], log_record['function'], target_code, target_index = inspect.getframeinfo(target_frame)
				#log_record['module'] = target_code.co_filename
				del target_code
				del target_index
				if "chain_env" in target_frame.f_locals:
					chain_env = target_frame.f_locals['chain_env']
				else:
					chain_env = {}
				if chain_env:
					log_record['prod_level'] = chain_env['prod_level']
					log_record['prefix'] = chain_env['prefix']
					log_record['login_id'] = chain_env['login_id']
					log_record['app_switch'] = "%s.%s" % (chain_env['logic'], chain_env['realm'])
					log_record['credential'] = chain_env['credential']
				if content:
					try:
						log_record['content'] = JSON.dumps(content)
					except:
						log_record['content'] = JSON.dumps(repr(content))
				elif target_frame.f_trace:
					log_record['type_record'] = "traceback"
					log_record['content'] = JSON.dumps(traceback.format_tb(target_frame.f_trace))
			del target_frame
		else:
			pass
		del frame
		try:
			self.print_log_file(log_record)
		except:
			pass
		else:
			pass
		finally:
			return

		log_record['content'] = log_record['content'] or JSON.dumps(None)
		INSERT_KEYS = ("instance_id", "seq_no", "type_record", "prod_level", "prefix", "app_switch", "login_id", "credential", "module", "function", "lineno", "content",)
		try:
			cur.execute("""\
INSERT INTO `ft_logs` (
  `instance_id`,
  `seq_no`,
  `type_record`,
  `prod_level`,
  `prefix`,
  `app_switch`,
  `login_id`,
  `credential`,
  `module`,
  `function`,
  `lineno`,
  `content`) VALUES (
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s
  );""", tuple([log_record[k] for k in INSERT_KEYS]))
		except DBS.ProgrammingError, err:
			print traceback.format_exc()
			print cur._executed
		except DBS.OperationalError, err:
			tmp = inspect.getframeinfo(inspect.currentframe().f_back)
			print "-----<inspect>-----\n  module: %s\n  lineno: %d\n  function: %s" % (tmp[0], tmp[1], tmp[2])
			print traceback.format_exc()
		except DBS.DataError, err:
			tmp = inspect.getframeinfo(inspect.currentframe().f_back)
			print "-----<inspect>-----\n  module: %s\n  lineno: %d\n  function: %s" % (tmp[0], tmp[1], tmp[2])
			pprint.pprint(log_record)
			print traceback.format_exc()
		except:
			tmp = inspect.getframeinfo(inspect.currentframe().f_back)
			print "-----<inspect>-----\n  module: %s\n  lineno: %d\n  function: %s" % (tmp[0], tmp[1], tmp[2])
			print traceback.format_exc()
		else:
			self.__con__.commit()
		finally:
			cur.close()

	def map_called(self, chain_env, type_record="appglobal"):
		cur = self.__con__.cursor() if self.__con__ else (self.__connect__() or self.__con__.cursor())
		args = chain_env['argument'].data
		request_body = JSON.loads(args['request_body'])
		response_body = JSON.loads(args['response_body']) if args['response_body'] else None
		log_record = {
			"instance_id": self.__application_hash__,\
			"login_id": chain_env['login_id'] or None,\
			"request_IPv4": flask.request.environ['REMOTE_ADDR'] or None,\
			"prefix": chain_env['prefix'],\
			"app_switch": args['current'] + '#'+ (args['modalId'] or ""),\
			"target_id": args['target_id'] or None,\
			"target_type": args['target_type'] or None,\
			"called_api": args['called_api'],\
			"UA": flask.request.environ['HTTP_USER_AGENT'] or None,\
			"request_body": JSON.dumps(request_body),\
			"response_body": JSON.dumps(response_body) if response_body else None,\
			"api_status": args['api_status'] or None,\
			"prod_level": chain_env['prod_level'],\
			"type_record": type_record,\
		}
		INSERT_KEYS = ("instance_id", "login_id", "request_IPv4", "prefix", "app_switch", "target_id", "target_type", "called_api", "UA", "request_body", "response_body", "api_status", "prod_level", "type_record",)
		try:
			cur.execute("""\
INSERT INTO `ft_map_api_called` (
  `instance_id`,
  `login_id`,
  `request_IPv4`,
  `prefix`,
  `app_switch`,
  `target_id`,
  `target_type`,
  `called_api`,
  `UA`,
  `request_body`,
  `response_body`,
  `api_status`,
  `prod_level`,
  `type_record`) VALUES (
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s,
    %s
  );""", tuple([log_record[k] for k in INSERT_KEYS]))
		except DBS.ProgrammingError, err:
			print traceback.format_exc()
			print cur._executed
			self.__con__.rollback()
		except DBS.OperationalError, err:
			tmp = inspect.getframeinfo(inspect.currentframe().f_back)
			print "-----<inspect>-----\n  module: %s\n  lineno: %d\n  function: %s" % (tmp[0], tmp[1], tmp[2])
			print traceback.format_exc()
			self.__con__.rollback()
		except DBS.DataError, err:
			tmp = inspect.getframeinfo(inspect.currentframe().f_back)
			pprint.pprint(log_record)
			print "-----<inspect>-----\n  module: %s\n  lineno: %d\n  function: %s" % (tmp[0], tmp[1], tmp[2])
			print traceback.format_exc()
			self.__con__.rollback()
		except:
			print traceback.format_exc()
			self.__con__.rollback()
		else:
			self.__con__.commit()
		finally:
			cur.close()

	def print_log_file(self, log_record):
		info_str = "prod_level:" + (log_record['prod_level'] if log_record['prod_level'] else "None")
		info_str += " // prefix:" + (log_record['prefix'] if log_record['prefix'] else "None")
		info_str += " // login_id:" + (log_record['login_id'] if log_record['login_id'] else "None")
		info_str += " // credential:" + (log_record['credential'] if log_record['credential'] else "None")
		info_str += " // app_switch:" + (log_record['app_switch'] if log_record['app_switch'] else "None")
		info_str += " // content:" + (log_record['content'] if log_record['content'] else "None")
		print str(datetime.now()) + " ::" + info_str

