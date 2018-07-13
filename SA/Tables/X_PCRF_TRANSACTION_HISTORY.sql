CREATE TABLE sa.x_pcrf_transaction_history (
  objid NUMBER(22) NOT NULL,
  "MIN" VARCHAR2(30 BYTE),
  mdn VARCHAR2(30 BYTE),
  esn VARCHAR2(30 BYTE),
  subscriber_id VARCHAR2(50 BYTE),
  "GROUP_ID" VARCHAR2(50 BYTE),
  order_type VARCHAR2(30 BYTE),
  phone_manufacturer VARCHAR2(30 BYTE),
  action_type VARCHAR2(1 BYTE),
  sim VARCHAR2(30 BYTE),
  zipcode VARCHAR2(10 BYTE),
  service_plan_id NUMBER(22),
  case_id NUMBER(22),
  pcrf_status_code VARCHAR2(2 BYTE) NOT NULL,
  status_message VARCHAR2(1000 BYTE),
  web_objid NUMBER(22),
  brand VARCHAR2(40 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  "TEMPLATE" VARCHAR2(30 BYTE),
  rate_plan VARCHAR2(60 BYTE),
  blackout_wait_date DATE,
  retry_count NUMBER(10),
  data_usage NUMBER(14,2),
  hi_speed_data_usage NUMBER(14,2),
  conversion_factor VARCHAR2(50 BYTE),
  dealer_id VARCHAR2(80 BYTE),
  denomination VARCHAR2(50 BYTE),
  pcrf_parent_name VARCHAR2(40 BYTE),
  propagate_flag NUMBER(4),
  service_plan_type VARCHAR2(50 BYTE),
  part_inst_status VARCHAR2(30 BYTE),
  phone_model VARCHAR2(50 BYTE),
  content_delivery_format VARCHAR2(50 BYTE),
  language VARCHAR2(30 BYTE),
  wf_mac_id VARCHAR2(50 BYTE),
  pcrf_cos VARCHAR2(30 BYTE),
  ttl DATE,
  future_ttl DATE,
  redemption_date DATE,
  contact_objid NUMBER(22),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL
);
COMMENT ON TABLE sa.x_pcrf_transaction_history IS 'Table that contains the pcrf_transaction history record.';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_pcrf_transaction_history."MIN" IS 'Mobile identification number.';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.mdn IS 'Mobile identification number.';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.esn IS 'Member ESN to be activated.';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.subscriber_id IS 'Unique Subscriber ID assigned to customer';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.propagate_flag IS 'Propagate Flag ';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.service_plan_type IS 'Type of Service Plan';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.part_inst_status IS 'Status of the Part Instance';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.phone_model IS 'Model of the Phone or Device';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.content_delivery_format IS 'Format of the content';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.language IS 'Language Selected';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.wf_mac_id IS 'ID of the WF_MAC';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.pcrf_cos IS 'PCRF - Class of Service';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.ttl IS 'TTL';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.future_ttl IS 'Future TTL';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.redemption_date IS 'Redemption Date';
COMMENT ON COLUMN sa.x_pcrf_transaction_history.insert_timestamp IS 'Record Updated Timestamp';