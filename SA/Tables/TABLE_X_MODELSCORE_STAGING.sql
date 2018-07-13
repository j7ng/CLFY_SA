CREATE TABLE sa.table_x_modelscore_staging (
  x_value_scr NUMBER(6,2),
  x_churn_scr NUMBER(6,3),
  x_unit_churn_scr NUMBER(6,3),
  x_reactivation_scr NUMBER(6,3),
  x_esn VARCHAR2(30 BYTE) NOT NULL,
  x_min VARCHAR2(30 BYTE),
  x_active VARCHAR2(1 BYTE),
  x_scoring_date VARCHAR2(6 BYTE),
  x_segment_code VARCHAR2(1 BYTE),
  x_value_tier VARCHAR2(1 BYTE),
  x_churn_tier VARCHAR2(1 BYTE),
  x_unit_identifier VARCHAR2(1 BYTE),
  x_unit_churn_tier VARCHAR2(1 BYTE),
  x_reactivation_tier VARCHAR2(1 BYTE),
  x_segment_enhancement VARCHAR2(17 BYTE),
  x_last_name VARCHAR2(30 BYTE),
  x_first_name VARCHAR2(30 BYTE),
  x_address VARCHAR2(30 BYTE),
  x_city VARCHAR2(30 BYTE),
  x_state VARCHAR2(2 BYTE),
  x_zip VARCHAR2(5 BYTE),
  x_phone VARCHAR2(10 BYTE),
  x_new_record CHAR,
  x_segment_enhansement CHAR(17 BYTE)
);
ALTER TABLE sa.table_x_modelscore_staging ADD SUPPLEMENTAL LOG GROUP dmtsora1350208120_0 (x_active, x_address, x_churn_scr, x_churn_tier, x_city, x_esn, x_first_name, x_last_name, x_min, x_new_record, x_phone, x_reactivation_scr, x_reactivation_tier, x_scoring_date, x_segment_code, x_segment_enhancement, x_segment_enhansement, x_state, x_unit_churn_scr, x_unit_churn_tier, x_unit_identifier, x_value_scr, x_value_tier, x_zip) ALWAYS;