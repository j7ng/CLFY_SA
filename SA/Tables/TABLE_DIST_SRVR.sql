CREATE TABLE sa.table_dist_srvr (
  objid NUMBER,
  srvr_name VARCHAR2(80 BYTE),
  s_srvr_name VARCHAR2(80 BYTE),
  live_ind NUMBER,
  recovering NUMBER,
  status NUMBER,
  srvr_id NUMBER,
  srvr_db VARCHAR2(32 BYTE),
  proxy_name VARCHAR2(32 BYTE),
  proxy_db VARCHAR2(32 BYTE),
  local_ind NUMBER,
  dev NUMBER
);
ALTER TABLE sa.table_dist_srvr ADD SUPPLEMENTAL LOG GROUP dmtsora610118524_0 (dev, live_ind, local_ind, objid, proxy_db, proxy_name, recovering, srvr_db, srvr_id, srvr_name, status, s_srvr_name) ALWAYS;
COMMENT ON TABLE sa.table_dist_srvr IS 'Holds database names and descriptions of all the databases, including the local database, which can participate in replication. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.objid IS 'Internal record number. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.srvr_name IS 'Name of database server. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.live_ind IS 'Indicates whether participating server is currently live or not. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.recovering IS 'Indicates whether server is currently in recovery mode. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.status IS 'Status of server; i.e., 0=down, 1=up. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.srvr_id IS 'ID of database server. Matches the site_id field in dictionary table adp_db_header. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.srvr_db IS 'Database name of database server. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.proxy_name IS 'Name of alternate server that will receive data distribution if the server is not live. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.proxy_db IS 'Database name on proxy server. Reserved; future';
COMMENT ON COLUMN sa.table_dist_srvr.local_ind IS 'Local server indicator; i.e., 0=remote, 1=local';
COMMENT ON COLUMN sa.table_dist_srvr.dev IS 'Row version number for mobile distribution purposes';