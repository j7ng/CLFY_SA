CREATE TABLE sa.x_ota_params_aud (
  objid NUMBER,
  x_source_system VARCHAR2(20 BYTE),
  x_message_response VARCHAR2(255 BYTE),
  x_start_date DATE,
  x_redm_enabled VARCHAR2(10 BYTE),
  x_act_enabled VARCHAR2(10 BYTE),
  x_react_enabled VARCHAR2(10 BYTE),
  x_mo_enabled VARCHAR2(10 BYTE),
  x_mt_enabled VARCHAR2(10 BYTE),
  x_refill_training VARCHAR2(10 BYTE),
  x_refill_count NUMBER,
  x_ild_counter NUMBER,
  x_max_feature_count NUMBER,
  change_type CHAR,
  change_date DATE,
  x_buy_airtime_enabled VARCHAR2(10 BYTE),
  x_ba_pin_required VARCHAR2(10 BYTE),
  x_ba_promo_on VARCHAR2(10 BYTE),
  x_sim_req VARCHAR2(10 BYTE),
  ota_param2bus_org NUMBER
);
ALTER TABLE sa.x_ota_params_aud ADD SUPPLEMENTAL LOG GROUP dmtsora416253018_0 (change_date, change_type, objid, x_act_enabled, x_ba_pin_required, x_ba_promo_on, x_buy_airtime_enabled, x_ild_counter, x_max_feature_count, x_message_response, x_mo_enabled, x_mt_enabled, x_react_enabled, x_redm_enabled, x_refill_count, x_refill_training, x_sim_req, x_source_system, x_start_date) ALWAYS;