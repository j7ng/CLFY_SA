CREATE TABLE sa.table_x_modelscores (
  objid NUMBER,
  x_value_scr NUMBER(6,2),
  x_churn_scr NUMBER(6,3),
  x_unit_churn_scr NUMBER(6,3),
  x_reactivation_scr NUMBER(6,3),
  x_esn VARCHAR2(30 BYTE),
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
  x_modelscores2site_part NUMBER
);
ALTER TABLE sa.table_x_modelscores ADD SUPPLEMENTAL LOG GROUP dmtsora1596773072_0 (objid, x_active, x_churn_scr, x_churn_tier, x_esn, x_min, x_modelscores2site_part, x_reactivation_scr, x_reactivation_tier, x_scoring_date, x_segment_code, x_segment_enhancement, x_unit_churn_scr, x_unit_churn_tier, x_unit_identifier, x_value_scr, x_value_tier) ALWAYS;