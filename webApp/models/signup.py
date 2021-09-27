#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for sign up.
"""

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

from errors import exceptions as EXC
from models.base import ModelBase

class Signup(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Signup"
	__SQL__ = {\
		"check_history": """\
SELECT
  `R`.`id`,
  `R`.`type_signup`,
  `R`.`flg_enabled`,
  `VC`.`id`,
  `VU`.`id`,
  `VC`.`mail`,
  `VU`.`mail`
  FROM `ft_signup_req` AS `R`
  LEFT JOIN (
    SELECT
      `id`,
      `mail`
      FROM `ft_signup_val`
      WHERE
        `mail` = %(mail)s
  ) AS `VC`
    ON `VC`.`id` = `R`.`id` AND `R`.`type_signup` = 'ADD_COMPANY'
  LEFT JOIN (
    SELECT
      `id`,
      `mail`
      FROM `ft_signup_val`
      WHERE
        `mail` = %(mail)s
  ) AS `VU`
    ON `VU`.`id` = `R`.`id` AND `R`.`type_signup` = 'ADD_USER'
  WHERE
    `R`.`flg_enabled` = FALSE
    AND `R`.`type_signup` IN ('ADD_COMPANY', 'ADD_USER')
    AND COALESCE(`VC`.`mail`, `VU`.`mail`) IS NOT NULL;""",\
		"create_invitation": """\
INSERT INTO `ft_signup_req` (
  `code`,
  `type_signup`,
  `id_target_user`,
  `id_creator`) VALUES (
  %(code)s,
  %(type_signup)s,
  %(target_user)s,
  %(creator)s);""",\
		"fetch_new_invitation": """\
SELECT
  `id`,
  `code`
  FROM `ft_signup_req`
  WHERE
    `id` = LAST_INSERT_ID();""",\
		"load_invitation": """\
SELECT
  `REQ`.`id`,
  `REQ`.`code`,
  `REQ`.`type_signup`,
  `REQ`.`id_target_user`,
  `REQ`.`id_creator`,
  `VAL`.`val`,
  `REQ`.`dt_created`,
  `VAL`.`dt_modified`
  FROM `ft_signup_req` AS `REQ`
  LEFT JOIN `ft_signup_val` AS `VAL`
    ON `VAL`.`id` = `REQ`.`id`
  WHERE
    `REQ`.`flg_enabled` = TRUE
    AND `REQ`.`code` = %(unique_code)s;""",\
		"update_val": """\
REPLACE INTO `ft_signup_val` (`id`, `val`, `mail`)
  VALUES (
    (
      SELECT
        `id`
        FROM `ft_signup_req`
        WHERE
          `id` = %(id)s
          AND `code` = %(code)s
    ),
    %(val)s,
    %(mail)s
  );""",\
		"disable_invitation": """\
UPDATE `ft_signup_req` SET `flg_enabled` = FALSE
  WHERE `id` = %(id)s;""",\
		"create_company": """\
INSERT INTO `mt_user_companies` (
  `name`,
  `owner_name`,
  `tel`,
  `fax`,
  `addr_vip`,
  `addr1`,
  `addr2`,
  `prefix`,
  `dt_use_begin`
  ) VALUES (
  %(name)s,
  %(owner_name)s,
  %(tel)s,
  %(fax)s,
  %(addr_vip)s,
  %(addr1)s,
  %(addr2)s,
  %(prefix)s,
  CURRENT_DATE
  );""",\
		"create_group": """INSERT INTO `mt_user_groups` (`company_id`) VALUES (%(cid)s);""",\
		"create_user": """\
INSERT INTO `mt_user_persons` (
   `company_id`
  ,`group_id`
  ,`name`
  ,`login_id`
  ,`pwd_digest`
  ,`mail1`
  ,`tel1`
  ,`tel2`
  ,`fax`
  ,`is_admin`
  ) VALUES (
   %(cid)s
  ,%(gid)s
  ,%(name)s
  ,%(login_id)s
  ,MD5(%(pwd)s)
  ,%(mail1)s
  ,%(tel1)s
  ,COALESCE(%(tel2)s, '')
  ,COALESCE(%(fax)s, '')
  ,%(flg_admin)s
  );
""",\
		"check_mail_tpl": """\
SELECT
  CASE
    WHEN COUNT(DISTINCT `T`.`id`) > 0 THEN TRUE
    ELSE FALSE
  END AS `flg_already_setup`
  FROM `ft_mail_templates` AS `T`
  INNER JOIN `mt_user_persons` AS `P`
    ON `P`.`id` = `T`.`creator_id`
  INNER JOIN `mt_user_companies` AS `C`
    ON `C`.`id` = `P`.`company_id`
  WHERE
    `T`.`is_enabled` = TRUE
    AND `C`.`is_enabled` = TRUE
    AND `C`.`id` = %(cid)s;""",\
		"insert_mail_tpl": """\
INSERT INTO `ft_mail_templates` (
    `name`,
    `subject`,
    `body`,
    `type_recipient`,
    `type_iterator`,
    `creator_id`,
    `modifier_id`)
SELECT 
    `name`,
    `subject`,
    `body`,
    `type_recipient`,
    `type_iterator`,
    %(uid)s,
    %(uid)s
    FROM `ft_mail_templates`
    WHERE
        `id` IN (
          SELECT
            `id`
            FROM `ft_mail_templates`
            WHERE
              `is_enabled` = TRUE
              AND `creator_id` = 0
        );""",\
		"fetch_reset_target_user": """\
SELECT
  `P`.`id`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_companies` AS `C`
    ON `C`.`id` = `P`.`company_id`
  WHERE
    `C`.`prefix` = %(prefix)s
    AND `P`.`login_id` = %(login_id)s
    AND `P`.`mail1` = %(mail)s
    AND `C`.`is_enabled` = TRUE
    AND `P`.`is_enabled` = TRUE
    AND `P`.`is_locked` <> TRUE;""",\
		"resetpwd": """\
UPDATE `mt_user_persons`
  SET
    `pwd_digest` = MD5(%(tmp_pwd)s),
    `credential` = ''
  WHERE
    `id` = %(uid)s;""",\
		"overwrite_pwd": """\
UPDATE `mt_user_persons`
  SET `pwd_digest` = MD5(%(pwd)s)
  WHERE
    `id` = %(uid)s;""",\
		"last_insert_id": """SELECT LAST_INSERT_ID();""",\
	}
	__RULE__ = {\
	}
	
	@classmethod
	def __cvt_load_invitation(cls, cur):
		result = {}
		for res in cur:
			result['id'] = res[0]
			result['code'] = res[1]
			result['type_signup'] = res[2]
			result['target_user'] = {"id": res[3],}
			result['creator'] = {"id": res[4],}
			result['val'] = JSON.loads(res[5]) if res[5] else None
			result['created'] = res[6]
			result['modified'] = res[7]
		return result
	
	@classmethod
	def __cvt_fetch_new_invitation(cls, cur):
		result = {}
		for row in cur:
			result['id'] = row[0]
			result['code'] = row[1]
		return result
	
	@classmethod
	def __cvt_has_mail_template(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result = bool(tmp[0])
		return result
	
	
	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result
	
