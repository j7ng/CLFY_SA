CREATE TABLE sa.table_x_road_inst (
  objid NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  part_mod VARCHAR2(10 BYTE),
  part_bin VARCHAR2(20 BYTE),
  transaction_id VARCHAR2(20 BYTE),
  warr_end_date DATE,
  repair_date DATE,
  part_status VARCHAR2(40 BYTE),
  x_insert_date DATE,
  x_sequence NUMBER,
  x_creation_date DATE,
  x_po_num VARCHAR2(30 BYTE),
  x_red_code VARCHAR2(30 BYTE),
  x_domain VARCHAR2(20 BYTE),
  x_deactivation_flag NUMBER,
  x_reactivation_flag NUMBER,
  x_cool_end_date DATE,
  x_part_inst_status VARCHAR2(20 BYTE),
  x_order_number VARCHAR2(40 BYTE),
  x_hist_update NUMBER,
  n_road_inst2part_mod NUMBER,
  rd_create2user NUMBER,
  rd_status2x_code_table NUMBER,
  road_inst2inv_bin NUMBER,
  x_road_inst2contact NUMBER,
  x_road_inst2site_part NUMBER
);
ALTER TABLE sa.table_x_road_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1419634133_0 (n_road_inst2part_mod, objid, part_bin, part_mod, part_serial_no, part_status, rd_create2user, rd_status2x_code_table, repair_date, road_inst2inv_bin, transaction_id, warr_end_date, x_cool_end_date, x_creation_date, x_deactivation_flag, x_domain, x_hist_update, x_insert_date, x_order_number, x_part_inst_status, x_po_num, x_reactivation_flag, x_red_code, x_road_inst2contact, x_road_inst2site_part, x_sequence) ALWAYS;
COMMENT ON TABLE sa.table_x_road_inst IS 'Describes an instance of an inventory roadside part.';
COMMENT ON COLUMN sa.table_x_road_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_road_inst.part_serial_no IS 'For parts tracked by serial number, the part serial number';
COMMENT ON COLUMN sa.table_x_road_inst.part_mod IS 'The part revision number';
COMMENT ON COLUMN sa.table_x_road_inst.part_bin IS 'The inventory bin the part is now located in';
COMMENT ON COLUMN sa.table_x_road_inst.transaction_id IS 'The unique number of the part transaction';
COMMENT ON COLUMN sa.table_x_road_inst.warr_end_date IS 'Date the warranty expires';
COMMENT ON COLUMN sa.table_x_road_inst.repair_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_x_road_inst.part_status IS 'Status of the inventory part';
COMMENT ON COLUMN sa.table_x_road_inst.x_insert_date IS 'The Date on which the line was received from carrier';
COMMENT ON COLUMN sa.table_x_road_inst.x_sequence IS 'The Number of times that codes have been entered into the phone';
COMMENT ON COLUMN sa.table_x_road_inst.x_creation_date IS 'The Date of Part Creation';
COMMENT ON COLUMN sa.table_x_road_inst.x_po_num IS 'The Purchase Order Number for the Part';
COMMENT ON COLUMN sa.table_x_road_inst.x_red_code IS 'Redemption Code';
COMMENT ON COLUMN sa.table_x_road_inst.x_domain IS 'Domain of the Part (Phones, Cards, Lines)';
COMMENT ON COLUMN sa.table_x_road_inst.x_deactivation_flag IS 'Flag that denotes deactivation of MIN';
COMMENT ON COLUMN sa.table_x_road_inst.x_reactivation_flag IS 'Flag that denotes reactivation of MIN';
COMMENT ON COLUMN sa.table_x_road_inst.x_cool_end_date IS 'Cooling period end date';
COMMENT ON COLUMN sa.table_x_road_inst.x_part_inst_status IS 'Status of the inventory part - custom';
COMMENT ON COLUMN sa.table_x_road_inst.x_order_number IS 'Order Number (Oracle Financials interface)';
COMMENT ON COLUMN sa.table_x_road_inst.x_hist_update IS 'Used to determine writing to x_road_hist.  1= don"t write  0=write';
COMMENT ON COLUMN sa.table_x_road_inst.n_road_inst2part_mod IS 'The part version of the inventory part';
COMMENT ON COLUMN sa.table_x_road_inst.rd_create2user IS 'Creator of the part instance';
COMMENT ON COLUMN sa.table_x_road_inst.rd_status2x_code_table IS 'Part status relation to code table';
COMMENT ON COLUMN sa.table_x_road_inst.road_inst2inv_bin IS 'Inventory bin in which the instance is currently located';
COMMENT ON COLUMN sa.table_x_road_inst.x_road_inst2contact IS 'reserved road card to contact';
COMMENT ON COLUMN sa.table_x_road_inst.x_road_inst2site_part IS 'Part Inst to Site Part';