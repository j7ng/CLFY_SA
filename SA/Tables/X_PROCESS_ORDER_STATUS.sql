CREATE TABLE sa.x_process_order_status (
  process_order_status VARCHAR2(50 BYTE) NOT NULL,
  description VARCHAR2(200 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE,
  update_timestamp DATE DEFAULT SYSDATE,
  PRIMARY KEY (process_order_status)
);
COMMENT ON TABLE sa.x_process_order_status IS 'Table to configure process order status and description';
COMMENT ON COLUMN sa.x_process_order_status.process_order_status IS 'process order status';
COMMENT ON COLUMN sa.x_process_order_status.description IS 'Description of process order status';