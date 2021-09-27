#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from models.base import ModelBase

class Occupation(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Occupation"
	__SQL__ = {\
"enum_occupations": """SELECT `id`, `name` FROM `mt_occupations`;""",\
"create_occupation": """INSERT INTO `mt_occupations` (`name`) VALUES (%s);""",\
"last_insert_id": """SELECT LAST_INSERT_ID();"""\
	}
	__RULE__ = {\
		"enum_occupations": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": True}\
			},\
		"create_occupation": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='names']": {"type": "array", "need": True, "nullable": False, "generic": "string"},\
			"hashmap/array[@name='names']/string": {"type": "string", "need": True, "nullable": False, "min": 1}\
		}\
	}
	
	@classmethod
	def __cvt_enum_occupations(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {"id": res[0], "name": res[1]}
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_create_occupation(cls, cur):
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
	
