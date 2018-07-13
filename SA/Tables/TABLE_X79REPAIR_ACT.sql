CREATE TABLE sa.table_x79repair_act (
  objid NUMBER,
  dev NUMBER,
  entry_time VARCHAR2(30 BYTE),
  activity_info VARCHAR2(255 BYTE),
  s_activity_info VARCHAR2(255 BYTE),
  activity_code NUMBER,
  server_id NUMBER,
  act_cd_ind NUMBER,
  repair_act2x79person NUMBER,
  repair_act2x79telcom_tr NUMBER,
  p_rpr2x79provider_tr NUMBER
);
ALTER TABLE sa.table_x79repair_act ADD SUPPLEMENTAL LOG GROUP dmtsora1336122900_0 (activity_code, activity_info, act_cd_ind, dev, entry_time, objid, p_rpr2x79provider_tr, repair_act2x79person, repair_act2x79telcom_tr, server_id, s_activity_info) ALWAYS;