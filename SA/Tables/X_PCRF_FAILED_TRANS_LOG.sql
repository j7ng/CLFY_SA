CREATE TABLE sa.x_pcrf_failed_trans_log (
  objid NUMBER(22) NOT NULL,
  pcrf_transaction_id NUMBER(22) NOT NULL,
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
  pcrf_status_code VARCHAR2(2 BYTE),
  status_message VARCHAR2(1000 BYTE),
  web_objid NUMBER(22),
  brand VARCHAR2(40 BYTE),
  sourcesystem VARCHAR2(30 BYTE),
  "TEMPLATE" VARCHAR2(30 BYTE),
  rate_plan VARCHAR2(60 BYTE),
  blackout_wait_date DATE,
  retry_count NUMBER(10),
  data_usage NUMBER(20,2),
  hi_speed_data_usage NUMBER(20,2),
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
  logged_date DATE,
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_pcrf_failed_trans_log_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_pcrf_failed_trans_log IS 'Store information of failed transactions log';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.objid IS 'Unique Identified of the record';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.pcrf_transaction_id IS 'PCRF transaction id';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log."MIN" IS 'subscriber min';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.mdn IS 'subscriber mdn';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.esn IS 'Electronic Serial Number';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.subscriber_id IS 'Subscriber id';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log."GROUP_ID" IS 'account group id';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.order_type IS 'Order type';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.phone_manufacturer IS 'Phone manufacturer';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.action_type IS 'action_type            ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.sim IS 'sim                    ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.zipcode IS 'zipcode                ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.service_plan_id IS 'service_plan_id        ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.case_id IS 'case_id                ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.pcrf_status_code IS 'pcrf_status_code       ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.status_message IS 'status_message         ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.web_objid IS 'web_objid              ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.brand IS 'brand                  ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.sourcesystem IS 'sourcesystem           ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log."TEMPLATE" IS 'template               ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.rate_plan IS 'rate_plan              ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.blackout_wait_date IS 'blackout_wait_date     ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.retry_count IS 'retry_count            ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.data_usage IS 'data_usage             ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.hi_speed_data_usage IS 'hi_speed_data_usage    ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.conversion_factor IS 'conversion_factor      ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.dealer_id IS 'dealer_id              ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.denomination IS 'denomination           ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.pcrf_parent_name IS 'pcrf_parent_name       ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.propagate_flag IS 'propagate_flag         ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.service_plan_type IS 'service_plan_type      ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.part_inst_status IS 'part_inst_status       ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.phone_model IS 'phone_model            ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.content_delivery_format IS 'content_delivery_format';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.language IS 'Language Selected';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.wf_mac_id IS 'wf_mac_id              ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.pcrf_cos IS 'pcrf_cos               ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.ttl IS 'ttl                    ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.future_ttl IS 'future_ttl             ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.redemption_date IS 'redemption_date        ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.contact_objid IS 'contact_objid          ';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.logged_date IS 'Logged Date';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.insert_timestamp IS 'Record Inserted Timestamp';
COMMENT ON COLUMN sa.x_pcrf_failed_trans_log.update_timestamp IS 'Record Updated Timestamp';