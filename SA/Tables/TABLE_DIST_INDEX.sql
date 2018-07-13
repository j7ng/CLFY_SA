CREATE TABLE sa.table_dist_index (
  objid NUMBER,
  data_id NUMBER,
  data_type NUMBER,
  remote_obj NUMBER,
  active_ind NUMBER,
  dev NUMBER,
  dist_index2srvr NUMBER(*,0)
);
ALTER TABLE sa.table_dist_index ADD SUPPLEMENTAL LOG GROUP dmtsora609991971_0 (active_ind, data_id, data_type, dev, dist_index2srvr, objid, remote_obj) ALWAYS;
COMMENT ON TABLE sa.table_dist_index IS 'Index of the distribution transactions available for remote servers. Indexed to the external rules file, which has the details of the distribution. Reserved; obsolete';
COMMENT ON COLUMN sa.table_dist_index.objid IS 'Internal record number. Reserved; future';
COMMENT ON COLUMN sa.table_dist_index.data_id IS 'Object ID of the root object to be distributed. Reserved; future';
COMMENT ON COLUMN sa.table_dist_index.data_type IS 'Focus type of root object that is to be distributed; e.g., case=0. Reserved; future';
COMMENT ON COLUMN sa.table_dist_index.remote_obj IS 'Object ID of root object on the remote server. Reserved; future';
COMMENT ON COLUMN sa.table_dist_index.active_ind IS 'Indicates whether the item is still under active distribution. If inactive (e.g., ownership has transferred) further distributions of the data item will not be made. Reserved; future';
COMMENT ON COLUMN sa.table_dist_index.dev IS 'Row version number for mobile distribution purposes';