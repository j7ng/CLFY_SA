CREATE TABLE sa.table_x79activity (
  objid NUMBER,
  dev NUMBER,
  action_info LONG,
  act_code NUMBER,
  act_name VARCHAR2(80 BYTE),
  s_act_name VARCHAR2(80 BYTE),
  act_date DATE,
  reason_code NUMBER,
  reason_name VARCHAR2(80 BYTE),
  s_reason_name VARCHAR2(80 BYTE),
  server_id NUMBER,
  error_code NUMBER,
  act2x79person NUMBER,
  act2x79provider_tr NUMBER,
  act2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79activity ADD SUPPLEMENTAL LOG GROUP dmtsora1700466538_0 (act2x79person, act2x79provider_tr, act2x79telcom_tr, act_code, act_date, act_name, dev, error_code, objid, reason_code, reason_name, server_id, s_act_name, s_reason_name) ALWAYS;