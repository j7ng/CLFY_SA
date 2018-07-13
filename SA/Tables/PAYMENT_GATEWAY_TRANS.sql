CREATE TABLE sa.payment_gateway_trans (
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_response_xml CLOB,
  x_process_status VARCHAR2(30 BYTE),
  insert_date DATE,
  last_update_date DATE
);