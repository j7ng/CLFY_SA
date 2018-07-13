CREATE TABLE sa.table_csc_country (
  objid NUMBER,
  "NAME" VARCHAR2(40 BYTE),
  s_name VARCHAR2(40 BYTE),
  code NUMBER,
  is_default NUMBER,
  server_id NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_csc_country ADD SUPPLEMENTAL LOG GROUP dmtsora1285120892_0 (code, dev, is_default, "NAME", objid, server_id, s_name) ALWAYS;
COMMENT ON TABLE sa.table_csc_country IS 'Country object which defines each country';
COMMENT ON COLUMN sa.table_csc_country.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_country."NAME" IS 'Name of the specific country';
COMMENT ON COLUMN sa.table_csc_country.code IS 'Country code used in telephone numbers for that country';
COMMENT ON COLUMN sa.table_csc_country.is_default IS 'Indicates that this is the default country';
COMMENT ON COLUMN sa.table_csc_country.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_country.dev IS 'Row version number for mobile distribution purposes';