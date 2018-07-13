CREATE TABLE sa.safelink_data_feed (
  objid NUMBER,
  lid VARCHAR2(200 BYTE),
  qualify_date DATE,
  data_feed_month VARCHAR2(30 BYTE),
  "NAME" VARCHAR2(400 BYTE),
  address VARCHAR2(200 BYTE),
  address2 VARCHAR2(200 BYTE),
  city VARCHAR2(200 BYTE),
  "STATE" VARCHAR2(200 BYTE),
  zip VARCHAR2(200 BYTE),
  x_esn VARCHAR2(200 BYTE),
  x_min VARCHAR2(200 BYTE),
  x_plan VARCHAR2(200 BYTE),
  x_case_id VARCHAR2(100 BYTE),
  x_tracking_number VARCHAR2(100 BYTE),
  x_enrolled VARCHAR2(10 BYTE),
  x_active VARCHAR2(10 BYTE),
  connection_fee NUMBER,
  usac_amount NUMBER,
  state_support NUMBER,
  other_fee_1 NUMBER,
  other_fee_2 NUMBER,
  prog_purch_hdr_objid NUMBER,
  x_current_active_date DATE,
  run_date DATE DEFAULT SYSDATE,
  part_number VARCHAR2(30 BYTE)
);
COMMENT ON COLUMN sa.safelink_data_feed.objid IS 'Objid of SAFELINK_DATA_FEED table';
COMMENT ON COLUMN sa.safelink_data_feed.lid IS 'LID INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.qualify_date IS 'QUALIFY_DATE INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.data_feed_month IS 'DATA_FEED_MONTH INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed."NAME" IS 'NAME INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.address IS 'ADDRESS INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.city IS 'CITY INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.x_esn IS 'X_ESN INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.x_min IS 'X_MIN INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.x_plan IS 'X_PLAN INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.x_case_id IS 'X_CASE_ID INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.x_tracking_number IS 'X_TRACKING_NUMBER INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.x_enrolled IS 'X_ENROLLED INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.x_active IS 'X_ACTIVE INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.connection_fee IS 'CONNECTION_FEE INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.usac_amount IS 'USAC_AMOUNT INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.state_support IS 'STATE_SUPPORT INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.other_fee_1 IS 'OTHER_FEE_1 INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.other_fee_2 IS 'OTHER_FEE_2 INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.run_date IS 'RUN_DATE INTO SAFELINK_DATA_FEED';
COMMENT ON COLUMN sa.safelink_data_feed.part_number IS 'Part Numbers related to connection fee for BI';