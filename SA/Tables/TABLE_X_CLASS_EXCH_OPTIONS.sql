CREATE TABLE sa.table_x_class_exch_options (
  objid NUMBER,
  dev NUMBER,
  x_priority NUMBER,
  x_exch_type VARCHAR2(20 BYTE),
  source2part_class NUMBER,
  x_new_part_num VARCHAR2(30 BYTE),
  x_used_part_num VARCHAR2(30 BYTE),
  x_days_for_used_part NUMBER,
  x_bonus_days NUMBER,
  x_bonus_units NUMBER,
  x_airbil_part_number VARCHAR2(30 BYTE),
  x_sim_part_number VARCHAR2(30 BYTE),
  x_upd_part_number VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_class_exch_options ADD SUPPLEMENTAL LOG GROUP dmtsora517569502_0 (dev, objid, source2part_class, x_bonus_days, x_bonus_units, x_days_for_used_part, x_exch_type, x_new_part_num, x_priority, x_used_part_num) ALWAYS;
COMMENT ON COLUMN sa.table_x_class_exch_options.x_airbil_part_number IS 'PART NUMBER THAT IDENTIFIES AIRBILL REQUIRED FOR EXCHANGE.';
COMMENT ON COLUMN sa.table_x_class_exch_options.x_sim_part_number IS 'SIM part number to be sent along with the exchange part number';
COMMENT ON COLUMN sa.table_x_class_exch_options.x_upd_part_number IS 'Part number that will replace the part number of the phone sent after unlocking';