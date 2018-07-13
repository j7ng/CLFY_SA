CREATE TABLE sa.x_pcrf_transaction (
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
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  imsi VARCHAR2(30 BYTE),
  lifeline_id NUMBER(22),
  install_date DATE,
  program_parameter_id NUMBER(22),
  vmbc_certification_flag VARCHAR2(1 BYTE),
  char_field_1 VARCHAR2(100 BYTE),
  char_field_2 VARCHAR2(100 BYTE),
  char_field_3 VARCHAR2(100 BYTE),
  date_field_1 DATE,
  addons_flag VARCHAR2(1 BYTE),
  rcs_enable_flag VARCHAR2(1 BYTE),
  CONSTRAINT x_pcrf_transaction_pk PRIMARY KEY (objid)
);
ALTER TABLE sa.x_pcrf_transaction ADD SUPPLEMENTAL LOG GROUP tsora7944984_1 (contact_objid, future_ttl, insert_timestamp, language, pcrf_cos, redemption_date, ttl, update_timestamp, wf_mac_id) ALWAYS;
ALTER TABLE sa.x_pcrf_transaction ADD SUPPLEMENTAL LOG GROUP tsora7944984_0 (action_type, blackout_wait_date, brand, case_id, content_delivery_format, conversion_factor, data_usage, dealer_id, denomination, esn, "GROUP_ID", hi_speed_data_usage, mdn, "MIN", objid, order_type, part_inst_status, pcrf_parent_name, pcrf_status_code, phone_manufacturer, phone_model, propagate_flag, rate_plan, retry_count, service_plan_id, service_plan_type, sim, sourcesystem, status_message, subscriber_id, "TEMPLATE", web_objid, zipcode) ALWAYS;
COMMENT ON TABLE sa.x_pcrf_transaction IS 'Table that contains the suboffers for a pcrf_transaction record. Will mirror the suboffers attached to the spr_base table at the time the transaction is initiated.';
COMMENT ON COLUMN sa.x_pcrf_transaction.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_pcrf_transaction."MIN" IS 'Mobile identification number.';
COMMENT ON COLUMN sa.x_pcrf_transaction.mdn IS 'Mobile identification number.';
COMMENT ON COLUMN sa.x_pcrf_transaction.esn IS 'Member ESN to be activated.';
COMMENT ON COLUMN sa.x_pcrf_transaction.subscriber_id IS 'Unique Subscriber ID assigned to customer';
COMMENT ON COLUMN sa.x_pcrf_transaction."GROUP_ID" IS 'REFERENCE TO x_account_group.account_group_uid.';
COMMENT ON COLUMN sa.x_pcrf_transaction.order_type IS 'Order type';
COMMENT ON COLUMN sa.x_pcrf_transaction.phone_manufacturer IS 'Manufacture of phone';
COMMENT ON COLUMN sa.x_pcrf_transaction.action_type IS 'Action type';
COMMENT ON COLUMN sa.x_pcrf_transaction.sim IS 'SIM';
COMMENT ON COLUMN sa.x_pcrf_transaction.zipcode IS 'Zipcode to be activated.';
COMMENT ON COLUMN sa.x_pcrf_transaction.service_plan_id IS 'In case of enrollment, enrolling service plan id.';
COMMENT ON COLUMN sa.x_pcrf_transaction.case_id IS 'Populated if the esn requires port.';
COMMENT ON COLUMN sa.x_pcrf_transaction.pcrf_status_code IS 'PAYMENT_PENDING: initial status when inserted, QUEUED: when payment is completed, PROCESSING: when activation job picks record, COMPLETED: when activation job completes successfully, FAILED: when activation job failed.';
COMMENT ON COLUMN sa.x_pcrf_transaction.status_message IS 'Status Message';
COMMENT ON COLUMN sa.x_pcrf_transaction.web_objid IS 'Unique Identifier of the Web';
COMMENT ON COLUMN sa.x_pcrf_transaction.brand IS 'Brand of the Phone';
COMMENT ON COLUMN sa.x_pcrf_transaction.sourcesystem IS 'Source System';
COMMENT ON COLUMN sa.x_pcrf_transaction."TEMPLATE" IS 'Template';
COMMENT ON COLUMN sa.x_pcrf_transaction.rate_plan IS 'Curent Rate Plan';
COMMENT ON COLUMN sa.x_pcrf_transaction.blackout_wait_date IS 'Wait date for Blackout Period';
COMMENT ON COLUMN sa.x_pcrf_transaction.retry_count IS 'Count of Retry';
COMMENT ON COLUMN sa.x_pcrf_transaction.data_usage IS 'Data Usage';
COMMENT ON COLUMN sa.x_pcrf_transaction.hi_speed_data_usage IS 'Hi Speed Data Usage';
COMMENT ON COLUMN sa.x_pcrf_transaction.conversion_factor IS 'Conversion Factor';
COMMENT ON COLUMN sa.x_pcrf_transaction.dealer_id IS 'ID of the Dealer';
COMMENT ON COLUMN sa.x_pcrf_transaction.denomination IS 'Denomination';
COMMENT ON COLUMN sa.x_pcrf_transaction.pcrf_parent_name IS 'Current Parent Name';
COMMENT ON COLUMN sa.x_pcrf_transaction.propagate_flag IS 'Propagate Flag ';
COMMENT ON COLUMN sa.x_pcrf_transaction.service_plan_type IS 'Type of Service Plan';
COMMENT ON COLUMN sa.x_pcrf_transaction.part_inst_status IS 'Status of the Part Instance';
COMMENT ON COLUMN sa.x_pcrf_transaction.phone_model IS 'Model of the Phone or Device';
COMMENT ON COLUMN sa.x_pcrf_transaction.content_delivery_format IS 'Format of the content';
COMMENT ON COLUMN sa.x_pcrf_transaction.language IS 'Language Selected';
COMMENT ON COLUMN sa.x_pcrf_transaction.wf_mac_id IS 'ID of the WF_MAC';
COMMENT ON COLUMN sa.x_pcrf_transaction.pcrf_cos IS 'PCRF - Class of Service';
COMMENT ON COLUMN sa.x_pcrf_transaction.ttl IS 'TTL';
COMMENT ON COLUMN sa.x_pcrf_transaction.future_ttl IS 'Future TTL';
COMMENT ON COLUMN sa.x_pcrf_transaction.redemption_date IS 'Redemption Date';
COMMENT ON COLUMN sa.x_pcrf_transaction.insert_timestamp IS 'Record Updated Timestamp';
COMMENT ON COLUMN sa.x_pcrf_transaction.imsi IS 'imsi value from ig_transaction or sim inventory';
COMMENT ON COLUMN sa.x_pcrf_transaction.lifeline_id IS 'LifeLine ID for SafeLink customers';
COMMENT ON COLUMN sa.x_pcrf_transaction.install_date IS 'This is the first date the subscriber becomes a TF customer';
COMMENT ON COLUMN sa.x_pcrf_transaction.program_parameter_id IS 'Program_parameter ID for Auto Refill program enrollment other than lifeline customers';
COMMENT ON COLUMN sa.x_pcrf_transaction.vmbc_certification_flag IS 'VMBC Certification flag (certified or not)';
COMMENT ON COLUMN sa.x_pcrf_transaction.char_field_1 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_transaction.char_field_2 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_transaction.char_field_3 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_transaction.date_field_1 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_transaction.rcs_enable_flag IS 'TO CHECK IS RCS ENABLE OR NOT';