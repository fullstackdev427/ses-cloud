#!/usr/local/bin/python
# -*- coding: UTF-8 -*-

import time
import datetime
import pprint
import traceback

import flask

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

from providers.limitter import Limitter
from base import ProcessorBase
from errors import exceptions as EXC
from models.business import Business as Model


class Processor(ProcessorBase):
    __realms__ = { \
        "top": { \
            "logic": "html_top", \
            }, \
        }

    def _fn_html_top(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.mail import Processor as P_MAIL
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT

        # Fetch user profile.
        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        # Fetch current status for Limit.
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        # Fetch user accounts.
        status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        render_param['js.accounts'] = render_param['manage.enumAccounts']

        # Fetch client companies.
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)

        # [begin] Support objects.
        render_param['manage.enumPrefsDict'] = {}
        #[render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        # [end] Support objects.
        chain_env['response_body'] = flask.render_template( \
            "business.tpl",
            data=render_param, \
            env=chain_env, \
            query=chain_env['argument'].data, \
            trace=chain_env['trace'], \
            title=u"帳票|SESクラウド", \
            current="business.top")
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)