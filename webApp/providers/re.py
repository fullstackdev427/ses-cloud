# !/usr/local/bin/python
# -*- coding: UTF-8 -*-

try:
    import ujson as JSON
except ImportError:
    try:
        import czjson as JSON
    except ImportError:
        try:
            import json as JSON
        except ImportError:
            try:
                import simplejson as JSON
            except ImportError:
                raise EXC.DeployError("No JSON module has been found.", 1001)
import flask

from models.argument import Argument
from errors import exceptions as EXC


class Re(object):
    """
        This class provides parsers of arguments.
    """

    __parser__ = None

    def __init__(self):
        pass

    def __call__(self):
        return []

    @classmethod
    def _fn_double_escape(self, pattern):

        "Escape all non-alphanumeric characters in pattern."
        alphanum = frozenset("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
        s = list(pattern)
        # alphanum = re._alphanum
        for i, c in enumerate(pattern):
            if c not in alphanum:
                if c == "\000":
                    s[i] = "\\\\000"
                else:
                    s[i] = "\\\\" + c
        return pattern[:0].join(s)