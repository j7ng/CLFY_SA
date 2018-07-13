CREATE TABLE sa.table_csc_product (
  objid NUMBER,
  vendor VARCHAR2(80 BYTE),
  "NAME" VARCHAR2(225 BYTE),
  "VERSION" VARCHAR2(10 BYTE),
  relation NUMBER,
  csc_order VARCHAR2(10 BYTE),
  server_id NUMBER,
  dev NUMBER,
  component2csc_product NUMBER(*,0),
  parent2csc_category NUMBER(*,0),
  child2csc_category NUMBER(*,0),
  prod2csc_part NUMBER(*,0)
);
ALTER TABLE sa.table_csc_product ADD SUPPLEMENTAL LOG GROUP dmtsora1960781196_0 (child2csc_category, component2csc_product, csc_order, dev, "NAME", objid, parent2csc_category, prod2csc_part, relation, server_id, vendor, "VERSION") ALWAYS;
COMMENT ON COLUMN sa.table_csc_product.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_csc_product.vendor IS 'Creator/brand owner of the product';
COMMENT ON COLUMN sa.table_csc_product."NAME" IS 'Customer-defined popup with name Exchange Product supplies the name product for the incident';
COMMENT ON COLUMN sa.table_csc_product."VERSION" IS 'The name of the product';
COMMENT ON COLUMN sa.table_csc_product.relation IS 'Relation between identifier and value; i.e., 0=false (is not); 1=true (is)';
COMMENT ON COLUMN sa.table_csc_product.csc_order IS 'Order for sequential statements';
COMMENT ON COLUMN sa.table_csc_product.server_id IS 'Exchange prodocol server ID number';
COMMENT ON COLUMN sa.table_csc_product.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_csc_product.component2csc_product IS 'Product in which the current product is nested';
COMMENT ON COLUMN sa.table_csc_product.parent2csc_category IS 'Hierarchical parent category for the product';
COMMENT ON COLUMN sa.table_csc_product.child2csc_category IS 'Hierarchical subcategory for the product';