CREATE TABLE sa.table_call_script (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  scr_type VARCHAR2(25 BYTE),
  s_scr_type VARCHAR2(25 BYTE),
  status VARCHAR2(30 BYTE),
  s_status VARCHAR2(30 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  duration NUMBER,
  "ACTION" VARCHAR2(255 BYTE),
  s_action VARCHAR2(255 BYTE),
  parm VARCHAR2(255 BYTE),
  s_parm VARCHAR2(255 BYTE),
  create_date DATE,
  dev NUMBER,
  scr_originator2user NUMBER(*,0),
  s_next_s2call_script NUMBER(*,0),
  branch_ind NUMBER,
  embed_func VARCHAR2(255 BYTE),
  s_embed_func VARCHAR2(255 BYTE),
  embed_parm VARCHAR2(255 BYTE),
  s_embed_parm VARCHAR2(255 BYTE),
  call_script2hgbst_elm NUMBER,
  x_default_script NUMBER,
  x_qual_script NUMBER
);
ALTER TABLE sa.table_call_script ADD SUPPLEMENTAL LOG GROUP dmtsora1599593138_0 ("ACTION", branch_ind, call_script2hgbst_elm, create_date, description, dev, duration, embed_func, embed_parm, "NAME", objid, parm, scr_originator2user, scr_type, status, s_action, s_description, s_embed_func, s_embed_parm, s_name, s_next_s2call_script, s_parm, s_scr_type, s_status, x_default_script, x_qual_script) ALWAYS;
COMMENT ON TABLE sa.table_call_script IS 'A set of prompts, possible responses, scores, branching and actions which guides an agent through the steps required to perform a service for a customer';
COMMENT ON COLUMN sa.table_call_script.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_call_script."NAME" IS 'Script name';
COMMENT ON COLUMN sa.table_call_script.scr_type IS 'Script type. This is from a user-defined popup with default name Call Script Type';
COMMENT ON COLUMN sa.table_call_script.status IS 'Script status. This is from a user-defined popup with default name Call Script Status';
COMMENT ON COLUMN sa.table_call_script.description IS 'Description of the call script';
COMMENT ON COLUMN sa.table_call_script.duration IS 'Estimated length of the call script in seconds';
COMMENT ON COLUMN sa.table_call_script."ACTION" IS 'Action to take if the response is selected';
COMMENT ON COLUMN sa.table_call_script.parm IS 'Parameter set for the action';
COMMENT ON COLUMN sa.table_call_script.create_date IS 'The create date and time of the call_script object';
COMMENT ON COLUMN sa.table_call_script.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_call_script.scr_originator2user IS 'User who originated the call script';
COMMENT ON COLUMN sa.table_call_script.s_next_s2call_script IS 'Default next script to be executed';
COMMENT ON COLUMN sa.table_call_script.branch_ind IS 'Indicates whether branching is enabled on the script; i.e., 0=no, 1=yes, default=0. Indicator may be modified when used';
COMMENT ON COLUMN sa.table_call_script.embed_func IS 'Embeded function used for processing embeded text';
COMMENT ON COLUMN sa.table_call_script.embed_parm IS 'Parameter set for the embed func';
COMMENT ON COLUMN sa.table_call_script.call_script2hgbst_elm IS 'Script to hgbst_elm';
COMMENT ON COLUMN sa.table_call_script.x_default_script IS 'TBD';
COMMENT ON COLUMN sa.table_call_script.x_qual_script IS 'TBD';