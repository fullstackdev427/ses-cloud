#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for seudo-file object.
"""

import email.utils
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

class Mail(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Mail"
	__SQL__ = {\
"enum_mail_template": """SELECT
     `D`.`id`,
     `D`.`name`,
     `D`.`subject`,
     `D`.`body`,
     `D`.`type_recipient`,
     `D`.`type_iterator`,
     `D`.`creator_id`,
     `D`.`modifier_id`,
     `D`.`dt_created`,
     `D`.`dt_modified`
FROM
    `ft_mail_templates` AS `D`
    INNER JOIN
    (SELECT DISTINCT
          `C`.`id` AS `OBJ_CID`,`T`.`id`
     FROM
          `mt_user_persons` AS `P` INNER JOIN `mt_user_groups`    AS `G` ON `P`.`group_id`   = `G`.`id`
                                   INNER JOIN `mt_user_companies` AS `C` ON `G`.`company_id` = `C`.`id`
                                   INNER JOIN `ft_mail_templates` AS `T` ON `P`.`id` = `T`.`creator_id` OR
                                                                            `P`.`id` = `T`.`modifier_id`
     WHERE
          `C`.`is_enabled` <> FALSE
    ) AS `OC` ON `D`.`id` = `OC`.`id`
    INNER JOIN (SELECT valid_user_id_read(%s, %s, %s) AS pid) AS vsir ON vsir.pid <> 0
    INNER JOIN
    (SELECT
          `C`.`id` AS `USER_CID`
     FROM
          `mt_user_persons` AS P INNER JOIN `mt_user_groups`    AS `G` ON `P`.`group_id`   = `G`.`id`
                                 INNER JOIN `mt_user_companies` AS `C` ON `G`.`company_id` = `C`.`id`
     WHERE
          (`C`.`prefix` = %s AND `P`.`login_id` = %s) AND
          `C`.`is_enabled` <> FALSE
    ) AS `UC` ON `OC`.`OBJ_CID` = `UC`.`USER_CID`
WHERE
     `D`.`is_enabled` <> FALSE
ORDER BY `type_recipient`+0 ASC, COALESCE(`dt_modified`, `dt_created`) DESC;""",\
"create_mail_template": """\
INSERT INTO `ft_mail_templates` (
  `name`,
  `subject`,
  `body`,
  `type_recipient`,
  `type_iterator`,
  `creator_id`) VALUES (
  %s,
  %s,
  %s,
  %s,
  %s,
  valid_user_id_full(%s, %s, %s));""",\
"update_mail_template": """\
UPDATE `ft_mail_templates`
  SET
    `dt_modified` = NOW(),
    `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id` = %%s
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_mail_template": u"""\
UPDATE `ft_mail_templates` SET
  `is_enabled`=FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND `type_recipient` IN ('取引先担当者', '技術者')
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"enum_attachments": """\
SELECT
  `X`.`key_id`,
  `B`.`id`,
  `B`.`type_mime`,
  `B`.`name`,
  `B`.`size`,
  `B`.`digest`,
  `B`.`dt_created`
  FROM `%s` AS `X`
  INNER JOIN `ft_binaries` AS `B`
    ON `B`.`id` = `X`.`bin_id`
  WHERE
    `X`.`key_id` IN (%s)
    AND `B`.`is_enabled`<>FALSE;
""",\
"simulate_enum_templates": """\
SELECT
  `body`
  FROM `ft_mail_templates`
  WHERE
    `id`=%s
    AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
    AND valid_user_id_read(%s, %s, %s);""",\
"enum_mail_requests": """\
SELECT DISTINCT
  `R`.`id`,
  `R`.`addr_to`,
  `R`.`addr_cc`,
  `R`.`addr_bcc`,
  `R`.`type_title`,
  `R`.`subject`,
  `R`.`body`,
  `R`.`creator_id`,
  `R`.`dt_created`,
  `R`.`dt_modified`,
  `Q`.`len_msg`,
  `Q`.`len_queued`,
  `Q`.`len_finished`,
  COALESCE(GROUP_CONCAT(DISTINCT `B`.`id` ORDER BY `B`.`id` ASC SEPARATOR ', '), '') AS `attachment_id`,
  `R`.`tpl_id`,
  `TPL`.`type_recipient`,
  `TPL`.`type_iterator`,
  `R`.`id_replyto`
  FROM `ft_mails` AS `R`
  LEFT JOIN `cr_mail_bin` AS `X`
    ON `X`.`key_id` = `R`.`id`
  LEFT JOIN `ft_binaries` AS `B`
    ON `B`.`id` = `X`.`bin_id`
  LEFT JOIN (
    SELECT
      `request_id`,
      COUNT(`seq_no`) AS `len_msg`,
      COUNT(`dt_queued`) AS `len_queued`,
      COUNT(`is_processed`) AS `len_finished`
      FROM `ft_mail_queue`
      GROUP BY `request_id`
  ) AS `Q`
    ON `Q`.`request_id` = `R`.`id`
  LEFT JOIN (
    SELECT
      `id`,
      `type_recipient`,
      `type_iterator`
      FROM `ft_mail_templates`
  ) AS `TPL`
    ON `R`.`tpl_id` = `TPL`.`id`
  WHERE
    %s
    AND `R`.`is_enabled`<>FALSE
    AND `TPL`.`type_recipient` IN ('取引先担当者（既定）', '取引先担当者', '技術者（既定）', '技術者', 'リマインダー','マッチング', '見積書', '請求先注文書','注文書','請求書')
    AND valid_user_id_read(%%s, %%s, %%s)
    AND valid_acl(%%s, %%s, `R`.`creator_id`, NULL)
    AND `R`.`creator_id` = (
      SELECT `MUP`.`id`
        FROM `mt_user_persons` AS `MUP`
        INNER JOIN `mt_user_companies` AS `MUC`
          ON `MUP`.`company_id` = `MUC`.`id`
        WHERE
          `MUC`.`prefix` = %%s
          AND `MUP`.`login_id` = %%s
      LIMIT 1
    )
  GROUP BY `R`.`id`
  ORDER BY `R`.`dt_created` DESC
  %s;""",\
"enum_mail_requests_compact": """\
SELECT DISTINCT
  `R`.`id`,
  `R`.`addr_to`,
  `R`.`addr_cc`,
  `R`.`addr_bcc`,
  `R`.`type_title`,
  `R`.`subject`,
  `R`.`body`,
  `R`.`creator_id`,
  `R`.`dt_created`,
  `R`.`dt_modified`,
  COALESCE(GROUP_CONCAT(DISTINCT `B`.`id` ORDER BY `B`.`id` ASC SEPARATOR ', '), '') AS `attachment_id`,
  `R`.`tpl_id`,
  `TPL`.`type_recipient`,
  `TPL`.`type_iterator`,
  `R`.`id_replyto`
  FROM `ft_mails` AS `R` USE INDEX(si_fm_cid)
  LEFT JOIN `cr_mail_bin` AS `X`
    ON `X`.`key_id` = `R`.`id`
  LEFT JOIN `ft_binaries` AS `B`
    ON `B`.`id` = `X`.`bin_id`
  LEFT JOIN (
    SELECT
      `id`,
      `type_recipient`,
      `type_iterator`
      FROM `ft_mail_templates`
  ) AS `TPL`
    ON `R`.`tpl_id` = `TPL`.`id`
  INNER JOIN (
    SELECT valid_user_id_read(%%s, %%s, %%s) AS pid
  ) AS vsir 
    ON vsir.pid <> 0
  INNER JOIN (
    SELECT DISTINCT
    `C`.`id` AS `OBJ_CID`,`M`.`id`
    FROM
    `mt_user_persons` AS `P` 
    INNER JOIN `mt_user_groups` AS `G` 
      ON `P`.`group_id` = `G`.`id`
    INNER JOIN `mt_user_companies` AS `C`
      ON `G`.`company_id` = `C`.`id`
    INNER JOIN `ft_mails` AS `M` 
      ON `P`.`id` = `M`.`creator_id`
    WHERE
    `C`.`is_enabled` <> FALSE
  ) AS `OC` 
    ON `R`.`id` = `OC`.`id`
  INNER JOIN (
    SELECT `C`.`id` AS `USER_CID`
    FROM
    `mt_user_persons` AS P 
    INNER JOIN `mt_user_groups` AS `G` 
      ON `P`.`group_id` = `G`.`id`
    INNER JOIN `mt_user_companies` AS `C` 
      ON `G`.`company_id` = `C`.`id`
    WHERE `C`.`prefix` = %%s
    AND `P`.`login_id` = %%s
    AND `C`.`is_enabled` <> FALSE
  ) AS `UC` 
    ON `OC`.`OBJ_CID` = `UC`.`USER_CID`
  WHERE
    %s
    AND `R`.`is_enabled` = TRUE
    AND `TPL`.`type_recipient` IN ('取引先担当者（既定）', '取引先担当者', '技術者（既定）', '技術者', 'リマインダー','マッチング', '見積書', '請求先注文書','注文書','請求書')
    AND `R`.`creator_id` = (
      SELECT `MUP`.`id`
        FROM `mt_user_persons` AS `MUP`
        INNER JOIN `mt_user_companies` AS `MUC`
          ON `MUP`.`company_id` = `MUC`.`id`
        WHERE
          `MUC`.`prefix` = %%s
          AND `MUP`.`login_id` = %%s
      LIMIT 1
    )
  GROUP BY `R`.`id`
  ORDER BY `R`.`dt_created` DESC
  %s;""",\
"send_mail_request": """\
INSERT INTO `ft_mails` (
  `addr_to`,
  `addr_cc`,
  `addr_bcc`,
  `id_replyto`,
  `type_title`,
  `tpl_id`,
  `subject`,
  `body`,
  `creator_id` ) VALUES (
  %s,
  %s,
  %s,
  %s,
  %s,
  %s,
  %s,
  %s,
  valid_user_id_full(%s, %s, %s));""",\
"send_mail_request_insert_attachments": """\
INSERT INTO `cr_mail_bin`
  SELECT
    %%s,
    `id`
    FROM `ft_binaries`
    WHERE
      `is_enabled`<>FALSE
      AND `id` IN (%s)
      AND valid_acl(%%s, %%s, `creator_id`, NULL);""",\
"send_mail_request_update_attachments": """\
UPDATE `ft_binaries`
  SET `is_temp` = TRUE
  WHERE
    `is_enabled`<>FALSE
    AND `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, NULL)
    AND valid_user_id_full(%%s, %%s, %%s);""",\
"gen_mail_messages_enum_mail_req": """\
SELECT
     `M`.`id`,
     `M`.`addr_to`,
     `M`.`addr_cc`,
     `M`.`addr_bcc`,
     `M`.`type_title`,
     `M`.`subject`,
     `M`.`body`,
     `B`.`id`,
     `B`.`type_mime`,
     `B`.`name`,
     `B`.`value`,
     `M`.`tpl_id`,
     `TPL`.`type_recipient`,
     `M`.`id_replyto`
FROM
     `ft_mails` AS `M` INNER JOIN `ft_mail_templates` AS `TPL` ON `TPL`.`id`   = `M`.`tpl_id`
                       LEFT  JOIN `cr_mail_bin`       AS `X`   ON `X`.`key_id` = `M`.`id`
                       LEFT JOIN `ft_binaries`       AS `B`   ON `B`.`id`     = `X`.`bin_id`
WHERE
     `M`.`id` = %s;""",\
"gen_mail_messages_insert_mail_msg": """\
INSERT INTO `ft_mail_queue` (
  `request_id`,
  `seq_no`,
  `addr_to`,
  `subject`,
  `body`,
  `sig_generator`
) VALUES (
    %s,
    %s,
    %s,
    %s,
    %s,
    %s
);""",\
"send_messages_enum_msg": """\
SELECT
  `seq_no`,
  `body`
  FROM `ft_mail_queue`
  WHERE
    `request_id` = %s
    AND `smtp_dsn_code` IS NULL;""",\
"enum_users": """\
SELECT
  `P`.`id`,
  `G`.`id`,
  `G`.`name`,
  `P`.`login_id`,
  `P`.`name`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  WHERE `P`.`id` IN (%s);""",\
"update_quotation_send_flg_estimate": """\
UPDATE `ft_quotation_history_estimate` SET `is_send` = 1 WHERE id = %s;""", \
"update_quotation_send_flg_order": """\
UPDATE `ft_quotation_history_order` SET `is_send` = 1 WHERE id = %s;""", \
"update_quotation_send_flg_invoice": """\
UPDATE `ft_quotation_history_invoice` SET `is_send` = 1 WHERE id = %s;""", \
"update_quotation_send_flg_purchase": """\
UPDATE `ft_quotation_history_purchase` SET `is_send` = 1 WHERE id = %s;""", \
"last_insert_id": """SELECT LAST_INSERT_ID();"""\
	}
	__RULE__ = {\
		"create_mail_template_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='name']" : {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='subject']" : {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='body']" : {"type": "string", "need": True, "nullable": False, "max": 512},\
			"hashmap/string[@name='type_recipient']" : {"type": "string", "need": True, "nullable": False,\
				"candidates": (u"取引先担当者", u"技術者")},\
			"hashmap/array[@name='type_iterator']" : {"type": "array", "need": True, "nullable": True,},\
			"hashmap/array[@name='type_iterator']/string": {"type": "string", "need": False, "nullable": False,\
				"candidates": (u"技術者情報", u"案件情報")},\
		},\
		"update_mail_template_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": True, "min": 1},\
			"hashmap/string[@name='name']" : {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='subject']" : {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/string[@name='body']" : {"type": "string", "need": False, "nullable": False, "max": 512},\
			"hashmap/string[@name='type_recipient']" : {"type": "string", "need": False, "nullable": False,\
				"candidates": (u"取引先担当者", u"技術者")},\
			"hashmap/array[@name='type_iterator']" : {"type": "array", "need": False, "nullable": True,},\
			"hashmap/array[@name='type_iterator']/string": {"type": "string", "need": False, "nullable": False,\
				"candidates": (u"技術者情報", u"案件情報")},\
		},\
		"delete_mail_template_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1},\
		},\
	}
	
	@classmethod
	def __cvt_enum_mail_request(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['addr_to'] = JSON.loads(res[1])
			tmp['addr_cc'] = []
			for addr in res[2].split(","):
				real_name, email_address = email.utils.parseaddr(addr.strip())
				tmp['addr_cc'].append({"name": real_name, "mail": email_address})
			tmp['addr_bcc'] = []
			for addr in res[3].split(","):
				real_name, email_address = email.utils.parseaddr(addr.strip())
				tmp['addr_bcc'].append({"name": real_name, "mail": email_address})
			tmp['type_title'] = res[4]
			tmp['subject'] = res[5]
			tmp['body'] = res[6]
			tmp['creator'] = {"id": res[7]}
			tmp['dt_created'] = res[8].strftime("%Y/%m/%d %H:%M:%S") if res[8] else None
			tmp['dt_modified'] = res[9].strftime("%Y/%m/%d %H:%M:%S") if res[9] else None
			tmp['message_length'] = {"total": res[10], "queued": res[11], "finished": res[12]}
			tmp['attachment_id'] = map(lambda x: int(x), res[13].split(", ")) if res[13] else []
			tmp['template_id'] = res[14]
			tmp['template_type_recipient'] = res[15]
			tmp['template_type_iterator'] = res[16] or []
			tmp['replyto'] = {"id": int(res[17])} if res[17] else None
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_mail_request_compact(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['addr_to'] = JSON.loads(res[1])
			tmp['addr_cc'] = []
			for addr in res[2].split(","):
				real_name, email_address = email.utils.parseaddr(addr.strip())
				tmp['addr_cc'].append({"name": real_name, "mail": email_address})
			tmp['addr_bcc'] = []
			for addr in res[3].split(","):
				real_name, email_address = email.utils.parseaddr(addr.strip())
				tmp['addr_bcc'].append({"name": real_name, "mail": email_address})
			tmp['type_title'] = res[4]
			tmp['subject'] = res[5]
			tmp['body'] = res[6]
			tmp['creator'] = {"id": res[7]}
			tmp['dt_created'] = res[8].strftime("%Y/%m/%d %H:%M:%S") if res[8] else None
			tmp['dt_modified'] = res[9].strftime("%Y/%m/%d %H:%M:%S") if res[9] else None
			#tmp['message_length'] = {"total": res[10], "queued": res[11], "finished": res[12]}
			#tmp['attachment_id'] = map(lambda x: int(x), res[13].split(", ")) if res[13] else []
			#tmp['template_id'] = res[14]
			#tmp['template_type_recipient'] = res[15]
			#tmp['template_type_iterator'] = res[16] or []
			#tmp['replyto'] = {"id": int(res[17])} if res[17] else None
			tmp['attachment_id'] = map(lambda x: int(x), res[10].split(", ")) if res[10] else []
			tmp['template_id'] = res[11]
			tmp['template_type_recipient'] = res[12]
			tmp['template_type_iterator'] = res[13] or []
			tmp['replyto'] = {"id": int(res[14])} if res[14] else None
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_mail_template(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['name'] = res[1]
			tmp['subject'] = res[2]
			tmp['body'] = res[3]
			tmp['type_recipient'] = res[4]
			tmp['type_iterator'] = res[5].split(",") if res[5] else []
			tmp['creator'] = {"id": res[6]}
			tmp['modifier'] = {"id": res[7]}
			tmp['dt_created'] = res[8].strftime("%Y/%m/%d %H:%M:%S") if res[8] else None
			tmp['dt_modified'] = res[9].strftime("%Y/%m/%d %H:%M:%S") if res[9] else None
			tmp['attachments'] = []
			result.append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_attachments(cls, cur):
		result = {}
		for res in cur:
			tmp = {}
			tmp['key_id'] = res[0]
			tmp['id'] = res[1]
			tmp['type_mime'] = res[2]
			tmp['name'] = res[3]
			tmp['size'] = res[4]
			tmp['digest'] = res[5]
			tmp['dt_created'] = res[6].strftime("%Y/%m/%d %H:%M:%S") if res[6] else None
			result.update({tmp['key_id']: []}) if tmp['key_id'] not in result else None
			result[tmp['key_id']].append(tmp)
		return result
	
	@classmethod
	def __cvt_enum_client_simple(cls, cur):
		result = {}
		for res in cur:
			tmp = {"id": res[1], "name": res[2]}
			result[res[0]] = tmp
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
	
