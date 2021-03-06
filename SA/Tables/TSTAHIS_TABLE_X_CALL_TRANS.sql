CREATE TABLE sa.tstahis_table_x_call_trans (
  objid NUMBER,
  call_trans2site_part NUMBER,
  x_action_type VARCHAR2(20 BYTE),
  x_call_trans2carrier NUMBER,
  x_call_trans2dealer NUMBER,
  x_call_trans2user NUMBER,
  x_line_status VARCHAR2(20 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_service_id VARCHAR2(30 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_transact_date DATE,
  x_total_units NUMBER,
  x_action_text VARCHAR2(20 BYTE),
  x_reason VARCHAR2(500 BYTE),
  x_result VARCHAR2(20 BYTE),
  x_sub_sourcesystem VARCHAR2(30 BYTE),
  x_iccid VARCHAR2(30 BYTE),
  x_ota_req_type VARCHAR2(30 BYTE),
  x_ota_type VARCHAR2(30 BYTE),
  x_call_trans2x_ota_code_hist NUMBER,
  x_new_due_date DATE,
  update_stamp DATE,
  x_call_trans_hist2x_call_trans NUMBER,
  x_call_trans_his2user VARCHAR2(30 BYTE),
  x_change_date DATE,
  osuser VARCHAR2(30 BYTE),
  triggering_record_type VARCHAR2(6 BYTE)
);