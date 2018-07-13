CREATE TABLE sa.x_dp_payment_logs (
  x_merchant_ref_number VARCHAR2(30 BYTE),
  x_request_xml CLOB,
  x_response_xml CLOB,
  vendor_trans_status VARCHAR2(15 BYTE),
  x_process_status VARCHAR2(30 BYTE),
  insert_date DATE,
  last_update_date DATE
);