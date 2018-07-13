CREATE TABLE sa.table_proc_inst (
  objid NUMBER,
  dev NUMBER,
  start_time DATE,
  end_time DATE,
  status VARCHAR2(30 BYTE),
  err_code VARCHAR2(30 BYTE),
  err_mess VARCHAR2(255 BYTE),
  focus_type NUMBER,
  focus_lowid NUMBER,
  arch_ind NUMBER,
  duration NUMBER,
  proc_inst2process NUMBER,
  proc_inst2biz_cal_hdr NUMBER,
  proc_inst_owner2user NUMBER
);
ALTER TABLE sa.table_proc_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1714842427_0 (arch_ind, dev, duration, end_time, err_code, err_mess, focus_lowid, focus_type, objid, proc_inst2biz_cal_hdr, proc_inst2process, proc_inst_owner2user, start_time, status) ALWAYS;
COMMENT ON TABLE sa.table_proc_inst IS 'Contains one instance for each generic process that has been executed';
COMMENT ON COLUMN sa.table_proc_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_proc_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_proc_inst.start_time IS 'Date and time the process was executed';
COMMENT ON COLUMN sa.table_proc_inst.end_time IS 'Date and time the process execution completed';
COMMENT ON COLUMN sa.table_proc_inst.status IS 'Active, Complete, Suspended';
COMMENT ON COLUMN sa.table_proc_inst.err_code IS 'Error Code';
COMMENT ON COLUMN sa.table_proc_inst.err_mess IS 'Error message text';
COMMENT ON COLUMN sa.table_proc_inst.focus_type IS 'Exclusive realtion type for thge owning object instance';
COMMENT ON COLUMN sa.table_proc_inst.focus_lowid IS 'Exclusive realtion objid for thge owning object instance';
COMMENT ON COLUMN sa.table_proc_inst.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_proc_inst.duration IS 'Maximum duration (number of seconds before timeout)';
COMMENT ON COLUMN sa.table_proc_inst.proc_inst2process IS 'Generic process for this instance';
COMMENT ON COLUMN sa.table_proc_inst.proc_inst2biz_cal_hdr IS 'Business calendar for the process instance';
COMMENT ON COLUMN sa.table_proc_inst.proc_inst_owner2user IS 'Owner of the process instance';