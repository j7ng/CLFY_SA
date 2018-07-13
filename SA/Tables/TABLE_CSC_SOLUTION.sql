CREATE TABLE sa.table_csc_solution (
  objid NUMBER,
  solution_id VARCHAR2(80 BYTE),
  title VARCHAR2(80 BYTE),
  abstract VARCHAR2(255 BYTE),
  solution_type NUMBER,
  server_id NUMBER,
  dev NUMBER,
  solution2csc_incident NUMBER(*,0)
);
ALTER TABLE sa.table_csc_solution ADD SUPPLEMENTAL LOG GROUP dmtsora839853549_0 (abstract, dev, objid, server_id, solution2csc_incident, solution_id, solution_type, title) ALWAYS;
COMMENT ON TABLE sa.table_csc_solution IS 'The CSC solution describes the high level object that contains all objects pertaining to a specific solution document';
COMMENT ON COLUMN sa.table_csc_solution.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_solution.solution_id IS 'Owner s unique identifier for the whole solution';
COMMENT ON COLUMN sa.table_csc_solution.title IS 'Title for the CSC solution object';
COMMENT ON COLUMN sa.table_csc_solution.abstract IS 'Short description of solution';
COMMENT ON COLUMN sa.table_csc_solution.solution_type IS 'The standard type of solution; i.e., 0=reference, 1=diagnostic, 2=how_to. Default=0';
COMMENT ON COLUMN sa.table_csc_solution.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_solution.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_solution.solution2csc_incident IS 'CSC service incident which the problem describes';