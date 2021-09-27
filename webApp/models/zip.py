#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for address searching.
"""

from models.base import ModelBase

class Zip(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Zip"
	__SQL__ = {\
"search": """\
SELECT
  `code_zip`,
  CONCAT(`code_pref`, `name`) AS `addr`
  FROM `mt_zip_codes`
  WHERE
    `code_zip` = %s;""",\
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
		
	}
	
	@classmethod
	def __cvt_search(cls, cur):
		result = {}
		for res in cur:
			result['zip_code'] = res[0]
			result['addr1'] = unicode(res[1], "utf8") if res[1] else ""
		return result or {"zip_code": None, "addr1": ""}
	
	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "group_id": res[1], "group_name": res[2], "login_id": res[3]})
		return result
	
	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result
	
