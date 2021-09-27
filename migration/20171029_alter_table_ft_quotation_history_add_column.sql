ALTER TABLE ft_quotation_history_estimate ADD owner_company_id mediumint(5) unsigned;
ALTER TABLE ft_quotation_history_estimate ADD quotation_name varchar(64) ;
ALTER TABLE ft_quotation_history_estimate ADD quotation_no varchar(64) ;
ALTER TABLE ft_quotation_history_estimate ADD quotation_date date;

ALTER TABLE ft_quotation_history_order ADD owner_company_id mediumint(5) unsigned;
ALTER TABLE ft_quotation_history_order ADD quotation_name varchar(64) ;
ALTER TABLE ft_quotation_history_order ADD quotation_no varchar(64) ;
ALTER TABLE ft_quotation_history_order ADD quotation_date date;

ALTER TABLE ft_quotation_history_invoice ADD owner_company_id mediumint(5) unsigned;
ALTER TABLE ft_quotation_history_invoice ADD quotation_name varchar(64) ;
ALTER TABLE ft_quotation_history_invoice ADD quotation_no varchar(64) ;
ALTER TABLE ft_quotation_history_invoice ADD quotation_date date;