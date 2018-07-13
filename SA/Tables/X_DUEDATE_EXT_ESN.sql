CREATE TABLE sa.x_duedate_ext_esn (
  esn VARCHAR2(30 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  old_expy_dt DATE,
  new_expy_dt DATE,
  updt_yn CHAR,
  updt_dt DATE,
  x_bus_org VARCHAR2(25 BYTE),
  x_parent_name VARCHAR2(40 BYTE),
  x_parent_id VARCHAR2(30 BYTE),
  x_technology VARCHAR2(20 BYTE)
);
ALTER TABLE sa.x_duedate_ext_esn ADD SUPPLEMENTAL LOG GROUP dmtsora85131796_0 (esn, "MIN", new_expy_dt, old_expy_dt, updt_dt, updt_yn, x_bus_org, x_parent_id, x_parent_name, x_technology) ALWAYS;