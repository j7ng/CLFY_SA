CREATE TABLE sa.order_status_ecomm (
  objid NUMBER NOT NULL,
  order_id NUMBER,
  client_id VARCHAR2(50 BYTE),
  status_cd VARCHAR2(1 BYTE) DEFAULT 'Q',
  last_update_date DATE
);
COMMENT ON COLUMN sa.order_status_ecomm.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.order_status_ecomm.order_id IS 'Order id provided.';
COMMENT ON COLUMN sa.order_status_ecomm.status_cd IS 'Status code L- Pending, Q-Queued, C-Completed';