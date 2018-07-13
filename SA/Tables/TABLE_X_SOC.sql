CREATE TABLE sa.table_x_soc (
  objid NUMBER,
  x_soc_id VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_soc ADD SUPPLEMENTAL LOG GROUP dmtsora1024599856_0 (objid, x_soc_id) ALWAYS;
COMMENT ON TABLE sa.table_x_soc IS 'Contains the system operator codes';
COMMENT ON COLUMN sa.table_x_soc.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_soc.x_soc_id IS 'SOC';