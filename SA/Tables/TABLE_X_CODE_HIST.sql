CREATE TABLE sa.table_x_code_hist (
  objid NUMBER,
  x_gen_code VARCHAR2(100 BYTE),
  x_sequence NUMBER,
  code_hist2call_trans NUMBER,
  x_code_accepted VARCHAR2(10 BYTE),
  x_code_type VARCHAR2(20 BYTE),
  x_seq_update VARCHAR2(3 BYTE)
);
ALTER TABLE sa.table_x_code_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1026295646_0 (code_hist2call_trans, objid, x_code_accepted, x_code_type, x_gen_code, x_sequence, x_seq_update) ALWAYS;
COMMENT ON TABLE sa.table_x_code_hist IS 'Contains list of all the time codes that have been issued for an activation';
COMMENT ON COLUMN sa.table_x_code_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_code_hist.x_gen_code IS 'Time codes that have been generated';
COMMENT ON COLUMN sa.table_x_code_hist.x_sequence IS 'Counter/Order of the Time Codes';
COMMENT ON COLUMN sa.table_x_code_hist.code_hist2call_trans IS ' Call Transaction Code History';
COMMENT ON COLUMN sa.table_x_code_hist.x_code_accepted IS 'YES/NO if the code was accepted into the phone';
COMMENT ON COLUMN sa.table_x_code_hist.x_code_type IS 'The type of code being inserted, from the table_x_code_hist_temp';
COMMENT ON COLUMN sa.table_x_code_hist.x_seq_update IS '0/1 tells whether or not code will update the sequence of the phone; 1 = yes.';