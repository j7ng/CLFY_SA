CREATE TABLE sa.x_b2b_services_err_log (
  objid NUMBER,
  x_client_transactionid VARCHAR2(30 BYTE),
  x_clientid VARCHAR2(30 BYTE),
  x_error_code VARCHAR2(30 BYTE),
  x_error_message VARCHAR2(255 BYTE),
  x_server_transactionid VARCHAR2(30 BYTE),
  x_code NUMBER,
  x_subcode VARCHAR2(30 BYTE),
  x_isretriable VARCHAR2(1 BYTE),
  x_summary VARCHAR2(255 BYTE),
  x_message VARCHAR2(255 BYTE),
  x_payload CLOB,
  x_core_fault VARCHAR2(20 BYTE),
  x_causedby VARCHAR2(30 BYTE),
  x_brand_name VARCHAR2(30 BYTE),
  x_source_system VARCHAR2(30 BYTE),
  x_instanceid VARCHAR2(50 BYTE),
  x_instance_name VARCHAR2(50 BYTE),
  x_conversationid VARCHAR2(50 BYTE),
  x_failure_timestamp TIMESTAMP,
  x_failure_source VARCHAR2(10 BYTE),
  x_failure_target VARCHAR2(10 BYTE),
  x_operation_name VARCHAR2(40 BYTE),
  x_process_name VARCHAR2(30 BYTE),
  x_error_type VARCHAR2(20 BYTE),
  x_comments VARCHAR2(255 BYTE),
  x_segment1 VARCHAR2(30 BYTE),
  x_segment2 VARCHAR2(30 BYTE),
  x_segment3 VARCHAR2(30 BYTE),
  x_segment4 VARCHAR2(30 BYTE),
  CONSTRAINT b2b_err_const_uq UNIQUE (objid)
);
COMMENT ON TABLE sa.x_b2b_services_err_log IS 'Table having detail Error information';
COMMENT ON COLUMN sa.x_b2b_services_err_log.objid IS 'Internal record number';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_client_transactionid IS 'Correlation ID';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_clientid IS 'Client ID';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_error_code IS 'Error Code From Db Objects';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_error_message IS 'Error Message From Db Objects';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_server_transactionid IS 'To Track the incoming Transactions';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_code IS 'Error Code From SOA Objects';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_subcode IS 'Target System error sub code';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_isretriable IS 'YES or NO';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_summary IS 'Error Summary';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_message IS 'Error message from Services';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_payload IS 'Complete Input Payload From SOA in XML File';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_core_fault IS 'SOA/Middleware Fault';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_causedby IS 'Reason for Failure ';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_brand_name IS 'TRACFONE,NET10,ST,etc.. ';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_source_system IS 'WEB,WEBCSR,IVR';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_instanceid IS 'SOA Unique transaction identifier Id';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_instance_name IS 'SOA Unique transaction identifier name';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_conversationid IS 'SOA Unique Conversation ID';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_failure_timestamp IS 'Record Transaction Entry Time';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_failure_source IS 'Source Error System';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_failure_target IS 'Source target System';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_operation_name IS 'Service.operation Name Which Is Being Invoked';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_process_name IS 'SOA process /service name';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_error_type IS 'System or Business';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_comments IS 'Comments For The Particular Record';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_segment1 IS 'Additional Column ';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_segment2 IS 'Additional Column';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_segment3 IS 'Additional Column';
COMMENT ON COLUMN sa.x_b2b_services_err_log.x_segment4 IS 'Additional Column';