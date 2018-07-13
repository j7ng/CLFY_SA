CREATE TABLE sa.x_fraud_cases (
  x_case_id VARCHAR2(255 BYTE),
  x_esn VARCHAR2(30 BYTE),
  x_units NUMBER,
  x_date_issued DATE,
  x_insert_date DATE
);
ALTER TABLE sa.x_fraud_cases ADD SUPPLEMENTAL LOG GROUP dmtsora439218206_0 (x_case_id, x_date_issued, x_esn, x_insert_date, x_units) ALWAYS;