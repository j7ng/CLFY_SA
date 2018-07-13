CREATE TABLE sa.x_sales_order_items (
  order_id NUMBER NOT NULL,
  line_item_id NUMBER NOT NULL,
  line_type VARCHAR2(50 BYTE) NOT NULL,
  zip_code VARCHAR2(50 BYTE) NOT NULL,
  part_number VARCHAR2(30 BYTE) NOT NULL,
  airtime_plan VARCHAR2(30 BYTE) NOT NULL,
  quantity NUMBER(6) DEFAULT 1 NOT NULL,
  unit_price NUMBER(8,2) NOT NULL,
  plan_price NUMBER(8,2) NOT NULL,
  created_by VARCHAR2(60 BYTE) NOT NULL,
  creation_date DATE NOT NULL,
  last_updated_by VARCHAR2(60 BYTE) NOT NULL,
  last_update_date DATE NOT NULL,
  original_qty NUMBER,
  item_status VARCHAR2(30 BYTE),
  refund_item2purch_hdr NUMBER,
  refund_item2order_item NUMBER,
  CONSTRAINT x_so_items_pk PRIMARY KEY (order_id,line_item_id),
  CONSTRAINT x_so_items_orders_fk FOREIGN KEY (order_id) REFERENCES sa.x_sales_orders (order_id)
);
COMMENT ON COLUMN sa.x_sales_order_items.order_id IS 'Sales Order ID';
COMMENT ON COLUMN sa.x_sales_order_items.line_item_id IS 'Line Item ID';
COMMENT ON COLUMN sa.x_sales_order_items.line_type IS 'Line Type: Accessory,
Activation,
Airtime Card,
Phone,
Port In';
COMMENT ON COLUMN sa.x_sales_order_items.zip_code IS 'Zip Code for Activation Services';
COMMENT ON COLUMN sa.x_sales_order_items.part_number IS 'Part Number, Reference part_number in table_part_num';
COMMENT ON COLUMN sa.x_sales_order_items.airtime_plan IS 'Name of Airtime Plan Selected';
COMMENT ON COLUMN sa.x_sales_order_items.quantity IS 'Quantity Ordered.';
COMMENT ON COLUMN sa.x_sales_order_items.unit_price IS 'Unit Price from ECOMMERCE price list';
COMMENT ON COLUMN sa.x_sales_order_items.plan_price IS 'Airtime Plan Price';
COMMENT ON COLUMN sa.x_sales_order_items.created_by IS 'Login Name of User that created the order.';
COMMENT ON COLUMN sa.x_sales_order_items.creation_date IS 'Timestamp for order creation';
COMMENT ON COLUMN sa.x_sales_order_items.last_updated_by IS 'login name for last user that updated the record.';
COMMENT ON COLUMN sa.x_sales_order_items.last_update_date IS 'last timestamp for update';
COMMENT ON COLUMN sa.x_sales_order_items.original_qty IS 'Non used.  ';
COMMENT ON COLUMN sa.x_sales_order_items.item_status IS 'Order Line Status:';