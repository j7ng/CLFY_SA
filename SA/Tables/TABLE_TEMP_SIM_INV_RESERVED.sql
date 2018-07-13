CREATE TABLE sa.table_temp_sim_inv_reserved (
  x_sim_serial_no VARCHAR2(30 BYTE),
  pi_serial_no VARCHAR2(25 BYTE),
  sim_inv_objid NUMBER,
  sim_inv_status VARCHAR2(30 BYTE),
  x_sim_po_number VARCHAR2(30 BYTE),
  x_sim_imsi VARCHAR2(30 BYTE),
  part_num_objid NUMBER,
  part_number VARCHAR2(30 BYTE),
  domain VARCHAR2(40 BYTE),
  x_inv_insert_date DATE,
  x_inv_last_update_date DATE,
  x_processed_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  update_status VARCHAR2(50 BYTE),
  update_date DATE
);