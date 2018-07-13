CREATE TABLE sa.fix_line_part_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  n_part_inst2part_mod NUMBER,
  sp_objid NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);