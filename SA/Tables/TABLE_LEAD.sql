CREATE TABLE sa.table_lead (
  objid NUMBER,
  dev NUMBER,
  arch_ind NUMBER,
  first_name VARCHAR2(30 BYTE),
  s_first_name VARCHAR2(30 BYTE),
  last_name VARCHAR2(30 BYTE),
  s_last_name VARCHAR2(30 BYTE),
  phone VARCHAR2(20 BYTE),
  s_phone VARCHAR2(20 BYTE),
  fax VARCHAR2(20 BYTE),
  address VARCHAR2(200 BYTE),
  s_address VARCHAR2(200 BYTE),
  address_2 VARCHAR2(200 BYTE),
  s_address_2 VARCHAR2(200 BYTE),
  mail_stop VARCHAR2(30 BYTE),
  city VARCHAR2(30 BYTE),
  s_city VARCHAR2(30 BYTE),
  "STATE" VARCHAR2(40 BYTE),
  s_state VARCHAR2(40 BYTE),
  postal_code VARCHAR2(20 BYTE),
  country VARCHAR2(40 BYTE),
  s_country VARCHAR2(40 BYTE),
  e_mail VARCHAR2(80 BYTE),
  title VARCHAR2(30 BYTE),
  s_title VARCHAR2(30 BYTE),
  web_site VARCHAR2(255 BYTE),
  company_name VARCHAR2(80 BYTE),
  s_company_name VARCHAR2(80 BYTE),
  sic_code VARCHAR2(25 BYTE),
  site_name VARCHAR2(80 BYTE),
  s_site_name VARCHAR2(80 BYTE),
  "TYPE" VARCHAR2(20 BYTE),
  s_type VARCHAR2(20 BYTE),
  create_date DATE,
  last_update DATE,
  status NUMBER,
  rating VARCHAR2(20 BYTE),
  "ACTIVE" NUMBER,
  followup_date DATE,
  followup_note VARCHAR2(255 BYTE),
  s_followup_note VARCHAR2(255 BYTE),
  owner_init VARCHAR2(40 BYTE),
  s_owner_init VARCHAR2(40 BYTE),
  role_name VARCHAR2(80 BYTE),
  s_role_name VARCHAR2(80 BYTE),
  phone_contact NUMBER,
  email_contact NUMBER,
  "TIME_ZONE" VARCHAR2(20 BYTE),
  s_time_zone VARCHAR2(20 BYTE),
  salutation VARCHAR2(20 BYTE),
  active_stamp DATE,
  lead2contact_role NUMBER,
  lead2lead_source NUMBER,
  lead_orig2user NUMBER,
  lead_owner2user NUMBER,
  lead_modifier2user NUMBER
);
ALTER TABLE sa.table_lead ADD SUPPLEMENTAL LOG GROUP dmtsora409983578_0 (address, address_2, arch_ind, city, company_name, country, dev, e_mail, fax, first_name, last_name, mail_stop, objid, phone, postal_code, sic_code, site_name, "STATE", s_address, s_address_2, s_city, s_company_name, s_country, s_first_name, s_last_name, s_phone, s_site_name, s_state, s_title, s_type, title, "TYPE", web_site) ALWAYS;
ALTER TABLE sa.table_lead ADD SUPPLEMENTAL LOG GROUP dmtsora409983578_1 ("ACTIVE", active_stamp, create_date, email_contact, followup_date, followup_note, last_update, lead2contact_role, lead2lead_source, lead_modifier2user, lead_orig2user, lead_owner2user, owner_init, phone_contact, rating, role_name, salutation, status, s_followup_note, s_owner_init, s_role_name, s_time_zone, "TIME_ZONE") ALWAYS;
COMMENT ON TABLE sa.table_lead IS 'Individual who is a sales lead for user';
COMMENT ON COLUMN sa.table_lead.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_lead.dev IS 'Row version number for mobile distribution purposes';
COMMENT ON COLUMN sa.table_lead.arch_ind IS 'When set to 1, indicates the object is ready for purge/archive';
COMMENT ON COLUMN sa.table_lead.first_name IS 'Lead s first name';
COMMENT ON COLUMN sa.table_lead.last_name IS 'Lead s last name';
COMMENT ON COLUMN sa.table_lead.phone IS 'Lead s phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_lead.fax IS 'Lead s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_lead.address IS 'Line one of the lead s address';
COMMENT ON COLUMN sa.table_lead.address_2 IS 'Line two of the lead s address';
COMMENT ON COLUMN sa.table_lead.mail_stop IS 'Lead s internal company mail stop/location/building';
COMMENT ON COLUMN sa.table_lead.city IS 'City of the address';
COMMENT ON COLUMN sa.table_lead."STATE" IS 'State or province of the address';
COMMENT ON COLUMN sa.table_lead.postal_code IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_lead.country IS 'Country of the address';
COMMENT ON COLUMN sa.table_lead.e_mail IS 'Lead s e-mail address';
COMMENT ON COLUMN sa.table_lead.title IS 'Lead s professional title';
COMMENT ON COLUMN sa.table_lead.web_site IS 'The lead s URL';
COMMENT ON COLUMN sa.table_lead.company_name IS 'Name of the lead s company';
COMMENT ON COLUMN sa.table_lead.sic_code IS 'Industry (sic) code or equivalent';
COMMENT ON COLUMN sa.table_lead.site_name IS 'Lead s site or location name';
COMMENT ON COLUMN sa.table_lead."TYPE" IS 'Characterizes the lead as a business opportunity or a consumer opportunity';
COMMENT ON COLUMN sa.table_lead.create_date IS 'The create date for the lead';
COMMENT ON COLUMN sa.table_lead.last_update IS 'Datetime of last update to the lead';
COMMENT ON COLUMN sa.table_lead.status IS 'Lead s status; i.e., 0=not yet promoted to a contact, 1=promoted to a contact';
COMMENT ON COLUMN sa.table_lead.rating IS 'How hot the lead is; from a user-defined popup with name Lead Status';
COMMENT ON COLUMN sa.table_lead."ACTIVE" IS 'Indicates whether the lead is currently active; i.e., 0=active, 1=inactive, 2=obsolete, default=0';
COMMENT ON COLUMN sa.table_lead.followup_date IS 'The date and time that a follow up should happen';
COMMENT ON COLUMN sa.table_lead.followup_note IS 'Note for the followup';
COMMENT ON COLUMN sa.table_lead.owner_init IS 'Full name of the initial owner of the lead';
COMMENT ON COLUMN sa.table_lead.role_name IS 'Role that lead plays in his/her organization. Default role_name that is propagated to object contact_role.role name when the lead is promoted to a contact';
COMMENT ON COLUMN sa.table_lead.phone_contact IS 'Gives constraints on contacting the lead by phone; e.g., 0=do not call, 1=unrestricted calling. Default=1';
COMMENT ON COLUMN sa.table_lead.email_contact IS 'Gives constraints on contacting the lead by email; e.g., 0=do not email, 1=unrestricted email. Default=1';
COMMENT ON COLUMN sa.table_lead."TIME_ZONE" IS 'Time zone name in which an address is located';
COMMENT ON COLUMN sa.table_lead.salutation IS 'A form of address; e.g., Mr., Miss, Mrs';
COMMENT ON COLUMN sa.table_lead.active_stamp IS 'The date and time when field active last change';
COMMENT ON COLUMN sa.table_lead.lead2contact_role IS 'If the lead is promoted to a contact, the related contact_role object. This gives some indication of what the business context for the promotion';
COMMENT ON COLUMN sa.table_lead.lead2lead_source IS 'Lead source which generated the lead';
COMMENT ON COLUMN sa.table_lead.lead_orig2user IS 'User who created the lead';
COMMENT ON COLUMN sa.table_lead.lead_owner2user IS 'User who currently owns the lead';
COMMENT ON COLUMN sa.table_lead.lead_modifier2user IS 'User who last modified the lead';