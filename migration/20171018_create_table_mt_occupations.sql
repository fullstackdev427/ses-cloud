CREATE TABLE mt_occupations (
  id mediumint(5) unsigned auto_increment NOT NULL,
  name varchar(64),
  PRIMARY KEY (id)
);

INSERT INTO mt_occupations (name) VALUES ('コンサルタント');
INSERT INTO mt_occupations (name) VALUES ('営業');
INSERT INTO mt_occupations (name) VALUES ('プロジェクトマネージャ');
INSERT INTO mt_occupations (name) VALUES ('システムエンジニア');
INSERT INTO mt_occupations (name) VALUES ('インフラエンジニア');
INSERT INTO mt_occupations (name) VALUES ('プログラマー');

CREATE TABLE cr_prj_ocp_needs (
  project_id bigint(14) unsigned,
  occupation_id mediumint(5) unsigned,
  PRIMARY KEY (project_id, occupation_id)
);

CREATE TABLE cr_engineer_ocp (
  engineer_id mediumint(10) unsigned ,
  occupation_id mediumint(5) unsigned,
  PRIMARY KEY (engineer_id, occupation_id)
);