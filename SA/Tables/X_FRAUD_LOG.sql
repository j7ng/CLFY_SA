CREATE TABLE sa.x_fraud_log (
  esn VARCHAR2(30 BYTE),
  creation_time DATE,
  contact_objid NUMBER,
  case_id VARCHAR2(255 BYTE),
  agent_login VARCHAR2(30 BYTE),
  fraud_notes LONG
);
ALTER TABLE sa.x_fraud_log ADD SUPPLEMENTAL LOG GROUP dmtsora862465277_0 (agent_login, case_id, contact_objid, creation_time, esn) ALWAYS;