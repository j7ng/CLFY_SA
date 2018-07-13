CREATE TABLE sa.part_inst_audit (
  part_serial_no VARCHAR2(30 BYTE),
  old_part_inst_status VARCHAR2(20 BYTE),
  new_part_inst_status VARCHAR2(20 BYTE),
  os_user VARCHAR2(30 BYTE),
  db_user VARCHAR2(30 BYTE),
  update_date DATE
);