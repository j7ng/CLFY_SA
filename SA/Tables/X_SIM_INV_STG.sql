CREATE TABLE sa.x_sim_inv_stg (
  trans_id NUMBER,
  sim_serial_num VARCHAR2(30 BYTE),
  sim_po_num VARCHAR2(30 BYTE),
  part_num VARCHAR2(30 BYTE),
  manuf_site_id VARCHAR2(30 BYTE),
  manuf_name VARCHAR2(45 BYTE),
  insert_date DATE,
  pin1 VARCHAR2(30 BYTE),
  pin2 VARCHAR2(30 BYTE),
  puk1 VARCHAR2(30 BYTE),
  puk2 VARCHAR2(30 BYTE),
  qty NUMBER,
  userobjid NUMBER
);
ALTER TABLE sa.x_sim_inv_stg ADD SUPPLEMENTAL LOG GROUP dmtsora635887450_0 (insert_date, manuf_name, manuf_site_id, part_num, pin1, pin2, puk1, puk2, qty, sim_po_num, sim_serial_num, trans_id, userobjid) ALWAYS;