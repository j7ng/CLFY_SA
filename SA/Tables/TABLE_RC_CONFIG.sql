CREATE TABLE sa.table_rc_config (
  objid NUMBER,
  "NAME" VARCHAR2(80 BYTE),
  base_flag NUMBER,
  description VARCHAR2(255 BYTE),
  rc_time_stamp DATE,
  cl_ver VARCHAR2(40 BYTE),
  dev NUMBER
);
ALTER TABLE sa.table_rc_config ADD SUPPLEMENTAL LOG GROUP dmtsora5176506_0 (base_flag, cl_ver, description, dev, "NAME", objid, rc_time_stamp) ALWAYS;
COMMENT ON TABLE sa.table_rc_config IS 'Resource configuration object; each object represents a group of customized forms';
COMMENT ON COLUMN sa.table_rc_config.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_rc_config."NAME" IS 'Name of the resource configuration';
COMMENT ON COLUMN sa.table_rc_config.base_flag IS 'Indicates whether the resource configuration is a base line resource configuration; i.e., B=baseline, space=not baseline';
COMMENT ON COLUMN sa.table_rc_config.description IS 'Description of the resource configuration';
COMMENT ON COLUMN sa.table_rc_config.rc_time_stamp IS 'Date/time resource configuration was created';
COMMENT ON COLUMN sa.table_rc_config.cl_ver IS 'Clarify baseline version';
COMMENT ON COLUMN sa.table_rc_config.dev IS 'Row version number for mobile distribution purposes';