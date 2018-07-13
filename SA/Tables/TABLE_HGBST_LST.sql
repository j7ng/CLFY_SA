CREATE TABLE sa.table_hgbst_lst (
  objid NUMBER,
  title VARCHAR2(30 BYTE),
  description VARCHAR2(50 BYTE),
  deletable NUMBER,
  list_id NUMBER,
  locale NUMBER,
  dev NUMBER,
  hgbst_lst2hgbst_show NUMBER(*,0)
);
ALTER TABLE sa.table_hgbst_lst ADD SUPPLEMENTAL LOG GROUP dmtsora2026337611_0 (deletable, description, dev, hgbst_lst2hgbst_show, list_id, locale, objid, title) ALWAYS;
COMMENT ON TABLE sa.table_hgbst_lst IS 'Defines a custom list (user-defined, hierarchical pop up list)';
COMMENT ON COLUMN sa.table_hgbst_lst.objid IS 'Internal Record Number';
COMMENT ON COLUMN sa.table_hgbst_lst.title IS 'Title/Name of the List';
COMMENT ON COLUMN sa.table_hgbst_lst.description IS 'Description/Explanation of the List';
COMMENT ON COLUMN sa.table_hgbst_lst.deletable IS 'Flag to indicate if the list can be deleted: 0=Yes, 1=No';
COMMENT ON COLUMN sa.table_hgbst_lst.list_id IS 'Unique ID of the List for a Language';
COMMENT ON COLUMN sa.table_hgbst_lst.locale IS 'Preferred list language; i.e., 0=English,
1=SJIS, 2=French, 3=German, 4=Spanish,
5=Chinese Big5 (traditional character),
6=Chinese GB (simplified character),
7=Korean, 8-12 (Reserved), Default=0';
COMMENT ON COLUMN sa.table_hgbst_lst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_hgbst_lst.hgbst_lst2hgbst_show IS 'Reference to objid in table: table_hgbst_show';