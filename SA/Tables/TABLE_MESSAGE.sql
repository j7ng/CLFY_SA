CREATE TABLE sa.table_message (
  objid NUMBER,
  user_name VARCHAR2(50 BYTE),
  "ACTION" NUMBER,
  message VARCHAR2(255 BYTE),
  number_fails NUMBER,
  arrive_time DATE,
  dev NUMBER
);
ALTER TABLE sa.table_message ADD SUPPLEMENTAL LOG GROUP dmtsora866315022_0 ("ACTION", arrive_time, dev, message, number_fails, objid, user_name) ALWAYS;