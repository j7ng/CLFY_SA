CREATE TABLE sa.x_mtm_program_carrmkt (
  program_param_objid NUMBER NOT NULL,
  carrier_objid NUMBER NOT NULL
);
ALTER TABLE sa.x_mtm_program_carrmkt ADD SUPPLEMENTAL LOG GROUP dmtsora1501477436_0 (carrier_objid, program_param_objid) ALWAYS;
COMMENT ON TABLE sa.x_mtm_program_carrmkt IS 'Billing programs carriers dependency, some billing programs could be segregated by carrier.';
COMMENT ON COLUMN sa.x_mtm_program_carrmkt.program_param_objid IS 'Reference to objid of  x_program_parameters';
COMMENT ON COLUMN sa.x_mtm_program_carrmkt.carrier_objid IS 'Reference to objid of  TABLE_X_CARRIER ';