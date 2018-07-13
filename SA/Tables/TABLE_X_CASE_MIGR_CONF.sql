CREATE TABLE sa.table_x_case_migr_conf (
  objid NUMBER,
  dev NUMBER,
  x_status VARCHAR2(80 BYTE),
  x_active NUMBER,
  x_wait NUMBER,
  x_action VARCHAR2(50 BYTE),
  migr2conf_hdr NUMBER
);
ALTER TABLE sa.table_x_case_migr_conf ADD SUPPLEMENTAL LOG GROUP dmtsora320871_0 (dev, migr2conf_hdr, objid, x_action, x_active, x_status, x_wait) ALWAYS;