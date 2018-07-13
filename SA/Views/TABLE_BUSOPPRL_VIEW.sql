CREATE OR REPLACE FORCE VIEW sa.table_busopprl_view (objid,role_name,"ID",s_id,opp_name,s_opp_name,opp_prob,opp_cl_dt,"ACCOUNT",s_account,account_id,s_account_id,opp_objid,acct_objid) AS
select table_bus_opp_role.objid, table_bus_opp_role.role_name,
 table_opportunity.id, table_opportunity.S_id, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.frcst_cls_prb, table_opportunity.purch_date,
 table_bus_org.name, table_bus_org.S_name, table_bus_org.org_id, table_bus_org.S_org_id,
 table_opportunity.objid, table_bus_org.objid
 from table_bus_opp_role, table_opportunity, table_bus_org
 where table_opportunity.objid = table_bus_opp_role.opp_role2opportunity
 AND table_bus_org.objid = table_bus_opp_role.bus_role2bus_org
 ;
COMMENT ON TABLE sa.table_busopprl_view IS 'Opportunity roles for Bus Org. Used by forms Account Team (8504), Quick View (8507), Account Edit (8521), Account Detail (8522), Opportunities (8526)';
COMMENT ON COLUMN sa.table_busopprl_view.objid IS 'bus_opp_role  internal record number';
COMMENT ON COLUMN sa.table_busopprl_view.role_name IS 'The name of the role';
COMMENT ON COLUMN sa.table_busopprl_view."ID" IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_busopprl_view.opp_name IS 'Opportunity name';
COMMENT ON COLUMN sa.table_busopprl_view.opp_prob IS 'Forecasted close probability';
COMMENT ON COLUMN sa.table_busopprl_view.opp_cl_dt IS 'When the opportunity is expected to close';
COMMENT ON COLUMN sa.table_busopprl_view."ACCOUNT" IS 'Account name';
COMMENT ON COLUMN sa.table_busopprl_view.account_id IS 'Account ID number';
COMMENT ON COLUMN sa.table_busopprl_view.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_busopprl_view.acct_objid IS 'Account internal record number';