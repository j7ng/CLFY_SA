CREATE OR REPLACE FORCE VIEW sa.table_bus_lsc_view (objid,bus_objid,lsc_objid,role_name,s_role_name,focus_type,"ACTIVE",org_id,s_org_id,org_name,s_org_name,org_type,web_site,src_id,s_src_id,src_name,s_src_name,description,src_type,status,start_date,end_date,is_default) AS
select table_bus_lsc_role.objid, table_bus_org.objid,
 table_lead_source.objid, table_bus_lsc_role.role_name, table_bus_lsc_role.S_role_name,
 table_bus_lsc_role.focus_type, table_bus_lsc_role.active,
 table_bus_org.org_id, table_bus_org.S_org_id, table_bus_org.name, table_bus_org.S_name,
 table_bus_org.type, table_bus_org.web_site,
 table_lead_source.id, table_lead_source.S_id, table_lead_source.name, table_lead_source.S_name,
 table_lead_source.description, table_lead_source.type,
 table_lead_source.status, table_lead_source.start_date,
 table_lead_source.end_date, table_lead_source.is_default
 from table_bus_lsc_role, table_bus_org, table_lead_source
 where table_bus_org.objid = table_bus_lsc_role.bus_lsc2bus_org
 AND table_lead_source.objid = table_bus_lsc_role.bus_lsc2lead_source
 ;
COMMENT ON TABLE sa.table_bus_lsc_view IS 'Lead source information for an account';
COMMENT ON COLUMN sa.table_bus_lsc_view.objid IS 'bus_lsc_role internal record number';
COMMENT ON COLUMN sa.table_bus_lsc_view.bus_objid IS 'bus_org internal record number';
COMMENT ON COLUMN sa.table_bus_lsc_view.lsc_objid IS 'lead_source internal record number';
COMMENT ON COLUMN sa.table_bus_lsc_view.role_name IS 'Name of the role';
COMMENT ON COLUMN sa.table_bus_lsc_view.focus_type IS 'Object type ID of the role-player; i.e., 5017=a lead source s role for the account, 173=an account s role for the lead source';
COMMENT ON COLUMN sa.table_bus_lsc_view."ACTIVE" IS 'Indicates whether the role is currently being used; i.e., 0=inactive, 1=active, default=1';
COMMENT ON COLUMN sa.table_bus_lsc_view.org_id IS 'User-specified ID number of the organization';
COMMENT ON COLUMN sa.table_bus_lsc_view.org_name IS 'Name of the organization';
COMMENT ON COLUMN sa.table_bus_lsc_view.org_type IS 'Business type; e.g., competitor, prospect, customer. This is a user-defined pop up with default name Company Type';
COMMENT ON COLUMN sa.table_bus_lsc_view.web_site IS 'The URL of the main web page of the organization';
COMMENT ON COLUMN sa.table_bus_lsc_view.src_id IS 'Unique identifier of the lead source';
COMMENT ON COLUMN sa.table_bus_lsc_view.src_name IS 'Name of the lead source';
COMMENT ON COLUMN sa.table_bus_lsc_view.description IS 'Description of the lead source';
COMMENT ON COLUMN sa.table_bus_lsc_view.src_type IS 'Type of source; e.g., seminar, trade show, etc. This is a user-defined pop up with default name Lead Source Type';
COMMENT ON COLUMN sa.table_bus_lsc_view.status IS 'Status of the lead source. This is a user-defined pop up with default name Lead Source Status';
COMMENT ON COLUMN sa.table_bus_lsc_view.start_date IS 'The date the lead source became active';
COMMENT ON COLUMN sa.table_bus_lsc_view.end_date IS 'The date the lead source ends';
COMMENT ON COLUMN sa.table_bus_lsc_view.is_default IS 'Indicates whether the object is the default lead source; i.e., 0=no, 1=yes. Used for auto-generated opportunities, which must be related to a lead_source';