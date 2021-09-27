#!/usr/local/bin/python
#-*- coding: UTF-8 -*-

class Status(Exception):
	"""
	This base class indicates status.
	!MUST NOT! instansiate.
		Status codes:
			CODE_0: OK
			CODE_1: Undefined
			CODE_2: Infrastructure troubled.
			CODE_3: Database manipulated by invalid user.
	"""
	CODE_0 = "OK"
	STATUS_0 = 200
	CODE_1 = "Undefined" # client.py DBまわり , engineer.py DBまわり , project.py DBまわり
	STATUS_1 = 500
	CODE_2 = u"一時的に負荷がかかっておりますので10分から15分時間をおいたのちに再ログインをお試しください" # DB に接続できたけど うまく引けなかった
	STATUS_2 = 500
	CODE_3 = u"有効なユーザーからのリクエストではありません。正しくない操作をしたか、別の場所でログインした可能性があります。再ログインしてからお試しください。" # authenticate で prefix, login_id, credential 組に該当するものがなかった。またはそもそも渡されなかった。 redirect
	STATUS_3 = 404
	CODE_4 = u"ログインできませんでした。ログインIDとパスワードをご確認ください。" # ログイン処理で失敗した
	STATUS_4 = 404
	CODE_5 = u"データベースに障害が発生しました。" # DB に接続できなかった
	STATUS_5 = 500
	CODE_6 = u"入力値が正しくありません。"
	STATUS_6 = 400
	CODE_7 = u"認証の有効期限が切れています。再ログインをお試し下さい。" # providers/limitter が発行する CODE_8
	STATUS_7 = 404
	CODE_8 = u"ユーザー情報の取得に失敗しました。アカウントがロックされている可能性があります。管理者にご連絡ください。" # ログインできたけど ユーザ情報が取れなかった
	STATUS_8 = 404
	CODE_9 = u"認証の有効期限が切れています。再ログインをお試し下さい。" # authenticate で credential の期限失効
	STATUS_9 = 404
	CODE_10 = u"リクエストされたURLは存在しません。URLをご確認ください。" # field から適切な 関数 が取れなかった
	STATUS_10 = 404
	CODE_11 = u"ログアウトしました。ログイン画面に移動します。" # logout 時
	STATUS_11 = 307
	CODE_12 = u"ファイルダウンロードに失敗しました。" # ファイルダウンロードにエラーで突入したときの特殊処理
	STATUS_12 = 404
	CODE_13 = u"ファイルサイズが上限値を超えました。" # ファイルアップロード時のみ送出の可能性がある
	STATUS_13 = 200
	CODE_14 = u"ファイル名が上限の32文字を超過しています。" #ファイルアップロード時のみ送出の可能性がある
	STATUS_14 = 200
	CODE_15 = u"データ量が契約値を超えました。" #logics.base.check_limit でセットされる
	STATUS_15 = 402
	CODE_16 = u"有効なサインアップ コードではありません。" #サインアップ時のみのエラーコード
	
	@classmethod
	def desc(cls, code):
		desc_str = cls.CODE_1
		if isinstance(code, (int, long)) and code >= 0:
			try:
				desc_str = getattr(cls, "CODE_%d" % code)
			except:
				pass
		return desc_str
	
	@classmethod
	def http_status(cls, code):
		status = cls.STATUS_1
		if isinstance(code, (int, long)) and code >= 0:
			try:
				status = getattr(cls, "STATUS_%d" % code)
			except:
				pass
		return status
