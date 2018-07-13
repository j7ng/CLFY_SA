CREATE TABLE sa.ubi_mtg_src_configurations (
  mtg_short_name VARCHAR2(20 BYTE),
  balance_element VARCHAR2(30 BYTE),
  reference_type VARCHAR2(300 BYTE),
  reference_element VARCHAR2(300 BYTE),
  reference_units VARCHAR2(300 BYTE)
);
COMMENT ON COLUMN sa.ubi_mtg_src_configurations.mtg_short_name IS 'The actual Metering source used. references data_mtg_source from x_product_config';
COMMENT ON COLUMN sa.ubi_mtg_src_configurations.balance_element IS 'What balance element type will this return, ubi_ele_definitions has this value';
COMMENT ON COLUMN sa.ubi_mtg_src_configurations.reference_type IS 'TBD based off discussions and my understanding, This references the Service or Stored procedure - ELM,PROC,CALC';
COMMENT ON COLUMN sa.ubi_mtg_src_configurations.reference_element IS 'TBD based off discussions, this section determines the type of calculation to use. This could be a procedure or service. Something that describes what to call';
COMMENT ON COLUMN sa.ubi_mtg_src_configurations.reference_units IS 'This is the value that we are receiving from the source we get the value from - KB,MB,GB,UNITS,Money, etc.';