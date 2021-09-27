#-*- coding: UTF-8 -*-

import sys
import StringIO
import xml.dom.minidom as DOM
try:
	import lxml.etree as ETREE
	sys.stderr.write("ElementTree is from external 'lxml' module.\n")
except ImportError:
	import xml.etree.ElementTree as ETREE
	sys.stderr.write("ElementTree is from built-in 'xml' module.\n")

class Marshall(object):
	@classmethod
	def Dom(clsObj, obj=None):
		return DOM.parseString(clsObj.obj2xml(obj))
	
	@classmethod
	def ETree(clsObj, obj=""):
		et = ETREE.ElementTree()
		et.parse(StringIO.StringIO(clsObj.obj2xml(obj)))
		return et
	
	@staticmethod
	def obj2xml(data=None, rootName="root"):
		dom = DOM.parseString("""<?xml version="1.0"?><%s/>""" % rootName.replace(" ", ""))
		root = dom.firstChild
		def parse(obj, node, key=None):
			tmpNode = None
			if isinstance(obj, basestring):
				tmpNode = dom.createElement("string")
				tmpCNode = dom.createCDATASection(obj)
				tmpNode.appendChild(tmpCNode)
			elif isinstance(obj, bool):
				tmpNode = dom.createElement("boolean")
				tmpCNode = dom.createTextNode(str(obj))
				tmpNode.appendChild(tmpCNode)
			elif isinstance(obj, int) or isinstance(obj, long) or isinstance(obj, float):
				tmpNode = dom.createElement("number")
				tmpCNode = dom.createTextNode(str(obj))
				tmpNode.appendChild(tmpCNode)
			elif isinstance(obj, list) or isinstance(obj, tuple):
				tmpNode = dom.createElement("array")
				tmpNode.setAttribute("length", str(len(obj)))
				[parse(el, tmpNode) for el in obj]
			elif isinstance(obj, set) or isinstance(obj, frozenset):
				tmpNode = dom.createElement("set")
				tmpNode.setAttribute("length", str(len(obj)))
				[parse(el, tmpNode) for el in obj]
			elif isinstance(obj, dict):
				tmpNode = dom.createElement("hashmap")
				tmpNode.setAttribute("length", str(len(obj.keys())))
				[parse(obj[k], tmpNode, k) for k in obj]
			elif obj is None:
				tmpNode = dom.createElement("undefined")
			else:
				pass
			if tmpNode and key:
				tmpNode.setAttribute("name", key)
			if tmpNode:
				node.appendChild(tmpNode)
			else:
				raise ValueError(obj, node)
		parse(data, root)
		return dom.toprettyxml("", "", "UTF-8")