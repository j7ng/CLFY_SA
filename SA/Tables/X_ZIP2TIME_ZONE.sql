CREATE TABLE sa.x_zip2time_zone (
  zip VARCHAR2(20 BYTE),
  st VARCHAR2(3 BYTE),
  timezone VARCHAR2(6 BYTE)
);
COMMENT ON TABLE sa.x_zip2time_zone IS 'Timezone info for zipcode';
COMMENT ON COLUMN sa.x_zip2time_zone.zip IS 'Zip code';
COMMENT ON COLUMN sa.x_zip2time_zone.st IS 'State Name';
COMMENT ON COLUMN sa.x_zip2time_zone.timezone IS 'Timezone Info';