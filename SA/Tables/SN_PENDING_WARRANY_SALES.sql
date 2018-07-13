CREATE TABLE sa.sn_pending_warrany_sales (
  load_date DATE,
  manuf_code VARCHAR2(100 BYTE),
  dp_stream_no VARCHAR2(200 BYTE),
  record_type VARCHAR2(200 BYTE),
  client_batch_id VARCHAR2(200 BYTE),
  consumer_id_number VARCHAR2(80 BYTE),
  consumer_title VARCHAR2(30 BYTE),
  first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  business_indicator VARCHAR2(200 BYTE),
  business_dba_name VARCHAR2(200 BYTE),
  service_address1 VARCHAR2(200 BYTE),
  service_address2 VARCHAR2(200 BYTE),
  service_city VARCHAR2(30 BYTE),
  service_state VARCHAR2(40 BYTE),
  service_zip VARCHAR2(20 BYTE),
  service_zip4 VARCHAR2(200 BYTE),
  service_country_code VARCHAR2(40 BYTE),
  phone_type1 VARCHAR2(200 BYTE),
  phone VARCHAR2(30 BYTE),
  phone1_usage_type VARCHAR2(200 BYTE),
  phone_type2 VARCHAR2(200 BYTE),
  phone_2 VARCHAR2(200 BYTE),
  phone2_usage_type VARCHAR2(200 BYTE),
  e_mail_address VARCHAR2(80 BYTE),
  language_code VARCHAR2(200 BYTE),
  middle_initial VARCHAR2(3 BYTE),
  dealerid VARCHAR2(200 BYTE),
  contract_number VARCHAR2(200 BYTE),
  contract_purchase_date DATE,
  equipment_purchase_date DATE,
  package_sequence_number VARCHAR2(38 BYTE),
  line_item VARCHAR2(200 BYTE),
  reporting_tag_contract1 VARCHAR2(200 BYTE),
  reporting_tag_contract2 VARCHAR2(200 BYTE),
  model_number VARCHAR2(40 BYTE),
  serial_number VARCHAR2(30 BYTE),
  quantity_sold VARCHAR2(200 BYTE),
  labor_warr VARCHAR2(200 BYTE),
  parts_warr VARCHAR2(200 BYTE),
  product_code VARCHAR2(200 BYTE),
  sku_number VARCHAR2(30 BYTE),
  contract_retail VARCHAR2(30 BYTE),
  equipment_retail VARCHAR2(30 BYTE),
  cancel_request_date VARCHAR2(200 BYTE),
  update_action_code VARCHAR2(200 BYTE),
  sv_pendingwarsales_filename VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.sn_pending_warrany_sales IS 'THIS TABLE STORES SERVICE NET PENDING WARRANTY SALES';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.load_date IS 'CURRENT TIMESTAMP';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.manuf_code IS 'MANUFACTURING CODE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.dp_stream_no IS 'STREAM NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.record_type IS 'STREAM NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.client_batch_id IS 'CLIENT BATCH NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.consumer_id_number IS 'CONSUMER IDENTIFICATION NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.consumer_title IS 'CONSUMER TITLE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.first_name IS 'FIRST NAME';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.last_name IS 'LAST NAME';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.business_indicator IS 'BUSINESS INDICATOR';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.business_dba_name IS 'BUSINESS DBA NAME';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.service_address1 IS 'SERVICE ADDRESS LINE ONE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.service_address2 IS 'SERVICE ADDRESS LINE TWO';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.service_city IS 'SERVICE ADDRESS CITY NAME';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.service_state IS 'SERVICE ADDRESS STATE NAME';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.service_zip IS 'SERVICE ADDRESS ZIP CODE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.service_zip4 IS 'SERVICE ADDRESS ZIP PLUS 4';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.service_country_code IS 'SERVICE ADDRESS COUNTRY NAME';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.phone_type1 IS 'PHONE TYPE 1';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.phone IS 'PHONE NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.phone1_usage_type IS 'PHONE 1 USAGE TYPE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.phone_type2 IS 'PHONE TYPE 2';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.phone_2 IS 'PHONE 2';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.phone2_usage_type IS 'PHONE 2 USAGE TYPE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.e_mail_address IS 'ELECTRONIC MAIL';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.language_code IS 'LANGUAGE  CODE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.middle_initial IS 'MIDDLE INITIAL';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.dealerid IS 'DEALER ID';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.contract_number IS 'UNIQUE IDENTIFIER FOR THE CONTRACT';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.contract_purchase_date IS 'CONTRACT PURCHASE DATE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.equipment_purchase_date IS 'EQUIPMENT PURCHASE DATE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.package_sequence_number IS 'PACKAGE SEQUENCE NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.line_item IS 'LINE ITEM';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.reporting_tag_contract1 IS 'REPORTING TAG CONTRACT 1';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.reporting_tag_contract2 IS 'REPORTING TAG CONTRACT 2';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.model_number IS 'MODELE NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.serial_number IS 'SERIAL NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.quantity_sold IS 'QUANTITY SOLD';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.labor_warr IS 'LABOR WARRANTY';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.parts_warr IS 'PARTS WARRANTY';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.product_code IS 'PRODUCT CODE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.sku_number IS 'SKU NUMBER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.contract_retail IS 'CONTRACT RETAILER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.equipment_retail IS 'EQUIPMENT RETAILER';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.cancel_request_date IS 'CANCEL REQUEST DATE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.update_action_code IS 'UPDATE ACTION CODE';
COMMENT ON COLUMN sa.sn_pending_warrany_sales.sv_pendingwarsales_filename IS 'NAME OF THE PENDING WARRANTY SALES FILE';