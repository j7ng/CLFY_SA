CREATE TABLE sa.table_gb_kp (
  objid NUMBER,
  title VARCHAR2(255 BYTE),
  s_title VARCHAR2(255 BYTE),
  "RANK" NUMBER,
  last_mod_time DATE,
  unique_title VARCHAR2(255 BYTE),
  dev NUMBER,
  gb_kp2gbkp_subc NUMBER(*,0)
);
ALTER TABLE sa.table_gb_kp ADD SUPPLEMENTAL LOG GROUP dmtsora1849294406_0 (dev, gb_kp2gbkp_subc, last_mod_time, objid, "RANK", s_title, title, unique_title) ALWAYS;
COMMENT ON TABLE sa.table_gb_kp IS 'Global keyphrase';
COMMENT ON COLUMN sa.table_gb_kp.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_gb_kp.title IS 'Title of the global keyphrase';
COMMENT ON COLUMN sa.table_gb_kp."RANK" IS 'Presentation rank of the keyphrase used for user interface';
COMMENT ON COLUMN sa.table_gb_kp.last_mod_time IS 'Date and time the global keyphrase was last modified';
COMMENT ON COLUMN sa.table_gb_kp.unique_title IS 'Unique title of global keyphrase, a combination of the keyphrase and its category/subcategory';
COMMENT ON COLUMN sa.table_gb_kp.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_gb_kp.gb_kp2gbkp_subc IS 'Subcategory to which the global keyphrase belongs';