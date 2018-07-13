CREATE TABLE sa.table_x_trans_profile (
  objid NUMBER,
  x_transmit_method VARCHAR2(20 BYTE),
  x_exception NUMBER,
  x_fax_number VARCHAR2(30 BYTE),
  x_online_number VARCHAR2(45 BYTE),
  x_network_login VARCHAR2(30 BYTE),
  x_network_password VARCHAR2(30 BYTE),
  x_system_login VARCHAR2(30 BYTE),
  x_system_password VARCHAR2(30 BYTE),
  x_template VARCHAR2(80 BYTE),
  x_email VARCHAR2(45 BYTE),
  x_profile_name VARCHAR2(30 BYTE),
  x_default_queue VARCHAR2(30 BYTE),
  x_carrier_phone VARCHAR2(30 BYTE),
  x_exception_queue VARCHAR2(30 BYTE),
  x_batch_quantity VARCHAR2(5 BYTE),
  x_batch_delay_max VARCHAR2(10 BYTE),
  x_transmit_template VARCHAR2(30 BYTE),
  x_online_num2 VARCHAR2(30 BYTE),
  x_fax_num2 VARCHAR2(30 BYTE),
  x_description VARCHAR2(200 BYTE),
  x_trans_profile2wk_work_hr NUMBER,
  x_trans_exception2wk_work_hr NUMBER,
  x_ici_system VARCHAR2(30 BYTE),
  x_analog_deact VARCHAR2(30 BYTE),
  x_analog_rework VARCHAR2(30 BYTE),
  x_d_batch_delay_max VARCHAR2(10 BYTE),
  x_d_batch_quantity VARCHAR2(5 BYTE),
  x_d_carrier_phone VARCHAR2(30 BYTE),
  x_d_email VARCHAR2(45 BYTE),
  x_d_fax_num2 VARCHAR2(30 BYTE),
  x_d_fax_number VARCHAR2(30 BYTE),
  x_d_ici_system VARCHAR2(30 BYTE),
  x_d_network_login VARCHAR2(30 BYTE),
  x_d_network_password VARCHAR2(30 BYTE),
  x_d_online_num2 VARCHAR2(30 BYTE),
  x_d_online_number VARCHAR2(45 BYTE),
  x_d_system_login VARCHAR2(30 BYTE),
  x_d_system_password VARCHAR2(30 BYTE),
  x_d_template VARCHAR2(80 BYTE),
  x_d_trans_template VARCHAR2(30 BYTE),
  x_d_transmit_method VARCHAR2(20 BYTE),
  x_digital_act VARCHAR2(30 BYTE),
  x_digital_deact VARCHAR2(30 BYTE),
  x_digital_rework VARCHAR2(30 BYTE),
  x_upgrade VARCHAR2(30 BYTE),
  d_trans_profile2wk_work_hr NUMBER,
  x_gsm_act VARCHAR2(30 BYTE),
  x_gsm_batch_delay_max VARCHAR2(10 BYTE),
  x_gsm_batch_quantity VARCHAR2(5 BYTE),
  x_gsm_carrier_phone VARCHAR2(30 BYTE),
  x_gsm_deact VARCHAR2(30 BYTE),
  x_gsm_email VARCHAR2(45 BYTE),
  x_gsm_fax_num2 VARCHAR2(30 BYTE),
  x_gsm_fax_number VARCHAR2(30 BYTE),
  x_gsm_ici_system VARCHAR2(30 BYTE),
  x_gsm_network_login VARCHAR2(30 BYTE),
  x_gsm_network_password VARCHAR2(30 BYTE),
  x_gsm_online_num2 VARCHAR2(30 BYTE),
  x_gsm_online_number VARCHAR2(45 BYTE),
  x_gsm_rework VARCHAR2(30 BYTE),
  x_gsm_trans_template VARCHAR2(30 BYTE),
  x_gsm_transmit_method VARCHAR2(20 BYTE),
  x_debug_analog NUMBER,
  x_debug_digital NUMBER,
  x_debug_gsm NUMBER,
  x_sui_analog NUMBER,
  x_sui_digital NUMBER,
  x_sui_gsm NUMBER,
  x_timeout_analog NUMBER,
  x_timeout_digital NUMBER,
  x_timeout_gsm NUMBER,
  x_int_port_in_rework VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_trans_profile ADD SUPPLEMENTAL LOG GROUP dmtsora68844907_0 (objid, x_analog_deact, x_analog_rework, x_batch_delay_max, x_batch_quantity, x_carrier_phone, x_default_queue, x_description, x_d_batch_delay_max, x_d_batch_quantity, x_d_carrier_phone, x_d_email, x_d_fax_num2, x_d_fax_number, x_d_ici_system, x_email, x_exception, x_exception_queue, x_fax_num2, x_fax_number, x_ici_system, x_network_login, x_network_password, x_online_num2, x_online_number, x_profile_name, x_system_login, x_system_password, x_template, x_transmit_method, x_transmit_template, x_trans_exception2wk_work_hr, x_trans_profile2wk_work_hr) ALWAYS;
ALTER TABLE sa.table_x_trans_profile ADD SUPPLEMENTAL LOG GROUP dmtsora68844907_1 (d_trans_profile2wk_work_hr, x_debug_analog, x_debug_digital, x_debug_gsm, x_digital_act, x_digital_deact, x_digital_rework, x_d_network_login, x_d_network_password, x_d_online_num2, x_d_online_number, x_d_system_login, x_d_system_password, x_d_template, x_d_transmit_method, x_d_trans_template, x_gsm_act, x_gsm_batch_delay_max, x_gsm_batch_quantity, x_gsm_carrier_phone, x_gsm_deact, x_gsm_email, x_gsm_fax_num2, x_gsm_fax_number, x_gsm_ici_system, x_gsm_network_login, x_gsm_network_password, x_gsm_online_num2, x_gsm_online_number, x_gsm_rework, x_gsm_transmit_method, x_gsm_trans_template, x_upgrade) ALWAYS;
ALTER TABLE sa.table_x_trans_profile ADD SUPPLEMENTAL LOG GROUP dmtsora68844907_2 (x_int_port_in_rework, x_sui_analog, x_sui_digital, x_sui_gsm, x_timeout_analog, x_timeout_digital, x_timeout_gsm) ALWAYS;
COMMENT ON TABLE sa.table_x_trans_profile IS 'Stores transmission profiles for carrier markets';
COMMENT ON COLUMN sa.table_x_trans_profile.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_trans_profile.x_transmit_method IS 'transmission method';
COMMENT ON COLUMN sa.table_x_trans_profile.x_exception IS 'Exception flag';
COMMENT ON COLUMN sa.table_x_trans_profile.x_fax_number IS 'fax phone number';
COMMENT ON COLUMN sa.table_x_trans_profile.x_online_number IS 'Dial up phone number';
COMMENT ON COLUMN sa.table_x_trans_profile.x_network_login IS 'network login';
COMMENT ON COLUMN sa.table_x_trans_profile.x_network_password IS 'network password';
COMMENT ON COLUMN sa.table_x_trans_profile.x_system_login IS 'system login';
COMMENT ON COLUMN sa.table_x_trans_profile.x_system_password IS 'system password';
COMMENT ON COLUMN sa.table_x_trans_profile.x_template IS 'file path or template name';
COMMENT ON COLUMN sa.table_x_trans_profile.x_email IS 'email address';
COMMENT ON COLUMN sa.table_x_trans_profile.x_profile_name IS 'Name of the profile';
COMMENT ON COLUMN sa.table_x_trans_profile.x_default_queue IS 'Default Queue for Carrier';
COMMENT ON COLUMN sa.table_x_trans_profile.x_carrier_phone IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_exception_queue IS 'Exception Queue for Carrier';
COMMENT ON COLUMN sa.table_x_trans_profile.x_batch_quantity IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_batch_delay_max IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_transmit_template IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_online_num2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_fax_num2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_description IS 'Added for description of trans profile on 7/19/00';
COMMENT ON COLUMN sa.table_x_trans_profile.x_trans_profile2wk_work_hr IS 'Related business calendar';
COMMENT ON COLUMN sa.table_x_trans_profile.x_trans_exception2wk_work_hr IS 'Related business calendar';
COMMENT ON COLUMN sa.table_x_trans_profile.x_ici_system IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_analog_deact IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_analog_rework IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_batch_delay_max IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_batch_quantity IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_carrier_phone IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_email IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_fax_num2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_fax_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_ici_system IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_network_login IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_network_password IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_online_num2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_online_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_system_login IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_system_password IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_template IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_trans_template IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_d_transmit_method IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_digital_act IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_digital_deact IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_digital_rework IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_upgrade IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.d_trans_profile2wk_work_hr IS 'Related transmission profile';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_act IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_batch_delay_max IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_batch_quantity IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_carrier_phone IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_deact IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_email IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_fax_num2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_fax_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_ici_system IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_network_login IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_network_password IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_online_num2 IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_online_number IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_rework IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_trans_template IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_gsm_transmit_method IS 'TBD';
COMMENT ON COLUMN sa.table_x_trans_profile.x_debug_analog IS 'Debug Flow for Analog';
COMMENT ON COLUMN sa.table_x_trans_profile.x_debug_digital IS 'Debug Flow for Digital';
COMMENT ON COLUMN sa.table_x_trans_profile.x_debug_gsm IS 'Debug Flow for GSM';
COMMENT ON COLUMN sa.table_x_trans_profile.x_sui_analog IS 'Single User Interface Flag Analog';
COMMENT ON COLUMN sa.table_x_trans_profile.x_sui_digital IS 'Single User Interface Flag Digital TDMA/CDMA';
COMMENT ON COLUMN sa.table_x_trans_profile.x_sui_gsm IS 'Single User Interface Flag GSM';
COMMENT ON COLUMN sa.table_x_trans_profile.x_timeout_analog IS 'Timeout Limit Analog';
COMMENT ON COLUMN sa.table_x_trans_profile.x_timeout_digital IS 'Timeout Limit Digital TDMA/CDMA';
COMMENT ON COLUMN sa.table_x_trans_profile.x_timeout_gsm IS 'Timeout Limit GSM';
COMMENT ON COLUMN sa.table_x_trans_profile.x_int_port_in_rework IS 'Name of the queue that will hold failed action items';