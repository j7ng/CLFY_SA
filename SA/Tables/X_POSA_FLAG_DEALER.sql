CREATE TABLE sa.x_posa_flag_dealer (
  retailer VARCHAR2(50 BYTE),
  acct# VARCHAR2(20 BYTE),
  customer_id VARCHAR2(20 BYTE),
  site_id VARCHAR2(30 BYTE),
  posa_airtime VARCHAR2(1 BYTE) NOT NULL,
  posa_phone VARCHAR2(1 BYTE) NOT NULL
);
ALTER TABLE sa.x_posa_flag_dealer ADD SUPPLEMENTAL LOG GROUP dmtsora1124425838_0 (acct#, customer_id, posa_airtime, posa_phone, retailer, site_id) ALWAYS;