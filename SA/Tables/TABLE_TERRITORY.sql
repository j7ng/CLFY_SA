CREATE TABLE sa.table_territory (
  objid NUMBER,
  "TYPE" VARCHAR2(25 BYTE),
  "ACTIVE" NUMBER,
  terr_id VARCHAR2(80 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  comments VARCHAR2(255 BYTE),
  start_date DATE,
  end_date DATE,
  node_key VARCHAR2(255 BYTE),
  is_default NUMBER,
  dev NUMBER,
  include2filterset NUMBER(*,0),
  child2territory NUMBER(*,0)
);
ALTER TABLE sa.table_territory ADD SUPPLEMENTAL LOG GROUP dmtsora1099374264_0 ("ACTIVE", child2territory, comments, description, dev, end_date, include2filterset, is_default, "NAME", node_key, objid, start_date, s_name, terr_id, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_territory IS 'Information about a sales territory';
COMMENT ON COLUMN sa.table_territory.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_territory."TYPE" IS 'The territory type. This is a user-defined pop up with default name Territory Type';
COMMENT ON COLUMN sa.table_territory."ACTIVE" IS 'Indicates whether the territory is active; i.e., 0=inactive, 1=active. Default=1';
COMMENT ON COLUMN sa.table_territory.terr_id IS 'User-specified ID number of the territory';
COMMENT ON COLUMN sa.table_territory."NAME" IS 'Name of the territory';
COMMENT ON COLUMN sa.table_territory.description IS 'The description of the territory';
COMMENT ON COLUMN sa.table_territory.comments IS 'Comments about the territory';
COMMENT ON COLUMN sa.table_territory.start_date IS 'The starting date of the territory';
COMMENT ON COLUMN sa.table_territory.end_date IS 'The ending date of the territory';
COMMENT ON COLUMN sa.table_territory.node_key IS 'Used for rollups. Holds the path from top to the current territory in the hierarchy of territories. Reserved; obsolete. Replaced by ter_rol_itm';
COMMENT ON COLUMN sa.table_territory.is_default IS 'Indicates whether the object is the default territory; i.e., 0=no, 1=yes. Used for auto-generated opportunities, which must be related to a territory';
COMMENT ON COLUMN sa.table_territory.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_territory.include2filterset IS 'Filterset which selects business organizations for the territory. Reserved; future';
COMMENT ON COLUMN sa.table_territory.child2territory IS 'Territory the current territory reports to. Reserved; obsolete. Replaced by ter_rol_itm';