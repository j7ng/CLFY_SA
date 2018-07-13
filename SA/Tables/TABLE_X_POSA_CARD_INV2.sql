CREATE TABLE sa.table_x_posa_card_inv2 (
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
ALTER TABLE sa.table_x_posa_card_inv2 ADD SUPPLEMENTAL LOG GROUP dmtsora1239884485_0 (objid, x_created_by2user, x_domain, x_inv_insert_date, x_last_ship_date, x_last_update_by2user, x_last_update_date, x_part_serial_no, x_posa_inv2inv_bin, x_posa_inv2part_mod, x_posa_inv_status, x_posa_status2x_code_table, x_red_code, x_tf_order_number, x_tf_po_number) ALWAYS;