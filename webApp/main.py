#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module is uWSGI entry point.
	
	uwsgi --socket /tmp/c4s_devel.sock --wsgi-file /var/httpdStore/c4s_devel/webApp/main.py --callable application --manage-script-name --uid nginx --gid root --stats :10081 --chdir /var/httpdStore/c4s_devel/webApp --pidfile /tmp/c4s_devel.pid --enable-threads --thunder-lock --workers 4 --env PYTHONPASS=/var/httpdStore/c4s_devel/webApp
"""

import os
import time
import datetime
import traceback
import pprint
import urllib
import uuid

try:
	import psutil
except ImportError:
	raise EXC.DeployError("psutil module must be installed via pip.", 1001, traceback.format_exc(err))
import flask

import providers as PROV
from providers.logging import Logger
import interfaces as IF
from errors import exceptions as EXC
from errors.status import Status

import preference
import time
from threading import Event, Thread
from logics.mail import Processor as Mail
import email.utils

def check_reserved_mail():
	#make this value from preference
	PREF_LOGIN = {\
		'logging': {'host': '192.168.1.2', 'user': 'ses_log', 'use_unicode': True, 'passwd': 'N6bydA8k', 'compress': True, 'charset': 'utf8', 'db': 'ses_log', 'port': 3306L},\
		'MYSQL_MODULO': 1,\
		'MYSQL_HOSTS': (\
			{\
				"host": "192.168.1.2",\
				"port": 3306L,\
				"user": "ses_prod",\
				"passwd": "N6bydA8k",\
				"db": "ses_prod",\
				"charset": "utf8",\
				"use_unicode": True,\
				"compress": True\
			},\
		),\
		'MAIL_CHARSET': "utf-8",\
		'MAIL_SENDER_ADDR': "noreply@ses-cloud-stg.jp",\

	}
	mail = Mail(PREF_LOGIN)
	status, res = mail.send_current_mails()
	#my_log(str(res))

def my_log(msg):
	now = datetime.datetime.now()
	current_time = now.strftime("%H:%M:%S")
				
	myFile = open('call.txt', 'a')
	myFile.write('\n' + current_time + ' ' + msg)
	myFile.close()
	return

import threading
class ThreadingMail(object):
	""" Threading example class
	The run() method will be started and it will run in the background
	until the application exits.
	"""

	def __init__(self, interval=1):
		""" Constructor
		:type interval: int
		:param interval: Check interval, in seconds
		"""
		self.interval = interval

		thread = threading.Thread(target=self.run, args=())
		thread.daemon = True							# Daemonize thread
		thread.start()								  # Start the execution

	def run(self):
		""" Method that runs forever """
		while True:
			# Do something
			print('Doing something imporant in the background')
			check_reserved_mail()
			time.sleep(self.interval)

mailThread = ThreadingMail(30)

from flask_compress import Compress

application = flask.Flask(__name__)
application.debug = True
application.template_folder = os.path.join(os.getcwd(), "templates")
application.use_x_sendfile = True
application.jinja_env.cache = {}

#application.config["COMPRESS_REGISTER"] = False
compress = Compress()
compress.init_app(application)

#Entry point for HTML rendering.
@application.route("/<prefix>/html/<field>/", methods=("GET", "POST"))
@compress.compressed()
def respond_html(prefix, field):
	_load_config()
	pre_process = PROV.Parser()() + [PROV.Limitter.load_settings, PROV.Authenticate.valid_credential_dbonly]
	post_process = [getattr(IF, "HTML")(PREF).marshall]
	return _chain(prefix, field, pre_process, post_process)

@application.route("/<prefix>/html/<field>/<query>/", methods=("GET", "POST"))
@compress.compressed()
def respond_html_query(prefix, field,query):
	_load_config()
	pre_process = PROV.Parser()() + [PROV.Limitter.load_settings, PROV.Authenticate.valid_credential_dbonly]
	post_process = [getattr(IF, "HTML")(PREF).marshall]
	return _chain(prefix, field, pre_process, post_process, query)

#Entry point for API call.
@application.route("/<prefix>/api/<field>/<fmt>", methods=("GET", "POST",))
@compress.compressed()
def respond_api(prefix, field, fmt):
	_load_config()
	pre_process = PROV.Parser()() + [PROV.Limitter.load_settings, PROV.Authenticate.valid_credential_dbonly]
	post_process = [IF.cleanup] + (getattr(IF, fmt.upper())(PREF).process_list if fmt in ("json", "dump") else [])
	return _chain(prefix, field, pre_process, post_process)

def _load_config(p_lvl=None):
	p_lvl = p_lvl or flask.request.environ['PROD_LEVEL']
	global PREF
	PREF = preference.ENV[p_lvl] if p_lvl in preference.ENV else {}
	#myFile = open('append.txt', 'w')
	#myFile.write(str(PREF))
	#myFile.close()
	return PREF

def _import_logic(field):
	
	"""
	This method supports importing logic class.
	:Parameters:
		field : [module_name].[realm_name] formatted string from URL segment.
	:return:
		cls : Processor class object on module.
		realm_name : logic name string identigfied by Processor class.
	"""
	mod_name, realm_name = "", ""
	mod, cls = None, None
	try:
		mod_name, realm_name = field.split(".")
	except ValueError:
		mod = None
	else:
		try:
			mod = __import__("logics.%s" % mod_name, globals(), locals(), [mod_name])
		except ImportError, err:
			mod = None
			print traceback.format_exc()
			#raise EXC.MappingError("<module>'%s' doesn't exists." % mod_name, 1000, traceback.format_exc())
		else:
			pass
	if mod:
		try:
			cls = getattr(mod, "Processor")
		except AttributeError, err:
			cls = None
			#raise EXC.MappingError("<logics.%s> module has no Processor class. Module has attibutes below:\n  %s" % (mod_name, repr(dir(mod))), 1001, traceback.format_exc(err))
		else:
			pass
		#if not cls or not callable(cls):
		#	raise EXC.MappingError("<logic.%s.Processor> is not callable." % mod_name, 1001)
	return cls, mod_name, realm_name

def _chain(prefix, field, preprocess_list=None, postprocess_list=None, query=None):
	
	"""
	This method is central method of responding.
		:Parameters:
			prefix		   : first segment of URL which indicates user company.
			field			: URL segment which indicates logical domain. This string is splitted into Processor class and realm_name by _import_logic() method.
			preprocess_list  : List of preprocessor which provides authentication and so on.
			postprocess_list : List of postprocessor which finalyzes logging, data marshalling or rendering HTML.
		:return:
			Flask.Response instance
	"""
	global PREF
	time_bg = time.time()
	res_obj = None
	chain_env = {\
		"prefix": prefix, "login_id": None, "credential": None,\
		"logic": None, "realm": None,\
		"conf": PREF, "limit": None, "prod_level": flask.request.environ['PROD_LEVEL'],\
		"UA": flask.request.environ['HTTP_USER_AGENT'] if "HTTP_USER_AGENT" in flask.request.environ else "",\
		"argument": None, "user": {}, "propagate": True,\
		"performance": {\
			"total_time": None,\
			"logic_time": None,\
			"io_read_count" : None,\
			"io_write_count" : None,\
			"io_read_bytes" : None,\
			"io_write_bytes" : None
		},\
		"validate": {\
			"input": {\
				"result": None,\
				"log": None\
			},\
			"output": {\
				"result": None,\
				"log": None\
			}\
		},\
		"http_status": None,\
		"status": {\
			"code": None,\
			"description": None\
		}, "trace": [],\
		"mime": None, "headers": {}, "results": {}, "response_body": None,\
		"sendfile_content": None, "sendfile_params": {}, "logger": Logger(PREF['logging'], uuid.uuid4().hex), \
		"query": query,\
	}

	# chain_env['row_client_id'] = flask.request.cookies.get('selectedClientId', None);
	# chain_env['row_company_id'] = flask.request.cookies.get('selectedCompanyId', None);

	chain_env['headers']['X-AppInstance'] = chain_env['logger'].instance_id
	chain = preprocess_list if preprocess_list and isinstance(preprocess_list, list) else []
	try:
		logic_cls, chain_env['logic'], chain_env['realm'] = _import_logic(field)
		if not logic_cls or not callable(logic_cls):
			chain += (lambda chain_env: chain_env.__setitem__("status",{"code": 10,"description":None}) if chain_env['propagate'] else None ,)
		else:
			chain += logic_cls(PREF)(chain_env['realm'])
	except EXC.ErrorBase, err:
		chain_env['trace'].append(traceback.format_exc(err))
		chain_env['mime'] = "text/plain"
		chain_env['response_body'] = "%s occured(%d): %s" % (type(err), err.no, err.msg)
		chain_env['headers'] = {"Content-type": "text/plain; charset=UTF-8"}
		pprint.pprint(chain_env['trace'])
	else:
		if postprocess_list and isinstance(postprocess_list, list):
			chain += postprocess_list
		else:
			chain += IF.Dump(PREF).process_list
		chain_env['logger']("appglobal", map(lambda x: str(x), chain))
		for e_method in chain:
			if callable(e_method):
				e_method(chain_env)
				chain_env['logger']("appglobal", "%s passed." % str(e_method))
			else:
				chain_env['logger']("appglobal", "%s skipped." % str(e_method))
		res_obj = flask.make_response(chain_env['response_body'] if chain_env['response_body'] else u"認証が期限切れか、別の場所からログインしています。")
		if isinstance(chain_env['http_status'], (int,long)):
			res_obj.status_code = chain_env['http_status']
		if 'Location' in chain_env['headers'] and chain_env['headers']['Location']:
			res_obj.headers['Location'] = chain_env['headers']['Location']
		res_obj.headers = chain_env['headers'] if chain_env['headers'] and isinstance(chain_env['headers'], dict) else {"Content-type": "text/plain; charset=UTF-8"}
		EXT_HEADERS = (\
			("total_time", "PERF_TIME_TOTAL"),\
			("logic_time", "PERF_TIME_LOGIC"),\
			("io_read_count", "PERF_IO_COUNT_READ"),\
			("io_write_count", "PERF_IO_COUNT_WRITE"),\
			("io_read_bytes", "PERF_IO_BYTES_READ"),\
			("io_write_bytes", "PERF_IO_BYTES_WRITE")\
		)
		chain_env['performance']['total_time'] = time.time() - time_bg
		res_obj.headers['X-PRODUCTION_LEVEL'] = chain_env['prod_level']
		try:
			pio = filter(lambda x: x.pid == os.getpid(), psutil.get_process_list())[0].get_io_counters()
		except:
			pass
		else:
			chain_env['performance']['io_read_count'] = pio.read_count
			chain_env['performance']['io_write_count'] = pio.write_count
			chain_env['performance']['io_read_bytes'] = pio.read_bytes
			chain_env['performance']['io_write_bytes'] = pio.write_bytes
		for k, h in EXT_HEADERS:
			if chain_env['performance'][k] is not None and isinstance(chain_env['performance'][k], (int, long, float)):
				res_obj.headers['X-%s' % h] = ("%f" if isinstance(chain_env['performance'][k], float) else "%d") % chain_env['performance'][k]
		chain_env['logger']("appglobal", chain_env['performance'])
		if chain_env['mime'] is not None and isinstance(chain_env['mime'], basestring):
			res_obj.mimetype = chain_env['mime']
		del chain_env['logger']
		if chain_env['sendfile_content'] and chain_env['sendfile_params']:
			# return flask.send_file(chain_env['sendfile_content'], **chain_env['sendfile_params'])
			res_obj = flask.send_file(chain_env['sendfile_content'], **chain_env['sendfile_params'])
			if chain_env['headers']:
				if 'Set-Cookie' in chain_env['headers']:
					res_obj.headers['Set-Cookie'] = chain_env['headers']['Set-Cookie']
	#del chain_env['logger']
	return res_obj
