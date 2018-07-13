CREATE TABLE sa.x_voucher_order_hdr (
  objid NUMBER NOT NULL,
  order_id VARCHAR2(30 BYTE),
  order_source VARCHAR2(30 BYTE),
  order_status VARCHAR2(20 BYTE),
  vendor_id VARCHAR2(50 BYTE),
  x_order_date DATE,
  x_order_amount NUMBER,
  benefit_amount_used NUMBER,
  x_brand VARCHAR2(50 BYTE),
  customer_name VARCHAR2(100 BYTE),
  customer_account_id VARCHAR2(100 BYTE),
  customer_min VARCHAR2(30 BYTE),
  shipping_address_1 VARCHAR2(500 BYTE),
  shipping_address_2 VARCHAR2(500 BYTE),
  shipping_zipcode VARCHAR2(10 BYTE),
  shipping_city VARCHAR2(500 BYTE),
  shipping_state VARCHAR2(500 BYTE),
  shipping_country VARCHAR2(500 BYTE),
  shipping_amount NUMBER,
  shipping_method VARCHAR2(100 BYTE),
  tax_total NUMBER,
  tax_sales NUMBER,
  tax_sales_rate NUMBER,
  tax_e911 NUMBER,
  tax_e911_rate NUMBER,
  tax_usf NUMBER,
  tax_usf_rate NUMBER,
  tax_rcrf NUMBER,
  tax_rcrf_rate NUMBER,
  x_update_date DATE,
  x_benefit_value NUMBER
);
COMMENT ON TABLE sa.x_voucher_order_hdr IS 'Order header table - stores the summary of order that customer has placed using the vouchers';
COMMENT ON COLUMN sa.x_voucher_order_hdr.objid IS 'unqiue record identifier';
COMMENT ON COLUMN sa.x_voucher_order_hdr.order_id IS 'unique Order ID generated by vendor';
COMMENT ON COLUMN sa.x_voucher_order_hdr.order_source IS 'order source';
COMMENT ON COLUMN sa.x_voucher_order_hdr.order_status IS 'order status like - pending /confirmed /cancelled / refunded';
COMMENT ON COLUMN sa.x_voucher_order_hdr.vendor_id IS 'Vendor ID who will manage the order';
COMMENT ON COLUMN sa.x_voucher_order_hdr.x_order_date IS 'Date when the order is created';
COMMENT ON COLUMN sa.x_voucher_order_hdr.x_order_amount IS 'Total order amount incl. of charges ';
COMMENT ON COLUMN sa.x_voucher_order_hdr.benefit_amount_used IS 'benefit amount that customer has used to place this order';
COMMENT ON COLUMN sa.x_voucher_order_hdr.x_brand IS 'brand of the device that is ordered';
COMMENT ON COLUMN sa.x_voucher_order_hdr.customer_name IS 'Customer full name';
COMMENT ON COLUMN sa.x_voucher_order_hdr.customer_account_id IS 'Customer Account ID';
COMMENT ON COLUMN sa.x_voucher_order_hdr.customer_min IS 'Customer MIN';
COMMENT ON COLUMN sa.x_voucher_order_hdr.x_update_date IS 'Date when record was last time updated';