CREATE TABLE sa.table_x_ota_paramsbak (
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
  x_buy_airtime_enabled VARCHAR2(10 BYTE),
  x_ba_pin_required VARCHAR2(10 BYTE),
  x_ba_promo_on VARCHAR2(10 BYTE)
);
ALTER TABLE sa.table_x_ota_paramsbak ADD SUPPLEMENTAL LOG GROUP dmtsora845913291_0 (objid, x_act_enabled, x_ba_pin_required, x_ba_promo_on, x_buy_airtime_enabled, x_ild_counter, x_max_feature_count, x_message_response, x_mo_enabled, x_mt_enabled, x_react_enabled, x_redm_enabled, x_refill_count, x_refill_training, x_source_system, x_start_date) ALWAYS;