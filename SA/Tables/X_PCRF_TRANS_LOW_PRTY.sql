CREATE TABLE sa.x_pcrf_trans_low_prty (
  objid NUMBER(22) NOT NULL,
  "MIN" VARCHAR2(30 BYTE),
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
  data_usage NUMBER(10,2),
  hi_speed_data_usage NUMBER(10,2),
  conversion_factor VARCHAR2(50 BYTE),
  dealer_id VARCHAR2(80 BYTE),
  denomination VARCHAR2(50 BYTE),
  pcrf_parent_name VARCHAR2(40 BYTE),
  propagate_flag VARCHAR2(1 BYTE),
  service_plan_type VARCHAR2(50 BYTE),
  part_inst_status VARCHAR2(30 BYTE),
  phone_model VARCHAR2(50 BYTE),
  content_delivery_format VARCHAR2(50 BYTE),
  language VARCHAR2(30 BYTE),
  wf_mac_id VARCHAR2(50 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  mdn VARCHAR2(30 BYTE),
  pcrf_cos VARCHAR2(30 BYTE),
  ttl DATE,
  future_ttl DATE,
  redemption_date DATE,
  contact_objid NUMBER(22),
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
  CONSTRAINT pcrf_trans_low_prty_pk PRIMARY KEY (objid)
);
COMMENT ON TABLE sa.x_pcrf_trans_low_prty IS 'Table that contains the pcrf_transaction record for propagate flag 0.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.objid IS 'Unique identifier of the stage record.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty."MIN" IS 'Mobile identification number.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.esn IS 'Member ESN to be activated.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.subscriber_id IS 'Unique Subscriber ID assigned to customer';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty."GROUP_ID" IS 'REFERENCE TO x_account_group.account_group_uid.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.order_type IS 'Order type';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.phone_manufacturer IS 'Manufacture of phone';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.action_type IS 'Action type';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.sim IS 'SIM';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.zipcode IS 'Zipcode to be activated.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.service_plan_id IS 'In case of enrollment, enrolling service plan id.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.case_id IS 'Populated if the esn requires port.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.pcrf_status_code IS 'PAYMENT_PENDING: initial status when inserted, QUEUED: when payment is completed, PROCESSING: when activation job picks record, COMPLETED: when activation job completes successfully, FAILED: when activation job failed.';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.status_message IS 'Status Message';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.web_objid IS 'Unique Identifier of the Web';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.brand IS 'Brand of the Phone';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.sourcesystem IS 'Source System';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty."TEMPLATE" IS 'Template';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.rate_plan IS 'Curent Rate Plan';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.blackout_wait_date IS 'Wait date for Blackout Period';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.retry_count IS 'Count of Retry';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.data_usage IS 'Data Usage';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.hi_speed_data_usage IS 'Hi Speed Data Usage';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.conversion_factor IS 'Conversion Factor';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.dealer_id IS 'ID of the Dealer';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.denomination IS 'Denomination';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.pcrf_parent_name IS 'Current Parent Name';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.propagate_flag IS 'Propagate Flag ';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.service_plan_type IS 'Type of Service Plan';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.part_inst_status IS 'Status of the Part Instance';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.phone_model IS 'Model of the Phone or Device';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.content_delivery_format IS 'Format of the content';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.language IS 'Language Selected';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.wf_mac_id IS 'ID of the WF_MAC';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.insert_timestamp IS 'Record Updated Timestamp';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.imsi IS 'imsi value from ig_transaction or sim inventory';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.lifeline_id IS 'LifeLine ID for SafeLink customers';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.install_date IS 'This is the first date the subscriber becomes a TF customer';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.program_parameter_id IS 'Program_parameter ID for Auto Refill program enrollment other than lifeline customers';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.vmbc_certification_flag IS 'VMBC Certification flag (certified or not)';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.char_field_1 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.char_field_2 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.char_field_3 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.date_field_1 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_pcrf_trans_low_prty.rcs_enable_flag IS 'TO CHECK IS RCS ENABLE OR NOT';