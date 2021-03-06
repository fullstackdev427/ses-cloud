#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

ENV = {}

#[begin] Constants for 'develop' env.
ENV['develop'] = {}
ENV['develop']['DOMAIN'] = "http://c4s-pool.local"
ENV['develop']['MYSQL_MODULO'] = 1
ENV['develop']['MYSQL_HOSTS'] = (\
	{\
		"host": "localhost",\
		"port": 3306L,\
		"user": "c4s_devel",\
		"passwd": "interplug@20140501",\
		"db": "c4s_devel",\
		"charset": "utf8",\
		"use_unicode": True,\
		"compress": True
	},\
)
#Cache for preference per user company.
ENV['develop']['REDIS_PREF_TTL'] = 2 * 60 * 60# 2 hours.
ENV['develop']['REDIS_PREF'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 1,\
	"socket_timeout": 1
}
#Authentication cache.
ENV['develop']['REDIS_AUTH_TTL'] = 24 * 60 * 60# 8 hours.
ENV['develop']['REDIS_AUTH'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 2,\
	"socket_timeout": 1
}
#Cache for chunked data of pagenation.
ENV['develop']['REDIS_'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 3,\
	"socket_timeout": 1
}
#Misc.
ENV['develop']['REDIS_'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 4,\
	"socket_timeout": 1
}
ENV['develop']['AMQP_CRED'] = {"user": "c4s_devel", "passwd": "c4s_devel"}
ENV['develop']['AMQP_EXCHANGES'] = {\
	
}
ENV['develop']['AMQP_QUEUES'] = {\
	
}
ENV['develop']['AMQP_HOST'] = {\
	"host": "localhost",\
	"port": 5672,\
	"virtual_host": "/",\
	"channel_max": None,\
	"frame_max": None,\
	"heartbeat_interval": 5,\
	"ssl": False,\
	"ssl_options": None,\
	"connection_attempts": None,\
	"retry_delay": 3.0,\
	"socket_timeout": 5.0,\
	"locale": None,\
}
ENV['develop']['MAIL_SENDER_ADDR'] = "noreply@si-cloud.jp"
ENV['develop']['MAIL_CHARSET'] = "utf-8"
ENV['develop']['ZENRIN_ID'] = "JSZ9e399641bbab"
ENV['develop']['DATA_MIGRATE_CMD'] = "/var/httpdStore/c4s_devel/utilities/import_client_worker.py"
ENV['develop']['INQUIRE_MAIL'] = {\
	"user": {\
		"subject": u"【確認メール（develop）】 {{ name_inquire }} お問合せ確認メール",\
		"body_tpl": u"""\
{{ client_name }}
  {{ user_name }} 様

以下の内容で {{ name_inquire }} に関するお問合せをいただきました。

{{ content }}

営業担当よりご連絡させていただく場合がございます。
あらかじめご了承下さい。

引き続き、SESクラウドをご利用ください。

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
 お問合せは、担当営業までご連絡ください。
============================================================""",\
	},\
	"owner": {\
		"subject": u"【システムメール(develop)】 {{ name_inquire }} お問合せ受理",\
		"to": {\
			"name": u"SESクラウド問い合わせ受付",\
			"mail": "partner@good-works.co.jp",\
		},\
		"body_tpl": u"""\
{{ client_name }} の {{ user_name }} 様より、
{{ name_inquire }} に関するお問合せを受理しました。

------------------------------------------------------------
  コード : {{ credential }}
  ユーザー連絡先 : {{ user_name }} 様
  ユーザーメールアドレス : {{ user_mail }}
  ユーザー電話番号 : {{ user_tel1 }}{% if user_tel2 %} / {{ user_tel2 }}{% endif %}
  問合せ内容 :
{{ content }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
	"admin": {\
		"subject": u"【システムメール(develop)】 {{ name_inquire }} お問合せ受理",\
		"to": {\
			"name": "INTER PLUG SESクラウド ML",\
			"mail": "gw_crm@inter-plug.co.jp",\
		},
		"body_tpl": u"""\
{{ client_name }} の {{ user_name }} 様より、
{{ name_inquire }} に関するお問合せを受理しました。

------------------------------------------------------------
  コード : {{ credential }}
  ユーザー連絡先 : {{ user_name }} 様
  ユーザーメールアドレス : {{ user_mail1 }}
  ユーザー電話番号 : {{ user_tel1 }}{% if user_tel2 %} / {{ user_tel2 }}{% endif %}
  問合せ内容 :
{{ content }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
}
ENV['develop']['DATA_MIGRATE_MAIL'] = {\
	"user": {\
		"subject": u"【確認メール(develop)】 データ移行用ファイル受理",\
		"body_tpl": u"""\
{{ client_name }}
  {{ worker_name }} 様

以下のデータ移行用のファイルを受理しました。

------------------------------------------------------------
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

データ移行処理の進捗に応じて、担当営業よりご連絡させていただく場合がございます。
あらかじめご了承下さい。

引き続き、SESクラウドをご利用ください。

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
 お問合せは、担当営業までご連絡ください。
============================================================""",\
	},\
	"owner": {\
		"subject": u"【システムメール(develop)】 データ移行用ファイル受理",\
		"to": {\
			"name": u"SESクラウドデータ移行受付",\
			"mail": "partner@good-works.co.jp",\
		},\
		"body_tpl": u"""\
{{ client_name }} の {{ worker_name }} 様より、
データ移行用のファイルを受理しました（添付ファイル）。

------------------------------------------------------------
  ID : {{ transaction_id }}
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
	"admin": {\
		"subject": u"【データ移行(develop)】 {{ status }}（{{ transaction_id }}）",\
		"to": {\
			"name": "INTER PLUG SESクラウド ML",\
			"mail": "gw_crm@inter-plug.co.jp",\
		},
		"body_tpl": u"""\
{{ client_name }} の {{ worker_name }} より、
データ移行用のファイルを受理しました。

------------------------------------------------------------
  ID : {{ transaction_id }}
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
}
ENV['develop']['NEGOTIATION_REMIND_MAIL'] = {\
	"subject": u"{{ dt_negotiation }} : {{ name }} ({{ client['name'] or client_name }})",\
	"body_tpl": u"""\
営業担当：{{ charging_user['name'] }}
商談日： {{ dt_negotiation }}
商談名： {{ name }}
取引先名： {{ client['name'] or client_name }}
状態： {{ status }}
区別 / フェーズ： {{ business_type }} / {{ phase }}
備考：
{{ note }}
""",\
}
ENV['develop']['SIGNUP_INV_ADD_USER'] = {\
	"subject": u"SESクラウド: ユーザー サインアップのご案内",\
	"body_tpl": u"""\
SESクラウドのご利用申し込みありがとうございます。
システムが、SESクラウドのユーザー登録をご案内いたします。以下のURLから登録を行って下さい。

http://devel.si-cloud.jp/{{ prefix }}/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['develop']['SIGNUP_FINISH_ADD_USER'] = {\
	"subject": u"SESクラウド: ユーザー サインアップ完了のお知らせ",\
	"body_tpl": u"""\
{{ name }} 様

SESクラウドのご利用申し込みありがとうございます。
ユーザー登録が完了しました。以下のURLからご利用ください。

http://devel.si-cloud.jp/{{ prefix }}/html/

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['develop']['SIGNUP_RESET_PWD'] = {\
	"subject": u"SESクラウド: パスワード リセットのお知らせ",\
	"body_tpl": u"""\
パスワードをリセットしました。下記のURLからパスワードを再設定してからログインしてください。

http://devel.si-cloud.jp/{{ prefix }}/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['develop']['SIGNUP_INV_ADD_COMPANY'] = {\
	"subject": u"SESクラウド: サインアップのご案内",\
	"body_tpl": u"""\
SESクラウドのご利用申し込みありがとうございます。
システムが、SESクラウドの登録をご案内いたします。以下のURLから登録を行って下さい。

http://devel.si-cloud.jp/new/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
#[end] Constants for 'develop' env.

#[begin] Constants for 'pool' env.
ENV['pool'] = {}
ENV['pool']['DOMAIN'] = "http://c4s-pool.local"
ENV['pool']['MYSQL_MODULO'] = 1
ENV['pool']['MYSQL_HOSTS'] = (\
	{\
		"host": "153.121.48.45",\
		"port": 3306L,\
		"user": "c4s_pool",\
		"passwd": "goodworks@20140811",\
		"db": "c4s_pool",\
		"charset": "utf8",\
		"use_unicode": True,\
		"compress": True
	},\
)
#Cache for preference per user company.
ENV['pool']['REDIS_PREF_TTL'] = 2 * 60 * 60# 2 hours.
ENV['pool']['REDIS_PREF'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 7,\
	"socket_timeout": 1
}
#Authentication cache.
ENV['pool']['REDIS_AUTH_TTL'] = 24 * 60 * 60# 8 hours.
ENV['pool']['REDIS_AUTH'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 8,\
	"socket_timeout": 1
}
#Cache for chunked data of pagenation.
ENV['pool']['REDIS_'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 9,\
	"socket_timeout": 1
}
#Misc.
ENV['pool']['REDIS_'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 10,\
	"socket_timeout": 1
}
ENV['pool']['AMQP_CRED'] = {"user": "c4s_devel", "passwd": "c4s_devel"}
ENV['pool']['AMQP_EXCHANGES'] = {\
	
}
ENV['pool']['AMQP_QUEUES'] = {\
	
}
ENV['pool']['AMQP_HOST'] = {\
	"host": "localhost",\
	"port": 5672,\
	"virtual_host": "/",\
	"channel_max": None,\
	"frame_max": None,\
	"heartbeat_interval": 5,\
	"ssl": False,\
	"ssl_options": None,\
	"connection_attempts": None,\
	"retry_delay": 3.0,\
	"socket_timeout": 5.0,\
	"locale": None,\
}
ENV['pool']['MAIL_SENDER_ADDR'] = "noreply@si-cloud.jp"
ENV['pool']['MAIL_CHARSET'] = "utf-8"
ENV['pool']['ZENRIN_ID'] = "JSZ9e399641bbab"
ENV['pool']['DATA_MIGRATE_CMD'] = "/var/httpdStore/c4s_pool/utilities/import_client_worker.py"
ENV['pool']['DATA_MIGRATE_MAIL'] = {\
	"user": {\
		"subject": u"【確認メール(pool)】 データ移行用ファイル受理",\
		"body_tpl": u"""\
{{ client_name }}
  {{ worker_name }} 様

以下のデータ移行用のファイルを受理しました。

------------------------------------------------------------
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

データ移行処理の進捗に応じて、担当営業よりご連絡させていただく場合がございます。
あらかじめご了承下さい。

引き続き、SESクラウドをご利用ください。

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
 お問合せは、担当営業までご連絡ください。
============================================================""",\
	},\
	"owner": {\
		"subject": u"【システムメール(pool)】 データ移行用ファイル受理",\
		"to": {\
			"name": u"SESクラウドデータ移行受付",\
			"mail": "partner@good-works.co.jp",\
		},\
		"body_tpl": u"""\
{{ client_name }} の {{ worker_name }} 様より、
データ移行用のファイルを受理しました（添付ファイル）。

------------------------------------------------------------
  ID : {{ transaction_id }}
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
	"admin": {\
		"subject": u"【データ移行(pool)】 {{ status }}（{{ transaction_id }}）",\
		"to": {\
			"name": "INTER PLUG SESクラウド ML",\
			"mail": "gw_crm@inter-plug.co.jp",\
		},
		"body_tpl": u"""\
{{ client_name }} の {{ worker_name }} より、
データ移行用のファイルを受理しました。

------------------------------------------------------------
  ID : {{ transaction_id }}
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
}
ENV['pool']['INQUIRE_MAIL'] = {\
	"user": {\
		"subject": u"【確認メール（pool）】 {{ name_inquire }} お問合せ確認メール",\
		"body_tpl": u"""\
{{ client_name }}
  {{ user_name }} 様

以下の内容で {{ name_inquire }} に関するお問合せをいただきました。

{{ content }}

営業担当よりご連絡させていただく場合がございます。
あらかじめご了承下さい。

引き続き、SESクラウドをご利用ください。

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
 お問合せは、担当営業までご連絡ください。
============================================================""",\
	},\
	"owner": {\
		"subject": u"【システムメール(pool)】 {{ name_inquire }} お問合せ受理",\
		"to": {\
			"name": u"SESクラウド問い合わせ受付",\
			"mail": "partner@good-works.co.jp",\
		},\
		"body_tpl": u"""\
{{ client_name }} の {{ user_name }} 様より、
{{ name_inquire }} に関するお問合せを受理しました。

------------------------------------------------------------
  コード : {{ credential }}
  ユーザー連絡先 : {{ user_name }} 様
  ユーザーメールアドレス : {{ user_mail }}
  ユーザー電話番号 : {{ user_tel1 }}{% if user_tel2 %} / {{ user_tel2 }}{% endif %}
  問合せ内容 :
{{ content }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
	"admin": {\
		"subject": u"【システムメール(pool)】 {{ name_inquire }} お問合せ受理",\
		"to": {\
			"name": "INTER PLUG SESクラウド ML",\
			"mail": "gw_crm@inter-plug.co.jp",\
		},
		"body_tpl": u"""\
{{ client_name }} の {{ user_name }} 様より、
{{ name_inquire }} に関するお問合せを受理しました。

------------------------------------------------------------
  コード : {{ credential }}
  ユーザー連絡先 : {{ user_name }} 様
  ユーザーメールアドレス : {{ user_mail1 }}
  ユーザー電話番号 : {{ user_tel1 }}{% if user_tel2 %} / {{ user_tel2 }}{% endif %}
  問合せ内容 :
{{ content }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
}
ENV['pool']['NEGOTIATION_REMIND_MAIL'] = {\
	"subject": u"{{ dt_negotiation }} : {{ name }} ({{ client['name'] or client_name }})",\
	"body_tpl": u"""\
営業担当：{{ charging_user['name'] }}
商談日： {{ dt_negotiation }}
商談名： {{ name }}
取引先名： {{ client['name'] or client_name }}
状態： {{ status }}
区別 / フェーズ： {{ business_type }} / {{ phase }}
備考：
{{ note }}
""",\
}
ENV['pool']['SIGNUP_INV_ADD_USER'] = {\
	"subject": u"SESクラウド: ユーザー サインアップのご案内",\
	"body_tpl": u"""\
SESクラウドのご利用申し込みありがとうございます。
システムが、SESクラウドのユーザー登録をご案内いたします。以下のURLから登録を行って下さい。

http://pool.si-cloud.jp/{{ prefix }}/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['pool']['SIGNUP_FINISH_ADD_USER'] = {\
	"subject": u"SESクラウド: ユーザー サインアップ完了のお知らせ",\
	"body_tpl": u"""\
{{ name }} 様

SESクラウドのご利用申し込みありがとうございます。
ユーザー登録が完了しました。以下のURLからご利用ください。

http://pool.si-cloud.jp/{{ prefix }}/html/

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['pool']['SIGNUP_RESET_PWD'] = {\
	"subject": u"SESクラウド: パスワード リセットのお知らせ",\
	"body_tpl": u"""\
パスワードをリセットしました。下記のURLからパスワードを再設定してからログインしてください。

http://pool.si-cloud.jp/{{ prefix }}/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['pool']['SIGNUP_INV_ADD_COMPANY'] = {\
	"subject": u"SESクラウド: サインアップのご案内",\
	"body_tpl": u"""\
SESクラウドのご利用申し込みありがとうございます。
システムが、SESクラウドの登録をご案内いたします。以下のURLから登録を行って下さい。

http://pool.si-cloud.jp/new/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
#[end] Constants for 'pool' env.

#[begin] Constants for 'prod' env.
ENV['prod'] = {}
ENV['prod']['DOMAIN'] = "http://c4s-pool.local"
ENV['prod']['MYSQL_MODULO'] = 1
ENV['prod']['MYSQL_HOSTS'] = (\
	{\
		"host": "153.121.48.45",\
		"port": 3306L,\
		"user": "c4s_prod",\
		"passwd": "interplug@20140811",\
		"db": "c4s_prod",\
		"charset": "utf8",\
		"use_unicode": True,\
		"compress": True
	},\
)
#Cache for preference per user company.
ENV['prod']['REDIS_PREF_TTL'] = 2 * 60 * 60# 2 hours.
ENV['prod']['REDIS_PREF'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 13,\
	"socket_timeout": 1
}
#Authentication cache.
ENV['prod']['REDIS_AUTH_TTL'] = 24 * 60 * 60# 8 hours.
ENV['prod']['REDIS_AUTH'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 14,\
	"socket_timeout": 1
}
#Cache for chunked data of pagenation.
ENV['prod']['REDIS_'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 15,\
	"socket_timeout": 1
}
#Misc.
ENV['prod']['REDIS_'] = {\
	"host": "localhost",\
	"port": 6379L,\
	"db": 16,\
	"socket_timeout": 1
}
ENV['prod']['AMQP_CRED'] = {"user": "c4s_devel", "passwd": "c4s_devel"}
ENV['prod']['AMQP_EXCHANGES'] = {\
	
}
ENV['prod']['AMQP_QUEUES'] = {\
	
}
ENV['prod']['AMQP_HOST'] = {\
	"host": "localhost",\
	"port": 5672,\
	"virtual_host": "/",\
	"channel_max": None,\
	"frame_max": None,\
	"heartbeat_interval": 5,\
	"ssl": False,\
	"ssl_options": None,\
	"connection_attempts": None,\
	"retry_delay": 3.0,\
	"socket_timeout": 5.0,\
	"locale": None,\
}
ENV['prod']['MAIL_SENDER_ADDR'] = "noreply@si-cloud.jp"
ENV['prod']['MAIL_CHARSET'] = "utf-8"
ENV['prod']['ZENRIN_ID'] = "JSZ9e399641bbab"
ENV['prod']['DATA_MIGRATE_CMD'] = "/var/httpdStore/c4s_prod/utilities/import_client_worker.py"
ENV['prod']['DATA_MIGRATE_MAIL'] = {\
	"user": {\
		"subject": u"【確認メール】 データ移行用ファイル受理",\
		"body_tpl": u"""\
{{ client_name }}
  {{ worker_name }} 様

以下のデータ移行用のファイルを受理しました。

------------------------------------------------------------
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

データ移行処理の進捗に応じて、担当営業よりご連絡させていただく場合がございます。
あらかじめご了承下さい。

引き続き、SESクラウドをご利用ください。

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
 お問合せは、担当営業までご連絡ください。
============================================================""",\
	},\
	"owner": {\
		"subject": u"【システムメール】 データ移行用ファイル受理",\
		"to": {\
			"name": u"SESクラウドデータ移行受付",\
			"mail": "partner@good-works.co.jp",\
		},\
		"body_tpl": u"""\
{{ client_name }} の {{ worker_name }} 様より、
データ移行用のファイルを受理しました（添付ファイル）。

------------------------------------------------------------
  ID : {{ transaction_id }}
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
	"admin": {\
		"subject": u"【データ移行】 {{ status }}（{{ transaction_id }}）",\
		"to": {\
			"name": "INTER PLUG SESクラウド ML",\
			"mail": "gw_crm@inter-plug.co.jp",\
		},
		"body_tpl": u"""\
{{ client_name }} の {{ worker_name }} より、
データ移行用のファイルを受理しました。

------------------------------------------------------------
  ID : {{ transaction_id }}
  ファイル名: {{ filename }}
  サイズ: {{ filesize }}bytes
  メモ:
{{ memo }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
}
ENV['prod']['INQUIRE_MAIL'] = {\
	"user": {\
		"subject": u"【確認メール】 {{ name_inquire }} お問合せ確認メール",\
		"body_tpl": u"""\
{{ client_name }}
  {{ user_name }} 様

以下の内容で {{ name_inquire }} に関するお問合せをいただきました。

{{ content }}

営業担当よりご連絡させていただく場合がございます。
あらかじめご了承下さい。

引き続き、SESクラウドをご利用ください。

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
 お問合せは、担当営業までご連絡ください。
============================================================""",\
	},\
	"owner": {\
		"subject": u"【システムメール】 {{ name_inquire }} お問合せ受理",\
		"to": {\
			"name": u"SESクラウド問い合わせ受付",\
			"mail": "partner@good-works.co.jp",\
		},\
		"body_tpl": u"""\
{{ client_name }} の {{ user_name }} 様より、
{{ name_inquire }} に関するお問合せを受理しました。

------------------------------------------------------------
  コード : {{ credential }}
  ユーザー連絡先 : {{ user_name }} 様
  ユーザーメールアドレス : {{ user_mail }}
  ユーザー電話番号 : {{ user_tel1 }}{% if user_tel2 %} / {{ user_tel2 }}{% endif %}
  問合せ内容 :
{{ content }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
	"admin": {\
		"subject": u"【システムメール】 {{ name_inquire }} お問合せ受理",\
		"to": {\
			"name": "INTER PLUG SESクラウド ML",\
			"mail": "gw_crm@inter-plug.co.jp",\
		},
		"body_tpl": u"""\
{{ client_name }} の {{ user_name }} 様より、
{{ name_inquire }} に関するお問合せを受理しました。

------------------------------------------------------------
  コード : {{ credential }}
  ユーザー連絡先 : {{ user_name }} 様
  ユーザーメールアドレス : {{ user_mail1 }}
  ユーザー電話番号 : {{ user_tel1 }}{% if user_tel2 %} / {{ user_tel2 }}{% endif %}
  問合せ内容 :
{{ content }}
------------------------------------------------------------

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
	},\
}
ENV['prod']['NEGOTIATION_REMIND_MAIL'] = {\
	"subject": u"{{ dt_negotiation }} : {{ name }} ({{ client['name'] or client_name }})",\
	"body_tpl": u"""\
営業担当：{{ charging_user['name'] }}
商談日： {{ dt_negotiation }}
商談名： {{ name }}
取引先名： {{ client['name'] or client_name }}
状態： {{ status }}
区別 / フェーズ： {{ business_type }} / {{ phase }}
備考：
{{ note }}
""",\
}
ENV['prod']['SIGNUP_INV_ADD_USER'] = {\
	"subject": u"SESクラウド: ユーザー サインアップのご案内",\
	"body_tpl": u"""\
SESクラウドのご利用申し込みありがとうございます。
システムが、SESクラウドのユーザー登録をご案内いたします。以下のURLから登録を行って下さい。

https://www.si-cloud.jp/{{ prefix }}/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['prod']['SIGNUP_FINISH_ADD_USER'] = {\
	"subject": u"SESクラウド: ユーザー サインアップ完了のお知らせ",\
	"body_tpl": u"""\
{{ name }} 様

SESクラウドのご利用申し込みありがとうございます。
ユーザー登録が完了しました。以下のURLからご利用ください。

https://www.si-cloud.jp/{{ prefix }}/html/

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['prod']['SIGNUP_RESET_PWD'] = {\
	"subject": u"SESクラウド: パスワード リセットのお知らせ",\
	"body_tpl": u"""\
パスワードをリセットしました。下記のURLからパスワードを再設定してからログインしてください。

https://www.si-cloud.jp/{{ prefix }}/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
ENV['prod']['SIGNUP_INV_ADD_COMPANY'] = {\
	"subject": u"SESクラウド: サインアップのご案内",\
	"body_tpl": u"""\
SESクラウドのご利用申し込みありがとうございます。
システムが、SESクラウドの登録をご案内いたします。以下のURLから登録を行って下さい。

https://www.si-cloud.jp/new/html/signup.r/?inv={{ code }}

============================================================
 本メールはシステムから自動配信しています。 返信はしないでください。
============================================================""",\
}
#[end] Constants for 'prod' env.


#[begin] Global logging.
ENV['develop']['logging'] = {\
	"host": "localhost",\
	"port": 3306L,\
	"user": "c4s_devel",\
	"passwd": "interplug@20140501",\
	"db": "c4s_log",\
	"charset": "utf8",\
	"use_unicode": True,\
	"compress": True,
}
ENV['pool']['logging'] = {\
	"host": "153.121.48.45",\
	"port": 3306L,\
	"user": "c4s_pool",\
	"passwd": "goodworks@20140811",\
	"db": "c4s_log",\
	"charset": "utf8",\
	"use_unicode": True,\
	"compress": True,
}
ENV['prod']['logging'] = {\
	"host": "153.121.48.45",\
	"port": 3306L,\
	"user": "c4s_prod",\
	"passwd": "interplug@20140811",\
	"db": "c4s_log",\
	"charset": "utf8",\
	"use_unicode": True,\
	"compress": True,
}
#[end] Global logging.
