CREATE TABLE sa.table_country (
  objid NUMBER,
  "NAME" VARCHAR2(300 BYTE),
  s_name VARCHAR2(300 BYTE),
  code NUMBER,
  is_default NUMBER,
  dev NUMBER,
  country2currency NUMBER(*,0),
  x_postal_code VARCHAR2(10 BYTE),
  billable NUMBER DEFAULT 0,
  x_calling_codes VARCHAR2(10 BYTE),
  country VARCHAR2(300 BYTE)
);
ALTER TABLE sa.table_country ADD SUPPLEMENTAL LOG GROUP dmtsora1341129979_0 (code, country2currency, dev, is_default, "NAME", objid, s_name, x_postal_code) ALWAYS;
COMMENT ON TABLE sa.table_country IS 'Country object which defines each country';
COMMENT ON COLUMN sa.table_country.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_country."NAME" IS 'Name of the specific country';
COMMENT ON COLUMN sa.table_country.code IS 'Country code used in telephone numbers for that country';
COMMENT ON COLUMN sa.table_country.is_default IS 'Indicates that this is the default country';
COMMENT ON COLUMN sa.table_country.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_country.country2currency IS 'Currency used by the country';
COMMENT ON COLUMN sa.table_country.x_postal_code IS 'Country Postal Code';
COMMENT ON COLUMN sa.table_country.billable IS 'WHETHER OR NOT THE COUNTRY WILL BE SHOWN ON WEB BILLING PAGES. DEFAULT 0';