#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

import copy

from models.base import ModelBase

class Business(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Business"
	__SQL__ = {\
"enum_user_accounts": """SELECT
  `id`,
  `group_id`,
  `name`,
  `login_id`,
  `mail1`,
  `tel1`,
  `tel2`,
  `fax`,
  `tm_last_login`,
  `is_admin`,
  `dt_created`,
  `dt_modified`,
  `is_locked`,
  `is_enabled`
  FROM `mt_user_persons`
  WHERE
    valid_company(%s, %s, `id`);""",\
"enum_users": """SELECT
  `P`.`id`,
  `G`.`id`,
  `G`.`name`,
  `P`.`login_id`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  WHERE `P`.`id` IN (%s);""",\
	}
	

	

	

