-- section: 0 - registered from ses-cloud site, 1 - registered from promo site.
ALTER TABLE mt_user_persons ADD section tinyint(1) unsigned  DEFAULT 0;