CREATE TABLE sa.table_x_case_exch_options (
  objid NUMBER,
  x_priority NUMBER,
  x_exch_type VARCHAR2(20 BYTE),
  source2conf_hdr NUMBER NOT NULL,
  x_new_part_num VARCHAR2(30 BYTE),
  x_used_part_num VARCHAR2(30 BYTE),
  x_days_for_used_part NUMBER,
  x_bonus_days NUMBER,
  x_bonus_units NUMBER,
  x_airbil_part_number VARCHAR2(30 BYTE),
  x_sim_part_number VARCHAR2(30 BYTE),
  x_upd_part_number VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.table_x_case_exch_options IS 'Hold the default exchange options for a specific case type/title';
COMMENT ON COLUMN sa.table_x_case_exch_options.objid IS 'Unique identified for the record.';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_priority IS 'Priority, order in which the information will be provided.';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_exch_type IS 'Exchange Type.';
COMMENT ON COLUMN sa.table_x_case_exch_options.source2conf_hdr IS 'Reference to table_x_case_conf_hdr.objid';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_new_part_num IS 'Part number that identifies the new phone required for exchange.';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_used_part_num IS 'Part number that identifies the refurbish phone required for exchange.';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_days_for_used_part IS 'ESN age that determines if the phone will be new or refurbish';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_bonus_days IS 'Bonus Days';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_bonus_units IS 'Bonus Units';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_airbil_part_number IS 'Part number that identifies airbill required for exchange.';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_sim_part_number IS 'SIM part number to be sent along with the exchange part number';
COMMENT ON COLUMN sa.table_x_case_exch_options.x_upd_part_number IS 'Part number that will replace the part number of the phone sent after unlocking';