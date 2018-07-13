CREATE TABLE sa.x_rate_plan (
  objid NUMBER,
  x_rate_plan VARCHAR2(60 BYTE),
  x_private_network VARCHAR2(30 BYTE),
  x_espid_update VARCHAR2(30 BYTE),
  x_espid_num VARCHAR2(30 BYTE),
  allow_mform_apn_rqst_flag VARCHAR2(1 BYTE),
  propagate_flag_value NUMBER(4),
  calculate_data_units_flag VARCHAR2(1 BYTE),
  thresholds_to_tmo VARCHAR2(1 BYTE) DEFAULT 'Y',
  hotspot_buckets_flag VARCHAR2(1 BYTE)
);
COMMENT ON TABLE sa.x_rate_plan IS 'TO STORE INFOR OF RATE PLANS';
COMMENT ON COLUMN sa.x_rate_plan.objid IS 'UNIQUE INTERNAL IDENTIFIER';
COMMENT ON COLUMN sa.x_rate_plan.x_rate_plan IS 'CURRENT RATE PLAN OF DEVICE';
COMMENT ON COLUMN sa.x_rate_plan.x_private_network IS 'DO NOT FORWARD FLAG';
COMMENT ON COLUMN sa.x_rate_plan.x_espid_update IS ' FLAG FOR NET NUMBERS';
COMMENT ON COLUMN sa.x_rate_plan.x_espid_num IS 'SUB GROUP OF NET NUMBERS';
COMMENT ON COLUMN sa.x_rate_plan.calculate_data_units_flag IS 'WILL BE SET TO Y FOR IGATE TO COVERT KB DATA_UNITS TO MB';
COMMENT ON COLUMN sa.x_rate_plan.thresholds_to_tmo IS 'Sending threshold buckets to TMO based on rate plan';
COMMENT ON COLUMN sa.x_rate_plan.hotspot_buckets_flag IS 'Hotspot and BYOT Buckets flag';