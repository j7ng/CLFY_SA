CREATE TABLE sa.table_csc_category (
  objid NUMBER,
  "VALUE" VARCHAR2(255 BYTE),
  "TYPE" VARCHAR2(80 BYTE),
  server_id NUMBER,
  dev NUMBER,
  category2csc_solution NUMBER(*,0),
  category2csc_problem NUMBER(*,0),
  child2csc_category NUMBER(*,0),
  cat2csc_resolution NUMBER(*,0)
);
ALTER TABLE sa.table_csc_category ADD SUPPLEMENTAL LOG GROUP dmtsora944677631_0 (cat2csc_resolution, category2csc_problem, category2csc_solution, child2csc_category, dev, objid, server_id, "TYPE", "VALUE") ALWAYS;
COMMENT ON TABLE sa.table_csc_category IS 'The CSC category provides a storage place for a hierarchy of categorical information';
COMMENT ON COLUMN sa.table_csc_category.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_category."VALUE" IS 'Value for the category';
COMMENT ON COLUMN sa.table_csc_category."TYPE" IS 'Describes the type of the category';
COMMENT ON COLUMN sa.table_csc_category.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_category.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_category.category2csc_solution IS 'CSC Solution having the category';
COMMENT ON COLUMN sa.table_csc_category.category2csc_problem IS 'CSC Problem having the category';
COMMENT ON COLUMN sa.table_csc_category.child2csc_category IS 'Parent category';
COMMENT ON COLUMN sa.table_csc_category.cat2csc_resolution IS 'Resolution being categorized';