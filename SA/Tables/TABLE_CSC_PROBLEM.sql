CREATE TABLE sa.table_csc_problem (
  objid NUMBER,
  likelihood NUMBER,
  "IMPACT" NUMBER,
  "TYPE" VARCHAR2(80 BYTE),
  server_id NUMBER,
  dev NUMBER,
  problem2csc_incident NUMBER(*,0),
  problem2csc_solution NUMBER(*,0)
);
ALTER TABLE sa.table_csc_problem ADD SUPPLEMENTAL LOG GROUP dmtsora825403153_0 (dev, "IMPACT", likelihood, objid, problem2csc_incident, problem2csc_solution, server_id, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_csc_problem IS 'The CSC problem is a primary object in a solution document.  It contains both structured and freeform information that describe a single problem';
COMMENT ON COLUMN sa.table_csc_problem.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_problem.likelihood IS 'Probability that the problem will occur (gives users a way to rank problems';
COMMENT ON COLUMN sa.table_csc_problem."IMPACT" IS 'Monitors catastrophic impact';
COMMENT ON COLUMN sa.table_csc_problem."TYPE" IS 'Category of the problem';
COMMENT ON COLUMN sa.table_csc_problem.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_problem.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_problem.problem2csc_solution IS 'Solution for the problem';