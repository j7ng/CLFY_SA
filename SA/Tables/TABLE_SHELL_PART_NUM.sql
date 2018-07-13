CREATE TABLE sa.table_shell_part_num (
  shell_part_num_objid NUMBER,
  child_part_num_objid NUMBER,
  denom_description VARCHAR2(100 BYTE),
  vendor_upc VARCHAR2(30 BYTE),
  tf_filler VARCHAR2(1 BYTE),
  tf_id VARCHAR2(4 BYTE),
  airtime_denomination VARCHAR2(4 BYTE)
);
COMMENT ON COLUMN sa.table_shell_part_num.shell_part_num_objid IS 'The shell part number for the multi denom cards ';
COMMENT ON COLUMN sa.table_shell_part_num.child_part_num_objid IS 'The child part number for the multi denom cards ';
COMMENT ON COLUMN sa.table_shell_part_num.vendor_upc IS 'The vendor upc multi denom cards';
COMMENT ON COLUMN sa.table_shell_part_num.tf_filler IS 'The TF Filler for the multi denom cards';
COMMENT ON COLUMN sa.table_shell_part_num.tf_id IS 'The TF Id for the multi denom cards';
COMMENT ON COLUMN sa.table_shell_part_num.airtime_denomination IS 'The Denomination for the multi denom cards';