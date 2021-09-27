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
"見積書送付",
"【ご連絡】",
"[宛名]


お世話になっております。[会社名][営業担当者名]です。

[案件情報]

につきまして
お見積書を作成しましたのでお送りいたします。
以下のURLよりダウンロードいただくようお願いいたします。
[PDFダウンロードURL]

恐れ入りますが、何卒、よろしくお願いいたします。


[署名]                                              ",
"見積書",
"案件情報",
`id`,
`id`
from mt_user_persons where is_admin = 1
;