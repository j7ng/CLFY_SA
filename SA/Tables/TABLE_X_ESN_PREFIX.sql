CREATE TABLE sa.table_x_esn_prefix (
  objid NUMBER,
  x_prefix VARCHAR2(10 BYTE)
);
ALTER TABLE sa.table_x_esn_prefix ADD SUPPLEMENTAL LOG GROUP dmtsora1842616107_0 (objid, x_prefix) ALWAYS;