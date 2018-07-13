CREATE TABLE sa.table_site (
  objid NUMBER,
  site_id VARCHAR2(80 BYTE),
  "NAME" VARCHAR2(80 BYTE),
  s_name VARCHAR2(80 BYTE),
  external_id VARCHAR2(80 BYTE),
  "TYPE" NUMBER,
  logistics_type NUMBER,
  is_support NUMBER,
  region VARCHAR2(80 BYTE),
  s_region VARCHAR2(80 BYTE),
  district VARCHAR2(80 BYTE),
  s_district VARCHAR2(80 BYTE),
  depot VARCHAR2(80 BYTE),
  contr_login VARCHAR2(80 BYTE),
  contr_passwd VARCHAR2(80 BYTE),
  is_default NUMBER,
  notes VARCHAR2(255 BYTE),
  spec_consid NUMBER,
  mdbk VARCHAR2(80 BYTE),
  state_code NUMBER,
  state_value VARCHAR2(20 BYTE),
  industry_type VARCHAR2(30 BYTE),
  appl_type VARCHAR2(30 BYTE),
  cut_date DATE,
  site_type VARCHAR2(4 BYTE),
  status NUMBER,
  arch_ind NUMBER,
  alert_ind NUMBER,
  phone VARCHAR2(20 BYTE),
  fax VARCHAR2(20 BYTE),
  dev NUMBER,
  child_site2site NUMBER(*,0),
  support_office2site NUMBER(*,0),
  cust_primaddr2address NUMBER(*,0),
  cust_billaddr2address NUMBER(*,0),
  cust_shipaddr2address NUMBER(*,0),
  site_support2employee NUMBER(*,0),
  site_altsupp2employee NUMBER(*,0),
  report_site2bug NUMBER(*,0),
  primary2bus_org NUMBER(*,0),
  site2exch_protocol NUMBER(*,0),
  dealer2x_promotion NUMBER,
  x_smp_optional NUMBER DEFAULT 1,
  update_stamp DATE,
  x_fin_cust_id VARCHAR2(40 BYTE),
  ship_via VARCHAR2(80 BYTE),
  x_commerce_id VARCHAR2(150 BYTE),
  x_ship_loc_id NUMBER(22),
  x_referral_id VARCHAR2(20 BYTE),
  CONSTRAINT commerce_id_unique UNIQUE (x_commerce_id) USING INDEX sa.ind_commerce_id,
  CONSTRAINT ship_loc_id_unique UNIQUE (x_ship_loc_id) USING INDEX sa.ind_ship_loc_id
);
ALTER TABLE sa.table_site ADD SUPPLEMENTAL LOG GROUP dmtsora734089445_0 (alert_ind, appl_type, arch_ind, child_site2site, contr_login, contr_passwd, cut_date, depot, dev, district, external_id, fax, industry_type, is_default, is_support, logistics_type, mdbk, "NAME", notes, objid, phone, region, site_id, site_type, spec_consid, state_code, state_value, status, support_office2site, s_district, s_name, s_region, "TYPE") ALWAYS;
ALTER TABLE sa.table_site ADD SUPPLEMENTAL LOG GROUP dmtsora734089445_1 (cust_billaddr2address, cust_primaddr2address, cust_shipaddr2address, dealer2x_promotion, primary2bus_org, report_site2bug, ship_via, site2exch_protocol, site_altsupp2employee, site_support2employee, update_stamp, x_fin_cust_id, x_smp_optional) ALWAYS;
COMMENT ON TABLE sa.table_site IS 'A facility or location where business activities occur and parts are located';
COMMENT ON COLUMN sa.table_site.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_site.site_id IS 'Unique site number assigned according to auto-numbering definition';
COMMENT ON COLUMN sa.table_site."NAME" IS 'Name of the site';
COMMENT ON COLUMN sa.table_site.external_id IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site."TYPE" IS 'Site type; i.e., 1=BUSINESS, 2=OFFICE, 3=RESELLER, 4=INDIVIDUAL, 5=VENDOR';
COMMENT ON COLUMN sa.table_site.logistics_type IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.is_support IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.region IS 'Region to which the site belongs';
COMMENT ON COLUMN sa.table_site.district IS 'District to which the site belongs';
COMMENT ON COLUMN sa.table_site.depot IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.contr_login IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.contr_passwd IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.is_default IS 'Determines if site is default site';
COMMENT ON COLUMN sa.table_site.notes IS 'Site notes used with special consideration flag';
COMMENT ON COLUMN sa.table_site.spec_consid IS 'Check box which, when checked, specifies that site information is to be displayed automatically when new case is created';
COMMENT ON COLUMN sa.table_site.mdbk IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.state_code IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.state_value IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.industry_type IS 'Type of industry the site is in. This is a user-defined popup with name INDUSTRY_TYPE';
COMMENT ON COLUMN sa.table_site.appl_type IS 'Type of application site uses an installed part for; used in service interuption report. From user-defined pop up with default name PRIMARY_USE';
COMMENT ON COLUMN sa.table_site.cut_date IS 'Date/time when site started use of the installed part; used in service interuption report';
COMMENT ON COLUMN sa.table_site.site_type IS 'Mnemonic representation of the integer site type field';
COMMENT ON COLUMN sa.table_site.status IS 'Status of site; i.e., 0=active, 1=inactive, 2=obsolete, default=0';
COMMENT ON COLUMN sa.table_site.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_site.alert_ind IS 'When set to 1, indicates there is an alert related to the site';
COMMENT ON COLUMN sa.table_site.phone IS 'Main phone number';
COMMENT ON COLUMN sa.table_site.fax IS 'Main fax number';
COMMENT ON COLUMN sa.table_site.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_site.child_site2site IS 'Parent site of the site';
COMMENT ON COLUMN sa.table_site.support_office2site IS 'Support office site of the site';
COMMENT ON COLUMN sa.table_site.cust_primaddr2address IS 'Site primary address';
COMMENT ON COLUMN sa.table_site.cust_billaddr2address IS 'Site billing address';
COMMENT ON COLUMN sa.table_site.cust_shipaddr2address IS 'Site shipping address';
COMMENT ON COLUMN sa.table_site.site_support2employee IS 'Primary support person for the site';
COMMENT ON COLUMN sa.table_site.site_altsupp2employee IS 'Alternate support person for the site';
COMMENT ON COLUMN sa.table_site.report_site2bug IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_site.primary2bus_org IS 'Organization which owns the site';
COMMENT ON COLUMN sa.table_site.site2exch_protocol IS 'Exchange protocols used for the site';
COMMENT ON COLUMN sa.table_site.dealer2x_promotion IS 'Promotions assigned to individual dealers';
COMMENT ON COLUMN sa.table_site.x_smp_optional IS 'Designates whether the SMP is optional for cards purchased at the dealer; 0=no, 1=yes';
COMMENT ON COLUMN sa.table_site.update_stamp IS 'Date/time of last update to the site';
COMMENT ON COLUMN sa.table_site.x_fin_cust_id IS 'Oracle Financial Customer ID';
COMMENT ON COLUMN sa.table_site.ship_via IS 'Default means of shipment for the site. This is from a Clarify-defined popup list with default name SHIP_VIA';
COMMENT ON COLUMN sa.table_site.x_commerce_id IS 'ID from E-Commerce system';
COMMENT ON COLUMN sa.table_site.x_ship_loc_id IS 'ID from OFS system';
COMMENT ON COLUMN sa.table_site.x_referral_id IS 'Referral ID from E-Commerce system';