#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

"""
    This module provides client logics.
"""

import time
import copy
import datetime
import hashlib
import traceback
import pprint
import flask
import re
from providers.re import Re
from providers.limitter import Limitter
from validators.base import ValidatorBase as Validator
from models.engineer import Engineer as Model
from base import ProcessorBase
from errors import exceptions as EXC

class Processor(ProcessorBase):

    """
        This method is selector of functions which is members of the method chain, contains:
            preludium   : validation-input.(if need)
            main logic  : _fn_ functions.(must)
            postludium  : validation-output.(if need)
    """

    __realms__ = {\
        "top": {\
            "logic": "html_top",\
        },\
        "enumEngineers": {\
            "valid_in": None,\
            "logic": "enum_engineers",\
            "valid_out": None\
        }, \
        "enumBpEngineers": { \
            "valid_in": None, \
            "logic": "enum_bp_engineers", \
            "valid_out": None \
            }, \
        "enumEngineersCompact": { \
            "valid_in": None, \
            "logic": "enum_engineers_compact", \
            "valid_out": None \
            }, \
        "createEngineer": {\
            "valid_in": "create_engineer_in",\
            "logics": [\
                "check_item_cap",\
                "create_engineer",\
            ],\
            "valid_out": None\
        },\
        "updateEngineer": {\
            "valid_in": "update_engineer_in",\
            "logic": "update_engineer",\
            "valid_out": None\
        },\
        "deleteEngineer": {\
            "valid_in": "delete_engineer_in",\
            "logic": "delete_engineer",\
            "valid_out": None
        }, \
        "searchEngineers": { \
            "valid_in": None, \
            "logic": "search_engineers", \
            "valid_out": None \
            }, \
        "setSkills": {\
            "valid_in": "set_skills_in",\
            "logic": "set_skills",\
            "valid_out": None\
        },\
        "enumPreparations": {\
            "valid_in": "enum_preparations_in",\
            "logic": "enum_preparations",\
            "valid_out": None\
        },\
        "createPreparation": {\
            "valid_in": "create_preparation_in",\
            "logic": "create_preparation",\
            "valid_out": None\
        },\
        "updatePreparation": {\
            "valid_in": "update_preparation_in",\
            "logic": "update_preparation",\
            "valid_out": None\
        },\
        "deletePreparation": {\
            "valid_in": "delete_preparation_in",\
            "logic": "delete_preparation",\
            "valid_out": None\
        }, \
        "enumEngineersRelatedProject": { \
            "logic": "enum_engineers_related_project", \
            "valid_out": None \
            }, \
        "enumPrjEngineer": { \
            "logic": "enum_prj_engineer", \
            "valid_out": None \
            }, \
        "lastThreeDays": { \
            "logic": "last_three_days"
            }, \
        "updateMatchingEngineer": { \
            "logic": "update_matching_engineer"
            }, \
        }

    def _fn_check_item_cap(self, chain_env):
        self.check_limit(chain_env, ("LMT_LEN_ENGINEER",))

    def _fn_html_top(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.client import Processor as P_CLIENT
        from logics.manage import Processor as P_MANAGE
        from logics.skill import Processor as P_SKILL
        from logics.occupation import Processor as P_OCCUPATION
        #Fetch user profile.
        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        #Fetch engineers.
        status_engineer, render_param['engineer.enumEngineers'] = self._fn_enum_engineers(chain_env)
        #[begin] support objects.
        #Fetch user accounts.
        status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        #Fetch current status for Limit.
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)

        status_skills, render_param['skill.enumSkills'] = P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
        status_skills, render_param['skill.enumSkillCategories'] = P_SKILL(self.__pref__)._fn_enum_skill_categories(
            chain_env)
        status_skills, render_param['skill.enumSkillLevels'] = P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
        status_projects, render_param['occupation.enumOccupations'] = P_OCCUPATION(self.__pref__)._fn_enum_occupations(
            chain_env)
        clean_env = copy.deepcopy(chain_env)
        if "name" in clean_env['argument'].data:
            clean_env['argument'].data['name'] = u''
        status_client, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
        render_param['skill.type'] = "engineer.top"

        #[end] support objects.
        chain_env['response_body'] = flask.render_template(\
            "engineer.tpl",
            data=render_param,\
            env=chain_env,\
            query=chain_env['argument'].data,\
            trace=chain_env['trace'],\
            title=u"技術者|SESクラウド",\
            current="engineer.top")
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_enum_engineers(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = []
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            lines = []
            #[begin] Build where clause conditions.
            FILTERS_LIKE = {\
                "visible_name": "`MT`.`visible_name`",\
                "name": "`MT`.`name`",\
                "kana": "`MT`.`kana`",
                "station": "`MT`.`station`",\
                # "skill": "`MT`.`skill`",\
                "employer": "`MT`.`employer`",\
                # "client_name": "`MT`.`client_name`",\
                "client_name": "CONCAT(COALESCE(`MT`.`client_name`, ''''), COALESCE(`CL`.`name`, ''''))", \
                }
            FILTERS_SERIOUS = {\
                "id": "`MT`.`id`", \
                "engineer_id": "`MT`.`id`", \
                "gender": "`MT`.`gender`",\
                "flg_caution": "`MT`.`flg_caution`",\
                "flg_registered": "`MT`.`flg_registered`",\
                "flg_assignable": "`MT`.`flg_assignable`",\
                "flg_careful": "`MT`.`flg_careful`",\
            }
            whereClause = []
            whereValues = []
            [whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
            [whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
            #[end] Build where clause conditions.

            if ("skill" in args):
                whereClause.append("exists (select 1 from cr_engineer_skill es join mt_skills s on  s.id = es.skill_id where `MT`.id = es.engineer_id and s.name REGEXP \'^.*"+ dbcon.literal(re.escape(args["skill"]).replace('%', '%%'))[1:-1]+".*$\')")
            if ("contract" in args):
                if (args['contract'] == u"正社員(契約社員)"):
                    whereClause.append("`MT`.`contract` IN ('正社員', '契約社員')")
                else :
                    whereClause.append("`MT`.`contract` REGEXP \'^.*"+ dbcon.literal(re.escape(args["contract"]).replace('%', '%%'))[1:-1]+".*$\'")

            #[begin] Build order by clause.
            ORDER_KEYS = {\
                "kana": "`MT`.`kana`",\
                "contract": "`MT`.`contract`",\
                "fee": "`MT`.`fee`",\
                "dt_created": "`MT`.`dt_created`",\
            }
            orderClause = []
            if "sort_keys" in args:
                for k in args['sort_keys']:
                    if k in ORDER_KEYS:
                        orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
            if "sort_keys" in args and "dt_created" in args['sort_keys']:
                pass
            elif "flg_sort" in args:
                orderClause += ["`MT`.`name` ASC"]
            else:
                orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
            #[end] Build order by clause.
            param1 = (\
                [chain_env['prefix'], chain_env['login_id'], chain_env['prefix'], chain_env['login_id']]\
                + [chain_env['prefix'], chain_env['login_id'], chain_env['credential']]\
                + whereValues\
            )
            try:
                dbcur.execute(Model.sql("enum_engineers") % (("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param1)
            except:
                pprint.pprint(traceback.format_exc())
                chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                result = []
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("enum_engineers", dbcur)
                status['code'] = 0
            #[begin] Joining user list.
            user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id'], entity['charging_user']['id'],) for entity in result] for e in p]))
            if user_list:
                try:
                    dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
                except:
                    chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                    chain_env['trace'].append(dbcur._executed)
                else:
                    chain_env['trace'].append(dbcur._executed)
                    res2 = Model.convert("enum_users", dbcur)
                    for tmp_obj in res2:
                        [entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
                        [entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
                        [entity['charging_user'].update(tmp_obj) for entity in result if entity['charging_user']['id'] == tmp_obj['id']]
            #[end] Joining user list.
            #[begin] Joining File.
            eid_list = set([e['id'] for e in result])
            if eid_list:
                param2 = (\
                    chain_env['prefix'], chain_env['login_id'],\
                    chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                )
                dbcur.execute(Model.sql("enum_files") % ", ".join(map(str, eid_list)), param2)
                chain_env['trace'].append(dbcur._executed)
                file_dict = Model.convert("enum_file_dict", dbcur)
                [e_obj.update({"attachement": file_dict[e_obj['id']] if e_obj['id'] in file_dict else None}) for e_obj in result]
            #[end] Joining File.
            #[begin] Joining preparations.
            if eid_list:
                param3 = (\
                    chain_env['prefix'], chain_env['login_id'],\
                    chain_env['prefix'], chain_env['login_id'],\
                    chain_env['prefix'], chain_env['login_id'],\
                    chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                )
                dbcur.execute(Model.sql("enum_preparations") % ("`P`.`engineer_id` IN (%s)" % ", ".join(map(str, eid_list))), param3)
                chain_env['trace'].append(dbcur._executed)
                prep_list = Model.convert("enum_preparations", dbcur)
                for prep in prep_list:
                    for res in result:
                        if res['id'] == prep['engineer_id']:
                            res['preparations'].append(prep)
            #[end] Joining preparations.
            if eid_list:
                dbcur.execute(Model.sql("enum_engineer_skill_levels") % ("`P`.`engineer_id` IN (%s)" % ", ".join(map(str, eid_list))))
                chain_env['trace'].append(dbcur._executed)
                level_list = Model.convert("enum_engineer_skill_levels", dbcur)
                for level in level_list:
                    for res in result:
                        if res['id'] == level['engineer_id']:
                            res['skill_level_list'].append(level)
            status['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_enum_engineers_compact(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = []
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            # [begin] Build where clause conditions.
            FILTERS_LIKE = { \
                "visible_name": "`MT`.`visible_name`", \
                "name": "`MT`.`name`", \
                "kana": "`MT`.`kana`",
                "station": "`MT`.`station`", \
                "skill": "`MT`.`skill`", \
                "employer": "`MT`.`employer`", \
                }
            FILTERS_SERIOUS = { \
                "id": "`MT`.`id`", \
                "gender": "`MT`.`gender`", \
                "flg_caution": "`MT`.`flg_caution`", \
                "flg_registered": "`MT`.`flg_registered`", \
                "flg_assignable": "`MT`.`flg_assignable`", \
                }
            whereClause = []
            whereValues = []
            [whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args
             if k in FILTERS_LIKE]
            [whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if
             k in FILTERS_SERIOUS]
            if ("contract" in args):
                if (args['contract'] == u"正社員(契約社員)"):
                    whereClause.append("`MT`.`contract` IN ('正社員', '契約社員')")
                else :
                    whereClause.append("`MT`.`contract` REGEXP \'^.*"+ dbcon.literal(re.escape(args["contract"]).replace('%', '%%'))[1:-1]+".*$\'")
            # [end] Build where clause conditions.
            # [begin] Build order by clause.
            ORDER_KEYS = { \
                "kana": "`MT`.`kana`", \
                "contract": "`MT`.`contract`", \
                "fee": "`MT`.`fee`", \
                "dt_created": "`MT`.`dt_created`", \
                }
            orderClause = []
            if "sort_keys" in args:
                for k in args['sort_keys']:
                    if k in ORDER_KEYS:
                        orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
            if "sort_keys" in args and "dt_created" in args['sort_keys']:
                pass
            else:
                orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
            # [end] Build order by clause.
            param1 = ( \
                [chain_env['prefix'], chain_env['login_id'], chain_env['prefix'], chain_env['login_id']] \
                + [chain_env['prefix'], chain_env['login_id'], chain_env['credential']] \
                + whereValues \
                )
            try:
                dbcur.execute(Model.sql("enum_engineers") % (
                ("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param1)
            except:
                pprint.pprint(traceback.format_exc())
                chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                result = []
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("enum_engineers", dbcur)
                status['code'] = 0

            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_enum_bp_engineers(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = []
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            # [begin] Build where clause conditions.
            FILTERS_LIKE = { \
                "visible_name": "`MT`.`visible_name`", \
                "name": "`MT`.`name`", \
                "kana": "`MT`.`kana`",
                "station": "`MT`.`station`", \
                "skill": "`MT`.`skill`", \
                "employer": "`MT`.`employer`", \
                }
            FILTERS_SERIOUS = { \
                "id": "`MT`.`id`", \
                "gender": "`MT`.`gender`", \
                "flg_caution": "`MT`.`flg_caution`", \
                "flg_registered": "`MT`.`flg_registered`", \
                "flg_assignable": "`MT`.`flg_assignable`", \
                }
            whereClause = []
            whereValues = []
            [whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args
             if k in FILTERS_LIKE]
            [whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if
             k in FILTERS_SERIOUS]

            if ("engineer_ids" in args):
                whereClause.append("`MT`.`id` in(" + ", ".join(map(str, args["engineer_ids"])) + ")")
            if ("contract" in args):
                if (args['contract'] == u"正社員(契約社員)"):
                    whereClause.append("`MT`.`contract` IN ('正社員', '契約社員')")
                else :
                    whereClause.append("`MT`.`contract` REGEXP \'^.*"+ dbcon.literal(re.escape(args["contract"]).replace('%', '%%'))[1:-1]+".*$\'")

            # [end] Build where clause conditions.
            # [begin] Build order by clause.
            ORDER_KEYS = { \
                "kana": "`MT`.`kana`", \
                "contract": "`MT`.`contract`", \
                "fee": "`MT`.`fee`", \
                "dt_created": "`MT`.`dt_created`", \
                }
            orderClause = []
            if "sort_keys" in args:
                for k in args['sort_keys']:
                    if k in ORDER_KEYS:
                        orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
            if "sort_keys" in args and "dt_created" in args['sort_keys']:
                pass
            else:
                orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
            # [end] Build order by clause.

            param1 = ( \
                [chain_env['prefix'], chain_env['login_id'], chain_env['credential']] \
                + whereValues \
                )

            print whereClause
            print param1
            print orderClause
            try:
                dbcur.execute(Model.sql("enum_bp_engineers") % (
                ("AND " + "\n    AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param1)
            except:
                pprint.pprint(traceback.format_exc())
                chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                result = []
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("enum_bp_engineers", dbcur)
                status['code'] = 0

            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_create_engineer(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = {}
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            args['birth_datetime'] = self.str2datetime(args['birth']) if "birth" in args and args['birth'] else None
            args['fee'] = args['fee'] if "fee" in args else 0.0
            args['addr_vip'] = args['addr_vip'] if "addr_vip" in args and args['addr_vip'] else None
            args['addr1'] = args['addr1'] if "addr1" in args and args['addr1'] else None
            args['addr2'] = args['addr2'] if "addr2" in args and args['addr2'] else None
            param = (\
                args['visible_name'], args['name'], args['kana'], args['tel'], args['mail1'],\
                args['mail2'] if "mail2" in args else None,\
                args['birth_datetime'], args['gender'], args['contract'], args['fee'], args['station'] if "station" in args else "",\
                args['flg_caution'], args['flg_registered'], args['flg_assignable'],\
                chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                args['skill'] if "skill" in args else "",\
                args['state_work'] if "state_work" in args else "",\
                args['age'] if "age" in args and args['age'] else None,\
                args['charging_user_id'] if "charging_user_id" in args else None,\
                args['employer'] if "employer" in args else "",\
                chain_env['prefix'], chain_env['login_id'], chain_env['credential'], \
                args['operation_begin'] if ("operation_begin" in args and args["operation_begin"] != "") else None, \
                args['station_cd'], args['station_pref_cd'], args['station_line_cd'], \
                args['station_lon'], args['station_lat'], \
                args['flg_public'], args.get('web_public', 0), args['client_id'],args['client_name'], \
                args['addr_vip'], args['addr1'], args['addr2'], \
                args['flg_careful'] if "flg_careful" in args else 0 \
                )
            try:
                print Model.sql("create_engineer")
                print param
                dbcur.execute(Model.sql("create_engineer"), param)
            except Exception, err:
                print traceback.format_exc(err)
                chain_env['trace'].append(traceback.format_exc(err))
                try:
                    chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                except:
                    chain_env['trace'].append(dbcur._executed)
                    chain_env['trace'].append(traceback.format_exc())
            else:
                dbcur.execute(Model.sql("last_insert_id"))
                e_id = Model.convert("last_insert_id", dbcur)
                #[begin] note.
                if e_id: 
                    if "note" in args and args['note']:
                        try:
                            dbcur.execute(Model.sql("create_engineer_note"), (e_id, args['note'],))
                        except Exception, err:
                            chain_env['trace'].append(traceback.format_exc(err))
                            chain_env['trace'].append(dbcur._executed)
                            status['code'] = 2
                            dbcon.rollback()
                    if "internal_note" in args and args['internal_note'] and status['code'] != 2:
                        try:
                            dbcur.execute(Model.sql("create_engineer_internal_note"), (e_id, args['internal_note'],))
                        except Exception, err:
                            chain_env['trace'].append(traceback.format_exc(err))
                            chain_env['trace'].append(dbcur._executed)
                            status['code'] = 2
                            dbcon.rollback()
                    if status['code'] != 2:
                        dbcon.commit()
                        result = {"id": e_id}
                        status['code'] = 0
                else:
                    dbcon.rollback()
                    result = None
                    status['code'] = 2
                #[end] note.
                #[begin] attachement.
                if e_id and "attachement" in args and args['attachement']:
                    param2 = (\
                        e_id,\
                        chain_env['prefix'], chain_env['login_id'],\
                        chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                        args['attachement'],\
                        chain_env['prefix'], chain_env['login_id'],\
                        chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                    )
                    try:
                        dbcur.execute(Model.sql("create_engineer_attachement"), param2)
                    except Exception:
                        chain_env['trace'].append(traceback.format_exc())
                        chain_env['trace'].append(dbcur._executed)
                        status['code'] = 2
                    dbcon.commit()
                #[end] attachment.
            dbcur.close()
            dbcon.close()
            if 'id' in result and status['code'] == 0:
                chain_env['argument'].data["id"] = result['id']
                self._fn_set_skills(chain_env)
                self._fn_set_occupations(chain_env)
        chain_env['status'] = status
        chain_env['results'] = result
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_update_engineer(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = {}
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            #[begin] SQL preparation.
            ACCEPT_FIELDS = (
                "id", "visible_name", "name", "kana", "tel", "mail1", "mail2", "gender", "contract",
                "fee", "flg_caution", "flg_registered", "flg_assignable", "station", "skill", "state_work",
                "age", "charging_user_id", "employer",
                "station_cd", "station_pref_cd", "station_line_cd", "station_lon", "station_lat","flg_public","web_public",
                "client_id", "client_name", "addr_vip", "addr1", "addr2", "flg_careful"
            )
            args = chain_env['argument'].data
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [self.str2datetime(args[k]) if k in ("dt_assignable",) else args[k] for k in cols]
            if "birth" in args:
                cols += ["birth"]
                vals += [self.str2datetime(args['birth']) if args['birth'] else None]
            if "operation_begin" in args:
                cols += ["operation_begin"]
                vals += [args['operation_begin'] if args['operation_begin'] and args['operation_begin'] != ""  else None]
            if "flg_public" in args and args['flg_public'] == True:
                cols += ["is_show_matching"]
                vals += [1]
            cols += ["dt_modified"]
            vals += [datetime.datetime.now()]
            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] +\
                vals +\
                [args['id']] +\
                [chain_env['prefix'], args['login_id'], args['credential']] +\
                [chain_env['prefix'], args['login_id']]
            flg_ok = True
            #[end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_engineer") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                dbcon.rollback()
                flg_ok = False
            if flg_ok and "note" in args:
                try:
                    dbcur.execute(Model.sql("update_note"), (args['id'], args['note'], args['note']))
                except Exception, err:
                    status['code'] = 2
                    chain_env['trace'].append(traceback.format_exc(err))
                    flg_ok = False
            if flg_ok and "internal_note" in args:
                try:
                    dbcur.execute(Model.sql("update_internal_note"), (args['id'], args['internal_note'], args['internal_note']))
                except Exception, err:
                    status['code'] = 2
                    chain_env['trace'].append(traceback.format_exc(err))
                    flg_ok = False
            if not flg_ok:
                dbcon.rollback()
                status['code'] = 2
            else:
                dbcon.commit()
                status['code'] = status['code'] or 0
                #[begin] attachement.
                if "attachement" in args:
                    #[begin] Delete existing file and cross relation.
                    param2 = (\
                        args['attachement'],\
                        chain_env['prefix'], chain_env['login_id'],\
                        chain_env['prefix'], chain_env['login_id'],\
                        chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                    )
                    if args['attachement']:
                        try:
                            dbcur.execute(Model.sql("update_cleanup_attachement"), param2)
                            dbcur.execute(Model.sql("update_cleanup_attachement_cross"))
                            #[end] Delete existing file and cross relation.
                            param3a = (\
                                args['id'],\
                                chain_env['prefix'], chain_env['login_id'],\
                                chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                                args['attachement'],\
                                chain_env['prefix'], chain_env['login_id'],\
                                chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                            )
                            param3b = (\
                                args['id'],\
                            )
                        #[begin] Update cross relation.
                            try:
                                dbcur.execute(Model.sql("update_insert_attachement_cross"), param3a)
                            except:
                                chain_env['trace'].append(traceback.format_exc())
                                chain_env['trace'].append(dbcur._executed)
                            try:
                                dbcur.execute(Model.sql("update_upgrade_binary_upd"), param3b)
                            except:
                                chain_env['trace'].append(traceback.format_exc())
                                chain_env['trace'].append(dbcur._executed)
                        except Exception:
                            chain_env['trace'].append(traceback.format_exc())
                            status['code'] = 2
                            dbcon.rollback()
                        else:
                            status['code'] = 0
                            dbcon.commit()
                    else:
                        try:
                            dbcur.execute("""\
DELETE FROM `cr_engineer_bin` WHERE `key_id`=%s;""", (args['id'],))
                        except Exception:
                            chain_env['trace'].append(traceback.format_exc())
                            status['code'] = 2
                            dbcon.rollback()
                        else:
                            chain_env['trace'].append(dbcur._executed)
                            status['code'] = 0
                            dbcon.commit()
                    #[end] Update cross relation.
                #[end] attachment.
            dbcur.close()
            dbcon.close()
            if status['code'] == 0 and "update_data_only" not in args:
                self._fn_set_skills(chain_env)
                self._fn_set_occupations(chain_env)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_delete_engineer(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            param = (\
                chain_env['prefix'], args['login_id'], args['credential'],\
                chain_env['prefix'], args['login_id'],\
                chain_env['prefix'], args['login_id'], args['credential']\
            )
            try:
                dbcur.execute(Model.sql("delete_engineer") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
            except Exception, err:
                chain_env['propagate'] = False
                chain_env['results'] = {"id": None}
                chain_env['trace'].append(traceback.format_exc(err))
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                dbcon.rollback()
            else:
                chain_env['results']['rows'] = dbcur.rowcount
                dbcon.commit()
            dbcur.close()
            dbcon.close()
        chain_env['status']['code'] = chain_env['status']['code'] or 0
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_enum_preparations(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            #[begin] Prepare conditions.
            where_clause = []
            if "engineer_id" in args:
                where_clause.append("`engineer_id`=%d" % args['engineer_id'])
            #[end] Prepare conditions.
            param = (\
                chain_env['prefix'], args['login_id'],\
                chain_env['prefix'], args['login_id'],\
                chain_env['prefix'], args['login_id'],\
                chain_env['prefix'], args['login_id'], args['credential'],\
            )
            try:
                dbcur.execute(Model.sql("enum_preparations") % ("\n    AND ".join(where_clause) if where_clause else "TRUE",), param)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc(err))
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                chain_env['results'] = None
                chain_env['status']['code'] = 2
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("enum_preparations", cur)
                user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'],) for entity in result] for e in p]))
                try:
                    dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
                except Exception, err:
                    chain_env['trace'].append(traceback.format_exc(err))
                    chain_env['trace'].append(dbcur._executed)
                    chain_env['results'] = None
                    chain_env['status']['code'] = 2
                else:
                    res2 = Model.convert("enum_users", dbcur)
                    for tmp_obj in res2:
                        [entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
                    chain_env['results'] = result
                    chain_env['status']['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_search_engineers(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = []
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            lines = []
            #[begin] Build where clause conditions.
            FILTERS_LIKE = {\
                "visible_name": "`MT`.`visible_name`",\
                "name": "`MT`.`name`",\
                "kana": "`MT`.`kana`",
                # "station": "`MT`.`station`",\
                "skill": "`MT`.`skill`",\
                "employer": "`MT`.`employer`", \
                # "engineer_name": "`MT`.`name`", \
                }
            FILTERS_SERIOUS = {\
                "id": "`MT`.`id`", \
                "engineer_id": "`MT`.`id`", \
                "flg_caution": "`MT`.`flg_caution`",\
                "flg_registered": "`MT`.`flg_registered`",\
                "flg_assignable": "`MT`.`flg_assignable`", \
                }
            whereClause = []
            whereValues = []
            [whereClause.append("%s REGEXP '^.*%s.*$'" % (FILTERS_LIKE[k], dbcon.literal(re.escape(args[k]).replace('%', '%%'))[1:-1])) for k in args if k in FILTERS_LIKE]
            [whereClause.append("%s = %%s" % FILTERS_SERIOUS[k]) or (whereValues.append(args[k])) for k in args if k in FILTERS_SERIOUS]
            #[end] Build where clause conditions.

            if ("client_name" in args):
                whereClause.append("(MTC.name REGEXP \'^.*" + args['client_name'] + ".*$\' or MTUC.name REGEXP \'^.*" + args['client_name'] + ".*$\')")
            if ("occupation_id" in args):
                whereClause.append("CRO.occupation_id in (" + ",".join(args['occupation_id']) + " ) ")
            if ("skill_id" in args):
                whereClause.append("CRS.skill_id in (" + ",".join(args['skill_id']) + " ) ")
            if ("flg_skill_level" in args):
                if ("skill_level_list" in args and args["flg_skill_level"] == "1"):
                    skillWhere = []
                    for tmpSkill in args["skill_level_list"]:
                        skillWhere.append("CRS.skill_id = " + tmpSkill["skill_id"] + " and CRS.level >= " + tmpSkill["level"])
                    whereClause.append("((" + " )OR( ".join(skillWhere) + "))")
            if ("client_id" in args and "company_id" in args):
                whereClause.append("(MT.client_id in (" + ",".join(args['client_id']) + ") OR MT.owner_company_id in (" + ",".join(args['company_id']) + ")) ")
            if ("client_id" in args and "company_id" not in args):
                whereClause.append("MT.client_id in (" + ",".join(args['client_id']) + " ) ")
            if ("company_id" in args and "client_id" not in args):
                whereClause.append("MT.owner_company_id in (" + ",".join(args['company_id']) + " ) ")
            if ("not_company_id" in args):
                whereClause.append("MT.owner_company_id not in (" + ",".join(args['not_company_id']) + " ) ")
            if ("gender" in args):
                whereClause.append("MT.gender in (\'" + "\',\'".join(args['gender']) + "\' ) ")
            if ("contract" in args):
                whereClause.append("MT.contract in (\'" + "\',\'".join(args['contract']) + "\' ) ")
            if ("term_end" in args):
                whereClause.append("(MT.operation_begin <= \'" + args['term_end'] + "\' )")
            if ("term_begin" in args and "term_end" not in args):
                whereClause.append("(MT.operation_begin <= \'" + args['term_begin'] + "\' )")

            if ("amount_from" in args):
                whereClause.append("MT.fee >= (" + args['amount_from'] + " * 10000)")
            if ("amount_to" in args):
                whereClause.append("MT.fee <= (" + args['amount_to'] + " * 10000)")
            if ("age_from" in args):
                whereClause.append(
                    "(MT.age >= " + args['age_from'] + " )")
            if ("age_to" in args):
                whereClause.append("(MT.age <= " + args['age_to'] + " )")
            if ("engineer_name" in args):
                whereClause.append("(MT.name REGEXP \'^.*"+ args['engineer_name']+".*$\' or MT.kana REGEXP \'^.*" + args['engineer_name'] + ".*$\' or MT.visible_name REGEXP \'^.*" + args['engineer_name'] + ".*$\')")
            if ("travel_time" in args and "station_lat" in args and "station_lon" in args):
                if (int(args['travel_time'][0]) < 90):
                    whereClause.append(
                        "`MT`.`station_lat` is not null and travel_time_from_distance(" + args['station_lat'] + "," + args['station_lon'] + ",`MT`.`station_lat`,`MT`.`station_lon`) <= " + args['travel_time'][0])

            #[begin] Build order by clause.
            ORDER_KEYS = {\
                "kana": "`MT`.`kana`",\
                "contract": "`MT`.`contract`",\
                "fee": "`MT`.`fee`",\
                "dt_created": "`MT`.`dt_created`", \
                "charging_user_id": "`MT`.`charging_user_id`", \
                "occupation_count": "`occupation_count`", \
                "skill_count": "`skill_count`", \
                "age": "`MT`.`age`", \
                "gender": "`MT`.`gender`", \
                "operation_begin": "`MT`.`operation_begin`", \
                "company_name": "`company_name`", \
                "travel_time": "`travel_time`", \
                }
            orderClause = []
            if "sort_keys" in args:
                for k in args['sort_keys']:
                    if k in ORDER_KEYS:
                        orderClause.append("%s %s" % (ORDER_KEYS[k], "DESC" if args['sort_keys'][k] == "-" else "ASC"))
            if "sort_keys" in args and "dt_created" in args['sort_keys']:
                pass
            else:
                orderClause += ["COALESCE(`MT`.`dt_modified`, `MT`.`dt_created`) DESC"]
            #[end] Build order by clause.

            station_lat = 0;
            station_lon = 0;
            station_flg = 0;
            if ("station_lat" in args):
                station_lat = args['station_lat']
            if ("station_lon" in args):
                station_lon = args['station_lon']
            if ("station_lat" in args or "station_lon" in args):
                station_flg = 1

            param1 = (\
                [station_flg, station_lat, station_lon]\
                + [chain_env['prefix'], chain_env['login_id'], chain_env['credential']]\
                + whereValues\
            )

            print(whereClause)
            print(param1)
            print(orderClause)

            try:
                self.my_log("__call model_search")
                dbcur.execute(Model.sql("search_engineers") % (("AND " + "\n AND ".join(whereClause)) if whereClause else "", ", ".join(orderClause)), param1)
            except:
                pprint.pprint(traceback.format_exc())
                chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                result = []
                self.my_log("search_engineers_excep " + traceback.format_exc())
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("search_engineers", dbcur)
                status['code'] = 0
            #[begin] Joining user list.
            user_list = set(filter(lambda x: x is not None and x, [e for p in [(entity['creator']['id'], entity['modifier']['id'], entity['charging_user']['id'],) for entity in result] for e in p]))
            if user_list:
                try:
                    dbcur.execute(Model.sql("enum_users") % ", ".join(map(str, user_list)))
                except:
                    chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                    chain_env['trace'].append(dbcur._executed)
                else:
                    chain_env['trace'].append(dbcur._executed)
                    res2 = Model.convert("enum_users", dbcur)
                    for tmp_obj in res2:
                        [entity['creator'].update(tmp_obj) for entity in result if entity['creator']['id'] == tmp_obj['id']]
                        [entity['modifier'].update(tmp_obj) for entity in result if entity['modifier']['id'] == tmp_obj['id']]
                        [entity['charging_user'].update(tmp_obj) for entity in result if entity['charging_user']['id'] == tmp_obj['id']]
            #[end] Joining user list.
            #[begin] Joining File.
            eid_list = set([e['id'] for e in result])
            if eid_list:
                param2 = (\
                    # chain_env['prefix'], chain_env['login_id'],\
                    # chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                )
                dbcur.execute(Model.sql("enum_files_all") % ", ".join(map(str, eid_list)), param2)
                chain_env['trace'].append(dbcur._executed)
                file_dict = Model.convert("enum_file_dict", dbcur)
                [e_obj.update({"attachement": file_dict[e_obj['id']] if e_obj['id'] in file_dict else None}) for e_obj in result]
            #[end] Joining File.
            #[begin] Joining preparations.
            if eid_list:
                param3 = (\
                    chain_env['prefix'], chain_env['login_id'],\
                    chain_env['prefix'], chain_env['login_id'],\
                    chain_env['prefix'], chain_env['login_id'],\
                    chain_env['prefix'], chain_env['login_id'], chain_env['credential'],\
                )
                dbcur.execute(Model.sql("enum_preparations") % ("`P`.`engineer_id` IN (%s)" % ", ".join(map(str, eid_list))), param3)
                chain_env['trace'].append(dbcur._executed)
                prep_list = Model.convert("enum_preparations", dbcur)
                for prep in prep_list:
                    for res in result:
                        if res['id'] == prep['engineer_id']:
                            res['preparations'].append(prep)
            #[end] Joining preparations.
            if eid_list:
                dbcur.execute(Model.sql("enum_engineer_skill_levels") % ("`P`.`engineer_id` IN (%s)" % ", ".join(map(str, eid_list))))
                chain_env['trace'].append(dbcur._executed)
                level_list = Model.convert("enum_engineer_skill_levels", dbcur)
                for level in level_list:
                    for res in result:
                        if res['id'] == level['engineer_id']:
                            res['skill_level_list'].append(level)
            status['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_create_preparation(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            param = (\
                args['engineer_id'],\
                args['client_id'] if "client_id" in args else None,\
                args['client_name'] if "client_name" in args else None,\
                args['time'] if "time" in args else "",\
                args['progress'], args['note'],\
                chain_env['prefix'], args['login_id'], args['credential'],\
            )
            try:
                dbcur.execute(Model.sql("create_preparation"), param)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['propagate'] = False
                chain_env['results'] = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    chain_env['status']['code'] = 2
                else:
                    chain_env['trace'].append(err)
            else:
                chain_env['trace'].append(dbcur._executed)
                try:
                    dbcur.execute(Model.sql("last_insert_id"))
                except Exception, err:
                    chain_env['trace'].append(err)
                    chain_env['status']['code'] = 1
                    dbcon.rollback()
                else:
                    chain_env['results'] = Model.convert("last_insert_id", dbcur)
                    dbcon.commit()
            dbcur.close()
            dbcon.close()
        chain_env['status']['code'] = chain_env['status']['code'] or 0
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_update_preparation(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = {}
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            #[begin] SQL preparation.
            ACCEPT_FIELDS = ("client_id", "client_name", "time", "progress", "note")
            args = chain_env['argument'].data
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]
            cols += ["dt_modified"]
            vals += [datetime.datetime.now()]
            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] +\
                vals +\
                [args['id']] +\
                [chain_env['prefix'], args['login_id'], args['credential']] +\
                [chain_env['prefix'], args['login_id']]
            flg_ok = True
            #[end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_preparation") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['propagate'] = False
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                dbcon.rollback()
                flg_ok = False
            else:
                status['code'] = 0
            if flg_ok:
                dbcon.commit()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_delete_preparation(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            param = (\
                chain_env['prefix'], args['login_id'], args['credential'],\
                chain_env['prefix'], args['login_id'],\
                chain_env['prefix'], args['login_id'], args['credential']\
            )
            try:
                dbcur.execute(Model.sql("delete_preparation") % ", ".join(map(lambda x: "'%d'" % x, args['id_list'])), param)
            except Exception, err:
                chain_env['propagate'] = False
                chain_env['results'] = {"id": None}
                chain_env['trace'].append(traceback.format_exc(err))
                dbcon.rollback()
            else:
                chain_env['results']['rows'] = dbcur.rowcount
                dbcon.commit()
            dbcur.close()
            dbcon.close()
        chain_env['status']['code'] = chain_env['status']['code'] or 0
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_set_skills(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data

            param_needs = ( \
                "cr_engineer_skill", \
                ", ".join(map(str, set(args['skill_id_list']))) if "skill_id_list" in args else ""
            )
            # param_recommends= (\
            # 	"cr_prj_skill_recommends",\
            # 	", ".join(map(str, set(args['recommends']))) if "recommends" in args else ""
            # )
            param = ( \
                args['id'], \
                chain_env['prefix'], args['login_id'], \
                chain_env['prefix'], args['login_id'], args['credential'], \
                chain_env['prefix'], args['login_id'], args['credential'] \
                )
            result = {"skill_id_list": 0, "recommends": 0}
            # if not args['needs'] or not args['recommends']:
            # 	chain_env['status']['code'] = chain_env['status']['code'] or 0
            # 	self.perf_time(chain_env, time.time() - time_bg)
            # 	return
            flg_ok = True
            if flg_ok:
                try:  # Delete all.
                    # ACL checking is skipped because following SQL statement checks
                    # and if invalid access, you get user defined exception.
                    dbcur.execute("""DELETE FROM `%s` WHERE `engineer_id`=%%s;""" % ("cr_engineer_skill",),
                                  (args['id'],))
                # dbcur.execute("""DELETE FROM `%s` WHERE `project_id`=%%s;""" % ("cr_prj_skill_recommends",), (args['id'],))
                except Exception, err:
                    chain_env['trace'].append(traceback.format_exc(err))
                    chain_env['propagate'] = False
                    dbcon.rollback()
                    flg_ok = False
                    print err
            if flg_ok and "skill_id_list" in args:
                try:  # Insert needs.
                    dbcur.execute(Model.sql("set_skills") % param_needs, param)
                    self.my_log("__set_skills " + Model.sql("set_skills") % param_needs)
                except Exception, err:
                    chain_env['trace'].append(traceback.format_exc(err))
                    chain_env['trace'].append(dbcur._executed)
                    chain_env['propagate'] = False
                    dbcon.rollback()
                    print err
                    flg_ok = False
                else:
                    result['skill_id_list'] = dbcur.rowcount
            if flg_ok and "skill_level_list" in args:
                try:
                    for levelObj in args['skill_level_list']:
                        param_levels = (levelObj['level'], args['id'], levelObj['id']);
                        dbcur.execute(Model.sql("update_skill_level") , param_levels)
                except Exception, err:
                    chain_env['trace'].append(traceback.format_exc(err))
                    chain_env['trace'].append(dbcur._executed)
                    chain_env['propagate'] = False
                    dbcon.rollback()
                    print err
                    flg_ok = False
                else:
                    result['skill_id_list'] = dbcur.rowcount
            # if flg_ok:
            # 	try:#Insert recommends.
            # 		dbcur.execute(Model.sql("set_skills") % param_recommends, param)
            # 	except Exception, err:
            # 		chain_env['trace'].append(traceback.format_exc(err))
            # 		chain_env['trace'].append(dbcur._executed)
            # 		chain_env['propagate'] = False
            # 		dbcon.rollback()
            # 		flg_ok = False
            # 	else:
            # 		result['recommends'] = dbcur.rowcount
            dbcon.commit()
            # dbcon.commit() if sum(result.values()) else None
            dbcur.close()
            dbcon.close()
        chain_env['results']['rows'] = result
        chain_env['status']['code'] = chain_env['status']['code'] or 0
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_set_occupations(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            param_needs = ( \
                "cr_engineer_ocp", \
                ", ".join(map(str, set(args['occupation_id_list']))) if "occupation_id_list" in args else ""
            )
            param = ( \
                args['id'], \
                chain_env['prefix'], args['login_id'], \
                chain_env['prefix'], args['login_id'], args['credential'], \
                chain_env['prefix'], args['login_id'], args['credential'] \
                )
            result = {"occupation_id_list": 0, }

            flg_ok = True
            if flg_ok:
                try:  # Delete all.
                    # ACL checking is skipped because following SQL statement checks
                    # and if invalid access, you get user defined exception.
                    dbcur.execute("""DELETE FROM `%s` WHERE `engineer_id`=%%s;""" % ("cr_engineer_ocp",), (args['id'],))
                # dbcur.execute("""DELETE FROM `%s` WHERE `project_id`=%%s;""" % ("cr_prj_skill_recommends",), (args['id'],))
                except Exception, err:
                    chain_env['trace'].append(traceback.format_exc(err))
                    chain_env['propagate'] = False
                    print err
                    dbcon.rollback()
                    flg_ok = False
            if flg_ok and "occupation_id_list" in args:
                try:  # Insert .
                    dbcur.execute(Model.sql("set_occupations") % param_needs, param)
                except Exception, err:
                    chain_env['trace'].append(traceback.format_exc(err))
                    chain_env['trace'].append(dbcur._executed)
                    chain_env['propagate'] = False
                    dbcon.rollback()
                    print err
                    flg_ok = False
                else:
                    result['occupation_id_list'] = dbcur.rowcount
            dbcon.commit()
            dbcur.close()
            dbcon.close()
        chain_env['results']['rows'] = result
        chain_env['status']['code'] = chain_env['status']['code'] or 0
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_enum_engineers_related_project(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = []
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data

            param1 = (args['id'], chain_env['prefix'], chain_env['login_id'], chain_env['credential'])

            try:
                dbcur.execute(Model.sql("enum_engineers_related_project"), param1)
            except:
                pprint.pprint(traceback.format_exc())
                chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                result = []
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("enum_engineers_related_project", dbcur)
                status['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_enum_prj_engineer (self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = []
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data

            param1 = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])

            try:
                dbcur.execute(Model.sql("enum_prj_engineer"), param1)
            except:
                pprint.pprint(traceback.format_exc())
                chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                result = []
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("enum_prj_engineer", dbcur)
                status['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_last_three_days(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = {"count": 0, "date": None}
        status = {"code": None, "description": None}
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            try:
                dbcur.execute(Model.sql("count_last_three_days"))
            except:
                pprint.pprint(traceback.format_exc())
                chain_env['trace'].append(unicode(traceback.format_exc(), "utf8"))
                return status, result
            else:
                chain_env['trace'].append(unicode(dbcur._executed, "utf8"))
                result = Model.convert("count_last_three_days", dbcur)
                status['code'] = 0
                dbcur.close()
                dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_update_matching_engineer(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        result = []
        status = {"code": None, "description": None}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            args = chain_env['argument'].data
            flg_ok = True
            try:
                dbcur.execute(Model.sql("update_matching_engineer") % args['id'])
            except:
                status['code'] = 2
                dbcon.rollback()
                flg_ok = False
            else:
                status['code'] = 0
            if flg_ok:
                dbcon.commit()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result
