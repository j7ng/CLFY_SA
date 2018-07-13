CREATE TABLE sa.table_n_breakpoints (
  objid NUMBER,
  dev NUMBER,
  n_lineno NUMBER,
  n_brkpnt2n_functions NUMBER,
  n_brkpnt2user NUMBER
);
ALTER TABLE sa.table_n_breakpoints ADD SUPPLEMENTAL LOG GROUP dmtsora1553080778_0 (dev, n_brkpnt2n_functions, n_brkpnt2user, n_lineno, objid) ALWAYS;