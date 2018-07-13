CREATE TABLE sa.table_gbkp_set (
  objid NUMBER,
  last_mod_time DATE,
  dev NUMBER
);
ALTER TABLE sa.table_gbkp_set ADD SUPPLEMENTAL LOG GROUP dmtsora1640267158_0 (dev, last_mod_time, objid) ALWAYS;
COMMENT ON TABLE sa.table_gbkp_set IS 'Set of global keyphrases, in categories';
COMMENT ON COLUMN sa.table_gbkp_set.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_gbkp_set.last_mod_time IS 'Date/time of last modification';
COMMENT ON COLUMN sa.table_gbkp_set.dev IS 'Row version number for mobile distribution purposes';