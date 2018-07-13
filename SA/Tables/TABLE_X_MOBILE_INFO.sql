CREATE TABLE sa.table_x_mobile_info (
  objid NUMBER,
  pgm_enroll2mobile_info NUMBER,
  mobile_name_script_id VARCHAR2(30 BYTE),
  mobile_desc_script_id VARCHAR2(30 BYTE),
  mobile_info_script_id VARCHAR2(30 BYTE),
  mobile_terms_condition_link VARCHAR2(1000 BYTE)
);
COMMENT ON TABLE sa.table_x_mobile_info IS 'Stores Mobile Name, Mobile Description Mobile Info and Term and Condition';
COMMENT ON COLUMN sa.table_x_mobile_info.objid IS 'Sequence Number: Obj ID';
COMMENT ON COLUMN sa.table_x_mobile_info.pgm_enroll2mobile_info IS 'Obj ID refers Program Enrolled';
COMMENT ON COLUMN sa.table_x_mobile_info.mobile_name_script_id IS 'Mobile Name';
COMMENT ON COLUMN sa.table_x_mobile_info.mobile_desc_script_id IS 'Mobile Description';
COMMENT ON COLUMN sa.table_x_mobile_info.mobile_info_script_id IS 'Mobile Info';
COMMENT ON COLUMN sa.table_x_mobile_info.mobile_terms_condition_link IS 'Mobile Terms and Conditions Link';