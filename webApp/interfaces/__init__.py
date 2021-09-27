#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

from dump import DumpSerializer as DUMP
from json import JsonSerializer as JSON
from html import HtmlRenderer as HTML

def cleanup(chain_env):
	if "prod_level" in chain_env and chain_env['prod_level'] != "develop":
		del chain_env['trace']
		del chain_env['validate']