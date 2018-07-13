CREATE TABLE sa.table_x_sales_tax_prasad (
  objid NUMBER,
  x_zipcode VARCHAR2(10 BYTE),
  x_city VARCHAR2(28 BYTE),
  x_county VARCHAR2(25 BYTE),
  x_state VARCHAR2(2 BYTE),
  x_cntydef VARCHAR2(1 BYTE),
  x_default VARCHAR2(1 BYTE),
  x_cntyfips VARCHAR2(5 BYTE),
  x_statestax NUMBER,
  x_cntstax NUMBER,
  x_cntlclstax NUMBER,
  x_ctystax NUMBER,
  x_ctylclstax NUMBER,
  x_combstax NUMBER,
  x_eff_dt DATE,
  x_geocode VARCHAR2(10 BYTE),
  x_inout VARCHAR2(2 BYTE)
);
ALTER TABLE sa.table_x_sales_tax_prasad ADD SUPPLEMENTAL LOG GROUP dmtsora681216978_0 (objid, x_city, x_cntlclstax, x_cntstax, x_cntydef, x_cntyfips, x_combstax, x_county, x_ctylclstax, x_ctystax, x_default, x_eff_dt, x_geocode, x_inout, x_state, x_statestax, x_zipcode) ALWAYS;