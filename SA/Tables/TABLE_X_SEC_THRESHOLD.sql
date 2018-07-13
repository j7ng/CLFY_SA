CREATE TABLE sa.table_x_sec_threshold (
  objid NUMBER,
  dev NUMBER,
  x_threshold_name VARCHAR2(50 BYTE),
  x_threshold_desc VARCHAR2(100 BYTE),
  x_create_date DATE,
  x_units_per_tran NUMBER,
  x_units_per_day NUMBER,
  x_units_per_esn NUMBER,
  x_min_units NUMBER,
  x_max_units NUMBER,
  x_days_per_tran NUMBER,
  x_days_per_esn NUMBER,
  x_days_per_day NUMBER,
  x_repl_units_per_tran NUMBER,
  x_repl_units_per_esn NUMBER,
  x_repl_units_per_day NUMBER,
  x_repl_days_per_tran NUMBER,
  x_repl_days_per_esn NUMBER,
  x_repl_days_per_day NUMBER
);
ALTER TABLE sa.table_x_sec_threshold ADD SUPPLEMENTAL LOG GROUP dmtsora1685198940_0 (dev, objid, x_create_date, x_days_per_day, x_days_per_esn, x_days_per_tran, x_max_units, x_min_units, x_repl_days_per_day, x_repl_days_per_esn, x_repl_days_per_tran, x_repl_units_per_day, x_repl_units_per_esn, x_repl_units_per_tran, x_threshold_desc, x_threshold_name, x_units_per_day, x_units_per_esn, x_units_per_tran) ALWAYS;
COMMENT ON TABLE sa.table_x_sec_threshold IS 'Contains threshold info for each sec_group';
COMMENT ON COLUMN sa.table_x_sec_threshold.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_sec_threshold.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_threshold_name IS 'TBD';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_threshold_desc IS 'TBD';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_create_date IS 'TBD';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_units_per_tran IS 'Max Units per Transaction';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_units_per_day IS 'Max Units per Day';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_units_per_esn IS 'Max Units per ESN';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_min_units IS 'Minimum amount of units a group can issue';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_max_units IS 'Maxmimum amount of units a group can issue';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_days_per_tran IS 'Maxmimum x_days_per_tran';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_days_per_esn IS 'Maxmimum x_days_per_esn number';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_days_per_day IS 'Maxmimum x_days_per_day number';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_repl_units_per_tran IS 'Maxmimum x_repl_units_per_tran';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_repl_units_per_esn IS 'Maxmimum x_repl_units_per_esn';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_repl_units_per_day IS 'Maxmimum x_repl_units_per_day';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_repl_days_per_tran IS 'Maxmimum x_repl_days_per_tran';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_repl_days_per_esn IS 'Maxmimum x_repl_days_per_esn';
COMMENT ON COLUMN sa.table_x_sec_threshold.x_repl_days_per_day IS 'Maxmimum x_repl_days_per_day';