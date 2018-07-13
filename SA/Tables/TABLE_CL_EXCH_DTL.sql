CREATE TABLE sa.table_cl_exch_dtl (
  objid NUMBER,
  dev NUMBER,
  activity_type NUMBER,
  non_bill_time NUMBER,
  bill_time NUMBER,
  total_time NUMBER,
  close_dtl2close_exch NUMBER
);
ALTER TABLE sa.table_cl_exch_dtl ADD SUPPLEMENTAL LOG GROUP dmtsora632957159_0 (activity_type, bill_time, close_dtl2close_exch, dev, non_bill_time, objid, total_time) ALWAYS;