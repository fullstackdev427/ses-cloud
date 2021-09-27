alter table ft_mail_templates modify type_recipient enum ('取引先担当者（既定）','取引先担当者','技術者（既定）','技術者','リマインダー','マッチング','見積書','請求先注文書','仕入用注文書', '注文書','請求書') not null;

update ft_mail_templates set type_recipient = "請求先注文書" where type_recipient = "注文書";
update ft_mail_templates set type_recipient = "注文書" where type_recipient = "仕入用注文書";

alter table ft_mail_templates modify type_recipient enum ('取引先担当者（既定）','取引先担当者','技術者（既定）','技術者','リマインダー','マッチング','見積書','請求先注文書', '注文書','請求書') not null;


update ft_mail_templates set name = "注文書" where type_recipient = "注文書";
update ft_mail_templates set name = "請求先注文書" where type_recipient = "請求先注文書";