CREATE TABLE sa.table_work_hr (
  objid NUMBER,
  start_time NUMBER,
  end_time NUMBER,
  dev NUMBER,
  work_hr2wk_work_hr NUMBER(*,0),
  x_transmethod VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_work_hr ADD SUPPLEMENTAL LOG GROUP dmtsora604755882_0 (dev, end_time, objid, start_time, work_hr2wk_work_hr, x_transmethod) ALWAYS;