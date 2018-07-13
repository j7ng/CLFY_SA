CREATE TABLE sa.retention_matrix_update (
  flow_name VARCHAR2(30 BYTE),
  org_id VARCHAR2(40 BYTE),
  src_service_plan_group VARCHAR2(50 BYTE),
  dest_service_plan_group VARCHAR2(50 BYTE),
  "ACTION" VARCHAR2(50 BYTE),
  w_enr_script_id VARCHAR2(15 BYTE),
  w_not_enr_script_id VARCHAR2(15 BYTE),
  spl_script_id VARCHAR2(15 BYTE),
  warning_id VARCHAR2(15 BYTE),
  dml_operation VARCHAR2(50 BYTE)
);