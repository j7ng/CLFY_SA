CREATE TABLE sa.fix_tmin_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  sp_objid NUMBER,
  x_min VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);