CREATE TABLE mt_skill_categories (
  id mediumint(5) unsigned auto_increment NOT NULL,
  name varchar(64),
  PRIMARY KEY (id)
);

ALTER TABLE mt_skills ADD category_id mediumint(5) unsigned;