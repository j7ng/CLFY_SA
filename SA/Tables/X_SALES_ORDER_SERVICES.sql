CREATE TABLE sa.x_sales_order_services (
  order_id NUMBER NOT NULL,
  line_item_id NUMBER NOT NULL,
  line_serv_id NUMBER NOT NULL,
  service_type VARCHAR2(20 BYTE) NOT NULL,
  act_zip_code VARCHAR2(50 BYTE) NOT NULL,
  part_number VARCHAR2(30 BYTE) NOT NULL,
  part_serial_no VARCHAR2(30 BYTE),
  sim_serial_no VARCHAR2(30 BYTE),
  airtime_plan VARCHAR2(30 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  business_name VARCHAR2(200 BYTE),
  tax_id_number VARCHAR2(20 BYTE),
  contact_first_name VARCHAR2(60 BYTE),
  contact_last_name VARCHAR2(60 BYTE),
  address VARCHAR2(200 BYTE),
  address_2 VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(10 BYTE),
  zip_code VARCHAR2(10 BYTE),
  number_to_port VARCHAR2(20 BYTE),
  ssn_last_4 VARCHAR2(10 BYTE),
  provider VARCHAR2(30 BYTE),
  prov_acc_number VARCHAR2(30 BYTE),
  prov_pass_pin VARCHAR2(30 BYTE),
  port_req_status VARCHAR2(30 BYTE),
  port_case_id VARCHAR2(30 BYTE),
  created_by VARCHAR2(60 BYTE) NOT NULL,
  creation_date DATE NOT NULL,
  last_updated_by VARCHAR2(60 BYTE) NOT NULL,
  last_update_date DATE NOT NULL,
  status VARCHAR2(30 BYTE),
  red_code VARCHAR2(30 BYTE),
  CONSTRAINT x_so_serv_pk PRIMARY KEY (order_id,line_serv_id),
  CONSTRAINT x_so_serv_fk FOREIGN KEY (order_id) REFERENCES sa.x_sales_orders (order_id)
);
COMMENT ON TABLE sa.x_sales_order_services IS 'B2B Order support table, used to define service orders, Activations or Ports.  It complements the table: x_sales_order_items.';
COMMENT ON COLUMN sa.x_sales_order_services.order_id IS 'Sales Order ID';
COMMENT ON COLUMN sa.x_sales_order_services.line_item_id IS 'Line Item ID';
COMMENT ON COLUMN sa.x_sales_order_services.line_serv_id IS 'Line Service ID';
COMMENT ON COLUMN sa.x_sales_order_services.service_type IS 'Service Type: Activation, Port In';
COMMENT ON COLUMN sa.x_sales_order_services.act_zip_code IS 'Activation Zip Code';
COMMENT ON COLUMN sa.x_sales_order_services.part_number IS 'Part Number, references part_number in table_part_num';
COMMENT ON COLUMN sa.x_sales_order_services.part_serial_no IS 'Phone Serial Number, references part_serial_no in table_part_inst';
COMMENT ON COLUMN sa.x_sales_order_services.sim_serial_no IS 'SIM Serial Number, references x_sim_serial_no in table_x_sim_inv';
COMMENT ON COLUMN sa.x_sales_order_services.airtime_plan IS 'Billing Plan Description';
COMMENT ON COLUMN sa.x_sales_order_services.first_name IS 'Customer First Name';
COMMENT ON COLUMN sa.x_sales_order_services.last_name IS 'Customer Last Name';
COMMENT ON COLUMN sa.x_sales_order_services.business_name IS 'Port Info: Business Name ';
COMMENT ON COLUMN sa.x_sales_order_services.tax_id_number IS 'Port Info: Tax ID Number';
COMMENT ON COLUMN sa.x_sales_order_services.contact_first_name IS 'Port Info: First Name';
COMMENT ON COLUMN sa.x_sales_order_services.contact_last_name IS 'Port Info: Last Name';
COMMENT ON COLUMN sa.x_sales_order_services.address IS 'Port Info: Address 1';
COMMENT ON COLUMN sa.x_sales_order_services.address_2 IS 'Port Info: Address 2';
COMMENT ON COLUMN sa.x_sales_order_services.city IS 'Port Info: City';
COMMENT ON COLUMN sa.x_sales_order_services."STATE" IS 'Port Info: State';
COMMENT ON COLUMN sa.x_sales_order_services.zip_code IS 'Port Info: Zip Code';
COMMENT ON COLUMN sa.x_sales_order_services.number_to_port IS 'Port Info: Number being Ported';
COMMENT ON COLUMN sa.x_sales_order_services.ssn_last_4 IS 'Port Info: Social Security Last 4 Digits';
COMMENT ON COLUMN sa.x_sales_order_services.provider IS 'Port Info: Carrier Provider';
COMMENT ON COLUMN sa.x_sales_order_services.prov_acc_number IS 'Port Info: Provider Account Number';
COMMENT ON COLUMN sa.x_sales_order_services.prov_pass_pin IS 'Port Info: Password or PIN';
COMMENT ON COLUMN sa.x_sales_order_services.port_req_status IS 'Port Info: Port Status';
COMMENT ON COLUMN sa.x_sales_order_services.port_case_id IS 'Port Info: Case ID';
COMMENT ON COLUMN sa.x_sales_order_services.created_by IS 'login name user that created the record';
COMMENT ON COLUMN sa.x_sales_order_services.creation_date IS 'Timestamp record creation';
COMMENT ON COLUMN sa.x_sales_order_services.last_updated_by IS 'Login name last user that updated the record';
COMMENT ON COLUMN sa.x_sales_order_services.last_update_date IS 'timestamp last update to the record';
COMMENT ON COLUMN sa.x_sales_order_services.status IS 'Service Status: Associated,
Deenrolled,
Enrolled,
Enrollment Failed,
New,
Ready to Enroll,
Returned';
COMMENT ON COLUMN sa.x_sales_order_services.red_code IS 'Redemption PIN Number, optional to be used during activation.';