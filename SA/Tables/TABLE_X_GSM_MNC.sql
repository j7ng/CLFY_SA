CREATE TABLE sa.table_x_gsm_mnc (
  objid NUMBER,
  dev NUMBER,
  x_mcc VARCHAR2(5 BYTE),
  x_mnc VARCHAR2(5 BYTE),
  x_lac_beg VARCHAR2(5 BYTE),
  x_lac_end VARCHAR2(5 BYTE),
  x_index NUMBER,
  gsm_mnc2personality NUMBER
);
ALTER TABLE sa.table_x_gsm_mnc ADD SUPPLEMENTAL LOG GROUP dmtsora2059178948_0 (dev, gsm_mnc2personality, objid, x_index, x_lac_beg, x_lac_end, x_mcc, x_mnc) ALWAYS;
COMMENT ON TABLE sa.table_x_gsm_mnc IS 'GSM Parameters MCC MNC LAC';
COMMENT ON COLUMN sa.table_x_gsm_mnc.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_gsm_mnc.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_gsm_mnc.x_mcc IS 'Country Code';
COMMENT ON COLUMN sa.table_x_gsm_mnc.x_mnc IS 'TBD';
COMMENT ON COLUMN sa.table_x_gsm_mnc.x_lac_beg IS 'LAC Value - Begining of Range';
COMMENT ON COLUMN sa.table_x_gsm_mnc.x_lac_end IS 'LAC - End of Range';
COMMENT ON COLUMN sa.table_x_gsm_mnc.x_index IS 'Index 12 records allowed 1-12';
COMMENT ON COLUMN sa.table_x_gsm_mnc.gsm_mnc2personality IS 'TBD';