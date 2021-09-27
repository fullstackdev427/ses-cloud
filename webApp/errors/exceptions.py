#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

class ErrorBase(Exception):
	
	"""
	This base class indicates errors throwed by application.
		ErrorCodes:
			1000: (default)
	"""
	__trace__ = None
	__errmsg__ = "(default)"
	__errno__ = 1000L
	CODE_1000 = "(default)"
	
	def __init__(self, msg="", no=1000, trace_text=None):
		self.__errno__  = no if no and isinstance(no, (int, long)) else 1000L
		try:
			self.__errmsg__ = msg if msg else getattr(self, "CODE_%d" % self.__errno__)
		except:
			self.__errmsg__ = "(not implemented)"
	
	def __getattr__(self, name):
		if name == "msg":
			return self.__errmsg__
		elif name == "no":
			return self.__errno__
		elif name == "trace":
			return self.__trace__
	
	def __repr__(self):
		return repr([self.message, self.no, self.trace])
	
	def __str__(self):
		return "(%s, %d, %s)" % (self.msg if isinstance(self.msg, basestring) else repr(self.msg), self.no, self.trace)

class MappingError(ErrorBase):
	
	"""
	This class indicates errors of URL mapped logic module importing.
		ErrorCodes:
			1000: (default)
			1001: module importing error.
			1002: class membership error.
	"""
	CODE_1001 = "module importing error"
	CODE_1002 = "class membership error"

class DeployError(ErrorBase):
	
	"""
	This class indicates errors of module or infrastructure miss-operations.
		ErrorCodes:
			1000: (default)
			1001: Modules insufficient.
	"""
	CODE_1001 = "module insufficient"

class ModelError(ErrorBase):
	
	"""
	This class indicates errors on models.
	"""
	CODE_1001 = "SQL statement is not found."
	CODE_1002 = "Converter function is not found."