CREATE TABLE sa.table_csc_activity (
  objid NUMBER,
  action_info LONG,
  act_code NUMBER,
  csc_date DATE,
  act_name VARCHAR2(80 BYTE),
  reason_code NUMBER,
  reason_name VARCHAR2(80 BYTE),
  server_id NUMBER,
  parm_lst VARCHAR2(255 BYTE),
  dev NUMBER,
  activity2csc_incident NUMBER(*,0),
  csc_entry2gbst_elm NUMBER(*,0),
  activity2csc_resource NUMBER(*,0),
  activity2csc_contact NUMBER(*,0)
);
ALTER TABLE sa.table_csc_activity ADD SUPPLEMENTAL LOG GROUP dmtsora200677596_0 (activity2csc_contact, activity2csc_incident, activity2csc_resource, act_code, act_name, csc_date, csc_entry2gbst_elm, dev, objid, parm_lst, reason_code, reason_name, server_id) ALWAYS;