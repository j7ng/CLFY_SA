CREATE TABLE sa.x_fix_ota_completed (
  objid NUMBER,
  x_action_type VARCHAR2(20 BYTE),
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_transact_date DATE,
  x_total_units NUMBER,
  x_result VARCHAR2(20 BYTE),
  x_ota_type VARCHAR2(30 BYTE),
  chobjid NUMBER,
  x_gen_code VARCHAR2(100 BYTE),
  x_sequence NUMBER,
  x_code_accepted VARCHAR2(10 BYTE),
  x_code_type VARCHAR2(20 BYTE),
  x_seq_update VARCHAR2(3 BYTE)
);
ALTER TABLE sa.x_fix_ota_completed ADD SUPPLEMENTAL LOG GROUP dmtsora572623223_0 (chobjid, objid, x_action_type, x_code_accepted, x_code_type, x_gen_code, x_min, x_ota_type, x_result, x_sequence, x_seq_update, x_service_id, x_sourcesystem, x_total_units, x_transact_date) ALWAYS;