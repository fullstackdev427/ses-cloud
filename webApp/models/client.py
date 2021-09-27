#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from models.base import ModelBase

class Client(ModelBase):

	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""

	__class_name__ = "Client"
	__SQL__ = {\
"enum_clients": """SELECT
  `MCLI`.`id`,
  `MCLI`.`name`,
  `MCLI`.`kana`,
  `MCLI`.`addr_vip`,
  `MCLI`.`addr1`,
  `MCLI`.`addr2`,
  `MCLI`.`tel`,
  `MCLI`.`fax`,
  `MCLI`.`site`,
  `MCLI`.`type_presentation`,
  `MCLI`.`type_dealing`,
  `MCLI`.`charging_worker1`,
  `MCW1`.`name`,
  `MCW1`.`login_id`,
  `MCLI`.`charging_worker2`,
  `MCW2`.`name`,
  `MCW2`.`login_id`,
  `FCLN`.`note`,
  `MCLI`.`creator_id`,
  `MCLI`.`modifier_id`,
  `MCLI`.`dt_created`,
  `MCLI`.`dt_modified`,
  0,
  `MCW1`.`is_enabled`,
  `MCW2`.`is_enabled`,
  GROUP_CONCAT(`MCW3`.`id`)
  FROM `mt_clients` AS `MCLI`
  LEFT JOIN `ft_client_notes` AS `FCLN`
    ON `MCLI`.`id` = `FCLN`.`client_id`
  LEFT JOIN `mt_user_persons` AS `MCW1`
    ON `MCLI`.`charging_worker1` = `MCW1`.`id`
  LEFT JOIN `mt_user_persons` AS `MCW2`
    ON `MCLI`.`charging_worker2` = `MCW2`.`id`
  LEFT JOIN `mt_client_workers` AS `MCW3`
    ON `MCLI`.`id` = `MCW3`.`client_id`
    AND `MCW3`.`is_enabled` = TRUE
  WHERE
    `MCLI`.`is_enabled` = TRUE
    AND (
        SELECT
            `C`.`id`
            FROM `mt_user_persons` AS `P`
            INNER JOIN `mt_user_companies` AS `C`
                ON `C`.`id` = `P`.`company_id`
            WHERE
                `C`.`prefix` = %%s
                AND `P`.`login_id` = %%s
    ) = (
        SELECT
            `P`.`company_id`
            FROM `mt_user_persons` AS `P`
            WHERE `P`.`id` = `MCLI`.`creator_id`
    )
    AND (
        SELECT
            `C`.`id`
            FROM `mt_user_persons` AS `P`
            INNER JOIN `mt_user_companies` AS `C`
                ON `C`.`id` = `P`.`company_id`
            WHERE
                `C`.`prefix` = %%s AND `P`.`login_id` = %%s AND `P`.`credential` = %%s
                AND `P`.`is_locked` <> TRUE AND `P`.`is_enabled` = TRUE AND `C`.`is_enabled` = TRUE
                AND `C`.`dt_use_begin` <= NOW() AND NOW() <= COALESCE(`C`.`dt_charged_end`, NOW())
    )
    %s
  GROUP BY `MCLI`.`id`
  ORDER BY %s;""",\
"create_client": """INSERT INTO `mt_clients`
  (
    `name`, `kana`, `addr_vip`, `addr1`, `addr2`, `tel`, `fax`, `site`,
    `type_presentation`, `type_dealing`, `creator_id`, `charging_worker1`, `charging_worker2`, `owner_company_id`
  ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, valid_user_id_full(%s, %s, %s), %s, %s, valid_user_company(%s, %s, %s));""",\
"create_client_note": """INSERT INTO `ft_client_notes` VALUES (%s, %s);""",\
"update_client": """UPDATE `mt_clients` SET `modifier_id`=valid_user_id_full(%%s, %%s, %%s), %s WHERE `id`=%%s AND `is_enabled`<>FALSE AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"update_client_note": """INSERT INTO `ft_client_notes` VALUES (%s, %s) ON DUPLICATE KEY UPDATE `note`=%s;""",\
"delete_client": """UPDATE
  `mt_clients` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"enum_branches": """SELECT
  `B`.`id`,
  `B`.`client_id`,
  `B`.`name`,
  `B`.`addr_vip`,
  `B`.`addr1`,
  `B`.`addr2`,
  `B`.`tel`,
  `B`.`fax`,
  `B`.`creator_id`,
  `B`.`modifier_id`,
  `B`.`dt_created`,
  `B`.`dt_modified`,
  `C`.`name`
  FROM `mt_client_branches` AS `B`
  INNER JOIN `mt_clients` AS `C`
    ON `C`.`id` = `B`.`client_id`
  WHERE
    `B`.`is_enabled` <> FALSE
    AND valid_acl(%%s, %%s, `B`.`creator_id`, `B`.`modifier_id`)
    AND valid_acl(%%s, %%s, `C`.`creator_id`, `C`.`modifier_id`)
    AND valid_user_id_read(%%s, %%s, %%s)
    %s
  ORDER BY %s;""",\
"create_branch": """INSERT INTO `mt_client_branches`
  (`client_id`, `name`, `addr_vip`, `addr1`, `addr2`, `tel`, `fax`, `creator_id`)
  VALUES (
    (
      SELECT `id`
        FROM `mt_clients`
        WHERE `id`=%s AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
    ), %s, %s, %s, %s, %s, %s,
    (
      valid_user_id_full(%s, %s, %s)
    )
  );""",\
"update_branch": """UPDATE `mt_client_branches` SET `modifier_id`=valid_user_id_full(%%s, %%s, %%s), %s WHERE `id`=%%s AND `is_enabled`<>FALSE AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_branch": """UPDATE
  `mt_client_branches` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"enum_workers": """\
SELECT
  `W`.`id`,
  `W`.`client_id`,
  `W`.`name`,
  `W`.`kana`,
  `W`.`section`,
  `W`.`title`,
  `W`.`tel`,
  `W`.`mail1`,
  `W`.`mail2`,
  `W`.`flg_keyperson`,
  `W`.`flg_sendmail`,
  `W`.`charging_user_id`,
  `W`.`creator_id`,
  `W`.`modifier_id`,
  `W`.`dt_created`,
  `W`.`dt_modified`,
  `C`.`name`,
  `C`.`site`,
  `C`.`tel`,
  `N`.`note`,
  `C`.`type_dealing`,
  `C`.`type_presentation`,
  `W`.`tel2`,
  `W`.`recipient_priority`,
  `C`.`charging_worker1`,
  `C`.`charging_worker2`,
  COALESCE(`CN`.`note`, '')
  FROM `mt_client_workers` AS `W`
  INNER JOIN `mt_clients` AS `C`
    ON `C`.`id` = `W`.`client_id`
  LEFT JOIN `ft_client_worker_notes` AS `N`
    ON `N`.`worker_id` = `W`.`id`
  LEFT JOIN `ft_client_notes` AS `CN`
    ON `C`.`id` = `CN`.`client_id`
  WHERE
    `W`.`is_enabled` <> FALSE
    AND (
        SELECT
            `C`.`id`
            FROM `mt_user_persons` AS `P`
            INNER JOIN `mt_user_companies` AS `C`
                ON `P`.`company_id` = `C`.`id`
            WHERE
                `C`.`prefix` = %%s
                AND `P`.`login_id` = %%s
    ) = CASE WHEN(
            SELECT
                `P`.`company_id`
                FROM `mt_user_persons` AS `P`
                WHERE
                    `P`.`id` = `W`.`creator_id`
        ) = (
            SELECT
                `P`.`company_id`
                FROM `mt_user_persons` AS `P`
                WHERE
                    `P`.`id` = `C`.`creator_id`
        ) THEN (
            SELECT
                `P`.`company_id`
                FROM `mt_user_persons` AS `P`
                WHERE
                    `P`.`id` = `W`.`creator_id`
            )
        ELSE 0
    END
    AND (
        SELECT
            `C`.`id`
            FROM `mt_user_persons` AS `P`
            INNER JOIN `mt_user_companies` AS `C`
                ON `C`.`id` = `P`.`company_id`
            WHERE
                `C`.`prefix` = %%s AND `P`.`login_id` = %%s AND `P`.`credential` = %%s
                AND `P`.`is_locked` <> TRUE AND `P`.`is_enabled` = TRUE AND `C`.`is_enabled` = TRUE
                AND NOW() BETWEEN `C`.`dt_use_begin` AND COALESCE(`C`.`dt_use_end`, NOW())
    )
    %s
  ORDER BY %s;""",\
"create_worker": """\
INSERT INTO `mt_client_workers`
  (`client_id`, `name`, `kana`, `section`, `title`, `tel`, `tel2`, `mail1`, `mail2`, `flg_keyperson`, `flg_sendmail`, `charging_user_id`, `creator_id`, `recipient_priority`, `owner_company_id`)
  VALUES (
    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
    (
      SELECT
        `P`.`id`
        FROM `mt_user_persons` AS `P`
        INNER JOIN `mt_user_groups` AS `G`
          ON `P`.`group_id` = `G`.`id`
        INNER JOIN `mt_user_companies` AS `C`
          ON `G`.`company_id` = `C`.`id`
        WHERE
          `P`.`login_id` = %s
          AND `C`.`prefix` = %s
    ), valid_user_id_full(%s, %s, %s), %s, valid_user_company(%s, %s, %s)
  );""",\
"create_worker_note": """\
INSERT INTO `ft_client_worker_notes` (`worker_id`, `note`) VALUES (
  %s,
  %s) ON DUPLICATE KEY UPDATE `note` = %s;""",\
"update_worker": """UPDATE `mt_client_workers`
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
            AND `C`.`prefix` = %%s
      ), `charging_user_id`),
    %s
  WHERE
    `id`=%%s
    AND `is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_worker": """UPDATE
  `mt_client_workers` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"delete_worker_by_client_id": """UPDATE
  `mt_client_workers` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `client_id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"enum_contacts": """SELECT
  `C`.`id`, `C`.`client_id`, `C`.`subject`, `C`.`note`,
  `C`.`creator_id`,
  `U`.`name` AS `creator_name`,
  `U`.`login_id` AS `creator_login_id`,
  `U`.`group_id` AS `creator_group_id`,
  `G`.`name` AS `creator_group_name`,
  `C`.`dt_created`
  FROM `ft_client_contacts` AS `C`
  INNER JOIN `mt_user_persons` AS `U`
    ON `C`.`creator_id` = `U`.`id`
  INNER JOIN `mt_user_groups` AS `G`
    ON `U`.`group_id` = `G`.`id`
  WHERE
    `C`.`is_enabled` <> FALSE
    AND `C`.`client_id` IN (%s)
    AND valid_acl(%%s, %%s, `C`.`creator_id`, `C`.`modifier_id`)
    AND valid_user_id_read(%%s, %%s, %%s)
    %s
ORDER BY %s;""",\
"create_contact": """INSERT INTO `ft_client_contacts`
  (`client_id`, `subject`, `note`, `creator_id`) VALUES (
    (
      SELECT `id`
        FROM `mt_clients`
        WHERE `id`=%s AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
    ), %s, %s,
    (
      valid_user_id_full(%s, %s, %s)
    )
  );""",\
"delete_contact": """UPDATE
  `ft_client_contacts` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"enum_users": """\
SELECT
  `P`.`id`,
  `G`.`id`,
  `G`.`name`,
  `P`.`login_id`,
  `P`.`name`,
  `P`.`is_enabled`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  WHERE `P`.`id` IN (%s);""",\
"last_insert_id": """SELECT LAST_INSERT_ID();""",\
	}
	__RULE__ = {\
		"create_client_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='kana']": {"type": "string", "need": True, "nullable": False, "max": 128},\
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "[0-9]{7}"},\
			"hashmap/string[@name='addr1']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='addr2']": {"type": "string", "need": True, "nullable": True, "max": 64},\
			"hashmap/string[@name='tel']": {"type": "string", "need": True, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='fax']": {"type": "string", "need": True, "nullable": True, "max": 15,\
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
		"update_client_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": False, "min": 1},\

		},\
		"delete_client_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1}\
		},\
		"create_branch_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='client_id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "[0-9]{7}"},\
			"hashmap/string[@name='addr1']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='addr2']": {"type": "string", "need": True, "nullable": True, "max": 64},\
			"hashmap/string[@name='tel']": {"type": "string", "need": True, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='fax']": {"type": "string", "need": True, "nullable": True, "max": 15,\
				"restrict": "([0-9][0-9\-]+[0-9])?"}\
		},\
		"update_branch_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/string[@name='name']": {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "[0-9]{7}"},\
			"hashmap/string[@name='addr1']": {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/string[@name='addr2']": {"type": "string", "need": False, "nullable": True, "max": 64},\
			"hashmap/string[@name='tel']": {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='fax']": {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"}\
		},\
		"delete_branch_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1}\
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
			"hashmap/string[@name='tel2']": {"type": "string", "need": False, "max": 15,\
				"restrict": "([0-9][0-9\-]+[0-9])?"},\
			"hashmap/string[@name='mail1']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "[a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+"},\
			"hashmap/string[@name='mail2']": {"type": "string", "need": True, "nullable": True,\
				"restrict": "([a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+)?"},\
			"hashmap/boolean[@name='flg_keyperson']": {"type": "boolean", "need": True, "nullable": False},\
			"hashmap/boolean[@name='flg_sendmail']": {"type": "boolean", "need": True, "nullable": False},\
			# "hashmap/string[@name='charging_user_login_id']": {"type": "string", "need": False, "nullable": True,\
				# "restrict": "[a-zA-Z0-9\!\@\-\_\~\.\%\&\^\*\?]+"},\
			"hashmap/number[@name='recipient_priority']": {"type": "number", "need": True, "nullable": False, "min": 1, "max": 9},\
		},\
		"create_worker_out": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": True, "min": 1}\
		},\
		"update_worker_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/string[@name='name']": {"type": "string", "need": False, "nullable": False, "max": 16},\
			"hashmap/string[@name='kana']": {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='section']": {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/string[@name='title']": {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='tel']": {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='tel2']": {"type": "string", "need": False, "max": 15,\
				"restrict": "([0-9][0-9\-]+[0-9])?"},\
			"hashmap/string[@name='mail1']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "[a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+"},\
			"hashmap/string[@name='mail2']": {"type": "string", "need": False, "nullable": True,\
				"restrict": "([a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+)?"},\
			"hashmap/boolean[@name='flg_keyperson']": {"type": "boolean", "need": False, "nullable": False},\
			"hashmap/boolean[@name='flg_sendmail']": {"type": "boolean", "need": False, "nullable": False},\
			# "hashmap/string[@name='charging_user_login_id']": {"type": "string", "need": False, "nullable": True,\
				# "restrict": "[a-zA-Z0-9\!\@\-\_\~\.\%\&\^\*\?]+"},\
			"hashmap/number[@name='recipient_priority']": {"type": "number", "need": False, "nullable": False, "min": 1, "max": 9},\
		},\
		"delete_worker_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "nullable": False, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1}\
		},\
		"enum_contacts_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='client_id_list']": {"type": "array", "need": True, "nullable": False},\
			"hashmap/array[@name='client_id_list']/number": {"type": "number", "nullable": False, "min": 1}\
		},\
		"create_contact_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='client_id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/string[@name='subject']": {"type": "string", "need": True, "nullable": False,\
				"candidates": (u"コンタクト", u"不在")},\
			"hashmap/string[@name='note']": {"type": "string", "need": True, "nullable": False}\
		},\
		"delete_contact_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1}\
		}\
	}

	@classmethod
	def __cvt_enum_clients(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['name'] = res[1]
			tmp_obj['kana'] = res[2]
			tmp_obj['addr_vip'] = res[3][:3] + "-" + res[3][3:]
			tmp_obj['addr1'] = res[4]
			tmp_obj['addr2'] = res[5]
			tmp_obj['tel'] = res[6]
			tmp_obj['fax'] = res[7]
			tmp_obj['site'] = res[8]
			tmp_obj['type_presentation'] = tuple(res[9].split(","))
			tmp_obj['type_dealing'] = res[10]
			tmp_obj['charging_worker1'] = {"id": res[11], "name": res[12], "login_id": res[13], "is_enabled": bool(res[23])}
			tmp_obj['charging_worker2'] = {"id": res[14], "name": res[15], "login_id": res[16], "is_enabled": bool(res[24])}
			tmp_obj['note'] = res[17]
			tmp_obj['creator'] = {"id": res[18], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[19], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[20].strftime("%Y/%m/%d %H:%M:%S") if res[20] else None
			tmp_obj['dt_modified'] = res[21].strftime("%Y/%m/%d %H:%M:%S") if res[21] else None
			tmp_obj['contact_length'] = res[22]
			tmp_obj['worker_id_list'] = res[25]
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_branches(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['client_id'] = res[1]
			tmp_obj['name'] = res[2]
			tmp_obj['addr_vip'] = res[3][:3] + "-" + res[3][3:]
			tmp_obj['addr1'] = res[4]
			tmp_obj['addr2'] = res[5]
			tmp_obj['tel'] = res[6]
			tmp_obj['fax'] = res[7]
			tmp_obj['creator'] = {"id": res[8], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[9], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[10].strftime("%Y/%m/%d %H:%M:%S") if res[10] else None
			tmp_obj['dt_modified'] = res[11].strftime("%Y/%m/%d %H:%M:%S") if res[11] else None
			tmp_obj['client_name'] = res[12]
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_workers(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['client_id'] = res[1]
			tmp_obj['name'] = res[2]
			tmp_obj['kana'] = res[3]
			tmp_obj['section'] = res[4]
			tmp_obj['title'] = res[5]
			tmp_obj['tel'] = res[6]
			tmp_obj['mail1'] = res[7]
			tmp_obj['mail2'] = res[8]
			tmp_obj['flg_keyperson'] = bool(res[9])
			tmp_obj['flg_sendmail'] = bool(res[10])
			tmp_obj['charging_user'] = {"id": res[11], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['creator'] = {"id": res[12], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[13], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[14].strftime("%Y/%m/%d %H:%M:%S") if res[14] else None
			tmp_obj['dt_modified'] = res[15].strftime("%Y/%m/%d %H:%M:%S") if res[15] else None
			tmp_obj['client_name'] = res[16]
			tmp_obj['client_site'] = res[17]
			tmp_obj['client_tel'] = res[18]
			tmp_obj['note'] = res[19]
			tmp_obj['client_type_dealing'] = res[20]
			tmp_obj['client_type_presentation'] = res[21]
			tmp_obj['tel2'] = res[22]
			tmp_obj['recipient_priority'] = res[23]
			tmp_obj['client_charging_user_id_1'] = res[24]
			tmp_obj['client_charging_user_id_2'] = res[25]
			tmp_obj['client_note'] = res[26]
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_create_branch(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result

	@classmethod
	def __cvt_enum_contacts(cls, cur):
		result = {}
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['client_id'] = res[1]
			tmp_obj['subject'] = res[2]
			tmp_obj['note'] = res[3]
			tmp_obj['creator'] = {\
				"id": res[4],\
				"name": res[5],\
				"login_id": res[6],\
				"group_id": res[7],\
				"group_name": res[8],\
			}
			tmp_obj['dt_created'] = res[9].strftime("%Y/%m/%d %H:%M:%S") if res[9] else None
			if tmp_obj['client_id'] not in result:
				result[tmp_obj['client_id']] = []
			result[tmp_obj['client_id']].append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "group_id": res[1], "group_name": res[2], "login_id": res[3], "user_name": res[4], "is_enabled": bool(res[5])})
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
