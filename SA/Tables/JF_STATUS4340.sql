CREATE TABLE sa.jf_status4340 (
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
  tf_retail_rate VARCHAR2(60 BYTE)
);
ALTER TABLE sa.jf_status4340 ADD SUPPLEMENTAL LOG GROUP dmtsora343584198_0 (last_trans_time, n_part_inst2part_mod, part_inst2inv_bin, part_number, part_serial_no, posa, price, tf_om_trans_type_name, tf_retail_rate, tf_ret_location_name, x_part_inst_status) ALWAYS;