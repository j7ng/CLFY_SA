CREATE TABLE sa.table_rollup (
  objid NUMBER,
  dev NUMBER,
  rollup_type NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  focus_type NUMBER,
  use_type NUMBER,
  is_default NUMBER,
  rollup_ind NUMBER
);
ALTER TABLE sa.table_rollup ADD SUPPLEMENTAL LOG GROUP dmtsora541096407_0 (description, dev, focus_type, is_default, "NAME", objid, rollup_ind, rollup_type, s_name, use_type) ALWAYS;
COMMENT ON TABLE sa.table_rollup IS 'Idenfities a hierarchical structure e.g., organization chart, inventory location chart, which may be used to summarize information';
COMMENT ON COLUMN sa.table_rollup.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_rollup.dev IS 'Row version number for mobile50 distribution purposes';
COMMENT ON COLUMN sa.table_rollup.rollup_type IS 'Contraints on the rollup, i.e., 1=only single parent allowed, 2=multiple parents allowed, 3=duplicate indirect children allowed';
COMMENT ON COLUMN sa.table_rollup."NAME" IS 'Name of the rollup';
COMMENT ON COLUMN sa.table_rollup.description IS 'Description of the rollup';
COMMENT ON COLUMN sa.table_rollup.focus_type IS 'Object type ID of the object type for the rollup; e.g., 173=bus_org, 228=inv_locatn, 5002=territory';
COMMENT ON COLUMN sa.table_rollup.use_type IS 'Used within focus_type to signal how a rollup on a particular object is used by the application; e.g., for inventory locations (228) 1=counting for inventory counts, 2=physical - for zone management, 3=reporting for reporting operational metrics';
COMMENT ON COLUMN sa.table_rollup.is_default IS 'Determines, within focus_type, if the rollup is the default i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_rollup.rollup_ind IS 'Used for read-only account hierarchy';