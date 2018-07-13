CREATE TABLE sa.table_x_ild_product (
  x_ild_product VARCHAR2(50 BYTE) NOT NULL,
  x_is_default NUMBER,
  x_bus_org NUMBER
);
COMMENT ON COLUMN sa.table_x_ild_product.x_ild_product IS 'It is the Product ILD Code';
COMMENT ON COLUMN sa.table_x_ild_product.x_is_default IS 'It is the default product ILD for brand (1) defaul and 0 for special codes';
COMMENT ON COLUMN sa.table_x_ild_product.x_bus_org IS 'It is the objid from table_bus)org associate to the brand for ILD product';