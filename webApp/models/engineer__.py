#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from models.base import ModelBase

class Engineer(ModelBase):

	"""
		This class implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
	"""

	__class_name__ = "Engineer"
	__SQL__ = {\
"enum_engineers": """SELECT
  `MT`.`id`,
  `MT`.`visible_name`,
  `MT`.`name`,
  `MT`.`kana`,
  `MT`.`tel`,
  `MT`.`mail1`,
  `MT`.`mail2`,
  `MT`.`birth`,
  `MT`.`contract`,
  `MT`.`fee`,
  FORMAT(`MT`.`fee`, 0),
  `MT`.`flg_caution`,
  `MT`.`flg_registered`,
  `MT`.`flg_assignable`,
  `FT`.`note`,
  `MT`.`creator_id`,
  `MT`.`modifier_id`,
  `MT`.`dt_created`,
  `MT`.`dt_modified`,
  CASE
    WHEN `MT`.`birth` IS NULL AND `MT`.`age` IS NULL
      THEN NULL
    WHEN `MT`.`birth` IS NULL AND `MT`.`age` IS NOT NULL
      THEN `MT`.`age`
    WHEN `MT`.`birth` IS NOT NULL AND `MT`.`age` IS NOT NULL
      THEN `MT`.`age`
    WHEN DAYOFYEAR(NOW()) - DAYOFYEAR(`MT`.`birth`) > 0
      THEN YEAR(NOW()) - YEAR(`MT`.`birth`)
    ELSE YEAR(NOW()) - YEAR(`MT`.`birth`) - 1
  END AS `age`,
  `MT`.`gender`,
  `MT`.`station`,
  `MT`.`skill`,
  `MT`.`state_work`,
  `MT`.`charging_user_id`,
  `MT`.`employer`,
  `MT`.`operation_begin`,
  (SELECT group_concat(distinct name order by id  separator ',') from mt_skills ms join cr_engineer_skill ces where ms.id = ces.skill_id and ces.engineer_id = `MT`.`id`) AS skill_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_skills ms join cr_engineer_skill ces where ms.id = ces.skill_id and ces.engineer_id = `MT`.`id`) AS skill_id_list,
  (SELECT group_concat(distinct name order by name  separator ',') from mt_occupations mo join cr_engineer_ocp ceo where mo.id = ceo.occupation_id and ceo.engineer_id = `MT`.`id`) AS occupation_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_occupations mo join cr_engineer_ocp ceo where mo.id = ceo.occupation_id and ceo.engineer_id = `MT`.`id`) AS occupation_id_list,
  `MT`.`station_cd`,
  `MT`.`station_pref_cd`,
  `MT`.`station_line_cd`,
  `MT`.`station_lon`,
  `MT`.`station_lat`,
  `MT`.`flg_public`,
  `MT`.`client_id`,
  COALESCE(`CL`.`name`, `MT`.`client_name`),
  `MT`.`owner_company_id`,
  `MT`.`addr_vip`,
  `MT`.`addr1`,
  `MT`.`addr2`,
  `MT`.`flg_careful`
  FROM `mt_engineers` AS `MT`
  LEFT JOIN `ft_engineer_notes` AS `FT`
    ON `MT`.`id` = `FT`.`engineer_id`
  LEFT JOIN `mt_clients` AS `CL`
    ON `MT`.`client_id` = `CL`.`id` AND `CL`.`is_enabled` <> FALSE
  WHERE
    `MT`.`is_enabled` <> FALSE
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
    %s
  ORDER BY %s
;""", \
"enum_bp_engineers": """SELECT
	  `MT`.`id`,
	  `MT`.`visible_name`,
	  `MT`.`name`,
	  `MT`.`kana`,
	  `MT`.`tel`,
	  `MT`.`mail1`,
	  `MT`.`mail2`,
	  `MT`.`birth`,
	  `MT`.`contract`,
	  `MT`.`fee`,
	  FORMAT(`MT`.`fee`, 0),
	  `MT`.`flg_caution`,
	  `MT`.`flg_registered`,
	  `MT`.`flg_assignable`,
	  `FT`.`note`,
	  `MT`.`creator_id`,
	  `MT`.`modifier_id`,
	  `MT`.`dt_created`,
	  `MT`.`dt_modified`,
	  CASE
	    WHEN `MT`.`birth` IS NULL AND `MT`.`age` IS NULL
	      THEN NULL
	    WHEN `MT`.`birth` IS NULL AND `MT`.`age` IS NOT NULL
	      THEN `MT`.`age`
	    WHEN `MT`.`birth` IS NOT NULL AND `MT`.`age` IS NOT NULL
	      THEN `MT`.`age`
	    WHEN DAYOFYEAR(NOW()) - DAYOFYEAR(`MT`.`birth`) > 0
	      THEN YEAR(NOW()) - YEAR(`MT`.`birth`)
	    ELSE YEAR(NOW()) - YEAR(`MT`.`birth`) - 1
	  END AS `age`,
	  `MT`.`gender`,
	  `MT`.`station`,
	  `MT`.`skill`,
	  `MT`.`state_work`,
	  `MT`.`charging_user_id`,
	  `MT`.`employer`,
	  `MT`.`operation_begin`,
	  (SELECT group_concat(distinct name order by id  separator ',') from mt_skills ms join cr_engineer_skill ces where ms.id = ces.skill_id and ces.engineer_id = `MT`.`id`) AS skill_list,
	  (SELECT group_concat(distinct id order by id  separator ',') from mt_skills ms join cr_engineer_skill ces where ms.id = ces.skill_id and ces.engineer_id = `MT`.`id`) AS skill_id_list,
	  (SELECT group_concat(distinct name order by name  separator ',') from mt_occupations mo join cr_engineer_ocp ceo where mo.id = ceo.occupation_id and ceo.engineer_id = `MT`.`id`) AS occupation_list,
	  (SELECT group_concat(distinct id order by id  separator ',') from mt_occupations mo join cr_engineer_ocp ceo where mo.id = ceo.occupation_id and ceo.engineer_id = `MT`.`id`) AS occupation_id_list,
	  `MT`.`station_cd`,
	  `MT`.`station_pref_cd`,
	  `MT`.`station_line_cd`,
	  `MT`.`station_lon`,
	  `MT`.`station_lat`,
	  `MT`.`flg_public`,
	  `MT`.`owner_company_id`
	  FROM `mt_engineers` AS `MT`
	  LEFT JOIN `ft_engineer_notes` AS `FT`
	    ON `MT`.`id` = `FT`.`engineer_id`
	  WHERE
	    `is_enabled` <> FALSE
	    AND `MT`.flg_public = 1 AND EXISTS (SELECT 1 FROM mt_user_companies AS MUC WHERE MUC.id = `MT`.`owner_company_id` AND MUC.flg_public = 1 AND MUC.is_enabled = 1)
	    AND valid_user_id_read(%%s, %%s, %%s)
	    %s
	  ORDER BY %s
;""", \
"search_engineers": """SELECT
  distinct `MT`.`id`,
  `MT`.`visible_name`,
  `MT`.`name`,
  `MT`.`kana`,
  `MT`.`tel`,
  `MT`.`mail1`,
  `MT`.`mail2`,
  `MT`.`birth`,
  `MT`.`contract`,
  `MT`.`fee`,
  FORMAT(`MT`.`fee`, 0),
  `MT`.`flg_caution`,
  `MT`.`flg_registered`,
  `MT`.`flg_assignable`,
  `FT`.`note`,
  `MT`.`creator_id`,
  `MT`.`modifier_id`,
  `MT`.`dt_created`,
  `MT`.`dt_modified`,
  CASE
    WHEN `MT`.`birth` IS NULL AND `MT`.`age` IS NULL
      THEN NULL
    WHEN `MT`.`birth` IS NULL AND `MT`.`age` IS NOT NULL
      THEN `MT`.`age`
     WHEN `MT`.`birth` IS NOT NULL AND `MT`.`age` IS NOT NULL
      THEN `MT`.`age`
    WHEN DAYOFYEAR(NOW()) - DAYOFYEAR(`MT`.`birth`) > 0
      THEN YEAR(NOW()) - YEAR(`MT`.`birth`)
    ELSE YEAR(NOW()) - YEAR(`MT`.`birth`) - 1
  END AS `age`,
  `MT`.`gender`,
  `MT`.`station`,
  `MT`.`skill`,
  `MT`.`state_work`,
  `MT`.`charging_user_id`,
  `MT`.`employer`,
  (SELECT group_concat(distinct name order by id  separator ',') from mt_skills ms join cr_engineer_skill ces where ms.id = ces.skill_id and ces.engineer_id = `MT`.`id`) AS skill_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_skills ms join cr_engineer_skill ces where ms.id = ces.skill_id and ces.engineer_id = `MT`.`id`) AS skill_id_list,
  COALESCE((SELECT count(id) from mt_skills ms join cr_engineer_skill ces where ms.id = ces.skill_id and ces.engineer_id = `MT`.`id`),0) AS skill_count,
  (SELECT group_concat(distinct name order by name  separator ',') from mt_occupations mo join cr_engineer_ocp ceo where mo.id = ceo.occupation_id and ceo.engineer_id = `MT`.`id`) AS occupation_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_occupations mo join cr_engineer_ocp ceo where mo.id = ceo.occupation_id and ceo.engineer_id = `MT`.`id`) AS occupation_id_list,
  COALESCE((SELECT count(id) from mt_occupations mo join cr_engineer_ocp ceo where mo.id = ceo.occupation_id and ceo.engineer_id = `MT`.`id`),0) AS occupation_count,
  (SELECT name FROM mt_user_companies mc WHERE mc.id = `MT`.`owner_company_id`) AS company_name,
  `MT`.`operation_begin`,
  `MT`.`owner_company_id`,
  CASE WHEN `MT`.`station_lon` IS NULL OR %%s =0 THEN null ELSE travel_time_from_distance(%%s, %%s,`MT`.`station_lat`,`MT`.`station_lon`) END AS travel_time,
  `MTC`.`name`,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_client_workers mcw where mcw.client_id = `MTC`.id and mcw.is_enabled =1) AS worker_id_list,
  (SELECT group_concat(distinct id order by id  separator ',') from mt_user_persons mcp where mcp.company_id = `MT`.`owner_company_id` and mcp.is_enabled =1) AS user_id_list,
  `MTC`.`id`,
  `MT`.`flg_public`,
  `MTUC`.`tel`
  FROM `mt_engineers` AS `MT`
  JOIN `mt_user_companies` AS `MTUC`
  	ON `MTUC`.id = `MT`.`owner_company_id`
  LEFT JOIN `ft_engineer_notes` AS `FT`
    ON `MT`.`id` = `FT`.`engineer_id`
  LEFT OUTER JOIN `cr_engineer_ocp` AS `CRO`
	ON `CRO`.`engineer_id` = `MT`.`id`
  LEFT OUTER JOIN `cr_engineer_skill` AS `CRS`
	ON `CRS`.`engineer_id` = `MT`.`id`
  LEFT OUTER JOIN `mt_clients` AS `MTC`
  	ON `MTC`.id = `MT`.`client_id`
  WHERE
    `MT`.`is_enabled` <> FALSE
    AND
	`MT`.`flg_assignable` <> FALSE
    AND
  `MT`.`is_show_matching` <> FALSE
	AND
    (
		`MT`.`owner_company_id` = valid_user_company(%%s, %%s, %%s)
		OR
		`MT`.flg_public = 1 AND EXISTS (SELECT 1 FROM mt_user_companies AS MUC WHERE MUC.id = `MT`.`owner_company_id` AND MUC.flg_public = 1 AND MUC.is_enabled = 1)
    )
    %s
  ORDER BY %s
;""",\
"related_skills": """SELECT
  `T`.`engineer_id`,
  `M`.`id`,
  `M`.`name`
  FROM `%s` AS `T`
  INNER JOIN `mt_skills` AS `M`
    ON `T`.`skill_id` = `M`.`id`
  WHERE
    `T`.`engineer_id` IN (%s)
    AND `M`.`is_enabled` <> FALSE
    AND valid_company(%%s, %%s, `M`.`owner_company_id`) IS NOT NULL;""",\
"create_engineer": """INSERT INTO `mt_engineers` (
  `visible_name`, `name`, `kana`, `tel`, `mail1`, `mail2`, `birth`, `gender`, `contract`, `fee`,
  `station`, `flg_caution`, `flg_registered`, `flg_assignable`, `creator_id`, `skill`, `state_work`,
  `age`, `charging_user_id`, `employer`, `owner_company_id`, `operation_begin`,
  `station_cd`,`station_pref_cd`,`station_line_cd`,`station_lon`,`station_lat`,`flg_public`,`client_id`, `client_name`, `addr_vip`,`addr1`, `addr2`,
  `flg_careful`
  )
  VALUES (
    %s, %s, %s, %s, %s, %s, %s, %s, %s, %s,
    %s, %s, %s, %s, valid_user_id_full(%s, %s, %s), %s, %s, %s, %s, %s, valid_user_company(%s, %s, %s), %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);""",\
"create_engineer_note": """INSERT INTO `ft_engineer_notes` VALUES (%s, %s);""",\
"create_engineer_attachement": """\
INSERT INTO `cr_engineer_bin` (`key_id`, `bin_id`) VALUES (
  (
    SELECT `id` FROM `mt_engineers`
      WHERE
        `id` = %s
        AND `is_enabled`
        AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
        AND valid_user_id_full(%s, %s, %s)
  ),
  (
    SELECT `id` FROM `ft_binaries`
      WHERE
        `id` = %s
        AND `is_enabled`<>FALSE
        AND `is_temp`=TRUE
        AND valid_acl(%s, %s, `creator_id`, NULL)
        AND valid_user_id_read(%s, %s, %s)
  )
);""",\
"update_engineer": """UPDATE `mt_engineers`
  SET
    `modifier_id`=valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id`=%%s
    AND `is_enabled`<>FALSE
    AND valid_user_id_full(%%s, %%s, %%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"update_note": """INSERT INTO `ft_engineer_notes` (`engineer_id`, `note`) VALUES (%s, %s) ON DUPLICATE KEY UPDATE `note`=%s;""",\
"update_cleanup_attachement": """\
SELECT DISTINCT
  `B`.`id`
  INTO @bin_id
  FROM `ft_binaries` AS `B`
  INNER JOIN `cr_engineer_bin` AS `X`
    ON `X`.`bin_id` = `B`.`id`
  INNER JOIN `mt_engineers` AS `M`
    ON `M`.`id` = `X`.`key_id`
  WHERE
    `B`.`id` = %s
    AND `B`.`is_enabled`<>FALSE
    AND valid_acl(%s, %s, `M`.`creator_id`, `M`.`modifier_id`)
    AND valid_acl(%s, %s, `B`.`creator_id`, NULL)
    AND valid_user_id_full(%s, %s, %s);""",\
"update_cleanup_attachement_cross": """\
DELETE FROM `cr_engineer_bin`
  WHERE
    `key_id` = @bin_id;""",\
"update_upgrade_binary": """\
UPDATE `ft_binaries` SET `is_enabled`=FALSE
  WHERE
    `id` = @bin_id;""",\
"update_insert_attachement_cross": """\
INSERT INTO `cr_engineer_bin` (`key_id`, `bin_id`) VALUES (
  (
    SELECT `id` FROM `mt_engineers`
      WHERE
        `id` = %s
        AND `is_enabled`<>FALSE
        AND valid_acl(%s, %s, `creator_id`, `modifier_id`)
        AND valid_user_id_full(%s, %s, %s)
  ),
  (
    SELECT `id` FROM `ft_binaries`
      WHERE
        `id` = %s
        AND `is_enabled`<>FALSE
        /*AND `is_temp` = TRUE*/
        AND valid_acl(%s, %s, `creator_id`, NULL)
        AND valid_user_id_read(%s, %s, %s)
  )
);""",\
"update_upgrade_binary_upd": """\
UPDATE `ft_binaries` SET `is_temp`=FALSE
  WHERE
    `id` = %s;""",\
"delete_engineer": """UPDATE
  `mt_engineers` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"set_skills": """INSERT INTO `%s` (`engineer_id`, `skill_id`)
  SELECT
    (
      SELECT
        `id`
        FROM `mt_engineers`
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
"set_occupations": """INSERT INTO `%s` (`engineer_id`, `occupation_id`)
		  SELECT
		    (
		      SELECT
		        `id`
		        FROM `mt_engineers`
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
"enum_preparations": """\
SELECT
  `P`.`id`,
  `P`.`engineer_id`,
  `P`.`client_id`,
  COALESCE(`C`.`name`, `P`.`client_name`),
  `P`.`progress`,
  `P`.`note`,
  `P`.`creator_id`,
  `P`.`modifier_id`,
  `P`.`dt_created`,
  `P`.`time`
  FROM `ft_preparations` AS `P`
  LEFT JOIN (
    SELECT
      `id`,
      `name`
      FROM `mt_clients`
      WHERE
        `is_enabled`<>FALSE
        AND (
            `creator_id` IN (
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
            OR `modifier_id` IN (
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
  ) AS `C`
    ON `P`.`client_id` = `C`.`id`
  WHERE
    %s
    AND `P`.`is_enabled`<>FALSE
    AND valid_acl(%%s, %%s, `P`.`creator_id`, `P`.`modifier_id`)
    AND valid_user_id_read(%%s, %%s, %%s)
  ORDER BY COALESCE(`P`.`dt_modified`, `P`.`dt_created`) DESC;""",\
"create_preparation": """INSERT INTO `ft_preparations` (`engineer_id`, `client_id`, `client_name`, `time`, `progress`, `note`, `creator_id`) VALUES (
  %s, %s, %s, %s, %s, %s, valid_user_id_full(%s, %s, %s));""",\
"update_preparation": """UPDATE `ft_preparations`
  SET
    `modifier_id`=valid_user_id_full(%%s, %%s, %%s),
    %s
  WHERE
    `id`=%%s
    AND `is_enabled`<>FALSE
    AND valid_user_id_full(%%s, %%s, %%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`);""",\
"delete_preparation": """UPDATE
  `ft_preparations` SET `is_enabled` = FALSE,
  `modifier_id` = valid_user_id_full(%%s, %%s, %%s),
  `dt_modified` = CURRENT_TIMESTAMP
  WHERE
    `id` IN (%s)
    AND valid_acl(%%s, %%s, `creator_id`, `modifier_id`)
    AND valid_user_id_full(%%s, %%s, %%s) IS NOT NULL;""",\
"enum_files": """\
SELECT
  `X`.`key_id`,
  `BIN`.`id`,
  `BIN`.`type_mime`,
  `BIN`.`name`,
  `BIN`.`size`,
  `BIN`.`digest`,
  `BIN`.`dt_created`
  FROM `cr_engineer_bin` AS `X`
  INNER JOIN `ft_binaries` AS `BIN`
    ON `X`.`bin_id` = `BIN`.`id`
  WHERE
    `X`.`key_id` IN (%s)
    AND `BIN`.`is_enabled`<>FALSE
    AND `BIN`.`is_temp`<>FALSE
    AND valid_acl(%%s, %%s, `BIN`.`creator_id`, NULL)
    AND valid_user_id_read(%%s, %%s, %%s);""", \
"enum_files_all": """\
	SELECT
	  `X`.`key_id`,
	  `BIN`.`id`,
	  `BIN`.`type_mime`,
	  `BIN`.`name`,
	  `BIN`.`size`,
	  `BIN`.`digest`,
	  `BIN`.`dt_created`
	  FROM `cr_engineer_bin` AS `X`
	  INNER JOIN `ft_binaries` AS `BIN`
	    ON `X`.`bin_id` = `BIN`.`id`
	  WHERE
	    `X`.`key_id` IN (%s)
	    AND `BIN`.`is_enabled`<>FALSE
	    AND `BIN`.`is_temp`<>FALSE;""", \
"enum_users": """SELECT
  `P`.`id`,
  `G`.`id`,
  `G`.`name`,
  `P`.`login_id`,
  `P`.`name`
  FROM `mt_user_persons` AS `P`
  INNER JOIN `mt_user_groups` AS `G`
    ON `G`.`id` = `P`.`group_id`
  WHERE `P`.`id` IN (%s);""", \
"enum_engineers_related_project": """SELECT
	  `MT`.`id`,
	  `MT`.`visible_name`,
	  `MT`.`name`,
	  `MT`.`kana`,
	  `MT`.`tel`,
	  `MT`.`mail1`,
	  `MT`.`mail2`,
	  `MT`.`birth`,
	  `MT`.`contract`,
	  `MT`.`fee`,
	  FORMAT(`MT`.`fee`, 0),
	  `MT`.`flg_caution`,
	  `MT`.`flg_registered`,
	  `MT`.`flg_assignable`,
	  `MT`.`creator_id`,
	  `MT`.`modifier_id`,
	  `MT`.`dt_created`,
	  `MT`.`dt_modified`,
	  `MT`.`charging_user_id`
	 FROM `mt_engineers` AS `MT`
	 JOIN `cr_prj_engineer` AS `CPE`
	  WHERE
	  	`MT`.`id` = `CPE`.`engineer_id`
	  	AND `CPE`.`project_id` = %s
	    AND `is_enabled` <> FALSE
	    AND valid_user_id_read(%s, %s, %s)
	  ORDER BY name
	;""", \
"enum_prj_engineer": """SELECT
		  `CR`.`project_id`,
		  `CR`.`engineer_id`
		 FROM `cr_prj_engineer` AS `CR`
		  WHERE
		    valid_user_id_read(%s, %s, %s)
		;""", \
"update_skill_level": """UPDATE `cr_engineer_skill` SET `level` = %s WHERE `engineer_id` = %s and `skill_id` = %s;""", \
"enum_engineer_skill_levels": """\
	SELECT
	  `P`.`engineer_id`,
	  `P`.`skill_id`,
	  `P`.`level`
	  FROM `cr_engineer_skill` AS `P`
	  WHERE
	    %s
	    ;""", \
		"last_insert_id": """SELECT LAST_INSERT_ID();""", \
"count_last_three_days": """
  SELECT
    COUNT(`id`) AS count_engineer,
    (select `dt_created` from `mt_engineers` where `is_enabled`<>FALSE order by `dt_created` desc limit 1) AS newest_engineer
    FROM `mt_engineers`
    WHERE `dt_created` >= DATE(NOW() - INTERVAL 3 DAY) + INTERVAL 0 SECOND
    AND `is_enabled`<>FALSE;""", \
"update_matching_engineer": """UPDATE `mt_engineers` SET `flg_public` = 0, `is_show_matching` = 0 WHERE `id` = %s;"""\
	}
	__RULE__ = {\
		"enum_engineers_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": True}\
			},\
		"create_engineer_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='visible_name']": {"type": "string", "need": True, "nullable": False, "max": 16},\
			"hashmap/string[@name='name']": {"type": "string", "need": True, "nullable": False, "max": 32},\
			"hashmap/string[@name='kana']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='tel']": {"type": "string", "need": True, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='mail1']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "[a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+"},\
			"hashmap/string[@name='mail2']": {"type": "string", "need": True, "nullable": True,\
				"restrict": "([a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+)?"},\
			"hashmap/string[@name='birth']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\//][0-9]{2}[\//][0-9]{2})"},\
			"hashmap/number[@name='age']": {"type": "number", "need": True, "nullable": True,},\
			"hashmap/string[@name='gender']": {"type": "string", "need": True, "nullable": False,\
				"candidates": (u"男", u"女")},\
			"hashmap/string[@name='contract']": {"type": "string", "need": True, "nullable": False,\
				"candidates": (u"正社員", u"契約社員", u"個人事業主", u"パートナー正社員", u"パートナー契約社員", u"パートナー個人事業主")},\
			"hashmap/string[@name='fee']": {"type": "string", "need": True, "nullable": False, "max": 8},\
			"hashmap/boolean[@name='flg_caution']": {"type": "boolean", "need": True, "nullable": False},\
			"hashmap/boolean[@name='flg_registered']": {"type": "boolean", "need": True, "nullable": False},\
			"hashmap/string[@name='dt_assignable']": {"type": "string", "need": True, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\-/][0-9]{2}[\-/][0-9]{2})"},\
			"hashmap/string[@name='note']": {"type": "string", "need": False, "nullable": True},\
			"hashmap/string[@name='skill']": {"type": "string", "need": False, "nullable": True, "max": 512}, \
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": False, "nullable": True, \
												 "restrict": "[0-9]{7}"}, \
			"hashmap/string[@name='addr1']": {"type": "string", "need": False, "nullable": True, "max": 64}, \
			"hashmap/string[@name='addr2']": {"type": "string", "need": False, "nullable": True, "max": 64}, \
			},\
		"update_engineer_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/string[@name='visible_name']": {"type": "string", "need": False, "nullable": False, "max": 16},\
			"hashmap/string[@name='name']": {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='kana']": {"type": "string", "need": False, "nullable": False, "max": 64},\
			"hashmap/string[@name='tel']": {"type": "string", "need": False, "nullable": False, "max": 15,\
				"restrict": "[0-9][0-9\-]+[0-9]"},\
			"hashmap/string[@name='mail1']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "[a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+"},\
			"hashmap/string[@name='mail2']": {"type": "string", "need": False, "nullable": True,\
				"restrict": "([a-zA-Z0-9_\.+\-]+@[a-z0-9_][a-z.0-9\-_]+)?"},\
			"hashmap/string[@name='birth']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\//][0-9]{2}[\//][0-9]{2})"},\
			"hashmap/number[@name='age']": {"type": "number", "need": False, "nullable": True,},\
			"hashmap/string[@name='gender']": {"type": "string", "need": False, "nullable": False,\
				"candidates": (u"男", u"女")},\
			"hashmap/string[@name='contract']": {"type": "string", "need": False, "nullable": False,\
				"candidates": (u"正社員", u"契約社員", u"個人事業主", u"パートナー正社員", u"パートナー契約社員", u"パートナー個人事業主")},\
			"hashmap/number[@name='string']": {"type": "string", "need": False, "nullable": False, "max": 8},\
			"hashmap/boolean[@name='flg_caution']": {"type": "boolean", "need": False, "nullable": False},\
			"hashmap/boolean[@name='flg_registered']": {"type": "boolean", "need": False, "nullable": False},\
			"hashmap/string[@name='dt_assignable']": {"type": "string", "need": False, "nullable": False,\
				"restrict": "([0-9]{8})|([0-9]{4}[\-/][0-9]{2}[\-/][0-9]{2})"},\
			"hashmap/string[@name='note']": {"type": "string", "need": False, "nullable": False},\
			"hashmap/string[@name='skill']": {"type": "string", "need": False, "nullable": True, "max": 512}, \
			"hashmap/string[@name='addr_vip']": {"type": "string", "need": False, "nullable": True, \
												 "restrict": "[0-9]{7}"}, \
			"hashmap/string[@name='addr1']": {"type": "string", "need": False, "nullable": True, "max": 64}, \
			"hashmap/string[@name='addr2']": {"type": "string", "need": False, "nullable": True, "max": 64}, \
			},\
		"delete_engineers_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False, "generic": "number"},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "nullable": False, "min": 1}\
		},\
		"set_skills_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='id']": {"type": "number", "need": True, "nullable": False, "min": 1},\
			"hashmap/array[@name='skills']": {"type": "array", "need": False, "nullable": False, "generic": "number"}\
		},\
		"enum_preparations_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": True},\
			"hashmap/number[@name='engineer_id']": {"type": "number", "need": False, "nullable": False, "min": 1}\
		},\
		"create_preparation_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/number[@name='engineer_id']": {"type": "number", "need": True, "nullable": False, "min": 0},\
			"hashmap/number[@name='client_id']": {"type": "number", "need": False, "nullable": True, "min": 0},\
			"hashmap/string[@name='client_name']": {"type": "string", "need": False, "nullable": False, "max": 32},\
			"hashmap/string[@name='time']": {"type": "string", "need": False, "max": 32},\
			"hashmap/string[@name='progress']": {"type": "string", "need": True, "nullable": False, "max": 64},\
			"hashmap/string[@name='note']": {"type": "string", "need": True, "nullable": False, "max": 128}\
		},\
		"delete_preparation_in": {\
			"hashmap": {"type": "hashmap", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']": {"type": "array", "need": True, "nullable": False},\
			"hashmap/array[@name='id_list']/number": {"type": "number", "need": True, "nullable": False, "min": 1}\
		}\
	}

	@classmethod
	def __cvt_enum_engineers(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['visible_name'] = res[1]
			tmp_obj['name'] = res[2]
			tmp_obj['kana'] = res[3]
			tmp_obj['tel'] = res[4]
			tmp_obj['mail1'] = res[5]
			tmp_obj['mail2'] = res[6]
			tmp_obj['birth'] = res[7].strftime("%Y/%m/%d") if res[7] else None
			tmp_obj['contract'] = res[8]
			tmp_obj['fee'] = res[9]
			tmp_obj['fee_comma'] = res[10]
			tmp_obj['flg_caution'] = bool(res[11])
			tmp_obj['flg_registered'] = bool(res[12])
			tmp_obj['flg_assignable'] = bool(res[13])
			tmp_obj['note'] = res[14]
			tmp_obj['creator'] = {"id": res[15], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[16], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[17].strftime("%Y/%m/%d %H:%M:%S") if res[17] else None
			tmp_obj['dt_modified'] = res[18].strftime("%Y/%m/%d %H:%M:%S") if res[18] else None
			tmp_obj['age'] = res[19]
			tmp_obj['gender'] = res[20]
			tmp_obj['station'] = res[21]
			tmp_obj['skill'] = res[22]
			tmp_obj['state_work'] = res[23]
			tmp_obj['charging_user'] = {"id": res[24], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['employer'] = res[25]
			tmp_obj['operation_begin'] = res[26].strftime("%Y/%m/%d") if res[26] else None
			tmp_obj['skill_list'] = res[27]
			tmp_obj['skill_id_list'] = res[28]
			tmp_obj['occupation_list'] = res[29]
			tmp_obj['occupation_id_list'] = res[30]
			tmp_obj['station_cd'] = res[31]
			tmp_obj['station_pref_cd'] = res[32]
			tmp_obj['station_line_cd'] = res[33]
			tmp_obj['station_lon'] = res[34]
			tmp_obj['station_lat'] = res[35]
			tmp_obj['flg_public'] = bool(res[36])
			tmp_obj['client_id'] = res[37]
			tmp_obj['client_name'] = res[38]
			tmp_obj['owner_company_id'] = res[39]
			tmp_obj['addr_vip'] = res[40]
			tmp_obj['addr1'] = res[41]
			tmp_obj['addr2'] = res[42]
			tmp_obj['flg_careful'] = bool(res[43])
			tmp_obj['preparations'] = []
			tmp_obj['skill_level_list'] = []
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_bp_engineers(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['visible_name'] = res[1]
			tmp_obj['name'] = res[2]
			tmp_obj['kana'] = res[3]
			tmp_obj['tel'] = res[4]
			tmp_obj['mail1'] = res[5]
			tmp_obj['mail2'] = res[6]
			tmp_obj['birth'] = res[7].strftime("%Y/%m/%d") if res[7] else None
			tmp_obj['contract'] = res[8]
			tmp_obj['fee'] = res[9]
			tmp_obj['fee_comma'] = res[10]
			tmp_obj['flg_caution'] = bool(res[11])
			tmp_obj['flg_registered'] = bool(res[12])
			tmp_obj['flg_assignable'] = bool(res[13])
			tmp_obj['note'] = res[14]
			tmp_obj['creator'] = {"id": res[15], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[16], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[17].strftime("%Y/%m/%d %H:%M:%S") if res[17] else None
			tmp_obj['dt_modified'] = res[18].strftime("%Y/%m/%d %H:%M:%S") if res[18] else None
			tmp_obj['age'] = res[19]
			tmp_obj['gender'] = res[20]
			tmp_obj['station'] = res[21]
			tmp_obj['skill'] = res[22]
			tmp_obj['state_work'] = res[23]
			tmp_obj['charging_user'] = {"id": res[24], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['employer'] = res[25]
			tmp_obj['operation_begin'] = res[26].strftime("%Y/%m/%d") if res[26] else None
			tmp_obj['skill_list'] = res[27]
			tmp_obj['skill_id_list'] = res[28]
			tmp_obj['occupation_list'] = res[29]
			tmp_obj['occupation_id_list'] = res[30]
			tmp_obj['station_cd'] = res[31]
			tmp_obj['station_pref_cd'] = res[32]
			tmp_obj['station_line_cd'] = res[33]
			tmp_obj['station_lon'] = res[34]
			tmp_obj['station_lat'] = res[35]
			tmp_obj['flg_public'] = bool(res[36])
			tmp_obj['owner_company_id'] = res[37]
			tmp_obj['preparations'] = []
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_search_engineers(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['visible_name'] = res[1]
			tmp_obj['name'] = res[2]
			tmp_obj['kana'] = res[3]
			tmp_obj['tel'] = res[4]
			tmp_obj['mail1'] = res[5]
			tmp_obj['mail2'] = res[6]
			tmp_obj['birth'] = res[7].strftime("%Y/%m/%d") if res[7] else None
			tmp_obj['contract'] = res[8]
			tmp_obj['fee'] = res[9]
			tmp_obj['fee_comma'] = res[10]
			tmp_obj['flg_caution'] = bool(res[11])
			tmp_obj['flg_registered'] = bool(res[12])
			tmp_obj['flg_assignable'] = bool(res[13])
			tmp_obj['note'] = res[14]
			tmp_obj['creator'] = {"id": res[15], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[16], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[17].strftime("%Y/%m/%d %H:%M:%S") if res[17] else None
			tmp_obj['dt_modified'] = res[18].strftime("%Y/%m/%d %H:%M:%S") if res[18] else None
			tmp_obj['age'] = res[19]
			tmp_obj['gender'] = res[20]
			tmp_obj['station'] = res[21]
			tmp_obj['skill'] = res[22]
			tmp_obj['state_work'] = res[23]
			tmp_obj['charging_user'] = {"id": res[24], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['employer'] = res[25]
			tmp_obj['skill_list'] = res[26]
			tmp_obj['skill_id_list'] = res[27]
			tmp_obj['skill_count'] = res[28]
			tmp_obj['occupation_list'] = res[29]
			tmp_obj['occupation_id_list'] = res[30]
			tmp_obj['occupation_count'] = res[31]
			tmp_obj['company_name'] = res[32]
			tmp_obj['operation_begin'] = res[33].strftime("%Y/%m/%d") if res[33] else None
			tmp_obj['owner_company_id'] = res[34]
			tmp_obj['travel_time'] = u"--";
			if res[35] is not None:
				if int(res[35]) > 90:
					tmp_obj['travel_time'] = u"90〜"
				else:
					tmp_obj['travel_time'] = int(res[35])
			tmp_obj['client_name'] = res[36]
			tmp_obj['worker_id_list'] = res[37]
			tmp_obj['user_id_list'] = res[38]
			tmp_obj['client_id'] = res[39]
			tmp_obj['flg_public'] = bool(res[40])
			tmp_obj['company_tel'] = res[41]
			tmp_obj['preparations'] = []
			tmp_obj['skill_level_list'] = []
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_preparations(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['id'] = res[0]
			tmp['engineer_id'] = res[1]
			tmp['client_id'] = res[2]
			tmp['client_name'] = res[3]
			tmp['progress'] = res[4]
			tmp['note'] = res[5]
			tmp['creator'] = {"id": res[6]}
			tmp['modifier'] = {"id": res[7]}
			tmp['dt_created'] = res[8].strftime("%Y/%m/%d %H:%M:%S") if res[8] else None
			tmp['time'] = res[9]
			result.append(tmp)
		return result

	@classmethod
	def __cvt_enum_file_dict(cls, cur):
		result = {}
		for res in cur:
			tmp = {}
			tmp['engineer_id'] = res[0]
			tmp['id'] = res[1]
			tmp['type_mime'] = res[2]
			tmp['name'] = res[3]
			tmp['size'] = res[4]
			tmp['digest'] = res[5]
			tmp['dt_created'] = res[6].strftime("%Y/%m/%d %H:%M:%S") if res[6] else None
			result[tmp['engineer_id']] = tmp
		return result

	@classmethod
	def __cvt_enum_users(cls, cur):
		result = []
		for res in cur:
			result.append({"id": res[0], "group_id": res[1], "group_name": res[2], "login_id": res[3], "user_name": res[4]})
		return result

	@classmethod
	def __cvt_create_engineer(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {"id": res[0]}
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_last_insert_id(cls, cur):
		result = None
		tmp = cur.fetchone()
		result = tmp[0] if tmp and tmp[0] > 0 else None
		return result

	@classmethod
	def __cvt_enum_engineers_related_project(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['id'] = res[0]
			tmp_obj['visible_name'] = res[1]
			tmp_obj['name'] = res[2]
			tmp_obj['kana'] = res[3]
			tmp_obj['tel'] = res[4]
			tmp_obj['mail1'] = res[5]
			tmp_obj['mail2'] = res[6]
			tmp_obj['birth'] = res[7].strftime("%Y/%m/%d") if res[7] else None
			tmp_obj['contract'] = res[8]
			tmp_obj['fee'] = res[9]
			tmp_obj['fee_comma'] = res[10]
			tmp_obj['flg_caution'] = bool(res[11])
			tmp_obj['flg_registered'] = bool(res[12])
			tmp_obj['flg_assignable'] = bool(res[13])
			tmp_obj['creator'] = {"id": res[14], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['modifier'] = {"id": res[15], "group_id": None, "group_name": None, "login_id": None}
			tmp_obj['dt_created'] = res[16].strftime("%Y/%m/%d %H:%M:%S") if res[16] else None
			tmp_obj['dt_modified'] = res[17].strftime("%Y/%m/%d %H:%M:%S") if res[17] else None
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_prj_engineer(cls, cur):
		result = []
		for res in cur:
			tmp_obj = {}
			tmp_obj['project_id'] = res[0]
			tmp_obj['engineer_id'] = res[1]
			result.append(tmp_obj)
		return result

	@classmethod
	def __cvt_enum_engineer_skill_levels(cls, cur):
		result = []
		for res in cur:
			tmp = {}
			tmp['engineer_id'] = res[0]
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