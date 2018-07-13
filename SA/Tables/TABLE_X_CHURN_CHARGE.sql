CREATE TABLE sa.table_x_churn_charge (
  objid NUMBER,
  churn_charge2carrier NUMBER,
  x_charge_per_deact NUMBER(6,2),
  x_churn_excess NUMBER(6,2),
  x_excess_charge NUMBER(6,2),
  x_timeperiod NUMBER
);
ALTER TABLE sa.table_x_churn_charge ADD SUPPLEMENTAL LOG GROUP dmtsora681207393_0 (churn_charge2carrier, objid, x_charge_per_deact, x_churn_excess, x_excess_charge, x_timeperiod) ALWAYS;