CREATE TABLE sa.x_sales_orders (
  order_id NUMBER NOT NULL,
  order_date DATE NOT NULL,
  account_id NUMBER NOT NULL,
  ship_address VARCHAR2(200 BYTE),
  ship_address_2 VARCHAR2(200 BYTE),
  ship_city VARCHAR2(30 BYTE),
  ship_state VARCHAR2(10 BYTE),
  ship_zipcode VARCHAR2(10 BYTE),
  bill_address VARCHAR2(200 BYTE),
  bill_address_2 VARCHAR2(200 BYTE),
  bill_city VARCHAR2(30 BYTE),
  bill_state VARCHAR2(10 BYTE),
  bill_zipcode VARCHAR2(10 BYTE),
  order2payment_source NUMBER,
  order2purch_hdr NUMBER,
  terms_and_cond_check NUMBER,
  sub_total_items NUMBER(8,2),
  sub_total_air NUMBER(8,2),
  items_tax NUMBER(8,2),
  air_tax NUMBER(8,2),
  e911_fee NUMBER(8,2),
  shipping_option VARCHAR2(30 BYTE),
  shipping_cost NUMBER(8,2),
  order_total NUMBER(8,2),
  plan_sub_total NUMBER(8,2),
  plan_tax NUMBER(8,2),
  plan_e911_fee NUMBER(8,2),
  plan_total NUMBER(8,2),
  order_status VARCHAR2(30 BYTE),
  enroll_status VARCHAR2(30 BYTE),
  created_by VARCHAR2(60 BYTE) NOT NULL,
  creation_date DATE NOT NULL,
  last_updated_by VARCHAR2(60 BYTE) NOT NULL,
  last_update_date DATE NOT NULL,
  case_id_items VARCHAR2(30 BYTE),
  case_id_services VARCHAR2(30 BYTE),
  notes VARCHAR2(4000 BYTE),
  retailer VARCHAR2(30 BYTE),
  rep_id_name VARCHAR2(30 BYTE),
  plan_usf_fee NUMBER(8,2),
  plan_misc_fee NUMBER(8,2),
  CONSTRAINT x_sales_orders_pk PRIMARY KEY (order_id),
  CONSTRAINT x_so_customer_fk FOREIGN KEY (account_id) REFERENCES sa.x_business_accounts (account_id)
);
COMMENT ON TABLE sa.x_sales_orders IS 'B2B Sales Order Header';
COMMENT ON COLUMN sa.x_sales_orders.order_id IS 'Order ID';
COMMENT ON COLUMN sa.x_sales_orders.order_date IS 'Order Date';
COMMENT ON COLUMN sa.x_sales_orders.account_id IS 'Account ID, references x_business_accounts';
COMMENT ON COLUMN sa.x_sales_orders.ship_address IS 'Shipping Address 1';
COMMENT ON COLUMN sa.x_sales_orders.ship_address_2 IS 'Shipping Address 2';
COMMENT ON COLUMN sa.x_sales_orders.ship_city IS 'Shipping City';
COMMENT ON COLUMN sa.x_sales_orders.ship_state IS 'Shipping State';
COMMENT ON COLUMN sa.x_sales_orders.ship_zipcode IS 'Shipping Zip Code';
COMMENT ON COLUMN sa.x_sales_orders.bill_address IS 'Billing Address 1';
COMMENT ON COLUMN sa.x_sales_orders.bill_address_2 IS 'Billing Address 2';
COMMENT ON COLUMN sa.x_sales_orders.bill_city IS 'Billing City';
COMMENT ON COLUMN sa.x_sales_orders.bill_state IS 'Billing State';
COMMENT ON COLUMN sa.x_sales_orders.bill_zipcode IS 'Billing Zip Code';
COMMENT ON COLUMN sa.x_sales_orders.order2payment_source IS 'Reference to Payment Source';
COMMENT ON COLUMN sa.x_sales_orders.order2purch_hdr IS 'Reference to table_x_purch_hdr';
COMMENT ON COLUMN sa.x_sales_orders.terms_and_cond_check IS 'Flag for Terms and Contitions';
COMMENT ON COLUMN sa.x_sales_orders.sub_total_items IS 'Sub Total Amount Items';
COMMENT ON COLUMN sa.x_sales_orders.sub_total_air IS 'Sub Total Amount Airtime';
COMMENT ON COLUMN sa.x_sales_orders.items_tax IS 'Subtotal Items Tax';
COMMENT ON COLUMN sa.x_sales_orders.air_tax IS 'Subtotal Amount Airtime Tax';
COMMENT ON COLUMN sa.x_sales_orders.e911_fee IS 'E911 Tax Amount';
COMMENT ON COLUMN sa.x_sales_orders.shipping_option IS 'Shipping Method Selected';
COMMENT ON COLUMN sa.x_sales_orders.shipping_cost IS 'Shipping Cost Amount';
COMMENT ON COLUMN sa.x_sales_orders.order_total IS 'Total Order Amount';
COMMENT ON COLUMN sa.x_sales_orders.plan_sub_total IS 'Service Plan SubTotal';
COMMENT ON COLUMN sa.x_sales_orders.plan_tax IS 'Service Plan Sales Tax';
COMMENT ON COLUMN sa.x_sales_orders.plan_e911_fee IS 'Service Plan e911 Tax';
COMMENT ON COLUMN sa.x_sales_orders.plan_total IS 'Service Plan Total Amount';
COMMENT ON COLUMN sa.x_sales_orders.order_status IS 'Order Status: Canceled
Completed
Enrollment Failed
New
Payment Failed
Pending Activations
Pending ESNs
Pending Enrollment
Pending Shipment
Processing Payment';
COMMENT ON COLUMN sa.x_sales_orders.enroll_status IS 'not used.';
COMMENT ON COLUMN sa.x_sales_orders.created_by IS 'login name, user that created the record.';
COMMENT ON COLUMN sa.x_sales_orders.creation_date IS 'timestamp record creation';
COMMENT ON COLUMN sa.x_sales_orders.last_updated_by IS 'login name last user that updated the record';
COMMENT ON COLUMN sa.x_sales_orders.last_update_date IS 'timestamp last update to the record.';
COMMENT ON COLUMN sa.x_sales_orders.case_id_items IS 'Items Warehouse Case';
COMMENT ON COLUMN sa.x_sales_orders.case_id_services IS 'Services Warehouse Case';
COMMENT ON COLUMN sa.x_sales_orders.notes IS 'Sales Order Notes';
COMMENT ON COLUMN sa.x_sales_orders.retailer IS 'Retailer Name';
COMMENT ON COLUMN sa.x_sales_orders.rep_id_name IS 'Reppresentative ID (Retailer)';
COMMENT ON COLUMN sa.x_sales_orders.plan_usf_fee IS 'USF Tax Amount';
COMMENT ON COLUMN sa.x_sales_orders.plan_misc_fee IS 'Miscelaneous Tax Amount';