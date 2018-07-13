CREATE TABLE sa.table_x_ota_features (
  objid NUMBER,
  dev NUMBER,
  x_redemption_menu VARCHAR2(30 BYTE),
  x_handset_lock VARCHAR2(30 BYTE),
  x_low_units VARCHAR2(30 BYTE),
  x_ota_features2part_num NUMBER,
  x_ota_features2part_inst NUMBER,
  x_psms_destination_addr VARCHAR2(30 BYTE),
  x_ild_account VARCHAR2(30 BYTE),
  x_ild_carr_status VARCHAR2(30 BYTE),
  x_ild_prog_status VARCHAR2(30 BYTE),
  x_ild_counter NUMBER,
  x_close_count NUMBER,
  x_current_conv_rate NUMBER(19,4),
  x_spp_pin_on VARCHAR2(30 BYTE),
  x_buy_airtime_menu VARCHAR2(30 BYTE),
  x_spp_promo_code VARCHAR2(30 BYTE),
  current_config2x_data_config NUMBER,
  new_config2x_data_config NUMBER,
  x_data_config_prog_counter NUMBER,
  x_411_number VARCHAR2(30 BYTE),
  x_multicall_flag VARCHAR2(1 BYTE),
  x_motricity_deno NUMBER,
  x_611_clicks NUMBER,
  x_free_dial VARCHAR2(20 BYTE),
  x_ild_plus VARCHAR2(5 BYTE)
);
ALTER TABLE sa.table_x_ota_features ADD SUPPLEMENTAL LOG GROUP dmtsora1693590998_0 (current_config2x_data_config, dev, new_config2x_data_config, objid, x_buy_airtime_menu, x_close_count, x_current_conv_rate, x_data_config_prog_counter, x_handset_lock, x_ild_account, x_ild_carr_status, x_ild_counter, x_ild_prog_status, x_low_units, x_ota_features2part_inst, x_ota_features2part_num, x_psms_destination_addr, x_redemption_menu, x_spp_pin_on, x_spp_promo_code) ALWAYS;
COMMENT ON TABLE sa.table_x_ota_features IS 'Features that can be activated on a Handset for OTA';
COMMENT ON COLUMN sa.table_x_ota_features.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ota_features.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ota_features.x_redemption_menu IS 'Menu to Activate Redemption Menu in Handset';
COMMENT ON COLUMN sa.table_x_ota_features.x_handset_lock IS 'To Lock the Handset Menu';
COMMENT ON COLUMN sa.table_x_ota_features.x_low_units IS 'To validate Units in the Handset';
COMMENT ON COLUMN sa.table_x_ota_features.x_ota_features2part_num IS 'OTA features for a part number';
COMMENT ON COLUMN sa.table_x_ota_features.x_ota_features2part_inst IS 'OTA Features for the ESN';
COMMENT ON COLUMN sa.table_x_ota_features.x_psms_destination_addr IS 'To determine if MOPSMS destination address has been set or not';
COMMENT ON COLUMN sa.table_x_ota_features.x_ild_account IS 'TBD';
COMMENT ON COLUMN sa.table_x_ota_features.x_ild_carr_status IS 'ILD Carrier Status, Inactive, Active';
COMMENT ON COLUMN sa.table_x_ota_features.x_ild_prog_status IS 'ILD Programming Status: Pending, In Queue, Completed';
COMMENT ON COLUMN sa.table_x_ota_features.x_ild_counter IS 'Number of times the ILD invitation has been sent';
COMMENT ON COLUMN sa.table_x_ota_features.x_close_count IS 'ota transactions closed by other channel';
COMMENT ON COLUMN sa.table_x_ota_features.x_current_conv_rate IS 'Number of units equivalent to 1 dollar for a given phone';
COMMENT ON COLUMN sa.table_x_ota_features.x_spp_pin_on IS 'Flag  Active/Inactive  PIN ';
COMMENT ON COLUMN sa.table_x_ota_features.x_buy_airtime_menu IS 'Phone personal Identification Number';
COMMENT ON COLUMN sa.table_x_ota_features.x_spp_promo_code IS 'To validate Promo Code';
COMMENT ON COLUMN sa.table_x_ota_features.x_free_dial IS 'ACTUAL NUMBER THAT IS PROGRAMMED AS FREE IN THE CUSTOMER HANDSET';