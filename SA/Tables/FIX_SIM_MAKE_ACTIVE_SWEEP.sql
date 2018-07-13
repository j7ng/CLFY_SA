CREATE TABLE sa.fix_sim_make_active_sweep (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  esn_sim VARCHAR2(30 BYTE),
  x_sim_inv_status VARCHAR2(30 BYTE),
  part_number VARCHAR2(30 BYTE),
  part_num2bus_org NUMBER,
  sp_sim VARCHAR2(30 BYTE),
  insert_date DATE DEFAULT SYSDATE
);