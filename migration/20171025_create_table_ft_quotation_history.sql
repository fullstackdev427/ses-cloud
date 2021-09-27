CREATE TABLE ft_quotation_history_estimate (
  id bigint(14) unsigned auto_increment,
  project_id mediumint(5) unsigned,
  output_val LONGTEXT,
  creator_id mediumint(10) unsigned,
  dt_created timestamp default CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE ft_quotation_history_order (
  id bigint(14) unsigned auto_increment,
  project_id mediumint(5) unsigned,
  output_val LONGTEXT,
  creator_id mediumint(10) unsigned,
  dt_created timestamp default CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

CREATE TABLE ft_quotation_history_invoice (
  id bigint(14) unsigned auto_increment,
  client_id mediumint(10) unsigned,
  output_val LONGTEXT,
  creator_id mediumint(10) unsigned,
  dt_created timestamp default CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

ALTER TABLE ft_quotation_history_estimate ADD INDEX idx_project_id(project_id);
ALTER TABLE ft_quotation_history_order ADD INDEX idx_project_id(project_id);
ALTER TABLE ft_quotation_history_invoice ADD INDEX idx_client_id(client_id);
