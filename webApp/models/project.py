#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from models.base import ModelBase

class Project(ModelBase):

	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""

	__class_name__ = "Project"
	__SQL__ = {\
"enum_projects": """SELECT
  `MT`.`id`,
  `MT`.`client_id`,
  COALESCE(`CL`.`name`, `MT`.`client_name`),
  `MT`.`fee_inbound`,
  FORMAT(`MT`.`fee_inbound`, 0),
  `MT`.`fee_outbound`,
  FORMAT(`MT`.`fee_outbound`, 0),
  `MT`.`term_begin`,
  `MT`.`term_end`,
  `MT`.`title`,
  `MT`.`station`,
  `MT`.`process`,
  `MT`.`expense`,
  `MT`.`interview`,
  `MT`.`scheme`,
  `MT`.`flg_shared`,
  `MT`.`charging_user_id`,
  `MT`.`creator_id`,
  `MT`.`modifier_id`,
  `MT`.`dt_created`,
  `MT`.`dt_modified`,
  `MT`.`is_enabled`,
  `NOTE`.`note`,
  `MT`.`term`,
  `MT`.`skill_needs`,
  `MT`.`skill_recommends`,
  `MT`.`age_from`,
  `MT`.`age_to`,
  `MT`.`rank_id`,
  CASE rank_id WHEN 1 THEN 'A' WHEN 2 THEN 'B' WHEN 3 THEN 'C' ELSE '-' END,
  (SELECT group_concat(distinct name order by id  separator ',') from mt_skills ms join cr_prj_skill_needs cps where ms.id = cps.skill_id and cps.project_id = `MT`.`id`) AS skill_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_skills ms join cr_prj_skill_needs cps where ms.id = cps.skill_id and cps.project_id = `MT`.`id`) AS skill_id_list,
  (SELECT group_concat(distinct name order by name  separator ',') from mt_occupations mo join cr_prj_ocp_needs cpo where mo.id = cpo.occupation_id and cpo.project_id = `MT`.`id`) AS occupation_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_occupations mo join cr_prj_ocp_needs cpo where mo.id = cpo.occupation_id and cpo.project_id = `MT`.`id`) AS occupation_id_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_client_workers mcw where mcw.client_id = `CL`.id and mcw.is_enabled =1) AS worker_id_list,
  `MT`.`station_cd`,
  `MT`.`station_pref_cd`,
  `MT`.`station_line_cd`,
  `MT`.`station_lon`,
  `MT`.`station_lat`,
  `MT`.`flg_public`,
  `MT`.`web_public`,
  `MT`.`flg_foreign`,
  `INTERNAL_NOTE`.`internal_note`
  FROM `mt_projects` AS `MT`
  LEFT JOIN `mt_clients` AS `CL`
    ON `MT`.`client_id` = `CL`.`id` AND `CL`.`is_enabled` <> FALSE
  LEFT JOIN `ft_project_notes` AS `NOTE`
    ON `NOTE`.`project_id` = `MT`.`id`
  LEFT JOIN `ft_project_internal_notes` AS `INTERNAL_NOTE`
    ON `INTERNAL_NOTE`.`project_id` = `MT`.`id`
  WHERE
    `MT`.`is_enabled`<>FALSE
    AND
    (
      `MT`.`creator_id` IN(
        SELECT `id` FROM `mt_user_persons` WHERE `company_id` IN(
          SELECT
          `C`.`id`
          FROM `mt_user_persons` AS `P`
          INNER JOIN `mt_user_groups` AS `G`
            ON `P`.`group_id` = `G`.`id`
          INNER JOIN `mt_user_companies` AS `C`
            ON `G`.`company_id` = `C`.`id`
          WHERE
            (`C`.`prefix` = %%s AND `P`.`login_id` = %%s)
            AND `C`.`is_enabled` <> FALSE
        )
      )
      OR
      `MT`.`modifier_id` IN(
        SELECT `id` FROM `mt_user_persons` WHERE `company_id` IN(
          SELECT
          `C`.`id`
          FROM `mt_user_persons` AS `P`
          INNER JOIN `mt_user_groups` AS `G`
            ON `P`.`group_id` = `G`.`id`
          INNER JOIN `mt_user_companies` AS `C`
            ON `G`.`company_id` = `C`.`id`
          WHERE
            (`C`.`prefix` = %%s AND `P`.`login_id` = %%s)
            AND `C`.`is_enabled` <> FALSE
        )
      )
    )
    AND valid_user_id_read(%%s, %%s, %%s)
    AND (
      `MT`.`flg_shared`=TRUE
      OR (
        SELECT
          `P`.`is_admin`
          FROM `mt_user_persons` AS `P`
          INNER JOIN `mt_user_groups` AS `G`
            ON `P`.`group_id` = `G`.`id`
          INNER JOIN `mt_user_companies` AS `C`
            ON `G`.`company_id` = `C`.`id`
          WHERE
            `C`.`prefix` = %%s
            AND `P`.`login_id` = %%s
            AND `P`.`credential` = %%s
            AND `C`.`is_enabled` = TRUE
            AND `G`.`is_enabled` = TRUE
            AND `P`.`is_enabled` = TRUE
            AND `P`.`is_locked`<>TRUE
      ) = TRUE
    )
    %s
    ORDER BY %s;""", \
"enum_bp_projects": """SELECT
	  `MT`.`id`,
	  `MT`.`client_id`,
	  COALESCE(`CL`.`name`, `MT`.`client_name`),
	  `MT`.`fee_inbound`,
	  FORMAT(`MT`.`fee_inbound`, 0),
	  `MT`.`fee_outbound`,
	  FORMAT(`MT`.`fee_outbound`, 0),
	  `MT`.`term_begin`,
	  `MT`.`term_end`,
	  `MT`.`title`,
	  `MT`.`station`,
	  `MT`.`process`,
	  `MT`.`expense`,
	  `MT`.`interview`,
	  `MT`.`scheme`,
	  `MT`.`flg_shared`,
	  `MT`.`charging_user_id`,
	  `MT`.`creator_id`,
	  `MT`.`modifier_id`,
	  `MT`.`dt_created`,
	  `MT`.`dt_modified`,
	  `MT`.`is_enabled`,
	  `NOTE`.`note`,
	  `MT`.`term`,
	  `MT`.`skill_needs`,
	  `MT`.`skill_recommends`,
	  `MT`.`age_from`,
	  `MT`.`age_to`,
	  `MT`.`rank_id`,
	  CASE rank_id WHEN 1 THEN 'A' WHEN 2 THEN 'B' WHEN 3 THEN 'C' ELSE '-' END,
	  (SELECT group_concat(distinct name order by id  separator ',') from mt_skills ms join cr_prj_skill_needs cps where ms.id = cps.skill_id and cps.project_id = `MT`.`id`) AS skill_list,
	  (SELECT group_concat(distinct id order by id  separator ',') from mt_skills ms join cr_prj_skill_needs cps where ms.id = cps.skill_id and cps.project_id = `MT`.`id`) AS skill_id_list,
	  (SELECT group_concat(distinct name order by name  separator ',') from mt_occupations mo join cr_prj_ocp_needs cpo where mo.id = cpo.occupation_id and cpo.project_id = `MT`.`id`) AS occupation_list,
	  (SELECT group_concat(distinct id order by id  separator ',') from mt_occupations mo join cr_prj_ocp_needs cpo where mo.id = cpo.occupation_id and cpo.project_id = `MT`.`id`) AS occupation_id_list,
	  (SELECT group_concat(distinct id order by id  separator ',') from mt_client_workers mcw where mcw.client_id = `CL`.id and mcw.is_enabled =1) AS worker_id_list,
	  `MT`.`station_cd`,
	  `MT`.`station_pref_cd`,
	  `MT`.`station_line_cd`,
	  `MT`.`station_lon`,
	  `MT`.`station_lat`,
	  `MT`.`flg_public`,
  	  `MT`.`web_public`,
	  `MT`.`flg_foreign`,
	  `INTERNAL_NOTE`.`internal_note`
	  FROM `mt_projects` AS `MT`
	  LEFT JOIN `mt_clients` AS `CL`
	    ON `MT`.`client_id` = `CL`.`id` AND `CL`.`is_enabled` <> FALSE
	  LEFT JOIN `ft_project_notes` AS `NOTE`
	    ON `NOTE`.`project_id` = `MT`.`id`
	  LEFT JOIN `ft_project_internal_notes` AS `INTERNAL_NOTE`
		ON `INTERNAL_NOTE`.`project_id` = `MT`.`id`
	  WHERE
	    `MT`.`is_enabled`<>FALSE
	    AND `MT`.flg_public = 1 AND EXISTS (SELECT 1 FROM mt_user_companies AS MUC WHERE MUC.id = `MT`.`owner_company_id` AND MUC.flg_public = 1 AND MUC.is_enabled = 1)
	    AND valid_user_id_read(%%s, %%s, %%s)
	    %s
	    ORDER BY %s;""", \
"search_projects": """SELECT
	  distinct `MT`.`id`,
	  `MT`.`client_id`,
	  COALESCE(`CL`.`name`, `MT`.`client_name`),
	  `MT`.`fee_inbound`,
	  FORMAT(`MT`.`fee_inbound`, 0),
	  `MT`.`fee_outbound`,
	  FORMAT(`MT`.`fee_outbound`, 0),
	  `MT`.`term_begin`,
	  `MT`.`term_end`,
	  `MT`.`title`,
	  `MT`.`station`,
	  `MT`.`process`,
	  `MT`.`expense`,
	  `MT`.`interview`,
	  `MT`.`scheme`,
	  `MT`.`flg_shared`,
	  `MT`.`charging_user_id`,
	  `MT`.`creator_id`,
	  `MT`.`modifier_id`,
	  `MT`.`dt_created`,
	  `MT`.`dt_modified`,
	  `MT`.`is_enabled`,
	  `NOTE`.`note`,
	  `MT`.`term`,
	  `MT`.`skill_needs`,
	  `MT`.`skill_recommends`,
	  `MT`.`age_from`,
	  `MT`.`age_to`,
	  CASE rank_id WHEN 1 THEN 'A' WHEN 2 THEN 'B' WHEN 3 THEN 'C' ELSE '-' END,
	  (SELECT group_concat(distinct name order by id  separator ',') from mt_skills ms join cr_prj_skill_needs cps where ms.id = cps.skill_id and cps.project_id = `MT`.`id`) AS skill,
	  COALESCE((SELECT count(id) from mt_skills ms join cr_prj_skill_needs cps where ms.id = cps.skill_id and cps.project_id = `MT`.`id`),0) AS skill_count,
	  (SELECT group_concat(distinct name order by name  separator ',') from mt_occupations mo join cr_prj_ocp_needs cpo where mo.id = cpo.occupation_id and cpo.project_id = `MT`.`id`)  AS occupation,
	  COALESCE((SELECT count(id) from mt_occupations mo join cr_prj_ocp_needs cpo where mo.id = cpo.occupation_id and cpo.project_id = `MT`.`id`),0) AS occupation_count,
	  (SELECT group_concat(distinct id order by id  separator ',') from mt_client_workers mcw where mcw.client_id = `CL`.id and mcw.is_enabled =1) AS worker_id_list,
	  CASE WHEN `MT`.`station_lon` IS NULL OR %%s =0 THEN null ELSE travel_time_from_distance(%%s,%%s,`MT`.`station_lat`,`MT`.`station_lon`) END AS travel_time,
	  `MT`.`owner_company_id`,
	  (SELECT name FROM mt_user_companies mc WHERE mc.id = `MT`.`owner_company_id`) AS company_name,
	  (SELECT group_concat(distinct id order by id  separator ',') from mt_user_persons mcp where mcp.company_id = `MT`.`owner_company_id` and mcp.is_enabled =1) AS user_id_list,
	  `MT`.`flg_foreign`,
	  `MT`.`flg_public`,
	  `MT`.`web_public`,
	  `MT`.`create_from_promo`,
	  `MTC`.`tel`,
	  `INTERNAL_NOTE`.`internal_note`
	  FROM `mt_projects` AS `MT`
	  LEFT JOIN `mt_clients` AS `CL`
	    ON `MT`.`client_id` = `CL`.`id` AND `CL`.`is_enabled` <> FALSE
	  LEFT JOIN `ft_project_notes` AS `NOTE`
	    ON `NOTE`.`project_id` = `MT`.`id`
	  LEFT JOIN `ft_project_internal_notes` AS `INTERNAL_NOTE`
		ON `INTERNAL_NOTE`.`project_id` = `MT`.`id`
	  LEFT OUTER JOIN `cr_prj_ocp_needs` AS `CRO`
	    ON `CRO`.`project_id` = `MT`.`id`
	  LEFT OUTER JOIN `cr_prj_skill_needs` AS `CRS`
	    ON `CRS`.`project_id` = `MT`.`id`
	  LEFT OUTER JOIN `mt_user_companies` AS `MTC`
	    ON `MT`.`owner_company_id` = `MTC`.`id`
	  WHERE
	    `MT`.`flg_shared`<> FALSE
	    AND
	    `MT`.`is_show_matching` <> FALSE
	    AND
	    (
	    	`MT`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
	    	OR
	    	`MT`.flg_public = 1 AND EXISTS (SELECT 1 FROM mt_user_companies AS MUC WHERE MUC.id = `MT`.`owner_company_id` AND MUC.flg_public = 1 AND MUC.is_enabled = 1)
	    )
	    %s
	    ORDER BY %s;""", \
"related_skills": """SELECT
  `T`.`project_id`,
  `M`.`id`,
  `M`.`name`
  FROM `%s` AS `T`
  INNER JOIN `mt_skills` AS `M`
    ON `T`.`skill_id` = `M`.`id`
  WHERE
    `T`.`project_id` IN (%s)
    AND `M`.`is_enabled` <> FALSE
    AND valid_company(%%s, %%s, `M`.`owner_company_id`) IS NOT NULL;""",\
"create_project": """INSERT INTO `mt_projects` (
  `client_id`,
  `client_name`, `fee_inbound`, `fee_outbound`,
  `term_begin`, `term_end`,
  `title`, `station`, `process`, `expense`, `interview`, `scheme`, `flg_shared`, `charging_user_id`, `creator_id`,
  `term`, `skill_needs`, `skill_recommends`, `owner_company_id`, `age_from`, `age_to`,`rank_id`,
  `station_cd`,`station_pref_cd`,`station_line_cd`,`station_lon`,`station_lat`,`flg_public`,`web_public`,`flg_foreign`)
SELECT
  (
    SELECT `C`.`id`
    FROM `mt_clients` AS `C`
    WHERE `C`.`id` = %s AND valid_acl(%s, %s, `C`.`creator_id`, `modifier_id`)
  ), %s, %s, %s,
  %s, %s,
  %s, %s, %s, %s,
  %s, %s, %s,
  (
    SELECT `U`.`id`
    FROM `mt_user_persons` AS `U`
    WHERE `U`.`id` = %s AND valid_company(%s, %s, %s)
  ), valid_user_id_full(%s, %s, %s),
  %s, %s, %s, valid_user_company(%s, %s, %s), %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s;""",\
"update_project": """UPDATE `mt_projects`
  SET
    `modifier_id`=valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id`=%%s
    AND `is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_project": """UPDATE
  `mt_projects` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"set_skills": """INSERT INTO `%s` (`project_id`, `skill_id`)
  SELECT
    (
      SELECT
        `id`
        FROM `mt_projects`
        WHERE
          `id`=%%s
          AND `is_enabled`<>FALSE
          AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    ),
    `id`
    FROM `mt_skills`
    WHERE
      `id` IN (%s)
      AND `is_enabled`<>FALSE
      AND valid_user_company(%%s, %%s, %%s)
      AND valid_user_id_full(%%s, %%s, %%s)
  ON DUPLICATE KEY
    UPDATE `skill_id`=`skill_id`;""", \
"set_occupations": """INSERT INTO `%s` (`project_id`, `occupation_id`)
	  SELECT
	    (
	      SELECT
	        `id`
	        FROM `mt_projects`
	        WHERE
	          `id`=%%s
	          AND `is_enabled`<>FALSE
	          AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
	    ),
	    `id`
	    FROM `mt_occupations`
	    WHERE
	      `id` IN (%s)
	      AND valid_user_company(%%s, %%s, %%s)
	      AND valid_user_id_full(%%s, %%s, %%s)
	  ON DUPLICATE KEY
	    UPDATE `occupation_id`=`occupation_id`;""", \
"enum_related_clients" :"""\
SELECT
  `id`,
  `name`
  FROM `mt_clients`
  WHERE
    `is_enabled`<>FALSE
    AND `id` IN (%s)
    AND valid_user_id_read(%%s, %%s, %%s);""",\
"enum_clients" :"""\
SELECT
  `id`,
  `name`
  FROM `mt_clients`
  WHERE
    `is_enabled`<>FALSE
    AND valid_user_id_read(%s, %s, %s);""",\
"enum_users": """SELECT
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
"insert_cr_prj_engineer": """INSERT INTO cr_prj_engineer (project_id, engineer_id) VALUES (%s,%s);""", \
"delete_cr_prj_engineer": """DELETE FROM cr_prj_engineer WHERE project_id = %s and engineer_id =  %s;""", \
"update_skill_level": """UPDATE `cr_prj_skill_needs` SET `level` = %s WHERE `project_id` = %s and `skill_id` = %s;""", \
"enum_project_skill_levels": """\
		SELECT
		  `P`.`project_id`,
		  `P`.`skill_id`,
		  `P`.`level`
		  FROM `cr_prj_skill_needs` AS `P`
		  WHERE
		    %s
		    ;""", \
"last_insert_id": """SELECT LAST_INSERT_ID();""", \
"count_last_three_days": """
	SELECT
		COUNT(`id`) AS count_project,
		(select `dt_created` from `mt_projects` where `is_enabled`<>FALSE order by `dt_created` desc limit 1) AS newest_project
		FROM `mt_projects`
		WHERE `dt_created` >= DATE(NOW() - INTERVAL 3 DAY) + INTERVAL 0 SECOND
		AND `is_enabled`<>FALSE;""", \
"update_matching_project": """UPDATE `mt_projects` SET `flg_public` = 0, `is_show_matching` = 0 WHERE `id` = %s;"""\
	}
	__RULE__ = {\
		"enum_projects": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": True}\
			},\
		"create_project_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='client_id']": {"type": "number", "need": False, "nullable": True, "min": 1},\
			"hashmap/string[@name='client_name']": {"type": "string", "need": False, "nullable": True, "max": 32},\
			"hashmap/string[@name='fee_inbound']": {"type": "string", "need": True, "nullable": True,\
				"min": 0, "max": 15},\
			"hashmap/string[@name='fee_outbound']": {"type": "string", "need": True, "nullable": True,\
				"min": 0, "max": 15},\
			"hashmap/string[@name='term_begin']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\//][0-9]{2}[\//][0-9]{2})"},\
			"hashmap/string[@name='term_end']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\//][0-9]{2}[\//][0-9]{2})?"},\
			"hashmap/string[@name='title']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='station']": {"type": "string", "need": False, "nullable": False, "max": 15},\
			"hashmap/string[@name='process']": {"type": "string", "need": True, "nullable": False, "max": 128},\
			"hashmap/string[@name='expense']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/number[@name='interview']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/string[@name='scheme']": {"type": "string", "need": True, "nullable": True,\
				"candidates": (u"??????", u"?????????", u"")},\
			"hashmap/boolean[@name='flg_shared']": {"type": "boolean", "need": True, "nullable": False},\
			"hashmap/number[@name='charging_user_id']": {"type": "number", "need": False, "nullable": False, "min": 1},\
			"hashmap/string[@name='term']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='skill_needs']": {"type": "string", "need": True, "nullable": False, "max": 512},\
			"hashmap/string[@name='skill_recommends']": {"type": "string", "need": True, "nullable": False, "max": 512},\
		},\
		"update_project_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='client_name']": {"type": "string", "need": False, "nullable": True, "max": 32},\
			"hashmap/string[@name='fee_inbound']": {"type": "string", "need": False, "nullable": False,\
				"min": 0, "max": 15},\
			"hashmap/string[@name='fee_outbound']": {"type": "string", "need": False, "nullable": False,\
				"min": 0, "max": 15},\
			"hashmap/string[@name='term_begin']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\//][0-9]{2}[\//][0-9]{2})"},\
			"hashmap/string[@name='term_end']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\//][0-9]{2}[\//][0-9]{2})?"},\
			"hashmap/string[@name='title']": {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/string[@name='station']": {"type": "string", "need": False, "nullable": False, "max": 15},\
			"hashmap/string[@name='process']": {"type": "string", "need": False, "nullable": False, "max": 128},\
			"hashmap/string[@name='expense']": {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/number[@name='interview']": {"type": "number", "need": False, "nullable": False, "min": 1},\
			"hashmap/string[@name='scheme']": {"type": "string", "need": False, "nullable": True,\
				"candidates": (u"??????", u"?????????", u"")},\
			"hashmap/boolean[@name='flg_shared']": {"type": "boolean", "need": False, "nullable": False},\
			"hashmap/number[@name='charging_user_id']": {"type": "number", "need": False, "nullable": False, "min": 1},\
			"hashmap/string[@name='term']": {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='skill_needs']": {"type": "string", "need": False, "nullable": False, "max": 512},\
			"hashmap/string[@name='skill_recommends']": {"type": "string", "need": False, "nullable": False, "max": 512},\
		},\
		"delete_project_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False, "generics": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "need": True, "nullable": False, "min": 1}\
		},\
		"set_skills": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": False},\
			"hashmap/array[@name='needs']": {"type": "array", "need": False, "nullable": False, "generic": "number"},\
			"hashmap/array[@name='recommends']": {"type": "array", "need": False, "nullable": False, "generic": "number"}\
		},\
		"create_preparation": {
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='engineer_id']": {"type": "number", "need": True, "nullable": False, "min": 0},\
			"hashmap/number[@name='client_id']": {"type": "number", "need": False, "nullable": True, "min": 0},\
			"hashmap/string[@name='client_name']": {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='progress']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='note']": {"type": "string", "need": True, "nullable": False, "max": 128}\
		}\
	}

	@classmethod
	def __cvt_enum_projects(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['client'] = {"id": res[1]}
			tmp['client_name'] = res[2]
			tmp['fee_inbound'] = res[3]
			tmp['fee_inbound_comma'] = res[4]
			tmp['fee_outbound'] = res[5]
			tmp['fee_outbound_comma'] = res[6]
			tmp['term_begin'] = res[7].strftime("%Y/%m/%d") if res[7] else None
			tmp['term_end'] = res[8].strftime("%Y/%m/%d") if res[8] else None
			tmp['title'] = res[9]
			tmp['station'] = res[10]
			tmp['process'] = res[11]
			tmp['expense'] = res[12]
			tmp['interview'] = res[13]
			tmp['scheme'] = res[14]
			tmp['flg_shared'] = bool(res[15])
			tmp['charging_user'] = {"id": res[16]}
			tmp['creator'] = {"id": res[17]}
			tmp['modifier'] = {"id": res[18]}
			tmp['dt_created'] = res[19].strftime("%Y/%m/%d %H:%M:%S") if res[19] else None
			tmp['dt_modified'] = res[20].strftime("%Y/%m/%d %H:%M:%S") if res[20] else None
			tmp['is_enabled'] = bool(res[21])
			tmp['note'] = res[22]
			tmp['term'] = res[23]
			tmp['skill_needs'] = res[24]
			tmp['skill_recommends'] = res[25]
			tmp['age_from'] = res[26]
			tmp['age_to'] = res[27]
			tmp['rank_id'] = res[28]
			tmp['rank'] = res[29]
			tmp['skill_list'] = res[30]
			tmp['skill_id_list'] = res[31]
			tmp['occupation_list'] = res[32]
			tmp['occupation_id_list'] = res[33]
			tmp['worker_id_list'] = res[34]
			tmp['station_cd'] = res[35]
			tmp['station_pref_cd'] = res[36]
			tmp['station_line_cd'] = res[37]
			tmp['station_lon'] = res[38]
			tmp['station_lat'] = res[39]
			tmp['flg_public'] = res[40]
			tmp['web_public'] = res[41]
			tmp['flg_foreign'] = res[42]
			tmp['internal_note'] = res[43]
			tmp['skill_level_list'] = []
			result.append(tmp)
		return result

	@classmethod
	def __cvt_enum_bp_projects(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['client'] = {"id": res[1]}
			tmp['client_name'] = res[2]
			tmp['fee_inbound'] = res[3]
			tmp['fee_inbound_comma'] = res[4]
			tmp['fee_outbound'] = res[5]
			tmp['fee_outbound_comma'] = res[6]
			tmp['term_begin'] = res[7].strftime("%Y/%m/%d") if res[7] else None
			tmp['term_end'] = res[8].strftime("%Y/%m/%d") if res[8] else None
			tmp['title'] = res[9]
			tmp['station'] = res[10]
			tmp['process'] = res[11]
			tmp['expense'] = res[12]
			tmp['interview'] = res[13]
			tmp['scheme'] = res[14]
			tmp['flg_shared'] = bool(res[15])
			tmp['charging_user'] = {"id": res[16]}
			tmp['creator'] = {"id": res[17]}
			tmp['modifier'] = {"id": res[18]}
			tmp['dt_created'] = res[19].strftime("%Y/%m/%d %H:%M:%S") if res[19] else None
			tmp['dt_modified'] = res[20].strftime("%Y/%m/%d %H:%M:%S") if res[20] else None
			tmp['is_enabled'] = bool(res[21])
			tmp['note'] = res[22]
			tmp['term'] = res[23]
			tmp['skill_needs'] = res[24]
			tmp['skill_recommends'] = res[25]
			tmp['age_from'] = res[26]
			tmp['age_to'] = res[27]
			tmp['rank_id'] = res[28]
			tmp['rank'] = res[29]
			tmp['skill_list'] = res[30]
			tmp['skill_id_list'] = res[31]
			tmp['occupation_list'] = res[32]
			tmp['occupation_id_list'] = res[33]
			tmp['worker_id_list'] = res[34]
			tmp['station_cd'] = res[35]
			tmp['station_pref_cd'] = res[36]
			tmp['station_line_cd'] = res[37]
			tmp['station_lon'] = res[38]
			tmp['station_lat'] = res[39]
			tmp['flg_public'] = res[40]
			tmp['web_public'] = res[41]
			tmp['flg_foreign'] = res[42]
			tmp['internal_note'] = res[43]
			result.append(tmp)
		return result

	@classmethod
	def __cvt_search_projects(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['client'] = {"id": res[1]}
			tmp['client_name'] = res[2]
			tmp['fee_inbound'] = res[3]
			tmp['fee_inbound_comma'] = res[4]
			tmp['fee_outbound'] = res[5]
			tmp['fee_outbound_comma'] = res[6]
			tmp['term_begin'] = res[7].strftime("%Y/%m/%d") if res[7] else None
			tmp['term_end'] = res[8].strftime("%Y/%m/%d") if res[8] else None
			tmp['title'] = res[9]
			tmp['station'] = res[10]
			tmp['process'] = res[11]
			tmp['expense'] = res[12]
			tmp['interview'] = res[13]
			tmp['scheme'] = res[14]
			tmp['flg_shared'] = bool(res[15])
			tmp['charging_user'] = {"id": res[16]}
			tmp['creator'] = {"id": res[17]}
			tmp['modifier'] = {"id": res[18]}
			tmp['dt_created'] = res[19].strftime("%Y/%m/%d %H:%M:%S") if res[19] else None
			tmp['dt_modified'] = res[20].strftime("%Y/%m/%d %H:%M:%S") if res[20] else None
			tmp['is_enabled'] = bool(res[21])
			tmp['note'] = res[22]
			tmp['term'] = res[23]
			tmp['skill_needs'] = res[24]
			tmp['skill_recommends'] = res[25]
			tmp['age_from'] = res[26]
			tmp['age_to'] = res[27]
			tmp['rank'] = res[28]
			tmp['skill'] = res[29]
			tmp['skill_count'] = res[30]
			tmp['occupation'] = res[31]
			tmp['occupation_count'] = res[32]
			tmp['worker_id_list'] = res[33]
			tmp['travel_time'] = u"--"
			if res[34] is not None:
				if int(res[34]) > 90:
					tmp['travel_time'] = u"90???"
				else:
					tmp['travel_time'] = int(res[34])
			tmp['owner_company_id'] = res[35]
			tmp['owner_company_name'] = res[36]
			tmp['user_id_list'] = res[37]
			tmp['flg_foreign'] = int(res[38])
			tmp['flg_foreign_text'] = u"???" if int(res[38]) == 1 else u"??????"
			tmp['flg_public'] = bool(res[39])
			tmp['web_public'] = bool(res[40])
			tmp['create_from_promo'] = res[41]
			tmp['tel'] = res[42]
			tmp['internal_note'] = res[43]
			tmp['skill_level_list'] = []
			result.append(tmp)
		return result

	@classmethod
	def __cvt_related_skills(cls, cur):
		result = {}
		for res in cur:
			tmp = {}
			tmp['id'] = res[1]
			tmp['name'] = res[2]
			if res[0] not in result:
				result[res[0]] = []
			result[res[0]].append(tmp)
		return result

	@classmethod
	def __cvt_enum_clients(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "name": res[1]})
		return result

	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "group_id": res[1], "group_name": res[2], "login_id": res[3], "user_name": res[4], "is_enabled": bool(res[5])})
		return result

	@classmethod
	def __cvt_create_engineer(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {"id": res[0]}
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_create_engineer_note(cls, cur):
		pass

	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['id'] = tmp[0] if tmp and tmp[0] > 0 else None
		return result

	@classmethod
	def __cvt_enum_project_skill_levels(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['project_id'] = res[0]
			tmp['skill_id'] = res[1]
			tmp['level'] = res[2]
			result.append(tmp)
		return result

	@classmethod
	def __cvt_count_last_three_days(cls, cur):
		result = {}
		tmp = cur.fetchone()
		result['count'] = tmp[0] if tmp else 0
		result['date'] = tmp[1].strftime("%m/%d") if tmp else None
		return result