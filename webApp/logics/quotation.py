#!/usr/local/bin/python
# -*- coding: UTF-8 -*-

import time
import datetime
import pprint
import traceback
import urllib
import pdfkit
import flask
import werkzeug
import hashlib
import copy
from providers.limitter import Limitter
from base import ProcessorBase
from errors import exceptions as EXC
import cStringIO as SIO
from models.quotation import Quotation as Model

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

PDF_OUTPUT_OPTION = {
            'page-size': 'A4',
            'margin-top': '0.75in',
            'margin-right': '0.75in',
            'margin-bottom': '0.75in',
            'margin-left': '0.75in',
            'encoding': "UTF-8",
            'custom-header': [
                ('Accept-Encoding', 'gzip')
            ],
            'no-outline': None
        }
PDF_REPORT_OUTPUT_OPTION = {
            'page-size': 'A4',
            'margin-top': '0.25in',
            'margin-right': '0.75in',
            'margin-bottom': '0.25in',
            'margin-left': '0.75in',
            'encoding': "UTF-8",
            'custom-header': [
                ('Accept-Encoding', 'gzip')
            ],
            'no-outline': None
        }

class Processor(ProcessorBase):
    __realms__ = { \
        "topEstimate": { \
            "logic": "html_top_estimate", \
            }, \
        "topOrder": { \
            "logic": "html_top_order", \
            }, \
        "topInvoice": { \
            "logic": "html_top_invoice", \
            }, \
        "getDataForExcel": { \
            "logic": "get_data_for_excel", \
            }, \
        "topPurchase": { \
            "logic": "html_top_purchase", \
            }, \
        "downloadEstimate": { \
            "logic": "download_estimate", \
            }, \
        "downloadOrder": { \
            "logic": "download_order", \
            },
        "downloadInvoice": { \
            "logic": "download_invoice", \
            }, \
        "downloadPurchase": { \
            "logic": "download_purchase", \
            }, \
        "createEstimate": { \
            "logic": "create_estimate", \
            }, \
        "createEstimateSend": { \
            "logic": "create_estimate_send", \
            }, \
        "createOrder": { \
            "logic": "create_order", \
            },
        "createInvoice": { \
            "logic": "create_invoice", \
            }, \
        "createInvoiceSend": { \
            "logic": "create_invoice_send", \
            }, \
        "createPurchase": { \
            "logic": "create_purchase", \
            }, \
        "createPurchaseSend": { \
            "logic": "create_purchase_send", \
            }, \
        "downloadPdfEstimate": { \
            "logic": "download_pdf_estimate", \
            }, \
        "downloadPdfOrder": { \
            "logic": "download_pdf_order", \
            }, \
        "downloadPdfInvoice": { \
            "logic": "download_pdf_invoice", \
            }, \
        "downloadPdfPurchase": { \
            "logic": "download_pdf_purchase", \
            }, \
        "downloadPdfProject": { \
            "logic": "download_pdf_project", \
        }, \
        "downloadPdfEngineer": { \
            "logic": "download_pdf_engineer", \
        }, \
        "downloadPdfMatchingProject": { \
            "logic": "download_pdf_matching_project", \
        }, \
        "downloadPdfMatchingEngineer": { \
            "logic": "download_pdf_matching_engineer", \
        }, \
        
 \
        }

    from logics.auth import Processor as P_AUTH
    from logics.manage import Processor as P_MANAGE
    from logics.client import Processor as P_CLIENT
    from logics.operation import Processor as P_OPERATION
    from logics.estimate import Processor as P_ESTIMATE
    from logics.order import Processor as P_ORDER
    from logics.invoice import Processor as P_INVOICE
    from logics.purchase import Processor as P_PURCHASE
    from logics.project import Processor as P_PROJECT
    from logics.skill import Processor as P_SKILL
    from logics.occupation import Processor as P_OCCUPATION
    from logics.engineer import Processor as P_ENGINEER

    def _fn_html_top_estimate(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}

        status_profile, render_param['auth.userProfile'] = self.P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = self.P_MANAGE(self.__pref__)._fn_read_user_profile(chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        clean_env = copy.deepcopy(chain_env)
        status_client, render_param['client.enumClients'] = self.P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
        render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in render_param['client.enumClients']]
        status_skills, render_param['skill.enumSkills'] = self.P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
        status_skills, render_param['skill.enumSkillCategories'] = self.P_SKILL(self.__pref__)._fn_enum_skill_categories(chain_env)
        status_skills, render_param['skill.enumSkillLevels'] = self.P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
        status_projects, render_param['occupation.enumOccupations'] = self.P_OCCUPATION(self.__pref__)._fn_enum_occupations(chain_env)

        chain_env['argument'].data['from_operation'] = "true"

        if "project_id" in chain_env['argument'].data or "operation_ids" in chain_env['argument'].data:
            chain_env['argument'].data["is_active"] = 1
            status_operation, render_param['operation.enumOperations'] = self.P_OPERATION(self.__pref__)._fn_enum_operations(
                chain_env)
            status_project, render_param['operation.enumProjects'] = self.P_PROJECT(self.__pref__)._fn_enum_projects(
                chain_env)
            if "project_id" not in chain_env['argument'].data:
                chain_env['argument'].data['project_id'] = chain_env['argument'].data['project_id_top']
        else:
            render_param['operation.enumOperations'] = []

        if "quotation_id" in chain_env['argument'].data:
            render_param['quotation_id'] = chain_env['argument'].data['quotation_id']
            status_estimate, render_param['output_history_rec'] = self.P_ESTIMATE(self.__pref__)._fn_enum_estimates(chain_env)
            render_param['output_history_rec'] = render_param['output_history_rec'][0]["output_val"]
        else:
            render_param['quotation_id'] = 0

        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
            dbcur.execute(Model.sql("last_quotation_no_estimate"), param)
            quotation_default_no = Model.convert("last_quotation_no", dbcur)
            render_param["quotation_default_no"] = quotation_default_no
            dbcur.close()
            dbcon.close()
        from decimal import Decimal
        chain_env['response_body'] = flask.render_template( \
            "quotation.tpl",
            data=render_param, \
            env=chain_env, \
            query=chain_env['argument'].data, \
            trace=chain_env['trace'], \
            title=u"?????????|SES????????????", \
            current="quotation.topEstimate")
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_html_top_order(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}

        status_profile, render_param['auth.userProfile'] = self.P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = self.P_MANAGE(self.__pref__)._fn_read_user_profile(chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        clean_env = copy.deepcopy(chain_env)
        status_client, render_param['client.enumClients'] = self.P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
        render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in render_param['client.enumClients']]
        status_skills, render_param['skill.enumSkills'] = self.P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
        status_skills, render_param['skill.enumSkillCategories'] = self.P_SKILL(self.__pref__)._fn_enum_skill_categories(chain_env)
        status_skills, render_param['skill.enumSkillLevels'] = self.P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
        status_projects, render_param['occupation.enumOccupations'] = self.P_OCCUPATION(self.__pref__)._fn_enum_occupations(chain_env)

        chain_env['argument'].data['from_operation'] = "true"

        if "project_id" in chain_env['argument'].data:
            chain_env['argument'].data["is_active"] = 1
            status_operation, render_param['operation.enumOperations'] = self.P_OPERATION(self.__pref__)._fn_enum_operations(
                chain_env)
            status_project, render_param['operation.enumProjects'] = self.P_PROJECT(self.__pref__)._fn_enum_projects(
                chain_env)
        else:
            render_param['operation.enumOperations'] = []

        if "quotation_id" in chain_env['argument'].data:
            render_param['quotation_id'] = chain_env['argument'].data['quotation_id']
            status_estimate, render_param['output_history_rec'] = self.P_ORDER(self.__pref__)._fn_enum_orders(chain_env)
            render_param['output_history_rec'] = render_param['output_history_rec'][0]["output_val"]
        else:
            render_param['quotation_id'] = 0

        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
            dbcur.execute(Model.sql("last_quotation_no_estimate"), param)
            quotation_default_no = Model.convert("last_quotation_no", dbcur)
            render_param["quotation_default_no"] = quotation_default_no
            dbcur.close()
            dbcon.close()

        chain_env['response_body'] = flask.render_template( \
            "quotation_order.tpl",
            data=render_param, \
            env=chain_env, \
            query=chain_env['argument'].data, \
            trace=chain_env['trace'], \
            title=u"??????????????????|SES????????????", \
            current="quotation.topOrder")
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_html_top_invoice(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}

        status_profile, render_param['auth.userProfile'] = self.P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = self.P_MANAGE(self.__pref__)._fn_read_user_profile( chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        clean_env = copy.deepcopy(chain_env)
        status_client, render_param['client.enumClients'] = self.P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
        render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in render_param['client.enumClients']]
        status_skills, render_param['skill.enumSkills'] = self.P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
        status_skills, render_param['skill.enumSkillCategories'] = self.P_SKILL(self.__pref__)._fn_enum_skill_categories(chain_env)
        status_skills, render_param['skill.enumSkillLevels'] = self.P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
        status_projects, render_param['occupation.enumOccupations'] = self.P_OCCUPATION(self.__pref__)._fn_enum_occupations(chain_env)

        chain_env['argument'].data['from_operation'] = "true"

        if "project_id" in chain_env['argument'].data or "operation_ids" in chain_env['argument'].data:
            chain_env['argument'].data["is_active"] = 1;
            status_operation, render_param['operation.enumOperations'] = self.P_OPERATION(self.__pref__)._fn_enum_operations(
                chain_env)
            status_project, render_param['operation.enumProjects'] = self.P_PROJECT(self.__pref__)._fn_enum_projects(
                chain_env)
            if "project_id" not in chain_env['argument'].data:
                chain_env['argument'].data['project_id'] = chain_env['argument'].data['project_id_top']
        else:
            render_param['operation.enumOperations'] = []

        if "quotation_id" in chain_env['argument'].data:
            chain_env['argument'].data['output_history'] = 1
            render_param['quotation_id'] = chain_env['argument'].data['quotation_id']
            status_estimate, render_param['output_history_rec'], _, _ = self.P_INVOICE(self.__pref__)._fn_enum_invoices(chain_env)
            render_param['output_history_rec'] = render_param['output_history_rec'][0]["output_val"]
        else:
            render_param['quotation_id'] = 0

        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
            dbcur.execute(Model.sql("last_quotation_no_estimate"), param)
            quotation_default_no = Model.convert("last_quotation_no", dbcur)
            render_param["quotation_default_no"] = quotation_default_no
            dbcur.close()
            dbcon.close()

        chain_env['response_body'] = flask.render_template( \
            "quotation.tpl",
            data=render_param, \
            env=chain_env, \
            query=chain_env['argument'].data, \
            trace=chain_env['trace'], \
            title=u"?????????|SES????????????", \
            current="quotation.topInvoice")
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_get_data_for_excel(self, chain_env):
        self.my_log("_fn_get_data_for_excel")
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        
        chain_env['argument'].data['from_operation'] = "true"
        chain_env['argument'].data["is_active"] = 1
        
        if "where" in chain_env['argument'].data:
            chain_env['argument'].data['output_history'] = 1
            status_estimate, render_param['output_history_rec'], _, _ = self.P_INVOICE(self.__pref__)._fn_get_invoices_by_id_array(chain_env)
        else:
            render_param['quotation_id'] = 0
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_html_top_purchase(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}

        status_profile, render_param['auth.userProfile'] = self.P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = self.P_MANAGE(self.__pref__)._fn_read_user_profile(chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        clean_env = copy.deepcopy(chain_env)
        status_client, render_param['client.enumClients'] = self.P_CLIENT(self.__pref__)._fn_enum_clients(clean_env)
        render_param['js.clients'] = [{"label": tmp['name'], "id": tmp['id']} for tmp in render_param['client.enumClients']]
        status_skills, render_param['skill.enumSkills'] = self.P_SKILL(self.__pref__)._fn_enum_skills(chain_env)
        status_skills, render_param['skill.enumSkillCategories'] = self.P_SKILL(self.__pref__)._fn_enum_skill_categories(chain_env)
        status_skills, render_param['skill.enumSkillLevels'] = self.P_SKILL(self.__pref__)._fn_enum_skill_levels(chain_env)
        status_projects, render_param['occupation.enumOccupations'] = self.P_OCCUPATION(self.__pref__)._fn_enum_occupations(chain_env)

        chain_env['argument'].data['from_operation'] = "true"

        if "project_id" in chain_env['argument'].data or "operation_ids" in chain_env['argument'].data:
            chain_env['argument'].data["is_active"] = 1;
            status_operation, render_param['operation.enumOperations'] = self.P_OPERATION(self.__pref__)._fn_enum_operations(
                chain_env)
            status_project, render_param['operation.enumProjects'] = self.P_PROJECT(self.__pref__)._fn_enum_projects(
                chain_env)
            if "project_id" not in chain_env['argument'].data:
                chain_env['argument'].data['project_id'] = chain_env['argument'].data['project_id_top']
            for tmp_operation_obj in render_param['operation.enumOperations']:
                if tmp_operation_obj['engineer_client_id'] is None:
                    chain_env['argument'].data['engineer_id'] = tmp_operation_obj['engineer_id']
        else:
            render_param['operation.enumOperations'] = []

        if "quotation_id" in chain_env['argument'].data:
            render_param['quotation_id'] = chain_env['argument'].data['quotation_id']
            status_estimate, render_param['quotation.purchases'] = self.P_PURCHASE(self.__pref__)._fn_enum_purchases(chain_env)
            render_param['output_history_rec'] = render_param['quotation.purchases'][0]["output_val"]
        else:
            render_param['quotation_id'] = 0

        if "company_id" in chain_env['argument'].data:
            if chain_env['argument'].data["company_id"]:
                render_param['company_id'] = chain_env['argument'].data['company_id']
                status_estimate, render_param['manage.enumUserCompanies'] = self.P_MANAGE(self.__pref__)._fn_enum_user_companies(chain_env)
                render_param['manage.enumUserCompanies'] = filter((lambda x: x['id'] == chain_env['argument'].data['company_id']),render_param['manage.enumUserCompanies'])

        if "client_id" in chain_env['argument'].data:
            if chain_env['argument'].data["client_id"]:
                render_param['client_id'] = chain_env['argument'].data['client_id']

        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            param = (chain_env['prefix'], chain_env['login_id'], chain_env['credential'])
            dbcur.execute(Model.sql("last_quotation_no_purchase"), param)
            quotation_default_no = Model.convert("last_quotation_no", dbcur)
            render_param["quotation_default_no"] = quotation_default_no
            dbcur.close()
            dbcon.close()

        chain_env['response_body'] = flask.render_template( \
            "quotation_purchase.tpl",
            data=render_param, \
            env=chain_env, \
            query=chain_env['argument'].data, \
            trace=chain_env['trace'], \
            title=u"?????????|SES????????????", \
            current="quotation.topPurchase")
        chain_env['logger']("webhtml", ("END", None))
        self.perf_time(chain_env, time.time() - time_bg)

    def _fn_download_estimate(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
            chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}

        result = {}
        status = {"code": None, "description": None}

        #template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        #pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows
        body = flask.render_template("pdf_estimate.tpl", data=render_param, env=chain_env['argument'].data)

        # ???????????????#????????????????????????????????????????????????????????????
        # chain_env['response_body'] = flask.render_template( \
        #     "pdf_estimate.tpl",
        #     data=render_param, \
        #     env=chain_env['argument'].data, \
        #     query=chain_env['argument'].data, \
        #     trace=chain_env['trace'], \
        #     title=u"?????????|SES????????????")
        # chain_env['logger']("webhtml", ("END", None))
        # self.perf_time(chain_env, time.time() - time_bg)
        # return status, result
        # ???????????????#????????????????????????????????????????????????????????????

        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        #pdf_buf = pdfkit.from_string(body, 'out.pdf', configuration=config, options=options)
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_REPORT_OUTPUT_OPTION)

        # pdf_title = "?????????_.pdf"
        pdf_title = "?????????_" \
                    + chain_env['argument'].data['output']['quotation_no'] \
                    + "_" \
                    + render_param['client.enumClients'][0]['name'] \
                    + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }

        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_create_estimate(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}
        # [render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        result = {}
        status = {"code": None, "description": None}

        pdf_file_name_base = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        pdf_file_name = hashlib.sha256(pdf_file_name_base).hexdigest() + ".pdf"
        chain_env['argument'].data['pdffile_path'] = pdf_file_name

        if "quotation_id" in chain_env['argument'].data and chain_env['argument'].data["quotation_id"] != 0:
            result = self._fn_update_quotation_history_estimate(chain_env)
        else:
            result = self._fn_insert_quotation_history_estimate(chain_env)

        if "make_pdf" not in chain_env['argument'].data:
            status['code'] = 0
            chain_env['results'] = result
            chain_env['status'] = status
            chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
            self.perf_time(chain_env, time.time() - time_bg)
            return status, result

        # template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        # pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_estimate.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, "download/" + pdf_file_name, configuration=config, options=PDF_OUTPUT_OPTION)

        status['code'] = 0
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_create_estimate_send(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}
        # [render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        result = {}
        status = {"code": None, "description": None}

        pdf_file_name_base = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        pdf_file_name = hashlib.sha256(pdf_file_name_base).hexdigest() + ".pdf"
        chain_env['argument'].data['pdffile_path'] = pdf_file_name

        if "quotation_id" in chain_env['argument'].data and chain_env['argument'].data["quotation_id"] != 0:
            result = self._fn_update_quotation_history_estimate_send(chain_env)
        else:
            result = self._fn_insert_quotation_history_estimate(chain_env)

        if "make_pdf" not in chain_env['argument'].data:
            status['code'] = 0
            chain_env['results'] = result
            chain_env['status'] = status
            chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
            self.perf_time(chain_env, time.time() - time_bg)
            return status, result


        #template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        #pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_estimate.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, "download/" + pdf_file_name, configuration=config, options=PDF_OUTPUT_OPTION)

        status['code'] = 0
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_create_order(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}
        # [render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        # [end] Support objects.


        result = {}
        status = {"code": None, "description": None}

        pdf_file_name_base = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        pdf_file_name = hashlib.sha256(pdf_file_name_base).hexdigest() + ".pdf"
        chain_env['argument'].data['pdffile_path'] = pdf_file_name

        if "quotation_id" in chain_env['argument'].data and chain_env['argument'].data["quotation_id"] != 0:
            result = self._fn_update_quotation_history_order(chain_env)
        else:
            result = self._fn_insert_quotation_history_order(chain_env)

        if "make_pdf" not in chain_env['argument'].data:
            status['code'] = 0
            chain_env['results'] = result
            chain_env['status'] = status
            chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
            self.perf_time(chain_env, time.time() - time_bg)
            return status, result

        # template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        # pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_order2.tpl", data=render_param, env=chain_env['argument'].data)
        body += flask.render_template("pdf_order.tpl", data=render_param, env=chain_env['argument'].data)

        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")

        pdf_buf = pdfkit.from_string(body, "download/" + pdf_file_name, configuration=config, options=PDF_OUTPUT_OPTION)

        status['code'] = 0
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_create_invoice(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}
        # [render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        # [end] Support objects.


        result = {}
        status = {"code": None, "description": None}

        pdf_file_name_base = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        pdf_file_name = hashlib.sha256(pdf_file_name_base).hexdigest() + ".pdf"
        chain_env['argument'].data['pdffile_path'] = pdf_file_name

        if "quotation_id" in chain_env['argument'].data and chain_env['argument'].data["quotation_id"] != 0:
            result = self._fn_update_quotation_history_invoice(chain_env)
        else:
            result = self._fn_insert_quotation_history_invoice(chain_env)

        if "make_pdf" not in chain_env['argument'].data:
            status['code'] = 0
            chain_env['results'] = result
            chain_env['status'] = status
            chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
            self.perf_time(chain_env, time.time() - time_bg)
            return status, result

        # template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        # pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_invoice.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, "download/" + pdf_file_name, configuration=config, options=PDF_OUTPUT_OPTION)

        status['code'] = 0
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result


    def _fn_create_invoice_send(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}
        # [render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        # [end] Support objects.


        result = {}
        status = {"code": None, "description": None}

        pdf_file_name_base = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        pdf_file_name = hashlib.sha256(pdf_file_name_base).hexdigest() + ".pdf"
        chain_env['argument'].data['pdffile_path'] = pdf_file_name

        if "quotation_id" in chain_env['argument'].data and chain_env['argument'].data["quotation_id"] != 0:
            result = self._fn_update_quotation_history_invoice_send(chain_env)
        else:
            result = self._fn_insert_quotation_history_invoice(chain_env)

        if "make_pdf" not in chain_env['argument'].data:
            status['code'] = 0
            chain_env['results'] = result
            chain_env['status'] = status
            chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
            self.perf_time(chain_env, time.time() - time_bg)
            return status, result

        # template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        # pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_invoice.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, "download/" + pdf_file_name, configuration=config, options=PDF_OUTPUT_OPTION)

        status['code'] = 0
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_create_purchase(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}

        if "company_id" in chain_env['argument'].data:
            if chain_env['argument'].data["company_id"]:
                render_param['company_id'] = chain_env['argument'].data['company_id']
                status_estimate, render_param['manage.enumUserCompanies'] = P_MANAGE(self.__pref__)._fn_enum_user_companies(chain_env)
                render_param['manage.enumUserCompanies'] = filter((lambda x: x['id'] == int(chain_env['argument'].data['company_id'])),render_param['manage.enumUserCompanies'])
        # [render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        # [end] Support objects.

        result = {}
        status = {"code": None, "description": None}

        pdf_file_name_base = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        pdf_file_name = hashlib.sha256(pdf_file_name_base).hexdigest() + ".pdf"
        chain_env['argument'].data['pdffile_path'] = pdf_file_name

        if "quotation_id" in chain_env['argument'].data and chain_env['argument'].data["quotation_id"] != 0:
            result = self._fn_update_quotation_history_purchase(chain_env)
        else:
            result = self._fn_insert_quotation_history_purchase(chain_env)

        if "make_pdf" not in chain_env['argument'].data:
            status['code'] = 0
            chain_env['results'] = result
            chain_env['status'] = status
            chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
            self.perf_time(chain_env, time.time() - time_bg)
            return status, result

        # template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        # pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_purchase.tpl", data=render_param, env=chain_env['argument'].data)
        body += flask.render_template("pdf_purchase2.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, "download/" + pdf_file_name, configuration=config, options=PDF_OUTPUT_OPTION)

        status['code'] = 0
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_create_purchase_send(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)
        render_param['manage.enumPrefsDict'] = {}

        if "company_id" in chain_env['argument'].data:
            if chain_env['argument'].data["company_id"]:
                render_param['company_id'] = chain_env['argument'].data['company_id']
                status_estimate, render_param['manage.enumUserCompanies'] = P_MANAGE(self.__pref__)._fn_enum_user_companies(chain_env)
                render_param['manage.enumUserCompanies'] = filter((lambda x: x['id'] == int(chain_env['argument'].data['company_id'])),render_param['manage.enumUserCompanies'])
        # [render_param['manage.enumPrefsDict'].update({obj['key']: obj}) for obj in render_param['manage.enumPrefs']]
        # [end] Support objects.

        result = {}
        status = {"code": None, "description": None}

        pdf_file_name_base = datetime.datetime.now().strftime("%Y%m%d%H%M%S")
        pdf_file_name = hashlib.sha256(pdf_file_name_base).hexdigest() + ".pdf"
        chain_env['argument'].data['pdffile_path'] = pdf_file_name

        if "quotation_id" in chain_env['argument'].data and chain_env['argument'].data["quotation_id"] != 0:
            result = self._fn_update_quotation_history_purchase_send(chain_env)
        else:
            result = self._fn_insert_quotation_history_purchase(chain_env)

        if "make_pdf" not in chain_env['argument'].data:
            status['code'] = 0
            chain_env['results'] = result
            chain_env['status'] = status
            chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
            self.perf_time(chain_env, time.time() - time_bg)
            return status, result

        # template = flask.Flask.jinja_env.get_template('fmt_quotation.tpl')
        # pdf_buf = pdfkit.from_string(template.render(users=users), False)
        import sys
        # sys????????????????????????????????????
        reload(sys)
        # ???????????????????????????????????????????????????
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_purchase.tpl", data=render_param, env=chain_env['argument'].data)
        body += flask.render_template("pdf_purchase2.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, "download/" + pdf_file_name, configuration=config, options=PDF_OUTPUT_OPTION)

        status['code'] = 0
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result


    def _fn_download_order(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION
        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)

        # self._fn_insert_quotation_history_order(chain_env)

        result = {}
        status = {"code": None, "description": None}

        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_order2.tpl", data=render_param, env=chain_env['argument'].data)
        body += flask.render_template("pdf_order.tpl", data=render_param, env=chain_env['argument'].data)

        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_REPORT_OUTPUT_OPTION)
        pdf_title = "?????????_" \
                    + chain_env['argument'].data['output']['quotation_no'] \
                    + "_" \
                    + render_param['client.enumClients'][0]['name'] \
                    + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }
        status['code'] = 0
        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_invoice(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)

        # self._fn_insert_quotation_history_invoice(chain_env)

        result = {}
        status = {"code": None, "description": None}
        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_invoice.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_REPORT_OUTPUT_OPTION)
        pdf_title = "?????????_" \
                    + chain_env['argument'].data['output']['quotation_no'] \
                    + "_" \
                    + render_param['client.enumClients'][0]['name'] \
                    + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }

        status['code'] = 0
        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_purchase(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        from logics.auth import Processor as P_AUTH
        from logics.manage import Processor as P_MANAGE
        from logics.client import Processor as P_CLIENT
        from logics.operation import Processor as P_OPERATION

        status_profile, render_param['auth.userProfile'] = P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_limit, render_param['limit.count_records'] = Limitter.count_records(self.__pref__, chain_env)
        status_profile, render_param['manage.readUserProfile'] = P_MANAGE(self.__pref__)._fn_read_user_profile(
            chain_env)
        status_users, render_param['manage.enumAccounts'] = self.P_MANAGE(self.__pref__)._fn_enum_accounts(chain_env)
        chain_env['argument'].data['from_operation'] = "true"
        # status_engineer, render_param['operation.enumOperations'] = P_OPERATION(self.__pref__)._fn_enum_operations(
        #     chain_env)
        status_clients, render_param['client.enumClients'] = P_CLIENT(self.__pref__)._fn_enum_clients(chain_env)

        render_param['manage.enumUserCompanies'] = []
        # if "company_id" in chain_env['argument'].data:
        #     if chain_env['argument'].data["company_id"]:
        #         render_param['company_id'] = chain_env['argument'].data['company_id']
        #         status_estimate, render_param['manage.enumUserCompanies'] = P_MANAGE(self.__pref__)._fn_enum_user_companies(chain_env)
        #         render_param['manage.enumUserCompanies'] = filter((lambda x: x['id'] == int(chain_env['argument'].data['company_id'])), render_param['manage.enumUserCompanies'])
        # # self._fn_insert_quotation_history_invoice(chain_env)

        # print render_param['operation.enumOperations']

        result = {}
        status = {"code": None, "description": None}
        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')

        tmp_print_rows = []
        self._fn_setting_print_rows(tmp_print_rows, chain_env['argument'].data["output"])
        chain_env['argument'].data["output"]["print_rows"] = tmp_print_rows

        body = flask.render_template("pdf_purchase.tpl", data=render_param, env=chain_env['argument'].data)
        body += flask.render_template("pdf_purchase2.tpl", data=render_param, env=chain_env['argument'].data)
        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_REPORT_OUTPUT_OPTION)

        # client_name =""
        # if render_param['manage.enumUserCompanies']:
        #     client_name = render_param['manage.enumUserCompanies'][0]['name']
        # elif render_param['client.enumClients']:
        #     client_name = render_param['client.enumClients'][0]['name']

        pdf_title = "?????????_" \
                    + chain_env['argument'].data['output']['quotation_no'] \
                    + "_" \
                    + chain_env['argument'].data['output']['addr_name'] \
                    + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }

        status['code'] = 0
        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_insert_quotation_history_estimate(self, chain_env):

        result = {}
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

            param = (chain_env['argument'].data["project_id"],
                     chain_env['argument'].data["client_id"],
                     JSON.dumps(chain_env['argument'].data),
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['argument'].data["quotation_name"],
                     chain_env['argument'].data["quotation_no"],
                     chain_env['argument'].data["quotation_date"],
                     chain_env['argument'].data["total_including_tax"],
                     chain_env['argument'].data["is_view_window"],
                     chain_env['argument'].data["is_view_excluding_tax"],
                     chain_env['argument'].data["pdffile_path"],
                     chain_env['argument'].data["office_memo"],
                     )
            try:
                dbcur.execute(Model.sql("insert_quotation_history_estimate"), param)

            except Exception, err:
                chain_env['trace'].append(err)
                chain_env['status']['code'] = 2
                print err
            else:
                deleted.add(param[0])
                try:
                    dbcur.execute(Model.sql("last_insert_id"))
                except Exception, err:
                    chain_env['trace'].append(err)
                else:
                    result = Model.convert("last_insert_id", dbcur)
                    chain_env['argument'].data["id"] = result['id']
            dbcon.commit() if deleted else None
            chain_env['results'] = {"conflicts": tuple(conflicts), "deleted": tuple(deleted)}
            chain_env['status']['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['logger']("webapi", chain_env['argument'].data)
        self.perf_time(chain_env, time.time() - time_bg)
        return result

    def _fn_update_quotation_history_estimate(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        status = {"code": None, "description": None}
        result = {}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            # [begin] SQL preparation.
            ACCEPT_FIELDS = ( \
                "project_id", "client_id", "dt_created","owner_company_id", "quotation_name", "quotation_no",\
                "quotation_date", "total_including_tax", "is_view_window", "is_view_excluding_tax", "is_enabled", "is_send", "modifier_id", \
                "pdffile_path", "office_memo",)
            args = chain_env['argument'].data
            if "scheme" in args and args['scheme'] == "":
                args['scheme'] = None
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]

            cols += ["output_val"]
            vals += [JSON.dumps(chain_env['argument'].data)]

            print(chain_env)

            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] + \
                vals + \
                [args['quotation_id'], chain_env['prefix'], args['login_id']]
            # [end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_quotation_history_estimate") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                print err
                result = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                    status['code'] = 2
            else:
                chain_env['trace'].append(dbcur._executed)
                result = {}
                status['code'] = status['code'] or 0

            dbcon.commit() if status['code'] == 0 else dbcon.rollback()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_update_quotation_history_estimate_send(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        status = {"code": None, "description": None}
        result = {}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            # [begin] SQL preparation.
            ACCEPT_FIELDS = ( \
                "project_id", "client_id", "dt_created","owner_company_id", "quotation_name", "quotation_no",\
                "quotation_date", "total_including_tax", "is_view_window", "is_view_excluding_tax", "is_enabled", "is_send", "modifier_id", \
                "pdffile_path", "office_memo",)
            args = chain_env['argument'].data
            if "scheme" in args and args['scheme'] == "":
                args['scheme'] = None
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]

            print(chain_env)

            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] + \
                vals + \
                [args['quotation_id'], chain_env['prefix'], args['login_id']]
            # [end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_quotation_history_estimate") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                print err
                result = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                    status['code'] = 2
            else:
                chain_env['trace'].append(dbcur._executed)
                result = {}
                status['code'] = status['code'] or 0

            dbcon.commit() if status['code'] == 0 else dbcon.rollback()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result


    def _fn_insert_quotation_history_order(self, chain_env):

        result = {}
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

            param = (chain_env['argument'].data["project_id"],
                     chain_env['argument'].data["client_id"],
                     JSON.dumps(chain_env['argument'].data),
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['argument'].data["quotation_name"],
                     chain_env['argument'].data["quotation_no"],
                     chain_env['argument'].data["quotation_date"],
                     chain_env['argument'].data["total_including_tax"],
                     chain_env['argument'].data["is_view_window"],
                     chain_env['argument'].data["is_view_excluding_tax"],
                     chain_env['argument'].data["pdffile_path"],
                     chain_env['argument'].data["office_memo"],
                     )
            try:
                dbcur.execute(Model.sql("insert_quotation_history_order"), param)

            except Exception, err:
                chain_env['trace'].append(err)
                chain_env['status']['code'] = 2
                print err
            else:
                deleted.add(param[0])
                try:
                    dbcur.execute(Model.sql("last_insert_id"))
                except Exception, err:
                    chain_env['trace'].append(err)
                else:
                    result = Model.convert("last_insert_id", dbcur)
                    chain_env['argument'].data["id"] = result['id']
            dbcon.commit() if deleted else None
            chain_env['results'] = {"conflicts": tuple(conflicts), "deleted": tuple(deleted)}
            chain_env['status']['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['logger']("webapi", chain_env['argument'].data)
        self.perf_time(chain_env, time.time() - time_bg)
        return result

    def _fn_update_quotation_history_order(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        status = {"code": None, "description": None}
        result = {}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            # [begin] SQL preparation.
            ACCEPT_FIELDS = ( \
                "project_id", "client_id", "dt_created","owner_company_id", "quotation_name", "quotation_no",\
                "quotation_date", "total_including_tax", "is_view_window", "is_view_excluding_tax", \
                "is_enabled", "is_send", "modifier_id",
                "pdffile_path", "office_memo",)
            args = chain_env['argument'].data
            if "scheme" in args and args['scheme'] == "":
                args['scheme'] = None
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]

            cols += ["output_val"]
            vals += [JSON.dumps(chain_env['argument'].data)]

            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] + \
                vals + \
                [args['quotation_id'], chain_env['prefix'], args['login_id']]
            # [end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_quotation_history_order") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                print err
                result = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                    status['code'] = 2
            else:
                chain_env['trace'].append(dbcur._executed)
                result = {}
                status['code'] = status['code'] or 0

            dbcon.commit() if status['code'] == 0 else dbcon.rollback()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_insert_quotation_history_invoice(self, chain_env):

        result = {}
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

            param = (chain_env['argument'].data["project_id"],
					chain_env['argument'].data["client_id"],
                     JSON.dumps(chain_env['argument'].data),
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['argument'].data["quotation_name"],
                     chain_env['argument'].data["quotation_no"],
                     chain_env['argument'].data["quotation_date"],
                     chain_env['argument'].data["total_including_tax"],
                     chain_env['argument'].data["is_view_window"],
                     chain_env['argument'].data["is_view_excluding_tax"],
                     chain_env['argument'].data["pdffile_path"],
                     chain_env['argument'].data["office_memo"],
                     )
            try:
                dbcur.execute(Model.sql("insert_quotation_history_invoice"), param)
            except Exception, err:
                chain_env['trace'].append(err)
                chain_env['status']['code'] = 2
                print err
            else:
                deleted.add(param[0])
                try:
                    dbcur.execute(Model.sql("last_insert_id"))
                except Exception, err:
                    chain_env['trace'].append(err)
                else:
                    result = Model.convert("last_insert_id", dbcur)
                    chain_env['argument'].data["id"] = result['id']
            dbcon.commit() if deleted else None
            chain_env['results'] = {"conflicts": tuple(conflicts), "deleted": tuple(deleted)}
            chain_env['status']['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['logger']("webapi", chain_env['argument'].data)
        self.perf_time(chain_env, time.time() - time_bg)
        return result

    def _fn_update_quotation_history_invoice(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        status = {"code": None, "description": None}
        result = {}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            # [begin] SQL preparation.
            ACCEPT_FIELDS = ( \
                "project_id", "client_id", "dt_created","owner_company_id", "quotation_name", "quotation_no",\
                "quotation_date", "total_including_tax", "is_view_window", "is_view_excluding_tax", "is_enabled", "is_send", "modifier_id",
                "pdffile_path", "office_memo",)
            args = chain_env['argument'].data
            if "scheme" in args and args['scheme'] == "":
                args['scheme'] = None
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]

            cols += ["output_val"]
            vals += [JSON.dumps(chain_env['argument'].data)]

            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] + \
                vals + \
                [args['quotation_id'], chain_env['prefix'], args['login_id']]
            # [end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_quotation_history_invoice") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                print err
                result = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                    status['code'] = 2
            else:
                chain_env['trace'].append(dbcur._executed)
                result = {}
                status['code'] = status['code'] or 0

            dbcon.commit() if status['code'] == 0 else dbcon.rollback()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result


    def _fn_update_quotation_history_invoice_send(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        status = {"code": None, "description": None}
        result = {}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            # [begin] SQL preparation.
            ACCEPT_FIELDS = ( \
                "project_id", "client_id", "dt_created","owner_company_id", "quotation_name", "quotation_no",\
                "quotation_date", "total_including_tax", "is_view_window", "is_view_excluding_tax", "is_enabled", "is_send", "modifier_id",
                "pdffile_path", "office_memo",)
            args = chain_env['argument'].data
            if "scheme" in args and args['scheme'] == "":
                args['scheme'] = None
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]

            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] + \
                vals + \
                [args['quotation_id'], chain_env['prefix'], args['login_id']]
            # [end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_quotation_history_invoice") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                print err
                result = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                    status['code'] = 2
            else:
                chain_env['trace'].append(dbcur._executed)
                result = {}
                status['code'] = status['code'] or 0

            dbcon.commit() if status['code'] == 0 else dbcon.rollback()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_insert_quotation_history_purchase(self, chain_env):

        result = {}
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

            param = (chain_env['argument'].data["project_id"],
                     JSON.dumps(chain_env['argument'].data),
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['prefix'], chain_env['login_id'], chain_env['credential'],
                     chain_env['argument'].data["quotation_name"],
                     chain_env['argument'].data["quotation_no"],
                     chain_env['argument'].data["quotation_date"],
                     chain_env['argument'].data["total_including_tax"],
                     chain_env['argument'].data["is_view_window"],
                     chain_env['argument'].data["is_view_excluding_tax"],
                     chain_env['argument'].data["client_id"] if "client_id" in chain_env['argument'].data.keys() else 0,
                     chain_env['argument'].data["pdffile_path"],
                     chain_env['argument'].data["company_id"],
                     chain_env['argument'].data["office_memo"],
                     chain_env['argument'].data["addr_vip"],
                     chain_env['argument'].data["addr1"],
                     chain_env['argument'].data["addr2"],
                     chain_env['argument'].data["addr_name"],
                     chain_env['argument'].data["type_honorific"],
                     chain_env['argument'].data["engineer_id"] if "engineer_id" in chain_env['argument'].data.keys() else 0
                     )
            try:
                dbcur.execute(Model.sql("insert_quotation_history_purchase"), param)

            except Exception, err:
                chain_env['trace'].append(err)
                chain_env['status']['code'] = 2
                print err
            else:
                deleted.add(param[0])
                try:
                    dbcur.execute(Model.sql("last_insert_id"))
                except Exception, err:
                    chain_env['trace'].append(err)
                else:
                    result = Model.convert("last_insert_id", dbcur)
                    chain_env['argument'].data["id"] = result['id']
            dbcon.commit() if deleted else None
            chain_env['results'] = {"conflicts": tuple(conflicts), "deleted": tuple(deleted)}
            chain_env['status']['code'] = 0
            dbcur.close()
            dbcon.close()
        chain_env['logger']("webapi", chain_env['argument'].data)
        self.perf_time(chain_env, time.time() - time_bg)
        return result

    def _fn_update_quotation_history_purchase(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        status = {"code": None, "description": None}
        result = {}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            # [begin] SQL preparation.
            ACCEPT_FIELDS = ( \
                "project_id", "dt_created","owner_company_id", "quotation_name", "quotation_no",\
                "quotation_date", "total_including_tax", "is_view_window", "is_view_excluding_tax",\
                "is_enabled", "is_send", "modifier_id",\
                "client_id","pdffile_path","company_id","office_memo", \
                "addr_vip", "addr1", "addr2","addr_name","type_honorific", "engineer_id")
            args = chain_env['argument'].data
            if "scheme" in args and args['scheme'] == "":
                args['scheme'] = None
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]

            cols += ["output_val"]
            vals += [JSON.dumps(chain_env['argument'].data)]

            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] + \
                vals + \
                [args['quotation_id'], chain_env['prefix'], args['login_id']]
            # [end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_quotation_history_purchase") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                print err
                result = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                    status['code'] = 2
            else:
                chain_env['trace'].append(dbcur._executed)
                result = {}
                status['code'] = status['code'] or 0

            dbcon.commit() if status['code'] == 0 else dbcon.rollback()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result

    def _fn_update_quotation_history_purchase_send(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webapi", ("BEGIN", chain_env['argument'].data))
        status = {"code": None, "description": None}
        result = {}
        if not chain_env['propagate']:
            return
        dbcur = None
        dbcon, db_err_list = self.connect_db()
        if dbcon and not db_err_list:
            dbcur = dbcon.cursor()
        else:
            chain_env['trace'] += db_err_list
        if dbcur:
            # [begin] SQL preparation.
            ACCEPT_FIELDS = ( \
                "project_id", "dt_created","owner_company_id", "quotation_name", "quotation_no",\
                "quotation_date", "total_including_tax", "is_view_window", "is_view_excluding_tax",\
                "is_enabled", "is_send", "modifier_id",\
                "client_id","pdffile_path","company_id","office_memo", \
                "addr_vip", "addr1", "addr2","addr_name","type_honorific", "engineer_id")
            args = chain_env['argument'].data
            if "scheme" in args and args['scheme'] == "":
                args['scheme'] = None
            cols = filter(lambda x: x in ACCEPT_FIELDS, args.keys())
            vals = [args[k] for k in cols]

            cvt = \
                [chain_env['prefix'], args['login_id'], args['credential']] + \
                vals + \
                [args['quotation_id'], chain_env['prefix'], args['login_id']]
            # [end] SQL preparation.
            try:
                dbcur.execute(Model.sql("update_quotation_history_purchase") % ", ".join(["`%s`=%%s" % col for col in cols]), cvt)
            except Exception, err:
                chain_env['trace'].append(traceback.format_exc())
                chain_env['trace'].append(dbcur._executed)
                chain_env['propagate'] = False
                print err
                result = {"id": None}
                if err.errno == 1048 and err.sqlstate == "23000":
                    status['code'] = 2
                else:
                    chain_env['trace'].append(traceback.format_exc(err))
                    status['code'] = 2
            else:
                chain_env['trace'].append(dbcur._executed)
                result = {}
                status['code'] = status['code'] or 0

            dbcon.commit() if status['code'] == 0 else dbcon.rollback()
            dbcur.close()
            dbcon.close()
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", chain_env['results'], chain_env['status']))
        self.perf_time(chain_env, time.time() - time_bg)
        return status, result


    def _fn_download_pdf_estimate(self, chain_env):
        from logics.estimate import Processor as P_ESTIMATE
        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')
        time_bg = time.time()
        result = {}
        status = {"code": None, "description": None}
        render_param = {}

        status_estimate, operation_info = P_ESTIMATE(self.__pref__)._fn_enum_estimates_pdfinfo(chain_env)

        # if render_param['operation_info']
        #     status['code'] = 2
        #     self.perf_time(chain_env, time.time() - time_bg)
        #     chain_env['results'] = result
        #     chain_env['status'] = status
        #     chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        #     return status, result
        quotation_no = operation_info[0]['quotation_no']
        quotation_name = operation_info[0]["quotation_name"];
        client_name = operation_info[0]["client_name"];

        f = open('download/' + chain_env['query'], 'r')
        pdf_buf = f.read()

        pdf_title = "?????????_" + quotation_no + "_" + client_name + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }

        status['code'] = 0
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_pdf_order(self, chain_env):
        from logics.order import Processor as P_ORDER
        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')
        time_bg = time.time()
        result = {}
        status = {"code": None, "description": None}
        render_param = {}

        status_estimate, operation_info = P_ORDER(self.__pref__)._fn_enum_orders_pdfinfo(chain_env)

        # if render_param['operation_info']
        #     status['code'] = 2
        #     self.perf_time(chain_env, time.time() - time_bg)
        #     chain_env['results'] = result
        #     chain_env['status'] = status
        #     chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        #     return status, result
        quotation_no = operation_info[0]['quotation_no']
        quotation_name = operation_info[0]["quotation_name"];
        client_name = operation_info[0]["client_name"];

        f = open('download/' + chain_env['query'], 'r')
        pdf_buf = f.read()

        pdf_title = "?????????_" + quotation_no + "_" + client_name + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis") , \
            }

        status['code'] = 0
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_pdf_invoice(self, chain_env):
        from logics.invoice import Processor as P_INVOICE
        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')
        time_bg = time.time()
        result = {}
        status = {"code": None, "description": None}
        render_param = {}

        status_estimate, operation_info = P_INVOICE(self.__pref__)._fn_enum_invoices_pdfinfo(chain_env)

        # if render_param['operation_info']
        #     status['code'] = 2
        #     self.perf_time(chain_env, time.time() - time_bg)
        #     chain_env['results'] = result
        #     chain_env['status'] = status
        #     chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        #     return status, result
        quotation_no = operation_info[0]['quotation_no']
        quotation_name = operation_info[0]["quotation_name"];
        client_name = operation_info[0]["client_name"];

        f = open('download/' + chain_env['query'], 'r')
        pdf_buf = f.read()

        pdf_title = "?????????_" + quotation_no + "_" + client_name + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis") , \
            }

        status['code'] = 0
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_pdf_purchase(self, chain_env):
        from logics.purchase import Processor as P_PURCHASE
        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')
        time_bg = time.time()
        time_bg = time.time()
        result = {}
        status = {"code": None, "description": None}
        render_param = {}

        status_estimate, operation_info = P_PURCHASE(self.__pref__)._fn_enum_purchases_pdfinfo(chain_env)

        # if render_param['operation_info']
        #     status['code'] = 2
        #     self.perf_time(chain_env, time.time() - time_bg)
        #     chain_env['results'] = result
        #     chain_env['status'] = status
        #     chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        #     return status, result
        quotation_no = operation_info[0]['quotation_no']
        quotation_name = operation_info[0]["quotation_name"]
        client_name = operation_info[0]['addr_name']
        # if operation_info[0]["engineer_company_name"]:
        #     client_name = operation_info[0]["engineer_company_name"]
        # else:
        #     client_name = operation_info[0]["client_name"]

        f = open('download/' + chain_env['query'], 'r')
        pdf_buf = f.read()

        pdf_title = "?????????_" + quotation_no + "_" + client_name + "???.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis") , \
            }

        status['code'] = 0
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_setting_print_rows(self, print_rows, output):
        rows = output["rows"]
        for row in rows:
            print_row = {
                "summary": row["summary"] if row["summary"] else "",
                "quantity": row["quantity"] if row["quantity"] else "",
                "unit": row["unit"] if row["unit"] else "",
                "settlement_exp": row["settlement_exp"] if row["settlement_exp"] else "",
                "price": row["price"] if row["price"] else "",
                "isIncludingTax": row["isIncludingTax"] if row["isIncludingTax"] else "",
                "subtotal": row["subtotal"] if row["subtotal"] else "",
                "tax": row["tax"] if row["tax"] else "",
            }
            print_rows.append(print_row)
            if("summary_1" in row):
                if(row["summary_1"] != ""):
                    print_row = {
                        "summary": "????????????(" + row["summary_1"] + "h)" if row["summary_1"] else "",
                        "quantity": row["quantity_1"] if row["quantity_1"] else "",
                        "unit": row["unit_1"] if row["unit_1"] else "",
                        "price": row["price_1"] if row["price_1"] else "",
                        "isIncludingTax": row["isIncludingTax_1"] if row["isIncludingTax_1"] else "",
                        "subtotal": row["subtotal_1"] if row["subtotal_1"] else "",
                        "tax": row["tax_1"] if row["tax_1"] else "",
                    }
                    print_rows.append(print_row)
            if ("summary_2" in row):
                if (row["summary_2"] != ""):
                    print_row = {
                        "summary": "????????????(" + row["summary_2"] + "h)" if row["summary_2"] else "",
                        "quantity": row["quantity_2"] if row["quantity_2"] else "",
                        "unit": row["unit_2"] if row["unit_2"] else "",
                        "price": row["price_2"] if row["price_2"] else "",
                        "isIncludingTax": row["isIncludingTax_2"] if row["isIncludingTax_2"] else "",
                        "subtotal": row["subtotal_2"] if row["subtotal_2"] else "",
                        "tax": row["tax_2"] if row["tax_2"] else "",
                    }
                    print_rows.append(print_row)

        free_rows = output["free_rows"]
        for row in free_rows:
            print_row = {
                "summary": row["summary"] if row["summary"] else "",
                "quantity": row["quantity"] if row["quantity"] else "",
                "unit": row["unit"] if row["unit"] else "",
                # "settlement_exp": row["settlement_exp"] if row["settlement_exp"] else "",
                "price": row["price"] if row["price"] else "",
                "isIncludingTax": row["isIncludingTax"] if row["isIncludingTax"] else "",
                "subtotal": row["subtotal"] if row["subtotal"] else "",
                "tax": row["tax"] if row["tax"] else "",
            }
            print_rows.append(print_row)

    def _fn_setting_download_cookie(self, chain_env):
        max_age = 60 * 60 * 24 * 120  # 120 days
        chain_env['headers']['Set-Cookie'] = werkzeug.dump_cookie( \
            "downloaded", \
            value="yes", \
            max_age=max_age, \
            expires=datetime.datetime.now(), \
            path="/")

    def _fn_download_pdf_project(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        status_project, render_param['operation.enumProjects'] = self.P_PROJECT(self.__pref__)._fn_enum_projects(
            chain_env)
        render_param['operation.enumProjects'] = [tmp_data for tmp_data in render_param['operation.enumProjects'] if tmp_data['id'] in chain_env['argument'].data['id_list']]

        result = {}
        status = {"code": None, "description": None}

        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')

        body = flask.render_template("pdf_project.tpl", data=render_param, env=chain_env['argument'].data)

        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_OUTPUT_OPTION)
        pdf_title = "?????? ??????.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }
        status['code'] = 0
        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_pdf_engineer(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        status_project, render_param['operation.enumEngineers'] = self.P_ENGINEER(self.__pref__)._fn_enum_engineers(
            chain_env)
        render_param['operation.enumEngineers'] = [tmp_data for tmp_data in render_param['operation.enumEngineers'] if tmp_data['id'] in chain_env['argument'].data['id_list']]

        result = {}
        status = {"code": None, "description": None}

        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')

        body = flask.render_template("pdf_engineer.tpl", data=render_param, env=chain_env['argument'].data)

        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_OUTPUT_OPTION)
        pdf_title = "?????? ??????.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }
        status['code'] = 0
        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_pdf_matching_project(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        status_profile, render_param['auth.userProfile'] = self.P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_project, render_param['operation.enumProjects'] = self.P_PROJECT(self.__pref__)._fn_search_projects(
            chain_env)
        render_param['operation.enumProjects'] = [tmp_data for tmp_data in render_param['operation.enumProjects'] if tmp_data['id'] in chain_env['argument'].data['id_list']]
        if("engineer_id" in chain_env['argument'].data):
            status_projects, render_param['engineer.enumEngineers'] = self.P_ENGINEER(self.__pref__)._fn_enum_engineers(chain_env)

        result = {}
        status = {"code": None, "description": None}

        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')

        body = flask.render_template("pdf_matching_project.tpl", data=render_param, env=chain_env['argument'].data)

        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_OUTPUT_OPTION)
        pdf_title = "????????????????????? ??????.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }
        status['code'] = 0
        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result

    def _fn_download_pdf_matching_engineer(self, chain_env):
        time_bg = time.time()
        chain_env['logger']("webhtml", ("BEGIN", chain_env['argument'].data))
        if not chain_env['propagate']:
            return
        render_param = {}
        status_profile, render_param['auth.userProfile'] = self.P_AUTH(self.__pref__).read_user_profile(chain_env)
        status_project, render_param['operation.enumEngineers'] = self.P_ENGINEER(self.__pref__)._fn_search_engineers(
            chain_env)
        render_param['operation.enumEngineers'] = [tmp_data for tmp_data in render_param['operation.enumEngineers'] if tmp_data['id'] in chain_env['argument'].data['id_list']]
        if ("project_id" in chain_env['argument'].data):
            status_projects, render_param['project.enumProjects'] = self.P_PROJECT(self.__pref__)._fn_enum_projects(
                chain_env)

        result = {}
        status = {"code": None, "description": None}

        import sys
        reload(sys)
        sys.setdefaultencoding('utf-8')

        body = flask.render_template("pdf_matching_engineer.tpl", data=render_param, env=chain_env['argument'].data)

        config = pdfkit.configuration(wkhtmltopdf="/usr/local/bin/wkhtmltopdf")
        pdf_buf = pdfkit.from_string(body, False, configuration=config, options=PDF_OUTPUT_OPTION)
        pdf_title = "????????????????????? ??????.pdf"

        chain_env['sendfile_content'] = SIO.StringIO(pdf_buf)
        chain_env['sendfile_params'] = { \
            "mimetype": 'application/pdf', \
            "as_attachment": True, \
            "attachment_filename": pdf_title.encode("shift-jis"), \
            }
        status['code'] = 0
        self._fn_setting_download_cookie(chain_env)
        self.perf_time(chain_env, time.time() - time_bg)
        chain_env['results'] = result
        chain_env['status'] = status
        chain_env['logger']("webapi", ("END", "[OMMITTED](Too long)", chain_env['status']))
        return status, result