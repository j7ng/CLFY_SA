CREATE OR REPLACE FORCE VIEW sa.table_con_lsc_view (objid,con_objid,lsc_objid,role_name,s_role_name,focus_type,"ACTIVE",first_name,s_first_name,last_name,s_last_name,phone,e_mail,title,status,src_id,s_src_id,src_name,s_src_name,description,src_type,src_status,start_date,end_date,is_default) AS
select table_con_lsc_role.objid, table_contact.objid,
 table_lead_source.objid, table_con_lsc_role.role_name, table_con_lsc_role.S_role_name,
 table_con_lsc_role.focus_type, table_con_lsc_role.active,
 table_contact.first_name, table_contact.S_first_name, table_contact.last_name, table_contact.S_last_name,
 table_contact.phone, table_contact.e_mail,
 table_contact.title, table_contact.status,
 table_lead_source.id, table_lead_source.S_id, table_lead_source.name, table_lead_source.S_name,
 table_lead_source.description, table_lead_source.type,
 table_lead_source.status, table_lead_source.start_date,
 table_lead_source.end_date, table_lead_source.is_default
 from table_con_lsc_role, table_contact, table_lead_source
 where table_contact.objid = table_con_lsc_role.con_lsc2contact
 AND table_lead_source.objid = table_con_lsc_role.con_lsc2lead_source
 ;
COMMENT ON TABLE sa.table_con_lsc_view IS 'Contact information for lead source. Used by form Campaign Mgr (11950)';
COMMENT ON COLUMN sa.table_con_lsc_view.objid IS 'Contact role internal record number';
COMMENT ON COLUMN sa.table_con_lsc_view.con_objid IS 'Contact internal record number';
COMMENT ON COLUMN sa.table_con_lsc_view.lsc_objid IS 'lead_source internal record number';
COMMENT ON COLUMN sa.table_con_lsc_view.role_name IS 'Name of the role';
COMMENT ON COLUMN sa.table_con_lsc_view.focus_type IS 'Object type ID of the role player; i.e., 5017=a lead source s role for the contact, 45=a contact s role for the lead source';
COMMENT ON COLUMN sa.table_con_lsc_view."ACTIVE" IS 'Indicates whether the role is currently being used; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_con_lsc_view.first_name IS 'Contact first name';
COMMENT ON COLUMN sa.table_con_lsc_view.last_name IS 'Contact last name';
COMMENT ON COLUMN sa.table_con_lsc_view.phone IS 'Contact phone number which includes area code, number, and extension';
COMMENT ON COLUMN sa.table_con_lsc_view.e_mail IS 'Contact s e-mail address';
COMMENT ON COLUMN sa.table_con_lsc_view.title IS 'Contact s professional title';
COMMENT ON COLUMN sa.table_con_lsc_view.status IS 'Status of contact; i.e., active/inactive/obsolete';
COMMENT ON COLUMN sa.table_con_lsc_view.src_id IS 'Unique identifier of the lead source';
COMMENT ON COLUMN sa.table_con_lsc_view.src_name IS 'Name of the lead source';
COMMENT ON COLUMN sa.table_con_lsc_view.description IS 'Description of the lead source';
COMMENT ON COLUMN sa.table_con_lsc_view.src_type IS 'Type of source; e.g., seminar, trade show, etc. This is a user-defined pop up with default name Lead Source Type';
COMMENT ON COLUMN sa.table_con_lsc_view.src_status IS 'Status of the lead source. This is a user-defined pop up with default name Lead Source Status';
COMMENT ON COLUMN sa.table_con_lsc_view.start_date IS 'The date the lead source became active';
COMMENT ON COLUMN sa.table_con_lsc_view.end_date IS 'The date the lead source ends';
COMMENT ON COLUMN sa.table_con_lsc_view.is_default IS 'Indicates whether the object is the default lead source; i.e., 0=no, 1=yes. Used for auto-generated opportunities, which must be related to a lead_source';