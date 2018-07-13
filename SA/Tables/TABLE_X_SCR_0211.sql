CREATE TABLE sa.table_x_scr_0211 (
  objid NUMBER(*,0),
  x_script_id NUMBER(*,0),
  x_script_text LONG,
  x_script_type VARCHAR2(20 BYTE),
  x_sourcesystem VARCHAR2(30 BYTE),
  x_ivr_id VARCHAR2(40 BYTE),
  x_description VARCHAR2(255 BYTE),
  x_language VARCHAR2(12 BYTE)
);
ALTER TABLE sa.table_x_scr_0211 ADD SUPPLEMENTAL LOG GROUP dmtsora1344809705_0 (objid, x_description, x_ivr_id, x_language, x_script_id, x_script_type, x_sourcesystem) ALWAYS;