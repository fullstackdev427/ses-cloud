CREATE TABLE ft_quotation_history_purchase (
  id bigint(14) unsigned auto_increment,
  project_id mediumint(5) unsigned,
  output_val LONGTEXT,
  creator_id mediumint(10) unsigned,
  dt_created timestamp default CURRENT_TIMESTAMP,
  owner_company_id mediumint(5) unsigned,
  quotation_name varchar(64),
  quotation_no varchar(64),
  quotation_date date,
  is_enabled tinyint(1) unsigned default 1,
  total_including_tax decimal(10,0) default 0,
  is_send tinyint(1) unsigned default 0,
  modifier_id mediumint(10) unsigned,
  is_view_window tinyint(1) unsigned default 0,
  client_id mediumint(5) unsigned,
  PRIMARY KEY (id)
);

ALTER TABLE ft_quotation_history_purchase ADD INDEX idx_purchase_client_id(client_id);
