CREATE OR REPLACE FORCE VIEW sa.table_sfa_opp_mto_v (objid,terr_objid,leadsrc_objid,cycle_objid,currency_objid,opp_name,s_opp_name,opp_id,s_opp_id,terr_name,s_terr_name,terr_id,source_name,s_source_name,source_id,s_source_id,cycle_name,currency_name,s_currency_name,sub_scale,stage_objid,stage_name,s_stage_name) AS
select table_opportunity.objid, table_territory.objid,
 table_lead_source.objid, table_life_cycle.objid,
 table_currency.objid, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.id, table_opportunity.S_id, table_territory.name, table_territory.S_name,
 table_territory.terr_id, table_lead_source.name, table_lead_source.S_name,
 table_lead_source.id, table_lead_source.S_id, table_life_cycle.name,
 table_currency.name, table_currency.S_name, table_currency.sub_scale,
 table_cycle_stage.objid, table_cycle_stage.name, table_cycle_stage.S_name
 from table_opportunity, table_territory, table_lead_source,
  table_life_cycle, table_currency, table_cycle_stage
 where table_territory.objid (+) = table_opportunity.opp2territory
 AND table_lead_source.objid (+) = table_opportunity.opp2lead_source
 AND table_currency.objid (+) = table_opportunity.opp2currency
 AND table_life_cycle.objid (+) = table_opportunity.opp2life_cycle
 AND table_cycle_stage.objid = table_opportunity.opp2cycle_stage
 ;
COMMENT ON TABLE sa.table_sfa_opp_mto_v IS 'Displays opportunitys parent objects. Used by Used by Account Mgr (11650), Console-Sales (12000), and Opportunity Mgr (13000)';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.terr_objid IS 'Territory internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.leadsrc_objid IS 'Lead_source internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.cycle_objid IS 'Life_cycle internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.opp_name IS 'Name of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.opp_id IS 'Unique ID number of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.terr_name IS 'Name of the territory';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.terr_id IS 'Unique ID number of the territory';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.source_name IS 'Name of the lead source';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.source_id IS 'Unique ID of the lead source';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.cycle_name IS 'Name of the sales process';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.currency_name IS 'Currency in which the opportunity is denominated';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.stage_objid IS 'Cycle_stage internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_mto_v.stage_name IS 'Name of the Sales Stage';