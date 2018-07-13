CREATE OR REPLACE FORCE VIEW sa.table_sfa_frcst_v (objid,user_objid,acct_objid,currency_objid,terr_objid,opp_objid,"ID","NAME",close_date,product_family,product_line,amount,probability,comments,status,terr_name,s_terr_name,terr_node_key,opp_name,s_opp_name,opp_id,s_opp_id,currency_name,s_currency_name,owner_name,s_owner_name,acct_name,s_acct_name,sub_scale) AS
select table_frcst_itm.objid, table_user.objid,
 table_bus_org.objid, table_currency.objid,
 table_territory.objid, table_opportunity.objid,
 table_frcst_itm.id_number, table_frcst_itm.name,
 table_frcst_itm.close_date, table_frcst_itm.family,
 table_frcst_itm.line, table_frcst_itm.amount,
 table_frcst_itm.probability, table_frcst_itm.comments,
 table_frcst_itm.status, table_territory.name, table_territory.S_name,
 table_territory.node_key, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.id, table_opportunity.S_id, table_currency.name, table_currency.S_name,
 table_user.login_name, table_user.S_login_name, table_bus_org.name, table_bus_org.S_name,
 table_currency.sub_scale
 from table_frcst_itm, table_user, table_bus_org,
  table_currency, table_territory, table_opportunity
 where table_territory.objid = table_frcst_itm.frcst_itm2territory
 AND table_bus_org.objid (+) = table_frcst_itm.item2bus_org
 AND table_user.objid = table_frcst_itm.originator2user
 AND table_currency.objid = table_frcst_itm.frcst_itm2currency
 AND table_opportunity.objid (+) = table_frcst_itm.item2opportunity
 ;
COMMENT ON TABLE sa.table_sfa_frcst_v IS 'Used by forms Sales Console (12000) and Opportunity Mgr (13000)';
COMMENT ON COLUMN sa.table_sfa_frcst_v.objid IS 'Forecast item internal record number';
COMMENT ON COLUMN sa.table_sfa_frcst_v.user_objid IS 'User owner internal record number';
COMMENT ON COLUMN sa.table_sfa_frcst_v.acct_objid IS 'Account internal record number';
COMMENT ON COLUMN sa.table_sfa_frcst_v.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_sfa_frcst_v.terr_objid IS 'Territory internal record number';
COMMENT ON COLUMN sa.table_sfa_frcst_v.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_frcst_v."ID" IS 'Application-controlled ID number of the forcast item';
COMMENT ON COLUMN sa.table_sfa_frcst_v."NAME" IS 'Name of the forecast item';
COMMENT ON COLUMN sa.table_sfa_frcst_v.close_date IS 'Close date of the forecast item';
COMMENT ON COLUMN sa.table_sfa_frcst_v.product_family IS 'Marketing product family the part belongs to';
COMMENT ON COLUMN sa.table_sfa_frcst_v.product_line IS 'Product line forecasted';
COMMENT ON COLUMN sa.table_sfa_frcst_v.amount IS 'Currency amount forecasted';
COMMENT ON COLUMN sa.table_sfa_frcst_v.probability IS 'Probability that the forecasted amount will close';
COMMENT ON COLUMN sa.table_sfa_frcst_v.comments IS 'Comments about of the forecast item';
COMMENT ON COLUMN sa.table_sfa_frcst_v.status IS 'Status of the forecast item';
COMMENT ON COLUMN sa.table_sfa_frcst_v.terr_name IS 'Name of the territory';
COMMENT ON COLUMN sa.table_sfa_frcst_v.terr_node_key IS 'Node Key of the territory';
COMMENT ON COLUMN sa.table_sfa_frcst_v.opp_name IS 'Name of the related opportunity';
COMMENT ON COLUMN sa.table_sfa_frcst_v.opp_id IS 'System generated D of the opportunity';
COMMENT ON COLUMN sa.table_sfa_frcst_v.currency_name IS 'Name of the currency';
COMMENT ON COLUMN sa.table_sfa_frcst_v.owner_name IS 'Login name of the user';
COMMENT ON COLUMN sa.table_sfa_frcst_v.acct_name IS 'Name of the forecasted account';
COMMENT ON COLUMN sa.table_sfa_frcst_v.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';