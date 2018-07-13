CREATE TABLE sa.fix_addi_multi_acct_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst2contact NUMBER,
  addi_objid NUMBER,
  add_info2contact NUMBER,
  webu_bus_org NUMBER,
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);