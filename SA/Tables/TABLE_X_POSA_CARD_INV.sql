CREATE TABLE sa.table_x_posa_card_inv (
  objid NUMBER,
  x_part_serial_no VARCHAR2(30 BYTE),
  x_domain VARCHAR2(20 BYTE),
  x_red_code VARCHAR2(30 BYTE),
  x_posa_inv_status VARCHAR2(20 BYTE),
  x_inv_insert_date DATE,
  x_last_ship_date DATE,
  x_tf_po_number VARCHAR2(30 BYTE),
  x_tf_order_number VARCHAR2(40 BYTE),
  x_last_update_date DATE,
  x_created_by2user NUMBER,
  x_last_update_by2user NUMBER,
  x_posa_status2x_code_table NUMBER,
  x_posa_inv2part_mod NUMBER,
  x_posa_inv2inv_bin NUMBER
);
ALTER TABLE sa.table_x_posa_card_inv ADD SUPPLEMENTAL LOG GROUP dmtsora1322582723_0 (objid, x_created_by2user, x_domain, x_inv_insert_date, x_last_ship_date, x_last_update_by2user, x_last_update_date, x_part_serial_no, x_posa_inv2inv_bin, x_posa_inv2part_mod, x_posa_inv_status, x_posa_status2x_code_table, x_red_code, x_tf_order_number, x_tf_po_number) ALWAYS;
COMMENT ON TABLE sa.table_x_posa_card_inv IS 'Stores the available POSA cards';
COMMENT ON COLUMN sa.table_x_posa_card_inv.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_part_serial_no IS 'For parts tracked by serial number, the part serial number';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_domain IS 'Domain of the Part (Phones, Cards, Lines)';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_red_code IS 'Redemption Code';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_posa_inv_status IS 'Status of the inventory part';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_inv_insert_date IS 'The Date on which the line was received from carrier';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_last_ship_date IS 'The Date on which the line was received from carrier';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_tf_po_number IS 'The Purchase Order Number for the Part';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_tf_order_number IS 'Order Number (Oracle Financials interface)';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_last_update_date IS 'Last update date';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_created_by2user IS 'Creator of the part instance';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_last_update_by2user IS 'Updater of the part instance';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_posa_status2x_code_table IS 'Part status relation to code table';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_posa_inv2part_mod IS 'The part version of the inventory part';
COMMENT ON COLUMN sa.table_x_posa_card_inv.x_posa_inv2inv_bin IS 'Inventory bin in which the instance is currently located';