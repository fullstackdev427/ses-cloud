truncate table mt_skill_categories;
insert into mt_skill_categories (id, name) values (1,"言語");
insert into mt_skill_categories (id, name) values (2,"DB");
insert into mt_skill_categories (id, name) values (3,"OS　サーバー 等");
insert into mt_skill_categories (id, name) values (4,"ツール");
insert into mt_skill_categories (id, name) values (5,"フレームワーク");

ALTER TABLE cr_engineer_skill DROP FOREIGN KEY `cr_engineer_skill_ibfk_2`;
ALTER TABLE cr_prj_skill_needs DROP FOREIGN KEY `cr_prj_skill_needs_ibfk_2`;
ALTER TABLE cr_prj_skill_recommends DROP FOREIGN KEY `cr_prj_skill_recommends_ibfk_2`;

alter table mt_skills modify name varchar(64);

truncate table mt_skills;
insert into mt_skills (name, owner_company_id, category_id) values ("Java", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("PHP", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("C#.net", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("VB.net", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("ASP.NET", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("VBA", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("VB", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("GO", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Python", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Android", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Ruby", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Perl", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("HTML", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("JQuery", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Objective-C", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("C言語", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("C++", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("VC++", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Pro*C", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("CSS", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("PL/SQL", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("SQL", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("ASP", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("ABAP", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Delphi", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Bash", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("JCL", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Javascript(jQuery)", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("vbscript", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Salesforce", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("COBOL", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("PL/1", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Shell", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Swift", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("AJAX", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("XML", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("XHTML", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("wordpress", 0, 1);
insert into mt_skills (name, owner_company_id, category_id) values ("Transact SQL", 0, 1);

insert into mt_skills (name, owner_company_id, category_id) values ("Oracle", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("MySQL", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("PostgreSQL", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("SQLserver", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("MongoDB", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("DB2", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("HiRDB", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("SQLite", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("Access", 0, 2);
insert into mt_skills (name, owner_company_id, category_id) values ("Sybase", 0, 2);

insert into mt_skills (name, owner_company_id, category_id) values ("AIX", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("LINUX(Red hat)", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("HP-UX", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("Windows Server", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("CentOS", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("iOS", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("Active Directory", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("OpenLdap", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("Xen", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("Exchange Server", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("postfix", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("sendmail", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("Apache", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("nginx", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("IIS（Internet Information Services)", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("Tomcat", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("Weblogic", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("WebSphere", 0, 3);
insert into mt_skills (name, owner_company_id, category_id) values ("JBoss", 0, 3);

insert into mt_skills (name, owner_company_id, category_id) values ("Git", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("GitHub", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("SVN", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("CVS", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("JIRA", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("Redmine", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("Trac", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("SVF", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("ireport", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("Crystal Reports", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("ActiveReports", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("VMware", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("Visual Studio", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("Xcode", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("Subversion", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("SWIG", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("Bazaar", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("JP1", 0, 4);
insert into mt_skills (name, owner_company_id, category_id) values ("千手", 0, 4);

insert into mt_skills (name, owner_company_id, category_id) values ("Laravel", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("CakePHP", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("CodeIgniter", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("FuelPHP", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Phalcon", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Symphony", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("ZendFramework", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Ethna", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Struts", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Struts2", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("SAStruts", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Hibernate", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Spring", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("TERASOLUNA", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Play Framework", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Intramat", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Seasar2", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values (".net framework	", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("junit", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("javaEE", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("JSF", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Wicket", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Ruby on Rails", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Catalyst", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Ark", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Mojolicios", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Vue.js", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Backbone.js", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("AngularJS", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Knockout.js", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Ember.js", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("CherryPY", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Flask", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Django", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Pyramid", 0, 5);
insert into mt_skills (name, owner_company_id, category_id) values ("Tornado", 0, 5);

alter table cr_engineer_skill add constraint cr_engineer_skill_ibfk_2 foreign key (skill_id) references mt_skills(id) on update cascade;
alter table cr_prj_skill_needs add constraint cr_prj_skill_needs_ibfk_2 foreign key (skill_id) references mt_skills(id) on update cascade;
alter table cr_prj_skill_recommends add constraint cr_prj_skill_recommends_ibfk_2 foreign key (skill_id) references mt_skills(id) on update cascade;
