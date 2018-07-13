CREATE TABLE sa.jf_status4340_cr4341 (
  part_serial_no VARCHAR2(30 BYTE),
  x_part_inst_status VARCHAR2(20 BYTE),
  last_trans_time DATE,
  n_part_inst2part_mod NUMBER(38),
  part_inst2inv_bin NUMBER(38),
  posa VARCHAR2(1 BYTE),
  part_number VARCHAR2(80 BYTE),
  price NUMBER(38),
  tf_ret_location_name VARCHAR2(60 BYTE),
  tf_om_trans_type_name VARCHAR2(60 BYTE),
  insert_yn VARCHAR2(4000 BYTE)
);
ALTER TABLE sa.jf_status4340_cr4341 ADD SUPPLEMENTAL LOG GROUP dmtsora1325384177_0 (insert_yn, last_trans_time, n_part_inst2part_mod, part_inst2inv_bin, part_number, part_serial_no, posa, price, tf_om_trans_type_name, tf_ret_location_name, x_part_inst_status) ALWAYS;