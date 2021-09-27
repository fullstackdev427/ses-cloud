#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from models.base import ModelBase

class Operation(ModelBase):
	
	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""
	
	__class_name__ = "Operation"
	__SQL__ = {\
"enum_operations": """SELECT
	`FO`.`id`,
	`FO`.`project_id`,
	`FO`.`engineer_id`,
	`FO`.`term_begin_exp`,
	`FO`.`term_end_exp`,
	`FO`.`term_memo`,
	`FO`.`demand_exc_tax`,
	`FO`.`demand_inc_tax`,
	`FO`.`payment_exc_tax`,
	`FO`.`payment_inc_tax`,
	`FO`.`gross_profit`,
	`FO`.`gross_profit_rate`,
	`FO`.`settlement_from`,
	`FO`.`settlement_to`,
	`FO`.`contract_date`,
	`FO`.`tax`,
	`FO`.`welfare_fee`,
	`FO`.`transportation_fee`,
	`FO`.`excess`,
	`FO`.`deduction`,
	`FO`.`demand_memo`,
	`FO`.`payment_memo`,
	`FO`.`demand_site`,
	`FO`.`payment_site`,
	`FO`.`cutoff_date`,
	`FO`.`other_memo`,
	`FO`.`is_active`,
	`FO`.`is_fixed`,
	`FO`.`creator_id`,
	`FO`.`modifier_id`,
	`FO`.`dt_created`,
	`FO`.`dt_modified`,
	`FO`.`base_exc_tax`,
	`FO`.`base_inc_tax`,
	`FO`.`transfer_member`,
	`MTC`.`id`,
	`MTC`.`name`,
	`MTC`.`kana`,
	`MTC`.`addr_vip`,
	`MTC`.`addr1`,
	`MTC`.`addr2`,
	`MTC`.`tel`,
	`MTC`.`fax`,
	`MTP`.`title`,
	`MTP`.`charging_user_id`,
	`MTE`.`name`,
	`MTE`.`charging_user_id`,
	`MTUC`.`name`,
	`MTE`.`contract`,
	`MTP`.`term_begin`,
	`MTP`.`term_end`,
	(SELECT group_concat(distinct name order by name  separator ',') from mt_skills ms join cr_prj_skill_needs cps where ms.id = cps.skill_id and cps.project_id = `MTP`.`id`) AS skill_list,
	(SELECT group_concat(distinct id order by id  separator ',') from mt_client_workers mcw where mcw.client_id = `MTC`.id and mcw.is_enabled =1) AS worker_id_list,
	`FO`.`term_begin`,
	`FO`.`term_end`,
	`FO`.`settlement_exp`,
	`FO`.`settlement_unit`,
	`FO`.`demand_unit`,
	`FO`.`payment_unit`,
	`FO`.`bonuses_division`,
	`FO`.`payment_base`,
	`FO`.`payment_excess`,
	`FO`.`payment_deduction`,
	`FO`.`payment_exp`,
	`FO`.`payment_settlement_unit`,
	`FO`.`demand_wage_per_hour`,
	`FO`.`demand_working_time`,
	`FO`.`payment_wage_per_hour`,
	`FO`.`payment_working_time`,
	`FO`.`payment_settlement_from`,
	`FO`.`payment_settlement_to`,
	`MTEC`.`id`,
	`MTEC`.`name`,
	`MTEC`.`kana`,
	`MTEC`.`addr_vip`,
	`MTEC`.`addr1`,
	`MTEC`.`addr2`,
	`MTEC`.`tel`,
	`MTEC`.`fax`,
	(SELECT group_concat(distinct id order by id  separator ',') from mt_client_workers mcw where mcw.client_id = `MTEC`.id and mcw.is_enabled =1) AS engineer_worker_id_list,
	`MTUC`.`id`,
	(SELECT group_concat(distinct id order by id  separator ',') from mt_user_persons mup where mup.company_id = `MTUC`.id and mup.is_enabled =1) AS engineer_company_user_id_list
	FROM `ft_operations` AS `FO`
	JOIN `mt_projects` AS `MTP` ON (`FO`.`project_id` = `MTP`.`id`)
	LEFT OUTER JOIN `mt_clients` AS `MTC` ON (`MTP`.`client_id` = `MTC`.`id`)
	JOIN `mt_engineers` AS `MTE` ON (`FO`.`engineer_id` = `MTE`.`id`)
	JOIN `mt_user_companies` AS `MTUC` ON (`MTE`.`owner_company_id` = `MTUC`.`id`)
	LEFT OUTER JOIN `mt_clients` AS `MTEC` ON (`MTE`.`client_id` = `MTEC`.`id`)
	WHERE
	`MTP`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
		%s
	ORDER BY %s;
""", \
"enum_operations_summary": """SELECT
		sum(1),
		sum(`FO`.`base_exc_tax`),
		sum(`FO`.`base_exc_tax` - `FO`.`payment_base` - `FO`.`welfare_fee` - `FO`.`transportation_fee` - `FO`.`bonuses_division`),
		sum(case when `FO`.is_fixed = 1 then 1 else 0 end),
		sum(case when `FO`.is_fixed = 1 then `FO`.`base_exc_tax` else 0 end),
		sum(case when `FO`.is_fixed = 1 then (`FO`.`base_exc_tax` - `FO`.`payment_base` - `FO`.`welfare_fee` - `FO`.`transportation_fee` - `FO`.`bonuses_division`) else 0 end)
FROM `ft_operations` AS `FO`
		JOIN `mt_projects` AS `MTP` ON (`FO`.`project_id` = `MTP`.`id`)
		LEFT OUTER JOIN `mt_clients` AS `MTC` ON (`MTP`.`client_id` = `MTC`.`id`)
		JOIN `mt_engineers` AS `MTE` ON (`FO`.`engineer_id` = `MTE`.`id`)
		JOIN `mt_user_companies` AS `MTUC` ON (`MTE`.`owner_company_id` = `MTUC`.`id`)
		LEFT OUTER JOIN `mt_clients` AS `MTEC` ON (`MTE`.`client_id` = `MTEC`.`id`)
		WHERE
		`MTP`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
			%s
	ORDER BY %s;""", \
"enum_operations_total": """SELECT
		sum(1)
FROM `ft_operations` AS `FO`
		JOIN `mt_projects` AS `MTP` ON (`FO`.`project_id` = `MTP`.`id`)
		LEFT OUTER JOIN `mt_clients` AS `MTC` ON (`MTP`.`client_id` = `MTC`.`id`)
		JOIN `mt_engineers` AS `MTE` ON (`FO`.`engineer_id` = `MTE`.`id`)
		JOIN `mt_user_companies` AS `MTUC` ON (`MTE`.`owner_company_id` = `MTUC`.`id`)
		LEFT OUTER JOIN `mt_clients` AS `MTEC` ON (`MTE`.`client_id` = `MTEC`.`id`)
		WHERE
		`MTP`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
			%s
	ORDER BY %s;""", \
"create_operation": """INSERT INTO ft_operations (
	`project_id`,
	`engineer_id`,
	`term_memo`,
	`base_exc_tax`,
	`excess`,
	`deduction`,
	`demand_exc_tax`,
	`demand_inc_tax`,
	`payment_exc_tax`,
	`payment_inc_tax`,
	`welfare_fee`,
	`transportation_fee`,
	`gross_profit`,
	`gross_profit_rate`,
	`tax`,
	`settlement_from`,
	`settlement_to`,
	`contract_date`,
	`demand_site`,
	`payment_site`,
	`other_memo`,
	`is_active`,
	`is_fixed`,
	`base_inc_tax`,
	`transfer_member`,
	`term_begin`,
	`term_end`,
	`settlement_unit`,
	`demand_unit`,
	`payment_unit`,
	`bonuses_division`,
	`payment_base`,
	`payment_excess`,
	`payment_deduction`,
	`payment_settlement_unit`,
	`demand_wage_per_hour`,
	`demand_working_time`,
	`payment_wage_per_hour`,
	`payment_working_time`,
	`payment_settlement_from`,
	`payment_settlement_to`,
	`demand_memo`,
	`payment_memo`,
	`creator_id`
 ) VALUES (
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,%s,%s,
	%s,%s,
	%s,valid_user_id_full(%s, %s, %s)
	);""", \
"update_operation": """UPDATE `ft_operations`
		SET
			`modifier_id`=valid_user_id_full(%%s, %%s, %%s),
			%s
		WHERE
			`id`=%%s
			;""", \
"copy_operation": """
INSERT INTO ft_operations (
	`project_id`,
	`engineer_id`,
	`term_begin_exp`,
	`term_end_exp`,
	`term_memo`,
	`base_exc_tax`,
	`excess`,
	`deduction`,
	`demand_exc_tax`,
	`demand_inc_tax`,
	`payment_exc_tax`,
	`payment_inc_tax`,
	`welfare_fee`,
	`transportation_fee`,
	`gross_profit`,
	`gross_profit_rate`,
	`tax`,
	`settlement_from`,
	`settlement_to`,
	`contract_date`,
	`demand_memo`,
	`payment_memo`,
	`demand_site`,
	`payment_site`,
	`cutoff_date`,
	`other_memo`,
	`is_active`,
	`is_fixed`,
	`creator_id`,
	`modifier_id`,
	`dt_created`,
	`dt_modified`,
	`base_inc_tax`,
	`transfer_member`,
	`term_begin`,
	`term_end`,
	`settlement_exp`,
	`settlement_unit`,
	`demand_unit`,
	`payment_unit`,
	`bonuses_division`,
	`payment_base`,
	`payment_excess`,
	`payment_deduction`,
	`payment_exp`,
	`payment_settlement_unit`,
	`demand_wage_per_hour`,
	`demand_working_time`,
	`payment_wage_per_hour`,
	`payment_working_time`,
	`payment_settlement_from`,
	`payment_settlement_to`
)
SELECT 
	`FO`.`project_id`,
	`FO`.`engineer_id`,
	`FO`.`term_begin_exp`,
	`FO`.`term_end_exp`,
	`FO`.`term_memo`,
	`FO`.`base_exc_tax`,
	`FO`.`excess`,
	`FO`.`deduction`,
	`FO`.`demand_exc_tax`,
	`FO`.`demand_inc_tax`,
	`FO`.`payment_exc_tax`,
	`FO`.`payment_inc_tax`,
	`FO`.`welfare_fee`,
	`FO`.`transportation_fee`,
	`FO`.`gross_profit`,
	`FO`.`gross_profit_rate`,
	`FO`.`tax`,
	`FO`.`settlement_from`,
	`FO`.`settlement_to`,
	`FO`.`contract_date`,
	`FO`.`demand_memo`,
	`FO`.`payment_memo`,
	`FO`.`demand_site`,
	`FO`.`payment_site`,
	`FO`.`cutoff_date`,
	`FO`.`other_memo`,
	`FO`.`is_active`,
	`FO`.`is_fixed`,
	`FO`.`creator_id`,
	`FO`.`modifier_id`,
	now(),
	now(),
	`FO`.`base_inc_tax`,
	`FO`.`transfer_member`,
	`FO`.`term_begin`,
	`FO`.`term_end`,
	`FO`.`settlement_exp`,
	`FO`.`settlement_unit`,
	`FO`.`demand_unit`,
	`FO`.`payment_unit`,
	`FO`.`bonuses_division`,
	`FO`.`payment_base`,
	`FO`.`payment_excess`,
	`FO`.`payment_deduction`,
	`FO`.`payment_exp`,
	`FO`.`payment_settlement_unit`,
	`FO`.`demand_wage_per_hour`,
	`FO`.`demand_working_time`,
	`FO`.`payment_wage_per_hour`,
	`FO`.`payment_working_time`,
	`FO`.`payment_settlement_from`,
	`FO`.`payment_settlement_to`
 FROM ft_operations FO WHERE id = %s;
""", \
"delete_operation": """DELETE FROM ft_operations WHERE project_id = %s and engineer_id =  %s;""", \
"delete_operation_from_id": """DELETE FROM ft_operations WHERE id = %s;""", \
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
		"delete_contact_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1}\
		}\
	}
	
	@classmethod
	def __cvt_enum_operations(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['project_id'] = res[1]
			tmp_obj['engineer_id'] = res[2]
			tmp_obj['term_begin_exp'] = res[3].strftime("%Y/%m/%d") if res[3] else None
			tmp_obj['term_end_exp'] = res[4].strftime("%Y/%m/%d") if res[4] else None
			tmp_obj['term_memo'] = res[5]
			tmp_obj['demand_exc_tax'] = res[6]
			tmp_obj['demand_inc_tax'] = res[7]
			tmp_obj['payment_exc_tax'] = res[8]
			tmp_obj['payment_inc_tax'] = res[9]
			tmp_obj['gross_profit'] = res[10]
			tmp_obj['gross_profit_rate'] = res[11]
			tmp_obj['settlement_from'] = res[12]
			tmp_obj['settlement_to'] = res[13]
			tmp_obj['contract_date'] = res[14].strftime("%Y/%m/%d") if res[14] else None
			tmp_obj['tax'] = res[15]
			tmp_obj['welfare_fee'] = res[16]
			tmp_obj['transportation_fee'] = res[17]
			tmp_obj['excess'] = res[18]
			tmp_obj['deduction'] = res[19]
			tmp_obj['demand_memo'] = res[20]
			tmp_obj['payment_memo'] = res[21]
			tmp_obj['demand_site'] = res[22]
			tmp_obj['payment_site'] = res[23]
			tmp_obj['cutoff_date'] = res[24].strftime("%Y/%m/%d") if res[24] else None
			tmp_obj['other_memo'] = res[25]
			tmp_obj['is_active'] = res[26]
			tmp_obj['is_fixed'] = res[27]
			tmp_obj['creator'] = {"id": res[28], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[29], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[30].strftime("%Y/%m/%d %H:%M:%S") if res[30] else None
			tmp_obj['dt_modified'] = res[31].strftime("%Y/%m/%d %H:%M:%S") if res[31] else None
			tmp_obj['base_exc_tax'] = res[32]
			tmp_obj['base_inc_tax'] = res[33]
			tmp_obj['transfer_member'] = res[34]
			tmp_obj['client_id'] = res[35]
			tmp_obj['client_name'] = res[36]
			tmp_obj['client_kana'] = res[37]
			tmp_obj['client_addr_vip'] = res[38]
			tmp_obj['client_addr1'] = res[39]
			tmp_obj['client_addr2'] = res[40]
			tmp_obj['client_tel'] = res[41]
			tmp_obj['client_fax'] = res[42]
			tmp_obj['project_title'] = res[43]
			tmp_obj['charging_user'] = {"id": res[44]}
			tmp_obj['engineer_name'] = res[45]
			tmp_obj['engineer_charging_user'] = {"id": res[46]}
			tmp_obj['engineer_company_name'] = res[47]
			tmp_obj['contract'] = res[48]
			tmp_obj['term_begin_project'] = res[49].strftime("%Y/%m/%d") if res[49] else None
			tmp_obj['term_end_project'] = res[50].strftime("%Y/%m/%d") if res[50] else None
			tmp_obj['skill_list'] = res[51]
			tmp_obj['worker_id_list'] = res[52]
			tmp_obj['term_begin'] = res[53].strftime("%Y/%m/%d") if res[53] else None
			tmp_obj['term_end'] = res[54].strftime("%Y/%m/%d") if res[54] else None
			tmp_obj['settlement_exp'] = res[55]
			tmp_obj['settlement_unit'] = res[56]
			tmp_obj['demand_unit'] = res[57]
			tmp_obj['payment_unit'] = res[58]
			tmp_obj['bonuses_division'] = res[59]
			tmp_obj['payment_base'] = res[60]
			tmp_obj['payment_excess'] = res[61]
			tmp_obj['payment_deduction'] = res[62]
			tmp_obj['payment_exp'] = res[63]
			tmp_obj['payment_settlement_unit'] = res[64]
			tmp_obj['demand_wage_per_hour'] = res[65]
			tmp_obj['demand_working_time'] = res[66]
			tmp_obj['payment_wage_per_hour'] = res[67]
			tmp_obj['payment_working_time'] = res[68]
			tmp_obj['payment_settlement_from'] = res[69]
			tmp_obj['payment_settlement_to'] = res[70]
			tmp_obj['engineer_client_id'] = res[71]
			tmp_obj['engineer_client_name'] = res[72]
			tmp_obj['engineer_client_kana'] = res[73]
			tmp_obj['engineer_client_addr_vip'] = res[74]
			tmp_obj['engineer_client_addr1'] = res[75]
			tmp_obj['engineer_client_addr2'] = res[76]
			tmp_obj['engineer_client_tel'] = res[77]
			tmp_obj['engineer_client_fax'] = res[78]
			tmp_obj['engineer_worker_id_list'] = res[79]
			tmp_obj['engineer_company_id'] = res[80]
			tmp_obj['engineer_company_user_id_list'] = res[81]
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_operations_summary(cls, cur):
		result = []
		import locale
		locale.setlocale(locale.LC_NUMERIC, 'ja_JP')
		for res in cur:
			tmp_obj = {}
			tmp_obj['count'] = int(res[0]) if res[0] else 0
			tmp_obj['base_exc_tax'] = locale.format('%d', int(res[1]), True) if res[1] else 0
			tmp_obj['gross_profit'] = locale.format('%d', int(res[2]), True) if res[2] else 0
			tmp_obj['gross_profit_rate'] = round(res[2] / res[1] * 100,1) if (res[1] != 0 and res[2]) else 0
			if tmp_obj['gross_profit_rate'] > 1000:
				tmp_obj['gross_profit_rate'] = 999.9
			if tmp_obj['gross_profit_rate'] < -1000:
				tmp_obj['gross_profit_rate'] = -999.9
			tmp_obj['fix_count'] = int(res[3]) if res[3] else 0
			tmp_obj['fix_base_exc_tax'] = locale.format('%d', int(res[4]), True) if res[4] else 0
			tmp_obj['fix_gross_profit'] = locale.format('%d', int(res[5]), True) if res[5] else 0
			tmp_obj['fix_gross_profit_rate'] = round(res[5] / res[4] * 100,1) if (res[4] != 0 and res[5]) else 0
			if tmp_obj['fix_gross_profit_rate'] > 1000:
				tmp_obj['fix_gross_profit_rate'] = 999.9
			if tmp_obj['fix_gross_profit_rate'] < -1000:
				tmp_obj['fix_gross_profit_rate'] = -999.9

			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result

	@classmethod
	def __cvt_enum_operations_total(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['count'] = int(res[0]) if res[0] else 0

			result.append(tmp_obj)
		return result
	

