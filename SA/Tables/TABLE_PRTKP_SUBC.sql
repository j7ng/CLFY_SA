CREATE TABLE sa.table_prtkp_subc (
  objid NUMBER,
  "RANK" NUMBER,
  last_mod_time DATE,
  dev NUMBER,
  prtkp_subc2prtkp_cat NUMBER(*,0),
  prtkp_subc2gbkp_subc NUMBER(*,0)
);
ALTER TABLE sa.table_prtkp_subc ADD SUPPLEMENTAL LOG GROUP dmtsora1186560644_0 (dev, last_mod_time, objid, prtkp_subc2gbkp_subc, prtkp_subc2prtkp_cat, "RANK") ALWAYS;
COMMENT ON TABLE sa.table_prtkp_subc IS 'Part keyphrase sub-category';
COMMENT ON COLUMN sa.table_prtkp_subc.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_prtkp_subc."RANK" IS 'Rank of the part keyphrase sub-category';
COMMENT ON COLUMN sa.table_prtkp_subc.last_mod_time IS 'Date and time the sub-category was last modified';
COMMENT ON COLUMN sa.table_prtkp_subc.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_prtkp_subc.prtkp_subc2prtkp_cat IS 'The parent part keyphrase category of the part keyphrase sub-category';
COMMENT ON COLUMN sa.table_prtkp_subc.prtkp_subc2gbkp_subc IS 'The global keyphrase subcategory related to the part keyphrase sub-category';