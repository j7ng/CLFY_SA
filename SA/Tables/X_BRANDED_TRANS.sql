CREATE TABLE sa.x_branded_trans (
  objid NUMBER,
  tf_part_num_parent VARCHAR2(100 BYTE),
  tf_serial_num VARCHAR2(100 BYTE),
  tf_extract_flag VARCHAR2(1 BYTE),
  tf_extract_date DATE,
  log_date DATE,
  tf_part_num_old VARCHAR2(100 BYTE),
  tf_branding_channel VARCHAR2(80 BYTE)
);
COMMENT ON TABLE sa.x_branded_trans IS 'TRANSACTION FILE THAT CAPTURES THE BRANDING OF THE ESN';
COMMENT ON COLUMN sa.x_branded_trans.objid IS 'UNIQUE KEY OF X_BRANDED_TRANS TABLE';
COMMENT ON COLUMN sa.x_branded_trans.tf_part_num_parent IS 'PART_NUMBER';
COMMENT ON COLUMN sa.x_branded_trans.tf_serial_num IS 'ESN';
COMMENT ON COLUMN sa.x_branded_trans.tf_extract_flag IS 'EXTRACT FLAG';
COMMENT ON COLUMN sa.x_branded_trans.tf_extract_date IS 'EXTRACT DATE';
COMMENT ON COLUMN sa.x_branded_trans.log_date IS 'LOG DATE';