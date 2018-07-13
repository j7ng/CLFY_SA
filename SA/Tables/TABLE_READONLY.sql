CREATE TABLE sa.table_readonly (
  objid NUMBER,
  dev NUMBER,
  readonly2window_db NUMBER(*,0),
  readonly2privclass NUMBER(*,0)
);
ALTER TABLE sa.table_readonly ADD SUPPLEMENTAL LOG GROUP dmtsora275531599_0 (dev, objid, readonly2privclass, readonly2window_db) ALWAYS;