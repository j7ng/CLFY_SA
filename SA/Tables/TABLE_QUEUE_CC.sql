CREATE TABLE sa.table_queue_cc (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  resp_time NUMBER,
  dev NUMBER,
  queue_cc2employee NUMBER(*,0),
  queue_cc2queue NUMBER(*,0)
);
ALTER TABLE sa.table_queue_cc ADD SUPPLEMENTAL LOG GROUP dmtsora943737609_0 (dev, objid, queue_cc2employee, queue_cc2queue, resp_time, title) ALWAYS;