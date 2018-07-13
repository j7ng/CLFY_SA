CREATE TABLE sa.x_partner_id (
  objid NUMBER,
  x_partner_id VARCHAR2(30 BYTE),
  x_security_code VARCHAR2(30 BYTE),
  x_site_id VARCHAR2(30 BYTE),
  x_status VARCHAR2(30 BYTE),
  x_start_date DATE,
  x_end_date DATE
);
COMMENT ON TABLE sa.x_partner_id IS 'INFO OF RTR PARTNERS';
COMMENT ON COLUMN sa.x_partner_id.objid IS 'UNIQUE IDENTIFIER';
COMMENT ON COLUMN sa.x_partner_id.x_partner_id IS 'SIMPLE MOBILE DEALER LOGIN NAMES';
COMMENT ON COLUMN sa.x_partner_id.x_security_code IS 'SIMPLE MOBILE DEALER PASSWORDS';
COMMENT ON COLUMN sa.x_partner_id.x_site_id IS 'TRACFONE DEALER NAME MAPPING(TABLE_SITE.SITE_ID)';
COMMENT ON COLUMN sa.x_partner_id.x_status IS 'ACTIVE OR INACTIVE';
COMMENT ON COLUMN sa.x_partner_id.x_start_date IS 'ACTIVE START DATE';
COMMENT ON COLUMN sa.x_partner_id.x_end_date IS 'ACTIVE EDN DATE';