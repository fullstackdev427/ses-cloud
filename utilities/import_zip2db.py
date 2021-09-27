#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import os
import urllib
import zipfile
import sys
import pprint
import traceback
import mysql.connector as DBS
from db_connect import connect2prod_schema

kogaki_zip_url = 'http://www.post.japanpost.jp/zipcode/dl/kogaki/zip/ken_all.zip'
ziped_ken_all, headers = urllib.urlretrieve(kogaki_zip_url, './ken_all.zip')
try:
    with zipfile.ZipFile(ziped_ken_all, 'r') as ken_zip:
        ken_zip.extract('KEN_ALL.CSV', './')
except:
    print traceback.format_exc()
    print headers.items()
    raise SystemExit

if not os.path.isfile('./KEN_ALL.CSV'):
    raise SystemExit, "KEN_ALL.CSV doesn't exist."

hdl = open("./KEN_ALL.CSV", "Ur")
tmp = hdl.readline()
con = connect2prod_schema(sys.argv[1] if len(sys.argv) > 1 else "develop")
cur = con.cursor()

try:
	cur.execute("TRUNCATE TABLE `mt_zip_tmp`;")
	cur.execute("TRUNCATE TABLE `mt_zip_codes`;")
except:
	print traceback.format_exc()
	raise SystemExit, "Failed Truncate"

while tmp:
	tmp = unicode(tmp, "sjis")
	cols = tmp.split(",")
	cols = tuple([col[1:-1].strip() if col.startswith('"') and col.endswith('"') else col.strip() for col in cols])
	try:
		cur.execute("""INSERT INTO `mt_zip_tmp` (`code_jis`, `code_zip_old`, `code_zip_new`, `kana_addr1`, `kana_addr2`, `kana_addr3`, `name_addr1`, `name_addr2`, `name_addr3`, `flg_1`, `flg_2`, `flg_3`, `flg_4`, `flg_5`, `flg_6`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s);""", params=cols)
	except:
		print traceback.format_exc()
		con.rollback()
		con.close()
		hdl.close()
		raise SystemExit()
	tmp = hdl.readline()
con.commit()
try:
	cur.execute("""SET SESSION group_concat_max_len = 10240;""")
	cur.execute("""\
INSERT INTO `mt_zip_codes`
(`code_zip`, `code_pref`, `name`)
SELECT
CASE
  WHEN LENGTH(`code_zip_new`)=6
	THEN CONCAT('0', `code_zip_new`)
  ELSE `code_zip_new`
END,
`name_addr1`,
CASE
  WHEN `name_addr3`='以下に掲載がない場合'
	THEN `name_addr2`
  WHEN INSTR(`name_addr3`, '（')
	THEN CONCAT(`name_addr2`, LEFT(`name_addr3`, INSTR(`name_addr3`, '（') - 1))
  ELSE CONCAT(`name_addr2`, `name_addr3`)
END
FROM (
  SELECT
	`code_zip_new`,
	`name_addr1`,
	`name_addr2`,
	GROUP_CONCAT(DISTINCT `name_addr3` ORDER BY `id` ASC SEPARATOR ' ') AS `name_addr3`
	FROM `mt_zip_tmp`
	GROUP BY `code_zip_new`
) AS `tmp`;""")
except:
	print traceback.format_exc()
	con.rollback()
else:
	con.commit()
con.close()
hdl.close()
