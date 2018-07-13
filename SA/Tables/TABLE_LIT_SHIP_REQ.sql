CREATE TABLE sa.table_lit_ship_req (
  objid NUMBER,
  dev NUMBER,
  first_name VARCHAR2(30 BYTE),
  s_first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  s_last_name VARCHAR2(30 BYTE),
  phone VARCHAR2(20 BYTE),
  fax VARCHAR2(20 BYTE),
  e_mail VARCHAR2(80 BYTE),
  address VARCHAR2(200 BYTE),
  s_address VARCHAR2(200 BYTE),
  city VARCHAR2(30 BYTE),
  s_city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  s_state VARCHAR2(40 BYTE),
  postal_code VARCHAR2(20 BYTE),
  address_2 VARCHAR2(200 BYTE),
  s_address_2 VARCHAR2(200 BYTE),
  mail_stop VARCHAR2(30 BYTE),
  country VARCHAR2(40 BYTE),
  s_country VARCHAR2(40 BYTE),
  lit_ship_req2lit_req NUMBER,
  lit_ship_req2lead NUMBER,
  lit_ship2contact_role NUMBER,
  lit_ship_req2bus_org NUMBER,
  lit_ship2opportunity NUMBER
);
ALTER TABLE sa.table_lit_ship_req ADD SUPPLEMENTAL LOG GROUP dmtsora996619661_0 (address, address_2, city, country, dev, e_mail, fax, first_name, last_name, lit_ship2contact_role, lit_ship2opportunity, lit_ship_req2bus_org, lit_ship_req2lead, lit_ship_req2lit_req, mail_stop, objid, phone, postal_code, "STATE", s_address, s_address_2, s_city, s_country, s_first_name, s_last_name, s_state) ALWAYS;
COMMENT ON TABLE sa.table_lit_ship_req IS 'Contains shipping information for a particular recipient of a literature request';
COMMENT ON COLUMN sa.table_lit_ship_req.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_lit_ship_req.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_lit_ship_req.first_name IS 'First name of the recipient';
COMMENT ON COLUMN sa.table_lit_ship_req.last_name IS 'Last name of the recipient';
COMMENT ON COLUMN sa.table_lit_ship_req.phone IS 'Recipient s phone number';
COMMENT ON COLUMN sa.table_lit_ship_req.fax IS 'Recipient s fax number';
COMMENT ON COLUMN sa.table_lit_ship_req.e_mail IS 'Recipient s email address';
COMMENT ON COLUMN sa.table_lit_ship_req.address IS 'Line 1 of address which includes street number, street name, office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_lit_ship_req.city IS 'The city for the specified address';
COMMENT ON COLUMN sa.table_lit_ship_req."STATE" IS 'The state for the specified address';
COMMENT ON COLUMN sa.table_lit_ship_req.postal_code IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_lit_ship_req.address_2 IS 'Line 2 of address which typically includes office, building, or suite number, etc';
COMMENT ON COLUMN sa.table_lit_ship_req.mail_stop IS 'Recipient s internal company mail stop/location/building';
COMMENT ON COLUMN sa.table_lit_ship_req.country IS 'Country of the address';
COMMENT ON COLUMN sa.table_lit_ship_req.lit_ship_req2lead IS 'Lead recipient';
COMMENT ON COLUMN sa.table_lit_ship_req.lit_ship2contact_role IS 'Contact role for the shipment';
COMMENT ON COLUMN sa.table_lit_ship_req.lit_ship_req2bus_org IS 'Related account';
COMMENT ON COLUMN sa.table_lit_ship_req.lit_ship2opportunity IS 'Related opportunity';