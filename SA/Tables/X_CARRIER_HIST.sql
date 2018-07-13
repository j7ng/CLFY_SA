CREATE TABLE sa.x_carrier_hist (
  objid NUMBER,
  x_carrier_id NUMBER,
  x_mkt_submkt_name VARCHAR2(30 BYTE),
  x_submkt_of NUMBER,
  x_city VARCHAR2(30 BYTE),
  x_state VARCHAR2(30 BYTE),
  x_tapereturn_charge NUMBER(6,2),
  x_country_code NUMBER,
  x_activeline_percent NUMBER,
  x_status VARCHAR2(20 BYTE),
  x_ld_provider VARCHAR2(30 BYTE),
  x_ld_account VARCHAR2(50 BYTE),
  x_ld_pic_code VARCHAR2(50 BYTE),
  x_rate_plan VARCHAR2(60 BYTE),
  x_dummy_esn VARCHAR2(10 BYTE),
  x_bill_date DATE,
  x_voicemail NUMBER,
  x_vm_code VARCHAR2(30 BYTE),
  x_vm_package NUMBER,
  x_caller_id NUMBER,
  x_id_code VARCHAR2(30 BYTE),
  x_id_package NUMBER,
  x_call_waiting NUMBER,
  x_cw_code VARCHAR2(30 BYTE),
  x_cw_package NUMBER,
  x_react_technology VARCHAR2(20 BYTE),
  x_react_analog NUMBER,
  x_act_technology VARCHAR2(20 BYTE),
  x_act_analog NUMBER,
  x_digital_rate_plan VARCHAR2(60 BYTE),
  x_digital_feature VARCHAR2(30 BYTE),
  x_prl_preloaded NUMBER,
  carrier2carrier_group NUMBER,
  tapereturn_addr2address NUMBER,
  carrier2provider NUMBER,
  x_carrier2address NUMBER,
  carrier2personality NUMBER,
  carrier2rules NUMBER,
  carrier2x_carr_script NUMBER,
  x_special_mkt NUMBER,
  x_new_analog_plan VARCHAR2(30 BYTE),
  x_new_digital_plan VARCHAR2(30 BYTE),
  x_sms NUMBER,
  x_sms_code VARCHAR2(30 BYTE),
  x_sms_package NUMBER,
  carrier_hist2carrier NUMBER,
  x_carrier_hist2user NUMBER,
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  triggering_record_type VARCHAR2(6 BYTE)
);
ALTER TABLE sa.x_carrier_hist ADD SUPPLEMENTAL LOG GROUP dmtsora350246071_0 (carrier2carrier_group, objid, x_activeline_percent, x_act_analog, x_act_technology, x_bill_date, x_caller_id, x_call_waiting, x_carrier_id, x_city, x_country_code, x_cw_code, x_cw_package, x_digital_feature, x_digital_rate_plan, x_dummy_esn, x_id_code, x_id_package, x_ld_account, x_ld_pic_code, x_ld_provider, x_mkt_submkt_name, x_prl_preloaded, x_rate_plan, x_react_analog, x_react_technology, x_state, x_status, x_submkt_of, x_tapereturn_charge, x_vm_code, x_vm_package, x_voicemail) ALWAYS;
ALTER TABLE sa.x_carrier_hist ADD SUPPLEMENTAL LOG GROUP dmtsora350246071_1 (carrier2personality, carrier2provider, carrier2rules, carrier2x_carr_script, carrier_hist2carrier, osuser, tapereturn_addr2address, triggering_record_type, x_carrier2address, x_carrier_hist2user, x_change_date, x_new_analog_plan, x_new_digital_plan, x_sms, x_sms_code, x_sms_package, x_special_mkt) ALWAYS;
COMMENT ON TABLE sa.x_carrier_hist IS 'This table tracks all the changes performed on the table_x_carrier';
COMMENT ON COLUMN sa.x_carrier_hist.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.x_carrier_hist.x_carrier_id IS 'Carrier ID';
COMMENT ON COLUMN sa.x_carrier_hist.x_mkt_submkt_name IS 'Carrier Name';
COMMENT ON COLUMN sa.x_carrier_hist.x_submkt_of IS 'not used';
COMMENT ON COLUMN sa.x_carrier_hist.x_city IS 'City';
COMMENT ON COLUMN sa.x_carrier_hist.x_state IS 'State';
COMMENT ON COLUMN sa.x_carrier_hist.x_tapereturn_charge IS 'Tape Return Charge';
COMMENT ON COLUMN sa.x_carrier_hist.x_country_code IS 'Country Code';
COMMENT ON COLUMN sa.x_carrier_hist.x_activeline_percent IS 'Active Line Percentage';
COMMENT ON COLUMN sa.x_carrier_hist.x_status IS 'Status: ACTIVE,INACTIVE';
COMMENT ON COLUMN sa.x_carrier_hist.x_ld_provider IS 'Long Distance Provider';
COMMENT ON COLUMN sa.x_carrier_hist.x_ld_account IS 'Long Distance Account';
COMMENT ON COLUMN sa.x_carrier_hist.x_ld_pic_code IS 'Long Distance PIC Code';
COMMENT ON COLUMN sa.x_carrier_hist.x_rate_plan IS 'Rate Plan, not used';
COMMENT ON COLUMN sa.x_carrier_hist.x_dummy_esn IS 'Dummy ESN, not used';
COMMENT ON COLUMN sa.x_carrier_hist.x_bill_date IS 'Bill date, not used';
COMMENT ON COLUMN sa.x_carrier_hist.x_vm_code IS 'Voice Mail Flag';
COMMENT ON COLUMN sa.x_carrier_hist.x_vm_package IS 'Voice Mail Package';
COMMENT ON COLUMN sa.x_carrier_hist.x_caller_id IS 'Caller ID Flag';
COMMENT ON COLUMN sa.x_carrier_hist.x_id_code IS 'Caller ID Code';
COMMENT ON COLUMN sa.x_carrier_hist.x_id_package IS 'Caller ID Package';
COMMENT ON COLUMN sa.x_carrier_hist.x_call_waiting IS 'Call Waiting Flag';
COMMENT ON COLUMN sa.x_carrier_hist.x_cw_code IS 'Call Waiting Code';
COMMENT ON COLUMN sa.x_carrier_hist.x_cw_package IS 'Call Waiting Package';
COMMENT ON COLUMN sa.x_carrier_hist.x_react_technology IS 'Reactivation Technology';
COMMENT ON COLUMN sa.x_carrier_hist.x_react_analog IS 'Reactivate Analog Flag';
COMMENT ON COLUMN sa.x_carrier_hist.x_act_technology IS 'Activation Technology';
COMMENT ON COLUMN sa.x_carrier_hist.x_act_analog IS 'Analog Activation Flag';
COMMENT ON COLUMN sa.x_carrier_hist.x_digital_rate_plan IS 'Digital Rate Plan';
COMMENT ON COLUMN sa.x_carrier_hist.x_digital_feature IS 'Digital Feature';
COMMENT ON COLUMN sa.x_carrier_hist.x_prl_preloaded IS 'PRL Preload';
COMMENT ON COLUMN sa.x_carrier_hist.carrier2carrier_group IS 'Reference objid table_x_carrier_group';
COMMENT ON COLUMN sa.x_carrier_hist.tapereturn_addr2address IS 'Reference to objid table_address';
COMMENT ON COLUMN sa.x_carrier_hist.carrier2provider IS 'Reference to objid table_x_ld_provider';
COMMENT ON COLUMN sa.x_carrier_hist.x_carrier2address IS 'Reference objid table_address';
COMMENT ON COLUMN sa.x_carrier_hist.carrier2personality IS 'Reference objid table_x_carr_personality';
COMMENT ON COLUMN sa.x_carrier_hist.carrier2rules IS 'Reference objid table_x_carrier_rules';
COMMENT ON COLUMN sa.x_carrier_hist.carrier2x_carr_script IS 'not used';
COMMENT ON COLUMN sa.x_carrier_hist.x_special_mkt IS 'Special Market';
COMMENT ON COLUMN sa.x_carrier_hist.x_new_analog_plan IS 'New Analog Plan';
COMMENT ON COLUMN sa.x_carrier_hist.x_new_digital_plan IS 'New Digital Plan';
COMMENT ON COLUMN sa.x_carrier_hist.x_sms IS 'SMS Flag';
COMMENT ON COLUMN sa.x_carrier_hist.x_sms_code IS 'SMS Code';
COMMENT ON COLUMN sa.x_carrier_hist.x_sms_package IS 'SMS package';
COMMENT ON COLUMN sa.x_carrier_hist.carrier_hist2carrier IS 'Reference objid table_x_carrier';
COMMENT ON COLUMN sa.x_carrier_hist.x_carrier_hist2user IS 'Reference objid table_user';
COMMENT ON COLUMN sa.x_carrier_hist.x_change_date IS 'Change Date';
COMMENT ON COLUMN sa.x_carrier_hist.osuser IS 'Operating System User';
COMMENT ON COLUMN sa.x_carrier_hist.triggering_record_type IS 'Type of Change';