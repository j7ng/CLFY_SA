CREATE TABLE sa.fix_cp_switchbased_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  sb_objid NUMBER,
  insert_date DATE DEFAULT SYSDATE
);