#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import os
import sys
import traceback
import pprint
import json
import optparse

import MySQLdb as DBS
import xlrd

__PREF_PASSES__ = {\
	"develop": "/var/httpdStore/c4s_devel/webApp",\
	"pool": "/var/httpdStore/c4s_pool/webApp",\
	"prod": "/var/httpdStore/c4s_prod/webApp",\
}
__VERSION__ = "0.90"
__VERBOSE__ = True
__PREF_PASS__ = "/var/httpdStore/c4s_prod/webApp"
__WORK_PATH__ = "/tmp"
__RULE_CLIENT__ = {\
	"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
	"hashmap/string[@name='tmp_id']": {"type": "string", "need": True, "nullable": False},\
	"hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False, "max": 64},\
	"hashmap/string[@name='kana']": {"type": "string", "need": True, "nullable": True, "max": 128},\
	"hashmap/string[@name='addr_vip']": {"type": "string", "need": True, "nullable": True,\
		"restrict": "([0-9]{7})?"},\
	"hashmap/string[@name='addr1']": {"type": "string", "need": True, "nullable": True, "max": 64},\
	"hashmap/string[@name='addr2']": {"type": "string", "need": True, "nullable": True, "max": 64},\
	"hashmap/string[@name='tel']": {"type": "string", "need": True, "nullable": True, "max": 15,\
		"restrict": "([0-9][0-9\-]+[0-9])?"},\
	"hashmap/string[@name='fax']": {"type": "string", "need": True, "nullable": True, "max": 15,\
		"restrict": "([0-9][0-9\-]+[0-9])?"},\
	"hashmap/string[@name='site']": {"type": "string", "need": True, "nullable": True, "max": 128,\
		"restrict": "((http|https)\://[a-z0-9\^_~\.\-/]+)?"},\
	"hashmap/string[@name='type_presentation']/string": {"type": "string", "nullable": False,\
		"candidates": (u"案件", u"人材", u"案件,人材")},\
	"hashmap/string[@name='type_dealing']": {"type": "string", "need": True, "nullable": False,\
		"candidates": (u"重要客", u"通常客", u"低ポテンシャル", u"取引停止")},\
}
__RULE_WORKER__ = {\
	"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
	"hashmap/string[@name='tmp_id']": {"type": "string", "need": True, "nullable": False},\
	"hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False, "max": 16},\
	"hashmap/string[@name='kana']": {"type": "string", "need": True, "nullable": True, "max": 32},\
	"hashmap/string[@name='section']": {"type": "string", "need": True, "nullable": True, "max": 64},\
	"hashmap/string[@name='title']": {"type": "string", "need": True, "nullable": True, "max": 32},\
	"hashmap/string[@name='tel']": {"type": "string", "need": True, "nullable": True, "max": 15,\
		"restrict": "([0-9][0-9\-]+[0-9])?"},\
	"hashmap/string[@name='tel2']": {"type": "string", "need": True, "nullable": True, "max": 15,\
		"restrict": "([0-9][0-9\-]+[0-9])?"},\
	"hashmap/string[@name='mail1']": {"type": "string", "need": True, "nullable": True,\
		"restrict": "([a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+)?"},\
	"hashmap/string[@name='mail2']": {"type": "string", "need": True, "nullable": True,\
		"restrict": "([a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+)?"},\
	"hashmap/boolean[@name='flg_keyperson']": {"type": "boolean", "need": False, "nullable": False},\
	"hashmap/boolean[@name='flg_sendmail']": {"type": "boolean", "need": False, "nullable": False},\
	"hashmap/number[@name='recipient_priority']": {"type": "number", "need": True, "nullable": False, "min": 1, "max": 9},\
}
LOG_LIST = []

def get_dsn(prod_level):
	global __PREF_PASS__
	sys.path.append(__PREF_PASS__)
	import preference as PREF
	return (PREF.ENV[prod_level] if prod_level in PREF.ENV else PREF.ENV['default'])['MYSQL_HOSTS'][0]

def get_tmp_filename(tr_id):
	global __WORK_PATH__
	return os.path.join(__WORK_PATH__, "%s.xls" % tr_id)

def open_workbook(dsn, tr_id, filepath = None):
	if not filepath:
		con = DBS.connect(**dsn)
		cur = con.cursor()
		cur.execute("""\
	SELECT DISTINCT
	  `B`.`name`,
	  `B`.`size`,
	  `B`.`digest`,
	  `B`.`value`
	  FROM `ft_import_requests` AS `R`
	  INNER JOIN `cr_impreq_data_bin` AS `X`
	    ON `X`.`impreq_id` = `R`.`transaction_id`
	  INNER JOIN `ft_binaries` AS `B`
	    ON `B`.`id` = `X`.`bin_id`
	  WHERE
	    `R`.`transaction_id` = %s;""", (tr_id,))
		db_res = cur.fetchone()
		con.close()
		hdl = open(get_tmp_filename(tr_id), "wb")
		hdl.write(db_res[3])
		hdl.close()
		bk = xlrd.open_workbook(get_tmp_filename(tr_id))
	else:
		bk = xlrd.open_workbook(filepath)
	return bk

def parse_clients(book, sheet_name = u"取引先"):
	COLS = (\
		"tmp_id", "name", "kana", "addr_vip", "addr1", "addr2",\
		"tel", "fax", "site", "type_presentation", "type_dealing",\
	)
	try:
		sh = book.sheet_by_name(sheet_name)
	except xlrd.biffh.XLRDError, err:
		log(traceback.format_exc())
	else:
		res = {}
		cnt = 1
		while True:
			try:
				row = sh.row(cnt)
			except:
				break
			else:
				tmp = {\
					"kana": "",\
					"addr_vip": "",\
					"addr1": "",\
					"addr2": "",\
					"tel": "",\
					"fax": "",\
					"site": "",\
				}
				flg_skip = False
				try:
					for idx, nm in enumerate(COLS):
						if idx < len(row):
							if row[idx].ctype != 0:
								if nm == "tmp_id":
									try:
										tmp[nm] = str(int(row[idx].value))
									except Exception, err:
										tmp[nm] = ""
										flg_skip = True
								elif nm == "addr_vip":
									tmp[nm] = row[idx].value.replace("-", "")
								else:
									tmp[nm] = row[idx].value or ""
							else:
								tmp[nm] = ""
							tmp[nm] = tmp[nm] or ""
				except:
					log(traceback.format_exc())
					cnt += 1
					continue
				else:
					if not flg_skip:
						res[tmp['tmp_id']] = tmp
					cnt += 1
		return res

def parse_workers(book, sheet_name = u"取引先担当者"):
	COLS = (\
		"tmp_id", "name", "kana", "section", "title",\
		"tel", "tel2", "mail1", "mail2",\
		"flg_keyperson", "flg_sendmail", "recipient_priority",\
	)
	try:
		sh = book.sheet_by_name(sheet_name)
	except xlrd.biffh.XLRDError, err:
		log(traceback.format_exc())
	else:
		res = {}
		cnt = 1
		while True:
			try:
				row = sh.row(cnt)
			except:
				break
			else:
				tmp = {\
					"kana": "",\
					"section": "",\
					"title": "",\
					"tel2": "",\
					"mail2": "",\
					"flg_keyperson": False,\
					"flg_sendmail": False,\
					"recipient_priority": 5,\
				}
				flg_skip = False
				try:
					for idx, nm in enumerate(COLS):
						if idx < len(row):
							if nm == "tmp_id":
								try:
									tmp[nm] = str(int(row[idx].value))
								except Exception, err:
									if row[idx].value.startswith("#"):
										tmp[nm] = ""
										flg_skip = True
							elif nm in ("mail1", "mail2",):
								tmp[nm] = (row[idx].value if isinstance(row[idx].value, basestring) else "").strip()
							elif nm in ("flg_keyperson", "flg_sendmail",):
								tmp[nm] = True if row[idx].value == "y" else False
							elif nm == "recipient_priority":
								try:
									tmp[nm] = int(row[idx].value)
								except:
									tmp[nm] = 5
							else:
								if row[idx].ctype != 0:
									tmp[nm] = row[idx].value or ""
								else:
									tmp[nm] = ""
							tmp[nm] = tmp[nm] or ""
				except:
					log(traceback.format_exc())
					cnt += 1
					continue
				else:
					if tmp['tmp_id'] not in res:
						res[tmp['tmp_id']] = []
					res[tmp['tmp_id']].append(tmp) if not flg_skip else None
					cnt += 1
		return res

def validate_client(obj):
	
	"""
	For 1st phase of validation.
	"""
	global __PREF_PASS__
	global __RULE_CLIENT__
	sys.path.append(__PREF_PASS__)
	from validators.base import ValidatorBase as Validator
	v = Validator()
	v_res, v_log = v.test(__RULE_CLIENT__, obj)
	return (v_res, {"result": v_res, "log": v.logTrim(v_log)},)

def validate_worker(obj):
	
	"""
	For 1st phase of validation.
	"""
	global __PREF_PASS__
	global __RULE_WORKER__
	sys.path.append(__PREF_PASS__)
	from validators.base import ValidatorBase as Validator
	v = Validator()
	v_res, v_log = v.test(__RULE_WORKER__, obj)
	if not v_res:
		pprint.pprint((obj, v_log,))
	return (v_res, {"result": v_res, "log": v.logTrim(v_log)},)

def validate_joint(clients, workers):
	
	"""
	For 2nd phase of validation.
	"""
	client_id_set = set(clients.keys())
	worker_parent_id_set = set(workers.keys())
	unbound_client_id_set = worker_parent_id_set.difference(client_id_set)
	return (False if unbound_client_id_set else True, unbound_client_id_set,)

def prepare_tmp_tables(dsn, tr_id = "test"):
	
	"""
	Prepare temporary tables transaction_id dependent.
	"""
	DDL = []
	#temporary mt_client.
	DDL += [\
"""DROP TABLE IF EXISTS `tmp_%s_mt_client_workers`;""" % tr_id,\
"""DROP TABLE IF EXISTS `tmp_%s_mt_clients`;""" % tr_id,\
"""\
CREATE TABLE `tmp_%s_mt_clients` (
  `id` MEDIUMINT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(64) NOT NULL COMMENT '取引先名',
  `kana` VARCHAR(128) NOT NULL COMMENT '取引先名（カナ）',
  `addr_vip` VARCHAR(7) CHARSET latin1 COLLATE latin1_bin NOT NULL COMMENT '本社郵便番号',
  `addr1` VARCHAR(64) CHARSET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '都道府県市区町村文字列',
  `addr2` VARCHAR(64) CHARSET utf8 COLLATE utf8_general_ci NOT NULL COMMENT '番地ビル名号室文字列',
  `tel` VARCHAR(15) CHARSET latin1 COLLATE latin1_bin NOT NULL COMMENT '代表電話番号',
  `fax` VARCHAR(15) CHARSET latin1 COLLATE latin1_bin DEFAULT NULL COMMENT '代表FAX番号',
  `site` VARCHAR(128) CHARSET latin1 COLLATE latin1_bin NOT NULL COMMENT 'サイトURL',
  `type_presentation` SET('案件', '人材') NOT NULL COMMENT '提案区分（案件|人材|案件,人材）',
  `type_dealing` ENUM('重要客', '通常客', '低ポテンシャル', '取引停止') NOT NULL COMMENT '取引区分',
  `charging_worker1` MEDIUMINT(10) UNSIGNED NULL DEFAULT NULL COMMENT '担当営業1',
  `charging_worker2` MEDIUMINT(10) UNSIGNED NULL DEFAULT NULL COMMENT '担当営業2',
  `owner_company_id` MEDIUMINT(5) UNSIGNED NOT NULL COMMENT '所有顧客社ID',
  `creator_id` MEDIUMINT(10) UNSIGNED DEFAULT NULL COMMENT '作成者ID',
  `modifier_id` MEDIUMINT(10) UNSIGNED DEFAULT NULL COMMENT '修正者ID',
  `dt_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日',
  `dt_modified` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最終更新日',
  `is_enabled` TINYINT(1) UNSIGNED NOT NULL DEFAULT TRUE COMMENT '有効フラグ',
  PRIMARY KEY (`id`),
  INDEX (`creator_id`),
  INDEX (`modifier_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ROW_FORMAT=COMPRESSED;""" % tr_id,\
"""\
ALTER TABLE `tmp_%s_mt_clients` ADD FOREIGN KEY (`owner_company_id`)
  REFERENCES `mt_user_companies`(`id`)
  ON UPDATE NO ACTION
  ON DELETE RESTRICT;""" % tr_id,\
"""\
ALTER TABLE `tmp_%s_mt_clients` ADD FOREIGN KEY (`creator_id`)
  REFERENCES `mt_user_persons`(`id`)
  ON UPDATE NO ACTION
  ON DELETE RESTRICT;""" % tr_id,\
"""\
ALTER TABLE `tmp_%s_mt_clients` ADD FOREIGN KEY (`modifier_id`)
  REFERENCES `mt_user_persons`(`id`)
  ON UPDATE NO ACTION
  ON DELETE RESTRICT;""" % tr_id,
	]
	#temporary mt_client_workers.
	DDL += [\
"""\
CREATE TABLE `tmp_%s_mt_client_workers` (
  `id` MEDIUMINT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `client_id` MEDIUMINT(10) UNSIGNED NOT NULL,
  `name` VARCHAR(16) NOT NULL COMMENT '取引先担当者名',
  `kana` VARCHAR(32) NOT NULL COMMENT '取引先担当者名（カナ）',
  `section` VARCHAR(64) NOT NULL DEFAULT '' COMMENT '部署名',
  `title` VARCHAR(32) NOT NULL DEFAULT '' COMMENT '役職名',
  `tel` VARCHAR(15) CHARSET latin1 COLLATE latin1_bin NOT NULL COMMENT '携帯電話番号',
  `tel2` VARCHAR(15) CHARACTER SET latin1 COLLATE latin1_bin NOT NULL DEFAULT '' COMMENT '個別代表番号',
  `mail1` VARCHAR(64) CHARSET latin1 COLLATE latin1_bin NOT NULL COMMENT '送信用メールアドレス',
  `mail2` VARCHAR(64) CHARSET latin1 COLLATE latin1_bin NULL DEFAULT NULL COMMENT 'サブメールアドレス',
  `flg_keyperson` TINYINT(1) UNSIGNED NOT NULL DEFAULT FALSE COMMENT 'キーマンフラグ',
  `flg_sendmail` TINYINT(1) UNSIGNED NOT NULL DEFAULT TRUE COMMENT 'メール送信フラグ',
  `recipient_priority` INT(1) UNSIGNED NOT NULL DEFAULT 5 COMMENT 'メール送信 時宛先優先度（最小：1～最大：9）',
  `charging_user_id` MEDIUMINT(10) UNSIGNED NULL DEFAULT NULL COMMENT '営業担当',
  `owner_company_id` MEDIUMINT(5) UNSIGNED NOT NULL COMMENT '所有顧客社ID',
  `creator_id` MEDIUMINT(10) UNSIGNED DEFAULT NULL COMMENT '作成者ID',
  `modifier_id` MEDIUMINT(10) UNSIGNED DEFAULT NULL COMMENT '修正者ID',
  `dt_created` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '作成日',
  `dt_modified` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP COMMENT '最終更新日',
  `is_enabled` TINYINT(1) UNSIGNED NOT NULL DEFAULT TRUE COMMENT '有効フラグ',
  PRIMARY KEY (`id`),
  INDEX (`client_id`),
  INDEX (`creator_id`),
  INDEX (`modifier_id`)
) ENGINE=InnoDB DEFAULT CHARACTER SET utf8 COLLATE utf8_bin ROW_FORMAT=COMPRESSED;""" % tr_id,\
"""\
ALTER TABLE `tmp_%s_mt_client_workers` ADD FOREIGN KEY (`owner_company_id`)
  REFERENCES `mt_user_companies`(`id`)
  ON UPDATE NO ACTION
  ON DELETE RESTRICT;""" % tr_id,\
"""\
ALTER TABLE `tmp_%s_mt_client_workers` ADD FOREIGN KEY (`client_id`)
  REFERENCES `tmp_%s_mt_clients`(`id`)
  ON UPDATE NO ACTION
  ON DELETE CASCADE;""" % (tr_id, tr_id,),\
"""\
ALTER TABLE `tmp_%s_mt_client_workers` ADD FOREIGN KEY (`creator_id`)
  REFERENCES `mt_user_persons`(`id`)
  ON UPDATE NO ACTION
  ON DELETE RESTRICT;""" % tr_id,\
"""\
ALTER TABLE `tmp_%s_mt_client_workers` ADD FOREIGN KEY (`modifier_id`)
  REFERENCES `mt_user_persons`(`id`)
  ON UPDATE NO ACTION
  ON DELETE RESTRICT;""" % tr_id,\
	]
	con = DBS.connect(**dsn)
	cur = con.cursor()
	for ddl in DDL:
		try:
			cur.execute(ddl)
		except Exception, err:
			raise Exception(err, ddl)
		except Warning, err:
			raise Exception(err, ddl)
	con.commit()
	con.close()

def store_state(dsn, tr_id, state, memo = "", logs=None):
	stmt_r = """\
INSERT INTO `ft_import_requests` (
  `transaction_id`,
  `company_id`,
  `status`,
  `memo`)
SELECT
  %(transaction_id)s,
  (
    SELECT
      `company_id`
      FROM `ft_import_requests`
      WHERE
        `transaction_id` = %(transaction_id)s
        AND `status` = '受理'
  ),
  %(status)s,
  %(memo)s
ON DUPLICATE KEY UPDATE
  `status` = %(status)s,
  `memo` = %(memo)s,
  `dt_created` = CURRENT_TIMESTAMP;"""
	stmt_b1 = """\
INSERT INTO `ft_binaries` (
  `type_mime`,
  `name`,
  `value`,
  `size`,
  `digest`,
  `creator_id`,
  `is_temp`,
  `is_enabled`) VALUES (
  'text/plain',
  '解析ログ.txt',
  %(binary_content)s,
  %(binary_size)s,
  MD5(%(binary_content)s),
  (
    SELECT
      `P`.`id`
      FROM `mt_user_persons` AS `P`
      INNER JOIN `ft_import_requests` AS `R`
        ON `R`.`company_id` = `P`.`company_id`
      WHERE
        `R`.`transaction_id` = %(transaction_id)s
        AND `P`.`is_enabled` = TRUE
        AND `P`.`is_locked` <> TRUE
        AND `P`.`is_admin` = TRUE
      ORDER BY `P`.`tm_last_login` DESC
      LIMIT 1
  ),
  FALSE,
  TRUE);"""
	stmt_b2 = """SELECT LAST_INSERT_ID();"""
	stmt_x = """\
INSERT INTO `cr_impreq_log_bin` (
  `impreq_id`,
  `bin_id`) VALUES (
  %(transaction_id)s,
  %(bin_id)s);"""
	con = DBS.connect(**dsn)
	cur = con.cursor()
	flg_committable = True
	params = {\
		"transaction_id": tr_id,\
		"status": state,\
		"memo": memo,\
	}
	if logs:
		import cStringIO
		buff = cStringIO.StringIO()
		if isinstance(logs, basestring):
			buff.write(logs)
		elif isinstance(logs, (list, tuple,)):
			[(buff.write(chunk) if isinstance(chunk, basestring) else buff.write(pprint.pformat(chunk))) or buff.write("\n") for chunk in logs]
		buff.seek(0)
		params.update({\
			"binary_content": buff.read(),\
			"binary_size": buff.tell(),\
		})
		del buff
	try:
		cur.execute(stmt_r, params)
	except:
		flg_committable = flg_committable and False
		log(traceback.format_exc())
	if logs:
		try:
			cur.execute(stmt_b1, params)
		except:
			flg_committable = flg_committable and False
			log(traceback.format_exc())
		else:
			try:
				cur.execute(stmt_b2)
			except:
				flg_committable = flg_committable and False
				log(traceback.format_exc())
			else:
				params.update({"bin_id": cur.fetchone()[0]})
				try:
					cur.execute(stmt_x, params)
				except:
					flg_committable = flg_committable and False
					log(traceback.format_exc())
					pprint.pprint(params)
	if flg_committable:
		con.commit()
	else:
		try:
			con.rollback()
		except:
			pass
	con.close()

def log(obj, store = LOG_LIST):
	global __VERBOSE__
	txt = pprint.pformat(obj) if not isinstance(obj, basestring) else obj
	store.append(txt)
	if __VERBOSE__:
		print txt

def phase_1_parse(prod_level, tr_id, filepath = None):
	dsn = get_dsn(prod_level)
	bk = open_workbook(dsn, tr_id, filepath)
	p_cl = parse_clients(bk)
	p_wk = parse_workers(bk)
	return p_cl, p_wk

def phase_2_validate(prod_level, tr_id, clients, workers):
	valid_clients = filter(lambda x: not x[0], [validate_client(clients[k]) for k in clients])
	valid_workers = filter(lambda x: not x[0], [validate_worker(worker) for k in workers for worker in workers[k]])
	valid_joints = validate_joint(clients, workers)
	if not valid_clients and not valid_workers and valid_joints[0]:
		return True, None
	else:
		valid_log = []
		if valid_clients:
			valid_log += map(lambda x: x[1], valid_clients)
		if valid_workers:
			valid_log += map(lambda x: x[1], valid_workers)
		if not valid_joints[0]:
			valid_log += valid_joints[1]
		return False, valid_log

def phase_3_import_tmp(prod_level, tr_id, clients, workers):
	stmt_c1 = """\
INSERT INTO `tmp_%s_mt_clients` (
  `name`,
  `kana`,
  `addr_vip`,
  `addr1`,
  `addr2`,
  `tel`,
  `fax`,
  `site`,
  `type_presentation`,
  `type_dealing`,
  `owner_company_id`,
  `creator_id`) VALUES (
  %%(name)s,
  %%(kana)s,
  %%(addr_vip)s,
  %%(addr1)s,
  %%(addr2)s,
  %%(tel)s,
  %%(fax)s,
  %%(site)s,
  %%(type_presentation)s,
  %%(type_dealing)s,
  (
    SELECT
      `P`.`company_id`
      FROM `mt_user_persons` AS `P`
      INNER JOIN `ft_import_requests` AS `R`
        ON `R`.`company_id` = `P`.`company_id`
      WHERE
        `R`.`transaction_id` = %%(transaction_id)s
        AND `P`.`is_enabled` = TRUE
        AND `P`.`is_locked` = FALSE
        AND `P`.`is_admin` = TRUE
      ORDER BY `P`.`tm_last_login` DESC
      LIMIT 1
  ),
  (
    SELECT
      `P`.`id`
      FROM `mt_user_persons` AS `P`
      INNER JOIN `ft_import_requests` AS `R`
        ON `R`.`company_id` = `P`.`company_id`
      WHERE
        `R`.`transaction_id` = %%(transaction_id)s
        AND `P`.`is_enabled` = TRUE
        AND `P`.`is_locked` = FALSE
        AND `P`.`is_admin` = TRUE
      ORDER BY `P`.`tm_last_login` DESC
      LIMIT 1
  ));""" % tr_id
	stmt_c2 = """SELECT LAST_INSERT_ID() INTO @c_id;"""
	stmt_w = """\
INSERT INTO `tmp_%s_mt_client_workers` (
  `client_id`,
  `name`,
  `kana`,
  `section`,
  `title`,
  `tel`,
  `tel2`,
  `mail1`,
  `mail2`,
  `flg_keyperson`,
  `flg_sendmail`,
  `recipient_priority`,
  `owner_company_id`,
  `creator_id`) VALUES (
  @c_id,
  %%(name)s,
  %%(kana)s,
  %%(section)s,
  %%(title)s,
  %%(tel)s,
  %%(tel2)s,
  %%(mail1)s,
  %%(mail2)s,
  CASE
    WHEN %%(flg_keyperson)s IS NULL OR %%(flg_keyperson)s = FALSE OR %%(flg_keyperson)s = ''
      THEN FALSE
    ELSE %%(flg_keyperson)s
  END,
  %%(flg_sendmail)s,
  %%(recipient_priority)s,
  (
    SELECT
      `P`.`company_id`
      FROM `mt_user_persons` AS `P`
      INNER JOIN `ft_import_requests` AS `R`
        ON `R`.`company_id` = `P`.`company_id`
      WHERE
        `R`.`transaction_id` = %%(transaction_id)s
        AND `P`.`is_enabled` = TRUE
        AND `P`.`is_locked` = FALSE
        AND `P`.`is_admin` = TRUE
      ORDER BY `P`.`tm_last_login` DESC
      LIMIT 1
  ),
  (
    SELECT
      `P`.`id`
      FROM `mt_user_persons` AS `P`
      INNER JOIN `ft_import_requests` AS `R`
        ON `R`.`company_id` = `P`.`company_id`
      WHERE
        `R`.`transaction_id` = %%(transaction_id)s
        AND `P`.`is_enabled` = TRUE
        AND `P`.`is_locked` = FALSE
        AND `P`.`is_admin` = TRUE
      ORDER BY `P`.`tm_last_login` DESC
      LIMIT 1
  ));""" % tr_id
	prepare_tmp_tables(get_dsn(prod_level), tr_id)
	con = DBS.connect(**(get_dsn(prod_level)))
	cur = con.cursor()
	flg_committable = True
	for client_key in clients:
		client = clients[client_key]
		client.update({"transaction_id": tr_id})
		try:
			cur.execute(stmt_c1, client)
		except:
			log(traceback.format_exc())
			flg_committable = flg_committable and False
			break
		else:
			cur.execute(stmt_c2)
			if client['tmp_id'] in workers:
				for worker in workers[client['tmp_id']]:
					worker.update({"transaction_id": tr_id})
					try:
						cur.execute(stmt_w, worker)
					except:
						log(traceback.format_exc())
						flg_committable = flg_committable and False
						log(worker)
						break
					else:
						pass
	if flg_committable:
		con.commit()
	else:
		try:
			con.rollback()
		except:
			pass
	con.close()
	return flg_committable

def phase_4_release(prod_level, tr_id):#This function will lock tables.
	dsn = get_dsn(prod_level)
	stmt_c1 = """\
SELECT
  `id`
  INTO @c_old_id
  FROM `tmp_%s_mt_clients`
  WHERE
    `is_enabled` = TRUE
  ORDER BY `id` ASC
  LIMIT 1;""" % tr_id
	stmt_c2 = """\
INSERT INTO `mt_clients` (
  `name`,
  `kana`,
  `addr_vip`,
  `addr1`,
  `addr2`,
  `tel`,
  `fax`,
  `site`,
  `type_presentation`,
  `type_dealing`,
  `owner_company_id`,
  `creator_id`)
SELECT
  `name`,
  `kana`,
  `addr_vip`,
  `addr1`,
  `addr2`,
  `tel`,
  `fax`,
  `site`,
  `type_presentation`,
  `type_dealing`,
  `owner_company_id`,
  `creator_id`
  FROM `tmp_%s_mt_clients`
  WHERE
    `id` = @c_old_id;""" % tr_id
	stmt_c3 = """SELECT LAST_INSERT_ID() INTO @c_new_id;"""
	stmt_w1 = """\
INSERT INTO `mt_client_workers` (
  `client_id`,
  `name`,
  `kana`,
  `section`,
  `title`,
  `tel`,
  `tel2`,
  `mail1`,
  `mail2`,
  `flg_keyperson`,
  `flg_sendmail`,
  `recipient_priority`,
  `owner_company_id`,
  `creator_id`)
SELECT
  @c_new_id,
  `name`,
  `kana`,
  `section`,
  `title`,
  `tel`,
  `tel2`,
  `mail1`,
  `mail2`,
  `flg_keyperson`,
  `flg_sendmail`,
  `recipient_priority`,
  `owner_company_id`,
  `creator_id`
  FROM `tmp_%s_mt_client_workers`
  WHERE
    `client_id` = @c_old_id;""" % tr_id
	stmt_c4 = """UPDATE `tmp_%s_mt_clients` SET `is_enabled` = FALSE WHERE `id` = @c_old_id;""" % tr_id
	con = DBS.connect(**dsn)
	cur = con.cursor()
	flg_committable = True
	while cur.execute(stmt_c1):
		try:
			cur.execute(stmt_c2)
			cur.execute(stmt_c3)
			cur.execute(stmt_w1)
			cur.execute(stmt_c4)
		except:
			flg_committable = flg_committable and False
			log(traceback.format_exc())
			print cur._executed
			break
	if flg_committable:
		con.commit()
	else:
		con.rollback()
	return flg_committable

def phase_5_cleanup(prod_level, tr_id, targets=None):
	if tr_id and targets:
		for target in targets:
			if target == "tmp_file":
				global __WORK_PATH__
				os.remove(os.path.join(__WORK_PATH__, "%s.xls" % tr_id))
			elif target == "tmp_table":
				con = DBS.connect(**(get_dsn(prod_level)))
				cur = con.cursor()
				cur.execute("""DROP TABLE IF EXISTS `tmp_%s_mt_client_workers`;""" % tr_id)
				cur.execute("""DROP TABLE IF EXISTS `tmp_%s_mt_clients`;""" % tr_id)
				try:
					con.commit()
				except:
					pass
				finally:
					con.close()
			else:
				pass

if __name__ == "__main__":
	#[boot options]
	opt_list = [\
		optparse.make_option("-t", "--transaction-id", action="store", dest="tr_id", default=None,\
			help="Transaction ID of target migration request."),\
		optparse.make_option("-f", "--filepath", action="store", dest="filepath", default=None,\
			help="File path of the target XLS data file. This option forces dry-run mode and validation ONLY. '-f' option and '-t' option are exclusive."),\
		optparse.make_option("-p", "--prod_level", action="store", dest="prod_level", default="develop",\
			help="Target production environment level. ie.)develop, pool, prod,..."),\
		optparse.make_option("-s", "--step", action="store", choices=("validate", "import", "release",),\
			dest="step", default="validate", help="Processing step."),\
		optparse.make_option("-l", "--log-file-name", action="store", dest="logfile", default="log.txt",\
			help="File name of execution log. This name is stored on database."),\
		optparse.make_option(None, "--temporary", action="store", dest="tmp_dir", default=__WORK_PATH__,\
			help="Temporary file directory."),\
		optparse.make_option("-d", "--dry", action="store_true", dest="flg_dryrun", default=False,\
			help="Set dry run mode which won't write any state to database."),\
		optparse.make_option("-v", "--verbose", action="store_true", dest="flg_verbose", default=False),\
	]
	usage = """> python %prog -t 99ce09b686684168962ce17a5ded6b05d0664ebf -p develop -s validate -v
or
> python %prog -f target.xls -p prod -v"""
	optparser = optparse.OptionParser(usage = usage, version = "%%prog version %s" % __VERSION__,\
		option_list = opt_list, epilog = "made by INTER PLUG Corp.,(Hiroyuki Nakatsuka)")
	options, args = optparser.parse_args()
	del args
	if options.filepath:
		options.step = "validate"
		options.flg_dryrun = True
	#[boot check]
	if not (options.tr_id or options.filepath):
		print "Transaction ID or Filepath is unbound."
		optparser.print_help()
		raise SystemExit
	__VERBOSE__ = options.flg_verbose
	__WORK_PATH__ = options.tmp_dir
	__PREF_PASS__ = __PREF_PASSES__[options.prod_level] if options.prod_level in __PREF_PASSES__ else __PREF_PASS__
	log("[Boot Options]")
	log("  Transaction ID: %s" % options.tr_id)
	log("  Filepath: %s" % options.filepath)
	log("  Production Level: %s" % options.prod_level)
	log("  Step: %s" % options.step)
	log("  Log filename: %s" % options.logfile)
	log("  Temporary directory: %s" % options.tmp_dir)
	log("  Dry run mode: %s" % options.flg_dryrun)
	log("==============================")
	#[switch]
	if options.step == "validate":
		clients, workers = phase_1_parse(options.prod_level, options.tr_id, options.filepath)
		flg_valid, log_valid = phase_2_validate(options.prod_level, options.tr_id, clients, workers) if clients and workers else (None, None)
		if flg_valid and not options.filepath:
			store_state(get_dsn(options.prod_level), options.tr_id, u"検証済", u"検証で異状はありませんでした。") if not options.flg_dryrun else None
			store_state(get_dsn(options.prod_level), options.tr_id, u"本投入待機") if not options.flg_dryrun else None
		elif options.filepath:
			print "%s to validate." % "Successed" if flg_valid else "Failed"
			pprint.pprint(log_valid)
		else:
			store_state(get_dsn(options.prod_level), options.tr_id, u"検証失敗", u"検証中に異状を確認しました。", log_valid or LOG_LIST) if not options.flg_dryrun else None
		phase_5_cleanup(options.prod_level, options.tr_id, targets=("tmp_file",))
	elif options.step == "import":
		clients, workers = phase_1_parse(options.prod_level, options.tr_id)
		flg_valid = phase_2_validate(options.prod_level, options.tr_id, clients, workers) if clients and workers else (None, None)
		if flg_valid:
			store_state(get_dsn(options.prod_level), options.tr_id, u"本投入中", u"暫定テーブルへの投入を開始しました。") if not options.flg_dryrun else None
			if not phase_3_import_tmp(options.prod_level, options.tr_id, clients, workers):
				store_state(get_dsn(options.prod_level), options.tr_id, u"本投入失敗", u"暫定テーブルへの投入に失敗しました。") if not options.flg_dryrun else None
			else:
				store_state(get_dsn(options.prod_level), options.tr_id, u"本投入中", u"暫定テーブルへの投入を完了しました。")
				pass
		phase_5_cleanup(options.prod_level, options.tr_id, targets=("tmp_file",))
	elif options.step == "release":
		store_state(get_dsn(options.prod_level), options.tr_id, u"本投入中", u"本テーブルへの投入を開始しました。")
		if not phase_4_release(options.prod_level, options.tr_id):
			store_state(get_dsn(options.prod_level), options.tr_id, u"本投入失敗", u"本テーブルへの投入に失敗しました。") if not options.flg_dryrun else None
		else:
			store_state(get_dsn(options.prod_level), options.tr_id, u"本投入済", u"本テーブルへの投入を完了しました。") if not options.flg_dryrun else None
			store_state(get_dsn(options.prod_level), options.tr_id, u"完了", u"データ移行を完了しました。") if not options.flg_dryrun else None
		phase_5_cleanup(options.prod_level, options.tr_id, targets=("tmp_table",))
	else:
		print "Step is unbound."
		optparser.print_help()
		raise SystemExit