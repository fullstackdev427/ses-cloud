#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import time
import pprint
import traceback
import xml.dom.minidom as DOM

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

#import mysql.connector as DBS
import MySQLdb as DBS
import redis

from models.limitter import Limitter as Model
from errors import exceptions as EXC
from errors.status import Status

class Limitter(object):
	DB_MAIN = 1
	DB_LOG = 2
	STORED_ROWS = (\
		(DB_MAIN, "LMT_LEN_ACCOUNT"),\
		(DB_MAIN, "LMT_LEN_CLIENT"),\
		(DB_MAIN, "LMT_LEN_ENGINEER"),\
		(DB_MAIN, "LMT_LEN_PROJECT"),\
		(DB_MAIN, "LMT_LEN_MAIL_PER_DAY"),\
		(DB_MAIN, "LMT_LEN_MAIL_PER_MONTH"),\
		(DB_MAIN, "LMT_LEN_MAIL_TPL"),\
		(DB_MAIN, "LMT_SIZE_STORAGE"),\
		(DB_LOG,  "LMT_CALL_MAP_EXTERN_M"),\
	)
	
	@classmethod
	def load_settings(cls, chain_env):
		if chain_env['propagate'] and "prefix" in chain_env and chain_env['prefix'] and "login_id" in chain_env and chain_env['login_id'] and "credential" in chain_env and chain_env['credential'] and len(chain_env['credential']) == 32:
			CONF = chain_env['conf']
			dsn = CONF['MYSQL_HOSTS'][len(CONF['MYSQL_HOSTS']) % CONF['MYSQL_MODULO']]
			try:
				dbcon = DBS.connect(**dsn)
			except Exception, err:
				chain_env['trace'].append(traceback.format_exc())
				chain_env['status']['code'] = 2
				chain_env['propagate'] = False
			else:
				dbcur = dbcon.cursor()
				try:
					dbcur.execute(Model.sql("SELECT_PREFS"), (chain_env['prefix'], chain_env['login_id'], chain_env['credential']))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc())
					chain_env['status']['code'] = 2
					chain_env['propagate'] = False
					dbcur.close()
					dbcon.close()
				else:
					chain_env['limit'] = cls.serialize_settings(dbcur)
				try:
					dbcur.execute(Model.sql("read_mail_signature"), (chain_env['login_id'], chain_env['credential']))
				except Exception, err:
					chain_env['trace'].append(traceback.format_exc())
					chain_env['status']['code'] = 2
					chain_env['propagate'] = False
				else:
					tmp = dbcur.fetchone()
					#print tmp
					if dbcur.rowcount == 1:
						chain_env['limit'].update({\
							"MAIL_SIGNATURE": tmp[0] if tmp[0] else "",\
							"SHOW_HELP": bool(tmp[1]),\
							"ROW_LENGTH": tmp[2],\
						})
					else:
						#print "providers.limitter::load_settings:%d" % dbcur.rowcount
						#print dbcur.statement
						chain_env['propagate'] = False
						chain_env['status']['code'] = 7
				dbcur.close()
				dbcon.close()
		else:
			pass
	
	@classmethod
	def refresh_settings(cls, chain_env):
		if chain_env['propagate']:
			#CONF = chain_env['conf']
			#rcon = redis.Redis(**CONF['REDIS_PREF'])
			#rkey = "%s" % chain_env['prefix']
			#rcon.delete(rkey)
			cls.load_settings(chain_env)
	
	@classmethod
	def serialize_settings(cls, cur):
		import json as JSON
		import xml.dom.minidom as DOM
		marshal_fnc = {"JSON": JSON.loads, "XML": DOM.parseString, "PLAIN": None, "PHP-EVAL": None, "PYTHON-EVAL": eval}
		result = {}
		default_vars = {}
		original_vars = {}
		for res in cur:
			tmp = {}
			tmp['owner_id'] = res[0]
			tmp['key'] = res[1]
			tmp['marshal'] = repr(marshal_fnc[res[3]])
			try:
				tmp['value'] = marshal_fnc[res[3]](res[2]) if callable(marshal_fnc[res[3]]) else res[2]
			except:
				tmp['value'] = res[2]
			(default_vars if tmp['owner_id']==0 else original_vars)[tmp['key']] = tmp['value']
		[result.update({k: default_vars[k]}) for k in default_vars]
		[result.update({k: original_vars[k]}) for k in original_vars]
		try:
			cur.execute(Model.sql("read_mail_signature"), (chain_env['login_id'], chain_env['credential']))
		except Exception, err:
			pass
		else:
			if dbcur.rowcount == 1:
				result.update({\
					"MAIL_SIGNATURE": unicode(dbcur.fetchone()[0], "utf8")\
				})
		return result
	
	@classmethod
	def valid_limit(cls, cur, chain_env={}, target_limits=[]):
		res_flg = True
		res_desc = []
		if target_limits and isinstance(target_limits, (tuple, list, set, frozenset)):
			lmt_obj_table_keys = ("LMT_LEN_CLIENT", "LMT_LEN_PROJECT", "LMT_LEN_ENGINEER", "LMT_LEN_MAIL_TPL")
			lmt_obj_table_vals = ("mt_clients", "mt_projects", "mt_engineers", "ft_mail_templates")
			lmt_obj_table_desc = (u"取引先企業", u"案件", u"技術者", u"メール テンプレート")
			for lmt_key in target_limits:
				lmt_val = chain_env['limit'][lmt_key]
				if lmt_key == "LMT_ACT_MAIL":
					res_flg = res_flg and lmt_val
					res_desc.append(u"ご契約のライセンスでは、メール機能をご利用いただけません。")
				if lmt_key == "LMT_LEN_ACCOUNT":
					param = (\
						chain_env['prefix'], chain_env['login_id'], chain_env['credential']\
					)
					cur.execute(Model.sql("LMT_LEN_ACCOUNT"), param)
					tmp = cur.fetchone()[0]
					res_flg = res_flg and (tmp >= lmt_val or tmp == 0)
					res_desc.append(u"ご契約のライセンスの有効アカウント上限数に到達しました(%d)。" % tmp)
				elif lmt_key in lmt_obj_table_keys:
					table_name = lmt_obj_table_vals[lmt_obj_table_keys.index(lmt_key)]
					param = (\
						chain_env['prefix'], chain_env['login_id']\
					)
					cur.execute(Model.sql("LMT_LEN_OBJECTS") % table_name, params)
					tmp = cur.fetchone()[0]
					res_flg = res_flg and (tmp >= lmt_val or lmt_val != 0)
					res_desc.append(u"ご契約のライセンスで、%sの登録上限数に到達しているため追加できません(%d)。" % (lmt_obj_table_desc[lmt_obj_table_keys.index(lmt_key)], tmp))
				elif lmt_key == "LMT_LEN_SKILL":
					param = (\
						chain_env['prefix'], chain_env['login_id'], chain_env['credential']\
					)
					cur.execute(Model.sql("LMT_LEN_SKILL"), params)
					tmp = cur.fetchone()[0]
					res_flg = res_flg and (tmp >= lmt_val or lmt_val != 0)
					res_desc.append(u"ご契約のライセンスで、スキルの登録上限数に到達しているため追加できません(%d)。" % tmp)
				else:
					pass
		else:
			pass
	
	@classmethod
	def count_records(cls, prefs, chain_env={}, limit_list=()):
		
		"""
		クライアントの利用状況を取得する
		とても重たい処理なのでRedisにデータがあればそちらを使う。
		またRedisにデータがあっても、chain_env['flg_batch_use']がTrulyなら、
		DBからデータを取得する。

		今後この関数を改修する際は、
		必ずmanageApp/create_report/update_redis.pyを熟読し、
		キャッシュ搭載バッチに影響が出ないことを確認すること。
		"""
		if not limit_list:
			limit_list = cls.STORED_ROWS

		def connect_main_db(pref):
			MYSQL_PREF = pref['MYSQL_HOSTS'][len(pref['MYSQL_HOSTS']) % pref['MYSQL_MODULO']]
			dbcon = None
			error = None
			try:
				dbcon = DBS.connect(**MYSQL_PREF)
			except Exception, err:
				error = traceback.format_exc()
			else:
				pass
			return dbcon, error

		def connect_log_db(pref):
			MYSQL_PREF = pref['logging']
			dbcon = None
			error = None
			try:
				dbcon = DBS.connect(**MYSQL_PREF)
			except Exception, err:
				error = traceback.format_exc()
			else:
				pass
			return dbcon, error

		results = {}
		statuses = {}
		if not chain_env['propagate']:
			return
		dbcur = {}
		dbcon = {}
		#[begin] KVS check.
		rcon = redis.Redis(**prefs['REDIS_PREF'])
		try:
			results = JSON.loads(rcon.get("%s" % (chain_env['prefix'],)))
		except:# case of null response(connection failed or key is undefined)
			pass
		else:
			chain_env['headers']['X-USE-CACHE'] = "redis=%s, %s, TTL=%d;" % (prefs['REDIS_PREF']['host'], True, rcon.ttl("%s" % (chain_env['prefix'],)))
		#[end] KVS check.
		if not results or (('flg_batch_use' in chain_env) and chain_env['flg_batch_use']):
			db_err_list = {}
			# Loop for each DB
			for db_idx in (cls.DB_MAIN, cls.DB_LOG):
				result = {}
				status = {"code": None, "description": None}
				dbcur[db_idx] = None
				if db_idx is cls.DB_MAIN:
					dbcon[db_idx], db_err_list[db_idx] = connect_main_db(prefs)
				elif db_idx is cls.DB_LOG:
					dbcon[db_idx], db_err_list[db_idx] = connect_log_db(prefs)
				else:
					pass
				if dbcon[db_idx] and not db_err_list[db_idx]:
					dbcur[db_idx] = dbcon[db_idx].cursor()
				else:
					chain_env['trace'] += db_err_list[db_idx]
				if dbcur[db_idx]:
					for db_code, limit_code in limit_list:
						if db_code is not db_idx:
							continue
						param = (\
							chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
						) if db_idx == cls.DB_MAIN else (\
							chain_env['prefix'], chain_env['login_id'], chain_env['credential'], chain_env['prod_level'],\
						)
						try:
							idx = 0
							for idx, op in enumerate(Model.sql("count_" + limit_code)):
								if idx < len(param):
									dbcur[db_idx].execute(op, (param[idx],))
								else:
									dbcur[db_idx].execute(op)
						except DBS.Error:
							chain_env['trace'].append(traceback.format_exc())
							status['code'] = status['code'] or 2
						except:
							chain_env['trace'].append(traceback.format_exc())
							status['code'] = status['code'] or None
						else:
							chain_env['trace'].append(dbcur[db_idx]._executed)
							tmp = dbcur[db_idx].fetchone()
							result[limit_code] = tmp[0] if tmp else None
					dbcur[db_idx].close()
					dbcon[db_idx].close()
					results.update(result)
					statuses[db_idx] = status
			rcon.setex("%s" % (chain_env['prefix'],), JSON.dumps(results), prefs['REDIS_PREF_TTL'])
			chain_env['headers']['X-USE-CACHE'] = "redis=%s, %s, TTL=%d;" % (prefs['REDIS_PREF']['host'], False, prefs['REDIS_PREF_TTL'])
		pprint.pprint((statuses, results,))
		return statuses, results

	@classmethod
	def count_records(cls, prefs, chain_env={}, limit_list=()):
		
		u"""
			こちらのメソッドは制限値実装のための改訂版です。
			Redisの検証も行いますが、`ft_cap_rec`を参照する形で
			実績値を取り出すようになっています。つまり、稼動時に記録されていた
			Redisのキャッシュ値は、TTLが経過すると消滅し、利用されなくなります。
			また、この実装と同時に、実績値を積み込むcrontab登録の
			バッチは廃止し、すべてMySQLのイベント スケジューラによる処理に
			切り替わっています。そのため、バッチからこのメソッドが呼び出される
			ことを考慮しません。
		"""
		def connect_main_db(pref):
			MYSQL_PREF = pref['MYSQL_HOSTS'][len(pref['MYSQL_HOSTS']) % pref['MYSQL_MODULO']]
			dbcon = None
			error = None
			try:
				dbcon = DBS.connect(**MYSQL_PREF)
			except Exception, err:
				error = traceback.format_exc()
			else:
				pass
			return dbcon, error
		
		if not limit_list:
			limit_list = cls.STORED_ROWS
		
		results = {}
		statuses = {}
		if not chain_env['propagate']:
			return
		dbcur = {}
		dbcon = {}
		#[begin] DB check.
		if not results:
			dbcon, err = connect_main_db(prefs)
			if dbcon and not err:
				dbcur= dbcon.cursor()
				try:
					dbcur.execute(Model.sql("count_ALL_from_CAPREC"), {\
							"prefix": chain_env['prefix'],\
							"login_id": chain_env['login_id'],\
							"credential": chain_env['credential'],\
						})
				except:
					pprint.pprint(traceback.format_exc())
					statuses['ALL_db'] = {"code": 2,}
					chain_env['trace'].append(traceback.format_exc())
				else:
					for r_oid, r_key, r_cap, r_rec in dbcur:
						results[r_key] = r_rec
				finally:
					dbcon.close()
		#[end] DB check.
		return statuses, results
