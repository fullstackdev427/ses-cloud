#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from models.base import ModelBase

class Quotation(ModelBase):

	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""

	__class_name__ = "Quotation"
	__SQL__ = {\
"enum_estimates": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`
	 FROM `ft_quotation_history_estimate` AS `FQ`
	 LEFT JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT JOIN `mt_clients` AS `CL`
	 ON `FQ`.`client_id` = `CL`.`id`
	 WHERE `CL`.`is_enabled` <> FALSE
	 AND `FQ`.`is_enabled` <> FALSE
	 AND `FQ`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
	 %s ORDER BY %s
	 ;
""", \
"enum_estimates_pdf_info": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`
	 FROM `ft_quotation_history_estimate` AS `FQ`
	 LEFT JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT JOIN `mt_clients` AS `CL`
	 ON `FQ`.`client_id` = `CL`.`id`
	 WHERE `CL`.`is_enabled` <> FALSE
	 AND `FQ`.`is_enabled` <> FALSE
	 %s ORDER BY %s
	 ;
""", \
"insert_quotation_history_estimate": """
	INSERT INTO `ft_quotation_history_estimate` (
	project_id, client_id, output_val,
	creator_id,dt_created,
	owner_company_id,
	quotation_name, quotation_no,quotation_date, total_including_tax, is_view_window, is_view_excluding_tax, pdffile_path, office_memo
	) VALUES (
	%s, %s, %s,
	valid_user_id_full(%s,%s,%s), now()
	,valid_user_company(%s, %s, %s)
	,%s,%s,%s,%s,%s,%s,%s,%s
	);
""", \
"update_quotation_history_estimate": """
	UPDATE `ft_quotation_history_estimate`
	SET
	    `modifier_id`=valid_user_id_full(%%s, %%s, %%s),%s
	WHERE
	    `id`=%%s
	    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);
""", \
"enum_orders": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`
	 FROM `ft_quotation_history_order` AS `FQ`
	 LEFT JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT JOIN `mt_clients` AS `CL`
	 ON `FQ`.`client_id` = `CL`.`id`
	 WHERE `CL`.`is_enabled` <> FALSE
	 AND `FQ`.`is_enabled` <> FALSE
	 AND `FQ`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
	 %s ORDER BY %s
	 ;
""", \
"enum_orders_pdf_info": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`
	 FROM `ft_quotation_history_order` AS `FQ`
	 LEFT JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT JOIN `mt_clients` AS `CL`
	 ON `FQ`.`client_id` = `CL`.`id`
	 WHERE `CL`.`is_enabled` <> FALSE
	 AND `FQ`.`is_enabled` <> FALSE
	 %s ORDER BY %s
	;
""", \
"insert_quotation_history_order": """
	INSERT INTO `ft_quotation_history_order` (
	project_id, client_id, output_val,
	creator_id,dt_created,
	owner_company_id,
	quotation_name, quotation_no,quotation_date, total_including_tax, is_view_window, is_view_excluding_tax, pdffile_path, office_memo
	) VALUES (
	%s, %s, %s,
	valid_user_id_full(%s,%s,%s), now()
	,valid_user_company(%s, %s, %s)
	,%s,%s,%s,%s,%s,%s,%s,%s
	);
""", \
"update_quotation_history_order": """
	UPDATE `ft_quotation_history_order`
	SET
	  `modifier_id`=valid_user_id_full(%%s, %%s, %%s),%s
	WHERE
	  `id`=%%s
	  AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);
""", \
"enum_invoices": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`
	 FROM `ft_quotation_history_invoice` AS `FQ`
	 LEFT JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT JOIN `mt_clients` AS `CL`
	 ON `FQ`.`client_id` = `CL`.`id`
	 WHERE `CL`.`is_enabled` <> FALSE
	 AND `FQ`.`is_enabled` <> FALSE
	 AND `FQ`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
	 %s ORDER BY %s
	 ;
""", \
"get_invoices": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`
	 FROM `ft_quotation_history_invoice` AS `FQ`
	 LEFT JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT JOIN `mt_clients` AS `CL`
	 ON `FQ`.`client_id` = `CL`.`id`
	 WHERE `CL`.`is_enabled` <> FALSE
	 AND `FQ`.`is_enabled` <> FALSE
	 AND `FQ`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
	 %s
	 ;
""", \
"enum_invoices_pdf_info": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`
	 FROM `ft_quotation_history_invoice` AS `FQ`
	 LEFT JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT JOIN `mt_clients` AS `CL`
	 ON `FQ`.`client_id` = `CL`.`id`
	 WHERE `CL`.`is_enabled` <> FALSE
	 AND `FQ`.`is_enabled` <> FALSE
	 %s ORDER BY %s
	;
""", \
"insert_quotation_history_invoice": """
	INSERT INTO `ft_quotation_history_invoice` (
	project_id, client_id, output_val,
	creator_id,dt_created,
	owner_company_id,
	quotation_name, quotation_no,quotation_date, total_including_tax, is_view_window, is_view_excluding_tax, pdffile_path, office_memo
	) VALUES (
	%s, %s, %s,
	valid_user_id_full(%s,%s,%s), now()
	,valid_user_company(%s, %s, %s)
	,%s,%s,%s,%s,%s,%s,%s,%s
	);
""", \
"update_quotation_history_invoice": """
	UPDATE `ft_quotation_history_invoice`
	SET
	  `modifier_id`=valid_user_id_full(%%s, %%s, %%s),%s
	WHERE
	  `id`=%%s
	AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);
""", \
"enum_purchases": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`client_id`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`,
	 `FQCL`.`name`,
	 `FQUC`.`id`,
	 `FQUC`.`name`,
	 `FQ`.`addr_vip`,
	 `FQ`.`addr1`,
	 `FQ`.`addr2`,
	 `FQ`.`addr_name`,
	 `FQ`.`type_honorific`,
	 `FQ`.`engineer_id`
	 FROM `ft_quotation_history_purchase` AS `FQ`
	 LEFT OUTER JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT OUTER JOIN `mt_clients` AS `CL` ON `MT`.`client_id` = `CL`.`id`
	 LEFT OUTER JOIN `mt_clients` AS `FQCL` ON `FQ`.`client_id` = `FQCL`.`id`
	 LEFT OUTER JOIN `mt_user_companies` AS `FQUC` ON `FQ`.company_id = `FQUC`.id
	 WHERE `FQ`.`is_enabled` <> FALSE
	 AND `FQ`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
	 %s ORDER BY %s
	 ;
""", \
"enum_purchases_pdf_info": """
	SELECT
	 `FQ`.`id`,
	 `FQ`.`project_id`,
	 `FQ`.`output_val`,
	 `FQ`.`creator_id`,
	 `FQ`.`dt_created`,
	 `FQ`.`owner_company_id`,
	 `FQ`.`quotation_name`,
	 `FQ`.`quotation_no`,
	 `FQ`.`quotation_date`,
	 `FQ`.`is_enabled`,
	 `FQ`.`total_including_tax`,
	 `FQ`.`is_send`,
	 `FQ`.`modifier_id`,
	 `FQ`.`is_view_window`,
	 `FQ`.`is_view_excluding_tax`,
	 `FQ`.`client_id`,
	 `FQ`.`pdffile_path`,
	 `FQ`.`office_memo`,
	 `MT`.`title`,
	 `MT`.`charging_user_id`,
	 `CL`.`name`,
	 `FQCL`.`name`,
	 `FQUC`.`id`,
	 `FQUC`.`name`,
	 `FQ`.`addr_vip`,
	 `FQ`.`addr1`,
	 `FQ`.`addr2`,
	 `FQ`.`addr_name`,
	 `FQ`.`type_honorific`,
	 `FQ`.`engineer_id`
	 FROM `ft_quotation_history_purchase` AS `FQ`
	 LEFT OUTER JOIN `mt_projects` AS `MT` ON `FQ`.project_id = `MT`.id
	 LEFT OUTER JOIN `mt_clients` AS `CL` ON `MT`.`client_id` = `CL`.`id`
	 LEFT OUTER JOIN `mt_clients` AS `FQCL` ON `FQ`.`client_id` = `FQCL`.`id`
	 LEFT OUTER JOIN `mt_user_companies` AS `FQUC` ON `FQ`.company_id = `FQUC`.id
	 WHERE `FQ`.`is_enabled` <> FALSE
	 %s ORDER BY %s
	 ;
""", \
"insert_quotation_history_purchase": """
	INSERT INTO `ft_quotation_history_purchase` (
	project_id, output_val,
	creator_id,dt_created,
	owner_company_id,
	quotation_name, quotation_no, quotation_date, total_including_tax, is_view_window, is_view_excluding_tax, client_id, pdffile_path, company_id, office_memo,
	addr_vip, addr1, addr2, addr_name, type_honorific, engineer_id
	) VALUES (
	%s, %s,
	valid_user_id_full(%s, %s, %s), now()
	,valid_user_company(%s, %s, %s)
	,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s
	,%s,%s,%s,%s,%s,%s
	);
""", \
"update_quotation_history_purchase": """
	UPDATE `ft_quotation_history_purchase`
	SET
	  `modifier_id`=valid_user_id_full(%%s, %%s, %%s),%s
	WHERE
	  `id`=%%s
	AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);
""", \
"last_quotation_no_estimate": """SELECT COUNT(id) + 1 as id FROM ft_quotation_history_estimate WHERE owner_company_id = valid_user_company(%s, %s, %s);""", \
"last_quotation_no_order": """SELECT COUNT(id) + 1 as id FROM ft_quotation_history_order WHERE owner_company_id = valid_user_company(%s, %s, %s);""", \
"last_quotation_no_invoice": """SELECT COUNT(id) + 1 as id FROM ft_quotation_history_invoice WHERE owner_company_id = valid_user_company(%s, %s, %s);""", \
"last_quotation_no_purchase": """SELECT COUNT(id) + 1 as id FROM ft_quotation_history_purchase WHERE owner_company_id = valid_user_company(%s, %s, %s);""", \
"last_insert_id": """SELECT LAST_INSERT_ID();"""\
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
	def __cvt_enum_estimates(cls, cur):
		import locale
		import json
		locale.setlocale(locale.LC_NUMERIC, 'ja_JP')
		locale.setlocale(locale.LC_MONETARY, 'en_US')
		result = []
		for res in cur:
			tmp_obj = {
				"id": res[0],
				"project_id": res[1],
				"output_val": res[2],
				"creator" : {"id": res[3]},
				"dt_created": res[4].strftime("%Y/%m/%d %H:%M:%S") if res[4] else None,
				"owner_company_id": res[5],
				"quotation_name": res[6],
				"quotation_no": res[7],
				"quotation_date": res[8].strftime("%Y/%m") if res[8] else None,
				"is_enabled": bool(res[9]),
				"total_including_tax": res[10],
				"total_including_tax_view":  locale.format('%d', res[10], True),
				"is_send": bool(res[11]),
				"modifier": {"id": res[12]},
				"is_view_window": bool(res[13]),
				"is_view_excluding_tax": bool(res[14]),
				"pdffile_path": res[15],
				"office_memo": res[16],
				"project_title": res[17],
				"charging_user": {"id": res[18]},
				"client_name": res[19],
			}
			subtotal = 0
			output_val = json.loads(res[2])
			if 'output' in output_val:
				rows = output_val["output"]["rows"]
				for row in rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
					if row.get("subtotal_1"):
						subtotal += int(row["subtotal_1"].replace(',', ''))
					if row.get("subtotal_2"):
						subtotal += int(row["subtotal_2"].replace(',', ''))

				free_rows = output_val["output"]["free_rows"]
				for row in free_rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
				tmp_obj["subtotal"] = tmp_obj["subtotal"] = locale.format("%d", subtotal, grouping=True)
			else:
				tmp_obj["subtotal"] = 0
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_orders(cls, cur):
		import locale
		import json
		locale.setlocale(locale.LC_NUMERIC, 'ja_JP')
		locale.setlocale(locale.LC_MONETARY, 'en_US')
		result = []
		for res in cur:
			tmp_obj = {
				"id": res[0],
				"project_id": res[1],
				"output_val": res[2],
				"creator" : {"id": res[3]},
				"dt_created": res[4].strftime("%Y/%m/%d %H:%M:%S") if res[4] else None,
				"owner_company_id": res[5],
				"quotation_name": res[6],
				"quotation_no": res[7],
				"quotation_date": res[8].strftime("%Y/%m") if res[8] else None,
				"is_enabled": bool(res[9]),
				"total_including_tax": res[10],
				"total_including_tax_view":  locale.format('%d', res[10], True),
				"is_send": bool(res[11]),
				"modifier": {"id": res[12]},
				"is_view_window": bool(res[13]),
				"is_view_excluding_tax": bool(res[14]),
				"pdffile_path": res[15],
				"office_memo": res[16],
				"project_title": res[17],
				"charging_user": {"id": res[18]},
				"client_name": res[19],

			}
			subtotal = 0
			output_val = json.loads(res[2])
			if 'output' in output_val:
				rows = output_val["output"]["rows"]
				for row in rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
					if row.get("subtotal_1"):
						subtotal += int(row["subtotal_1"].replace(',', ''))
					if row.get("subtotal_2"):
						subtotal += int(row["subtotal_2"].replace(',', ''))

				free_rows = output_val["output"]["free_rows"]
				for row in free_rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
				tmp_obj["subtotal"] = tmp_obj["subtotal"] = locale.format("%d", subtotal, grouping=True)
			else:
				tmp_obj["subtotal"] = 0
		return result

	@classmethod
	def __cvt_enum_invoices(cls, cur):
		import locale
		import json
		locale.setlocale(locale.LC_NUMERIC, 'ja_JP')
		locale.setlocale(locale.LC_MONETARY, 'en_US')
		result = []
		for res in cur:
			tmp_obj = {
				"id": res[0],
				"project_id": res[1],
				"output_val": res[2],
				"creator" : {"id": res[3]},
				"dt_created": res[4].strftime("%Y/%m/%d %H:%M:%S") if res[4] else None,
				"owner_company_id": res[5],
				"quotation_name": res[6],
				"quotation_no": res[7],
				"quotation_date": res[8].strftime("%Y/%m") if res[8] else None,
				"is_enabled": bool(res[9]),
				"total_including_tax": res[10],
				"total_including_tax_view":  locale.format('%d', res[10], True),
				"is_send": bool(res[11]),
				"modifier": {"id": res[12]},
				"is_view_window": bool(res[13]),
				"is_view_excluding_tax": bool(res[14]),
				"pdffile_path": res[15],
				"office_memo": res[16],
				"project_title": res[17],
				"charging_user": {"id": res[18]},
				"client_name": res[19],
			}
			subtotal = 0
			output_val = json.loads(res[2])
			if 'output' in output_val:
				rows = output_val["output"]["rows"]
				for row in rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
					if row.get("subtotal_1"):
						subtotal += int(row["subtotal_1"].replace(',', ''))
					if row.get("subtotal_2"):
						subtotal += int(row["subtotal_2"].replace(',', ''))
				free_rows = output_val["output"]["free_rows"]
				for row in free_rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
				tmp_obj["subtotal_num"] = subtotal
				tmp_obj["subtotal"] = locale.format("%d", subtotal, grouping=True)
			else:
				tmp_obj["subtotal"] = 0
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_purchases(cls, cur):
		import locale
		import json
		locale.setlocale(locale.LC_NUMERIC, 'ja_JP')
		locale.setlocale(locale.LC_MONETARY, 'en_US')
		result = []
		for res in cur:
			tmp_obj = {
				"id": res[0],
				"project_id": res[1],
				"output_val": res[2],
				"creator" : {"id": res[3]},
				"dt_created": res[4].strftime("%Y/%m/%d %H:%M:%S") if res[4] else None,
				"owner_company_id": res[5],
				"quotation_name": res[6],
				"quotation_no": res[7],
				"quotation_date": res[8].strftime("%Y/%m") if res[8] else None,
				"is_enabled": bool(res[9]),
				"total_including_tax": res[10],
				"total_including_tax_view":  locale.format('%d', res[10], True),
				"is_send": bool(res[11]),
				"modifier": {"id": res[12]},
				"is_view_window": bool(res[13]),
				"is_view_excluding_tax": bool(res[14]),
				"client_id": res[15],
				"pdffile_path": res[16],
				"office_memo": res[17],
				"project_title": res[18],
				"charging_user": {"id": res[19]},
				"client_name": res[20],
				"engineer_client_name": res[21],
				"engineer_company_id": res[22],
				"engineer_company_name": res[23],
				"addr_vip": res[24],
				"addr1": res[25],
				"addr2": res[26],
				"addr_name": res[27],
				"type_honorific": res[28],
				"engineer_id": res[29],
			}
			subtotal = 0
			output_val = json.loads(res[2])
			if 'output' in output_val:
				rows = output_val["output"]["rows"]
				for row in rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
					if row.get("subtotal_1"):
						subtotal += int(row["subtotal_1"].replace(',', ''))
					if row.get("subtotal_2"):
						subtotal += int(row["subtotal_2"].replace(',', ''))

				free_rows = output_val["output"]["free_rows"]
				for row in free_rows:
					if row["subtotal"]:
						subtotal += int(row["subtotal"].replace(',', ''))
				tmp_obj["subtotal"] = locale.format("%d", subtotal, grouping=True)
			else:
				tmp_obj["subtotal"] = 0
			result.append(tmp_obj)
		return result


	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result

	@classmethod
	def __cvt_last_quotation_no(cls, cur):
		tmp = cur.fetchone()
		result = tmp[0] if tmp and tmp[0] > 0 else None
		return result
