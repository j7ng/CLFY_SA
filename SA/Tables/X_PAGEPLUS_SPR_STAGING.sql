CREATE TABLE sa.x_pageplus_spr_staging (
  objid NUMBER(22) NOT NULL,
  pcrf_min VARCHAR2(30 BYTE),
  pcrf_mdn VARCHAR2(30 BYTE),
  pcrf_esn VARCHAR2(30 BYTE),
  pcrf_spr_id VARCHAR2(50 BYTE),
  pcrf_group_id VARCHAR2(50 BYTE),
  pcrf_parent_name VARCHAR2(40 BYTE),
  pcrf_cos VARCHAR2(30 BYTE),
  pcrf_base_ttl DATE,
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
  spr_status_code VARCHAR2(3 BYTE),
  curr_throttle_policy_id NUMBER(22),
  curr_throttle_eff_date DATE,
  zipcode VARCHAR2(10 BYTE),
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  meter_source_voice NUMBER(22),
  meter_source_sms NUMBER(22),
  meter_source_data NUMBER(22),
  meter_source_ild NUMBER(22),
  pcrf_subscriber_id VARCHAR2(50 BYTE),
  subscriber_status_code VARCHAR2(3 BYTE),
  imsi VARCHAR2(30 BYTE),
  "ACTION" VARCHAR2(30 BYTE),
  spr_status VARCHAR2(4000 BYTE),
  pcrf_status VARCHAR2(4000 BYTE),
  event_timestamp DATE,
  renewal_processed VARCHAR2(1 BYTE),
  pcrf_last_redemption_date DATE,
  addon_flag VARCHAR2(1 BYTE),
  CONSTRAINT spr_stg_pk PRIMARY KEY (objid) USING INDEX sa.spr__stg_pk
);
COMMENT ON TABLE sa.x_pageplus_spr_staging IS 'Base table for storing SPR information.';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_min IS 'Mobile identification number';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_esn IS 'Electronic serial number';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_spr_id IS 'Unique SPRID assigned to customer ';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_group_id IS 'GroupID of group the customer belongs to';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_parent_name IS 'Carrier Parent name';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_cos IS 'Class of Service';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_base_ttl IS 'Expiration date of the base offer';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.brand IS 'Reference to TABLE_BUS_ORG.BUS_ORG_ID';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.phone_manufacturer IS 'Manufacturer of the phone';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.phone_model IS 'Model of the phone';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.content_delivery_format IS 'Format of the content delivery';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.denomination IS 'Denomination Value';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.conversion_factor IS 'Conversion Factor';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.dealer_id IS 'ID of the Dealer';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.rate_plan IS 'Current rate plan the SPR belongs to';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.propagate_flag IS 'Propagate flag';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.pcrf_transaction_id IS 'Reference to X_PCRF_TRANSACTION.OBJID';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.service_plan_type IS 'Type of Service Plan';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.service_plan_id IS 'Reference to X_SERVICE_PLAN.OBJID';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.queued_days IS 'Number of days queued';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.language IS 'Hard-coded to ENGLISH';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.part_inst_status IS 'Line Status';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.bus_org_objid IS 'Unique identifier of the record';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.contact_objid IS 'Reference to TABLE_CONTACT.OBJID';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.web_user_objid IS 'Reference to TABLE_WEB_USER.OBJID';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.wf_mac_id IS 'Wi-Fi Mac Address Id';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.spr_status_code IS 'Status of the SPR. Reference to X_SPR_STATUS.SPR_STATUS_CODE';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.curr_throttle_policy_id IS 'Current Throttle Policy ID';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.curr_throttle_eff_date IS 'Current Throttle Effective Date';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.zipcode IS 'Location Zipcode';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.insert_timestamp IS 'Date when the record was created';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.update_timestamp IS 'Last date when the record was last modified';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.meter_source_voice IS 'Voice metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.meter_source_sms IS 'SMS metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.meter_source_data IS 'Data metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.meter_source_ild IS 'ILD metering ID from x_usage_host table';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.imsi IS 'imsi value from ig_transaction or sim inventory';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.event_timestamp IS 'Redemption date calculated based on various rule';
COMMENT ON COLUMN sa.x_pageplus_spr_staging.renewal_processed IS 'Flag to determine if renewal was processed';