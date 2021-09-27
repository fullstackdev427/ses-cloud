#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from models.base import ModelBase

class Skill(ModelBase):

	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""

	__class_name__ = "Skill"
	__SQL__ = {\
"enum_skills": """SELECT `MT`.`id`, `MT`.`name`, `MTC`.`name` FROM `mt_skills` AS `MT` LEFT OUTER JOIN mt_skill_categories AS `MTC` ON `MT`.category_id = `MTC`.id WHERE `MT`.`is_enabled`=1 ORDER BY %s;""",\
"search_skill": """SELECT `id`, `name` FROM `mt_skills` WHERE `owner_company_id` = valid_user_company(%s, %s, %s) AND `name` LIKE %s;""",\
"create_skill": """INSERT INTO `mt_skills` (`name`, `owner_company_id`) VALUES (%s, valid_user_company(%s, %s, %s));""",\
"last_insert_id": """SELECT LAST_INSERT_ID();""", \
"enum_skill_levels": """SELECT `MT`.`id`, `MT`.`level`, `MT`.`name` FROM `mt_skill_levels` AS `MT` ORDER BY `MT`.`level`;""", \
 \
		}
	__RULE__ = {\
		"enum_skills": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": True}\
			},\
		"search_skill": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": True},\
			"hashmap/string[@name='partial']": {"type": "string", "need": True, "nullable": True, "min": 0}\
		},\
		"create_skill": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='names']": {"type": "array", "need": True, "nullable": False, "generic": "string"},\
			"hashmap/array[@name='names']/string": {"type": "string", "need": True, "nullable": False, "min": 1}\
		}\
	}

	@classmethod
	def __cvt_enum_skills(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {"id": res[0], "name": res[1], "category_name": res[2]}
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_search_skill(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj = {"id": res[0], "name": res[1]}
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_create_skill(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result

	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result

	@classmethod
	def __cvt_enum_skill_levels(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {"id": res[0], "level": res[1], "name": res[2]}
			result.append(tmp_obj)
		return result
