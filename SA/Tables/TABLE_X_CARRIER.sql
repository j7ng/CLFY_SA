CREATE TABLE sa.table_x_carrier (
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
  x_vm_setup_land_line NUMBER,
  carrier2rules_cdma NUMBER,
  carrier2rules_gsm NUMBER,
  carrier2rules_tdma NUMBER,
  x_data_service NUMBER,
  x_automated NUMBER
);
ALTER TABLE sa.table_x_carrier ADD SUPPLEMENTAL LOG GROUP dmtsora229601223_0 (carrier2carrier_group, objid, x_activeline_percent, x_act_analog, x_act_technology, x_bill_date, x_caller_id, x_call_waiting, x_carrier_id, x_city, x_country_code, x_cw_code, x_cw_package, x_digital_feature, x_digital_rate_plan, x_dummy_esn, x_id_code, x_id_package, x_ld_account, x_ld_pic_code, x_ld_provider, x_mkt_submkt_name, x_prl_preloaded, x_rate_plan, x_react_analog, x_react_technology, x_state, x_status, x_submkt_of, x_tapereturn_charge, x_vm_code, x_vm_package, x_voicemail) ALWAYS;
ALTER TABLE sa.table_x_carrier ADD SUPPLEMENTAL LOG GROUP dmtsora229601223_1 (carrier2personality, carrier2provider, carrier2rules, carrier2rules_cdma, carrier2rules_gsm, carrier2rules_tdma, carrier2x_carr_script, tapereturn_addr2address, x_automated, x_carrier2address, x_data_service, x_new_analog_plan, x_new_digital_plan, x_sms, x_sms_code, x_sms_package, x_special_mkt, x_vm_setup_land_line) ALWAYS;
COMMENT ON TABLE sa.table_x_carrier IS 'Stores all the carrier information';
COMMENT ON COLUMN sa.table_x_carrier.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carrier.x_carrier_id IS 'Carrier Market Identification Number';
COMMENT ON COLUMN sa.table_x_carrier.x_mkt_submkt_name IS 'Carrier Market/Submarket Name';
COMMENT ON COLUMN sa.table_x_carrier.x_submkt_of IS 'Shows the carrier market for a submarket';
COMMENT ON COLUMN sa.table_x_carrier.x_city IS 'City where the carrier market/submarket is located';
COMMENT ON COLUMN sa.table_x_carrier.x_state IS 'State where the carrier market/submarket is located';
COMMENT ON COLUMN sa.table_x_carrier.x_tapereturn_charge IS 'Late Fee for Tape Return';
COMMENT ON COLUMN sa.table_x_carrier.x_country_code IS 'Country Code';
COMMENT ON COLUMN sa.table_x_carrier.x_activeline_percent IS 'Percentage of Active Lines';
COMMENT ON COLUMN sa.table_x_carrier.x_status IS 'Carrier Status.  values = ACTIVE or INACTIVE';
COMMENT ON COLUMN sa.table_x_carrier.x_ld_provider IS 'name of long distance provider';
COMMENT ON COLUMN sa.table_x_carrier.x_ld_account IS 'Account number for the LD Provider';
COMMENT ON COLUMN sa.table_x_carrier.x_ld_pic_code IS 'name of long distance provider that Carrier requires or pic code';
COMMENT ON COLUMN sa.table_x_carrier.x_rate_plan IS 'Rate plan used by the Carrier for interface';
COMMENT ON COLUMN sa.table_x_carrier.x_dummy_esn IS 'Dummy ESN used by the Carrier for the online system';
COMMENT ON COLUMN sa.table_x_carrier.x_bill_date IS 'Billing date for carrier';
COMMENT ON COLUMN sa.table_x_carrier.x_voicemail IS 'Voicemail feature available';
COMMENT ON COLUMN sa.table_x_carrier.x_vm_code IS 'Voicemail package or code';
COMMENT ON COLUMN sa.table_x_carrier.x_vm_package IS 'Voicemail is part of package';
COMMENT ON COLUMN sa.table_x_carrier.x_caller_id IS 'Caller ID feature available';
COMMENT ON COLUMN sa.table_x_carrier.x_id_code IS 'Caller id package or code';
COMMENT ON COLUMN sa.table_x_carrier.x_id_package IS 'Caller id is part of package';
COMMENT ON COLUMN sa.table_x_carrier.x_call_waiting IS 'Caller ID feature available';
COMMENT ON COLUMN sa.table_x_carrier.x_cw_code IS 'Call waiting package or code';
COMMENT ON COLUMN sa.table_x_carrier.x_cw_package IS 'Call waiting is part of package';
COMMENT ON COLUMN sa.table_x_carrier.x_react_technology IS 'Technology TDMA or CDMA for reactivation';
COMMENT ON COLUMN sa.table_x_carrier.x_react_analog IS 'Analog flag for reactivation';
COMMENT ON COLUMN sa.table_x_carrier.x_act_technology IS 'Technology TDMA or CDMA for activation';
COMMENT ON COLUMN sa.table_x_carrier.x_act_analog IS 'Analog flag for activation';
COMMENT ON COLUMN sa.table_x_carrier.x_digital_rate_plan IS 'Digital rate plan';
COMMENT ON COLUMN sa.table_x_carrier.x_digital_feature IS 'Digital feature code';
COMMENT ON COLUMN sa.table_x_carrier.x_prl_preloaded IS '1 0r 0. Tells if the PRL was preloaded in the phone by the manufuacturer. 1 = Yes, 0 = No';
COMMENT ON COLUMN sa.table_x_carrier.carrier2carrier_group IS 'Group to  which the carrier belongs';
COMMENT ON COLUMN sa.table_x_carrier.tapereturn_addr2address IS 'Address where the tape is returned';
COMMENT ON COLUMN sa.table_x_carrier.carrier2provider IS ' Long Distance Provider for the Carrier';
COMMENT ON COLUMN sa.table_x_carrier.x_carrier2address IS 'Address for the Carrier';
COMMENT ON COLUMN sa.table_x_carrier.carrier2personality IS ' Group containing the Carrier';
COMMENT ON COLUMN sa.table_x_carrier.carrier2rules IS 'Rules for the Carriers';
COMMENT ON COLUMN sa.table_x_carrier.carrier2x_carr_script IS 'Scripts related to carrier';
COMMENT ON COLUMN sa.table_x_carrier.x_special_mkt IS 'Flag to determine if mkt is special - 0 = Tracfone, 1 = Amigo';
COMMENT ON COLUMN sa.table_x_carrier.x_new_analog_plan IS 'Dual Rate New Analog Plan';
COMMENT ON COLUMN sa.table_x_carrier.x_new_digital_plan IS 'Dual Rate New Digital Plan';
COMMENT ON COLUMN sa.table_x_carrier.x_sms IS 'SMS feature available';
COMMENT ON COLUMN sa.table_x_carrier.x_sms_code IS 'SMS package or code';
COMMENT ON COLUMN sa.table_x_carrier.x_sms_package IS 'SMS is part of package';
COMMENT ON COLUMN sa.table_x_carrier.x_vm_setup_land_line IS 'Check box to determine if carrier allows setup the voice mail via land line';
COMMENT ON COLUMN sa.table_x_carrier.carrier2rules_cdma IS 'CDMA rules for the carrier';
COMMENT ON COLUMN sa.table_x_carrier.carrier2rules_gsm IS 'GSM rules for the carrier';
COMMENT ON COLUMN sa.table_x_carrier.carrier2rules_tdma IS 'TDMA rules for the carriers';
COMMENT ON COLUMN sa.table_x_carrier.x_data_service IS 'Carrier provides data service 0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_carrier.x_automated IS 'Carrier has automated activations 0 = No, 1 = Yes';