CREATE TABLE sa.codes (
  x_code_num VARCHAR2(20 BYTE),
  x_code_name VARCHAR2(20 BYTE),
  x_code_type VARCHAR2(20 BYTE),
  x_value NUMBER
);
ALTER TABLE sa.codes ADD SUPPLEMENTAL LOG GROUP dmtsora2124653570_0 (x_code_name, x_code_num, x_code_type, x_value) ALWAYS;