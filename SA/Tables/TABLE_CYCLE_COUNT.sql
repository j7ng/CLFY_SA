CREATE TABLE sa.table_cycle_count (
  objid NUMBER,
  dev NUMBER,
  ct_days NUMBER,
  ct_name VARCHAR2(80 BYTE),
  s_ct_name VARCHAR2(80 BYTE),
  ct_start_date DATE,
  ct_end_date DATE,
  dflt_pct_ind NUMBER,
  dflt_turn_ind NUMBER,
  dflt_abc_ind NUMBER,
  status VARCHAR2(30 BYTE),
  ccount2rollup NUMBER,
  ccount2biz_cal_hdr NUMBER
);
ALTER TABLE sa.table_cycle_count ADD SUPPLEMENTAL LOG GROUP dmtsora1791502662_0 (ccount2biz_cal_hdr, ccount2rollup, ct_days, ct_end_date, ct_name, ct_start_date, dev, dflt_abc_ind, dflt_pct_ind, dflt_turn_ind, objid, status, s_ct_name) ALWAYS;
COMMENT ON TABLE sa.table_cycle_count IS 'Groups specific ABC Code classifications for a cycle count inventory rollup object';
COMMENT ON COLUMN sa.table_cycle_count.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_cycle_count.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_cycle_count.ct_days IS 'Number of days in a cycle count for a location';
COMMENT ON COLUMN sa.table_cycle_count.ct_name IS 'Unique name of the cycle count';
COMMENT ON COLUMN sa.table_cycle_count.ct_start_date IS 'Cycle count start date';
COMMENT ON COLUMN sa.table_cycle_count.ct_end_date IS 'Cycle count end date';
COMMENT ON COLUMN sa.table_cycle_count.dflt_pct_ind IS 'Indicates whether system-wide ABC code default will be used when determining stratification value parameters; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_cycle_count.dflt_turn_ind IS 'Indicates whether mod_level turn_ratio default will be used when determining stratification value parameters; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_cycle_count.dflt_abc_ind IS 'Indicates whether mod_level ABC code default will be used when determining stratification value parameters; i.e., 0=no, 1=yes, default=0';
COMMENT ON COLUMN sa.table_cycle_count.status IS 'Cyle count status; i.e., Open, Calculated, Scheduled, Complete';
COMMENT ON COLUMN sa.table_cycle_count.ccount2rollup IS 'Related rollup (inventory locations) using cycle count parameters';
COMMENT ON COLUMN sa.table_cycle_count.ccount2biz_cal_hdr IS 'Related business calendar header';