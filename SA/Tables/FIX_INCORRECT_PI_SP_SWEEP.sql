CREATE TABLE sa.fix_incorrect_pi_sp_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst2site_part NUMBER,
  sp_objid NUMBER,
  x_min VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  insert_date DATE DEFAULT SYSDATE
);