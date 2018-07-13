CREATE TABLE sa.table_gl_summary (
  objid NUMBER,
  credit_amt NUMBER(19,4),
  debit_amt NUMBER(19,4),
  dev NUMBER,
  gl_summary2gl_sum_log NUMBER(*,0),
  fm_summary2inv_locatn NUMBER(*,0),
  to_summary2inv_locatn NUMBER(*,0)
);
ALTER TABLE sa.table_gl_summary ADD SUPPLEMENTAL LOG GROUP dmtsora1887154347_0 (credit_amt, debit_amt, dev, fm_summary2inv_locatn, gl_summary2gl_sum_log, objid, to_summary2inv_locatn) ALWAYS;