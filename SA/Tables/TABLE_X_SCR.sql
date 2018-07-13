CREATE TABLE sa.table_x_scr (
  objid NUMBER,
  x_script_id NUMBER,
  x_script_text_bkp LONG,
  x_script_type VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_ivr_id VARCHAR2(40 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_language VARCHAR2(12 BYTE),
  x_technology VARCHAR2(10 BYTE),
  x_script_text VARCHAR2(4000 BYTE)
);
ALTER TABLE sa.table_x_scr ADD SUPPLEMENTAL LOG GROUP dmtsora2043849416_0 (objid, x_description, x_ivr_id, x_language, x_script_id, x_script_type, x_sourcesystem, x_technology) ALWAYS;
COMMENT ON TABLE sa.table_x_scr IS 'Stores scripts related to particular carriers';
COMMENT ON COLUMN sa.table_x_scr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_scr.x_script_id IS 'Script Identification Number';
COMMENT ON COLUMN sa.table_x_scr.x_script_type IS 'Contains the type of script such as analog, digital or voice mail';
COMMENT ON COLUMN sa.table_x_scr.x_sourcesystem IS 'Contains the system the script applies to';
COMMENT ON COLUMN sa.table_x_scr.x_ivr_id IS 'Contains the associated voice script for the IVR';
COMMENT ON COLUMN sa.table_x_scr.x_description IS 'Added as a description of the script';
COMMENT ON COLUMN sa.table_x_scr.x_language IS 'Language Description';
COMMENT ON COLUMN sa.table_x_scr.x_technology IS 'Technology associated to the script';
COMMENT ON COLUMN sa.table_x_scr.x_script_text IS 'Carrier script text';