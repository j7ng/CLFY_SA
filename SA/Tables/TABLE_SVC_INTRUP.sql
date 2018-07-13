CREATE TABLE sa.table_svc_intrup (
  objid NUMBER,
  start_time DATE,
  stop_time DATE,
  dev NUMBER,
  svc_intrup2act_entry NUMBER(*,0),
  cust_hold_info2case NUMBER(*,0)
);
ALTER TABLE sa.table_svc_intrup ADD SUPPLEMENTAL LOG GROUP dmtsora1780398842_0 (cust_hold_info2case, dev, objid, start_time, stop_time, svc_intrup2act_entry) ALWAYS;