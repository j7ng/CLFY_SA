CREATE TABLE sa.table_cl_act_src (
  objid NUMBER,
  dev NUMBER,
  "TYPE" NUMBER,
  module_name VARCHAR2(80 BYTE),
  s_module_name VARCHAR2(80 BYTE),
  comments VARCHAR2(255 BYTE),
  src_code LONG,
  "VERSION" VARCHAR2(20 BYTE),
  s_version VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_cl_act_src ADD SUPPLEMENTAL LOG GROUP dmtsora1367774893_0 (comments, dev, module_name, objid, s_module_name, s_version, "TYPE", "VERSION") ALWAYS;
COMMENT ON TABLE sa.table_cl_act_src IS 'The source for a specific action. This is always a Java script';
COMMENT ON COLUMN sa.table_cl_act_src.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_cl_act_src.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_cl_act_src."TYPE" IS 'Source code type; 0=JScript, 1=VBScript, default=0';
COMMENT ON COLUMN sa.table_cl_act_src.module_name IS 'Name of the module';
COMMENT ON COLUMN sa.table_cl_act_src.comments IS 'Comments about the module';
COMMENT ON COLUMN sa.table_cl_act_src.src_code IS 'Script source code';
COMMENT ON COLUMN sa.table_cl_act_src."VERSION" IS 'Version of the source code';