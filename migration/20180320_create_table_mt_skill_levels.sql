CREATE TABLE mt_skill_levels (
  id mediumint(5) unsigned auto_increment NOT NULL,
  level mediumint(5),
  name varchar(64),
  PRIMARY KEY (id)
);

INSERT INTO mt_skill_levels (level, name) VALUES (1,'未経験');
INSERT INTO mt_skill_levels (level, name) VALUES (2,'未経験(研修のみ)');
INSERT INTO mt_skill_levels (level, name) VALUES (3,'～3ヶ月');
INSERT INTO mt_skill_levels (level, name) VALUES (4,'3～6ヶ月');
INSERT INTO mt_skill_levels (level, name) VALUES (5,'6ヶ月～1年');
INSERT INTO mt_skill_levels (level, name) VALUES (6,'1年～2年');
INSERT INTO mt_skill_levels (level, name) VALUES (7,'2年～3年');
INSERT INTO mt_skill_levels (level, name) VALUES (8,'3年～5年');
INSERT INTO mt_skill_levels (level, name) VALUES (9,'5年～10年');
INSERT INTO mt_skill_levels (level, name) VALUES (10,'10年以上');


ALTER TABLE cr_engineer_skill ADD level mediumint(5) default 0;
ALTER TABLE cr_prj_skill_needs ADD level mediumint(5) default 0;
