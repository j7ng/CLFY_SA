CREATE OR REPLACE FORCE VIEW sa.table_sfa_leadsrc (objid,cmp_objid,campaign_name,s_campaign_name,source_name,s_source_name,source_code,s_source_code,source_type,source_desc,source_loc,s_source_loc,source_st_dt,source_phone,source_status) AS
select table_lead_source.objid, table_campaign.objid,
 table_campaign.name, table_campaign.S_name, table_lead_source.name, table_lead_source.S_name,
 table_lead_source.id, table_lead_source.S_id, table_lead_source.type,
 table_lead_source.description, table_lead_source.location, table_lead_source.S_location,
 table_lead_source.start_date, table_lead_source.phone,
 table_lead_source.status
 from table_lead_source, table_campaign
 where table_campaign.objid = table_lead_source.source2campaign
 ;
COMMENT ON TABLE sa.table_sfa_leadsrc IS 'Displays the campaign name along with Lead Source information. Used by form Console-Sales (12000)';
COMMENT ON COLUMN sa.table_sfa_leadsrc.objid IS 'Lead_source internal record number';
COMMENT ON COLUMN sa.table_sfa_leadsrc.cmp_objid IS 'Campaign internal record number';
COMMENT ON COLUMN sa.table_sfa_leadsrc.campaign_name IS 'Name of the campaign';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_name IS 'Name of the lead source';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_code IS 'Unique identifier of the lead source';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_type IS 'Type of source; e.g., seminar, trade show, etc. This is a user-defined pop up with default name Lead Source Type';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_desc IS 'Description of the lead source';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_loc IS 'Location of the lead source';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_st_dt IS 'The date the lead source became active';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_phone IS 'Phone number of the lead source';
COMMENT ON COLUMN sa.table_sfa_leadsrc.source_status IS 'Status of the lead source. This is a user-defined pop up with default name Lead Source Status';