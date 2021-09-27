#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import sys
import time
import datetime
import re
import traceback
import pprint

import flask
import MySQLdb as DBS

from validators.base import ValidatorBase as Validator
from providers.limitter import Limitter

class ProcessorBase(object):
	
	"""
	This class is base class of realm Processors.
	"""
	
	__pref__ = None
	__realms__ = None
	
	def __init__(self, pref):
		self.__pref__ = pref if isinstance(pref, dict) and pref else None
		self.write_log("[logger initialized]")
	
	def __call__(self, realm_name):
		
		"""
			This method must not be overridden.
			It provides tuple formatted lambda function wrapping internal method chain per realm.
		"""
		methods = []
		if isinstance(realm_name, basestring) and realm_name in self.__realms__ and isinstance(self.__realms__[realm_name], dict):
			if "valid_in" in self.__realms__[realm_name]:
				if callable(self.__realms__[realm_name]['valid_in']):
					methods.append(self.__realms__[realm_name]['valid_in'])
				else:
					lambda x: self.valid_cmn(x, Model, self.__realms__[realm_name]['valid_in'])
			if "logic" in self.__realms__[realm_name]:
				if callable(self.__realms__[realm_name]['logic']):# To fit to irregular lambda function.
					methods.append(self.__realms__[realm_name]['logic'])
				else:# Regular condition.
					try:
						tmp = getattr(self, "_fn_%s" % self.__realms__[realm_name]['logic'])
					except AttributeError, err:
						self.write_err(traceback.format_exc())
					else:
						methods.append(tmp) 
			if "logics" in self.__realms__[realm_name]:
				for logic_name in self.__realms__[realm_name]['logics']:
					if callable(logic_name):# To fit to irregular lambda function.
						methods.append(logic_name)
					else:# Regular condition.
						try:
							tmp = getattr(self, "_fn_%s" % logic_name)
						except AttributeError, err:
							self.write_err(traceback.format_exc())
						else:
							methods.append(tmp)
			if "valid_out" in self.__realms__[realm_name]:
				if callable(self.__realms__[realm_name]['valid_out']):
					methods.append(self.__realms__[realm_name]['valid_out'])
				else:
					lambda x: self.valid_cmn(x, Model, self.__realms__[realm_name]['valid_out'])
		else:
			methods.append(self.__not_supported__)
		return methods
	
	def __not_supported__(self, chain_env):
		if not chain_env['propagate']:
			return
		chain_env['status']['code'] = 10
		chain_env['response'] = "<realm>'%s' is not supported." % str(chain_env['realm'])
	
	def connect_db(self):
		MYSQL_PREF = self.__pref__['MYSQL_HOSTS'][len(self.__pref__['MYSQL_HOSTS']) % self.__pref__['MYSQL_MODULO']]
		dbcon = None
		error = None
		try:
			dbcon = DBS.connect(**MYSQL_PREF)
		except Exception, err:
			error = traceback.format_exc()
		else:
			pass
		return dbcon, error
	
	def valid_cmn(self, chain_env, model_cls, rule_name):
		time_bg = time.time()
		if not chain_env['propagate']:
			return
		target = chain_env['argument'].data
		v = Validator()
		rules = model_cls.rule(rule_name)
		try:
			chain_env['validate']['input']['result'], chain_env['validate']['input']['log'] = v.test(rules, target)
		except Exception, err:
			chain_env['trace'].append(traceback.format_exc(err))
			chain_env['propagate'] = False
		else:
			chain_env['validate']['input']['log'] = v.logTrim(chain_env['validate']['input']['log'])
			chain_env['propagate'] = chain_env['validate']['input']['result']
		self.perf_time(chain_env, time.time() - time_bg)
	
	def my_log(self, msg):
		enableLog = True
		if enableLog:
			now = datetime.datetime.now()
			current_time = now.strftime("%H:%M:%S")
				
			myFile = open('call.txt', 'a')
			myFile.write('\n' + current_time + ' ' + msg)
			myFile.close()

	def write_log(self, obj):
		tm_float = time.time()
		tm_str = time.strftime("[%Y/%m/%d %H:%M:%S]")
		msg_obj = obj if isinstance(obj, dict) else {"data": obj}
		msg_obj['amqp_time_in'] = {"float": tm_float, "string": tm_str}
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
	
	def write_err(self, obj):
		stream = flask.request.environ['wsgi.errors']
		stream.write("\n")
		stream.write(obj) if isinstance(obj, basestring) else pprint.pprint(obj, stream)
		stream.write("\n")
	
	def str2datetime(self, text):
		matched = re.compile("^(([0-9]{4})([0-9]{2})([0-9]{2}))|(([0-9]{4})[\-/]([0-9]{2})[\-/]([0-9]{2}))$").findall(text)
		return datetime.datetime(*(map(int, (matched[0][1:4] if matched[0][1] else matched[0][5:8]))))
	
	def str2datetime_ex(self, text):
		matched = re.compile("^(([0-9]{4})([0-9]{2})([0-9]{2}))|(([0-9]{4})[\-/]([0-9]{2})[\-/]([0-9]{2}) ([0-9]{2}):([0-9]{2}):([0-9]{2}))$").findall(text)
		return datetime.datetime(*(map(int, (matched[0][1:4] if matched[0][1] else matched[0][5:10]))))
	
	def method_chain_wrapper(self, method_names, chain_env):
		if isinstance(method_names, basestring):
			method_names = (method_names,)
		result_dict = {}
		trace_dict = {}
		entity_list = []
		for method_name in method_names:
			try:
				method_obj = self.getattr(method_name)
			except AttributeError:
				entity_list.append((method_name, "METHOD_NOT_FOUND"))
				trace_dict.update({\
					"method_name": method_name,
					"values": (traceback.format_exc(),)
				})
			else:
				if callable(method_obj):
					try:
						tmp_entity, tmp_res, tmp_trace = method_obj(chain_env)
					except Exception:
						pass
					else:
						result_dict.update({tmp_entity: tmp_res})
						trace_dict.update({tmp_entity: tmp_trace})
	
	def perf_time(self, chain_env, elapsed):
		chain_env['performance']['logic_time'] = (chain_env['performance']['logic_time'] if chain_env['performance']['logic_time'] else 0.0) + elapsed
	
	def check_limit(self, chain_env, keys = []):
		chain_env['logger']("webapi", ("BEGIN", chain_env['limit']))
		if not chain_env['propagate']:
			chain_env['logger']("webapi", ("END", None))
			return
		limitation_dict = {}
		[limitation_dict.update({k: {"cap": chain_env['limit'][k]}}) for k in chain_env['limit'] if k in keys or not keys and k.startswith("LMT_")]
		[limitation_dict[k].update({"current": v}) for k, v in Limitter.count_records(self.__pref__, chain_env)[1].items() if k in limitation_dict]
		checked_list = filter(lambda x: limitation_dict[x]['current'] >= limitation_dict[x]['cap'] and limitation_dict[x]['cap'] != 0, limitation_dict)
		chain_env['propagate'] = not bool(checked_list)
		if not chain_env['propagate']:
			chain_env['status'] = chain_env['status'] or {"code": None}
			chain_env['status']['code'] = chain_env['status']['code'] or 15
			chain_env['status']['signature'] = keys
		chain_env['logger']("webapi", ("END", checked_list))