CREATE TABLE sa.table_dist_birth (
  objid NUMBER,
  focus_type NUMBER,
  focus_lowid NUMBER,
  dev NUMBER,
  dist_birth2dist_srvr NUMBER(*,0),
  birth_srvr2dist_srvr NUMBER(*,0)
);
ALTER TABLE sa.table_dist_birth ADD SUPPLEMENTAL LOG GROUP dmtsora2134885540_0 (birth_srvr2dist_srvr, dev, dist_birth2dist_srvr, focus_lowid, focus_type, objid) ALWAYS;
COMMENT ON TABLE sa.table_dist_birth IS 'First replication instance of an object';
COMMENT ON COLUMN sa.table_dist_birth.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_dist_birth.focus_type IS 'Type_id of replicated object';
COMMENT ON COLUMN sa.table_dist_birth.focus_lowid IS 'Objid of replicated object';
COMMENT ON COLUMN sa.table_dist_birth.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_dist_birth.dist_birth2dist_srvr IS 'Server the object was replicated from';