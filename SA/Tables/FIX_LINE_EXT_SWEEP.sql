CREATE TABLE sa.fix_line_ext_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  x_npa VARCHAR2(10 BYTE),
  x_nxx VARCHAR2(10 BYTE),
  x_ext VARCHAR2(38 BYTE),
  sp_objid NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);