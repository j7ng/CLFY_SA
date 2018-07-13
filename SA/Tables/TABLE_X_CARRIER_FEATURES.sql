CREATE TABLE sa.table_x_carrier_features (
  objid NUMBER,
  dev NUMBER,
  x_technology VARCHAR2(30 BYTE),
  x_rate_plan VARCHAR2(60 BYTE),
  x_voicemail NUMBER,
  x_vm_code VARCHAR2(30 BYTE),
  x_vm_package NUMBER,
  x_caller_id NUMBER,
  x_id_code VARCHAR2(30 BYTE),
  x_id_package NUMBER,
  x_sms NUMBER,
  x_sms_code VARCHAR2(30 BYTE),
  x_sms_package NUMBER,
  x_call_waiting NUMBER,
  x_cw_code VARCHAR2(30 BYTE),
  x_cw_package NUMBER,
  x_digital_feature VARCHAR2(30 BYTE),
  x_dig_feature NUMBER,
  x_feature2x_carrier NUMBER,
  x_smsc_number VARCHAR2(30 BYTE),
  x_data NUMBER,
  x_restricted_use NUMBER,
  x_switch_base_rate VARCHAR2(10 BYTE),
  x_features2bus_org NUMBER,
  x_is_swb_carrier NUMBER(1),
  x_mpn NUMBER,
  x_mpn_code VARCHAR2(30 BYTE),
  x_pool_name VARCHAR2(60 BYTE),
  create_mform_ig_flag VARCHAR2(1 BYTE),
  use_cf_extension_flag VARCHAR2(1 BYTE),
  data_saver NUMBER(22),
  data_saver_code VARCHAR2(30 BYTE),
  use_rp_extension_flag VARCHAR2(1 BYTE)
);
ALTER TABLE sa.table_x_carrier_features ADD SUPPLEMENTAL LOG GROUP dmtsora381021642_0 (dev, objid, x_caller_id, x_call_waiting, x_cw_code, x_cw_package, x_data, x_digital_feature, x_dig_feature, x_feature2x_carrier, x_id_code, x_id_package, x_rate_plan, x_restricted_use, x_sms, x_smsc_number, x_sms_code, x_sms_package, x_switch_base_rate, x_technology, x_vm_code, x_vm_package, x_voicemail) ALWAYS;
COMMENT ON TABLE sa.table_x_carrier_features IS 'Contains feature information of a carrier';
COMMENT ON COLUMN sa.table_x_carrier_features.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrier_features.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_carrier_features.x_technology IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_rate_plan IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_voicemail IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_vm_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_vm_package IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_caller_id IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_id_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_id_package IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_sms IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_sms_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_sms_package IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_call_waiting IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_cw_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_cw_package IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_digital_feature IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_dig_feature IS 'digital feature flag 0 = No, 1 = Yes';
COMMENT ON COLUMN sa.table_x_carrier_features.x_feature2x_carrier IS 'Relation to carrier table';
COMMENT ON COLUMN sa.table_x_carrier_features.x_smsc_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_data IS 'data features record flag 0 = No, 1 = Yes';
COMMENT ON COLUMN sa.table_x_carrier_features.x_restricted_use IS 'data features record flag 0 = No, 1 = Yes';
COMMENT ON COLUMN sa.table_x_carrier_features.x_switch_base_rate IS 'TBD';
COMMENT ON COLUMN sa.table_x_carrier_features.x_is_swb_carrier IS 'Has SWB Rate Plan or Not. 0 means No and 1 means YES';
COMMENT ON COLUMN sa.table_x_carrier_features.x_mpn IS 'MOBILE PRIVATE NETWORK FLAG';
COMMENT ON COLUMN sa.table_x_carrier_features.x_mpn_code IS 'RATE_PLAN';
COMMENT ON COLUMN sa.table_x_carrier_features.x_pool_name IS 'IP ADDRESSES FOR PRIVATE NETWORK';