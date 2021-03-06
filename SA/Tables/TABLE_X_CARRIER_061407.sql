CREATE TABLE sa.table_x_carrier_061407 (
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
  x_rate_plan VARCHAR2(30 BYTE),
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
  x_digital_rate_plan VARCHAR2(30 BYTE),
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