ALTER TABLE ft_operations ADD demand_wage_per_hour decimal(10,0) default 0;
ALTER TABLE ft_operations ADD demand_working_time mediumint(10) unsigned ;

ALTER TABLE ft_operations ADD payment_wage_per_hour decimal(10,0) default 0;
ALTER TABLE ft_operations ADD payment_working_time mediumint(10) unsigned;

