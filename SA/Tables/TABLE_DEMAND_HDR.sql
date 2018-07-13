CREATE TABLE sa.table_demand_hdr (
  objid NUMBER,
  header_number VARCHAR2(20 BYTE),
  s_header_number VARCHAR2(20 BYTE),
  header_case_no VARCHAR2(255 BYTE),
  header_date DATE,
  originator VARCHAR2(30 BYTE),
  s_originator VARCHAR2(30 BYTE),
  site_name VARCHAR2(80 BYTE),
  s_site_name VARCHAR2(80 BYTE),
  ship_address VARCHAR2(200 BYTE),
  s_ship_address VARCHAR2(200 BYTE),
  ship_address2 VARCHAR2(200 BYTE),
  ship_city VARCHAR2(30 BYTE),
  s_ship_city VARCHAR2(30 BYTE),
  ship_zip VARCHAR2(20 BYTE),
  ship_attn VARCHAR2(30 BYTE),
  s_ship_attn VARCHAR2(30 BYTE),
  ship_state VARCHAR2(40 BYTE),
  ship_country VARCHAR2(40 BYTE),
  demand_type NUMBER,
  partials NUMBER,
  order_acknowl NUMBER,
  request_notes VARCHAR2(255 BYTE),
  request_auth NUMBER,
  request_status VARCHAR2(20 BYTE),
  sequence_num NUMBER,
  pay_terms VARCHAR2(40 BYTE),
  s_pay_terms VARCHAR2(40 BYTE),
  pay_method VARCHAR2(40 BYTE),
  s_pay_method VARCHAR2(40 BYTE),
  "PRIORITY" VARCHAR2(40 BYTE),
  ownership_stmp DATE,
  modify_stmp DATE,
  dist NUMBER,
  removed NUMBER,
  ship_attn2 VARCHAR2(40 BYTE),
  s_ship_attn2 VARCHAR2(40 BYTE),
  attn_phone VARCHAR2(40 BYTE),
  ship_site_id VARCHAR2(80 BYTE),
  s_ship_site_id VARCHAR2(80 BYTE),
  arch_ind NUMBER,
  dev NUMBER,
  caseinfo2case NUMBER(*,0),
  current_owner2owner NUMBER(*,0),
  ship_info2state_prov NUMBER(*,0),
  ship_info2country NUMBER(*,0),
  subcaseinfo2case NUMBER(*,0),
  attention2contact NUMBER(*,0),
  open_reqst2site NUMBER(*,0),
  bill_reqst2site NUMBER(*,0),
  reqst2contr_schedule NUMBER(*,0),
  notes VARCHAR2(255 BYTE)
);
ALTER TABLE sa.table_demand_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora735029467_0 (demand_type, header_case_no, header_date, header_number, modify_stmp, objid, order_acknowl, originator, ownership_stmp, partials, pay_method, pay_terms, "PRIORITY", request_auth, request_notes, request_status, sequence_num, ship_address, ship_address2, ship_attn, ship_city, ship_country, ship_state, ship_zip, site_name, s_header_number, s_originator, s_pay_method, s_pay_terms, s_ship_address, s_ship_attn, s_ship_city, s_site_name) ALWAYS;
ALTER TABLE sa.table_demand_hdr ADD SUPPLEMENTAL LOG GROUP dmtsora735029467_1 (arch_ind, attention2contact, attn_phone, bill_reqst2site, caseinfo2case, current_owner2owner, dev, dist, notes, open_reqst2site, removed, reqst2contr_schedule, ship_attn2, ship_info2country, ship_info2state_prov, ship_site_id, subcaseinfo2case, s_ship_attn2, s_ship_site_id) ALWAYS;
COMMENT ON TABLE sa.table_demand_hdr IS 'Part request; contains basic request information';
COMMENT ON COLUMN sa.table_demand_hdr.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_demand_hdr.header_number IS 'The request ID for the part request header';
COMMENT ON COLUMN sa.table_demand_hdr.header_case_no IS 'The ID of the object which originated the header; i.e., the case, subcase, or opportunity ID';
COMMENT ON COLUMN sa.table_demand_hdr.header_date IS 'The create date for the request header';
COMMENT ON COLUMN sa.table_demand_hdr.originator IS 'The user originator for the request';
COMMENT ON COLUMN sa.table_demand_hdr.site_name IS 'Local copy of the site name';
COMMENT ON COLUMN sa.table_demand_hdr.ship_address IS 'Local copy of the site address; line 1';
COMMENT ON COLUMN sa.table_demand_hdr.ship_address2 IS 'Local copy of the site address; line 2';
COMMENT ON COLUMN sa.table_demand_hdr.ship_city IS 'Local copy of the site city';
COMMENT ON COLUMN sa.table_demand_hdr.ship_zip IS 'Local copy of the site zip or other postal code';
COMMENT ON COLUMN sa.table_demand_hdr.ship_attn IS 'First name of the person the header is created for';
COMMENT ON COLUMN sa.table_demand_hdr.ship_state IS 'Local copy of the site state';
COMMENT ON COLUMN sa.table_demand_hdr.ship_country IS 'Local copy of the request country';
COMMENT ON COLUMN sa.table_demand_hdr.demand_type IS 'Type of part request; i.e., 0=standard part request, 1=literature part request, 2=vendor part request';
COMMENT ON COLUMN sa.table_demand_hdr.partials IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_hdr.order_acknowl IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_hdr.request_notes IS 'Comments about the request';
COMMENT ON COLUMN sa.table_demand_hdr.request_auth IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_hdr.request_status IS 'Status of the request';
COMMENT ON COLUMN sa.table_demand_hdr.sequence_num IS 'Reserved; future';
COMMENT ON COLUMN sa.table_demand_hdr.pay_terms IS 'Payment terms. This is from a user-defined popup with default name PAYMENT_TERMS';
COMMENT ON COLUMN sa.table_demand_hdr.pay_method IS 'Payment method. This is from a user-defined popup with default name PAYMENT_METHOD';
COMMENT ON COLUMN sa.table_demand_hdr."PRIORITY" IS 'Request priority This is from a user-defined popup with default name REQUEST_PRIORITY';
COMMENT ON COLUMN sa.table_demand_hdr.ownership_stmp IS 'The date and time when ownership changes';
COMMENT ON COLUMN sa.table_demand_hdr.modify_stmp IS 'The date and time when object is saved';
COMMENT ON COLUMN sa.table_demand_hdr.dist IS 'Reserved; not used';
COMMENT ON COLUMN sa.table_demand_hdr.removed IS 'Indicates the logical removal of the object; i.e., 0=present, 1=removed, default=0';
COMMENT ON COLUMN sa.table_demand_hdr.ship_attn2 IS 'Last name of the person the header is created for';
COMMENT ON COLUMN sa.table_demand_hdr.attn_phone IS 'Phone number of the person the header is created for';
COMMENT ON COLUMN sa.table_demand_hdr.ship_site_id IS 'Site ID of the ship to site selected for the header';
COMMENT ON COLUMN sa.table_demand_hdr.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_demand_hdr.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_demand_hdr.caseinfo2case IS 'The case the request is related to';
COMMENT ON COLUMN sa.table_demand_hdr.current_owner2owner IS 'Owner of the part request header';
COMMENT ON COLUMN sa.table_demand_hdr.ship_info2state_prov IS 'State or province to which the part request header is addressed';
COMMENT ON COLUMN sa.table_demand_hdr.ship_info2country IS 'Country to which the part request header is addressed';
COMMENT ON COLUMN sa.table_demand_hdr.subcaseinfo2case IS 'Reserved; not used. Use relation from parent case to demand_hdr instead';
COMMENT ON COLUMN sa.table_demand_hdr.attention2contact IS 'The contact for the request';
COMMENT ON COLUMN sa.table_demand_hdr.open_reqst2site IS 'Site to which the request will be shipped';
COMMENT ON COLUMN sa.table_demand_hdr.bill_reqst2site IS 'Site to which the request will be billed';
COMMENT ON COLUMN sa.table_demand_hdr.reqst2contr_schedule IS 'The contract/quote schedule the request is related to. Reserved; future';
COMMENT ON COLUMN sa.table_demand_hdr.notes IS 'Notes about the part request';