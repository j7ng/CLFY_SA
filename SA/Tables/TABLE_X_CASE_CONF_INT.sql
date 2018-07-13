CREATE TABLE sa.table_x_case_conf_int (
  objid NUMBER,
  dev NUMBER,
  x_status VARCHAR2(80 BYTE),
  x_action VARCHAR2(10 BYTE),
  x_active NUMBER,
  conf_int2conf_hdr NUMBER
);
ALTER TABLE sa.table_x_case_conf_int ADD SUPPLEMENTAL LOG GROUP dmtsora583687633_0 (conf_int2conf_hdr, dev, objid, x_action, x_active, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_case_conf_int IS 'Warehouse Integrations Configuration';
COMMENT ON COLUMN sa.table_x_case_conf_int.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_case_conf_int.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_case_conf_int.x_status IS 'Case Status for Open Condition';
COMMENT ON COLUMN sa.table_x_case_conf_int.x_action IS 'Actions to Take when case adquires status:  PROCESS,CANCEL,RETRY';
COMMENT ON COLUMN sa.table_x_case_conf_int.x_active IS 'Rule is Active:  0=No, 1=Yes';
COMMENT ON COLUMN sa.table_x_case_conf_int.conf_int2conf_hdr IS 'TBD';