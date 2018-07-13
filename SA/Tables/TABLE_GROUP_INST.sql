CREATE TABLE sa.table_group_inst (
  objid NUMBER,
  dev NUMBER,
  status VARCHAR2(30 BYTE),
  err_code VARCHAR2(30 BYTE),
  err_mess VARCHAR2(255 BYTE),
  seqno NUMBER,
  no_functions NUMBER,
  cond_val VARCHAR2(255 BYTE),
  focus_type NUMBER,
  focus_lowid NUMBER,
  status_code NUMBER,
  iter_seqno NUMBER,
  start_time DATE,
  end_time DATE,
  focus_object VARCHAR2(64 BYTE),
  iter_instance_count NUMBER,
  error_status VARCHAR2(30 BYTE),
  err_type VARCHAR2(10 BYTE),
  err_info VARCHAR2(128 BYTE),
  resume_focus_type NUMBER,
  resume_focus_lowid NUMBER,
  "ID" VARCHAR2(80 BYTE),
  group2func_group NUMBER,
  group2proc_inst NUMBER,
  child2group_inst NUMBER,
  group2function NUMBER
);
ALTER TABLE sa.table_group_inst ADD SUPPLEMENTAL LOG GROUP dmtsora80113960_0 (child2group_inst, cond_val, dev, end_time, error_status, err_code, err_info, err_mess, err_type, focus_lowid, focus_object, focus_type, group2function, group2func_group, group2proc_inst, "ID", iter_instance_count, iter_seqno, no_functions, objid, resume_focus_lowid, resume_focus_type, seqno, start_time, status, status_code) ALWAYS;
COMMENT ON TABLE sa.table_group_inst IS 'Contains one instance for each function group that has been executed';
COMMENT ON COLUMN sa.table_group_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_group_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_group_inst.status IS 'Active, Complete, Suspended';
COMMENT ON COLUMN sa.table_group_inst.err_code IS 'Error Code';
COMMENT ON COLUMN sa.table_group_inst.err_mess IS 'Error message text';
COMMENT ON COLUMN sa.table_group_inst.seqno IS 'Sequence number of current serial function';
COMMENT ON COLUMN sa.table_group_inst.no_functions IS 'Number of active paralled functions';
COMMENT ON COLUMN sa.table_group_inst.cond_val IS 'Conditional expression for conditional group';
COMMENT ON COLUMN sa.table_group_inst.focus_type IS 'Focus object for group';
COMMENT ON COLUMN sa.table_group_inst.focus_lowid IS 'Objid of the focus object';
COMMENT ON COLUMN sa.table_group_inst.status_code IS 'Status code';
COMMENT ON COLUMN sa.table_group_inst.iter_seqno IS 'Sequence number of this iteration instance';
COMMENT ON COLUMN sa.table_group_inst.start_time IS 'Date and time the function was executed';
COMMENT ON COLUMN sa.table_group_inst.end_time IS 'Date and time the function was completed';
COMMENT ON COLUMN sa.table_group_inst.focus_object IS 'Focus object as text (focus_type is less useful!)';
COMMENT ON COLUMN sa.table_group_inst.iter_instance_count IS 'Number of concurrent iteration instances';
COMMENT ON COLUMN sa.table_group_inst.error_status IS 'Status of an error group (Active, Fallout, Resumed)';
COMMENT ON COLUMN sa.table_group_inst.err_type IS 'Type of error eg USER, SYSTEM';
COMMENT ON COLUMN sa.table_group_inst.err_info IS 'Additional info for an error';
COMMENT ON COLUMN sa.table_group_inst.resume_focus_type IS 'Resume focus type for error group';
COMMENT ON COLUMN sa.table_group_inst.resume_focus_lowid IS 'Resume focus lowid for error group';
COMMENT ON COLUMN sa.table_group_inst."ID" IS 'Group instance ID';
COMMENT ON COLUMN sa.table_group_inst.group2func_group IS 'Generic function group for this instance';
COMMENT ON COLUMN sa.table_group_inst.group2proc_inst IS 'Process instance for the top level function group instance';
COMMENT ON COLUMN sa.table_group_inst.child2group_inst IS 'Parent group instance for subgroup instances';
COMMENT ON COLUMN sa.table_group_inst.group2function IS 'Function for this group instance';