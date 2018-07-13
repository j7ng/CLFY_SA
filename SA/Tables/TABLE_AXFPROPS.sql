CREATE TABLE sa.table_axfprops (
  objid NUMBER,
  friendly_name VARCHAR2(30 BYTE),
  "PATH" VARCHAR2(255 BYTE),
  dev NUMBER,
  addnl_info VARCHAR2(255 BYTE),
  axfprops2xfilter NUMBER
);
ALTER TABLE sa.table_axfprops ADD SUPPLEMENTAL LOG GROUP dmtsora399618704_0 (addnl_info, axfprops2xfilter, dev, friendly_name, objid, "PATH") ALWAYS;