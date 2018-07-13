CREATE TABLE sa.table_config_itm (
  objid NUMBER,
  last_mod_time DATE,
  "NAME" VARCHAR2(32 BYTE),
  value_type NUMBER,
  i_value NUMBER,
  f_value NUMBER,
  str_value VARCHAR2(255 BYTE),
  "SCOPE" NUMBER,
  description VARCHAR2(255 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_config_itm ADD SUPPLEMENTAL LOG GROUP dmtsora721478761_0 (description, dev, f_value, i_value, last_mod_time, "NAME", objid, "SCOPE", str_value, value_type) ALWAYS;