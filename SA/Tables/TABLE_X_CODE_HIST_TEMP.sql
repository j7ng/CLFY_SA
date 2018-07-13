CREATE TABLE sa.table_x_code_hist_temp (
  objid NUMBER,
  x_seq VARCHAR2(5 BYTE),
  x_code VARCHAR2(60 BYTE),
  x_seq_update VARCHAR2(3 BYTE),
  x_type VARCHAR2(20 BYTE),
  x_code_temp2x_call_trans NUMBER
);
COMMENT ON TABLE sa.table_x_code_hist_temp IS 'This temp table is used during the gGenCodes tuxedo routine';
COMMENT ON COLUMN sa.table_x_code_hist_temp.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_code_hist_temp.x_seq IS 'TBD';
COMMENT ON COLUMN sa.table_x_code_hist_temp.x_code IS 'TBD';
COMMENT ON COLUMN sa.table_x_code_hist_temp.x_seq_update IS 'TBD';
COMMENT ON COLUMN sa.table_x_code_hist_temp.x_type IS 'TBD';
COMMENT ON COLUMN sa.table_x_code_hist_temp.x_code_temp2x_call_trans IS 'Related lines to carrier market';