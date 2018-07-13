CREATE TABLE sa.table_bill_itm (
  objid NUMBER,
  start_dt DATE,
  event_type NUMBER,
  calc_type NUMBER,
  bill_event VARCHAR2(40 BYTE),
  calc_value NUMBER(19,4),
  calc_type_str VARCHAR2(40 BYTE),
  event_type_str VARCHAR2(40 BYTE),
  dev NUMBER,
  bill_itm2contr_schedule NUMBER(*,0)
);
ALTER TABLE sa.table_bill_itm ADD SUPPLEMENTAL LOG GROUP dmtsora1541138372_0 (bill_event, bill_itm2contr_schedule, calc_type, calc_type_str, calc_value, dev, event_type, event_type_str, objid, start_dt) ALWAYS;