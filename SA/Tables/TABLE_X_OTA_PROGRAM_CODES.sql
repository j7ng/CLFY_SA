CREATE TABLE sa.table_x_ota_program_codes (
  objid NUMBER,
  x_ota_code_number VARCHAR2(20 BYTE),
  x_ota_code_type VARCHAR2(30 BYTE),
  x_ota_mode_type VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_ota_program_codes ADD SUPPLEMENTAL LOG GROUP dmtsora791540613_0 (objid, x_ota_code_number, x_ota_code_type, x_ota_mode_type) ALWAYS;