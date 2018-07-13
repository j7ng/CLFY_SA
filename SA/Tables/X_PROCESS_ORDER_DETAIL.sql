CREATE TABLE sa.x_process_order_detail (
  objid NUMBER NOT NULL,
  process_order_objid NUMBER,
  case_objid NUMBER,
  call_trans_objid NUMBER,
  order_status VARCHAR2(50 BYTE) NOT NULL,
  insert_timestamp DATE DEFAULT sysdate NOT NULL,
  update_timestamp DATE DEFAULT sysdate NOT NULL,
  order_type VARCHAR2(50 BYTE),
  ban VARCHAR2(20 BYTE),
  "MIN" VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  smp VARCHAR2(30 BYTE),
  CONSTRAINT pk_process_order_detail PRIMARY KEY (objid),
  CONSTRAINT fk1_order_status FOREIGN KEY (order_status) REFERENCES sa.x_process_order_status (process_order_status),
  CONSTRAINT fk1_process_order_detail FOREIGN KEY (process_order_objid) REFERENCES sa.x_process_order (objid)
);
COMMENT ON TABLE sa.x_process_order_detail IS 'Table to store the order details';
COMMENT ON COLUMN sa.x_process_order_detail.process_order_objid IS 'objid of x_process_order table';
COMMENT ON COLUMN sa.x_process_order_detail.case_objid IS 'Case objid from TABLE_CASE';
COMMENT ON COLUMN sa.x_process_order_detail.call_trans_objid IS 'call transaction objid from table_x_call_trans';
COMMENT ON COLUMN sa.x_process_order_detail.order_status IS 'Order status';
COMMENT ON COLUMN sa.x_process_order_detail.smp IS 'Storing SMP information';