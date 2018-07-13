CREATE TABLE sa.fix_incorrect_due_date_sweep (
  pi_objid NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  sp_objid NUMBER,
  x_min VARCHAR2(30 BYTE),
  install_date DATE,
  x_expire_dt DATE,
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);