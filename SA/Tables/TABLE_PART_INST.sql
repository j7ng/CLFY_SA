CREATE TABLE sa.table_part_inst (
  objid NUMBER,
  part_good_qty NUMBER,
  part_bad_qty NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  part_mod VARCHAR2(10 BYTE),
  part_bin VARCHAR2(20 BYTE),
  last_pi_date DATE,
  pi_tag_no VARCHAR2(8 BYTE),
  last_cycle_ct DATE,
  next_cycle_ct DATE,
  last_mod_time DATE,
  last_trans_time DATE,
  transaction_id VARCHAR2(20 BYTE),
  date_in_serv DATE,
  warr_end_date DATE,
  repair_date DATE,
  part_status VARCHAR2(40 BYTE),
  pick_request VARCHAR2(255 BYTE),
  good_res_qty NUMBER,
  bad_res_qty NUMBER,
  dev NUMBER,
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
  x_npa VARCHAR2(10 BYTE),
  x_nxx VARCHAR2(10 BYTE),
  x_ext VARCHAR2(38 BYTE),
  x_order_number VARCHAR2(40 BYTE),
  part_inst2inv_bin NUMBER,
  n_part_inst2part_mod NUMBER,
  fulfill2demand_dtl NUMBER,
  part_inst2x_pers NUMBER,
  part_inst2x_new_pers NUMBER,
  part_inst2carrier_mkt NUMBER,
  created_by2user NUMBER,
  status2x_code_table NUMBER,
  part_to_esn2part_inst NUMBER,
  x_part_inst2site_part NUMBER,
  x_ld_processed VARCHAR2(10 BYTE),
  dtl2part_inst NUMBER,
  eco_new2part_inst NUMBER,
  hdr_ind NUMBER,
  x_msid VARCHAR2(30 BYTE),
  x_part_inst2contact NUMBER,
  x_iccid VARCHAR2(30 BYTE),
  x_clear_tank NUMBER,
  x_port_in NUMBER,
  x_hex_serial_no VARCHAR2(30 BYTE),
  x_parent_part_serial_no VARCHAR2(30 BYTE),
  x_wf_mac_id VARCHAR2(50 BYTE),
  cpo_manufacturer VARCHAR2(240 BYTE)
);
ALTER TABLE sa.table_part_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1087428170_1 (created_by2user, dtl2part_inst, eco_new2part_inst, fulfill2demand_dtl, hdr_ind, n_part_inst2part_mod, part_inst2carrier_mkt, part_inst2inv_bin, part_inst2x_new_pers, part_inst2x_pers, part_to_esn2part_inst, status2x_code_table, x_clear_tank, x_ext, x_hex_serial_no, x_iccid, x_ld_processed, x_msid, x_order_number, x_part_inst2contact, x_part_inst2site_part, x_port_in) ALWAYS;
ALTER TABLE sa.table_part_inst ADD SUPPLEMENTAL LOG GROUP dmtsora1087428170_0 (bad_res_qty, date_in_serv, dev, good_res_qty, last_cycle_ct, last_mod_time, last_pi_date, last_trans_time, next_cycle_ct, objid, part_bad_qty, part_bin, part_good_qty, part_mod, part_serial_no, part_status, pick_request, pi_tag_no, repair_date, transaction_id, warr_end_date, x_cool_end_date, x_creation_date, x_deactivation_flag, x_domain, x_insert_date, x_npa, x_nxx, x_part_inst_status, x_po_num, x_reactivation_flag, x_red_code, x_sequence) ALWAYS;
ALTER TABLE sa.table_part_inst ADD SUPPLEMENTAL LOG GROUP dmtsora85881232_0 (bad_res_qty, date_in_serv, dev, good_res_qty, last_cycle_ct, last_mod_time, last_pi_date, last_trans_time, next_cycle_ct, objid, part_bad_qty, part_bin, part_good_qty, part_mod, part_serial_no, part_status, pick_request, pi_tag_no, repair_date, transaction_id, warr_end_date, x_cool_end_date, x_creation_date, x_deactivation_flag, x_domain, x_insert_date, x_npa, x_nxx, x_part_inst_status, x_po_num, x_reactivation_flag, x_red_code, x_sequence) ALWAYS;
ALTER TABLE sa.table_part_inst ADD SUPPLEMENTAL LOG GROUP dmtsora85881232_1 (created_by2user, dtl2part_inst, eco_new2part_inst, fulfill2demand_dtl, hdr_ind, n_part_inst2part_mod, part_inst2carrier_mkt, part_inst2inv_bin, part_inst2x_new_pers, part_inst2x_pers, part_to_esn2part_inst, status2x_code_table, x_clear_tank, x_ext, x_hex_serial_no, x_iccid, x_ld_processed, x_msid, x_order_number, x_part_inst2contact, x_part_inst2site_part, x_port_in) ALWAYS;
ALTER TABLE sa.table_part_inst ADD SUPPLEMENTAL LOG GROUP dmtsora360759080_0 (bad_res_qty, date_in_serv, dev, good_res_qty, last_cycle_ct, last_mod_time, last_pi_date, last_trans_time, next_cycle_ct, objid, part_bad_qty, part_bin, part_good_qty, part_mod, part_serial_no, part_status, pick_request, pi_tag_no, repair_date, transaction_id, warr_end_date, x_cool_end_date, x_creation_date, x_deactivation_flag, x_domain, x_insert_date, x_npa, x_nxx, x_part_inst_status, x_po_num, x_reactivation_flag, x_red_code, x_sequence) ALWAYS;
ALTER TABLE sa.table_part_inst ADD SUPPLEMENTAL LOG GROUP dmtsora360759080_1 (created_by2user, dtl2part_inst, eco_new2part_inst, fulfill2demand_dtl, hdr_ind, n_part_inst2part_mod, part_inst2carrier_mkt, part_inst2inv_bin, part_inst2x_new_pers, part_inst2x_pers, part_to_esn2part_inst, status2x_code_table, x_clear_tank, x_ext, x_hex_serial_no, x_iccid, x_ld_processed, x_msid, x_order_number, x_part_inst2contact, x_part_inst2site_part, x_port_in) ALWAYS;
COMMENT ON TABLE sa.table_part_inst IS 'Describes an instance of an inventory part. If serialized it is one part in inventory. If tracked-by-quantity, it is a quantity of like parts in an inventory location';
COMMENT ON COLUMN sa.table_part_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_part_inst.part_good_qty IS 'For parts tracked by quantity, the quantity usable';
COMMENT ON COLUMN sa.table_part_inst.part_bad_qty IS 'FOR A PHONE PART THE ESN EXCHANGE COUNTER';
COMMENT ON COLUMN sa.table_part_inst.part_serial_no IS 'For parts tracked by serial number, the part serial number';
COMMENT ON COLUMN sa.table_part_inst.part_mod IS 'The part revision number';
COMMENT ON COLUMN sa.table_part_inst.part_bin IS 'The inventory bin the part is now located in';
COMMENT ON COLUMN sa.table_part_inst.last_pi_date IS 'Date of the last inventory count reconciliation for the inventory part';
COMMENT ON COLUMN sa.table_part_inst.pi_tag_no IS 'Tag number associated with the last inventory count reconciliation for the inventory part';
COMMENT ON COLUMN sa.table_part_inst.last_cycle_ct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_inst.next_cycle_ct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_inst.last_mod_time IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_inst.last_trans_time IS 'Date and time of the last transaction against the inventory part';
COMMENT ON COLUMN sa.table_part_inst.transaction_id IS 'The unique number of the part transaction';
COMMENT ON COLUMN sa.table_part_inst.date_in_serv IS 'Date the part was placed in service';
COMMENT ON COLUMN sa.table_part_inst.warr_end_date IS 'Date the warranty expires';
COMMENT ON COLUMN sa.table_part_inst.repair_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_part_inst.part_status IS 'Status of the inventory part';
COMMENT ON COLUMN sa.table_part_inst.pick_request IS 'The detail numbers for the requests that have currently picked the part';
COMMENT ON COLUMN sa.table_part_inst.good_res_qty IS 'For parts tracked by quantity, the good reserved quantity';
COMMENT ON COLUMN sa.table_part_inst.bad_res_qty IS 'For parts tracked by quantity, the bad reserved quantity';
COMMENT ON COLUMN sa.table_part_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_part_inst.x_insert_date IS 'The Date on which the line was received from carrier';
COMMENT ON COLUMN sa.table_part_inst.x_sequence IS 'The Number of times that codes have been entered into the phone';
COMMENT ON COLUMN sa.table_part_inst.x_creation_date IS 'The Date of Part Creation';
COMMENT ON COLUMN sa.table_part_inst.x_po_num IS 'The Purchase Order Number for the Part';
COMMENT ON COLUMN sa.table_part_inst.x_red_code IS 'Redemption Code';
COMMENT ON COLUMN sa.table_part_inst.x_domain IS 'Domain of the Part (Phones, Cards, Lines)';
COMMENT ON COLUMN sa.table_part_inst.x_deactivation_flag IS 'Flag that denotes deactivation of MIN';
COMMENT ON COLUMN sa.table_part_inst.x_reactivation_flag IS 'Flag that denotes reactivation of MIN';
COMMENT ON COLUMN sa.table_part_inst.x_cool_end_date IS 'Cooling period end date';
COMMENT ON COLUMN sa.table_part_inst.x_part_inst_status IS 'Status of the inventory part - custom';
COMMENT ON COLUMN sa.table_part_inst.x_npa IS 'NPA value for MIN';
COMMENT ON COLUMN sa.table_part_inst.x_nxx IS 'NXX value for MIN';
COMMENT ON COLUMN sa.table_part_inst.x_ext IS 'Extension value for MIN';
COMMENT ON COLUMN sa.table_part_inst.x_order_number IS 'Order Number (Oracle Financials interface)';
COMMENT ON COLUMN sa.table_part_inst.part_inst2inv_bin IS 'Inventory bin in which the instance is currently located';
COMMENT ON COLUMN sa.table_part_inst.n_part_inst2part_mod IS 'The part version of the inventory part';
COMMENT ON COLUMN sa.table_part_inst.fulfill2demand_dtl IS 'Reserved; obsolete. Replaced by fulflld2demand_dtl';
COMMENT ON COLUMN sa.table_part_inst.part_inst2x_pers IS 'Old Personality Relation to Part Instance';
COMMENT ON COLUMN sa.table_part_inst.part_inst2x_new_pers IS 'New Personality Relation to Part Instance';
COMMENT ON COLUMN sa.table_part_inst.part_inst2carrier_mkt IS 'Carrier Market of Part Instance';
COMMENT ON COLUMN sa.table_part_inst.created_by2user IS 'Creator of the part instance';
COMMENT ON COLUMN sa.table_part_inst.status2x_code_table IS 'Part status relation to code table';
COMMENT ON COLUMN sa.table_part_inst.part_to_esn2part_inst IS 'Reserved ESN for the part';
COMMENT ON COLUMN sa.table_part_inst.x_part_inst2site_part IS 'Part Inst to Site Part';
COMMENT ON COLUMN sa.table_part_inst.x_ld_processed IS 'Flag used for Batch Line process';
COMMENT ON COLUMN sa.table_part_inst.dtl2part_inst IS 'Header part inst tracking the detail serial numbered instance';
COMMENT ON COLUMN sa.table_part_inst.eco_new2part_inst IS 'The part instance the current part instance was upgraded from';
COMMENT ON COLUMN sa.table_part_inst.hdr_ind IS 'Whether the part instance is a header which tracks a group of serialized part instances; 0=serial tracked part instance, 1=serial tracked header instance, 2=quantity tracked part instance, 3=empty serial tracked header instance, default=0';
COMMENT ON COLUMN sa.table_part_inst.x_msid IS 'MSID';
COMMENT ON COLUMN sa.table_part_inst.x_part_inst2contact IS 'Part Inst related to contact';
COMMENT ON COLUMN sa.table_part_inst.x_iccid IS 'SIM Serial Number';
COMMENT ON COLUMN sa.table_part_inst.x_clear_tank IS 'Flag that denotes esn will receive a clear time tank code dusring next reac';
COMMENT ON COLUMN sa.table_part_inst.x_port_in IS 'Flag to signal that the line is a port in line';
COMMENT ON COLUMN sa.table_part_inst.x_hex_serial_no IS 'hexadecimal serial number';
COMMENT ON COLUMN sa.table_part_inst.x_parent_part_serial_no IS 'BUNDLE SCAN NUMBER';