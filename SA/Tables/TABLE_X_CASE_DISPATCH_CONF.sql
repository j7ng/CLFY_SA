CREATE TABLE sa.table_x_case_dispatch_conf (
  dev NUMBER,
  objid NUMBER,
  dispatch2conf_hdr NUMBER,
  status2gbst_elm NUMBER,
  priority2gbst_elm NUMBER,
  dispatch2queue NUMBER
);
ALTER TABLE sa.table_x_case_dispatch_conf ADD SUPPLEMENTAL LOG GROUP dmtsora796903255_0 (dev, dispatch2conf_hdr, dispatch2queue, objid, priority2gbst_elm, status2gbst_elm) ALWAYS;
COMMENT ON TABLE sa.table_x_case_dispatch_conf IS 'Case Dispatch Configuration, Queue Destination according to type, title and status';
COMMENT ON COLUMN sa.table_x_case_dispatch_conf.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_case_dispatch_conf.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_dispatch_conf.dispatch2conf_hdr IS 'TBD';
COMMENT ON COLUMN sa.table_x_case_dispatch_conf.status2gbst_elm IS 'TBD';
COMMENT ON COLUMN sa.table_x_case_dispatch_conf.priority2gbst_elm IS 'TBD';
COMMENT ON COLUMN sa.table_x_case_dispatch_conf.dispatch2queue IS 'TBD';