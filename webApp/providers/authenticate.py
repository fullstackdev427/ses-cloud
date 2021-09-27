#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import pprint
import traceback

import flask
#import redis
#import mysql.connector as DBS
import MySQLdb as DBS

class Authenticate(object):
	
	@classmethod
	def valid_credential(cls, chain_env):
		REDIS_PREF = chain_env['conf']['REDIS_AUTH']
		MYSQL_PREF = chain_env['conf']['MYSQL_HOSTS'][len(chain_env['conf']['MYSQL_HOSTS']) % chain_env['conf']['MYSQL_MODULO']]
		rcon = redis.Redis(**REDIS_PREF)
		flg_propagate = None
		status = {"code": 0, "description": None}
		if "prefix" in chain_env and "login_id" in chain_env['argument'].data:
			rkey = "%s_%s" % (chain_env['prefix'], chain_env['argument'].data['login_id'])
			rval = (rcon.get(rkey), rcon.ttl(rkey))
			#pprint.pprint(rval)
			if rval == (None, None):
				try:
					dbcon = DBS.connect(**MYSQL_PREF)
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc(err))
					status['code'] = 5
					flg_propagate = False
				else:
					dbcur = dbcon.cursor()
					param = (\
						chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
						chain_env['conf']['REDIS_AUTH_TTL']\
					)
					try:
						dbcur.execute("""SELECT valid_credential(%s, %s, %s, %s);""", param)
					except Exception , err:
						chain_env['trace'].append(traceback.format_exc(err))
						status['code'] = 2
						flg_propagate = False
					else:
						rcode = dbcur.fetchone()
						if res and res[0]==True:#Valid.
							dbcon.commit()
							rcon.setex(rkey, chain_env['credential'], chain_env['conf']['REDIS_AUTH_TTL'])
							status['code'] = 0
							flg_propagate = True
						elif res and res[0]==False:#Invalid.
							dbcon.commit()
							rcon.delete(rkey)
							status['code'] = 9
							flg_propagate = False
						else:#Undefined.
							status['code'] = 3
							flg_propagate = False
						try:
							_ = dbcur.fetchall()
						except:
							pass
						dbcur.close()
						dbcon.close()
			else:
				if rval[1] <= chain_env['conf']['REDIS_AUTH_TTL']:
					flg_propagate = True
					rcon.setex(rkey, chain_env['credential'], chain_env['conf']['REDIS_AUTH_TTL'])
				else:
					flg_propagate = False
		else:
			flg_propagate = False
		chain_env['propagate'] = flg_propagate
		chain_env['status'] = status
	
	@classmethod
	def valid_credential_dbonly(cls, chain_env):
		MYSQL_PREF = chain_env['conf']['MYSQL_HOSTS'][len(chain_env['conf']['MYSQL_HOSTS']) % chain_env['conf']['MYSQL_MODULO']]
		flg_propagate = None
		status = {"code": 0, "description": None}
		if "prefix" in chain_env and "login_id" in chain_env['argument'].data:
			if "password" in chain_env['argument'].data:
				status['code'] = 0
				flg_propagate = True
			else:
				if not ("prefix" in chain_env and "login_id" in chain_env['argument'].data and "credential" in chain_env and len(chain_env['credential']) == 32):
					status['code'] = 3
					flg_propagate = False
					chain_env['http_status'] = 403
				else:
					try:
						dbcon = DBS.connect(**MYSQL_PREF)
					except Exception, err:
						chain_env['trace'].append(traceback.format_exc(err))
						status['code'] = 5
						flg_propagate = False
					else:
						dbcur = dbcon.cursor()
						param = (\
							chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
							chain_env['conf']['REDIS_AUTH_TTL']\
						)
						try:
							dbcur.execute("""SELECT valid_credential(%s, %s, %s, %s);""", param)
						except Exception, err:
							chain_env['trace'].append(dbcur._executed)
							status['code'] = 2
							flg_propagate = False
						else:
							res = dbcur.fetchone()
							print "providers.authenticate::valid_credential_dbonly", res, chain_env['login_id'] if "login_id" in chain_env else None, chain_env['credential'] if "credential" in chain_env else None
							if res and res[0] is None:
								status['code'] = 3
								flg_propagate = False
							elif res and bool(res[0]):#Valid.
								dbcon.commit()
								status['code'] = 0
								flg_propagate = True
							elif res and not bool(res[0]):#Invalid.
								dbcon.commit()
								status['code'] = 9
								flg_propagate = False
							else:#Undefined.
								flg_propagate = False
							try:
								_ = dbcur.fetchall()
							except:
								pass
							dbcur.close()
							dbcon.close()
		else:
			status['code'] = 3
			flg_propagate = False
		chain_env['propagate'] = flg_propagate
		#pprint.pprint((flg_propagate, flask.request.environ['PATH_INFO'], "/%s/html/" % chain_env['prefix']))
		chain_env['status'] = status
		chain_env['logger']("stdout", chain_env['argument'].data)
		#pprint.pprint(chain_env['trace'])
	
	@classmethod
	def valid_test(cls, chain_env):
		res_obj = {}
		res_obj['prefix'] = chain_env['prefix']
		res_obj['login_id'] = chain_env['argument'].data['login_id'] if "login_id" in chain_env['argument'].data else None
		res_obj['password'] = chain_env['argument'].data['password'] if "password" in chain_env['argument'].data else None
		res_obj['credential'] = chain_env['argument'].data['credential'] if "credential" in chain_env['argument'].data else None
		flask.request.environ['wsgi.errors'].write("\n[%s]\n  " % flask.request.path + repr(res_obj) + "\n")