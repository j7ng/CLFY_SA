CREATE TABLE sa.table_queued_cbo_service (
  objid NUMBER,
  cbo_task_name VARCHAR2(100 BYTE),
  status VARCHAR2(20 BYTE),
  creation_date DATE,
  delay_in_seconds NUMBER,
  request XMLTYPE,
  response XMLTYPE,
  processed_date DATE,
  retry_count NUMBER DEFAULT 0,
  action_item_id VARCHAR2(30 BYTE),
  soa_service_uri VARCHAR2(255 BYTE),
  esn VARCHAR2(30 BYTE),
  upgrade_to_esn VARCHAR2(30 BYTE),
  source_system VARCHAR2(30 BYTE)
);
COMMENT ON TABLE sa.table_queued_cbo_service IS 'THIS TABLE STORES CBO SERVICES REQUEST/RESPONSE';
COMMENT ON COLUMN sa.table_queued_cbo_service.objid IS 'INTERNAL UNIQUE IDENTIFIER.';
COMMENT ON COLUMN sa.table_queued_cbo_service.cbo_task_name IS 'CBO TASK NAME';
COMMENT ON COLUMN sa.table_queued_cbo_service.status IS 'STATUS Q:QUEUED, L:LOCKED, C:COMPLETED';
COMMENT ON COLUMN sa.table_queued_cbo_service.creation_date IS 'CREATION DATE.';
COMMENT ON COLUMN sa.table_queued_cbo_service.delay_in_seconds IS 'TIME TO WAIT BEFORE RUNNING THE PAYLOAD (IN SECONDS).';
COMMENT ON COLUMN sa.table_queued_cbo_service.request IS 'REQUEST TO BE SENT TO CBO.';
COMMENT ON COLUMN sa.table_queued_cbo_service.response IS 'RESPONSE FROM CBO.';
COMMENT ON COLUMN sa.table_queued_cbo_service.processed_date IS 'DATE THE QUEUED TASK GOT PROCESSED.';
COMMENT ON COLUMN sa.table_queued_cbo_service.retry_count IS 'RETRY COUNTER';
COMMENT ON COLUMN sa.table_queued_cbo_service.action_item_id IS 'Action item';
COMMENT ON COLUMN sa.table_queued_cbo_service.soa_service_uri IS 'Stores URI information used by SOA.';