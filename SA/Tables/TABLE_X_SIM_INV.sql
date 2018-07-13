CREATE TABLE sa.table_x_sim_inv (
  objid NUMBER,
  x_sim_serial_no VARCHAR2(30 BYTE),
  x_sim_inv_status VARCHAR2(30 BYTE),
  x_sim_mnc VARCHAR2(6 BYTE),
  x_inv_insert_date DATE,
  x_last_ship_date DATE,
  x_sim_po_number VARCHAR2(30 BYTE),
  x_sim_order_number VARCHAR2(40 BYTE),
  x_last_update_date DATE,
  x_sim_inv2part_mod NUMBER,
  x_created_by2user NUMBER,
  x_sim_status2x_code_table NUMBER,
  x_sim_inv2inv_bin NUMBER,
  x_pin1 VARCHAR2(30 BYTE),
  x_pin2 VARCHAR2(30 BYTE),
  x_puk1 VARCHAR2(30 BYTE),
  x_puk2 VARCHAR2(30 BYTE),
  x_qty NUMBER,
  x_sim_imsi VARCHAR2(30 BYTE),
  ig_imsi VARCHAR2(40 BYTE),
  expiration_date DATE
);
ALTER TABLE sa.table_x_sim_inv ADD SUPPLEMENTAL LOG GROUP dmtsora103264909_0 (objid, x_created_by2user, x_inv_insert_date, x_last_ship_date, x_last_update_date, x_pin1, x_pin2, x_puk1, x_puk2, x_qty, x_sim_inv2inv_bin, x_sim_inv2part_mod, x_sim_inv_status, x_sim_mnc, x_sim_order_number, x_sim_po_number, x_sim_serial_no, x_sim_status2x_code_table) ALWAYS;
COMMENT ON TABLE sa.table_x_sim_inv IS 'Stores SIM parameters';
COMMENT ON COLUMN sa.table_x_sim_inv.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_serial_no IS 'For parts tracked by serial number, the SIM serial number';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_inv_status IS 'Status of the SIM inventory part';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_mnc IS 'SIM MNC';
COMMENT ON COLUMN sa.table_x_sim_inv.x_inv_insert_date IS 'The Date on which the SIM was received from manufacturer';
COMMENT ON COLUMN sa.table_x_sim_inv.x_last_ship_date IS 'The Date on which the SIM was shipped to retailer';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_po_number IS 'The Purchase Order Number for the Part';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_order_number IS 'Order Number (Oracle Financials interface)';
COMMENT ON COLUMN sa.table_x_sim_inv.x_last_update_date IS 'Last update date';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_inv2part_mod IS 'The part version of the SIM';
COMMENT ON COLUMN sa.table_x_sim_inv.x_created_by2user IS 'Creator of the part instance';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_status2x_code_table IS 'Part status relation to code table';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_inv2inv_bin IS 'Inventory bin in which the instance is currently located';
COMMENT ON COLUMN sa.table_x_sim_inv.x_pin1 IS 'Pin 1';
COMMENT ON COLUMN sa.table_x_sim_inv.x_pin2 IS 'Pin 2';
COMMENT ON COLUMN sa.table_x_sim_inv.x_puk1 IS 'Puk 1';
COMMENT ON COLUMN sa.table_x_sim_inv.x_puk2 IS 'Puk 2';
COMMENT ON COLUMN sa.table_x_sim_inv.x_qty IS 'Quantity';
COMMENT ON COLUMN sa.table_x_sim_inv.x_sim_imsi IS 'THIS IS IMSI NUMBER FOR THE SIM';
COMMENT ON COLUMN sa.table_x_sim_inv.ig_imsi IS 'TO CAMPTURE THE IMSI VALUE FROM IG TRANSACTION TABLE';
COMMENT ON COLUMN sa.table_x_sim_inv.expiration_date IS 'SIM Expiry Date';