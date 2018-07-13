CREATE TABLE sa.tf_inactives_sample (
  phone_id VARCHAR2(15 BYTE),
  carrier_market_code VARCHAR2(15 BYTE),
  company_code VARCHAR2(15 BYTE),
  deactivation_date DATE,
  esn VARCHAR2(15 BYTE)
);
ALTER TABLE sa.tf_inactives_sample ADD SUPPLEMENTAL LOG GROUP dmtsora332471458_0 (carrier_market_code, company_code, deactivation_date, esn, phone_id) ALWAYS;