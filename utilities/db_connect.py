#!/usr/local/bin/python
# -*- coding: utf-8 -*-

import mysql.connector as DBS


def connect2prod_schema(prod_level="develop"):
	if prod_level == "develop":
		con = DBS.connect(**{\
			"host": "inter-plug.co.jp",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "uchimura",\
			"db": "c4s_devel",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	elif prod_level == "pool":
		con = DBS.connect(**{\
			"host": "153.121.48.45",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "k-uchimura",\
			"db": "c4s_pool",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	elif prod_level == "prod":
		con = DBS.connect(**{\
			"host": "153.121.48.45",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "k-uchimura",\
			"db": "c4s_prod",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	else:
		con = None
	return con

def connect2log_schema(prod_level="develop"):
	if prod_level == "develop":
		con = DBS.connect(**{\
			"host": "inter-plug.co.jp",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "uchimura",\
			"db": "c4s_log",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	elif prod_level == "pool":
		con = DBS.connect(**{\
			"host": "153.121.48.45",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "k-uchimura",\
			"db": "c4s_log",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	elif prod_level == "prod":
		con = DBS.connect(**{\
			"host": "153.121.48.45",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "k-uchimura",\
			"db": "c4s_log",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	else:
		con = None
	return con

def connect2report_schema(prod_level="develop"):
	if prod_level == "develop":
		con = DBS.connect(**{\
			"host": "inter-plug.co.jp",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "uchimura",\
			"db": "c4s_report",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	elif prod_level == "pool":
		con = DBS.connect(**{\
			"host": "153.121.48.45",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "k-uchimura",\
			"db": "c4s_report",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	elif prod_level == "prod":
		con = DBS.connect(**{\
			"host": "153.121.48.45",\
			"port": 3306L,\
			"user": "k-uchimura",\
			"passwd": "k-uchimura",\
			"db": "c4s_report",\
			"charset": "utf8",\
			"collation": "utf8_bin",\
			"use_unicode": True,\
			"buffered": True,\
			"compress": True,\
		})
	else:
		con = None
	return con
