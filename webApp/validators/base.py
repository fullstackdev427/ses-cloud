# -*- coding: utf-8 -*-

u"""バリデータの基本クラスとその用法を示したものです。

:Authors: - 中塚 寛幸
          - 太田 飛鳥
:Status: Stable
:Version: 1.0
:Date: 2011/09/20
"""

import re
import traceback

from XmlMarshall import Marshall
class ValidatorErrorBase(Exception):pass
class ValidatorLogicError(ValidatorErrorBase):pass

__DEBUG__ = False

class ValidatorBase(object):
	u"""バリデータの基本クラスです。
	
	:Author: 中塚 寛幸
	"""
	
	def __valid_nullable(self, vector, defval):# Not used. Migrated to lambda.
		if defval is False:
			for e in vector:
				if e.tag in ("hashmap", "array", "set"):
					if not e.getchildren():
						return False
				else:
					if not e.text:
						return False
		return True
	
	def __valid_min(self, vector, defval):
		for e in vector:
			if e.tag=="string":
				if len(e.text) < defval:
					return False
			elif e.tag in ("array", "set"):
				if len(e.getchildren()) < defval:
					return False
			elif e.tag=="number":
				if e.text.replace(".", "")!=e.text:
					if float(e.text) < defval:
						return False
				elif long(e.text) < defval:
					return False
		return True
	
	def __valid_max(self, vector, defval):
		for e in vector:
			if e.tag=="string":
				if len(e.text) > defval:
					return False
			elif e.tag in ("array", "set"):
				if len(e.getchildren()) > defval:
					return False
			elif e.tag=="number":
				if e.text.replace(".", "")!=e.text:
					if float(e.text) > defval:
						return False
				elif long(e.text) > defval:
					return False
		return True
	
	def test(self, rule=None, target=None):
		u"""与えられたルールでターゲットのバリデーションを行います。
		
		:Author: 中塚 寛幸
		:Fixed: 太田 飛鳥
		:Param rule: dictionary of rule
		:Param target: anyobject except None
		:Return: tuple of (boolean , array of string)
		
		パッケージの主たる機能です。rule , target の意味合い、用法はパッケージ
		の説明で記述した通りです。内部的には、与えられたターゲットオブジェクト
		をXMLに変換し、ruleに与えられているXPath式を辿って条件に合致する要素で
		構成されているかを監査しています。監査の結果は文字列の列として保持され、
		戻り値に含まれます。
		
		戻り値はタプルで返され、第一要素が監査の成功失敗を示し、第二要素が監査
		時に得た評価のログになります。ログは主に監査失敗の問題追求のために提供
		され、全要素の監査結果が保持されます。
		"""
		if not isinstance(rule, dict) or not rule or not target:
			raise ValueError("'rule' has invalid class-type or None.") if not isinstance(rule, dict) or not rule else ValueError("'target' is not filled.")
		log = []
		#[begin] Prepare target.
		tgtEt = Marshall.ETree(target)
		#[end] Prepare target.
		#[begin] Prepare rule actions.
		valids = {}
		# 'vector' is list of XPath matched elements.
		# 'defval' is a member of rule dict object.
		# vector = args[0], defval = args[1], parentVector = args[2], vectorXpath = args[3]
		valids['type'] = lambda *args: False if [False for e in args[0] if e.tag!=args[1]] else True
		valids['need'] = lambda *args: False if args[1] and args[3]!="" and len([True for pe in args[2] if [True for vector in pe.getchildren() if vector.findall(args[3]) > 0]])!=len(args[0]) else True# Logical Bug.
		valids['nullable'] = lambda *args: False if args[1] is False and [False for e in args[0] if ((e.tag in ("string", "number", "boolean") and e.text=="") or (e.tag in ("hashmap", "array") and len(e.getchildren())==0))] else True
		valids['min'] = lambda *args: self.__valid_min(args[0], args[1])
		valids['max'] = lambda *args: self.__valid_max(args[0], args[1])
		valids['memberKey'] = lambda *args: False if [False for e in args[0] if [False for ec in e.getchildren() if ec.get("name") not in args[1]]] else True
		valids['restrict'] = lambda *args: False if [False for e in args[0] if not re.match(args[1], e.text) or e.text!=e.text[re.match(args[1], e.text).start():re.match(args[1], e.text).end()]] else True# Experimental
		valids['candidates'] = lambda *args: False if [False for e in args[0] if e.text not in args[1]] else True
		valids['generic'] = lambda *args: False if [False for e in args[0] if [False for ec in e.getchildren() if ec.tag!=args[1]]] else True
		#[end] Prepare rule actions.
		def results():
			def logger(txt=""):
				global __DEBUG__
				if isinstance(txt, basestring):
					log.append(txt)
					if __DEBUG__:
						print log[-1]
			for xpath in sorted(rule.keys()):
				vector = tgtEt.findall(xpath)
				logger("<xpath> [vector.length]:  <%s> [%d]" % (xpath, len(vector)))
				if vector:
					logger("    tags: [%s], names: [%s], texts: [%s]" % (", ".join(set([v.tag for v in vector])), ", ".join(set([v.get("name", default="") for v in vector])), ", ".join(set([v.text if v.text is not None else "" for v in vector]))))
				for rk in sorted(rule[xpath].keys()):
					localResult = None
					if (len(vector)==1 and len(tgtEt.getroot().getchildren())==1 and tgtEt.getroot().getchildren()[0] is vector[0]):#Obviously, super element must exist.
						if rk=="need":
							localResult = True
						else:
							localResult = valids[rk](vector, rule[xpath][rk])
					else:
						localResult = valids[rk](vector, rule[xpath][rk], tgtEt.findall("/".join(xpath.split("/")[:-1])) if xpath.split("/") else "", xpath)
					logger("      rule key: %s=%s <%s>" % (rk,rule[xpath][rk],localResult))
					yield localResult
		return reduce(lambda x, y: x and y, results()), log
	
	def logTrim(self, logs):
		u"""test関数で取得した監査ログを圧縮します。
		
		:Author: 太田 飛鳥
		:Parameter logs: array of string
		:Return: array of string
		
		test関数戻り値の第二要素として与えられる監査ログを対象にした関数です。
		監査ログには全要素の監査結果が保持され、成功した監査の情報も含んで
		います。この関数は監査ログから監査失敗に関係のない要素を除去した監査
		ログを返します。
		"""
		ret = []
		tmp = []
		flag = False
		for l in logs:
			if l.startswith("<xpath>"):
				if flag:
					ret.extend(tmp)
				flag = False
				tmp=[]
			tmp.append(l)
			if l.find("<False>")>0:
				flag=True
		if flag:
			ret.extend(tmp)
		return ret
	
	def validate(self, target):
		return False#Invalid.

if __name__=="__main__":
#		__DEBUG__ = True
		I = ValidatorBase()
		req = {"requestType":"XML","requestBody":"nantoka","queryId":"ab"}
		R = {}
		R["""hashmap"""]= {"type": "hashmap", "need": True, "nullable": False}
		R["""hashmap/string[@name='requestType']"""]={"type":"string", "need": True, "nullable":False, "restrict":"""XML|JSON|QString"""}
		R["""hashmap/string[@name='requestBody']"""]={"type":"string", "need": True, "nullable":False}
		R["""hashmap/number[@name='queryId']"""]={"type":"number", "need": False, "nullable":False}
		#print I.test(R, req)[0]
		print I.logTrim(I.test(R, req)[1])

if False:
	__DEBUG__ = True
	I = ValidatorBase()
	D1 = [{"queryId": "foo1", "queryType": "pv", "spot_id": "foo2", "deviceType": "all", "range":{"begin": "20110701", "end": "20110718"}}, {"queryId": "foo3", "queryType": "pv", "spot_id": "foo4", "deviceType": "all", "rangeType": "week", "range":{"begin": "20110701", "end": "20110718"}}]
	R1 = {}
	R1["""array"""] = {"type": "array", "need": True, "nullable": False, "generic": "hashmap", "min": 1}
	R1["""array/hashmap/string[@name='queryId']"""] = {"type": "string", "need": True, "nullable": False, "restrict": """[^ ]+"""}
	R1["""array/hashmap/string[@name='queryType']"""] = {"type": "string", "need": True, "nullable": False, "restrict": """[^ ]+""", "candidates": ("pv", "usageCouponCount", "usageCouponCountUser")}
	R1["""array/hashmap/string[@name='spot_id']"""] = {"type": "string", "need": True, "nullable": False, "restrict": """[^ 0][^ ]+"""}
	R1["""array/hashmap/string[@name='deviceType']"""] = {"type": "string", "need": False, "nullable": True, "candidates": ("pc", "mb", "sp", "all")}
	R1["""array/hashmap/string[@name='rangeType']"""] = {"type": "string", "need": True, "nullable": False}
	R1["""array/hashmap/hashmap[@name='range']"""] = {"type": "hashmap", "need": True, "nullable": False, "memberKey": ("begin", "end")}
	R1["""array/hashmap/hashmap[@name='range']/string[@name='begin']"""] = {"type": "string", "need": True, "nullable": False}
	R1["""array/hashmap/hashmap[@name='range']/string[@name='end']"""] = {"type": "string", "need": True, "nullable": False}
	D2 = [{"queryId": "foo1", "queryType": "pv", "spot_id": "0foo2", "deviceType": "all", "rangeType": "week", "range":{"begin": "20110701", "end": "20110718"}}]
	if __DEBUG__:
		#print Marshall.Dom(D2).toprettyxml("  ", "\n")
		#print "=========="
		pass
	print "\n=====> D1 <====="
	print I.test(R1, D1)[0]
	print "\n=====> D2 <====="
	print I.test(R1, D2)[0]
