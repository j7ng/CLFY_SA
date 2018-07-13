CREATE TABLE sa.x_subscriber_spr (
  objid NUMBER(22) NOT NULL,
  pcrf_min VARCHAR2(30 BYTE),
  pcrf_mdn VARCHAR2(30 BYTE),
  pcrf_esn VARCHAR2(30 BYTE),
  pcrf_subscriber_id VARCHAR2(50 BYTE),
  pcrf_group_id VARCHAR2(50 BYTE),
  pcrf_parent_name VARCHAR2(40 BYTE),
  pcrf_cos VARCHAR2(30 BYTE),
  pcrf_base_ttl DATE,
  pcrf_last_redemption_date DATE,
  future_ttl DATE,
  brand VARCHAR2(40 BYTE),
  phone_manufacturer VARCHAR2(30 BYTE),
  phone_model VARCHAR2(50 BYTE),
  content_delivery_format VARCHAR2(50 BYTE),
  denomination VARCHAR2(50 BYTE),
  conversion_factor VARCHAR2(50 BYTE),
  dealer_id VARCHAR2(80 BYTE),
  rate_plan VARCHAR2(60 BYTE),
  propagate_flag NUMBER(4),
  pcrf_transaction_id NUMBER(22),
  service_plan_type VARCHAR2(50 BYTE),
  service_plan_id NUMBER(22),
  queued_days NUMBER(3),
  language VARCHAR2(30 BYTE),
  part_inst_status VARCHAR2(30 BYTE),
  bus_org_objid NUMBER(22),
  contact_objid NUMBER(22),
  web_user_objid NUMBER(22),
  wf_mac_id VARCHAR2(50 BYTE),
  expired_usage_date DATE,
  subscriber_status_code VARCHAR2(3 BYTE),
  curr_throttle_policy_id NUMBER(22),
  curr_throttle_eff_date DATE,
  zipcode VARCHAR2(10 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  meter_source_voice NUMBER(22),
  meter_source_sms NUMBER(22),
  meter_source_data NUMBER(22),
  meter_source_ild NUMBER(22),
  imsi VARCHAR2(30 BYTE),
  lifeline_id NUMBER(22),
  install_date DATE,
  program_parameter_id NUMBER(22),
  vmbc_certification_flag VARCHAR2(1 BYTE),
  char_field_1 VARCHAR2(100 BYTE),
  char_field_2 VARCHAR2(100 BYTE),
  char_field_3 VARCHAR2(100 BYTE),
  date_field_1 DATE,
  rcs_enable_flag VARCHAR2(1 BYTE),
  CONSTRAINT subscriber_spr_pk PRIMARY KEY (objid),
  CONSTRAINT subscriber_spr_fk1 FOREIGN KEY (subscriber_status_code) REFERENCES sa.x_subscriber_status (subscriber_status_code)
);
COMMENT ON TABLE sa.x_subscriber_spr IS 'Base table for storing subscriber information.';
COMMENT ON COLUMN sa.x_subscriber_spr.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_min IS 'Mobile identification number';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_esn IS 'Electronic serial number';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_subscriber_id IS 'Unique subscriberID assigned to customer ';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_group_id IS 'GroupID of group the customer belongs to';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_parent_name IS 'Carrier Parent name';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_cos IS 'Class of Service';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_base_ttl IS 'Expiration date of the base offer';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_last_redemption_date IS 'Base last redemption date';
COMMENT ON COLUMN sa.x_subscriber_spr.brand IS 'Reference to TABLE_BUS_ORG.BUS_ORG_ID';
COMMENT ON COLUMN sa.x_subscriber_spr.phone_manufacturer IS 'Manufacturer of the phone';
COMMENT ON COLUMN sa.x_subscriber_spr.phone_model IS 'Model of the phone';
COMMENT ON COLUMN sa.x_subscriber_spr.content_delivery_format IS 'Format of the content delivery';
COMMENT ON COLUMN sa.x_subscriber_spr.denomination IS 'Denomination Value';
COMMENT ON COLUMN sa.x_subscriber_spr.conversion_factor IS 'Conversion Factor';
COMMENT ON COLUMN sa.x_subscriber_spr.dealer_id IS 'ID of the Dealer';
COMMENT ON COLUMN sa.x_subscriber_spr.rate_plan IS 'Current rate plan the subscriber belongs to';
COMMENT ON COLUMN sa.x_subscriber_spr.propagate_flag IS 'Propagate flag';
COMMENT ON COLUMN sa.x_subscriber_spr.pcrf_transaction_id IS 'Reference to X_PCRF_TRANSACTION.OBJID';
COMMENT ON COLUMN sa.x_subscriber_spr.service_plan_type IS 'Type of Service Plan';
COMMENT ON COLUMN sa.x_subscriber_spr.service_plan_id IS 'Reference to X_SERVICE_PLAN.OBJID';
COMMENT ON COLUMN sa.x_subscriber_spr.queued_days IS 'Number of days queued';
COMMENT ON COLUMN sa.x_subscriber_spr.language IS 'Hard-coded to ENGLISH';
COMMENT ON COLUMN sa.x_subscriber_spr.part_inst_status IS 'Line Status';
COMMENT ON COLUMN sa.x_subscriber_spr.bus_org_objid IS 'Unique identifier of the record';
COMMENT ON COLUMN sa.x_subscriber_spr.contact_objid IS 'Reference to TABLE_CONTACT.OBJID';
COMMENT ON COLUMN sa.x_subscriber_spr.web_user_objid IS 'Reference to TABLE_WEB_USER.OBJID';
COMMENT ON COLUMN sa.x_subscriber_spr.wf_mac_id IS 'Wi-Fi Mac Address Id';
COMMENT ON COLUMN sa.x_subscriber_spr.expired_usage_date IS 'Date when the base data usage was expired';
COMMENT ON COLUMN sa.x_subscriber_spr.subscriber_status_code IS 'Status of the subscriber. Reference to X_SUBSCRIBER_STATUS.SUBSCRIBER_STATUS_CODE';
COMMENT ON COLUMN sa.x_subscriber_spr.curr_throttle_policy_id IS 'Current Throttle Policy ID';
COMMENT ON COLUMN sa.x_subscriber_spr.curr_throttle_eff_date IS 'Current Throttle Effective Date';
COMMENT ON COLUMN sa.x_subscriber_spr.zipcode IS 'Location Zipcode';
COMMENT ON COLUMN sa.x_subscriber_spr.insert_timestamp IS 'Date when the record was created';
COMMENT ON COLUMN sa.x_subscriber_spr.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_subscriber_spr.meter_source_voice IS 'Voice metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_subscriber_spr.meter_source_sms IS 'SMS metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_subscriber_spr.meter_source_data IS 'Data metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_subscriber_spr.meter_source_ild IS 'ILD metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_subscriber_spr.imsi IS 'imsi value from ig_transaction or sim inventory';
COMMENT ON COLUMN sa.x_subscriber_spr.lifeline_id IS 'LifeLine ID for SafeLink customers';
COMMENT ON COLUMN sa.x_subscriber_spr.install_date IS 'This is the first date the subscriber becomes a TF customer';
COMMENT ON COLUMN sa.x_subscriber_spr.program_parameter_id IS 'Program_parameter ID for Auto Refill program enrollment other than lifeline customers';
COMMENT ON COLUMN sa.x_subscriber_spr.vmbc_certification_flag IS 'VMBC Certification flag (certified or not)';
COMMENT ON COLUMN sa.x_subscriber_spr.char_field_1 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_subscriber_spr.char_field_2 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_subscriber_spr.char_field_3 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_subscriber_spr.date_field_1 IS 'Reserved field for future use';
COMMENT ON COLUMN sa.x_subscriber_spr.rcs_enable_flag IS 'TO CHECK IS RCS ENABLE OR NOT';