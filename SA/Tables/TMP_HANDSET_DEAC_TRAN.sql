CREATE TABLE sa.tmp_handset_deac_tran (
  part_number VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  phone_status VARCHAR2(20 BYTE),
  line VARCHAR2(30 BYTE),
  line_status VARCHAR2(20 BYTE),
  line_parent_name VARCHAR2(40 BYTE),
  x_result VARCHAR2(20 BYTE),
  x_total_units NUMBER,
  x_transact_date DATE,
  x_deact_date DATE,
  flag CHAR
);