#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

import copy

from models.base import ModelBase

class Manage(ModelBase):

	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""

	__class_name__ = "Manage"
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
"enum_prefs": """SELECT 
    `ft_prefs`.`owner_id`, 
    `ft_prefs`.`key`, 
    `ft_prefs`.`value`, 
    `ft_prefs`.`marshal` 
    FROM `ft_prefs` 
        INNER JOIN (
            SELECT valid_user_company(%s, %s, %s) AS owner_id
        ) AS oi
        ON `ft_prefs`.`owner_id` = `oi`.`owner_id`
    UNION
    SELECT `owner_id`, 
        `key`, 
        `value`, 
        `marshal`
    FROM `ft_prefs`  
    WHERE 
        `owner_id` = 0;""", \
"enum_prefs_by_id": """SELECT `owner_id`, `key`, `value`, `marshal` FROM `ft_prefs` WHERE `owner_id` = %s AND valid_user_company(%s, %s, %s);""", \
#"enum_user_companies": """\
#	SELECT
#	  `id`,
#	  `name`,
#	  `owner_name`,
#	  `tel`,
#	  `fax`,
#	  `addr_vip`,
#	  `addr1`,
#	  `addr2`,
#	  `prefix`,
#	  `dt_use_begin`,
#	  `dt_use_end`,
#	  `dt_charged_end`,
#	  `is_enabled`
#	  FROM `mt_user_companies`;""", \
"enum_user_companies": """\
	SELECT
	  `C`.`id`,
	  `C`.`name`,
	  `C`.`owner_name`,
	  `C`.`tel`,
	  `C`.`fax`,
	  `C`.`addr_vip`,
	  `C`.`addr1`,
	  `C`.`addr2`,
	  `C`.`prefix`,
	  `C`.`dt_use_begin`,
	  `C`.`dt_use_end`,
	  `C`.`dt_charged_end`,
	  `C`.`is_enabled`,
	  MAX(`P`.`tm_last_login`)
	  FROM `mt_user_companies` AS `C`
	  INNER JOIN `mt_user_groups` AS `G`
	  ON `G`.`company_id` = `C`.`id`
	  INNER JOIN `mt_user_persons` AS `P`
	  ON `P`.`group_id` = `G`.`id`
	  GROUP BY `C`.`id`;""", \

"enum_bp_companies": """\
	SELECT
	  `id`,
	  `name`,
	  `owner_name`,
	  `tel`,
	  `fax`,
	  `addr_vip`,
	  `addr1`,
	  `addr2`,
	  `prefix`,
	  `dt_use_begin`,
	  `dt_use_end`,
	  `dt_charged_end`,
	  `is_enabled`
	  FROM `mt_user_companies`
	  WHERE
		is_enabled = TRUE AND id in(SELECT id FROM mt_user_companies WHERE prefix = %s OR flg_public = 1)
;""", \
"enum_bp_company_users": """\
	SELECT
	  MTUC.`id`,
	  MTUC.`name`,
	  MTUC.`owner_name`,
	  MTUC.`tel`,
	  MTUC.`fax`,
	  MTUC.`addr_vip`,
	  MTUC.`addr1`,
	  MTUC.`addr2`,
	  MTUC.`prefix`,
	  MTUC.`dt_use_begin`,
	  MTUC.`dt_use_end`,
	  MTUC.`dt_charged_end`,
	  MTUC.`is_enabled`,
	  MTUP.`id`,
	  MTUP.`group_id`,
	  MTUP.`name`,
	  MTUP.`login_id`,
	  MTUP.`mail1`,
	  MTUP.`tel1`,
	  MTUP.`tel2`,
	  MTUP.`fax`,
	  MTUP.`tm_last_login`,
	  MTUP.`is_admin`,
	  MTUP.`dt_created`,
	  MTUP.`dt_modified`,
	  MTUP.`is_locked`,
	  MTUP.`is_enabled`
	  FROM `mt_user_companies` AS MTUC
	  JOIN `mt_user_persons` AS MTUP ON MTUC.id = MTUP.company_id
	  WHERE
		MTUC.is_enabled = TRUE AND MTUC.id in(SELECT id FROM mt_user_companies WHERE prefix = %s OR flg_public = 1)
;""", \
"read_mail_signature": """\
SELECT
  `signature`
  FROM `mt_user_persons`
  WHERE
    `is_enabled` = TRUE
    AND `is_locked` = FALSE
    AND `login_id` = %s
    AND `credential` = %s;""",\
"write_mail_signature": """\
UPDATE `mt_user_persons` SET
  `signature` = %s,
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `is_enabled` = TRUE
    AND `is_locked` = FALSE
    AND `login_id` = %s
    AND `credential` = %s;""",\
"write_use_help": """\
UPDATE `mt_user_persons` SET
  `flg_show_help` = %s,
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `is_enabled` = TRUE
    AND `is_locked` = FALSE
    AND `login_id` = %s
    AND `credential` = %s;""",\
"write_row_length": """\
UPDATE `mt_user_persons` SET
  `row_length` = %s,
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `is_enabled` = TRUE
    AND `is_locked` = FALSE
    AND `login_id` = %s
    AND `credential` = %s;""", \
"update_flg_public": """\
	UPDATE `mt_user_companies` SET
	  `flg_public` = %s,
	  `dt_modified` = CURRENT_TIMESTAMP
	  WHERE 
	  	`id` = valid_user_company(%s, %s, %s);""", \
"read_mail_receiver": """SELECT
  	`ft_prefs`.`owner_id`,
  	`ft_prefs`.`key`,
  	`ft_prefs`.`value`,
  	`ft_prefs`.`marshal`
  	FROM `ft_prefs`
	INNER JOIN(
		SELECT valid_user_company(%s, %s, %s) AS owner_id
	) AS oi
	ON `ft_prefs`.`owner_id` = `oi`.`owner_id`
	AND `ft_prefs`.`key` IN ('MAIL_RECEIVER_CC', 'MAIL_RECEIVER_BCC')
UNION 
  	SELECT `owner_id`,
		`key`,
		`value`,
		`marshal`
	FROM `ft_prefs`
	WHERE
    	`owner_id` = 0 
    	AND `key` IN ('MAIL_RECEIVER_CC', 'MAIL_RECEIVER_BCC');""",\
"read_mail_reply_to": """SELECT
	`ft_prefs`.`owner_id`,
	`ft_prefs`.`key`,
	`ft_prefs`.`value`,
	`ft_prefs`.`marshal`
  	FROM `ft_prefs`
	INNER JOIN(
		SELECT valid_user_company(%s, %s, %s) AS owner_id
	) AS oi
		ON `ft_prefs`.`owner_id` = `oi`.`owner_id`
    AND `ft_prefs`.`key` = 'MAIL_REPLY_TO'
UNION
    SELECT `owner_id`,
		`key`,
		`value`,
		`marshal`
  	FROM `ft_prefs`
  	WHERE `owner_id` IN = 0 
    AND `key` = 'MAIL_REPLY_TO';""",\
"write_mail_receiver": """INSERT INTO `ft_prefs` (`owner_id`, `key`, `marshal`, `value`, `dt_created`)
  VALUES (
    valid_user_company(%s, %s, %s),
    %s,
    'JSON',
    %s,
    NOW()
  )
  ON DUPLICATE KEY
    UPDATE `value`=%s, `dt_modified`=NOW();""",\
"write_mail_reply_to": """INSERT INTO `ft_prefs` (`owner_id`, `key`, `marshal`, `value`, `dt_created`)
  VALUES (
    valid_user_company(%s, %s, %s),
    %s,
    'JSON',
    %s,
    NOW()
  )
  ON DUPLICATE KEY
    UPDATE `value`=%s, `dt_modified`=NOW();""",\
"read_user_profile": """SELECT
  `C`.`id` AS `company_id`,
  `C`.`name` AS `company_name`,
  `C`.`owner_name` AS `company_owner_name`,
  `C`.`tel` AS `company_tel`,
  `C`.`fax` AS `company_fax`,
  `C`.`addr_vip` AS `company_addr_vip`,
  `C`.`addr1` AS `company_addr1`,
  `C`.`addr2` AS `company_addr2`,
  `C`.`prefix` AS `company_prefix`,
  `C`.`dt_use_begin`,
  `C`.`dt_use_end`,
  `C`.`dt_charged_end`,
  `C`.`dt_created` AS `company_dt_created`,
  `C`.`dt_modified` AS `company_dt_modified`,
  `C`.`is_admin` AS `company_is_admin`,
  `C`.`flg_public` AS `flg_public`,
  `G`.`id` AS `group_id`,
  `G`.`name` AS `group_name`,
  `G`.`dt_created` AS `group_dt_created`,
  `G`.`dt_modified` AS `group_dt_modified`,
  `P`.`id` AS `user_id`,
  `P`.`name` AS `user_name`,
  `P`.`login_id` AS `user_login_id`,
  `P`.`mail1` AS `user_mail1`,
  `P`.`tel1` AS `user_tel1`,
  `P`.`tel2` AS `user_tel2`,
  `P`.`fax` AS `user_fax`,
  `P`.`tm_last_login`,
  `P`.`is_admin`,
  `P`.`dt_created` AS `user_dt_created`,
  `P`.`dt_modified` AS `user_dt_modified`,
  `Q`.`company_seal` AS `company_seal`,
  `Q`.`company_version` AS `company_version`,
  `Q`.`bank_account1` AS `bank_account1`,
  `Q`.`bank_account2` AS `bank_account2`,
  `Q`.`estimate_charging_user_id` AS `estimate_charging_user_id`,
  `Q`.`order_charging_user_id` AS `order_charging_user_id`,
  `Q`.`purchase_charging_user_id` AS `purchase_charging_user_id`,
  `Q`.`invoice_charging_user_id` AS `invoice_charging_user_id`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `P`.`group_id` = `G`.`id`
  INNER JOIN `mt_user_companies` AS `C`
    ON `G`.`company_id` = `C`.`id`
  LEFT OUTER JOIN `mt_quotation_config` AS `Q`
    ON `Q`.company_id = `C`.`id`
  WHERE
    `P`.`is_enabled`<>FALSE AND `G`.`is_enabled`<>FALSE AND `C`.`is_enabled`<>FALSE AND `P`.`is_locked`<>TRUE
    AND `P`.`id` = valid_user_id_read(%s, %s, %s);""",\
"update_user_profile": """UPDATE `mt_user_persons`
  SET
    `dt_modified` = NOW(),
    `pwd_digest` = CASE WHEN %%s IS NOT NULL THEN MD5(%%s) ELSE `pwd_digest` END,
    `is_admin` = CASE WHEN `is_admin`=TRUE AND %%s IS NOT NULL THEN %%s ELSE `is_admin` END,
    `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id` = valid_user_id_full(%%s, %%s, %%s);""",\
"update_user_account": """UPDATE `mt_user_persons`
  SET
    `dt_modified` = NOW(),
    `pwd_digest` = CASE WHEN %%s IS NOT NULL THEN MD5(%%s) ELSE `pwd_digest` END,
    `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id` = %%s
    AND valid_company(%%s, %%s, `id`);""",\
"create_user_account": """INSERT INTO `mt_user_persons` (`company_id`, `group_id`, `name`, `login_id`, `pwd_digest`, `mail1`, `tel1`, `tel2`, `fax`, `is_admin`, `creator_id`) VALUES (
  valid_user_company(%s, %s, %s),
  (
    SELECT
      `id`
      FROM `mt_user_groups`
      WHERE `company_id` = valid_user_company(%s, %s, %s) AND `name` IS NULL
  ), %s, %s, MD5(%s), %s, %s, %s, %s, %s, valid_user_id_full(%s, %s, %s)
);""",\
"delete_user_account": """UPDATE `mt_user_persons` SET
  `is_enabled`=FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND `company_id` = valid_user_company(%%s, %%s, %%s);""",\
"unlock_user_account": """UPDATE `mt_user_persons` SET
  `is_locked`=FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = NOW()
  WHERE
    `id` IN (%s)
    AND `is_enabled` = TRUE
    AND `company_id` = valid_user_company(%%s, %%s, %%s);""", \
"create_user_company":  \
	"""INSERT INTO `mt_user_companies` (`name`, `owner_name`, `tel`, `fax`, `addr_vip`, `addr1`, `addr2`, `prefix`, `dt_use_begin`, `dt_use_end`) VALUES (
	   %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);""", \
"create_user_group": \
	"""INSERT INTO mt_user_groups (company_id) VALUES (@cid);
    """, \
"call_renew_pref": \
	"""CALL `renew_pref` (%s, %s, %s); \
    """, \
"create_admin_account": """INSERT INTO `mt_user_persons` (`company_id`, `group_id`, `name`, `login_id`, `pwd_digest`, `mail1`, `tel1`, `tel2`, `fax`, `is_admin`, `creator_id`) VALUES (
  @cid,
  @gid,
  %s, %s, MD5(%s), %s, %s, '', '', 1, valid_user_id_full(%s, %s, %s)
);""", \
"init_account_mail_template": """INSERT INTO `ft_mail_templates` (`name`, `subject`, `body`, `type_recipient`, `type_iterator`, `creator_id`, `modifier_id`)
	SELECT `name`, subject, body, type_recipient, type_iterator, @aid, @aid FROM ft_mail_templates 
	WHERE id IN ( SELECT id FROM ft_mail_templates WHERE creator_id = 0)
	;""", \
"update_user_company": """UPDATE `mt_user_companies` SET
	    `name` = %s,
	    `owner_name` = %s,
	    `tel` = %s,
	    `fax` = %s,
	    `addr_vip` = %s,
	    `addr1` = %s,
	    `addr2` = %s,
	    `prefix` = %s,
	    `dt_use_begin` = %s,
	    `dt_use_end` = %s,
	    `is_enabled` = %s,
	    `dt_modified` = NOW()
	  WHERE `id` = %s AND valid_user_id_full(%s, %s, %s);""", \
"update_user_company_cap_id": """UPDATE `ft_prefs` SET
		    `owner_id` = %s
		  WHERE `owner_id` = %s AND valid_user_id_full(%s, %s, %s);""", \
"update_user_company_cap_id_sub": """UPDATE `ft_cap_rec` SET
			`owner_id` = %s
		  WHERE `owner_id` = %s AND valid_user_id_full(%s, %s, %s);""", \
"update_pref": """UPDATE `ft_prefs` SET
			`value` = %s, `dt_modified` = now()
		  WHERE `owner_id` = %s AND `key` = %s AND valid_user_id_full(%s, %s, %s);""", \
"update_pref_sub": """UPDATE `ft_cap_rec` SET
			`value_cap` = %s
		  WHERE `owner_id` = %s AND `key` = %s AND valid_user_id_full(%s, %s, %s);""", \
"insert_mt_quotation_config": """
    INSERT INTO `mt_quotation_config` (\
    company_id, company_seal, company_version, bank_account1, bank_account2,\
     estimate_charging_user_id, order_charging_user_id, purchase_charging_user_id, invoice_charging_user_id) VALUES 
	((SELECT id FROM mt_user_companies WHERE `prefix` = %s) ,%s,%s,%s,%s,%s,%s,%s,%s);""", \
"delete_mt_quotation_config": """
	DELETE FROM `mt_quotation_config`  WHERE company_id in (SELECT id FROM mt_user_companies WHERE `prefix` = %s);""", \
"migrate_invoke": [\
	"""SELECT SHA1(UUID()) INTO @tr_id;""",\
	"""SET @prefix = %(prefix)s;""",\
	"""SET @login_id = %(login_id)s;""",\
	"""SET @credential = %(credential)s;""",\
	"""\
INSERT INTO `ft_import_requests` (
  `transaction_id`,
  `company_id`,
  `memo`,
  `creator_id`
) VALUES (
  @tr_id,
  valid_user_company(@prefix, @login_id, @credential),
  %(memo)s,
  valid_user_id_read(@prefix, @login_id, @credential)
);""",\
	"""\
INSERT INTO `cr_impreq_data_bin` (
  `impreq_id`,
  `bin_id`
) VALUES (
  @tr_id,
  %(attachment)s
);"""\
],
"migrate_invoked_tr_id": """SELECT @tr_id;""",\
"migrate_fetch_attachment": """SELECT `type_mime`, `name`, `value` FROM `ft_binaries` WHERE `id` = %(attachment_id)s;""",\
"migrate_enum_requests": """\
SELECT
  `R`.`transaction_id`,
  ELT(MAX(`R`.`status` + 0), '受理', '検証中', '検証済', '検証失敗', '本投入待機', '本投入中', 'キャンセル', '本投入済', '本投入失敗', '完了', '確認済') AS `last_status`,
  MIN(`R`.`dt_created`),
  MAX(`R`.`dt_created`),
  MAX(`R`.`dt_scheduled`),
  `R`.`creator_id`,
  `B`.`id`,
  `B`.`name`,
  `B`.`size`,
  `B`.`type_mime`,
  `P`.`name`,
  `P`.`login_id`
  FROM `ft_import_requests` AS `R`
  INNER JOIN `cr_impreq_data_bin` AS `XR`
    ON `XR`.`impreq_id` = `R`.`transaction_id`
  INNER JOIN `ft_binaries` AS `B`
    ON `XR`.`bin_id` = `B`.`id`
  LEFT JOIN `mt_user_persons` AS `P`
    ON `P`.`id` = `R`.`creator_id`
  WHERE
    `R`.`transaction_id` IN (
      SELECT DISTINCT
        `transaction_id`
        FROM `ft_import_requests`
        WHERE
          `company_id` = valid_user_company(%(prefix)s, %(login_id)s, %(credential)s)
    )
  GROUP BY `R`.`transaction_id`
  HAVING MAX(`R`.`status` + 0)
  ORDER BY MIN(`R`.`dt_created`) DESC;""",\
"migrate_enum_messages": """\
SELECT
  `R`.`transaction_id`,
  `R`.`status`,
  `R`.`memo`,
  `R`.`dt_scheduled`,
  `R`.`creator_id`,
  `P`.`name`,
  `P`.`login_id`,
  `BR`.`id`,
  `BR`.`name`,
  `BR`.`size`,
  `BR`.`type_mime`,
  `BL`.`id`,
  `BL`.`name`,
  `BL`.`size`,
  `BL`.`type_mime`,
  `R`.`dt_created`
  FROM `ft_import_requests` AS `R`
  INNER JOIN `cr_impreq_data_bin` AS `XR`
    ON `XR`.`impreq_id` = `R`.`transaction_id`
  INNER JOIN `ft_binaries` AS `BR`
    ON `XR`.`bin_id` = `BR`.`id`
  LEFT JOIN `cr_impreq_log_bin` AS `XL`
    ON `XL`.`impreq_id` = `R`.`transaction_id`
  LEFT JOIN `ft_binaries` AS `BL`
    ON `XL`.`bin_id` = `BL`.`id`
  LEFT JOIN `mt_user_persons` AS `P`
    ON `P`.`id` = `R`.`creator_id`
  WHERE
    `R`.`transaction_id` = %(transaction_id)s
    AND `R`.`company_id` = valid_user_company(%(prefix)s, %(login_id)s, %(credential)s)
  ORDER BY `R`.`dt_created` DESC, (`R`.`status` + 0) DESC;""",\
"migrate_cancel_request": u"""\
INSERT INTO `ft_import_requests` (
  `transaction_id`,
  `company_id`,
  `status`,
  `memo`,
  `creator_id`)
SELECT
  %(transaction_id)s,
  valid_user_company(%(prefix)s, %(login_id)s, %(credential)s),
  'キャンセル',
  'ユーザー操作によりキャンセルされました。',
  valid_user_id_read(%(prefix)s, %(login_id)s, %(credential)s)
  FROM `ft_import_requests`
  WHERE
    `transaction_id` = %(transaction_id)s
  GROUP BY `transaction_id`
  HAVING ELT(MAX(`status` + 0), '受理','検証中','検証済','検証失敗','本投入待機','本投入中','キャンセル','本投入済','本投入失敗','完了','確認済') IN ('受理', '検証中', '検証済', '本投入待機');""",\
"migrate_drop_tmp_tables": [\
	"""DROP TABLE `tmp_%s_mt_client_workers`;""",\
	"""DROP TABLE `tmp_%s_mt_clients`;""",\
], \
"set_last_insert_company_id": """SELECT LAST_INSERT_ID() INTO @cid;""", \
"set_last_insert_group_id": """SELECT LAST_INSERT_ID() INTO @gid;""", \
"set_last_insert_account_id": """SELECT LAST_INSERT_ID() INTO @aid;""", \
"last_insert_id": """SELECT LAST_INSERT_ID() ;""", \
"enum_new_information": """SELECT `id`, `content` FROM `ft_new_informations`;""", \
"update_new_information": """UPDATE `ft_new_informations` SET `content` = %s WHERE `id` = %s;"""\
	}
	__RULE__ = {\
		"update_user_profile_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='mail1']" : {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/string[@name='tel1']" : {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='tel2']" : {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='fax']" : {"type": "string", "need": False, "nullable": True, "max": 15,\
				"restrict": "([0-9][0-9\-]+[0-9])?"},\
			"hashmap/string[@name='password']" : {"type": "string", "need": False, "nullable": False},\
			"hashmap/boolean[@name='is_admin']" : {"type": "boolean", "need": False, "nullable": False}\
		},\
		"update_user_account_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='mail1']" : {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/string[@name='tel1']" : {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='tel2']" : {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='fax']" : {"type": "string", "need": False, "nullable": True, "max": 15,\
				"restrict": "([0-9][0-9\-]+[0-9])?"},\
			"hashmap/string[@name='password']" : {"type": "string", "need": False, "nullable": False},\
			"hashmap/boolean[@name='is_admin']" : {"type": "boolean", "need": False, "nullable": False}\
		},\
		"create_user_account_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='name']" : {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='new_login_id']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='password']": {"type": "string", "need": True, "nullable": False, "min": 8,\
				"restrict": "[0-9a-zA-Z_@!\.\-\+\/\*\=\^\~\?\'\"]+"},\
			"hashmap/string[@name='mail1']" : {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='tel1']" : {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='tel2']" : {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='fax']" : {"type": "string", "need": False, "nullable": True, "max": 15,\
				"restrict": "([0-9][0-9\-]+[0-9])?"},\
			"hashmap/boolean[@name='is_admin']" : {"type": "boolean", "need": False, "nullable": False}\
		}, \
		"update_user_company_in": { \
			"hashmap": {"type": "hashmap", "need": True, "nullable": False}, \
			"hashmap/string[@name='name']" : {"type": "string", "need": True, "nullable": False, "max": 32}, \
			"hashmap/string[@name='owner_name']": {"type": "string", "need": True, "nullable": False, "max": 32}, \
			"hashmap/string[@name='tel']": {"type": "string", "need": False, "nullable": False, "max": 15, \
											 "restrict": "[0-9][0-9\-]+[0-9]"}, \
			"hashmap/string[@name='fax']": {"type": "string", "need": False, "nullable": True, "max": 15, \
											"restrict": "([0-9][0-9\-]+[0-9])?"}, \
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": True, "nullable": False, "max": 7, \
											"restrict": "([0-9]+)"}, \
			"hashmap/string[@name='addr1']": {"type": "string", "need": True, "nullable": False, "max": 64}, \
			"hashmap/string[@name='addr2']": {"type": "string", "need": True, "nullable": False, "max": 64}, \
 \
			}, \
		"create_user_company_in": { \
			"hashmap": {"type": "hashmap", "need": True, "nullable": False}, \
			"hashmap/string[@name='name']" : {"type": "string", "need": True, "nullable": False, "max": 32}, \
			"hashmap/string[@name='owner_name']": {"type": "string", "need": True, "nullable": False, "max": 32}, \
			"hashmap/string[@name='tel']": {"type": "string", "need": False, "nullable": False, "max": 15, \
											 "restrict": "[0-9][0-9\-]+[0-9]"}, \
			"hashmap/string[@name='fax']": {"type": "string", "need": False, "nullable": True, "max": 15, \
											"restrict": "([0-9][0-9\-]+[0-9])?"}, \
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": True, "nullable": False, "max": 7, \
											"restrict": "([0-9]+)"}, \
			"hashmap/string[@name='addr1']": {"type": "string", "need": True, "nullable": False, "max": 64}, \
			"hashmap/string[@name='addr2']": {"type": "string", "need": True, "nullable": False, "max": 64}, \
			"hashmap/string[@name='admin_name']": {"type": "string", "need": True, "nullable": False, "max": 32}, \
			"hashmap/string[@name='admin__login_id']": {"type": "string", "need": True, "nullable": False, "max": 32}, \
			"hashmap/string[@name='admin_password']": {"type": "string", "need": True, "nullable": False, "min": 8, \
												 "restrict": "[0-9a-zA-Z_@!\.\-\+\/\*\=\^\~\?\'\"]+"}, \
			"hashmap/string[@name='admin_mail']": {"type": "string", "need": True, "nullable": False, "max": 64}, \
			"hashmap/string[@name='admin_tel']": {"type": "string", "need": True, "nullable": False, "max": 15, \
											 "restrict": "[0-9][0-9\-]+[0-9]"}, \
			}, \
		"update_pref_in": { \
			"hashmap": {"type": "hashmap", "need": True, "nullable": False}, \
			"hashmap/string[@name='max_account']": {"type": "number", "need": True, "nullable": False, "min": 0,
													"max": 9999, "restrict": "[0-9]+"}, \
			"hashmap/string[@name='max_client']": {"type": "number", "need": True, "nullable": False, "min": 0,
													"max": 9999, "restrict": "[0-9]+"},
			"hashmap/string[@name='max_worker']": {"type": "number", "need": True, "nullable": False, "min": 0,
													"max": 9999, "restrict": "[0-9]+"}, \
			"hashmap/string[@name='max_project']": {"type": "number", "need": True, "nullable": False, "min": 0,
													"max": 9999, "restrict": "[0-9]+"},
			"hashmap/string[@name='max_engineer']": {"type": "number", "need": True, "nullable": False, "min": 0,
													"max": 9999, "restrict": "[0-9]+"}, \
			"hashmap/string[@name='max_mail_tpl']": {"type": "number", "need": True, "nullable": False, "min": 0,
													"max": 9999, "restrict": "[0-9]+"},
			}, \
		"write_mail_receiver_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='cc']": {"type": "array", "need": True, "generic": "hashmap"},\
			"hashmap/array[@name='bcc']": {"type": "array", "need": True, "generic": "hashmap"},\
			"hashmap/array/hashmap": {"type": "hashmap", "need": False},\
			"hashmap/array/hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False},\
			"hashmap/array/hashmap/string[@name='mail']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "[a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+"},\
		},\
		"write_mail_reply_to_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/hashmap[@name='replyTo']": {"type": "array", "need": True, "generic": "hashmap"},\
			"hashmap/hashmap/string[@name='name']": {"type": "string", "need": False},\
			"hashmap/hashmap/string[@name='mail']": {"type": "string", "need": False,\
				"restrict": "[a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+"},\
		},\
		"insert_map_called_log_in": {
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='login_id']": {"type": "string", "need": True, "nullable": True, "max": 32},\
			"hashmap/string[@name='current']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='modalId']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='target_id']": {"type": "number", "need": True, "nullable": True},\
			"hashmap/string[@name='target_type']": {"type": "string", "need": True, "nullable": True, "max": 16},\
			"hashmap/string[@name='called_api']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='UA']": {"type": "string", "need": True, "nullable": False},\
			"hashmap/string[@name='request_body']": {"type": "string", "need": True, "nullable": False},\
			"hashmap/string[@name='response_body']": {"type": "string", "need": True, "nullable": True},\
			"hashmap/string[@name='api_status']": {"type": "string", "need": True, "nullable": True, "max": 5},\
			"hashmap/string[@name='credential']": {"type": "string", "need": True, "nullable": False, "max": 32},\
		},\
	}

	@classmethod
	def __cvt_enum_prefs(cls, cur):
		import json as JSON
		import xml.dom.minidom as DOM
		from providers.limitter import Limitter
		marshal_fnc = {"JSON": JSON.loads, "XML": DOM.parseString, "PLAIN": None, "PHP-EVAL": None, "PYTHON-EVAL": eval}
		raw_result = cur.fetchall()
		res_default = {}
		res_proper = {}
		res_final = Limitter.serialize_settings(raw_result)
		res_dict = {}
		for res in raw_result:
			tmp = {}
			tmp['owner_id'] = res[0]
			tmp['key'] = res[1]
			tmp['marshal'] = repr(marshal_fnc[res[3]])
			try:
				tmp['value'] = marshal_fnc[res[3]](res[2]) if callable(marshal_fnc[res[3]]) else res[2]
			except:
				tmp['value'] = res[2]
			(res_default if tmp['owner_id']==0 else res_proper)[tmp['key']] = tmp['value']
		for k in res_final:
			res_dict[k] = {"key": k, "final": res_final[k]}
		for k in res_proper:
			res_dict[k]['proper'] = res_proper[k]
		for k in res_default:
			res_dict[k]['default'] = res_default[k]
		return [res_dict[k] for k in res_dict]

	@classmethod
	def __cvt_read_user_profile(cls, cur):
		for res in cur:
			tmp = {"company": {}, "group": {}, "user": {}}
			tmp['company']['id'] = res[0]
			tmp['company']['name'] = res[1]
			tmp['company']['owner_name'] = res[2]
			tmp['company']['tel'] = res[3]
			tmp['company']['fax'] = res[4]
			tmp['company']['addr_vip'] = res[5][:3] + "-" + res[5][3:]
			tmp['company']['addr1'] = res[6]
			tmp['company']['addr2'] = res[7]
			tmp['company']['prefix'] = res[8]
			tmp['company']['dt_use_begin'] = res[9].strftime("%Y/%m/%d") if res[9] else None
			tmp['company']['dt_use_end'] = res[10].strftime("%Y/%m/%d") if res[10] else None
			tmp['company']['dt_charged_end'] = res[11].strftime("%Y/%m/%d") if res[11] else None
			tmp['company']['dt_created'] = res[12].strftime("%Y/%m/%d %H:%M:%S") if res[12] else None
			tmp['company']['dt_modified'] = res[13].strftime("%Y/%m/%d %H:%M:%S") if res[13] else None
			tmp['company']['is_admin'] = bool(res[14])
			tmp['company']['flg_public'] = res[15]
			tmp['group']['id'] = res[16]
			tmp['group']['name'] = res[17]
			tmp['group']['dt_created'] = res[18].strftime("%Y/%m/%d %H:%M:%S") if res[18] else None
			tmp['group']['dt_modified'] = res[19].strftime("%Y/%m/%d %H:%M:%S") if res[19] else None
			tmp['user']['id'] = res[20]
			tmp['user']['name'] = res[21]
			tmp['user']['login_id'] = res[22]
			tmp['user']['mail1'] = res[23]
			tmp['user']['tel1'] = res[24]
			tmp['user']['tel2'] = res[25]
			tmp['user']['fax'] = res[26]
			tmp['user']['tm_last_login'] = res[27].strftime("%Y/%m/%d %H:%M:%S") if res[27] else None
			tmp['user']['is_admin'] = bool(res[28])
			tmp['user']['dt_created'] = res[29].strftime("%Y/%m/%d %H:%M:%S") if res[29] else None
			tmp['user']['dt_modified'] = res[30].strftime("%Y/%m/%d %H:%M:%S") if res[30] else None
			tmp['company']['company_seal'] = res[31]
			tmp['company']['company_version'] = res[32]
			tmp['company']['bank_account1'] = res[33]
			tmp['company']['bank_account2'] = res[34]
			tmp['company']['estimate_charging_user_id'] = res[35]
			tmp['company']['order_charging_user_id'] = res[36]
			tmp['company']['purchase_charging_user_id'] = res[37]
			tmp['company']['invoice_charging_user_id'] = res[38]
			return tmp

	@classmethod
	def __cvt_read_mail_receiver(cls, cur):
		from providers.limitter import Limitter
		result = {"MAIL_RECEIVER_CC": [], "MAIL_RECEIVER_BCC": []}
		for res in cur:
			tmp = Limitter.serialize_settings((res,))
			result[res[1]] = tmp[res[1]] if res[1] in tmp else []
		return result

	@classmethod
	def __cvt_read_mail_reply_to(cls, cur):
		from providers.limitter import Limitter
		result = {"MAIL_REPLY_TO": None}
		for res in cur:
			tmp = Limitter.serialize_settings((res,))
			result[res[1]] = tmp[res[1]] if res[1] in tmp else []
		return result

	@classmethod
	def __cvt_read_mail_signature(cls, cur):
		result = {}
		for res in cur:
			result.update({"MAIL_SIGNATURE": res[0] or ""})
		return result

	@classmethod
	def __cvt_enum_user_accounts(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['group_id'] = res[1]
			tmp['name'] = res[2]
			tmp['login_id'] = res[3]
			tmp['mail1'] = res[4]
			tmp['tel1'] = res[5]
			tmp['tel2'] = res[6]
			tmp['fax'] = res[7]
			tmp['tm_last_login'] = res[8].strftime("%Y/%m/%d %H:%M:%S") if res[8] else None
			tmp['is_admin'] = bool(res[9])
			tmp['dt_created'] = res[10].strftime("%Y/%m/%d %H:%M:%S") if res[10] else None
			tmp['dt_modified'] = res[11].strftime("%Y/%m/%d %H:%M:%S") if res[11] else None
			tmp['is_locked'] = bool(res[12])
			tmp['is_enabled'] = bool(res[13])
			result.append(tmp)
		return result

	@classmethod
	def __cvt_enum_user_companies(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['name'] = res[1]
			tmp['owner_name'] = res[2]
			tmp['tel'] = res[3]
			tmp['fax'] = res[4]
			tmp['addr_vip'] = res[5][:3] + res[5][3:]
			tmp['addr1'] = res[6]
			tmp['addr2'] = res[7]
			tmp['prefix'] = res[8]
			tmp['dt_use_begin'] = res[9].strftime("%Y/%m/%d") if res[9] else None
			tmp['dt_use_end'] = res[10].strftime("%Y/%m/%d") if res[10] else None
			tmp['dt_charged_end'] = res[11].strftime("%Y/%m/%d") if res[11] else None
			tmp['is_enabled'] = bool(res[12])
			if res[13]:
				tmp['dt_last_login'] = res[13].strftime("%Y/%m/%d %I:%M %p")
			else:
				tmp['dt_last_login'] = ''
			result.append(tmp)
		return result

	@classmethod
	def __cvt_enum_bp_companies(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['name'] = res[1]
			tmp['owner_name'] = res[2]
			tmp['tel'] = res[3]
			tmp['fax'] = res[4]
			tmp['addr_vip'] = res[5][:3] + res[5][3:]
			tmp['addr1'] = res[6]
			tmp['addr2'] = res[7]
			tmp['prefix'] = res[8]
			tmp['dt_use_begin'] = res[9].strftime("%Y/%m/%d") if res[9] else None
			tmp['dt_use_end'] = res[10].strftime("%Y/%m/%d") if res[10] else None
			tmp['dt_charged_end'] = res[11].strftime("%Y/%m/%d") if res[11] else None
			tmp['is_enabled'] = bool(res[12])
			result.append(tmp)
		return result

	@classmethod
	def __cvt_enum_bp_company_users(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['company_id'] = res[0]
			tmp['company_name'] = res[1]
			tmp['company_owner_name'] = res[2]
			tmp['company_tel'] = res[3]
			tmp['company_fax'] = res[4]
			tmp['company_addr_vip'] = res[5][:3] + res[5][3:]
			tmp['company_addr1'] = res[6]
			tmp['company_addr2'] = res[7]
			tmp['company_prefix'] = res[8]
			tmp['company_dt_use_begin'] = res[9].strftime("%Y/%m/%d") if res[9] else None
			tmp['company_dt_use_end'] = res[10].strftime("%Y/%m/%d") if res[10] else None
			tmp['company_dt_charged_end'] = res[11].strftime("%Y/%m/%d") if res[11] else None
			tmp['company_is_enabled'] = bool(res[12])
			tmp['user_id'] = res[13]
			tmp['user_group_id'] = res[14]
			tmp['user_name'] = res[15]
			tmp['user_login_id'] = res[16]
			tmp['user_mail1'] = res[17]
			tmp['user_tel1'] = res[18]
			tmp['user_tel2'] = res[19]
			tmp['user_fax'] = res[20]
			tmp['user_tm_last_login'] = res[21].strftime("%Y/%m/%d %H:%M:%S") if res[21] else None
			tmp['user_is_admin'] = bool(res[22])
			tmp['user_dt_created'] = res[23].strftime("%Y/%m/%d %H:%M:%S") if res[23] else None
			tmp['user_dt_modified'] = res[24].strftime("%Y/%m/%d %H:%M:%S") if res[24] else None
			tmp['user_is_locked'] = bool(res[25])
			tmp['user_is_enabled'] = bool(res[26])
			result.append(tmp)
		return result

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
			tmp_obj['type_presentation'] = res[9].split(",") or []
			tmp_obj['type_dealing'] = res[10]
			tmp_obj['charging_worker1'] = {"id": res[11], "name": res[12]}
			tmp_obj['charging_worker2'] = {"id": res[13], "name": res[14]}
			tmp_obj['note'] = res[15]
			tmp_obj['creator'] = {"id": res[16], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[17], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[18].strftime("%Y/%m/%d %H:%M:%S") if res[18] else None
			tmp_obj['dt_modified'] = res[19].strftime("%Y/%m/%d %H:%M:%S") if res[19] else None
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_migrate_enum_requests(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['transaction_id'] = res[0]
			tmp_obj['last_status'] = res[1]
			tmp_obj['dt_registered'] = res[2].strftime("%Y/%m/%d %H:%M:%S")
			tmp_obj['dt_updated'] = res[3].strftime("%Y/%m/%d %H:%M:%S")
			tmp_obj['dt_scheduled'] = res[4].strftime("%Y/%m/%d %H:%M:%S") if res[4] else None
			tmp_obj['creator'] = {\
				"id": res[5],\
				"name": res[10],\
				"login_id": res[11],\
			}
			tmp_obj['attachment'] = {\
				"id": res[6],\
				"filename": res[7],\
				"size": res[8],\
				"mime": res[9],\
			}
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_migrate_enum_messages(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['transaction_id'] = res[0]
			tmp_obj['status'] = res[1]
			tmp_obj['memo'] = res[2]
			tmp_obj['dt_scheduled'] = res[3].strftime("%Y/%m/%d %H:%M:%S") if res[3] else None
			tmp_obj['creator'] = {\
				"id": res[4],\
				"name": res[5],\
				"login_id": res[6],\
			} if res[4] else {\
				"id": None,
				"name": u"システム",\
				"login_id": None,\
			}
			tmp_obj['attachment_request'] = {\
				"id": res[7],\
				"name": res[8],\
				"size": res[9],\
				"mime": res[10],\
			} if res[7] else {}
			tmp_obj['attachment_log'] = {\
				"id": res[11],\
				"name": res[12],\
				"size": res[13],\
				"mime": res[14],\
			} if res[11] else {}
			tmp_obj['dt_created'] = res[15].strftime("%Y/%m/%d %H:%M:%S")
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "group_id": res[1], "group_name": res[2], "login_id": res[3]})
		return result

	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		for res in cur:
			result['id'] = res[0] if res and res[0] > 0 else None
		return result

	@classmethod
	def __cvt_enum_new_information(cls, cur):
		result = {}
		for res in cur:
			result['id'] = res[0] if res and res[0] > 0 else None
			result['content'] = res[1] if res and res[1] else ""
		return result
