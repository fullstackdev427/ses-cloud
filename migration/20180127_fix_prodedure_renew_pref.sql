DROP PROCEDURE renew_pref;
DELIMITER //
CREATE DEFINER=`root`@`localhost` PROCEDURE `renew_pref`(
  IN `param_prefix` TEXT CHARACTER SET latin1 COLLATE latin1_bin,
  IN `pref_key` TEXT CHARACTER SET latin1 COLLATE latin1_bin,
  IN `pref_val` TEXT)
    MODIFIES SQL DATA
    SQL SECURITY INVOKER
BEGIN
DECLARE company_id MEDIUMINT(5) UNSIGNED;
SELECT
      `id`
      INTO `company_id`
      FROM `mt_user_companies` AS `C`
      WHERE
        `C`.`prefix` = `param_prefix`;

    IF `company_id` IS NOT NULL THEN
      BEGIN
        INSERT INTO `ft_prefs` (`owner_id`, `key`, `value`) VALUES (
          `company_id`, `pref_key`, `pref_val`)
          ON DUPLICATE KEY UPDATE `value` = `pref_val`;
        IF `pref_key` IN (
            'LMT_LEN_ACCOUNT', 'LMT_LEN_CLIENT', 'LMT_LEN_WORKER', 'LMT_LEN_PROJECT', 'LMT_LEN_ENGINEER',
            'LMT_LEN_MAIL_ATTACHMENT','LMT_LEN_MAIL_PER_DAY','LMT_LEN_MAIL_PER_MONTH','LMT_LEN_MAIL_TPL',
            'LMT_LEN_STORE_DATE','LMT_SIZE_BIN') THEN
            INSERT INTO `ft_cap_rec` (`owner_id`, `key`, `value_cap`, `value_rec`) VALUES (`company_id`, `pref_key`, `pref_val`, 0)
            ON DUPLICATE KEY UPDATE `value_cap` = `pref_val`;
        END IF;
      END;
    END IF;
  END
  //
DELIMITER ;