CREATE TABLE sa.table_x_ild_hist (
  objid NUMBER,
  dev NUMBER,
  x_part_serial_no VARCHAR2(30 BYTE),
  x_creation_date DATE,
  x_po_num VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  x_change_date DATE,
  x_change_reason VARCHAR2(30 BYTE),
  x_domain VARCHAR2(20 BYTE),
  x_purchase_time DATE,
  x_order_number VARCHAR2(40 BYTE),
  x_macaw_id NUMBER,
  x_invoice_id NUMBER,
  x_invoice_date DATE,
  x_red_code VARCHAR2(30 BYTE),
  ild_hist2x_code_table NUMBER,
  ild_hist2inv_bin NUMBER,
  ild_hist2mod_level NUMBER,
  ild_hist2ild_inst NUMBER,
  ild_hist2user NUMBER,
  ild_hist2contact NUMBER
);
ALTER TABLE sa.table_x_ild_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1629541874_0 (dev, ild_hist2contact, ild_hist2ild_inst, ild_hist2inv_bin, ild_hist2mod_level, ild_hist2user, ild_hist2x_code_table, objid, x_change_date, x_change_reason, x_creation_date, x_domain, x_invoice_date, x_invoice_id, x_macaw_id, x_order_number, x_part_inst_status, x_part_serial_no, x_po_num, x_purchase_time, x_red_code) ALWAYS;
COMMENT ON TABLE sa.table_x_ild_hist IS 'History for ILD Inventory';
COMMENT ON COLUMN sa.table_x_ild_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ild_hist.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ild_hist.x_part_serial_no IS 'ILD Part Serial No';
COMMENT ON COLUMN sa.table_x_ild_hist.x_creation_date IS 'Original ILD Inventory Creation Date from x_cc_ild_inv';
COMMENT ON COLUMN sa.table_x_ild_hist.x_po_num IS 'Purchase Order Number';
COMMENT ON COLUMN sa.table_x_ild_hist.x_part_inst_status IS 'part inst status code for x_code_table';
COMMENT ON COLUMN sa.table_x_ild_hist.x_change_date IS 'Date of the update';
COMMENT ON COLUMN sa.table_x_ild_hist.x_change_reason IS 'description of the change';
COMMENT ON COLUMN sa.table_x_ild_hist.x_domain IS 'Domain Description';
COMMENT ON COLUMN sa.table_x_ild_hist.x_purchase_time IS 'Purchase Date Time Stamp from x_ild_inst';
COMMENT ON COLUMN sa.table_x_ild_hist.x_order_number IS 'Order Number';
COMMENT ON COLUMN sa.table_x_ild_hist.x_macaw_id IS 'Vendor Id';
COMMENT ON COLUMN sa.table_x_ild_hist.x_invoice_id IS 'Invoice ID from vendor';
COMMENT ON COLUMN sa.table_x_ild_hist.x_invoice_date IS 'Invoice Date from vendor';
COMMENT ON COLUMN sa.table_x_ild_hist.x_red_code IS 'ILD Pin Number';
COMMENT ON COLUMN sa.table_x_ild_hist.ild_hist2x_code_table IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_hist.ild_hist2inv_bin IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_hist.ild_hist2mod_level IS ' User performing the change';
COMMENT ON COLUMN sa.table_x_ild_hist.ild_hist2ild_inst IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_hist.ild_hist2user IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_hist.ild_hist2contact IS 'TBD';