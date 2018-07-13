CREATE TABLE sa.table_fcs_header (
  objid NUMBER,
  req_case_num VARCHAR2(15 BYTE),
  request_date DATE,
  req_originator VARCHAR2(30 BYTE),
  site_name VARCHAR2(80 BYTE),
  ship_addr1 VARCHAR2(200 BYTE),
  ship_addr2 VARCHAR2(200 BYTE),
  ship_city VARCHAR2(30 BYTE),
  ship_state VARCHAR2(40 BYTE),
  ship_zip VARCHAR2(20 BYTE),
  ship_country VARCHAR2(40 BYTE),
  ship_attn VARCHAR2(30 BYTE),
  request_note VARCHAR2(255 BYTE),
  header_status VARCHAR2(20 BYTE),
  dev NUMBER,
  req_by2case NUMBER(*,0),
  req_by2subcase NUMBER(*,0),
  cur_owner2owner NUMBER(*,0)
);
ALTER TABLE sa.table_fcs_header ADD SUPPLEMENTAL LOG GROUP dmtsora1318164791_0 (cur_owner2owner, dev, header_status, objid, request_date, request_note, req_by2case, req_by2subcase, req_case_num, req_originator, ship_addr1, ship_addr2, ship_attn, ship_city, ship_country, ship_state, ship_zip, site_name) ALWAYS;
COMMENT ON TABLE sa.table_fcs_header IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.objid IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.req_case_num IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.request_date IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.req_originator IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.site_name IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.ship_addr1 IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.ship_addr2 IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.ship_city IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.ship_state IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.ship_zip IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.ship_country IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.ship_attn IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.request_note IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.header_status IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_fcs_header.req_by2case IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.req_by2subcase IS 'Reserved; custom';
COMMENT ON COLUMN sa.table_fcs_header.cur_owner2owner IS 'Reserved; custom';