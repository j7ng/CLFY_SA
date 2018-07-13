CREATE TABLE sa.table_gbst_lst (
  objid NUMBER,
  title VARCHAR2(80 BYTE),
  list_id NUMBER,
  locale NUMBER,
  dev NUMBER,
  addnl_info VARCHAR2(255 BYTE),
  sql_text VARCHAR2(4000 BYTE)
);
ALTER TABLE sa.table_gbst_lst ADD SUPPLEMENTAL LOG GROUP dmtsora115500141_0 (addnl_info, dev, list_id, locale, objid, title) ALWAYS;
COMMENT ON TABLE sa.table_gbst_lst IS 'Defines a Clarify (Global String) list; Defines code and pop up list lists <does not include user-defined pop up lists>; used with object 79, which defines the individual list elements';
COMMENT ON COLUMN sa.table_gbst_lst.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_gbst_lst.title IS 'Name of the list';
COMMENT ON COLUMN sa.table_gbst_lst.list_id IS 'Cross-locale ID of a list. Reserved; future';
COMMENT ON COLUMN sa.table_gbst_lst.locale IS 'Preferred list language; i.e., 0=English, 1=SJIS, 2=French, 3=German, 4=Spanish, 5=Chinese Big5 (traditional character), 6=Chinese GB (simplified character), 7=Korean, 8-12 (Reserved), Default=0';
COMMENT ON COLUMN sa.table_gbst_lst.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_gbst_lst.addnl_info IS 'Additional application-specific control data used to process the list';
COMMENT ON COLUMN sa.table_gbst_lst.sql_text IS 'Dynamic SQL statement to generate the DDL for the list.';