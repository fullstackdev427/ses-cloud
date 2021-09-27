#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

CHR = (\
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",\
    "a", "A", "b", "B", "c", "C", "d", "D", "e", "E",\
    "f", "F", "g", "G", "h", "H", "i", "I", "j", "J",\
    "k", "K", "l", "L", "m", "M", "n", "N", "o", "O",\
    "p", "P", "q", "Q", "r", "R", "s", "S", "t", "T",\
    "u", "U", "v", "V", "w", "W", "x", "X", "y", "Y",\
    "z", "Z",\
)

def encode(src_num, code_map = CHR):
    if not isinstance(src_num, (int, long,)):
        raise ValueError("'src_num' must be an integer but given is '%s'." % type(src_num))
    if not isinstance(code_map, (list, tuple,)) or\
        filter(lambda x: not isinstance(x, basestring) or not len(x) == 1, code_map):
        raise ValueError("'code_map' must be a sequence of a character.")
    result = "" 
    src = src_num
    while True:
        if src < len(code_map):
            result += code_map[src]
            break
        q, r = divmod(src, len(code_map))
        result += code_map[r]
        src = q
    return "".join(reversed(result))

def decode(enc_str, code_map = CHR):
    if not isinstance(enc_str, basestring):
        raise ValueError("'enc_str' must be an string but given is '%s'." % type(enc_str))
    if not isinstance(code_map, (list, tuple,)) or\
        filter(lambda x: not isinstance(x, basestring) or not len(x) == 1, code_map):
        raise ValueError("'code_map' must be a sequence of a character.")
    result = 0L
    for i, v in enumerate(reversed(enc_str)):
        result += code_map.index(v) * pow(len(code_map), i)
    return result