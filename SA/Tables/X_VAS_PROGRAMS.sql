CREATE TABLE sa.x_vas_programs (
  objid NUMBER,
  vas_name VARCHAR2(30 BYTE),
  vas_id VARCHAR2(30 BYTE),
  mobile_plan_type_script_id VARCHAR2(30 BYTE),
  mobile_desc1_script_id VARCHAR2(30 BYTE),
  mobile_desc2_script_id VARCHAR2(30 BYTE),
  mobile_desc3_script_id VARCHAR2(30 BYTE),
  mobile_desc4_script_id VARCHAR2(30 BYTE),
  mobile_ild_rates_link VARCHAR2(1000 BYTE)
);
COMMENT ON TABLE sa.x_vas_programs IS 'VALUE ADDED PROGRAMS';
COMMENT ON COLUMN sa.x_vas_programs.objid IS 'UNIQUE KEY OF X_VAS_PROGRAMS TABLE';
COMMENT ON COLUMN sa.x_vas_programs.vas_name IS 'NAME OF THE SERVICE';
COMMENT ON COLUMN sa.x_vas_programs.vas_id IS 'SERVICE ID';
COMMENT ON COLUMN sa.x_vas_programs.mobile_plan_type_script_id IS 'Mobile Plan Type';
COMMENT ON COLUMN sa.x_vas_programs.mobile_desc1_script_id IS 'Mobile Description';
COMMENT ON COLUMN sa.x_vas_programs.mobile_desc2_script_id IS 'Mobile Description 2';
COMMENT ON COLUMN sa.x_vas_programs.mobile_desc3_script_id IS 'Mobile Description 3';
COMMENT ON COLUMN sa.x_vas_programs.mobile_desc4_script_id IS 'Mobile Description 4';
COMMENT ON COLUMN sa.x_vas_programs.mobile_ild_rates_link IS 'Mobile ILD Rates URL';