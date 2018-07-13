CREATE TABLE sa.table_hgbst_show (
  objid NUMBER,
  last_mod_time DATE,
  title VARCHAR2(30 BYTE),
  def_val NUMBER,
  dev NUMBER,
  chld_prnt2hgbst_show NUMBER(*,0)
);
ALTER TABLE sa.table_hgbst_show ADD SUPPLEMENTAL LOG GROUP dmtsora420557221_0 (chld_prnt2hgbst_show, def_val, dev, last_mod_time, objid, title) ALWAYS;
COMMENT ON TABLE sa.table_hgbst_show IS 'Defines a level of a custom list (user-defined, hierarchical pop up list)';
COMMENT ON COLUMN sa.table_hgbst_show.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_hgbst_show.last_mod_time IS 'Shows date and time last modified. Reserved; future';
COMMENT ON COLUMN sa.table_hgbst_show.title IS 'Title/name of the level';
COMMENT ON COLUMN sa.table_hgbst_show.def_val IS 'Indicates which element in the level is the default element';
COMMENT ON COLUMN sa.table_hgbst_show.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_hgbst_show.chld_prnt2hgbst_show IS 'Related parent level in hierarchical user-defined pop up list';