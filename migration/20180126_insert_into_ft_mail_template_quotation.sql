alter table ft_mail_templates modify type_recipient
enum ('取引先担当者（既定）','取引先担当者','技術者（既定）','技術者','リマインダー','マッチング','見積書','請求先注文書','注文書','請求書') not null;

insert into ft_mail_templates
(
`name`,
`subject`,
`body`,
`type_recipient`,
`type_iterator`,
`creator_id`,
`modifier_id`
)
select
"注文書送付",
"【ご連絡】",
"[宛名]


お世話になっております。[会社名][営業担当者名]です。

[案件情報]

につきまして
ご注文書を作成しましたのでお送りいたします。
以下のURLよりダウンロードいただくようお願いいたします。
[PDFダウンロードURL]

恐れ入りますが、何卒、よろしくお願いいたします。


[署名]                                              ",
"注文書",
"案件情報",
`id`,
`id`
from mt_user_persons where is_admin = 1
;



insert into ft_mail_templates
(
`name`,
`subject`,
`body`,
`type_recipient`,
`type_iterator`,
`creator_id`,
`modifier_id`
)
select
"仕入用注文書送付",
"【ご連絡】",
"[宛名]


お世話になっております。[会社名][営業担当者名]です。

[案件情報]

につきまして
ご注文書を作成しましたのでお送りいたします。
以下のURLよりダウンロードいただくようお願いいたします。
[PDFダウンロードURL]

恐れ入りますが、何卒、よろしくお願いいたします。


[署名]                                              ",
"仕入用注文書",
"案件情報",
`id`,
`id`
from mt_user_persons where is_admin = 1
;



insert into ft_mail_templates
(
`name`,
`subject`,
`body`,
`type_recipient`,
`type_iterator`,
`creator_id`,
`modifier_id`
)
select
"請求書送付",
"【ご連絡】",
"[宛名]


お世話になっております。[会社名][営業担当者名]です。

[案件情報]

につきまして
ご請求書を作成しましたのでお送りいたします。
以下のURLよりダウンロードいただくようお願いいたします。
[PDFダウンロードURL]

恐れ入りますが、何卒、よろしくお願いいたします。


[署名]                                              ",
"請求書",
"案件情報",
`id`,
`id`
from mt_user_persons where is_admin = 1
;