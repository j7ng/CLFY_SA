CREATE TABLE sa.table_cl_action (
  objid NUMBER,
  dev NUMBER,
  title VARCHAR2(80 BYTE),
  s_title VARCHAR2(80 BYTE),
  description VARCHAR2(255 BYTE),
  s_description VARCHAR2(255 BYTE),
  "RANK" NUMBER,
  "ACTION" VARCHAR2(80 BYTE),
  "ACTIVE" NUMBER,
  "TYPE" NUMBER,
  auto_exec_ind NUMBER,
  cl_action2cl_rule NUMBER,
  cl_action2cl_act_src NUMBER,
  cl_action2template NUMBER
);
ALTER TABLE sa.table_cl_action ADD SUPPLEMENTAL LOG GROUP dmtsora74588272_0 ("ACTION", "ACTIVE", auto_exec_ind, cl_action2cl_act_src, cl_action2cl_rule, cl_action2template, description, dev, objid, "RANK", s_description, s_title, title, "TYPE") ALWAYS;
COMMENT ON TABLE sa.table_cl_action IS 'The action to be taken when the related rule evaluates true. The action is always to run a cl_act_src function';
COMMENT ON COLUMN sa.table_cl_action.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_cl_action.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_cl_action.title IS 'Common name of the individual action';
COMMENT ON COLUMN sa.table_cl_action.description IS 'Description of the individual action';
COMMENT ON COLUMN sa.table_cl_action."RANK" IS 'Sequence number of the action. Used for ordering the execution of actions within a rule';
COMMENT ON COLUMN sa.table_cl_action."ACTION" IS 'Function name, either JScript or VBScript function entry';
COMMENT ON COLUMN sa.table_cl_action."ACTIVE" IS 'Indicates whether the action is active; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_cl_action."TYPE" IS 'Execution type; i.e., 0=script, 1=auto-suggest, default=0';
COMMENT ON COLUMN sa.table_cl_action.auto_exec_ind IS 'Indicates if the action will execute without review; i.e., 0=no, suggest only, 1=yes, execute automatically, default=0';
COMMENT ON COLUMN sa.table_cl_action.cl_action2cl_act_src IS 'Related function source code';
COMMENT ON COLUMN sa.table_cl_action.cl_action2template IS 'Template used by the action';