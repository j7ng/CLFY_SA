CREATE TABLE sa.table_x_promotion_group (
  objid NUMBER,
  group_name VARCHAR2(30 BYTE),
  group_desc VARCHAR2(55 BYTE),
  x_start_date DATE,
  x_end_date DATE,
  x_flash_text LONG,
  promo_group2x_promo NUMBER,
  x_max_count NUMBER,
  x_current_count NUMBER,
  x_multiplier NUMBER(19,4),
  x_stack_multiplier NUMBER(19,4)
);
ALTER TABLE sa.table_x_promotion_group ADD SUPPLEMENTAL LOG GROUP dmtsora1256288103_0 (group_desc, group_name, objid, promo_group2x_promo, x_current_count, x_end_date, x_max_count, x_multiplier, x_stack_multiplier, x_start_date) ALWAYS;
COMMENT ON TABLE sa.table_x_promotion_group IS 'Added J.R. - groups related to promotions for flashes';
COMMENT ON COLUMN sa.table_x_promotion_group.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_promotion_group.group_name IS 'Name for promotion group';
COMMENT ON COLUMN sa.table_x_promotion_group.group_desc IS 'description for promotion group';
COMMENT ON COLUMN sa.table_x_promotion_group.x_start_date IS 'Start Date for flash';
COMMENT ON COLUMN sa.table_x_promotion_group.x_end_date IS 'End Date for flash';
COMMENT ON COLUMN sa.table_x_promotion_group.x_flash_text IS 'Text used for flash';
COMMENT ON COLUMN sa.table_x_promotion_group.promo_group2x_promo IS 'Promo Group Related to promo';
COMMENT ON COLUMN sa.table_x_promotion_group.x_max_count IS 'Maximum elegible members for program';
COMMENT ON COLUMN sa.table_x_promotion_group.x_current_count IS 'Current Number of registered members';
COMMENT ON COLUMN sa.table_x_promotion_group.x_multiplier IS 'Conversion factor for service days and stacking calculations';
COMMENT ON COLUMN sa.table_x_promotion_group.x_stack_multiplier IS 'Stacking Rule Multiplier';