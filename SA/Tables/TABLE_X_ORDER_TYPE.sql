CREATE TABLE sa.table_x_order_type (
  objid NUMBER,
  x_order_type VARCHAR2(30 BYTE),
  x_npa VARCHAR2(10 BYTE),
  x_nxx VARCHAR2(10 BYTE),
  x_bill_cycle VARCHAR2(10 BYTE),
  x_dealer_code VARCHAR2(30 BYTE),
  x_ld_account_num VARCHAR2(30 BYTE),
  x_market_code VARCHAR2(30 BYTE),
  x_order_type2x_trans_profile NUMBER,
  x_order_type2x_carrier NUMBER
);
ALTER TABLE sa.table_x_order_type ADD SUPPLEMENTAL LOG GROUP dmtsora873461103_0 (objid, x_bill_cycle, x_dealer_code, x_ld_account_num, x_market_code, x_npa, x_nxx, x_order_type, x_order_type2x_carrier, x_order_type2x_trans_profile) ALWAYS;
COMMENT ON TABLE sa.table_x_order_type IS 'Stores order type information for carrier markets';
COMMENT ON COLUMN sa.table_x_order_type.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_x_order_type.x_order_type IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type.x_npa IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type.x_nxx IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type.x_bill_cycle IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type.x_dealer_code IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type.x_ld_account_num IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type.x_market_code IS 'x_order_type';
COMMENT ON COLUMN sa.table_x_order_type.x_order_type2x_trans_profile IS 'Related transmission profile';