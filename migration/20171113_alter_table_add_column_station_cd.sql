
ALTER TABLE mt_engineers ADD station_pref_cd varchar(8);
ALTER TABLE mt_engineers ADD station_line_cd varchar(8);
ALTER TABLE mt_engineers ADD station_cd varchar(8);
ALTER TABLE mt_engineers ADD station_lon decimal(30,10);
ALTER TABLE mt_engineers ADD station_lat decimal(30,10);

ALTER TABLE mt_projects ADD station_pref_cd varchar(8);
ALTER TABLE mt_projects ADD station_line_cd varchar(8);
ALTER TABLE mt_projects ADD station_cd varchar(8);
ALTER TABLE mt_projects ADD station_lon decimal(30,10);
ALTER TABLE mt_projects ADD station_lat decimal(30,10);
