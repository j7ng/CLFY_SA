CREATE TABLE sa.table_x_ild_country (
  objid NUMBER,
  dev NUMBER,
  x_country_code VARCHAR2(5 BYTE),
  x_country_name VARCHAR2(50 BYTE),
  country2ild_rate NUMBER
);
ALTER TABLE sa.table_x_ild_country ADD SUPPLEMENTAL LOG GROUP dmtsora575443289_0 (country2ild_rate, dev, objid, x_country_code, x_country_name) ALWAYS;
COMMENT ON COLUMN sa.table_x_ild_country.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ild_country.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ild_country.x_country_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_country.x_country_name IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_country.country2ild_rate IS 'TBD';