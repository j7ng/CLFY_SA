CREATE TABLE sa.x_script_handset_os (
  operating_system VARCHAR2(50 BYTE),
  os_desc VARCHAR2(100 BYTE),
  script_id VARCHAR2(30 BYTE),
  os_name VARCHAR2(30 BYTE),
  display_order NUMBER(22)
);
COMMENT ON TABLE sa.x_script_handset_os IS 'GENERIC SCRIPTING HANDSET OS TABLE';
COMMENT ON COLUMN sa.x_script_handset_os.operating_system IS 'GENERIC OS';
COMMENT ON COLUMN sa.x_script_handset_os.os_desc IS 'DESCRIPTION';
COMMENT ON COLUMN sa.x_script_handset_os.script_id IS 'SCRIPT ID';