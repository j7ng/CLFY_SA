CREATE TABLE sa.table_x_posa (
  site_id VARCHAR2(80 BYTE)
);
ALTER TABLE sa.table_x_posa ADD SUPPLEMENTAL LOG GROUP dmtsora888504518_0 (site_id) ALWAYS;