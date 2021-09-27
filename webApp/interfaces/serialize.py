#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module declares base class of Serializer.
"""

class SerializerBase(object):
	
	"""
		Base class of serializer.
	"""
	__pref__ = None
	process_list = None
	def __init__(self, pref):
		self.__pref__ = pref
		self.process_list = [self.marshall]
	
	def marshall(self, chain_env):
		pass