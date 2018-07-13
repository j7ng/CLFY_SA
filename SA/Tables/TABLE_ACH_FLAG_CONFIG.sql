CREATE TABLE sa.table_ach_flag_config (
  objid NUMBER NOT NULL,
  brand VARCHAR2(20 BYTE) NOT NULL,
  x_source_system VARCHAR2(10 BYTE) NOT NULL,
  txn_flow VARCHAR2(50 BYTE) NOT NULL,
  is_flag_on VARCHAR2(5 BYTE),
  CONSTRAINT tafc_pk PRIMARY KEY (objid,brand,x_source_system,txn_flow)
);
COMMENT ON TABLE sa.table_ach_flag_config IS 'ACH flag configuration';
COMMENT ON COLUMN sa.table_ach_flag_config.brand IS 'ACH Brand setup';
COMMENT ON COLUMN sa.table_ach_flag_config.x_source_system IS 'Source system. WEB IVR etc';
COMMENT ON COLUMN sa.table_ach_flag_config.txn_flow IS 'Flow like AutoRefill PAYNOW BUYNOW etc.';
COMMENT ON COLUMN sa.table_ach_flag_config.is_flag_on IS 'Flag can only be TRUE or FALSE.';