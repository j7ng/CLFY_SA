CREATE TABLE sa.x_cbo_trans_log_1215 (
  objid NUMBER,
  x_transact_date DATE,
  x_bus_line VARCHAR2(30 BYTE),
  x_source_system VARCHAR2(30 BYTE),
  x_action_type VARCHAR2(20 BYTE),
  x_esn_imei VARCHAR2(30 BYTE),
  x_result VARCHAR2(30 BYTE),
  x_servername VARCHAR2(40 BYTE),
  x_session_id VARCHAR2(100 BYTE),
  x_tealeaf_id VARCHAR2(100 BYTE),
  x_source_jsp VARCHAR2(100 BYTE),
  x_source_cbo VARCHAR2(100 BYTE),
  x_cbo_trans2call_trans NUMBER,
  x_cbo_method VARCHAR2(50 BYTE),
  x_result_num VARCHAR2(10 BYTE),
  x_result_string VARCHAR2(300 BYTE),
  x_action VARCHAR2(30 BYTE),
  x_esn_status VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_cbo_trans_log_1215 ADD SUPPLEMENTAL LOG GROUP dmtsora1190709750_0 (objid, x_action, x_action_type, x_bus_line, x_cbo_method, x_cbo_trans2call_trans, x_esn_imei, x_esn_status, x_result, x_result_num, x_result_string, x_servername, x_session_id, x_source_cbo, x_source_jsp, x_source_system, x_tealeaf_id, x_transact_date) ALWAYS;