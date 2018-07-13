CREATE TABLE sa.table_x_account_hist (
  objid NUMBER,
  account_hist2part_inst NUMBER,
  account_hist2x_account NUMBER,
  account_hist2x_pi_hist NUMBER,
  x_end_date DATE,
  x_start_date DATE
);
ALTER TABLE sa.table_x_account_hist ADD SUPPLEMENTAL LOG GROUP dmtsora890855557_0 (account_hist2part_inst, account_hist2x_account, account_hist2x_pi_hist, objid, x_end_date, x_start_date) ALWAYS;
COMMENT ON TABLE sa.table_x_account_hist IS 'Stores carrier account history information';
COMMENT ON COLUMN sa.table_x_account_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_account_hist.account_hist2part_inst IS 'Part instances related to account';
COMMENT ON COLUMN sa.table_x_account_hist.account_hist2x_account IS 'Account history for account';
COMMENT ON COLUMN sa.table_x_account_hist.account_hist2x_pi_hist IS 'History: Part instances related to account';
COMMENT ON COLUMN sa.table_x_account_hist.x_end_date IS 'End Date';
COMMENT ON COLUMN sa.table_x_account_hist.x_start_date IS 'Start Date';