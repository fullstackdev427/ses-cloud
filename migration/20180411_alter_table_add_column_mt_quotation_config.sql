ALTER TABLE mt_quotation_config ADD bank_account1 varchar(64);
ALTER TABLE mt_quotation_config ADD bank_account2 varchar(64);

ALTER TABLE mt_quotation_config ADD estimate_charging_user_id mediumint(10) unsigned;
ALTER TABLE mt_quotation_config ADD order_charging_user_id mediumint(10) unsigned;
ALTER TABLE mt_quotation_config ADD invoice_charging_user_id mediumint(10) unsigned;
ALTER TABLE mt_quotation_config ADD purchase_charging_user_id mediumint(10) unsigned;
