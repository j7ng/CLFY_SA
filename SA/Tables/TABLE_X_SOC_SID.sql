CREATE TABLE sa.table_x_soc_sid (
  objid NUMBER,
  x_sid VARCHAR2(30 BYTE),
  x_soc_sid2x_soc NUMBER
);
ALTER TABLE sa.table_x_soc_sid ADD SUPPLEMENTAL LOG GROUP dmtsora1862242145_0 (objid, x_sid, x_soc_sid2x_soc) ALWAYS;
COMMENT ON TABLE sa.table_x_soc_sid IS 'Contains the SIDs';
COMMENT ON COLUMN sa.table_x_soc_sid.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_soc_sid.x_sid IS 'SID';
COMMENT ON COLUMN sa.table_x_soc_sid.x_soc_sid2x_soc IS 'SOC related to the SIDs';