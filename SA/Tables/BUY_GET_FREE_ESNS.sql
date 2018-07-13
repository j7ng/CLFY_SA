CREATE TABLE sa.buy_get_free_esns (
  esn VARCHAR2(25 BYTE),
  program_name VARCHAR2(20 BYTE),
  enroll_yn CHAR,
  enroll_dt DATE
);
ALTER TABLE sa.buy_get_free_esns ADD SUPPLEMENTAL LOG GROUP dmtsora1548591130_0 (enroll_dt, enroll_yn, esn, program_name) ALWAYS;