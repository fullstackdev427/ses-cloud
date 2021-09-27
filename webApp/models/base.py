#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
	This module provides model for client object.
"""

from errors import exceptions as EXC

class ModelBase(object):
	
	"""
		This class is super class for models which implements SQL and serializer.
		Members of this class MUST NOT be instantiated.
		Serializer method for database rows must be headed '__cvt_'.
	"""
	
	__class_name__ = "ModelBase"
	__SQL__ = {}
	__RULE__ = {}
	
	@classmethod
	def sql(cls, name):
		stmt = cls.__SQL__[name] if (isinstance(name, basestring) and name and name in cls.__SQL__) else None
		if stmt:
			return stmt
		else:
			raise EXC.ModelError("'%s' doesn't exists." % str(name), 1001)
	
	@classmethod
	def convert(cls, name, dbcur):
		fnc = None
		if isinstance(name, basestring) and name:
			try:
				fnc = getattr(cls, "_%s__cvt_%s" % (cls.__class_name__, name))
			except:
				pass
		if fnc and callable(fnc):
			return fnc(dbcur)
		else:
			raise EXC.ModelError("'%s' doesn't exists or can't be called." % str(name), 1002)
	
	@classmethod
	def rule(cls, name):
		rule = cls.__RULE__[name] if (isinstance(name, basestring) and name and name in cls.__RULE__) else None
		if rule:
			return rule
		else:
			raise EXC.ModelError("'%s' doesn't exists." % str(name), 1003)
	
	