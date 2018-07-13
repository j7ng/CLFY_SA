CREATE TABLE sa.x_process_order (
  objid NUMBER NOT NULL,
  transaction_date DATE,
  external_order_id VARCHAR2(100 BYTE),
  order_id VARCHAR2(100 BYTE) NOT NULL,
  brm_trans_id VARCHAR2(100 BYTE),
  insert_timestamp DATE DEFAULT sysdate NOT NULL,
  update_timestamp DATE DEFAULT sysdate NOT NULL,
  channel VARCHAR2(30 BYTE),
  store_id VARCHAR2(30 BYTE),
  register_id VARCHAR2(30 BYTE),
  user_id VARCHAR2(30 BYTE),
  party_id VARCHAR2(30 BYTE),
  CONSTRAINT pk_process_order PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_process_order IS 'Table to store the order headers';
COMMENT ON COLUMN sa.x_process_order.transaction_date IS 'Date when the order has been placed';
COMMENT ON COLUMN sa.x_process_order.external_order_id IS 'Order ID from extern source system like WALMART';
COMMENT ON COLUMN sa.x_process_order.order_id IS 'Unique order ID generated in CLARIFY';
COMMENT ON COLUMN sa.x_process_order.brm_trans_id IS 'BRM transaction ID for the order';
COMMENT ON COLUMN sa.x_process_order.store_id IS 'Storing - Target Store identifier  (To know which store submit the order ) information';
COMMENT ON COLUMN sa.x_process_order.register_id IS 'Storing - The register / terminal within the store information';
COMMENT ON COLUMN sa.x_process_order.user_id IS 'Storing the agent id who submit the order information';
COMMENT ON COLUMN sa.x_process_order.party_id IS 'Storing party_id information';