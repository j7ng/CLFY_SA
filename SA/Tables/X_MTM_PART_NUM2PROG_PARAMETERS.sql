CREATE TABLE sa.x_mtm_part_num2prog_parameters (
  program_param_objid NUMBER,
  part_number_objid NUMBER,
  x_promo_code VARCHAR2(10 BYTE),
  x_ar_display_order NUMBER
);
COMMENT ON COLUMN sa.x_mtm_part_num2prog_parameters.program_param_objid IS 'PART NUMBER OBJID';