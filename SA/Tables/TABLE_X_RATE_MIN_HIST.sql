CREATE TABLE sa.table_x_rate_min_hist (
  objid NUMBER,
  x_start_date DATE,
  x_end_date DATE,
  x_esn VARCHAR2(30 BYTE),
  x_min VARCHAR2(30 BYTE),
  x_npa VARCHAR2(10 BYTE),
  x_nxx VARCHAR2(10 BYTE),
  x_ext VARCHAR2(10 BYTE),
  x_rate_plan VARCHAR2(60 BYTE),
  x_esn_technology VARCHAR2(30 BYTE),
  x_activation_tech VARCHAR2(30 BYTE),
  x_status VARCHAR2(30 BYTE),
  x_rate_min2site_part NUMBER
);
ALTER TABLE sa.table_x_rate_min_hist ADD SUPPLEMENTAL LOG GROUP dmtsora1822854914_0 (objid, x_activation_tech, x_end_date, x_esn, x_esn_technology, x_ext, x_min, x_npa, x_nxx, x_rate_min2site_part, x_rate_plan, x_start_date, x_status) ALWAYS;
COMMENT ON TABLE sa.table_x_rate_min_hist IS 'Stores activation records with technology';
COMMENT ON COLUMN sa.table_x_rate_min_hist.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_start_date IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_end_date IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_esn IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_min IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_npa IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_nxx IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_ext IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_rate_plan IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_esn_technology IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_activation_tech IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_status IS 'TBD';
COMMENT ON COLUMN sa.table_x_rate_min_hist.x_rate_min2site_part IS 'Relation to Site Part';