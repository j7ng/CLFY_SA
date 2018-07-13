CREATE TABLE sa.simoutconfrules (
  sourcesystem VARCHAR2(30 BYTE),
  org_id VARCHAR2(30 BYTE),
  sim_profile VARCHAR2(30 BYTE),
  vendor_model VARCHAR2(30 BYTE),
  dealer_id VARCHAR2(80 BYTE),
  phone_part_num VARCHAR2(30 BYTE),
  esninputformat VARCHAR2(30 BYTE),
  esnsize NUMBER,
  luhn_validation VARCHAR2(5 BYTE),
  hexconversion VARCHAR2(30 BYTE),
  vd_reqd VARCHAR2(5 BYTE),
  fraud_alert_chk VARCHAR2(1 BYTE),
  time_interval NUMBER,
  esn_count NUMBER,
  fraud_alert_to_add VARCHAR2(200 BYTE),
  fraud_alert_subj VARCHAR2(300 BYTE),
  description VARCHAR2(200 BYTE)
);
COMMENT ON TABLE sa.simoutconfrules IS 'SIM OUT Configuration Rules';
COMMENT ON COLUMN sa.simoutconfrules.sourcesystem IS 'Sourcesystem of the transaction drives dealer selection';
COMMENT ON COLUMN sa.simoutconfrules.org_id IS 'Brand';
COMMENT ON COLUMN sa.simoutconfrules.sim_profile IS 'SIM Part Number';
COMMENT ON COLUMN sa.simoutconfrules.vendor_model IS 'Vendor Model Equivalent';
COMMENT ON COLUMN sa.simoutconfrules.dealer_id IS 'Dealer ID linked to the Sourcesystem';
COMMENT ON COLUMN sa.simoutconfrules.phone_part_num IS 'Phone Part Number';
COMMENT ON COLUMN sa.simoutconfrules.esninputformat IS 'Expected Valuer DECIMAL,HEXADECIMAL';
COMMENT ON COLUMN sa.simoutconfrules.esnsize IS 'Number of Characters';
COMMENT ON COLUMN sa.simoutconfrules.luhn_validation IS 'LUHN Validation Required : YES, NO';
COMMENT ON COLUMN sa.simoutconfrules.hexconversion IS 'HEX Value update: NOT_NEEDED,DECIMAL,HEXADECIMAL';
COMMENT ON COLUMN sa.simoutconfrules.vd_reqd IS 'Verify Device Required : YES, NO';
COMMENT ON COLUMN sa.simoutconfrules.fraud_alert_chk IS 'Fraud Alert Required Y / N';
COMMENT ON COLUMN sa.simoutconfrules.time_interval IS 'Time interval to check the count of Registered ESN for particular store id';
COMMENT ON COLUMN sa.simoutconfrules.esn_count IS 'No of ESN';
COMMENT ON COLUMN sa.simoutconfrules.fraud_alert_to_add IS 'Fraud Alert To Email Address';
COMMENT ON COLUMN sa.simoutconfrules.fraud_alert_subj IS 'Fraud Alert Subject';