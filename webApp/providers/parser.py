#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

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
import flask

from models.argument import Argument
from errors import exceptions as EXC

class Parser(object):
	
	"""
		This class provides parsers of arguments.
	"""
	
	__parser__ = None
	
	def __init__(self):
		ipt = flask.request
		if ipt.content_type == "application/json":
			self.__parser__ = lambda x: self.__parse_json_input(ipt, x)
		elif ipt.content_type == "application/x-www-form-urlencoded":
			self.__parser__ = lambda x: self.__parse_html_form_json_input(ipt, x)
		elif ipt.content_type.startswith("multipart/form-data"):
			self.__parser__ = lambda x: self.__parse_multipart_json_input(ipt, x)
		else:
			self.__parser__ = lambda x: self.__skip_parse(ipt, x)
	
	def __call__(self):
		return [self.__parser__]
	
	def __parse_html_form_json_input(self, ipt, chain_env):
		chain_env['argument'] = Argument()
		try:
			if "json" in ipt.form:
				chain_env['argument'].setData(JSON.loads(ipt.form['json']))
				if "credential" in chain_env['argument'].data:
					chain_env['credential'] = chain_env['argument'].data['credential']
				if "login_id" in chain_env['argument'].data:
					chain_env['login_id'] = chain_env['argument'].data['login_id']
		except:
			pass
	
	def __parse_multipart_json_input(self, ipt, chain_env):
		chain_env['argument'] = Argument()
		try:
			if "json" in ipt.form:
				chain_env['argument'].setData(JSON.loads(ipt.form['json']))
				if "credential" in chain_env['argument'].data:
					chain_env['credential'] = chain_env['argument'].data['credential']
				if "login_id" in chain_env['argument'].data:
					chain_env['login_id'] = chain_env['argument'].data['login_id']
		except:
			pass
		if ipt.files:
			for f in ipt.files:
				chain_env['argument'].setFile(f, ipt.files[f])
	
	def __parse_json_input(self, ipt, chain_env):
		chain_env['argument'] = Argument()
		try:
			chain_env['argument'].setData(JSON.loads(ipt.data))
			if "credential" in chain_env['argument'].data:
				chain_env['credential'] = chain_env['argument'].data['credential']
			if "login_id" in chain_env['argument'].data:
				chain_env['login_id'] = chain_env['argument'].data['login_id']
		except:
			pass
	
	def __skip_parse(self, ipt=None, chain_env=None):
		chain_env['argument'] = Argument()
	

