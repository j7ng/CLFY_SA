CREATE TABLE sa.table_rqst_def (
  objid NUMBER,
  dev NUMBER,
  svc_name VARCHAR2(128 BYTE),
  duration NUMBER,
  max_retries NUMBER,
  retry_interval NUMBER,
  description VARCHAR2(255 BYTE),
  rqst_def2svc_type NUMBER
);
ALTER TABLE sa.table_rqst_def ADD SUPPLEMENTAL LOG GROUP dmtsora629618009_0 (description, dev, duration, max_retries, objid, retry_interval, rqst_def2svc_type, svc_name) ALWAYS;
COMMENT ON TABLE sa.table_rqst_def IS 'Defines the published service requests available for process definition';
COMMENT ON COLUMN sa.table_rqst_def.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_rqst_def.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_rqst_def.svc_name IS 'The Tuxedo service name that this function will call';
COMMENT ON COLUMN sa.table_rqst_def.duration IS 'Maximum duration (number of seconds before timeout)';
COMMENT ON COLUMN sa.table_rqst_def.max_retries IS 'Maximum retries';
COMMENT ON COLUMN sa.table_rqst_def.retry_interval IS 'Retry Interval';
COMMENT ON COLUMN sa.table_rqst_def.description IS 'Brief description of what the service request does';
COMMENT ON COLUMN sa.table_rqst_def.rqst_def2svc_type IS 'The type of service request';