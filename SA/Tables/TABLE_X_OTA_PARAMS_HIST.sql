CREATE TABLE sa.table_x_ota_params_hist (
  objid NUMBER,
  x_source_system VARCHAR2(20 BYTE),
  x_redm_enabled VARCHAR2(10 BYTE),
  x_act_enabled VARCHAR2(10 BYTE),
  x_react_enabled VARCHAR2(10 BYTE),
  x_mo_enabled VARCHAR2(10 BYTE),
  x_mt_enabled VARCHAR2(10 BYTE),
  x_message_response VARCHAR2(255 BYTE),
  x_start_date DATE,
  x_last_update_date DATE,
  x_end_date DATE,
  x_action_type VARCHAR2(60 BYTE),
  x_enabled VARCHAR2(10 BYTE),
  x_msg_response VARCHAR2(100 BYTE),
  x_transaction_type VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_ota_params_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1491948990_0 (objid, x_action_type, x_act_enabled, x_enabled, x_end_date, x_last_update_date, x_message_response, x_mo_enabled, x_msg_response, x_mt_enabled, x_react_enabled, x_redm_enabled, x_source_system, x_start_date, x_transaction_type) ALWAYS;