#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for limit provider.
"""

from models.base import ModelBase

class Limitter(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Limitter"
	__SQL__ = {\
"SELECT_PREFS": """\
SELECT
  `owner_id`,
  `key`,
  `value`,
  `marshal`
  FROM `ft_prefs`
  WHERE
    `owner_id` IN (0, valid_user_company(%s, %s, %s));""",\
"LMT_LEN_ACCOUNT": """\
SELECT
  COUNT(`P`.`id`)
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `P`.`group_id` = `G`.`id`
  INNER JOIN `mt_user_companies` AS `C`
    ON `G`.`company_id` = `C`.`id`
  WHERE
    `C`.`is_enabled`<>FALSE
    AND `G`.`is_enabled`<>FALSE
    AND `P`.`is_enabled`<>FALSE
    AND `C`.`id` = valid_user_company(%s, %s, %s);
""",\
"LMT_LEN_OBJECTS": """\
SELECT
  COUNT(`id`)
  FROM `%s`
  WHERE
    `is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"LMT_LEN_SKILL": """\
SELECT
  COUNT(`id`)
  FROM `mt_skills`
  WHERE
    `is_enabled`<>FALSE
    AND `owner_company_id` = valid_user_company(%s, %s, %s);""",\
"enum_users": """SELECT
  `P`.`id`,
  `G`.`id`,
  `G`.`name`,
  `P`.`login_id`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  WHERE `P`.`id` IN (%s);""",\
"count_LMT_LEN_ACCOUNT": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  COUNT(`P`.`id`)
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  INNER JOIN `mt_user_companies` AS `C`
    ON `C`.`id` = `G`.`company_id`
  WHERE
    `P`.`is_enabled`
    AND `G`.`is_enabled`=TRUE
    AND `C`.`is_enabled`=TRUE
    AND `C`.`id` = valid_user_company(@var_prefix, @var_login_id, @var_credential)
  GROUP BY `C`.`id`;
"""),\
"count_LMT_SIZE_STORAGE": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  SUM(`T`.`size`)
  FROM `ft_binaries` AS `T`
  WHERE
    `T`.`is_enabled`=TRUE
    /*AND `T`.`is_temp`=FALSE*/
    AND valid_acl(@var_prefix, @var_login_id, `T`.`creator_id`, NULL);
"""),\
"count_LMT_LEN_CLIENT": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  COUNT(`T`.`id`)
  FROM `mt_clients` AS `T`
  WHERE
    `T`.`is_enabled`=TRUE
    AND valid_acl(@var_prefix, @var_login_id, `T`.`creator_id`, `T`.`modifier_id`);
"""),\
"count_LMT_LEN_ENGINEER": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  COUNT(`T`.`id`)
  FROM `mt_engineers` AS `T`
  WHERE
    `T`.`is_enabled`=TRUE
    AND valid_acl(@var_prefix, @var_login_id, `T`.`creator_id`, `T`.`modifier_id`);
"""),\
"count_LMT_LEN_PROJECT": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  COUNT(`T`.`id`)
  FROM `mt_projects` AS `T`
  WHERE
    `T`.`is_enabled`=TRUE
    AND valid_acl(@var_prefix, @var_login_id, `T`.`creator_id`, `T`.`modifier_id`);
"""),\
"count_LMT_LEN_MAIL_TPL": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  COUNT(`T`.`id`)
  FROM `ft_mail_templates` AS `T`
  WHERE
    `T`.`is_enabled`=TRUE
    AND valid_acl(@var_prefix, @var_login_id, `T`.`creator_id`, `T`.`modifier_id`);
"""),\
"count_LMT_LEN_MAIL_PER_DAY": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  COUNT(1)
  FROM `ft_mail_queue` AS `T`
  INNER JOIN `ft_mails` AS `M`
    ON `M`.`id` = `T`.`request_id`
  WHERE
    `M`.`is_enabled`=TRUE
    AND `T`.`seq_no` IS NOT NULL
    AND valid_acl(@var_prefix, @var_login_id, `M`.`creator_id`, NULL)
    AND (`T`.`dt_created` BETWEEN DATE_ADD(CURRENT_TIMESTAMP, INTERVAL -1 DAY) AND CURRENT_TIMESTAMP);
"""),\
"count_LMT_LEN_MAIL_PER_MONTH": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SELECT
  COUNT(1)
  FROM `ft_mail_queue` AS `T`
  INNER JOIN `ft_mails` AS `M`
    ON `M`.`id` = `T`.`request_id`
  WHERE
    `M`.`is_enabled`=TRUE
    AND `T`.`seq_no` IS NOT NULL
    AND valid_acl(@var_prefix, @var_login_id, `M`.`creator_id`, NULL)
    AND (`T`.`dt_created` BETWEEN DATE_ADD(CURRENT_TIMESTAMP, INTERVAL -1 MONTH) AND CURRENT_TIMESTAMP);
"""),\
"count_LMT_CALL_MAP_EXTERN_M": (\
"""SET @var_prefix=%s;""",\
"""SET @var_login_id=%s;""",\
"""SET @var_credential=%s;""",\
"""SET @var_prod_level=%s;""",\
"""SELECT
  COUNT(1)
  FROM `ft_map_api_called`
  WHERE
    `prefix` = @var_prefix
    AND `prod_level` = @var_prod_level
    AND (`called_ts` BETWEEN DATE_FORMAT(CURRENT_DATE ,'%Y-%m-01 00:00:00') AND DATE_FORMAT(LAST_DAY(CURRENT_DATE), '%Y/%m/%d 23:59:59'));
"""),\
"count_ALL_from_CAPREC": """\
SELECT
  `owner_id`,
  `key`,
  `value_cap`,
  `value_rec`
  FROM `ft_cap_rec`
  WHERE
    `owner_id` = valid_user_company(%(prefix)s, %(login_id)s, %(credential)s);""",\
"read_mail_signature": """\
SELECT
  `signature`,
  `flg_show_help`,
  `row_length`
  FROM `mt_user_persons`
  WHERE
    `is_enabled` = TRUE
    AND `is_locked` = FALSE
    AND `login_id` = %s
    AND `credential` = %s;""",\
"last_insert_id": """SELECT LAST_INSERT_ID();"""\
	}
	__RULE__ = {\
		"": {\
			
		}\
	}
	
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
