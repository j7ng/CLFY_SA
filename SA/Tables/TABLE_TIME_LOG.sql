CREATE TABLE sa.table_time_log (
  objid NUMBER,
  time_type VARCHAR2(30 BYTE),
  start_time DATE,
  duration NUMBER,
  billable NUMBER,
  bill_to VARCHAR2(30 BYTE),
  removed NUMBER,
  wrk_center VARCHAR2(40 BYTE),
  rate NUMBER,
  dev NUMBER,
  time2onsite_log NUMBER(*,0)
);
ALTER TABLE sa.table_time_log ADD SUPPLEMENTAL LOG GROUP dmtsora1722090896_0 (billable, bill_to, dev, duration, objid, rate, removed, start_time, time2onsite_log, time_type, wrk_center) ALWAYS;