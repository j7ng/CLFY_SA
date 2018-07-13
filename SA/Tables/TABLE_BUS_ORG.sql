CREATE TABLE sa.table_bus_org (
  objid NUMBER,
  org_id VARCHAR2(40 BYTE),
  s_org_id VARCHAR2(40 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(40 BYTE),
  loc_type VARCHAR2(80 BYTE),
  year_end VARCHAR2(25 BYTE),
  year_start VARCHAR2(25 BYTE),
  tax_exempt VARCHAR2(25 BYTE),
  standards VARCHAR2(25 BYTE),
  phone VARCHAR2(20 BYTE),
  fax VARCHAR2(20 BYTE),
  business_desc VARCHAR2(255 BYTE),
  web_site VARCHAR2(255 BYTE),
  stock_sym VARCHAR2(10 BYTE),
  revn_range VARCHAR2(20 BYTE),
  size_empl VARCHAR2(20 BYTE),
  size_revn NUMBER,
  product VARCHAR2(255 BYTE),
  "OWNERSHIP" VARCHAR2(25 BYTE),
  comments VARCHAR2(255 BYTE),
  alt_name VARCHAR2(80 BYTE),
  e_mail VARCHAR2(80 BYTE),
  arch_ind NUMBER,
  dev NUMBER,
  prospect2territory NUMBER(*,0),
  bus_primary2address NUMBER(*,0),
  alt_url VARCHAR2(255 BYTE),
  status NUMBER,
  update_stamp DATE,
  defaultbus2price_prog NUMBER,
  fed_tax_id VARCHAR2(40 BYTE),
  sales_tax_id VARCHAR2(40 BYTE),
  struct_type NUMBER,
  bus_node NUMBER,
  collectn_sts VARCHAR2(20 BYTE),
  is_competitor NUMBER,
  is_partner NUMBER,
  primary2site NUMBER,
  tax_exempt_start_dt DATE,
  x_411_number VARCHAR2(30 BYTE),
  org_flow VARCHAR2(1 BYTE),
  org_conversion NUMBER,
  leasing_flag VARCHAR2(1 BYTE),
  shared_group_flag VARCHAR2(1 BYTE),
  brm_applicable_flag VARCHAR2(1 BYTE) DEFAULT 'N',
  arpu_amount NUMBER(22),
  arpu_multiplier NUMBER(22),
  addon_rtr_applicable_flag VARCHAR2(1 BYTE),
  w3ci_acronym VARCHAR2(3 BYTE),
  brm_notification_flag VARCHAR2(1 BYTE),
  pin_required_reactivation_flag VARCHAR2(1 BYTE),
  email_trans_summary_flag VARCHAR2(1 BYTE),
  sms_template VARCHAR2(400 BYTE),
  sms_trans_summary_flag VARCHAR2(1 BYTE),
  bogo_enabled_flag VARCHAR2(1 BYTE),
  clfy_rtc_queue_flag VARCHAR2(1 BYTE),
  multiline_discount_flag VARCHAR2(1 BYTE),
  sms_flag_3ci VARCHAR2(1 BYTE)
);
ALTER TABLE sa.table_bus_org ADD SUPPLEMENTAL LOG GROUP dmtsora1983746384_1 (bus_node, collectn_sts, is_competitor, is_partner, primary2site, sales_tax_id, struct_type, tax_exempt_start_dt) ALWAYS;
ALTER TABLE sa.table_bus_org ADD SUPPLEMENTAL LOG GROUP dmtsora1983746384_0 (alt_name, alt_url, arch_ind, business_desc, bus_primary2address, comments, defaultbus2price_prog, dev, e_mail, fax, fed_tax_id, loc_type, "NAME", objid, org_id, "OWNERSHIP", phone, product, prospect2territory, revn_range, size_empl, size_revn, standards, status, stock_sym, s_name, s_org_id, tax_exempt, "TYPE", update_stamp, web_site, year_end, year_start) ALWAYS;
COMMENT ON TABLE sa.table_bus_org IS 'A business entity which has roles and responsibilities that need to be tracked';
COMMENT ON COLUMN sa.table_bus_org.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_bus_org.org_id IS 'User-specified ID number of the organization';
COMMENT ON COLUMN sa.table_bus_org."NAME" IS 'Name of the organization';
COMMENT ON COLUMN sa.table_bus_org."TYPE" IS 'Business type; e.g., competitor, prospect, customer. This is a user-defined pop up with default name Company Type';
COMMENT ON COLUMN sa.table_bus_org.loc_type IS 'Location type; e.g., headquarters, subsidiary, etc. This is a user-defined pop up';
COMMENT ON COLUMN sa.table_bus_org.year_end IS 'Fiscal year end';
COMMENT ON COLUMN sa.table_bus_org.year_start IS 'Fiscal year start';
COMMENT ON COLUMN sa.table_bus_org.tax_exempt IS 'Reserved not used; see account';
COMMENT ON COLUMN sa.table_bus_org.standards IS 'Standards the business organization adheres to; e.g., ISO 9000';
COMMENT ON COLUMN sa.table_bus_org.phone IS 'Main phone number of the organization';
COMMENT ON COLUMN sa.table_bus_org.fax IS 'Main fax number of the organization';
COMMENT ON COLUMN sa.table_bus_org.business_desc IS 'Describes the purpose of the organization or the business it is in';
COMMENT ON COLUMN sa.table_bus_org.web_site IS 'The URL of the main web page of the organization';
COMMENT ON COLUMN sa.table_bus_org.stock_sym IS 'Stock symbol';
COMMENT ON COLUMN sa.table_bus_org.revn_range IS 'Revenue range of the bus_org. This is a user-defined popup with default name Company Revenue';
COMMENT ON COLUMN sa.table_bus_org.size_empl IS 'Estimated number of employees in the organization';
COMMENT ON COLUMN sa.table_bus_org.size_revn IS 'Estimated company revenue';
COMMENT ON COLUMN sa.table_bus_org.product IS 'A high-level description of the products that the business organization sells';
COMMENT ON COLUMN sa.table_bus_org."OWNERSHIP" IS 'Type of ownership. This is a user-defined popup with defaul name Company Ownership';
COMMENT ON COLUMN sa.table_bus_org.comments IS 'Additional comments about the organization';
COMMENT ON COLUMN sa.table_bus_org.alt_name IS 'An alternate name for the organization';
COMMENT ON COLUMN sa.table_bus_org.e_mail IS 'Primary e-mail address of the organization';
COMMENT ON COLUMN sa.table_bus_org.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_bus_org.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_bus_org.prospect2territory IS 'Territory to which the organization is assigned';
COMMENT ON COLUMN sa.table_bus_org.bus_primary2address IS 'Primary address of the business organization. Reserved; not used. Gets addresses from related sites';
COMMENT ON COLUMN sa.table_bus_org.alt_url IS 'Alternate URL for the account. Reserved; future';
COMMENT ON COLUMN sa.table_bus_org.status IS 'Status of bus_org; i.e., 0=active, 1=inactive, 2=obsolete, default=0';
COMMENT ON COLUMN sa.table_bus_org.update_stamp IS 'Date/time of last update to the bus_org';
COMMENT ON COLUMN sa.table_bus_org.defaultbus2price_prog IS 'The default price book for the account';
COMMENT ON COLUMN sa.table_bus_org.fed_tax_id IS 'Account s federal tax idenfification number';
COMMENT ON COLUMN sa.table_bus_org.sales_tax_id IS 'Account s sales tax idenfification number';
COMMENT ON COLUMN sa.table_bus_org.struct_type IS 'The scope of the account; i.e., 0=business to business account, 1=business to consumer account, default=0.';
COMMENT ON COLUMN sa.table_bus_org.bus_node IS 'Indicates whether the bus_org is a Customer or Organizational Unit ; i.e. 0=Customer, 1=Organizational Unit';
COMMENT ON COLUMN sa.table_bus_org.collectn_sts IS 'GL ACCOUNT FOR UNLOCK BUYBACK';
COMMENT ON COLUMN sa.table_bus_org.is_competitor IS 'Indicates whether the bus_org is a competitor; i.e., 0=No, 1=Yes';
COMMENT ON COLUMN sa.table_bus_org.is_partner IS 'Indicates whether the bus_org is a partner; i.e., 0=No, 1=Yes';
COMMENT ON COLUMN sa.table_bus_org.primary2site IS 'Primary site for the organization';
COMMENT ON COLUMN sa.table_bus_org.tax_exempt_start_dt IS 'Date Tax exemption is started';
COMMENT ON COLUMN sa.table_bus_org.org_flow IS 'DECISION PATHS FOR SIMILAR COMPANY LOGIC ';
COMMENT ON COLUMN sa.table_bus_org.org_conversion IS 'DEFAULT VALUE FOR PHONE CONVERSION BASED ON ORG';
COMMENT ON COLUMN sa.table_bus_org.addon_rtr_applicable_flag IS 'Whether the brand needs to allow add on activation through RTR';
COMMENT ON COLUMN sa.table_bus_org.w3ci_acronym IS 'Masked value of the brand that will be sent to 3CI';
COMMENT ON COLUMN sa.table_bus_org.brm_notification_flag IS 'Column which indicates whether the brand is maintained by BRM or not';
COMMENT ON COLUMN sa.table_bus_org.pin_required_reactivation_flag IS 'Column that indicates if the PIN is required for reactiation at brand level';
COMMENT ON COLUMN sa.table_bus_org.email_trans_summary_flag IS 'Send Purchase Confirmation as email, if flag is Y';
COMMENT ON COLUMN sa.table_bus_org.sms_template IS 'SMS Template of Brand';
COMMENT ON COLUMN sa.table_bus_org.sms_trans_summary_flag IS 'Send Purchase Confirmation as SMS, if flag is Y';
COMMENT ON COLUMN sa.table_bus_org.bogo_enabled_flag IS 'Enable BOGO functionality flag where Y allows and N or NULL prevents';
COMMENT ON COLUMN sa.table_bus_org.clfy_rtc_queue_flag IS 'Enable call to CLFY_RTC_Q queue flag where Y allows and N or NULL prevents';
COMMENT ON COLUMN sa.table_bus_org.sms_flag_3ci IS '3CI SMS Enabled Flag ';