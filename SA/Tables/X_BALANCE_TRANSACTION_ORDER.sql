CREATE TABLE sa.x_balance_transaction_order (
  objid NUMBER(22) NOT NULL,
  "MIN" VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  status VARCHAR2(50 BYTE),
  transaction_ref_id VARCHAR2(50 BYTE),
  pin_partnumber VARCHAR2(30 BYTE),
  smp VARCHAR2(30 BYTE),
  web_user_objid NUMBER(22),
  source_system VARCHAR2(100 BYTE),
  brand VARCHAR2(40 BYTE),
  payment_source_id VARCHAR2(40 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  throttle_params VARCHAR2(200 BYTE),
  CONSTRAINT x_balance_transaction_order_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_balance_transaction_order IS 'Work table for low balance charges for clearway data club';
COMMENT ON COLUMN sa.x_balance_transaction_order.status IS 'QUEUED for all real-time OR PENDING_PAYMENT for orgs set-up as EOD batch';
COMMENT ON COLUMN sa.x_balance_transaction_order.transaction_ref_id IS 'x_merchant_ref_id of the payment record';
COMMENT ON COLUMN sa.x_balance_transaction_order.pin_partnumber IS 'Part number for pin being generated';
COMMENT ON COLUMN sa.x_balance_transaction_order.smp IS 'Pin issued during order processing';
COMMENT ON COLUMN sa.x_balance_transaction_order.web_user_objid IS 'Web id for the Organization';
COMMENT ON COLUMN sa.x_balance_transaction_order.insert_timestamp IS 'Date when the record was created';
COMMENT ON COLUMN sa.x_balance_transaction_order.update_timestamp IS 'Last date when the record was last modified';