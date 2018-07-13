CREATE TABLE sa.table_inv_ctrl (
  objid NUMBER,
  dev NUMBER,
  control_id VARCHAR2(20 BYTE),
  s_control_id VARCHAR2(20 BYTE),
  control_name VARCHAR2(80 BYTE),
  s_control_name VARCHAR2(80 BYTE),
  control_freq VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_inv_ctrl ADD SUPPLEMENTAL LOG GROUP dmtsora1441887004_0 (control_freq, control_id, control_name, dev, objid, s_control_id, s_control_name) ALWAYS;
COMMENT ON TABLE sa.table_inv_ctrl IS 'Establishes control groups used in the periodic auditing of specific part numbers within specific bins within cycle count reporting locations. Reserved; future';
COMMENT ON COLUMN sa.table_inv_ctrl.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_inv_ctrl.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_inv_ctrl.control_id IS ' Control ID for control group used for audits';
COMMENT ON COLUMN sa.table_inv_ctrl.control_name IS ' Control group name';
COMMENT ON COLUMN sa.table_inv_ctrl.control_freq IS 'Frequency used when running control audits';