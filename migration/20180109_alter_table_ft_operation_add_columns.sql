ALTER TABLE ft_operations CHANGE base base_exc_tax decimal(10,0) default 0;
ALTER TABLE ft_operations ADD base_inc_tax decimal(10,0) default 0;

ALTER TABLE ft_operations ADD transfer_member varchar(64);