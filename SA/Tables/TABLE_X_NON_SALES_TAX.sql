CREATE TABLE sa.table_x_non_sales_tax (
  objid NUMBER,
  x_state VARCHAR2(20 BYTE),
  x_zipcode VARCHAR2(20 BYTE)
);
ALTER TABLE sa.table_x_non_sales_tax ADD SUPPLEMENTAL LOG GROUP dmtsora1964280323_0 (objid, x_state, x_zipcode) ALWAYS;
COMMENT ON TABLE sa.table_x_non_sales_tax IS 'Added D.R For Non Sales Tax';
COMMENT ON COLUMN sa.table_x_non_sales_tax.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_non_sales_tax.x_state IS 'State for which there is no sales tax';
COMMENT ON COLUMN sa.table_x_non_sales_tax.x_zipcode IS 'no sales tax zipcode';