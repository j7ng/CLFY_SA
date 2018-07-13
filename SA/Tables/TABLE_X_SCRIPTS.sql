CREATE TABLE sa.table_x_scripts (
  objid NUMBER,
  dev NUMBER,
  x_script_id VARCHAR2(20 BYTE),
  x_script_type VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(20 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_language VARCHAR2(10 BYTE),
  x_technology VARCHAR2(20 BYTE),
  x_script_text VARCHAR2(4000 BYTE),
  x_published_date DATE,
  x_published_by VARCHAR2(30 BYTE),
  x_script_manager_link VARCHAR2(255 BYTE),
  script2bus_org NUMBER
);
ALTER TABLE sa.table_x_scripts ADD SUPPLEMENTAL LOG GROUP dmtsora1508155735_0 (dev, objid, x_description, x_language, x_published_by, x_published_date, x_script_id, x_script_text, x_script_type, x_sourcesystem, x_technology) ALWAYS;
COMMENT ON TABLE sa.table_x_scripts IS 'Centralized Scripts Table';
COMMENT ON COLUMN sa.table_x_scripts.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_scripts.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_scripts.x_script_id IS 'Script ID';
COMMENT ON COLUMN sa.table_x_scripts.x_script_type IS 'Script Type';
COMMENT ON COLUMN sa.table_x_scripts.x_sourcesystem IS 'Sourcesystem: WEB,WEBCSR,IVR,HANDSET';
COMMENT ON COLUMN sa.table_x_scripts.x_description IS 'Script Description';
COMMENT ON COLUMN sa.table_x_scripts.x_language IS 'Language: English,Spanish';
COMMENT ON COLUMN sa.table_x_scripts.x_technology IS 'Technology: CDMA,GSM';
COMMENT ON COLUMN sa.table_x_scripts.x_script_text IS 'Script Text';
COMMENT ON COLUMN sa.table_x_scripts.x_published_date IS 'Date of Publishing';
COMMENT ON COLUMN sa.table_x_scripts.x_published_by IS 'Login name of publishing user';