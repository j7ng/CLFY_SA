CREATE TABLE sa.table_mod_display (
  objid NUMBER,
  mod_level VARCHAR2(10 BYTE),
  "ACTIVE" VARCHAR2(10 BYTE),
  replace_date DATE,
  replace_by_date DATE,
  replace_mod VARCHAR2(10 BYTE),
  replace_by_mod VARCHAR2(10 BYTE),
  replace_pn VARCHAR2(30 BYTE),
  replace_by_pn VARCHAR2(30 BYTE),
  replace_by_des VARCHAR2(255 BYTE),
  replace_by_act VARCHAR2(20 BYTE),
  replace_desc VARCHAR2(255 BYTE),
  replace_active VARCHAR2(20 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_mod_display ADD SUPPLEMENTAL LOG GROUP dmtsora1489031653_0 ("ACTIVE", dev, mod_level, objid, replace_active, replace_by_act, replace_by_date, replace_by_des, replace_by_mod, replace_by_pn, replace_date, replace_desc, replace_mod, replace_pn) ALWAYS;