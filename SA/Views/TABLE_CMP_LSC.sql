CREATE OR REPLACE FORCE VIEW sa.table_cmp_lsc (lsc_objid,cmp_objid,campaign_name,s_campaign_name,source_name,s_source_name,source_code,s_source_code,source_type,source_description,source_location,s_source_location,source_start_date,source_phone,source_status) AS
select table_lead_source.objid, table_campaign.objid,
 table_campaign.name, table_campaign.S_name, table_lead_source.name, table_lead_source.S_name,
 table_lead_source.id, table_lead_source.S_id, table_lead_source.type,
 table_lead_source.description, table_lead_source.location, table_lead_source.S_location,
 table_lead_source.start_date, table_lead_source.phone,
 table_lead_source.status
 from table_lead_source, table_campaign
 where table_campaign.objid = table_lead_source.source2campaign
 ;
COMMENT ON TABLE sa.table_cmp_lsc IS 'Used by forms Select Lead Source (9510), Generic LookUp (20000), Generic Lookup (40000), Literature Request Detail (11614) Lead (11610)';
COMMENT ON COLUMN sa.table_cmp_lsc.lsc_objid IS 'Lead_source internal record number';
COMMENT ON COLUMN sa.table_cmp_lsc.cmp_objid IS 'Campaign internal record number';
COMMENT ON COLUMN sa.table_cmp_lsc.campaign_name IS 'Name of the campaign';
COMMENT ON COLUMN sa.table_cmp_lsc.source_name IS 'Name of the lead source';
COMMENT ON COLUMN sa.table_cmp_lsc.source_code IS 'ID of the lead source';
COMMENT ON COLUMN sa.table_cmp_lsc.source_type IS 'Type of lead source';
COMMENT ON COLUMN sa.table_cmp_lsc.source_description IS 'Description of the lead source';
COMMENT ON COLUMN sa.table_cmp_lsc.source_location IS 'Location of the lead source';
COMMENT ON COLUMN sa.table_cmp_lsc.source_start_date IS 'The date the lead source became active';
COMMENT ON COLUMN sa.table_cmp_lsc.source_phone IS 'Phone number of the lead source';
COMMENT ON COLUMN sa.table_cmp_lsc.source_status IS 'Status of the lead source. This is a user-defined pop up';