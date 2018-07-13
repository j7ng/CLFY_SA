CREATE TABLE sa.table_gbkp_subc (
  objid NUMBER,
  title VARCHAR2(30 BYTE),
  "RANK" NUMBER,
  last_mod_time DATE,
  unique_title VARCHAR2(30 BYTE),
  dev NUMBER,
  gbkp_subc2gbkp_cat NUMBER(*,0)
);
ALTER TABLE sa.table_gbkp_subc ADD SUPPLEMENTAL LOG GROUP dmtsora1760772803_0 (dev, gbkp_subc2gbkp_cat, last_mod_time, objid, "RANK", title, unique_title) ALWAYS;
COMMENT ON TABLE sa.table_gbkp_subc IS 'Global keyphrase sub-category';
COMMENT ON COLUMN sa.table_gbkp_subc.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_gbkp_subc.title IS 'Title of keyphrase sub-category';
COMMENT ON COLUMN sa.table_gbkp_subc."RANK" IS 'Presentation rank of the sub-category; used for user interface';
COMMENT ON COLUMN sa.table_gbkp_subc.last_mod_time IS 'Date and time keyphrase sub-category was last modified';
COMMENT ON COLUMN sa.table_gbkp_subc.unique_title IS 'A unique title of the sub-category, a combination of the title and the parent category';
COMMENT ON COLUMN sa.table_gbkp_subc.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_gbkp_subc.gbkp_subc2gbkp_cat IS 'The subcategory s parent global keyphrase category';