#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for seudo-file object.
"""

from models.base import ModelBase

class Negotiation(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Negotiation"
	__SQL__ = {\
"enum_negotiations": """\
SELECT
  `N`.`id`,
  `N`.`client_id`,
  `N`.`client_name`,
  `N`.`name`,
  `N`.`charging_user_id`,
  `N`.`business_type`,
  `N`.`phase`,
  `N`.`status`,
  `N`.`creator_id`,
  `N`.`modifier_id`,
  `N`.`dt_created`,
  `N`.`dt_modified`,
  `N`.`note`,
  `C`.`name`,
  `N`.`dt_negotiation`
  FROM `ft_negotiations` AS `N`
  LEFT JOIN `mt_clients` AS `C`
    ON `N`.`client_id` = `C`.`id`
  WHERE
    `N`.`is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `N`.`creator_id`, `N`.`modifier_id`)
    AND (
      valid_acl(%%s, %%s, `C`.`creator_id`, `C`.`modifier_id`)
      OR `N`.`client_id` IS NULL
    )
    AND valid_user_id_read(%%s, %%s, %%s)
    %s
  ORDER BY %s;""",\
"enum_negotiations_for_reminder": """\
SELECT
  `N`.`id`,
  `N`.`client_id`,
  `N`.`client_name`,
  `N`.`name`,
  /*`N`.`charging_user_id`,*/
  `P`.`name`,
  `N`.`business_type`,
  `N`.`phase`,
  `N`.`status`,
  `N`.`creator_id`,
  `N`.`modifier_id`,
  `N`.`dt_created`,
  `N`.`dt_modified`,
  `N`.`note`,
  `C`.`name`,
  `N`.`dt_negotiation`
  FROM `ft_negotiations` AS `N`
  LEFT JOIN `mt_clients` AS `C`
    ON `N`.`client_id` = `C`.`id`
  LEFT JOIN `mt_user_persons` AS `P`
    ON `P`.`id` = `N`.`charging_user_id`
  WHERE
    `N`.`is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `N`.`creator_id`, `N`.`modifier_id`)
    AND (
      valid_acl(%%s, %%s, `C`.`creator_id`, `C`.`modifier_id`)
      OR `N`.`client_id` IS NULL
    )
    AND valid_user_id_read(%%s, %%s, %%s)
    %s
  ORDER BY %s;""",\
"enum_clients": """\
SELECT
  `id`,
  `name`,
  `kana`,
  `tel`,
  `fax`,
  `site`,
  `type_presentation`,
  `type_dealing`
  FROM `mt_clients`
  WHERE
    `id` IN (%s)
    AND `is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_read(%%s, %%s, %%s);""",\
"create_negotiation": """\
INSERT INTO `ft_negotiations` (
  `client_id`,
  `client_name`,
  `name`,
  `charging_user_id`,
  `business_type`,
  `phase`,
  `status`,
  `note`,
  `creator_id`,
  `dt_negotiation`) VALUES (
  %s,
  %s,
  %s,
  (
    SELECT
      `id`
      FROM `mt_user_persons`
      WHERE
        `is_enabled`<>FALSE
        AND `id` = %s
        AND valid_company(%s, %s, `id`)
  ),
  %s,
  %s,
  %s,
  %s,
  valid_user_id_full(%s, %s, %s),
  %s);""",\
"update_negotiation": """\
UPDATE `ft_negotiations`
  SET
    `modifier_id`=valid_user_id_full(%%s, %%s, %%s),
    `charging_user_id`=COALESCE(
      (
        SELECT
          `P`.`id`
          FROM `mt_user_persons` AS `P`
          INNER JOIN `mt_user_groups` AS `G`
            ON `P`.`group_id` = `G`.`id`
          INNER JOIN `mt_user_companies` AS `C`
            ON `G`.`company_id` = `C`.`id`
          WHERE
            `P`.`login_id` = %%s
            AND valid_user_id_full(%%s, %%s, %%s) = valid_user_id_full(`C`.`prefix`, `P`.`login_id`, `P`.`credential`)
      ), %%s, `charging_user_id`),
    %s
  WHERE
    `id`=%%s
    AND `is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_negotiation": """\
UPDATE `ft_negotiations` SET
  `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"enum_users_for_mail": """\
SELECT
  `P`.`id`,
  `P`.`name`,
  `P`.`mail1`
  FROM `mt_user_persons` AS `P`
  WHERE
    `P`.`id` IN (%s)
    AND `P`.`is_locked` <> TRUE
    AND `P`.`is_enabled` = TRUE;
""",\
"enum_users": """SELECT
  `P`.`id`,
  `G`.`id`,
  `G`.`name`,
  `P`.`login_id`,
  `P`.`name`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  WHERE `P`.`id` IN (%s);""",\
"last_insert_id": """SELECT LAST_INSERT_ID();"""\
	}
	__RULE__ = {\
		"create_client_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='kana']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "[0-9]{7}"},\
			"hashmap/string[@name='addr1']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='addr2']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='tel']": {"type": "string", "need": True, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='fax']": {"type": "string", "need": True, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='site']": {"type": "string", "need": True, "nullable": False, "max": 128,\
				"restrict": "(http|https)\://[a-z0-9\^_~\.\-/]*"},\
			"hashmap/array[@name='type_presentation']": {"type": "array", "need": True, "nullable": False,\
				"generic": "string"},\
			"hashmap/array[@name='type_presentation']/string": {"type": "string", "nullable": False,\
				"candidates": (u"案件", u"人材")},\
			"hashmap/string[@name='type_dealing']": {"type": "string", "need": True, "nullable": False,\
				"candidates": (u"重要客", u"通常客", u"低ポテンシャル", u"取引停止")},\
			"hashmap/string[@name='note']": {"type": "string", "need": True, "nullable": False}\
		},\
		"create_client_out": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": True, "min": 1}\
		},\
		"create_worker_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='client_id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False, "max": 16},\
			"hashmap/string[@name='kana']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='section']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='title']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='tel']": {"type": "string", "need": True, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='mail1']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "[a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+"},\
			"hashmap/string[@name='mail2']": {"type": "string", "need": True, "nullable": True,\
				"restrict": "([a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+)?"},\
			"hashmap/boolean[@name='flg_keyperson']": {"type": "boolean", "need": True, "nullable": False},\
			"hashmap/boolean[@name='flg_sendmail']": {"type": "boolean", "need": True, "nullable": False},\
			"hashmap/string[@name='charging_user_login_id']": {"type": "string", "need": False, "nullable": True,\
				"restrict": "[a-zA-Z0-9\!\@\-\_\~\.\%\&\^\*\?]+"}\
		},\
		"create_worker_out": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": True, "min": 1}\
		},\
		"send_reminder_mail_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='negotiationId']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/array[@name='recipientIdList']": {"type": "array", "need": True, "nullable": False, "generic": "number"},\
		},\
	}
	
	@classmethod
	def __cvt_enum_negotiations(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['client'] = {"id": res[1], "name": res[13]}
			tmp['client_name'] = res[2]
			tmp['name'] = res[3]
			tmp['charging_user'] = {"id": res[4]}
			tmp['business_type'] = res[5]
			tmp['phase'] = res[6]
			tmp['status'] = res[7]
			tmp['creator'] = {"id": res[8]}
			tmp['modifier'] = {"id": res[9]}
			tmp['dt_created'] = res[10].strftime("%Y/%m/%d %H:%M:%S") if res[10] else None
			tmp['dt_modified'] = res[11].strftime("%Y/%m/%d %H:%M:%S") if res[11] else None
			tmp['note'] = res[12] or ""
			tmp['dt_negotiation'] = res[14].strftime("%Y/%m/%d") if res[14] else None
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_negotiations_for_reminder(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['client'] = {"id": res[1], "name": res[13]}
			tmp['client_name'] = res[2]
			tmp['name'] = res[3]
			tmp['charging_user'] = {"name": res[4]}
			tmp['business_type'] = res[5]
			tmp['phase'] = res[6]
			tmp['status'] = res[7]
			tmp['creator'] = {"id": res[8]}
			tmp['modifier'] = {"id": res[9]}
			tmp['dt_created'] = res[10].strftime("%Y/%m/%d %H:%M:%S") if res[10] else None
			tmp['dt_modified'] = res[11].strftime("%Y/%m/%d %H:%M:%S") if res[11] else None
			tmp['note'] = res[12] or ""
			tmp['dt_negotiation'] = res[14].strftime("%Y/%m/%d") if res[14] else None
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_clients(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['name'] = res[1]
			tmp['kana'] = res[2]
			tmp['tel'] = res[3]
			tmp['fax'] = res[4]
			tmp['site'] = res[5]
			tmp['type_presentation'] = res[6].split(",") if res[6] else []
			tmp['type_dealing'] = res[7]
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_users_for_mail(cls, cur):
		result = []
		for row in cur:
			result.append({"id": row[0], "name": row[1], "mail": row[2]})
		return result
	
	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "group_id": res[1], "group_name": res[2], "login_id": res[3], "user_name": res[4]})
		return result
	
	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result
	
