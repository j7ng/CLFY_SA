CREATE TABLE sa.table_trnd_rslt (
  objid NUMBER,
  time_stamp DATE,
  rslt_query_1 NUMBER,
  rslt_query_2 NUMBER,
  rslt_query_3 NUMBER,
  rslt_query_4 NUMBER,
  rslt_query_5 NUMBER,
  rslt_query_6 NUMBER,
  rslt_query_7 NUMBER,
  rslt_query_8 NUMBER,
  rslt_query_9 NUMBER,
  rslt_query_10 NUMBER,
  rslt_query_11 NUMBER,
  rslt_query_12 NUMBER,
  dev NUMBER,
  trnd_rslt2trnd_inst NUMBER(*,0)
);
ALTER TABLE sa.table_trnd_rslt ADD SUPPLEMENTAL LOG GROUP dmtsora1442757142_0 (dev, objid, rslt_query_1, rslt_query_10, rslt_query_11, rslt_query_12, rslt_query_2, rslt_query_3, rslt_query_4, rslt_query_5, rslt_query_6, rslt_query_7, rslt_query_8, rslt_query_9, time_stamp, trnd_rslt2trnd_inst) ALWAYS;