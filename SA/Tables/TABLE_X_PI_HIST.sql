CREATE TABLE sa.table_x_pi_hist (
  objid NUMBER,
  status_hist2x_code_table NUMBER,
  x_change_date DATE,
  x_change_reason VARCHAR2(30 BYTE),
  x_cool_end_date DATE,
  x_creation_date DATE,
  x_deactivation_flag NUMBER,
  x_domain VARCHAR2(20 BYTE),
  x_ext VARCHAR2(38 BYTE),
  x_insert_date DATE,
  x_npa VARCHAR2(10 BYTE),
  x_nxx VARCHAR2(10 BYTE),
  x_old_ext VARCHAR2(10 BYTE),
  x_old_npa VARCHAR2(10 BYTE),
  x_old_nxx VARCHAR2(10 BYTE),
  x_part_bin VARCHAR2(20 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  x_part_mod VARCHAR2(10 BYTE),
  x_part_serial_no VARCHAR2(30 BYTE),
  x_part_status VARCHAR2(40 BYTE),
  x_pi_hist2carrier_mkt NUMBER,
  x_pi_hist2inv_bin NUMBER,
  x_pi_hist2part_inst NUMBER,
  x_pi_hist2part_mod NUMBER,
  x_pi_hist2user NUMBER,
  x_pi_hist2x_new_pers NUMBER,
  x_pi_hist2x_pers NUMBER,
  x_po_num VARCHAR2(30 BYTE),
  x_reactivation_flag NUMBER,
  x_red_code VARCHAR2(30 BYTE),
  x_sequence NUMBER,
  x_warr_end_date DATE,
  dev NUMBER,
  fulfill_hist2demand_dtl NUMBER,
  part_to_esn_hist2part_inst NUMBER,
  x_bad_res_qty NUMBER,
  x_date_in_serv DATE,
  x_good_res_qty NUMBER,
  x_last_cycle_ct DATE,
  x_last_mod_time DATE,
  x_last_pi_date DATE,
  x_last_trans_time DATE,
  x_next_cycle_ct DATE,
  x_order_number VARCHAR2(40 BYTE),
  x_part_bad_qty NUMBER,
  x_part_good_qty NUMBER,
  x_pi_tag_no VARCHAR2(8 BYTE),
  x_pick_request VARCHAR2(255 BYTE),
  x_repair_date DATE,
  x_transaction_id VARCHAR2(20 BYTE),
  x_pi_hist2site_part NUMBER,
  x_msid VARCHAR2(30 BYTE),
  x_pi_hist2contact NUMBER,
  x_iccid VARCHAR2(30 BYTE)
);
ALTER TABLE sa.table_x_pi_hist ADD SUPPLEMENTAL LOG GROUP dmtsora614409903_0 (dev, objid, status_hist2x_code_table, x_change_date, x_change_reason, x_cool_end_date, x_creation_date, x_deactivation_flag, x_domain, x_ext, x_insert_date, x_npa, x_nxx, x_old_ext, x_old_npa, x_old_nxx, x_part_bin, x_part_inst_status, x_part_mod, x_part_serial_no, x_part_status, x_pi_hist2carrier_mkt, x_pi_hist2inv_bin, x_pi_hist2part_inst, x_pi_hist2part_mod, x_pi_hist2user, x_pi_hist2x_new_pers, x_pi_hist2x_pers, x_po_num, x_reactivation_flag, x_red_code, x_sequence, x_warr_end_date) ALWAYS;
ALTER TABLE sa.table_x_pi_hist ADD SUPPLEMENTAL LOG GROUP dmtsora614409903_1 (fulfill_hist2demand_dtl, part_to_esn_hist2part_inst, x_bad_res_qty, x_date_in_serv, x_good_res_qty, x_iccid, x_last_cycle_ct, x_last_mod_time, x_last_pi_date, x_last_trans_time, x_msid, x_next_cycle_ct, x_order_number, x_part_bad_qty, x_part_good_qty, x_pick_request, x_pi_hist2contact, x_pi_hist2site_part, x_pi_tag_no, x_repair_date, x_transaction_id) ALWAYS;
COMMENT ON TABLE sa.table_x_pi_hist IS 'Contains history of line characteristics';
COMMENT ON COLUMN sa.table_x_pi_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_pi_hist.status_hist2x_code_table IS 'History: Part status relation to code table';
COMMENT ON COLUMN sa.table_x_pi_hist.x_change_date IS 'Last change date/transaction date';
COMMENT ON COLUMN sa.table_x_pi_hist.x_change_reason IS 'Change reason';
COMMENT ON COLUMN sa.table_x_pi_hist.x_cool_end_date IS 'Cooling period end date';
COMMENT ON COLUMN sa.table_x_pi_hist.x_creation_date IS 'The Date of Part Creation';
COMMENT ON COLUMN sa.table_x_pi_hist.x_deactivation_flag IS 'Flag that denotes deactivation of MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_domain IS 'Domain of the Part (Phones, Cards, Lines)';
COMMENT ON COLUMN sa.table_x_pi_hist.x_ext IS 'Extension value for MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_insert_date IS 'The Date on which the line was received from carrier';
COMMENT ON COLUMN sa.table_x_pi_hist.x_npa IS 'NPA value for MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_nxx IS 'NXX value for MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_old_ext IS 'Old extension value for MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_old_npa IS 'Old NPA value for MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_old_nxx IS 'Old NXX value for MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_part_bin IS 'The inventory bin the part is now located in';
COMMENT ON COLUMN sa.table_x_pi_hist.x_part_inst_status IS 'Status of the inventory part - custom';
COMMENT ON COLUMN sa.table_x_pi_hist.x_part_mod IS 'The part revision number';
COMMENT ON COLUMN sa.table_x_pi_hist.x_part_serial_no IS 'For parts tracked by serial number, the part serial number';
COMMENT ON COLUMN sa.table_x_pi_hist.x_part_status IS 'Status of the inventory part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2carrier_mkt IS 'History: Carrier Market of Part Instance';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2inv_bin IS 'History: Inventory bin in which the instance is currently located';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2part_inst IS 'History: Relation to Part Instance';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2part_mod IS 'History: The part version of the inventory part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2user IS 'History: Relation to User initiating change';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2x_new_pers IS 'History: New Personality Relation to Part Instance';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2x_pers IS 'History: Old Personality Relation to Part Instance';
COMMENT ON COLUMN sa.table_x_pi_hist.x_po_num IS 'The Purchase Order Number for the Part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_reactivation_flag IS 'Flag that denotes reactivation of MIN';
COMMENT ON COLUMN sa.table_x_pi_hist.x_red_code IS 'Redemption Code';
COMMENT ON COLUMN sa.table_x_pi_hist.x_sequence IS 'The Number of times that codes have been entered into the phone';
COMMENT ON COLUMN sa.table_x_pi_hist.x_warr_end_date IS 'Date the warranty expires';
COMMENT ON COLUMN sa.table_x_pi_hist.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_pi_hist.fulfill_hist2demand_dtl IS 'History: Part request last fulfilled by the part instance';
COMMENT ON COLUMN sa.table_x_pi_hist.part_to_esn_hist2part_inst IS 'History: Reserved ESN for the part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_bad_res_qty IS 'For parts tracked by quantity, the bad reserved quantity';
COMMENT ON COLUMN sa.table_x_pi_hist.x_date_in_serv IS 'Date the part was placed in service';
COMMENT ON COLUMN sa.table_x_pi_hist.x_good_res_qty IS 'For parts tracked by quantity, the good reserved quantity';
COMMENT ON COLUMN sa.table_x_pi_hist.x_last_cycle_ct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_x_pi_hist.x_last_mod_time IS 'Reserved; future';
COMMENT ON COLUMN sa.table_x_pi_hist.x_last_pi_date IS 'Date of the last inventory count reconciliation for the inventory part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_last_trans_time IS 'Date and time of the last transaction against the inventory part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_next_cycle_ct IS 'Reserved; future';
COMMENT ON COLUMN sa.table_x_pi_hist.x_order_number IS 'Order Number (Oracle Financials interface)';
COMMENT ON COLUMN sa.table_x_pi_hist.x_part_bad_qty IS 'For parts tracked by quantity, the quantity not usable';
COMMENT ON COLUMN sa.table_x_pi_hist.x_part_good_qty IS 'For parts tracked by quantity, the quantity usable';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_tag_no IS 'Tag number associated with the last inventory count reconciliation for the inventory part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pick_request IS 'The detail numbers for the requests that have currently picked the part';
COMMENT ON COLUMN sa.table_x_pi_hist.x_repair_date IS 'Reserved; future';
COMMENT ON COLUMN sa.table_x_pi_hist.x_transaction_id IS 'The unique number of the part transaction';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2site_part IS 'History : Mirror of  Site Part to Part Inst Relation';
COMMENT ON COLUMN sa.table_x_pi_hist.x_msid IS 'MSID';
COMMENT ON COLUMN sa.table_x_pi_hist.x_pi_hist2contact IS 'History : Mirror of  pi to contact Relation';
COMMENT ON COLUMN sa.table_x_pi_hist.x_iccid IS 'SIM Serial Number';