#!/usr/local/bin/python
# -*- coding: UTF-8 -*-

import time
import copy
import datetime
import pprint
import traceback
import urllib
import pdfkit
import flask
import werkzeug

from providers.limitter import Limitter
from base import ProcessorBase
from errors import exceptions as EXC
import cStringIO as SIO
from models.business import Business as Model

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


class Processor(ProcessorBase):
    __realms__ = { \
        "project": { \
            "logic": "search_project", \
            }, \
        "engineer": { \
            "logic": "search_engineer", \
            }, \
        # "relateEngineerToProject": { \
        #     "logic": "relate_engineer_to_project", \
        #     }, \
        # "disconnectEngineerFromProject": { \
        #     "logic": "disconnect_engineer_from_project", \
        #     }, \
        }

    def _fn_search_project(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.project import Processor as P_PROJECT
        from logics.engineer import Processor as P_ENGINEER
        from logics.occupation import Processor as P_OCCUPATION
        from logics.skill import Processor as P_SKILL

        clean_env = copy.deepcopy(chain_env)
        if "client_id" in clean_env['argument'].data:
            del clean_env['argument'].data['client_id']
        status_clients, render_param['client.enumAllClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
        if "company_id" in clean_env['argument'].data:
            del clean_env['argument'].data['company_id']
        status_users, render_param['manage.enumBpCompanies'] = P_MANAGE(self.__pref__)._fn_enum_bp_companies(clean_env)
        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        status_projects, render_param['occupation.enumOccupations'] = P_OCCUPATION(self.__pref__)._fn_enum_occupations(chain_env)
        status_projects, render_param['skill.enumSkills'] = P_SKILL(self.__pref__)._fn_enum_skills(
            chain_env)
        status_skills, render_param['skill.enumSkillCategories'] = P_SKILL(self.__pref__)._fn_enum_skill_categories(
            chain_env)
        status_skills, render_param['skill.enumSkillLevels'] = P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
        if("engineer_id" in chain_env['argument'].data):
            status_projects, render_param['engineer.enumEngineers'] = P_ENGINEER(self.__pref__)._fn_enum_engineers(chain_env)
            if(not 'from_search_page' in chain_env['argument'].data):
                for engineerPram in render_param['engineer.enumEngineers']:
                    if (engineerPram['skill_id_list'] is not None):
                        chain_env['argument'].data['skill_id'] = engineerPram['skill_id_list'].split(",");
                        strSkillLevelList = []
                        for skillLevel in engineerPram['skill_level_list']:
                            strSkillLevel = {}
                            strSkillLevel["engineer_id"] = skillLevel["engineer_id"]
                            strSkillLevel["skill_id"] = str(skillLevel["skill_id"])
                            strSkillLevel["level"] = str(skillLevel["level"])
                            strSkillLevelList.append(strSkillLevel)
                        chain_env['argument'].data['skill_level_list'] = strSkillLevelList
                    # if (engineerPram['occupation_id_list'] is not None):
                    #     chain_env['argument'].data['occupation_id'] = engineerPram['occupation_id_list'].split(",");
                    if(engineerPram['age'] is not None):
                        chain_env['argument'].data['age_from'] = str(engineerPram['age']);
                    if (engineerPram['fee'] is not None):
                        engineerPram['fee'] = int(engineerPram['fee']) // 10000
                        chain_env['argument'].data['amount_from'] = str(engineerPram['fee']);
                    if (engineerPram['operation_begin'] is not None):
                        chain_env['argument'].data['term_begin'] = str(engineerPram['operation_begin']);
                    if (engineerPram['station_lat'] is not None):
                        chain_env['argument'].data['station_lat'] = str(engineerPram['station_lat']);
                    if (engineerPram['station_lon'] is not None):
                        chain_env['argument'].data['station_lon'] = str(engineerPram['station_lon']);
                    if (engineerPram['station'] is not None):
                        chain_env['argument'].data['station'] = engineerPram['station'];
                chain_env['argument'].data['flg_skill_level'] = "1"



        status_projects, render_param['project.enumProjects'] = P_PROJECT(self.__pref__)._fn_search_projects(chain_env)

        #[Begin] Filter by keyword
        if "keyword" in chain_env['argument'].data and chain_env['argument'].data['keyword']:
            keyword = chain_env['argument'].data['keyword']
            projects = []
            for project in render_param['project.enumProjects']:
                if  (project.get("rank") and project.get("rank").find(keyword) != -1) or \
                    (project.get("note") and project.get("note").find(keyword) != -1) or \
                    (project.get("title") and project.get("title").find(keyword) != -1) or \
                    (project.get("occupation") and project.get("occupation").find(keyword) != -1) or \
                    (project.get("owner_company_name") and project.get("owner_company_name").find(keyword) != -1) or \
                    (project.get("client_name") and project.get("client_name").find(keyword) != -1) or \
                    (project.get("skill") and project.get("skill").find(keyword) != -1) or \
                    (project.get("term_begin") and project.get("term_begin").find(keyword) != -1) or \
                    (project.get("term_end") and project.get("term_end").find(keyword) != -1) or \
                    (project.get("fee_outbound_comma") and project.get("fee_outbound_comma").find(keyword) != -1) or \
                    (project.get("fee_inbound_comma") and project.get("fee_inbound_comma").find(keyword) != -1) or \
                    (project.get("age_from") and str(project.get("age_from")).find(keyword) != -1) or \
                    (project.get("age_to") and str(project.get("age_to")).find(keyword) != -1) or \
                    (project.get("station") and project.get("station").find(keyword) != -1) or \
                    (project.get("travel_time") and str(project.get("travel_time")).find(keyword) != -1) or \
                    (project.get("interview") and str(project.get("interview")).find(keyword) != -1) or \
                    (project.get("charging_user") and project.get("charging_user").get("user_name") and project.get("charging_user").get("user_name").find(keyword) != -1) or \
                    (project.get("charging_user") and project.get("charging_user").get("login_id") and project.get("charging_user").get("login_id").find(keyword) != -1) or \
                    (project.get("expense") and project.get("expense").find(keyword) != -1) or \
                    (project.get("term_end") and project.get("term_end").find(keyword) != -1) or \
                    (project.get("skill_needs") and project.get("skill_needs").find(keyword) != -1) or \
                    (project.get("skill_recommends") and project.get("skill_recommends").find(keyword) != -1) or \
                    (project.get("flg_foreign_text") and project.get("flg_foreign_text").find(keyword) != -1) or \
                    (project.get("process") and project.get("process").find(keyword) != -1):
                    projects.append(project)
            render_param['project.enumProjects'] = projects

        if "note" in chain_env['argument'].data and chain_env['argument'].data['note']:
            render_param['project.enumProjects'] = [k for k in render_param['project.enumProjects'] if k.get("note") and k.get("note").find(chain_env['argument'].data['note']) != -1]

        status_projects, render_param['engineer.enumPrjEngineer'] = P_ENGINEER(self.__pref__)._fn_enum_prj_engineer(
            chain_env)
        query_data = copy.deepcopy(chain_env['argument'].data)
        if(not 'from_search_page' in chain_env['argument'].data):
            query_data['occupation_id'] = []
        render_param['matching.searchConditions'] = query_data
        render_param['matching.type'] = "matching.project"

        # [begin] Support objects.
        render_param['manage.enumPrefsDict'] = {}
        #[render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        # [end] Support objects.
        chain_env['response_body'] = flask.render_template( \
            "matching_project.tpl",
            data=render_param, \
            env=chain_env, \
            query=query_data, \
            trace=chain_env['trace'], \
            title=u"案件マッチング検索|SESクラウド", \
            current='matching.project' \
        )

        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)


    def _fn_search_engineer(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.project import Processor as P_PROJECT
        from logics.engineer import Processor as P_ENGINEER
        from logics.occupation import Processor as P_OCCUPATION
        from logics.skill import Processor as P_SKILL

        clean_env = copy.deepcopy(chain_env)
        if "client_id" in clean_env['argument'].data:
            del clean_env['argument'].data['client_id']
        status_clients, render_param['client.enumAllClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
        if "company_id" in clean_env['argument'].data:
            del clean_env['argument'].data['company_id']
        status_users, render_param['manage.enumBpCompanies'] = P_MANAGE(self.__pref__)._fn_enum_bp_companies(clean_env)
        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        #status_users, render_param['manage.enumAccounts'] = P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        #render_param['js.accounts'] = render_param['manage.enumAccounts']
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}
        status_projects, render_param['occupation.enumOccupations'] = P_OCCUPATION(self.__pref__)._fn_enum_occupations(
            chain_env)
        status_projects, render_param['skill.enumSkills'] = P_SKILL(self.__pref__)._fn_enum_skills(
            chain_env)
        status_skills, render_param['skill.enumSkillCategories'] = P_SKILL(self.__pref__)._fn_enum_skill_categories(
            chain_env)
        status_skills, render_param['skill.enumSkillLevels'] = P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)

        if ("project_id" in chain_env['argument'].data):
            # Fetch projects.
            status_projects, render_param['project.enumProjects'] = P_PROJECT(self.__pref__)._fn_enum_projects(
                chain_env)
            if (not 'from_search_page' in chain_env['argument'].data):
                for projectPram in render_param['project.enumProjects']:
                    if (projectPram['skill_id_list'] is not None):
                        chain_env['argument'].data['skill_id'] = projectPram['skill_id_list'].split(",");
                        strSkillLevelList = []
                        for skillLevel in projectPram['skill_level_list']:
                            strSkillLevel = {}
                            strSkillLevel["project_id"] = skillLevel["project_id"]
                            strSkillLevel["skill_id"] = str(skillLevel["skill_id"])
                            strSkillLevel["level"] = str(skillLevel["level"])
                            strSkillLevelList.append(strSkillLevel)
                        chain_env['argument'].data['skill_level_list'] = strSkillLevelList
                    if (projectPram['occupation_id_list'] is not None):
                        chain_env['argument'].data['occupation_id'] = projectPram['occupation_id_list'].split(",");
                    if (projectPram['term_begin'] is not None):
                        chain_env['argument'].data['term_begin'] = str(projectPram['term_begin']);
                    if (projectPram['term_end'] is not None):
                        chain_env['argument'].data['term_end'] = str(projectPram['term_end']);
                    if (projectPram['fee_outbound'] is not None):
                        projectPram['fee_outbound'] = int(projectPram['fee_outbound']) // 10000
                        chain_env['argument'].data['amount_to'] = str(projectPram['fee_outbound']);
                    if (projectPram['age_from'] is not None):
                        chain_env['argument'].data['age_from'] = str(projectPram['age_from']);
                    if (projectPram['age_to'] is not None):
                        chain_env['argument'].data['age_to'] = str(projectPram['age_to']);
                    if (projectPram['station_lat'] is not None):
                        chain_env['argument'].data['station_lat'] = str(projectPram['station_lat']);
                    if (projectPram['station_lon'] is not None):
                        chain_env['argument'].data['station_lon'] = str(projectPram['station_lon']);
                    if (projectPram['station'] is not None):
                        chain_env['argument'].data['station'] = projectPram['station'];
                chain_env['argument'].data['flg_skill_level'] = "1"

        status_projects, render_param['engineer.enumEngineers'] = P_ENGINEER(self.__pref__)._fn_search_engineers(
            chain_env)
        #import json as JSON
        #self.my_log("__search_enumEngineers " + JSON.dumps(render_param['engineer.enumEngineers']))
        #[Begin] Filter by keyword
        if "keyword" in chain_env['argument'].data and chain_env['argument'].data['keyword']:
            keyword = chain_env['argument'].data['keyword']
            engineers = []
            for engineer in render_param['engineer.enumEngineers']:
                if  (engineer.get("name") and engineer.get("name").find(keyword) != -1) or \
                    (engineer.get("visible_name") and engineer.get("visible_name").find(keyword) != -1) or \
                    (engineer.get("kana") and engineer.get("kana").find(keyword) != -1) or \
                    (engineer.get("tel") and engineer.get("tel").find(keyword) != -1) or \
                    (engineer.get("mail1") and engineer.get("mail1").find(keyword) != -1) or \
                    (engineer.get("mail2") and engineer.get("mail2").find(keyword) != -1) or \
                    (engineer.get("birth") and engineer.get("birth").find(keyword) != -1) or \
                    (engineer.get("contract") and engineer.get("contract").find(keyword) != -1) or \
                    (engineer.get("note") and engineer.get("note").find(keyword) != -1) or \
                    (engineer.get("occupation_list") and engineer.get("occupation_list").find(keyword) != -1) or \
                    (engineer.get("client_name") and engineer.get("client_name").find(keyword) != -1) or \
                    (engineer.get("company_name") and engineer.get("company_name").find(keyword) != -1) or \
                    (engineer.get("operation_begin") and engineer.get("operation_begin").find(keyword) != -1) or \
                    (engineer.get("fee_comma") and engineer.get("fee_comma").find(keyword) != -1) or \
                    (engineer.get("age") and str(engineer.get("age")).find(keyword) != -1) or \
                    (engineer.get("gender") and engineer.get("gender").find(keyword) != -1) or \
                    (engineer.get("station") and engineer.get("station").find(keyword) != -1) or \
                    (engineer.get("state_work") and engineer.get("state_work").find(keyword) != -1) or \
                    (engineer.get("travel_time") and str(engineer.get("travel_time")).find(keyword) != -1) or \
                    (engineer.get("charging_user") and engineer.get("charging_user").get("user_name") and engineer.get("charging_user").get("user_name").find(keyword) != -1) or \
                    (engineer.get("charging_user") and engineer.get("charging_user").get("login_id") and engineer.get("charging_user").get("login_id").find(keyword) != -1) or \
                    (engineer.get("skill_list") and engineer.get("skill_list").find(keyword) != -1):
                    engineers.append(engineer)
            render_param['engineer.enumEngineers'] = engineers

        if "note" in chain_env['argument'].data and chain_env['argument'].data['note']:
            render_param['engineer.enumEngineers'] = [k for k in render_param['engineer.enumEngineers'] if k.get("note") and k.get("note").find(chain_env['argument'].data['note']) != -1]
        status_projects, render_param['engineer.enumPrjEngineer'] = P_ENGINEER(self.__pref__)._fn_enum_prj_engineer(
            chain_env)
        render_param['matching.searchConditions'] = chain_env['argument'].data
        render_param['matching.type'] = "matching.engineer"


        chain_env['response_body'] = flask.render_template( \
            "matching_engineer.tpl",
            data=render_param, \
            env=chain_env, \
            query=chain_env['argument'].data, \
            trace=chain_env['trace'], \
            title=u"要員マッチング検索|SESクラウド", \
            current='matching.engineer' \
            )
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)


    def _fn_relate_engineer_to_project(self, chain_env):
        from models.project import Project as P_Model
        from models.operation import Operation as O_Model

        time_bg = time.time()
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            conflicts = set()
            inserted = set()
            for selected_engineer_id in set(chain_env['argument'].data['selected_engineers']):
                for selected_project_id in set(chain_env['argument'].data['selected_projects']):
                    param = (selected_project_id, selected_engineer_id,)
                    try:
                        dbcur.execute(P_Model.sql("insert_cr_prj_engineer"), param)
                        dbcur.execute(O_Model.sql("create_operation"), param)
                    except Exception, err:
                            chain_env['trace'].append(err)
                            chain_env['status']['code'] = 2
                            print err
                    else:
                        inserted.add(param[0])

            dbcon.commit() if inserted else None
            chain_env['results'] = {"conflicts": tuple(conflicts), "inserted": tuple(inserted)}
            chain_env['status']['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['logger']("webapi", chain_env['argument'].data)
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_disconnect_engineer_from_project(self, chain_env):
        from models.project import Project as P_Model
        from models.operation import Operation as O_Model

        time_bg = time.time()
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            conflicts = set()
            deleted = set()
            param = (chain_env['argument'].data['selected_project_id'], chain_env['argument'].data['selected_engineer_id'])
            try:
                dbcur.execute(P_Model.sql("delete_cr_prj_engineer"), param)
                dbcur.execute(O_Model.sql("delete_operation"), param)
            except Exception, err:
                    chain_env['trace'].append(err)
                    chain_env['status']['code'] = 2
                    print err
            else:
                deleted.add(param[0])

            dbcon.commit() if deleted else None
            chain_env['results'] = {"conflicts": tuple(conflicts), "deleted": tuple(deleted)}
            chain_env['status']['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['logger']("webapi", chain_env['argument'].data)
        self.perf_time(chain_env, time.time() - time_bg)
