CREATE TABLE sa.mtm_alert2part_class (
  part_class_objid NUMBER,
  alert_objid NUMBER,
  part_number_objid NUMBER,
  pgm_parameter2objid NUMBER(22)
);
COMMENT ON COLUMN sa.mtm_alert2part_class.part_number_objid IS 'table_part_num.Objid';
COMMENT ON COLUMN sa.mtm_alert2part_class.pgm_parameter2objid IS 'x_program_parameters.Objid';