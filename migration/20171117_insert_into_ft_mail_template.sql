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
"案件マッチング",
"【ご連絡】",
"[宛名]


お世話になっております。[会社名][営業担当者名]です。


御社案件へ要員をご提案させて頂きます。
是非、ご面談機会を頂きたいと存じます。


【御社案件】
[案件情報]


[技術者情報]


恐れ入りますが、何卒、よろしくお願いいたします。


[署名]                                              ",
"マッチング",
"技術者情報,案件情報",
`id`,
`id`
from mt_user_persons where is_admin = 1
;

