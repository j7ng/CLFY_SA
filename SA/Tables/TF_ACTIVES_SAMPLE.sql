CREATE TABLE sa.tf_actives_sample (
  phone_id VARCHAR2(15 BYTE),
  carrier_market_code VARCHAR2(15 BYTE),
  company_code VARCHAR2(15 BYTE),
  activation_date DATE,
  esn VARCHAR2(15 BYTE)
);
ALTER TABLE sa.tf_actives_sample ADD SUPPLEMENTAL LOG GROUP dmtsora1359273849_0 (activation_date, carrier_market_code, company_code, esn, phone_id) ALWAYS;