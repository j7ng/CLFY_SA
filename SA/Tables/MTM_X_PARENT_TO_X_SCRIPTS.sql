CREATE TABLE sa.mtm_x_parent_to_x_scripts (
  script_objid NUMBER,
  carrier_parent_objid NUMBER
);
COMMENT ON COLUMN sa.mtm_x_parent_to_x_scripts.script_objid IS 'This is the script objid';
COMMENT ON COLUMN sa.mtm_x_parent_to_x_scripts.carrier_parent_objid IS 'This is the carrier parent objid (table_x_parent)';