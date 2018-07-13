CREATE TABLE sa.table_eco_hdr (
  objid NUMBER,
  eco_code VARCHAR2(30 BYTE),
  title VARCHAR2(255 BYTE),
  eco_type VARCHAR2(30 BYTE),
  create_date DATE,
  eff_type VARCHAR2(30 BYTE),
  start_date DATE,
  end_date DATE,
  status VARCHAR2(30 BYTE),
  description LONG,
  dev NUMBER
);
ALTER TABLE sa.table_eco_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora949651657_0 (create_date, dev, eco_code, eco_type, eff_type, end_date, objid, start_date, status, title) ALWAYS;
COMMENT ON TABLE sa.table_eco_hdr IS 'A set of information about an ECO that potentially results in depot repair activity.';
COMMENT ON COLUMN sa.table_eco_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_eco_hdr.eco_code IS 'ECO code; defaulted from a numbering scheme';
COMMENT ON COLUMN sa.table_eco_hdr.title IS 'What the ECO is intended to achieve';
COMMENT ON COLUMN sa.table_eco_hdr.eco_type IS 'Type of ECO:  This is a user-defined pop up';
COMMENT ON COLUMN sa.table_eco_hdr.create_date IS 'The starting date for the campaign';
COMMENT ON COLUMN sa.table_eco_hdr.eff_type IS 'The effectivity type for the ECO:  This is a user-defined pop up';
COMMENT ON COLUMN sa.table_eco_hdr.start_date IS 'The starting date that the ECO is effective';
COMMENT ON COLUMN sa.table_eco_hdr.end_date IS 'The ending date for the ECO';
COMMENT ON COLUMN sa.table_eco_hdr.status IS 'Status of the ECO. This is a user-defined popup';
COMMENT ON COLUMN sa.table_eco_hdr.description IS 'Text of the ECO';
COMMENT ON COLUMN sa.table_eco_hdr.dev IS 'Row version number for mobile distribution purposes';