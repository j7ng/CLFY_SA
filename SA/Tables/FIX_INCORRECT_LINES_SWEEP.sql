CREATE TABLE sa.fix_incorrect_lines_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  esn_status VARCHAR2(20 BYTE),
  line VARCHAR2(30 BYTE),
  line_status VARCHAR2(20 BYTE),
  x_min VARCHAR2(30 BYTE),
  sp_objid NUMBER,
  part_number VARCHAR2(200 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);