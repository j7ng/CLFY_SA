CREATE TABLE sa.table_rqst_inst (
  objid NUMBER,
  dev NUMBER,
  start_time DATE,
  end_time DATE,
  status VARCHAR2(10 BYTE),
  focus_type NUMBER,
  focus_lowid NUMBER,
  retry_count NUMBER,
  err_code VARCHAR2(30 BYTE),
  err_mess VARCHAR2(255 BYTE),
  busy NUMBER,
  focus_object VARCHAR2(64 BYTE),
  error_status VARCHAR2(30 BYTE),
  err_type VARCHAR2(10 BYTE),
  err_info VARCHAR2(128 BYTE),
  resume_focus_type NUMBER,
  resume_focus_lowid NUMBER,
  interface_err_code VARCHAR2(30 BYTE),
  "ID" VARCHAR2(80 BYTE),
  duration NUMBER,
  rqst_inst2svc_rqst NUMBER,
  rqst_inst2group_inst NUMBER,
  rqst2function NUMBER,
  rqst_inst2proc_inst NUMBER
);
ALTER TABLE sa.table_rqst_inst ADD SUPPLEMENTAL LOG GROUP dmtsora971276015_0 (busy, dev, duration, end_time, error_status, err_code, err_info, err_mess, err_type, focus_lowid, focus_object, focus_type, "ID", interface_err_code, objid, resume_focus_lowid, resume_focus_type, retry_count, rqst2function, rqst_inst2group_inst, rqst_inst2proc_inst, rqst_inst2svc_rqst, start_time, status) ALWAYS;
COMMENT ON TABLE sa.table_rqst_inst IS 'Contains one instance for each service request that has been executed';
COMMENT ON COLUMN sa.table_rqst_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_rqst_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_rqst_inst.start_time IS 'Date and time the function was executed';
COMMENT ON COLUMN sa.table_rqst_inst.end_time IS 'Date and time the function was completed';
COMMENT ON COLUMN sa.table_rqst_inst.status IS 'Active, Complete, Suspended, Error';
COMMENT ON COLUMN sa.table_rqst_inst.focus_type IS 'Focus object for group';
COMMENT ON COLUMN sa.table_rqst_inst.focus_lowid IS 'Objid of the focus object';
COMMENT ON COLUMN sa.table_rqst_inst.retry_count IS 'Retry count';
COMMENT ON COLUMN sa.table_rqst_inst.err_code IS 'Error Code';
COMMENT ON COLUMN sa.table_rqst_inst.err_mess IS 'Error message';
COMMENT ON COLUMN sa.table_rqst_inst.busy IS '0 = request is idle, 1 = request is busy';
COMMENT ON COLUMN sa.table_rqst_inst.focus_object IS 'Focus object as text (focus_type is less useful!)';
COMMENT ON COLUMN sa.table_rqst_inst.error_status IS 'Status of an error group (Active, Fallout, Resumed)';
COMMENT ON COLUMN sa.table_rqst_inst.err_type IS 'Type of error eg USER, SYSTEM';
COMMENT ON COLUMN sa.table_rqst_inst.err_info IS 'Additional info for an error';
COMMENT ON COLUMN sa.table_rqst_inst.resume_focus_type IS 'Resume focus type for error group';
COMMENT ON COLUMN sa.table_rqst_inst.resume_focus_lowid IS 'Resume focus lowid for error group';
COMMENT ON COLUMN sa.table_rqst_inst.interface_err_code IS 'Error code returned by interface';
COMMENT ON COLUMN sa.table_rqst_inst."ID" IS 'Action instance ID';
COMMENT ON COLUMN sa.table_rqst_inst.duration IS 'Maximum duration (number of seconds before timeout)';
COMMENT ON COLUMN sa.table_rqst_inst.rqst_inst2svc_rqst IS 'Generic service request for the request instance';
COMMENT ON COLUMN sa.table_rqst_inst.rqst_inst2group_inst IS 'Function group instance for the request instance';
COMMENT ON COLUMN sa.table_rqst_inst.rqst2function IS 'Function for this request instance';
COMMENT ON COLUMN sa.table_rqst_inst.rqst_inst2proc_inst IS 'Process instance that owns the request instance';