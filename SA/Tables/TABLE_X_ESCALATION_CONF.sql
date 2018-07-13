CREATE TABLE sa.table_x_escalation_conf (
  objid NUMBER,
  dev NUMBER,
  x_hot_transfer NUMBER,
  x_script_id_hot VARCHAR2(20 BYTE),
  x_script_id_cold VARCHAR2(20 BYTE),
  x_script_id_grace VARCHAR2(20 BYTE),
  x_eval_escalation NUMBER,
  escal2conf_hdr NUMBER,
  from_prty2gbst_elm NUMBER,
  to_prty2gbst_elm NUMBER
);
ALTER TABLE sa.table_x_escalation_conf ADD SUPPLEMENTAL LOG GROUP dmtsora1020710632_0 (dev, escal2conf_hdr, from_prty2gbst_elm, objid, to_prty2gbst_elm, x_eval_escalation, x_hot_transfer, x_script_id_cold, x_script_id_grace, x_script_id_hot) ALWAYS;
COMMENT ON TABLE sa.table_x_escalation_conf IS 'Escalation Configuration';
COMMENT ON COLUMN sa.table_x_escalation_conf.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_escalation_conf.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_escalation_conf.x_hot_transfer IS '0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_escalation_conf.x_script_id_hot IS 'ref to table_x_scripts';
COMMENT ON COLUMN sa.table_x_escalation_conf.x_script_id_cold IS 'ref to table_x_scripts';
COMMENT ON COLUMN sa.table_x_escalation_conf.x_script_id_grace IS 'Script ID for Grace';
COMMENT ON COLUMN sa.table_x_escalation_conf.x_eval_escalation IS '0=No 1=Yes';
COMMENT ON COLUMN sa.table_x_escalation_conf.escal2conf_hdr IS 'TBD';
COMMENT ON COLUMN sa.table_x_escalation_conf.from_prty2gbst_elm IS 'TBD';
COMMENT ON COLUMN sa.table_x_escalation_conf.to_prty2gbst_elm IS 'TBD';