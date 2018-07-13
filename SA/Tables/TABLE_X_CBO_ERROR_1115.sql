CREATE TABLE sa.table_x_cbo_error_1115 (
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
ALTER TABLE sa.table_x_cbo_error_1115 ADD SUPPLEMENTAL LOG GROUP dmtsora340764132_0 (objid, x_cbo_method, x_error_date, x_error_string, x_esn_imei, x_promo_code, x_red_card, x_source_system, x_zip_code) ALWAYS;