#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

import copy
import pprint

from serialize import SerializerBase

class DumpSerializer(SerializerBase):
	
	"""
		This class provides JSONize functionality.
	"""
	def marshall(self, chain_env):
		#if "propagate" in chain_env and chain_env['propagate']:
		if True:
			chain_env['mime'] = "text/plain"
			chain_env['headers']['Content-type'] = "text/plain; charset=UTF-8"
			chain_env['response_body'] = pprint.pformat(chain_env['results'] if "results" in chain_env else copy.deepcopy(chain_env))
		