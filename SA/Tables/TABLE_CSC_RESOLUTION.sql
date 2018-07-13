CREATE TABLE sa.table_csc_resolution (
  objid NUMBER,
  confidence VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(80 BYTE),
  server_id NUMBER,
  dev NUMBER,
  res2csc_solution NUMBER(*,0),
  res2csc_incident NUMBER(*,0),
  res2csc_admin NUMBER(*,0)
);
ALTER TABLE sa.table_csc_resolution ADD SUPPLEMENTAL LOG GROUP dmtsora499410288_0 (confidence, dev, objid, res2csc_admin, res2csc_incident, res2csc_solution, server_id, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_csc_resolution IS 'Describes the actions to take if the defined PROBLEM(s) are true';
COMMENT ON COLUMN sa.table_csc_resolution.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_resolution.confidence IS 'Confidence that this solution solves problem';
COMMENT ON COLUMN sa.table_csc_resolution."TYPE" IS 'Type of resolution';
COMMENT ON COLUMN sa.table_csc_resolution.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_resolution.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_resolution.res2csc_solution IS 'Related solution';
COMMENT ON COLUMN sa.table_csc_resolution.res2csc_incident IS 'Related solution';
COMMENT ON COLUMN sa.table_csc_resolution.res2csc_admin IS 'Related solution';