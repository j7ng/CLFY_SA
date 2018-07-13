CREATE TABLE sa.table_affiliated_partners (
  objid NUMBER NOT NULL,
  partner_name VARCHAR2(100 BYTE),
  partner_domain VARCHAR2(50 BYTE),
  partner_code VARCHAR2(50 BYTE),
  brand VARCHAR2(40 BYTE),
  status VARCHAR2(10 BYTE),
  created_on DATE,
  modified_on DATE,
  partner_type VARCHAR2(100 BYTE),
  partner_site_name VARCHAR2(1000 BYTE),
  dealer_id_check VARCHAR2(1 BYTE),
  comments VARCHAR2(4000 BYTE),
  brm_discount_name VARCHAR2(50 BYTE),
  CONSTRAINT affpart_pk PRIMARY KEY (objid),
  CONSTRAINT affpart_uk UNIQUE (partner_name,partner_domain,partner_code,brand,partner_type)
);
COMMENT ON TABLE sa.table_affiliated_partners IS 'Affiliated Partner configuration details';
COMMENT ON COLUMN sa.table_affiliated_partners.partner_name IS 'Partner Name';
COMMENT ON COLUMN sa.table_affiliated_partners.partner_domain IS 'Partner Domain';
COMMENT ON COLUMN sa.table_affiliated_partners.partner_code IS 'Partner Code';
COMMENT ON COLUMN sa.table_affiliated_partners.brand IS 'Brand';
COMMENT ON COLUMN sa.table_affiliated_partners.status IS 'STATUS (ACTIVE /INACTIVE)';
COMMENT ON COLUMN sa.table_affiliated_partners.partner_type IS 'AFFILIATED / MEMBER_ENROLL';
COMMENT ON COLUMN sa.table_affiliated_partners.partner_site_name IS 'SITE NAME from table_site';
COMMENT ON COLUMN sa.table_affiliated_partners.dealer_id_check IS 'Check for dealer ID, applicable for Membership partner type';