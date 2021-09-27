ALTER TABLE ft_quotation_history_estimate ADD is_enabled tinyint(1) unsigned default 1;
ALTER TABLE ft_quotation_history_order ADD is_enabled tinyint(1) unsigned default 1;
ALTER TABLE ft_quotation_history_invoice ADD is_enabled tinyint(1) unsigned default 1;


ALTER TABLE ft_quotation_history_estimate ADD total_including_tax decimal(10,0) default 0;
ALTER TABLE ft_quotation_history_order ADD total_including_tax decimal(10,0) default 0;
ALTER TABLE ft_quotation_history_invoice ADD total_including_tax decimal(10,0) default 0;

ALTER TABLE ft_quotation_history_estimate ADD is_send tinyint(1) unsigned default 0;
ALTER TABLE ft_quotation_history_order ADD is_send tinyint(1) unsigned default 0;
ALTER TABLE ft_quotation_history_invoice ADD is_send tinyint(1) unsigned default 0;


ALTER TABLE ft_quotation_history_estimate ADD modifier_id mediumint(10) unsigned;
ALTER TABLE ft_quotation_history_order ADD modifier_id mediumint(10) unsigned;
ALTER TABLE ft_quotation_history_invoice ADD modifier_id mediumint(10) unsigned;

ALTER TABLE ft_quotation_history_estimate ADD is_view_window tinyint(1) unsigned default 0;
ALTER TABLE ft_quotation_history_order ADD is_view_window tinyint(1) unsigned default 0;
ALTER TABLE ft_quotation_history_invoice ADD is_view_window tinyint(1) unsigned default 0;