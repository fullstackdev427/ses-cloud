DROP FUNCTION IF EXISTS travel_time_from_distance ;

DELIMITER //
CREATE FUNCTION travel_time_from_distance(
  lat1 decimal(30,10),
  lng1  decimal(30,10),
  lat2  decimal(30,10),
  lng2  decimal(30,10)
)
RETURNS decimal(30,10) DETERMINISTIC

BEGIN
  DECLARE p decimal(30,10);
  DECLARE m decimal(30,10);
  DECLARE n decimal(30,10);
  DECLARE a decimal(30,10);
  DECLARE meter decimal(30,10);
  DECLARE wlat1 decimal(30,10);
  DECLARE wlng1 decimal(30,10);
  DECLARE wlat2 decimal(30,10);
  DECLARE wlng2 decimal(30,10);

  DECLARE latidiff decimal(30,10);
  DECLARE longdiff decimal(30,10);

  DECLARE wx decimal(30,10);
  DECLARE wy decimal(30,10);

  DECLARE minutes decimal(30,0);

  SET wlat1 = lat1 * (PI()/180);
  SET wlng1 = lng1 * (PI()/180);

  SET wlat2 = lat2 * (PI()/180);
  SET wlng2 = lng2 * (PI()/180);

  SET p = ((wlat2 + wlat1) / 2);
  SET latidiff = wlat2 - wlat1;
  SET longdiff = wlng2 - wlng1;

-- M:子午線曲率半径
  SET m = 6335439 / SQRT(POWER(1 - 0.006694 * sin(p) * sin(p), 3));

-- N:卯酉線曲率半径
  SET n = 6378137 / SQRT(1 - 0.006694 * sin(p) * sin(p));

-- 2点間の距離(m)
  SET wx = m * latidiff;
  SET wy = n * cos(p) * longdiff;

  SET meter = SQRT(wx * wx + wy * wy);

-- 時速28km/hの場合の時間(分)
  SET minutes = (meter / 1000) / 25 * 60;

  RETURN minutes;

END;
//
DELIMITER ;