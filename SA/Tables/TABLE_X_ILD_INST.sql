CREATE TABLE sa.table_x_ild_inst (
  objid NUMBER,
  dev NUMBER,
  x_part_serial_no VARCHAR2(30 BYTE),
  x_creation_date DATE,
  x_po_num VARCHAR2(30 BYTE),
  x_red_code VARCHAR2(30 BYTE),
  x_domain VARCHAR2(20 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  x_order_number VARCHAR2(40 BYTE),
  x_purchase_time DATE,
  x_last_update DATE,
  x_macaw_id NUMBER,
  x_invoice_id NUMBER,
  x_invoice_date DATE,
  x_tf_ani1 VARCHAR2(30 BYTE),
  x_tf_ani2 VARCHAR2(30 BYTE),
  x_tf_ani3 VARCHAR2(30 BYTE),
  x_tf_ani4 VARCHAR2(30 BYTE),
  x_tf_ani5 VARCHAR2(30 BYTE),
  ild_inst2part_mod NUMBER,
  ild_status2code_table NUMBER,
  ild_inst2inv_bin NUMBER,
  last_update_by2user NUMBER,
  ild_inst2contact NUMBER,
  created_by2user NUMBER
);
ALTER TABLE sa.table_x_ild_inst ADD SUPPLEMENTAL LOG GROUP dmtsora137740471_0 (created_by2user, dev, ild_inst2contact, ild_inst2inv_bin, ild_inst2part_mod, ild_status2code_table, last_update_by2user, objid, x_creation_date, x_domain, x_invoice_date, x_invoice_id, x_last_update, x_macaw_id, x_order_number, x_part_inst_status, x_part_serial_no, x_po_num, x_purchase_time, x_red_code, x_tf_ani1, x_tf_ani2, x_tf_ani3, x_tf_ani4, x_tf_ani5) ALWAYS;
COMMENT ON TABLE sa.table_x_ild_inst IS 'ILD Inventory after cards are sold';
COMMENT ON COLUMN sa.table_x_ild_inst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_ild_inst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_ild_inst.x_part_serial_no IS 'Part Serial No';
COMMENT ON COLUMN sa.table_x_ild_inst.x_creation_date IS 'Date of Inventory Record Creation';
COMMENT ON COLUMN sa.table_x_ild_inst.x_po_num IS 'Purchase Order Number';
COMMENT ON COLUMN sa.table_x_ild_inst.x_red_code IS 'ILD Pin Code';
COMMENT ON COLUMN sa.table_x_ild_inst.x_domain IS 'Type of Inventory';
COMMENT ON COLUMN sa.table_x_ild_inst.x_part_inst_status IS 'Part Inst Status (See x_code_table)';
COMMENT ON COLUMN sa.table_x_ild_inst.x_order_number IS 'Order Number';
COMMENT ON COLUMN sa.table_x_ild_inst.x_purchase_time IS 'Date Time of Purchase';
COMMENT ON COLUMN sa.table_x_ild_inst.x_last_update IS 'Date Time of last update';
COMMENT ON COLUMN sa.table_x_ild_inst.x_macaw_id IS 'Vendor Id';
COMMENT ON COLUMN sa.table_x_ild_inst.x_invoice_id IS 'Invoice ID';
COMMENT ON COLUMN sa.table_x_ild_inst.x_invoice_date IS 'Invoice Date';
COMMENT ON COLUMN sa.table_x_ild_inst.x_tf_ani1 IS 'ILD ANI Phone Number1';
COMMENT ON COLUMN sa.table_x_ild_inst.x_tf_ani2 IS 'ILD ANI Phone Number2';
COMMENT ON COLUMN sa.table_x_ild_inst.x_tf_ani3 IS 'ILD ANI Phone Number3';
COMMENT ON COLUMN sa.table_x_ild_inst.x_tf_ani4 IS 'ILD ANI Phone Number4';
COMMENT ON COLUMN sa.table_x_ild_inst.x_tf_ani5 IS 'ILD ANI Phone Number5';
COMMENT ON COLUMN sa.table_x_ild_inst.ild_inst2part_mod IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_inst.ild_status2code_table IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_inst.ild_inst2inv_bin IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_inst.last_update_by2user IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_inst.ild_inst2contact IS 'TBD';
COMMENT ON COLUMN sa.table_x_ild_inst.created_by2user IS 'TBD';