CREATE TABLE sa.table_gl_sum_log (
  objid NUMBER,
  "PERIOD" VARCHAR2(20 BYTE),
  start_trans VARCHAR2(20 BYTE),
  start_trans_dt DATE,
  end_trans VARCHAR2(20 BYTE),
  end_trans_dt DATE,
  run_date DATE,
  trans_count NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_gl_sum_log ADD SUPPLEMENTAL LOG GROUP dmtsora738216773_0 (dev, end_trans, end_trans_dt, objid, "PERIOD", run_date, start_trans, start_trans_dt, trans_count) ALWAYS;