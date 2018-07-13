CREATE TABLE sa.fix_missing_contact_sweep (
  pi_objid NUMBER,
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  x_part_inst2contact NUMBER,
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);