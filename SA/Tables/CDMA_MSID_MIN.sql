CREATE TABLE sa.cdma_msid_min (
  x_service_id VARCHAR2(20 BYTE),
  x_min VARCHAR2(20 BYTE),
  x_transact_date DATE,
  processed_flag CHAR
);
ALTER TABLE sa.cdma_msid_min ADD SUPPLEMENTAL LOG GROUP dmtsora762880526_0 (processed_flag, x_min, x_service_id, x_transact_date) ALWAYS;