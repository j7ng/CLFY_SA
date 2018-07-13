CREATE TABLE sa.table_x_carr_script (
  objid NUMBER,
  x_script_id NUMBER,
  x_script_text LONG,
  x_script_type VARCHAR2(20 BYTE),
  carrier_script2x_carrier NUMBER
);
ALTER TABLE sa.table_x_carr_script ADD SUPPLEMENTAL LOG GROUP dmtsora798416153_0 (carrier_script2x_carrier, objid, x_script_id, x_script_type) ALWAYS;
COMMENT ON TABLE sa.table_x_carr_script IS 'Stores scripts related to particular carriers';
COMMENT ON COLUMN sa.table_x_carr_script.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_carr_script.x_script_id IS 'Script Identification Number';
COMMENT ON COLUMN sa.table_x_carr_script.x_script_text IS 'Carrier script text';
COMMENT ON COLUMN sa.table_x_carr_script.x_script_type IS 'Contains the type of script such as analog, digital or voice mail';
COMMENT ON COLUMN sa.table_x_carr_script.carrier_script2x_carrier IS 'Scripts related to carrier - this replaces the old relation carr_script2x_carrier (Digital)';