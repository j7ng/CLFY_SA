CREATE TABLE sa.table_n_watches (
  objid NUMBER,
  dev NUMBER,
  n_expression LONG,
  n_wtch2n_functions NUMBER,
  n_wtch2user NUMBER
);
ALTER TABLE sa.table_n_watches ADD SUPPLEMENTAL LOG GROUP dmtsora390984150_0 (dev, n_wtch2n_functions, n_wtch2user, objid) ALWAYS;