CREATE TABLE sa.x_receive_ftp_auto (
  rec_seq_no NUMBER,
  cycle_number VARCHAR2(10 BYTE),
  pay_type_ind VARCHAR2(3 BYTE),
  date_received DATE,
  trans_amount NUMBER(10,2),
  esn VARCHAR2(15 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  return_code VARCHAR2(4 BYTE),
  program_type NUMBER(2),
  enroll_flag VARCHAR2(4 BYTE),
  promo_code VARCHAR2(10 BYTE),
  unique_rec_no NUMBER(10),
  qualified_date DATE,
  rev_flag VARCHAR2(1 BYTE)
);
ALTER TABLE sa.x_receive_ftp_auto ADD SUPPLEMENTAL LOG GROUP dmtsora1541070954_0 (cycle_number, date_received, enroll_flag, esn, first_name, last_name, pay_type_ind, program_type, promo_code, qualified_date, rec_seq_no, return_code, rev_flag, trans_amount, unique_rec_no) ALWAYS;