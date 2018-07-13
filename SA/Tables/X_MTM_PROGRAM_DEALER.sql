CREATE TABLE sa.x_mtm_program_dealer (
  program_param_objid NUMBER,
  dealer_objid NUMBER
);
COMMENT ON TABLE sa.x_mtm_program_dealer IS 'Eligible dealer to billing programs';
COMMENT ON COLUMN sa.x_mtm_program_dealer.program_param_objid IS 'Reference to objid of table  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_program_dealer.dealer_objid IS 'Reference to objid of table table_site';