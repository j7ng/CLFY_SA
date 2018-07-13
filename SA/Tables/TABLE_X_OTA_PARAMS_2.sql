CREATE TABLE sa.table_x_ota_params_2 (
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
  x_ba_promo_on VARCHAR2(10 BYTE),
  x_sim_req VARCHAR2(10 BYTE),
  ota_param2bus_org NUMBER
);
COMMENT ON TABLE sa.table_x_ota_params_2 IS 'OTA Application Parameters by Brand and Channel, replaces table_x_ota_params';
COMMENT ON COLUMN sa.table_x_ota_params_2.objid IS 'Internal Record ID';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_source_system IS 'Source System';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_message_response IS 'not used';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_start_date IS 'Start Date';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_redm_enabled IS 'OTA Enabled for Redemption';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_act_enabled IS 'OTA Enabled for Activation';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_react_enabled IS 'OTA Enable for Reactivation';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_mo_enabled IS 'OTA Enable for Mobile Originated';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_mt_enabled IS 'OTA Enable for Mobile Terminated';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_refill_training IS 'Refill Training Flag';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_refill_count IS 'Refill Training Max Count';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_ild_counter IS 'ILD Counter';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_max_feature_count IS 'Max Feature Count';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_buy_airtime_enabled IS 'Buy Airtime Enabled';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_ba_pin_required IS 'Buy Airtime Pin Required Flag';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_ba_promo_on IS 'Buy Airtime Promo On Flag';
COMMENT ON COLUMN sa.table_x_ota_params_2.x_sim_req IS 'SIM Required Flag';
COMMENT ON COLUMN sa.table_x_ota_params_2.ota_param2bus_org IS 'Reference to objid in table_bus_org';