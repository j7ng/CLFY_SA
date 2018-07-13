CREATE TABLE sa.table_nws_treefolders (
  objid NUMBER,
  dev NUMBER,
  n_sequencenumber NUMBER,
  n_name VARCHAR2(255 BYTE),
  n_expirationdate DATE,
  n_modificationdate DATE,
  n_effectivedate DATE,
  n_folders2nws_trees NUMBER,
  n_child2nws_treefolders NUMBER
);
ALTER TABLE sa.table_nws_treefolders ADD SUPPLEMENTAL LOG GROUP dmtsora106084975_0 (dev, n_child2nws_treefolders, n_effectivedate, n_expirationdate, n_folders2nws_trees, n_modificationdate, n_name, n_sequencenumber, objid) ALWAYS;