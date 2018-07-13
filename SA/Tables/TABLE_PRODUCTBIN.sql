CREATE TABLE sa.table_productbin (
  objid NUMBER,
  "NAME" VARCHAR2(30 BYTE),
  s_name VARCHAR2(30 BYTE),
  description VARCHAR2(255 BYTE),
  loc_path VARCHAR2(255 BYTE),
  s_loc_path VARCHAR2(255 BYTE),
  last_modified DATE,
  parent_type NUMBER,
  parent_id NUMBER,
  quantity NUMBER,
  bin_level NUMBER,
  dev NUMBER,
  prdbin2site NUMBER(*,0),
  child_prnt2productbin NUMBER(*,0),
  direct_prdbin2site NUMBER(*,0),
  productbin2primary NUMBER(*,0),
  productbin2backup NUMBER(*,0)
);
ALTER TABLE sa.table_productbin ADD SUPPLEMENTAL LOG GROUP dmtsora708118430_0 (bin_level, child_prnt2productbin, description, dev, direct_prdbin2site, last_modified, loc_path, "NAME", objid, parent_id, parent_type, prdbin2site, productbin2backup, productbin2primary, quantity, s_loc_path, s_name) ALWAYS;
COMMENT ON TABLE sa.table_productbin IS 'Product bin object: used to group parts at a site; e.g., could define a specific users configuration';
COMMENT ON COLUMN sa.table_productbin.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_productbin."NAME" IS 'Product bin name';
COMMENT ON COLUMN sa.table_productbin.description IS 'Product bin long description';
COMMENT ON COLUMN sa.table_productbin.loc_path IS 'Location of bin in the hierarchy of bins';
COMMENT ON COLUMN sa.table_productbin.last_modified IS 'Date and time last modified';
COMMENT ON COLUMN sa.table_productbin.parent_type IS 'Indicates whether the parent is a site or a bin by holding the type ID of the parent object type; e.g.,  52=Installed under site; 109=Installed under another productbin, 0=Deinstalled productbin';
COMMENT ON COLUMN sa.table_productbin.parent_id IS 'Objid of parent site (if parent_type=52) or productbin (if parent_type=109)';
COMMENT ON COLUMN sa.table_productbin.quantity IS 'Number of products and bins under the bin';
COMMENT ON COLUMN sa.table_productbin.bin_level IS 'Level of bin within a hierarchy of bins';
COMMENT ON COLUMN sa.table_productbin.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_productbin.prdbin2site IS 'Site the bin is located at';
COMMENT ON COLUMN sa.table_productbin.child_prnt2productbin IS 'Related parent for the child bin';
COMMENT ON COLUMN sa.table_productbin.direct_prdbin2site IS 'Site for the top-level product bin';
COMMENT ON COLUMN sa.table_productbin.productbin2primary IS 'Primary employee';
COMMENT ON COLUMN sa.table_productbin.productbin2backup IS 'Backup employee';