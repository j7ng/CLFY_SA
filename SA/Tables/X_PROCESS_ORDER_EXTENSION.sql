CREATE TABLE sa.x_process_order_extension (
  process_order_objid NUMBER,
  request_payload XMLTYPE,
  response_payload XMLTYPE,
  insert_timestamp DATE DEFAULT SYSDATE,
  updated_timestamp DATE
);
COMMENT ON COLUMN sa.x_process_order_extension.process_order_objid IS 'Refering process order objid';
COMMENT ON COLUMN sa.x_process_order_extension.request_payload IS 'Storing POA request xml';
COMMENT ON COLUMN sa.x_process_order_extension.response_payload IS 'Storing POA response xml';
COMMENT ON COLUMN sa.x_process_order_extension.insert_timestamp IS 'Time of record insertion';
COMMENT ON COLUMN sa.x_process_order_extension.updated_timestamp IS 'Time of record updation';