CREATE TABLE sa.table_n_categorytrees (
  objid NUMBER,
  dev NUMBER,
  n_treename VARCHAR2(50 BYTE),
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_itemid NUMBER,
  n_itemtypeid NUMBER
);
ALTER TABLE sa.table_n_categorytrees ADD SUPPLEMENTAL LOG GROUP dmtsora28313761_0 (dev, n_effectivedate, n_expirationdate, n_itemid, n_itemtypeid, n_modificationdate, n_treename, objid) ALWAYS;
COMMENT ON TABLE sa.table_n_categorytrees IS 'A tree structure comprised of category nodes. Items can belong to one or more nodes in a tree. Each N_Product has a category tree that can be used to organize its options and option packages. An N_Option may have a category tree provided it has options';
COMMENT ON COLUMN sa.table_n_categorytrees.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_n_categorytrees.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_n_categorytrees.n_treename IS 'The name of the tree';
COMMENT ON COLUMN sa.table_n_categorytrees.n_expirationdate IS 'Last date when the information should be used';
COMMENT ON COLUMN sa.table_n_categorytrees.n_modificationdate IS 'Date and time when the information was last modified';
COMMENT ON COLUMN sa.table_n_categorytrees.n_effectivedate IS 'The first date on which the information should be used';
COMMENT ON COLUMN sa.table_n_categorytrees.n_itemid IS 'The ID of the item that is a member of the category';
COMMENT ON COLUMN sa.table_n_categorytrees.n_itemtypeid IS 'Item type from N_ItemType table. It is used in conjunction with the N_ItemId field to identify to the item to which the package member belongs';