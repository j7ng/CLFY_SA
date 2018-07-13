CREATE TABLE sa.x_fraud_params (
  no_of_days NUMBER
);
ALTER TABLE sa.x_fraud_params ADD SUPPLEMENTAL LOG GROUP dmtsora913066484_0 (no_of_days) ALWAYS;