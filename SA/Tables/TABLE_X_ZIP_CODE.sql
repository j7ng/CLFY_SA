CREATE TABLE sa.table_x_zip_code (
  objid NUMBER,
  x_zip VARCHAR2(10 BYTE),
  x_city VARCHAR2(30 BYTE),
  x_state VARCHAR2(40 BYTE),
  x_has_warranty NUMBER,
  safelink_zip2part_num NUMBER,
  safelink_zip2part_num_hp NUMBER,
  x_att_dual NUMBER,
  x_att_nano NUMBER,
  x_tmo_dual NUMBER,
  x_tmo_nano NUMBER,
  x_sl_url VARCHAR2(200 BYTE),
  x_claro_dual NUMBER,
  x_claro_nano NUMBER,
  tribal_part_number NUMBER,
  tribal_tmo_nano NUMBER,
  tribal_tmo_dual NUMBER,
  tribal_att_nano NUMBER,
  tribal_att_dual NUMBER
);
ALTER TABLE sa.table_x_zip_code ADD SUPPLEMENTAL LOG GROUP dmtsora187711733_0 (objid, safelink_zip2part_num, x_city, x_has_warranty, x_state, x_zip) ALWAYS;
COMMENT ON TABLE sa.table_x_zip_code IS 'Contains Zip codes and their city and states';
COMMENT ON COLUMN sa.table_x_zip_code.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_zip_code.x_zip IS 'zip code or postal code';
COMMENT ON COLUMN sa.table_x_zip_code.x_city IS 'City Name';
COMMENT ON COLUMN sa.table_x_zip_code.x_state IS 'State';
COMMENT ON COLUMN sa.table_x_zip_code.x_has_warranty IS 'Extended Warranty Flag';
COMMENT ON COLUMN sa.table_x_zip_code.safelink_zip2part_num IS 'TBD';
COMMENT ON COLUMN sa.table_x_zip_code.safelink_zip2part_num_hp IS 'HOME PHONE PART NUMBER OBJID RELATED TO ZIP.';
COMMENT ON COLUMN sa.table_x_zip_code.x_att_dual IS 'It is ATT DUAL';
COMMENT ON COLUMN sa.table_x_zip_code.x_att_nano IS 'It is ATT NANO';
COMMENT ON COLUMN sa.table_x_zip_code.x_tmo_dual IS 'It is TMO DUAL';
COMMENT ON COLUMN sa.table_x_zip_code.x_tmo_nano IS 'It is TMO NANO';
COMMENT ON COLUMN sa.table_x_zip_code.x_sl_url IS 'Indicates Safelink URL';