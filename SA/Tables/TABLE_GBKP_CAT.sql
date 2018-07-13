CREATE TABLE sa.table_gbkp_cat (
  objid NUMBER,
  title VARCHAR2(30 BYTE),
  "RANK" NUMBER,
  last_mod_time DATE,
  dev NUMBER,
  gbkp_cat2gbkp_set NUMBER(*,0)
);
ALTER TABLE sa.table_gbkp_cat ADD SUPPLEMENTAL LOG GROUP dmtsora1206267825_0 (dev, gbkp_cat2gbkp_set, last_mod_time, objid, "RANK", title) ALWAYS;
COMMENT ON TABLE sa.table_gbkp_cat IS 'Global keyphrase categories';
COMMENT ON COLUMN sa.table_gbkp_cat.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_gbkp_cat.title IS 'Title of the keyphrase category';
COMMENT ON COLUMN sa.table_gbkp_cat."RANK" IS 'Presentation rank of the category; used for user interface';
COMMENT ON COLUMN sa.table_gbkp_cat.last_mod_time IS 'Date and time the category was last modified';
COMMENT ON COLUMN sa.table_gbkp_cat.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_gbkp_cat.gbkp_cat2gbkp_set IS 'The set of global keyphrase categories in which the category is a member';