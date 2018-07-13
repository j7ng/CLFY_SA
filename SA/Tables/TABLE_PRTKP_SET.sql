CREATE TABLE sa.table_prtkp_set (
  objid NUMBER,
  max_dim NUMBER,
  last_mod_time DATE,
  dev NUMBER,
  prtkp_set2gbkp_set NUMBER(*,0),
  prtkp_set2site_part NUMBER(*,0),
  prtkp_set2part_class NUMBER(*,0)
);
ALTER TABLE sa.table_prtkp_set ADD SUPPLEMENTAL LOG GROUP dmtsora1389004952_0 (dev, last_mod_time, max_dim, objid, prtkp_set2gbkp_set, prtkp_set2part_class, prtkp_set2site_part) ALWAYS;
COMMENT ON TABLE sa.table_prtkp_set IS 'Set of part keyphrases, in categories';
COMMENT ON COLUMN sa.table_prtkp_set.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_prtkp_set.max_dim IS 'Maximum size for the keyphrase set';
COMMENT ON COLUMN sa.table_prtkp_set.last_mod_time IS 'Date and time the keyphrase set was last modified';
COMMENT ON COLUMN sa.table_prtkp_set.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_prtkp_set.prtkp_set2gbkp_set IS 'The global keyphrase category set used as part keyphrase category sets; i.e., uses of the set for particular product/parts';
COMMENT ON COLUMN sa.table_prtkp_set.prtkp_set2site_part IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_prtkp_set.prtkp_set2part_class IS 'The generic part the part keyphrase category set is applied to';