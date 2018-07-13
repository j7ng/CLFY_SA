CREATE TABLE sa.x_migr_cases (
  case_number VARCHAR2(20 BYTE),
  status VARCHAR2(200 BYTE)
);
ALTER TABLE sa.x_migr_cases ADD SUPPLEMENTAL LOG GROUP dmtsora1148685663_0 (case_number, status) ALWAYS;