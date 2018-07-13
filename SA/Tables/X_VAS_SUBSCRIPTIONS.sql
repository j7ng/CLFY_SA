CREATE TABLE sa.x_vas_subscriptions (
  objid NUMBER,
  vas_esn VARCHAR2(30 BYTE),
  vas_min VARCHAR2(30 BYTE),
  vas_sim VARCHAR2(30 BYTE),
  vas_account VARCHAR2(50 BYTE),
  vas_name VARCHAR2(30 BYTE),
  vas_id NUMBER,
  vas_x_ig_order_type VARCHAR2(30 BYTE),
  vas_subscription_date DATE,
  vas_is_active VARCHAR2(1 BYTE),
  program_parameters_objid NUMBER,
  part_inst_objid NUMBER,
  web_user_objid NUMBER,
  promotion_objid NUMBER,
  program_purch_hdr_objid NUMBER,
  x_purch_hdr_objid NUMBER,
  addl_info VARCHAR2(50 BYTE),
  x_email VARCHAR2(100 BYTE),
  x_manufacturer VARCHAR2(80 BYTE),
  x_model_number VARCHAR2(80 BYTE),
  x_real_esn VARCHAR2(30 BYTE),
  vas_subscription_id NUMBER,
  program_enrolled_id NUMBER,
  status VARCHAR2(50 BYTE),
  vas_expiry_date DATE,
  device_price_tier NUMBER,
  ecommerce_order_id VARCHAR2(100 BYTE),
  vendor_contract_id VARCHAR2(100 BYTE),
  case_id_number VARCHAR2(255 BYTE),
  refund_amount NUMBER,
  refund_type VARCHAR2(100 BYTE),
  insert_date DATE DEFAULT SYSDATE,
  update_date DATE DEFAULT SYSDATE,
  is_claimed VARCHAR2(3 BYTE)
);
COMMENT ON TABLE sa.x_vas_subscriptions IS 'VAS TRANSACTION HISTORY';
COMMENT ON COLUMN sa.x_vas_subscriptions.objid IS 'UNIQUE KEY OF X_VAS_SUBSCRIPTIONS TABLE';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_esn IS 'TABLE_PART_INST.PART_SERIAL_NO';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_min IS 'TABLE_SITE_PART.X_MIN';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_sim IS 'TABLE_PART_INST.X_ICCID';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_account IS 'TABLE_WEB_USER.S_LOGIN_NAME';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_name IS 'X_VAS_PROGRAMS';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_id IS 'X_VAS_PROGRAMS';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_x_ig_order_type IS 'X_IG_ORDER_TYPE';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_subscription_date IS 'TRANSACTION DATE';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_is_active IS 'DEACTIVATE FOR A MINC';
COMMENT ON COLUMN sa.x_vas_subscriptions.program_parameters_objid IS 'X_PROGRAM_PARAMETERS';
COMMENT ON COLUMN sa.x_vas_subscriptions.part_inst_objid IS 'TABLE_PART_INST';
COMMENT ON COLUMN sa.x_vas_subscriptions.web_user_objid IS 'TABLE_WEB_USER';
COMMENT ON COLUMN sa.x_vas_subscriptions.promotion_objid IS 'TABLE_X_PROMOTION';
COMMENT ON COLUMN sa.x_vas_subscriptions.program_purch_hdr_objid IS 'X_PROGRAM_PURCH_HDR';
COMMENT ON COLUMN sa.x_vas_subscriptions.x_purch_hdr_objid IS 'TABLE_X_PURCH_HDR';
COMMENT ON COLUMN sa.x_vas_subscriptions.addl_info IS 'ADDITIONAL INFO';
COMMENT ON COLUMN sa.x_vas_subscriptions.x_email IS 'Used for HPP BYOP; stores the email provided by customer at time of HPP enrollment';
COMMENT ON COLUMN sa.x_vas_subscriptions.x_manufacturer IS 'Used for HPP BYOP; Stores BYOP Manufacturer';
COMMENT ON COLUMN sa.x_vas_subscriptions.x_model_number IS 'Used for HPP BYOP; stores the BYOP phone model';
COMMENT ON COLUMN sa.x_vas_subscriptions.x_real_esn IS 'Used for HPP BYOP; Stores Real ESN provided by customer';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_subscription_id IS 'VAS Subscription ID to identify customer';
COMMENT ON COLUMN sa.x_vas_subscriptions.program_enrolled_id IS 'objid from x_program_enrolled';
COMMENT ON COLUMN sa.x_vas_subscriptions.status IS 'Status Enrolled/ Suspended / Deenrolled';
COMMENT ON COLUMN sa.x_vas_subscriptions.vas_expiry_date IS 'Subscription Expiry date';
COMMENT ON COLUMN sa.x_vas_subscriptions.device_price_tier IS 'Price tier from table_handset_msrp_tiers.HANDSET_MSRP_TIER';
COMMENT ON COLUMN sa.x_vas_subscriptions.ecommerce_order_id IS 'Ecommerce ID store for purchase from commerce';
COMMENT ON COLUMN sa.x_vas_subscriptions.vendor_contract_id IS 'Contract ID from Vendor associated to the VAS program';
COMMENT ON COLUMN sa.x_vas_subscriptions.case_id_number IS 'Refers to ID number in table_case';
COMMENT ON COLUMN sa.x_vas_subscriptions.refund_amount IS 'Refund amount';
COMMENT ON COLUMN sa.x_vas_subscriptions.refund_type IS 'Refund Type Electronic / Check';
COMMENT ON COLUMN sa.x_vas_subscriptions.is_claimed IS 'Is this claimed or not (Y/N)';