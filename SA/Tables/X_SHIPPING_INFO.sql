CREATE TABLE sa.x_shipping_info (
  order_id NUMBER,
  sender VARCHAR2(50 BYTE),
  recipient VARCHAR2(50 BYTE),
  status VARCHAR2(20 BYTE),
  tracking_no VARCHAR2(50 BYTE),
  shipping_label BLOB,
  email_status VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.x_shipping_info IS 'Shipping Info Associated to each B2B Order';
COMMENT ON COLUMN sa.x_shipping_info.order_id IS 'Reference to x_sales_orders, order_id';
COMMENT ON COLUMN sa.x_shipping_info.sender IS 'Name of the Sender: BP_IO';
COMMENT ON COLUMN sa.x_shipping_info.recipient IS 'Name of Recipient';
COMMENT ON COLUMN sa.x_shipping_info.status IS 'Status of the Shipment: SHIPPED';
COMMENT ON COLUMN sa.x_shipping_info.tracking_no IS 'Tracking Number, FEDEX';
COMMENT ON COLUMN sa.x_shipping_info.shipping_label IS 'not used';
COMMENT ON COLUMN sa.x_shipping_info.email_status IS 'not used';