
ALTER TABLE mt_engineers ADD addr_vip varchar(7);
ALTER TABLE mt_engineers ADD addr1 varchar(64);
ALTER TABLE mt_engineers ADD addr2 varchar(64);

ALTER TABLE ft_quotation_history_purchase ADD addr_vip varchar(7);
ALTER TABLE ft_quotation_history_purchase ADD addr1 varchar(64);
ALTER TABLE ft_quotation_history_purchase ADD addr2 varchar(64);
ALTER TABLE ft_quotation_history_purchase ADD addr_name varchar(64);
ALTER TABLE ft_quotation_history_purchase ADD type_honorific enum('御中','様');
ALTER TABLE ft_quotation_history_purchase ADD engineer_id mediumint(10) unsigned;
