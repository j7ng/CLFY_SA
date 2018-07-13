CREATE TABLE sa.table_x_code_table (
  objid NUMBER,
  x_code_name VARCHAR2(20 BYTE),
  x_code_number VARCHAR2(20 BYTE),
  x_code_type VARCHAR2(20 BYTE),
  x_value NUMBER,
  x_text VARCHAR2(2000 BYTE),
  "ACTION" VARCHAR2(50 BYTE),
  remove_account_group_flag NUMBER(1),
  expire_acct_group_member_flag VARCHAR2(1 BYTE),
  expire_subscriber_flag VARCHAR2(1 BYTE),
  migration_flag VARCHAR2(1 BYTE),
  get_sui_last_trans_flag VARCHAR2(1 BYTE)
);
COMMENT ON TABLE sa.table_x_code_table IS 'Stores information regarding the code numbers';
COMMENT ON COLUMN sa.table_x_code_table.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_code_table.x_code_name IS 'Code Name';
COMMENT ON COLUMN sa.table_x_code_table.x_code_number IS 'Code Number';
COMMENT ON COLUMN sa.table_x_code_table.x_code_type IS 'Code Type';
COMMENT ON COLUMN sa.table_x_code_table.x_value IS 'Additional value for code';
COMMENT ON COLUMN sa.table_x_code_table.x_text IS 'Text associated with a code/script';
COMMENT ON COLUMN sa.table_x_code_table.get_sui_last_trans_flag IS 'Flag to retrieve call trans action item types for SUI processing';