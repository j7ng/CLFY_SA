CREATE TABLE sa.x_sprint_mrkt_info (
  mkt VARCHAR2(20 BYTE),
  npa VARCHAR2(20 BYTE),
  nxx VARCHAR2(20 BYTE),
  npanxx VARCHAR2(20 BYTE),
  rc_number VARCHAR2(20 BYTE),
  rc_name VARCHAR2(30 BYTE),
  rc_state VARCHAR2(20 BYTE),
  zip VARCHAR2(20 BYTE),
  mkt_type VARCHAR2(20 BYTE),
  account_num VARCHAR2(30 BYTE),
  market_code VARCHAR2(30 BYTE),
  dealer_code VARCHAR2(30 BYTE),
  submarketid VARCHAR2(30 BYTE),
  "TEMPLATE" VARCHAR2(20 BYTE)
);
COMMENT ON TABLE sa.x_sprint_mrkt_info IS 'HOLDING TABLE TO STORE SPRINT MARKET INFORMATION';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.mkt IS 'MARKET INFO';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.npa IS 'NPA INFO';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.nxx IS 'NXX INFO';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.npanxx IS 'NPA NXX COMBINATION';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.rc_number IS 'RATE CENTER NUMBER';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.rc_name IS 'RATE CENTER NAME';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.rc_state IS 'RATE CENTER STATE';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.zip IS 'ZIPCODE';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.mkt_type IS 'MARKET TYPE INFO';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.account_num IS 'ACCOUNT_NUMBER';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.market_code IS 'MARKET_CODE';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.dealer_code IS 'DEALER_CODE';
COMMENT ON COLUMN sa.x_sprint_mrkt_info.submarketid IS 'SUB MARKET ID';
COMMENT ON COLUMN sa.x_sprint_mrkt_info."TEMPLATE" IS 'TEMPLATE NAME';