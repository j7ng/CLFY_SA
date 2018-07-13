CREATE TABLE sa.revert_cr4454_app (
  x_service_id VARCHAR2(20 BYTE),
  rc_objid NUMBER,
  x_smp VARCHAR2(20 BYTE),
  part_number VARCHAR2(20 BYTE),
  ml_objid NUMBER,
  bin_objid NUMBER,
  x_inv_insert_date DATE,
  x_last_ship_date DATE,
  x_po_num VARCHAR2(20 BYTE),
  x_red_code VARCHAR2(30 BYTE),
  processed_yn VARCHAR2(30 BYTE),
  last_trans_time DATE
);
ALTER TABLE sa.revert_cr4454_app ADD SUPPLEMENTAL LOG GROUP dmtsora1918189970_0 (bin_objid, last_trans_time, ml_objid, part_number, processed_yn, rc_objid, x_inv_insert_date, x_last_ship_date, x_po_num, x_red_code, x_service_id, x_smp) ALWAYS;