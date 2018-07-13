CREATE TABLE sa.table_hgbst_elm (
  objid NUMBER,
  title VARCHAR2(40 BYTE),
  s_title VARCHAR2(40 BYTE),
  "RANK" NUMBER,
  "STATE" VARCHAR2(10 BYTE),
  dev NUMBER,
  intval1 NUMBER
);
ALTER TABLE sa.table_hgbst_elm ADD SUPPLEMENTAL LOG GROUP dmtsora1360933404_0 (dev, intval1, objid, "RANK", "STATE", s_title, title) ALWAYS;
COMMENT ON TABLE sa.table_hgbst_elm IS 'Specific element <item> in a custom list (user-defined pop up list)';
COMMENT ON COLUMN sa.table_hgbst_elm.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_hgbst_elm.title IS 'Title <name> of the item';
COMMENT ON COLUMN sa.table_hgbst_elm."RANK" IS 'Rank order of the item in its list';
COMMENT ON COLUMN sa.table_hgbst_elm."STATE" IS 'Status of the item; i.e., 0=active, 1=inactive, default=2';
COMMENT ON COLUMN sa.table_hgbst_elm.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_hgbst_elm.intval1 IS 'Multi-purpose field; used to attach control information to the element';