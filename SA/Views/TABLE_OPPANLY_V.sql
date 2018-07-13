CREATE OR REPLACE FORCE VIEW sa.table_oppanly_v (objid,as_of_date,opp_objid,opp_name,s_opp_name,bus_objid,bus_name,s_bus_name) AS
select table_opp_analysis.objid, table_opp_analysis.as_of_date,
 table_opportunity.objid, table_opportunity.name, table_opportunity.S_name,
 table_bus_org.objid, table_bus_org.name, table_bus_org.S_name
 from table_opp_analysis, table_opportunity, table_bus_org
 where table_opportunity.objid = table_opp_analysis.analysis2opportunity
 AND table_bus_org.objid (+) = table_opp_analysis.analysis2bus_org
 ;
COMMENT ON TABLE sa.table_oppanly_v IS 'Used by forms Opportunity Competitive Assessment (9599) and Opportunity (13000)';
COMMENT ON COLUMN sa.table_oppanly_v.objid IS 'Unique record ID';
COMMENT ON COLUMN sa.table_oppanly_v.as_of_date IS 'As of date of the analysis';
COMMENT ON COLUMN sa.table_oppanly_v.opp_objid IS 'Opportunity record number';
COMMENT ON COLUMN sa.table_oppanly_v.opp_name IS 'Name of the Opp';
COMMENT ON COLUMN sa.table_oppanly_v.bus_objid IS 'Competitor record number';
COMMENT ON COLUMN sa.table_oppanly_v.bus_name IS 'Competitor name';