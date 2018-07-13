CREATE TABLE sa.account_stg (
  s_x_acct_num VARCHAR2(32 BYTE),
  s_acc2x_carrier NUMBER(38),
  s_x_start_date DATE,
  s_x_end_date DATE,
  s_x_account_hist2part_inst NUMBER(38)
);
ALTER TABLE sa.account_stg ADD SUPPLEMENTAL LOG GROUP dmtsora1417796033_0 (s_acc2x_carrier, s_x_account_hist2part_inst, s_x_acct_num, s_x_end_date, s_x_start_date) ALWAYS;