CREATE TABLE sa.table_agent (
  objid NUMBER,
  dev NUMBER,
  agent_id VARCHAR2(30 BYTE),
  "PASSWORD" VARCHAR2(30 BYTE),
  equip_id VARCHAR2(30 BYTE),
  acd_queue VARCHAR2(30 BYTE),
  agent2user NUMBER,
  agent2acd NUMBER
);
ALTER TABLE sa.table_agent ADD SUPPLEMENTAL LOG GROUP dmtsora1750590793_0 (acd_queue, agent2acd, agent2user, agent_id, dev, equip_id, objid, "PASSWORD") ALWAYS;