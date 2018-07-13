CREATE TABLE sa.fix_lines_attach_to_esn_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  esn_status VARCHAR2(20 BYTE),
  line VARCHAR2(30 BYTE),
  line_status VARCHAR2(20 BYTE),
  x_min VARCHAR2(30 BYTE),
  sp_objid NUMBER,
  part_number VARCHAR2(200 BYTE),
  part_num2bus_org VARCHAR2(200 BYTE),
  insert_date DATE DEFAULT SYSDATE
);