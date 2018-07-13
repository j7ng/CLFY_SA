CREATE TABLE sa.table_x79act_dur (
  objid NUMBER,
  dev NUMBER,
  activity_type NUMBER,
  billable NUMBER,
  duration NUMBER,
  server_id NUMBER,
  dur2x79telcom_tr NUMBER
);
ALTER TABLE sa.table_x79act_dur ADD SUPPLEMENTAL LOG GROUP dmtsora1440946982_0 (activity_type, billable, dev, dur2x79telcom_tr, duration, objid, server_id) ALWAYS;