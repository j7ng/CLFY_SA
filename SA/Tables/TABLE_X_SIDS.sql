CREATE TABLE sa.table_x_sids (
  objid NUMBER,
  sids2personality NUMBER,
  x_band VARCHAR2(1 BYTE),
  x_sid VARCHAR2(10 BYTE),
  x_sid_type VARCHAR2(10 BYTE),
  x_index NUMBER
);
ALTER TABLE sa.table_x_sids ADD SUPPLEMENTAL LOG GROUP dmtsora1773720543_0 (objid, sids2personality, x_band, x_index, x_sid, x_sid_type) ALWAYS;
COMMENT ON TABLE sa.table_x_sids IS 'Contains information about the sids that are available under a carrier personality';
COMMENT ON COLUMN sa.table_x_sids.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_sids.sids2personality IS 'Personality Relation to SIDS';
COMMENT ON COLUMN sa.table_x_sids.x_band IS 'Band Type (A/B)';
COMMENT ON COLUMN sa.table_x_sids.x_sid IS 'Number that is local in the calling area';
COMMENT ON COLUMN sa.table_x_sids.x_sid_type IS 'Type of Sid (master/local)';
COMMENT ON COLUMN sa.table_x_sids.x_index IS 'Sequence number of the SID';