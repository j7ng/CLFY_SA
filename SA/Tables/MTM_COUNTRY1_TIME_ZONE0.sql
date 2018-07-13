CREATE TABLE sa.mtm_country1_time_zone0 (
  country2time_zone NUMBER(*,0) NOT NULL,
  time_zone2country NUMBER(*,0) NOT NULL
);
ALTER TABLE sa.mtm_country1_time_zone0 ADD SUPPLEMENTAL LOG GROUP dmtsora1732816180_0 (country2time_zone, time_zone2country) ALWAYS;
COMMENT ON TABLE sa.mtm_country1_time_zone0 IS 'Time zone info for countries';
COMMENT ON COLUMN sa.mtm_country1_time_zone0.country2time_zone IS 'Reference to objid of table table_country';
COMMENT ON COLUMN sa.mtm_country1_time_zone0.time_zone2country IS 'Countries which are in the time zone';