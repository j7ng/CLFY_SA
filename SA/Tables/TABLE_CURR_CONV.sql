CREATE TABLE sa.table_curr_conv (
  objid NUMBER,
  start_date DATE,
  rate NUMBER,
  dev NUMBER,
  fm_curr2currency NUMBER(*,0),
  to_curr2currency NUMBER(*,0)
);
ALTER TABLE sa.table_curr_conv ADD SUPPLEMENTAL LOG GROUP dmtsora167383958_0 (dev, fm_curr2currency, objid, rate, start_date, to_curr2currency) ALWAYS;