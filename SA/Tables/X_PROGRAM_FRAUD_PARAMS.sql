CREATE TABLE sa.x_program_fraud_params (
  program_id NUMBER,
  amount NUMBER,
  "TYPE" VARCHAR2(20 BYTE),
  frequency NUMBER
);
ALTER TABLE sa.x_program_fraud_params ADD SUPPLEMENTAL LOG GROUP dmtsora1567033851_0 (amount, frequency, program_id, "TYPE") ALWAYS;