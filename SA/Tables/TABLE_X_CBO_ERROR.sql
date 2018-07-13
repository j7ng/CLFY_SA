CREATE TABLE sa.table_x_cbo_error (
  objid NUMBER,
  x_esn_imei VARCHAR2(30 BYTE),
  x_source_system VARCHAR2(30 BYTE),
  x_cbo_method VARCHAR2(50 BYTE),
  x_error_string VARCHAR2(300 BYTE),
  x_error_date DATE,
  x_promo_code VARCHAR2(10 BYTE),
  x_red_card VARCHAR2(30 BYTE),
  x_zip_code VARCHAR2(10 BYTE)
);
ALTER TABLE sa.table_x_cbo_error ADD SUPPLEMENTAL LOG GROUP dmtsora1543147892_0 (objid, x_cbo_method, x_error_date, x_error_string, x_esn_imei, x_promo_code, x_red_card, x_source_system, x_zip_code) ALWAYS;
COMMENT ON TABLE sa.table_x_cbo_error IS 'Stores error strings for IVR, WEBCSR and WEB Customer';
COMMENT ON COLUMN sa.table_x_cbo_error.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_cbo_error.x_esn_imei IS 'ESN or IMEI';
COMMENT ON COLUMN sa.table_x_cbo_error.x_source_system IS 'Source of error';
COMMENT ON COLUMN sa.table_x_cbo_error.x_cbo_method IS 'CBO Method';
COMMENT ON COLUMN sa.table_x_cbo_error.x_error_string IS 'Error String';
COMMENT ON COLUMN sa.table_x_cbo_error.x_error_date IS 'Date for error';
COMMENT ON COLUMN sa.table_x_cbo_error.x_promo_code IS 'Optional: Promo Code used intransaction';
COMMENT ON COLUMN sa.table_x_cbo_error.x_red_card IS 'Optional: First Red Card used in transaction';
COMMENT ON COLUMN sa.table_x_cbo_error.x_zip_code IS 'Optional: Activation Zip Code';