#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for Miscellaneous Groupware objects.
"""

from models.base import ModelBase

class Misc(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Misc"
	__SQL__ = {\
"enum_schedules": """\
SELECT
  `id`,
  `title`,
  `note`,
  `dt_scheduled`,
  `creator_id`,
  `modifier_id`,
  `dt_created`,
  `dt_modified`
  FROM `ft_schedules`
  WHERE
    `is_enabled`<>FALSE
    AND (
      `dt_scheduled` BETWEEN DATE_ADD(CURRENT_DATE, INTERVAL %s WEEK) AND DATE_ADD(CURRENT_DATE, INTERVAL %s WEEK)
    )
    AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
    AND valid_user_id_read(%s, %s, %s)
  ORDER BY `dt_scheduled` ASC;""",\
"create_schedule": """\
INSERT INTO `ft_schedules` (
  `title`,
  `note`,
  `dt_scheduled`,
  `creator_id`) VALUES (
  %s,
  %s,
  %s,
  valid_user_id_full(%s, %s, %s));""",\
"update_schedule": """\
UPDATE `ft_schedules`
  SET
    `modifier_id`=valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id`=%%s
    AND `is_enabled`<>FALSE
    AND valid_user_id_full(%%s, %%s, %%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_schedule": """\
UPDATE `ft_schedules` SET
  `is_enabled` = FALSE,
  `dt_modified` = CURRENT_TIMESTAMP,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s)
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"enum_todos": """\
SELECT
  `id`,
  `note`,
  `priority`,
  `status`,
  `creator_id`,
  `modifier_id`,
  `dt_created`,
  `dt_modified`
  FROM `ft_todos`
  WHERE
    `is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_read(%%s, %%s, %%s) IN (`creator_id`, `modifier_id`)
    %s
  ORDER BY %s;""",\
"create_todo": """\
INSERT INTO `ft_todos` (
  `note`,
  `priority`,
  `status`,
  `creator_id`) VALUES (
  %s,
  %s,
  %s,
  valid_user_id_full(%s, %s, %s));""",\
"update_todo": """\
UPDATE `ft_todos`
  SET
    `modifier_id`=valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id`=%%s
    AND `is_enabled`<>FALSE
    AND valid_user_id_full(%%s, %%s, %%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_todo": """\
UPDATE `ft_todos` SET
  `is_enabled` = FALSE,
  `dt_modified` = CURRENT_TIMESTAMP,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s)
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
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
"last_insert_id": """SELECT LAST_INSERT_ID();""",\
	}
	__RULE__ = {\
		"enum_schedule_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='week']": {"type": "number", "need": False, "nullable": False},\
		},\
		"create_schedule_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='title']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='note']": {"type": "string", "need": True, "nullable": True},\
			"hashmap/string[@name='dt_scheduled']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:00$"},\
		},\
		"update_schedule_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/string[@name='title']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='note']": {"type": "string", "need": True, "nullable": True},\
			"hashmap/string[@name='dt_scheduled']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:00$"},\
		},\
		"create_todo_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='note']": {"type": "string", "need": True, "nullable": False},\
			"hashmap/string[@name='priority']": {"type": "string", "need": True, "nullable": False,\
				"candidates": (u"高", u"中", u"低")},\
			"hashmap/string[@name='status']": {"type": "string", "need": True, "nullable": False,\
				"candidates": (u"未完", u"完了")},\
		},\
		"update_todo_in": {\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap": {"type": "hashmap", "need": False, "nullable": False},\
			"hashmap/string[@name='note']": {"type": "string", "need": False, "nullable": False},\
			"hashmap/string[@name='priority']": {"type": "string", "need": False, "nullable": False,\
				"candidates": (u"高", u"中", u"低")},\
			"hashmap/string[@name='status']": {"type": "string", "need": False, "nullable": False,\
				"candidates": (u"未完", u"完了")},\
		},\
		"delete_schedule_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1}\
		},\
	}
	
	@classmethod
	def __cvt_enum_schedules(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['title'] = res[1]
			tmp['note'] = res[2] or ""
			tmp['dt_scheduled'] = res[3].strftime("%Y/%m/%d %H:%M:00") if res[3] else None
			tmp['creator'] = {"id": res[4]}
			tmp['modifier'] = {"id": res[5]}
			tmp['dt_created'] = res[6].strftime("%Y/%m/%d %H:%M:%S") if res[6] else None
			tmp['dt_modified'] = res[7].strftime("%Y/%m/%d %H:%M:%S") if res[7] else None
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_todos(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['note'] = res[1]
			tmp['priority'] = res[2]
			tmp['status'] = res[3]
			tmp['creator'] = {"id": res[4]}
			tmp['modifier'] = {"id": res[5]}
			tmp['dt_created'] = res[6].strftime("%Y/%m/%d %H:%M:%S") if res[6] else None
			tmp['dt_modified'] = res[7].strftime("%Y/%m/%d %H:%M:%S") if res[7] else None
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "group_id": res[1], "group_name": res[2], "login_id": res[3], "user_name": res[4]})
		return result
	
	@classmethod
	def __cvt_create_worker(cls, cur):
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
	def __cvt_create_contact(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result
