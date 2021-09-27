ALTER TABLE ft_quotation_history_estimate ADD is_view_excluding_tax tinyint(1) unsigned default 0;
ALTER TABLE ft_quotation_history_order ADD is_view_excluding_tax tinyint(1) unsigned default 0;
ALTER TABLE ft_quotation_history_invoice ADD is_view_excluding_tax tinyint(1) unsigned default 0;
ALTER TABLE ft_quotation_history_purchase ADD is_view_excluding_tax tinyint(1) unsigned default 0;