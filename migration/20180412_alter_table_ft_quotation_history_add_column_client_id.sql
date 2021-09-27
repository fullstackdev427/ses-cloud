-- ALTER TABLE ADD COLUMN
ALTER TABLE ft_quotation_history_invoice ADD COLUMN client_id mediumint(10) unsigned AFTER project_id;
ALTER TABLE ft_quotation_history_estimate ADD COLUMN client_id mediumint(10) unsigned AFTER project_id;
ALTER TABLE ft_quotation_history_order ADD COLUMN client_id mediumint(10) unsigned AFTER project_id;

-- データ移行
UPDATE ft_quotation_history_invoice ft SET ft.client_id = (SELECT mt.client_id FROM mt_projects mt WHERE mt.id = ft.project_id);
UPDATE ft_quotation_history_estimate ft SET ft.client_id = (SELECT mt.client_id FROM mt_projects mt WHERE mt.id = ft.project_id);
UPDATE ft_quotation_history_order ft SET ft.client_id = (SELECT mt.client_id FROM mt_projects mt WHERE mt.id = ft.project_id);
