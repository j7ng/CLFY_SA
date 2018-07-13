CREATE TABLE sa.table_prtnum_cat (
  objid NUMBER,
  last_mod_time DATE,
  dev NUMBER,
  prtnum_cat2part_info NUMBER(*,0),
  prtnum_cat2part_class NUMBER(*,0)
);
ALTER TABLE sa.table_prtnum_cat ADD SUPPLEMENTAL LOG GROUP dmtsora1980407235_0 (dev, last_mod_time, objid, prtnum_cat2part_class, prtnum_cat2part_info) ALWAYS;
COMMENT ON TABLE sa.table_prtnum_cat IS 'A grouping of keyphrases defined either for a part revision or for a part class';
COMMENT ON COLUMN sa.table_prtnum_cat.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_prtnum_cat.last_mod_time IS 'Date and time of last modification';
COMMENT ON COLUMN sa.table_prtnum_cat.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_prtnum_cat.prtnum_cat2part_info IS 'The part revision for these keyphrases';
COMMENT ON COLUMN sa.table_prtnum_cat.prtnum_cat2part_class IS 'The keyphrase category for a part_class';