#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import copy

try:
	import pika
except ImportError:
	raise EXC.DeployError("pika module must be installed.", 1001)

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

# from ..errors import exceptions AS EXC

class LoggerBase(object):
	"""
	This class is *NOT* compatible with Python built-in logging module.
	This module is experimental Singleton base class for logging.
	"""
	__instances__ = None# For Singleton.
	__broker__ = None#Connection instance.
	__dsn__ = None#ConnectionParameters instance.
	__params__ = None#list of DSN.
	__channel__ = None
	__queue__ = None
	EXCHANGE_NAME = None
	QUEUE_NAME = None
	
	def __new__(cls, preferences):
		
		key = "%s.%s" % (cls.__module__, cls.__name__)
		cls.__instance__ = cls.__instance__ or {}
		instance = None
		if key in cls.__instance__:
			instance = cls.__instance__[key]
		else:
			instance = super(cls, cls).__new__(cls, preferences)
			cls.__isntances__[key] = instance
		return instance
	
	def __init__(self, preferences):
		"""
			:Parameters:
				preferences : list or tuple of rabbitMQ connection setting dictionary.
		"""
		
		param_fields = (\
			("host", str), ("port", int), ("virtual_host", str),\
			("channel_max", int), ("frame_max", int),\
			("heartbeat_interval", int), ("ssl", bool),\
			("ssl_options", dict), ("connection_attempts", (int, long)),\
			("retry_delay", (int, float)), ("socket_timeout", (int, float)),\
			("locale", str), ("backpressure_detection", bool)
		)
		if not self.__broker__ or self.__broker__.is_closed:
			try:
				self.__broker__.connect()
			except pika.exceptions.AuthenticationError, err:
				self.__broker__ = None
				self.__dsn__ = None
				self.__params__ = None
				self.__channel__ = None
				self.__queue__ = None
			except pika.AMQPConnectionError, err:
				self.__broker__ = None
				self.__dsn__ = None
				self.__params__ = None
				self.__channel__ = None
				self.__queue__ = None
			else:
				pass
		if not self.__broker__ and preferences and isinstance(preferences, (list, tuple)):
			for pref in preferences:
				#[begin] Validate element of preferences.
				if "exchange_name" not in pref or "queue_name" not in pref:
					continue
				dsn = {}
				if isinstance(pref, dict) and\
					"user" in pref and "passwd" in pref:
					dsn['credentials'] = pika.credentials.PlainCredentials(pref['user'], pref['passwd'])
				else:
					continue
				#[end] Validate element of preferences.
				for param_name, param_type in param_fields:
					dsn[param_name] = pref[param_name] if (param_name in pref and isinstance(pref[param_name], param_type) else None
				param = pika.connection.ConnectionParameters(**dsn)
				try:
					con = pika.connection.AsyncoreConnection(\
						parameters = param,\
						on_open_callback = self.__hdl_open_broker,\
						on_open_error_callback = self.__hdl_open_broker_error,\
						on_close_callback = self.__hdl_close_broker,\
						on_stop_ioloop_on_close = self.__hdl_stop_ioloop
					)
				except pika.exceptions.AuthenticationError, err:
					raise err
				except pika.exceptions.AMQPConnectionError, err:
					raise err
				else:
					con.add_backpressure_callback(self.__hdl_backpressure)
					try:
						exchange_declare(exchange=pref['exchange_name'])
					else:
						con.close()
						continue
					self.__dsn__ = param
					self.__broker__ = con
					self.__channel__ = con.channel(on_open_callback = self.__hdl_open_channel)
					self.__channel__.add_on_close_callback(self.__hdl_close_channel)
					
	
	#[begin] AMQP callback handlers.
	def __hdl_open_broker(self):
		pass
	
	def __hdl_open_broker_error(self):
		pass
	
	def __hdl_close_broker(self):
		pass
	
	def __hdl_stop_ioloop(self):
		pass
	
	def __hdl_backpressure(self):
		pass
	
	def __hdl_open_channel(self):
		pass
	
	def __hdl_close_channel(self):
		pass
	#[end] AMQP callback handlers.

class LogRecord(object):
	pass