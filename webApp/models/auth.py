#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for authenticate.
"""

from models.base import ModelBase

class Auth(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Auth"
	__SQL__ = {\
"login": """SELECT `P`.`id` AS `id`, MD5(CONCAT(`login_id`, UUID(), `pwd_digest`)) AS `cred` FROM `mt_user_persons` AS `P`
	INNER JOIN `mt_user_groups` AS `G`
	ON `P`.`group_id` = `G`.`id`
	INNER JOIN `mt_user_companies` AS `C`
	ON `G`.`company_id` = `C`.`id`
	WHERE `P`.`login_id` = 'rep1' AND `P`.`pwd_digest` = 'rep2' AND `C`.`prefix` = 'rep3'
	AND `C`.`is_enabled` = TRUE
	AND `G`.`is_enabled` = TRUE
	AND `P`.`is_locked` <> TRUE AND `P`.`is_enabled` = TRUE
	AND `C`.`dt_use_begin` <= NOW() AND DATE(NOW()) <= COALESCE(`C`.`dt_use_end`, NOW()) AND DATE(NOW()) <= COALESCE(`C`.`dt_charged_end`, NOW());""",\
"update_cred": """\
UPDATE `mt_user_persons` SET `credential` = 'rep1' ,`tm_last_login` = CURRENT_TIMESTAMP WHERE `id` = rep2;
""",\
"logout": """\
UPDATE `mt_user_persons` SET
  `credential`='',
  `dt_modified`=CURRENT_TIMESTAMP
  WHERE
    `company_id` = valid_user_company(%s, %s, %s)
    AND `login_id` = %s
    AND `credential` = %s
    AND `is_locked`<>TRUE
    AND `is_enabled`=TRUE;
""",\
"read_user_profile": """SELECT
  `C`.`id` AS `company_id`,
  `C`.`name` AS `company_name`,
  `C`.`dt_use_begin`,
  `C`.`dt_use_end`,
  `C`.`dt_charged_end`,
  `C`.`dt_created` AS `company_dt_created`,
  `C`.`dt_modified` AS `company_dt_modified`,
  `C`.`flg_public` AS `flg_public`,
  `G`.`id` AS `group_id`,
  `G`.`name` AS `group_name`,
  `G`.`dt_created` AS `group_dt_created`,
  `G`.`dt_modified` AS `group_dt_modified`,
  `P`.`id` AS `user_id`,
  `P`.`name` AS `user_name`,
  `P`.`mail1` AS `user_mail1`,
  `P`.`tel1` AS `user_tel1`,
  `P`.`tel2` AS `user_tel2`,
  `P`.`fax` AS `user_fax`,
  `P`.`tm_last_login`,
  `P`.`is_admin`,
  `P`.`dt_created` AS `user_dt_created`,
  `P`.`dt_modified` AS `user_dt_modified`,
  `C`.`prefix`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `P`.`group_id` = `G`.`id`
  INNER JOIN `mt_user_companies` AS `C`
    ON `G`.`company_id` = `C`.`id`
  WHERE
    `P`.`is_enabled`<>FALSE AND `G`.`is_enabled`<>FALSE AND `C`.`is_enabled`<>FALSE AND `P`.`is_locked`<>TRUE
    AND `C`.`prefix`=%s AND `P`.`login_id`=%s;""",\
"fetch_login_id": """\
SELECT
  `P`.`login_id`
  FROM `mt_user_companies` AS `C`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`company_id` = `C`.`id`
  INNER JOIN `mt_user_persons` AS `P`
    ON `P`.`group_id` = `G`.`id`
  WHERE
    `C`.`is_enabled`=TRUE
    AND `G`.`is_enabled`=TRUE
    AND `P`.`is_enabled`=TRUE
    AND `C`.`prefix`=%s
    AND `P`.`credential`=%s;""",\
"enum_users": """SELECT
  `P`.`id`,
  `G`.`id`,
  `G`.`name`,
  `P`.`login_id`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  WHERE `P`.`id` IN (%s);""",\
"last_insert_id": """SELECT LAST_INSERT_ID();"""\
	}
	__RULE__ = {\
		"login_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='login_id']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='password']": {"type": "string", "need": True, "nullable": False}\
		}\
	}
	
	@classmethod
	def __cvt_user_profile(cls, cur):
		result = []
		for res in cur:
			tmp = {"company": {}, "group": {}, "user": {}}
			tmp['company']['id'] = res[0]
			tmp['company']['name'] = res[1]
			tmp['company']['dt_use_begin'] = res[2].strftime("%Y/%m/%d") if res[2] else None
			tmp['company']['dt_use_end'] = res[3].strftime("%Y/%m/%d") if res[3] else None
			tmp['company']['dt_charged_end'] = res[4].strftime("%Y/%m/%d") if res[4] else None
			tmp['company']['dt_created'] = res[5].strftime("%Y/%m/%d %H:%M:%S") if res[5] else None
			tmp['company']['dt_modified'] = res[6].strftime("%Y/%m/%d %H:%M:%S") if res[6] else None
			tmp['company']['flg_public'] = bool(res[7])
			tmp['group']['id'] = res[8]
			tmp['group']['name'] = res[9]
			tmp['group']['dt_created'] = res[10].strftime("%Y/%m/%d %H:%M:%S") if res[10] else None
			tmp['group']['dt_modified'] = res[11].strftime("%Y/%m/%d %H:%M:%S") if res[11] else None
			tmp['user']['id'] = res[12]
			tmp['user']['name'] = res[13]
			tmp['user']['mail1'] = res[14]
			tmp['user']['tel1'] = res[15]
			tmp['user']['tel2'] = res[16]
			tmp['user']['fax'] = res[17]
			tmp['user']['tm_last_login'] = res[18].strftime("%Y/%m/%d %H:%M:%S") if res[18] else None
			tmp['user']['is_admin'] = bool(res[19])
			tmp['user']['dt_created'] = res[20].strftime("%Y/%m/%d %H:%M:%S") if res[20] else None
			tmp['user']['dt_modified'] = res[21].strftime("%Y/%m/%d %H:%M:%S") if res[21] else None
			tmp['company']['prefix'] = res[22]
			return tmp
	
	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "cred": res[1]})
		return result

	@classmethod
	def __cvt_login(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "cred": res[1]})
		return result
	
	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result
