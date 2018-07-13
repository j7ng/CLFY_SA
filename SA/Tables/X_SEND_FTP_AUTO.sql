CREATE TABLE sa.x_send_ftp_auto (
  send_seq_no NUMBER,
  cycle_number VARCHAR2(10 BYTE),
  sent_date DATE,
  file_type_ind VARCHAR2(1 BYTE),
  esn VARCHAR2(15 BYTE),
  program_type NUMBER,
  account_status VARCHAR2(1 BYTE),
  amount_due NUMBER(10,2),
  debit_date DATE
);
ALTER TABLE sa.x_send_ftp_auto ADD SUPPLEMENTAL LOG GROUP dmtsora547365847_0 (account_status, amount_due, cycle_number, debit_date, esn, file_type_ind, program_type, send_seq_no, sent_date) ALWAYS;