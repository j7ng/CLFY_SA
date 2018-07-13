CREATE TABLE sa.ota_pending_030507 (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  last_trans_time DATE,
  part_inst2inv_bin NUMBER,
  n_part_inst2part_mod NUMBER,
  part_to_esn2part_inst NUMBER,
  call_trans_objid NUMBER,
  x_result VARCHAR2(20 BYTE),
  esn VARCHAR2(20 BYTE)
);