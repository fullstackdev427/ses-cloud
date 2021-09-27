#!/usr/local/bin/python
# -*- coding: UTF-8 -*-

from db_connect import connect2prod_schema
from pprint import pprint
import sys
import traceback

def delete_target_id(table_name, limits):
	population = """
	SELECT
	    `TGT`.`id`,
	    `MUP`.`company_id`,
	    `TGT`.`dt_created`,
	    `TGT`.`dt_modified`
	    FROM `mt_user_persons` AS `MUP`
	    INNER JOIN `%s` AS `TGT`
		ON `MUP`.`id` = `TGT`.`creator_id`
	    WHERE `TGT`.`is_enabled` = FALSE
	; 
	"""
	con = connect2prod_schema(prod_level)
	try:
		cur = con.cursor()
		cur.execute(population % table_name)
	except:
		print traceback.format_exc()
		con.rollback()
		con.close()
		raise SystemExit
	else:
		for id, com, cre, mod in cur:
			store_date = None
			for owner_id, value in limits:
				if owner_id == 0 or com == owner_id:
					store_date = value
				else:
					pass
			if not store_date:
				raise SystemExit, "no LMT_LEN_STORE_DATE."
			elif cre.date() < store_date and mod.date() < store_date:
				yield id
			else:
				pass
		con.close()

def delete_binaries_no_more(con, cur, limits):
	delete_no_reference = """
DELETE FROM `ft_binaries`
    WHERE `id` NOT IN (
        SELECT
            DISTINCT `SRC`.`bin_id`
            FROM (
                SELECT
                    `bin_id`
                    FROM `cr_engineer_bin`
                UNION ALL (
                    SELECT
                        `bin_id`
                        FROM `cr_fmt_bin`
                ) UNION ALL (
                    SELECT
                        `bin_id`
                        FROM `cr_mail_bin`
                )
            ) AS `SRC`
            ORDER BY `SRC`.`bin_id`
    )
;
"""
	un_enabled = """
SELECT
    `FB`.`id`,
    `MUP`.`company_id`,
    `FB`.`dt_created`
    FROM `mt_user_persons` AS `MUP`
    INNER JOIN `ft_binaries`AS `FB`
        ON `MUP`.`id` = `FB`.`creator_id`
    WHERE `FB`.`is_enabled` = FALSE
;
"""
	try:
		cur.execute(delete_no_reference)
	except:
		print traceback.format_exc()
		con.rollback()
	else:
		print cur.statement
		print cur.rowcount
		con.commit()

	try:
		cur.execute(un_enabled)
		target_ids = []
		for id, com, cre in cur:
			store_date = None
			for owner_id, value in limits:
				if owner_id == 0 or com == owner_id:
					store_date = value
				else:
					pass
			if not store_date:
				raise SystemExit, "no LMT_LEN_STORE_DATE."
			elif cre.date() < store_date:
				target_ids.append(id)
			else:
				pass
		if len(target_ids) is 0:
			pass
		elif len(target_ids) is 1:
			cur.execute("DELETE FROM `ft_binaries` WHERE `id` = %s;", target_ids[0])
		else:
			cur.execute("DELETE FROM `ft_binaries` WHERE `id` IN %s;" % repr(tuple(target_ids)))
	except:
		print traceback.format_exc()
		con.rollback()
	else:
		print cur.statement
		print cur.rowcount
		con.commit()
		

def delete_mail_no_more(con, cur, limits):
	"""
	ft_mailsからは最新20件以外のメールを削除する
	"""
	insert_bk_ft_mails_query = """
INSERT INTO `bk_ft_mails`
    SELECT
        `OFM`.*
        FROM `ft_mails` AS `OFM`
        WHERE (
            SELECT
                COUNT(1)
                FROM `ft_mails` AS `FM`
                WHERE `FM`.`creator_id` = `OFM`.`creator_id`
                    AND `FM`.`dt_modified` > `OFM`.`dt_modified`
                    AND `FM`.`is_enabled` = TRUE
        ) >= 20
        ORDER BY `OFM`.`id`
;
"""
	insert_bk_ft_mail_queue_query = """
INSERT INTO `bk_ft_mail_queue`
    SELECT
        *
        FROM `ft_mail_queue`
        WHERE `request_id` IN (
            SELECT
                `id`
                FROM `bk_ft_mails`
        )
;
"""
	delete_ft_mails_query = """
DELETE FROM `ft_mails`
    WHERE `id` IN (
        SELECT
            `id`
            FROM `bk_ft_mails`
    )
;
"""
	try:
		cur.execute(insert_bk_ft_mails_query)
	except:
		print traceback.format_exc()
		con.rollback()
	else:
		print cur.statement
		print cur.rowcount
		con.commit()

	try:
		cur.execute(insert_bk_ft_mail_queue_query)
	except:
		print traceback.format_exc()
		con.rollback()
	else:
		print cur.statement
		print cur.rowcount
		con.commit()

	try:
		cur.execute(delete_ft_mails_query)
	except:
		print traceback.format_exc()
		con.rollback()
	else:
		print cur.statement
		print cur.rowcount
		con.commit()

def delete_mt_client_no_more(cur, limits):
	"""
	mt_projectsのclient_idがconstraintでmt_clientのidを縛っており、
	on deleteが指定されていないため、それをon delete set nullにしてあげる事で、
	削除可能になると思われる。
	"""
	pass

if __name__ == "__main__":
	lmt_len_store_date = """
	SELECT
	    `owner_id`,
	    DATE_ADD(CURRENT_DATE, INTERVAL -`value` DAY)
	    FROM `ft_prefs`
	    WHERE `key` = 'LMT_LEN_STORE_DATE'
	    ORDER BY `owner_id`
	;
	"""

	delete_query = """
	DELETE FROM `%s` WHERE `id` %s;
	"""

	target_tables = (
		'ft_client_contacts',
		'ft_negotiations',
		'ft_preparations',
		'ft_schedules',
		'ft_todos',
		'mt_client_branches',
		'mt_client_workers',
		'mt_engineers',
		'mt_projects',
	)

	prod_level = sys.argv[1] if len(sys.argv) is 2 else "develop"
	con = connect2prod_schema(prod_level)
	try:
		cur = con.cursor()
		cur.execute(lmt_len_store_date)
	except:
		print traceback.format_exc()
		con.rollback()
		con.close()
		raise SystemExit
	else:
		limits = cur.fetchall()

	for table in target_tables:
		target_ids = [id for id in delete_target_id(table, limits)]
		try:
			if len(target_ids) is 0:
				continue
			cur.execute(delete_query % (table, "IN %s" % repr(tuple(target_ids)) if len(target_ids) > 1 else "= %s" % target_ids[0]))
		except:
			print traceback.format_exc()
			con.rollback()
		else:
			print cur.statement
			print cur.rowcount
			con.commit()

	delete_binaries_no_more(con, cur, limits)
	delete_mail_no_more(con, cur, limits)
	con.close()
