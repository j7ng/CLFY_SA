CREATE TABLE sa.x_clarify_codes (
  objid NUMBER,
  clfy_code VARCHAR2(30 BYTE),
  clfy_message VARCHAR2(200 BYTE),
  clfy_sp_message VARCHAR2(200 BYTE),
  program_name VARCHAR2(30 BYTE),
  "ACTIVE" VARCHAR2(30 BYTE),
  clfy_code_type VARCHAR2(30 BYTE)
);
ALTER TABLE sa.x_clarify_codes ADD SUPPLEMENTAL LOG GROUP dmtsora1316345581_0 ("ACTIVE", clfy_code, clfy_code_type, clfy_message, clfy_sp_message, objid, program_name) ALWAYS;