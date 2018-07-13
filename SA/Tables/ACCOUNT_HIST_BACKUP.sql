CREATE TABLE sa.account_hist_backup (
  objid NUMBER,
  account_hist2part_inst NUMBER,
  account_hist2x_account NUMBER,
  account_hist2x_pi_hist NUMBER,
  x_end_date DATE,
  x_start_date DATE
);
ALTER TABLE sa.account_hist_backup ADD SUPPLEMENTAL LOG GROUP dmtsora1124834697_0 (account_hist2part_inst, account_hist2x_account, account_hist2x_pi_hist, objid, x_end_date, x_start_date) ALWAYS;