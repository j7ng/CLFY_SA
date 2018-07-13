CREATE OR REPLACE FORCE VIEW sa.table_lead_view (objid,first_name,s_first_name,last_name,s_last_name,phone,s_phone,address,s_address,mail_stop,city,s_city,"STATE",s_state,postal_code,country,s_country,title,s_title,company_name,s_company_name,site_name,s_site_name,"TYPE",s_type,rating,"ACTIVE",status,ldsrc_objid,ldsrc_name,s_ldsrc_name,ldsrc_status,ldsrc_type,owner_objid,owner_name,s_owner_name,fax,address_2,s_address_2,e_mail,web_site,"TIME_ZONE",s_time_zone,role_name,s_role_name,phone_contact,email_contact) AS
select table_lead.objid, table_lead.first_name, table_lead.S_first_name,
 table_lead.last_name, table_lead.S_last_name, table_lead.phone, table_lead.S_phone,
 table_lead.address, table_lead.S_address, table_lead.mail_stop,
 table_lead.city, table_lead.S_city, table_lead.state, table_lead.S_state,
 table_lead.postal_code, table_lead.country, table_lead.S_country,
 table_lead.title, table_lead.S_title, table_lead.company_name, table_lead.S_company_name,
 table_lead.site_name, table_lead.S_site_name, table_lead.type, table_lead.S_type,
 table_lead.rating, table_lead.active,
 table_lead.status, table_lead_source.objid,
 table_lead_source.name, table_lead_source.S_name, table_lead_source.status,
 table_lead_source.type, table_user.objid,
 table_user.login_name, table_user.S_login_name, table_lead.fax,
 table_lead.address_2, table_lead.S_address_2, table_lead.e_mail,
 table_lead.web_site, table_lead.time_zone, table_lead.S_time_zone,
 table_lead.role_name, table_lead.S_role_name, table_lead.phone_contact,
 table_lead.email_contact
 from table_lead, table_lead_source, table_user
 where table_lead_source.objid = table_lead.lead2lead_source
 AND table_user.objid = table_lead.lead_owner2user
 ;
COMMENT ON TABLE sa.table_lead_view IS 'Lead identification information. Used by forms Generic LookUp non-modal (20000) and Generic LookUp modal (40000)';
COMMENT ON COLUMN sa.table_lead_view.objid IS 'Internal record number';
COMMENT ON COLUMN sa.table_lead_view.first_name IS 'Lead s first name';
COMMENT ON COLUMN sa.table_lead_view.last_name IS 'Lead s last name';
COMMENT ON COLUMN sa.table_lead_view.phone IS 'Lead s phone number';
COMMENT ON COLUMN sa.table_lead_view.address IS 'Line one of the lead s address';
COMMENT ON COLUMN sa.table_lead_view.mail_stop IS 'Lead s internal company mail stop/location/building';
COMMENT ON COLUMN sa.table_lead_view.city IS 'City of the address';
COMMENT ON COLUMN sa.table_lead_view."STATE" IS 'State or province of the address';
COMMENT ON COLUMN sa.table_lead_view.postal_code IS 'The zip or other postal code for the specified address';
COMMENT ON COLUMN sa.table_lead_view.country IS 'Country of the address';
COMMENT ON COLUMN sa.table_lead_view.title IS 'Contact s professional title';
COMMENT ON COLUMN sa.table_lead_view.company_name IS 'Name of the lead s company';
COMMENT ON COLUMN sa.table_lead_view.site_name IS 'Lead s site or location name';
COMMENT ON COLUMN sa.table_lead_view."TYPE" IS 'Characterizes the lead as a business opportunity or a consumer opportunity';
COMMENT ON COLUMN sa.table_lead_view.rating IS 'How hot the lead is; from a user-defined popup with name Lead Status';
COMMENT ON COLUMN sa.table_lead_view."ACTIVE" IS 'Indicates whether the lead is currently active; i.e., 0=inactive, 1=active. Default=1';
COMMENT ON COLUMN sa.table_lead_view.status IS 'Lead s status; i.e., 0=not yet promoted to a contact, 1=promoted to a contact';
COMMENT ON COLUMN sa.table_lead_view.ldsrc_objid IS 'lead_source s internal record number';
COMMENT ON COLUMN sa.table_lead_view.ldsrc_name IS 'Name of the lead source';
COMMENT ON COLUMN sa.table_lead_view.ldsrc_status IS 'Status of the lead source. This is a user-defined pop up with default name Lead Source Status';
COMMENT ON COLUMN sa.table_lead_view.ldsrc_type IS 'Type of source; e.g., seminar, trade show, etc. This is a user-defined pop up with default name Lead Source Type';
COMMENT ON COLUMN sa.table_lead_view.owner_objid IS 'user internal record number';
COMMENT ON COLUMN sa.table_lead_view.owner_name IS 'User login name';
COMMENT ON COLUMN sa.table_lead_view.fax IS 'Lead s fax number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_lead_view.address_2 IS 'Line two of the lead s address';
COMMENT ON COLUMN sa.table_lead_view.e_mail IS 'Lead s e-mail address';
COMMENT ON COLUMN sa.table_lead_view.web_site IS 'Lead s URL';
COMMENT ON COLUMN sa.table_lead_view."TIME_ZONE" IS 'Time zone name in which an address is located';
COMMENT ON COLUMN sa.table_lead_view.role_name IS 'Role that lead plays in his/her organization. Default role_name that is propagated to object contact_role.role name when the lead is promoted to a contact';
COMMENT ON COLUMN sa.table_lead_view.phone_contact IS 'Gives constraints on contacting the lead by phone; e.g., 0=do not call, 1=unrestricted calling. Default=1';
COMMENT ON COLUMN sa.table_lead_view.email_contact IS 'Gives constraints on contacting the lead by email; e.g., 0=do not email, 1=unrestricted email. Default=1';