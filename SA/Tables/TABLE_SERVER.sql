CREATE TABLE sa.table_server (
  objid NUMBER,
  dev NUMBER,
  is_local NUMBER,
  machine_name VARCHAR2(80 BYTE),
  process_name VARCHAR2(80 BYTE),
  server_state NUMBER,
  is_alive NUMBER,
  last_start_time DATE,
  update_timestamp DATE
);
ALTER TABLE sa.table_server ADD SUPPLEMENTAL LOG GROUP dmtsora1937375525_0 (dev, is_alive, is_local, last_start_time, machine_name, objid, process_name, server_state, update_timestamp) ALWAYS;
COMMENT ON TABLE sa.table_server IS 'Stores information about server instances';
COMMENT ON COLUMN sa.table_server.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_server.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_server.is_local IS 'Whether the node is local; i.e., 0=Local, 1=Remote, default=0';
COMMENT ON COLUMN sa.table_server.machine_name IS 'Name of the server where the server instance is running (e.g machine name where Notifier is running)';
COMMENT ON COLUMN sa.table_server.process_name IS 'Name of the server server process e.g. Notifier, Rule Mgr';
COMMENT ON COLUMN sa.table_server.server_state IS 'Indicates the state of the process: i.e., 0=Not running, 1=running, 2=waiting etc';
COMMENT ON COLUMN sa.table_server.is_alive IS 'Flag to signal if the process is alive or not; 0=dead, 1=is alive, default=0';
COMMENT ON COLUMN sa.table_server.last_start_time IS 'Date/time of last time when the process was started';
COMMENT ON COLUMN sa.table_server.update_timestamp IS 'Date/time of update of the Server information';