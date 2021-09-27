ALTER TABLE ft_operations ADD term_begin date;
ALTER TABLE ft_operations ADD term_end date;

ALTER TABLE ft_operations ADD settlement_exp mediumint(10) unsigned;

ALTER TABLE ft_operations ADD settlement_unit tinyint(1) unsigned default 1;
ALTER TABLE ft_operations ADD demand_unit tinyint(1) unsigned default 1;
ALTER TABLE ft_operations ADD payment_unit tinyint(1) unsigned default 1;

ALTER TABLE ft_operations ADD bonuses_division decimal(10,0) default 0;

ALTER TABLE ft_operations ADD payment_base decimal(10,0) default 0;
ALTER TABLE ft_operations ADD payment_excess decimal(10,0) default 0;
ALTER TABLE ft_operations ADD payment_deduction decimal(10,0) default 0;

ALTER TABLE ft_operations ADD payment_exp mediumint(10) unsigned;

ALTER TABLE ft_operations ADD payment_settlement_unit tinyint(1) unsigned default 1;
