CREATE TABLE sa.fix_esn_port_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  x_port_in NUMBER,
  sp_objid NUMBER,
  x_service_id VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);