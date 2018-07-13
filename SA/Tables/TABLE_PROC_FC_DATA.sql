CREATE TABLE sa.table_proc_fc_data (
  objid NUMBER,
  dev NUMBER,
  "NAME" VARCHAR2(50 BYTE),
  description VARCHAR2(50 BYTE),
  "TYPE" NUMBER,
  date_value DATE,
  update_stamp DATE,
  proc_fc_data2proc_forecast NUMBER
);
ALTER TABLE sa.table_proc_fc_data ADD SUPPLEMENTAL LOG GROUP dmtsora1626320825_0 (date_value, description, dev, "NAME", objid, proc_fc_data2proc_forecast, "TYPE", update_stamp) ALWAYS;