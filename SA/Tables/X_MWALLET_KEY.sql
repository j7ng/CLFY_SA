CREATE TABLE sa.x_mwallet_key (
  objid NUMBER,
  x_mkey_num NUMBER,
  x_mkey VARCHAR2(300 BYTE),
  x_brand VARCHAR2(40 BYTE)
);
COMMENT ON TABLE sa.x_mwallet_key IS 'WALLET KEYS';
COMMENT ON COLUMN sa.x_mwallet_key.objid IS 'UNIQUE IDENTIFIER.';
COMMENT ON COLUMN sa.x_mwallet_key.x_mkey_num IS 'LANDING PAGE NUMBER';
COMMENT ON COLUMN sa.x_mwallet_key.x_mkey IS 'LANDING PAGE KEY';
COMMENT ON COLUMN sa.x_mwallet_key.x_brand IS 'TABLE_BUS_ORG BRAND';