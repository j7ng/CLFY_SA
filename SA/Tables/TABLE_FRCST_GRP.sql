CREATE TABLE sa.table_frcst_grp (
  objid NUMBER,
  description VARCHAR2(255 BYTE),
  dev NUMBER,
  fgrp_type2gbst_elm NUMBER(*,0)
);
ALTER TABLE sa.table_frcst_grp ADD SUPPLEMENTAL LOG GROUP dmtsora1495207996_0 (description, dev, fgrp_type2gbst_elm, objid) ALWAYS;
COMMENT ON TABLE sa.table_frcst_grp IS 'Groups sales forecasts. Reserved; not used';
COMMENT ON COLUMN sa.table_frcst_grp.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_frcst_grp.description IS 'Description of the forecast group';
COMMENT ON COLUMN sa.table_frcst_grp.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_frcst_grp.fgrp_type2gbst_elm IS 'Type of forecast; e.g., actual, quota, etc';