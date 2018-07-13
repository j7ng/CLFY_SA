CREATE TABLE sa.table_cmcn_email (
  objid NUMBER,
  dev NUMBER,
  message_id VARCHAR2(255 BYTE),
  time_stamp VARCHAR2(80 BYTE),
  "TEXT" LONG,
  cmcn_email2communication NUMBER
);
ALTER TABLE sa.table_cmcn_email ADD SUPPLEMENTAL LOG GROUP dmtsora2007717983_0 (cmcn_email2communication, dev, message_id, objid, time_stamp) ALWAYS;