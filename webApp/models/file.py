#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for seudo-file object.
"""

import cStringIO as SIO
from models.base import ModelBase

class File(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "File"
	__SQL__ = {\
"enum": """\
SELECT
  `id`,
  `type_mime`,
  `name`,
  `size`,
  `digest`,
  `creator_id`,
  `dt_created`
  FROM `ft_binaries`
  WHERE
    `is_enabled`<>FALSE
    AND valid_user_id_read(%s, %s, %s)
    AND valid_acl(%s, %s, `creator_id`, NULL);""",\
"upload": """\
INSERT INTO `ft_binaries` (
  `type_mime`,
  `name`,
  `value`,
  `size`,
  `digest`,
  `is_temp`,
  `creator_id`) VALUES (
  %s, %s,
  %s,
  %s, %s, TRUE,
  valid_user_id_full(%s, %s, %s));""",\
"rename": """\
UPDATE `ft_binaries`
  SET `name` = %s
  WHERE
    `id` = %s
    AND valid_user_id_full(%s, %s, %s);""",\
"download": """\
SELECT
  `type_mime`,
  `name`,
  `value`
  FROM `ft_binaries`
  WHERE
    `id` = %s
    AND `is_enabled`<>FALSE
    AND valid_acl(%s, %s, `creator_id`, NULL)
    AND valid_user_id_read(%s, %s, %s);""", \
"download_all": """\
SELECT
  `type_mime`,
  `name`,
  `value`
  FROM `ft_binaries`
  WHERE
	`id` = %s
	AND `is_enabled`<>FALSE;""", \
"delete": """\
UPDATE `ft_binaries` SET
  `is_enabled`=FALSE
  WHERE
    `id` IN (%s)
    AND valid_user_id_full(%s, %s, %s)
    AND valid_acl(%s, %s, `creator_id`, NULL);""",\
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
		},\
	}
	
	@classmethod
	def __cvt_enum(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['type_mime'] = res[1]
			tmp['name'] = res[2]
			tmp['size'] = res[3]
			tmp['digest'] = res[4]
			tmp['creator'] = {"id": res[5]}
			tmp['dt_created'] = res[6].strftime("%Y/%m/%d %H:%M:%S") if res[6] else None
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_download(cls, cur):
		for res in cur:
			tmp = {}
			tmp['type_mime'] = res[0]
			tmp['name'] = res[1]
			tmp['value'] = SIO.StringIO(res[2])
			return tmp
	
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
	
