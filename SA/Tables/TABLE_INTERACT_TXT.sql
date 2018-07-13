CREATE TABLE sa.table_interact_txt (
  objid NUMBER,
  notes LONG,
  dev NUMBER,
  interact_txt2interact NUMBER(*,0)
);
ALTER TABLE sa.table_interact_txt ADD SUPPLEMENTAL LOG GROUP dmtsora1562450640_0 (dev, interact_txt2interact, objid) ALWAYS;
COMMENT ON TABLE sa.table_interact_txt IS 'Stores extended length text for an interaction';
COMMENT ON COLUMN sa.table_interact_txt.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_interact_txt.notes IS 'Notes describing additional information about an interaction';
COMMENT ON COLUMN sa.table_interact_txt.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_interact_txt.interact_txt2interact IS 'Related Interaction';