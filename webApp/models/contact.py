#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for contact.
"""

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

class Contact(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Contact"
	__SQL__ = {\
"inquire_commit": """\
INSERT INTO `ft_inquire_requests` (
  `credential`,
  `company_id`,
  `type_inquire`,
  `content`,
  `creator_id`) VALUES (
  %(credential)s,
  %(company_id)s,
  %(type_inquire)s,
  %(content)s,
  valid_user_id_read(%(prefix)s, %(login_id)s, %(credential)s));""",
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
],\
"last_insert_id": """SELECT LAST_INSERT_ID();"""\
	}
	__RULE__ = {\
	}
	
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
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result
