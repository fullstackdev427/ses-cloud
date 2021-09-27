#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

class Argument(object):
	
	"""
		This class is typedef.
	"""
	
	__data__ = None
	__files__ = None
	
	def __init__(self):
		self.__data__ = {}
		self.__files__ = {}
	
	def setData(self, data):
		self.__data__ = data
	
	def setFile(self, name, file_obj):
		if name in self.__files__ and not isinstance(self.__files__, list):
			self.__files__[name] = [self.__files__[name], file_obj]
		else:
			self.__files__[name] = file_obj
	
	def clear(self):
		self.__data__ = {}
		self.__files__ = {}
	
	@property
	def data(self):
		return self.__data__
	
	@property
	def files(self):
		return self.__files__