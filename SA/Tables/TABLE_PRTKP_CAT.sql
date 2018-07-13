CREATE TABLE sa.table_prtkp_cat (
  objid NUMBER,
  "RANK" NUMBER,
  last_mod_time DATE,
  dev NUMBER,
  prtkp_cat2prtkp_set NUMBER(*,0),
  prtkp_cat2gbkp_cat NUMBER(*,0),
  prtkp_cat2keyphrase NUMBER(*,0)
);
ALTER TABLE sa.table_prtkp_cat ADD SUPPLEMENTAL LOG GROUP dmtsora1891885632_0 (dev, last_mod_time, objid, prtkp_cat2gbkp_cat, prtkp_cat2keyphrase, prtkp_cat2prtkp_set, "RANK") ALWAYS;
COMMENT ON TABLE sa.table_prtkp_cat IS 'Part keyphrase category';
COMMENT ON COLUMN sa.table_prtkp_cat.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_prtkp_cat."RANK" IS 'Presentation rank of the category; used for user interface';
COMMENT ON COLUMN sa.table_prtkp_cat.last_mod_time IS 'Date and time the part keyphrase category was last modified';
COMMENT ON COLUMN sa.table_prtkp_cat.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_prtkp_cat.prtkp_cat2prtkp_set IS 'The set of part keyphrases in the category';
COMMENT ON COLUMN sa.table_prtkp_cat.prtkp_cat2gbkp_cat IS 'The global category of the part keyphrase category';
COMMENT ON COLUMN sa.table_prtkp_cat.prtkp_cat2keyphrase IS 'The part keyphrase that is used to index into the encoded logic for the category. This is a performance shortcut, enabling single calls to the DB for multiple combinations of keyphrase logic';