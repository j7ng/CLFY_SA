CREATE TABLE sa.x_subscriber_spr_hist (
  objid NUMBER(22) NOT NULL,
  subscriber_spr_objid NUMBER(22) NOT NULL,
  change_date DATE NOT NULL,
  pcrf_min VARCHAR2(30 BYTE),
  pcrf_mdn VARCHAR2(30 BYTE),
  pcrf_esn VARCHAR2(30 BYTE),
  pcrf_subscriber_id VARCHAR2(50 BYTE),
  pcrf_group_id VARCHAR2(50 BYTE),
  pcrf_parent_name VARCHAR2(40 BYTE),
  pcrf_cos VARCHAR2(30 BYTE),
  pcrf_base_ttl DATE,
  pcrf_last_redemption_date DATE,
  brand VARCHAR2(40 BYTE),
  future_ttl DATE,
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
  insert_timestamp DATE DEFAULT SYSDATE NOT NULL,
  update_timestamp DATE DEFAULT SYSDATE NOT NULL,
  CONSTRAINT x_subscriber_spr_hist_pk PRIMARY KEY (objid),
  CONSTRAINT x_subscriber_spr_hist_fk2 FOREIGN KEY (subscriber_status_code) REFERENCES sa.x_subscriber_status (subscriber_status_code)
);
ALTER TABLE sa.x_subscriber_spr_hist ADD SUPPLEMENTAL LOG GROUP tsora246375648_1 (curr_throttle_eff_date, curr_throttle_policy_id, insert_timestamp, subscriber_status_code, update_timestamp) ALWAYS;
ALTER TABLE sa.x_subscriber_spr_hist ADD SUPPLEMENTAL LOG GROUP tsora246375648_0 (brand, bus_org_objid, change_date, contact_objid, content_delivery_format, conversion_factor, dealer_id, denomination, expired_usage_date, future_ttl, language, objid, part_inst_status, pcrf_base_ttl, pcrf_cos, pcrf_esn, pcrf_group_id, pcrf_last_redemption_date, pcrf_mdn, pcrf_min, pcrf_parent_name, pcrf_subscriber_id, pcrf_transaction_id, phone_manufacturer, phone_model, propagate_flag, queued_days, rate_plan, service_plan_id, service_plan_type, subscriber_spr_objid, web_user_objid, wf_mac_id) ALWAYS;
COMMENT ON TABLE sa.x_subscriber_spr_hist IS 'Store subscriber history.';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.objid IS 'Unique identifier of the record.';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.subscriber_spr_objid IS 'Unique identifier of the Subscriber';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.change_date IS 'Date of change';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_min IS 'Mobile Identification Number';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_mdn IS 'Mobile Identification Number';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_esn IS 'Electronic Serial Number';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_subscriber_id IS 'Unique subscriber ID assigned to customer';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_group_id IS 'Group ID of group the customer belongs to';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_parent_name IS 'Carrier Parent';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_cos IS 'Class of service';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_base_ttl IS 'Expiration Date';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_last_redemption_date IS 'Base Last Redemption Date';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.brand IS 'Brand of the Phone';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.phone_manufacturer IS 'Phone Manufacturer';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.phone_model IS 'Model of the Phone';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.content_delivery_format IS 'Format of the content';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.denomination IS 'Denomination';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.conversion_factor IS 'Conversion Factor';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.dealer_id IS 'ID of the Dealer';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.rate_plan IS 'Current Rate Plan';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.propagate_flag IS 'Propagate flag value used to identify the usage host. Reference to x_usage_host';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.pcrf_transaction_id IS 'PCRF Transaction ID';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.service_plan_type IS 'Type of Service Plan';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.service_plan_id IS 'ID of service plan';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.queued_days IS 'Days in queue';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.language IS 'Language';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.part_inst_status IS 'Status of Part Instance';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.bus_org_objid IS 'Unique Identifier of the brand';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.contact_objid IS 'Unique Identifier of contact';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.web_user_objid IS 'Unique Identifier of web user account';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.wf_mac_id IS 'Wi-Fi Mac Address Id';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.expired_usage_date IS 'Date of expiry';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.subscriber_status_code IS 'Subscriber Status Code';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.curr_throttle_policy_id IS 'Current Throttling Policy Identifier';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.curr_throttle_eff_date IS 'Current Throttling Effective Date';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.insert_timestamp IS 'Record Inserted Timestamp';
COMMENT ON COLUMN sa.x_subscriber_spr_hist.update_timestamp IS 'Record last updated timestamp';