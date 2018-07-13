CREATE OR REPLACE FORCE VIEW sa.table_sfa_target (objid,"ID","NAME",s_name,start_date,end_date,product_family,product_line,amount,comments,terr_objid,terr_name,s_terr_name,terr_node_key,curr_objid,currency_name,s_currency_name,currency_symbol,owner_objid,owner_name,s_owner_name,terr_terr_id,acct_name,s_acct_name,acct_objid,status,s_status,status_objid,sub_scale) AS
select table_frcst_target.objid, table_frcst_target.id_number,
 table_frcst_target.name, table_frcst_target.S_name, table_frcst_target.start_date,
 table_frcst_target.end_date, table_frcst_target.family,
 table_frcst_target.line, table_frcst_target.amount,
 table_frcst_target.comments, table_territory.objid,
 table_territory.name, table_territory.S_name, table_territory.node_key,
 table_currency.objid, table_currency.name, table_currency.S_name,
 table_currency.symbol, table_user.objid,
 table_user.login_name, table_user.S_login_name, table_territory.terr_id,
 table_bus_org.name, table_bus_org.S_name, table_bus_org.objid,
 table_gbst_status.title, table_gbst_status.S_title, table_gbst_status.objid,
 table_currency.sub_scale
 from table_gbst_elm table_gbst_status, table_frcst_target, table_territory, table_currency,
  table_user, table_bus_org
 where table_bus_org.objid (+) = table_frcst_target.frcst2bus_org
 AND table_currency.objid = table_frcst_target.frcst_target2currency
 AND table_gbst_status.objid (+) = table_frcst_target.frcst_stat2gbst_elm
 AND table_territory.objid = table_frcst_target.frcst2territory
 AND table_user.objid = table_frcst_target.frcst_target2user
 ;
COMMENT ON TABLE sa.table_sfa_target IS 'Displays Forecast target Information. Used by form Console--Sales(12000), Generic LookUp-non-modal (20000)';
COMMENT ON COLUMN sa.table_sfa_target.objid IS 'Forecast target internal record number';
COMMENT ON COLUMN sa.table_sfa_target."ID" IS 'Forecast target Id';
COMMENT ON COLUMN sa.table_sfa_target."NAME" IS 'Name assigned to the forecast target';
COMMENT ON COLUMN sa.table_sfa_target.start_date IS 'Beginning date of the period for the target';
COMMENT ON COLUMN sa.table_sfa_target.end_date IS 'Last date of the period for the target';
COMMENT ON COLUMN sa.table_sfa_target.product_family IS 'Marketing product family the part belongs to. This is from a user-defined popup with default name FAMILY and level name lev1';
COMMENT ON COLUMN sa.table_sfa_target.product_line IS 'If target is assigned to a product, the marketing product line, within family, of the part; new user-defined pop up with default name FAMILY and level name Hardware Line';
COMMENT ON COLUMN sa.table_sfa_target.amount IS 'Target currency amount';
COMMENT ON COLUMN sa.table_sfa_target.comments IS 'Comments about the forecast target';
COMMENT ON COLUMN sa.table_sfa_target.terr_objid IS 'Territory internal record number';
COMMENT ON COLUMN sa.table_sfa_target.terr_name IS 'Name of the sales territory';
COMMENT ON COLUMN sa.table_sfa_target.terr_node_key IS 'Node Key of the territory';
COMMENT ON COLUMN sa.table_sfa_target.curr_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_sfa_target.currency_name IS 'Name of the currency';
COMMENT ON COLUMN sa.table_sfa_target.currency_symbol IS 'Symbol of the currency';
COMMENT ON COLUMN sa.table_sfa_target.owner_objid IS 'User owner internal record number';
COMMENT ON COLUMN sa.table_sfa_target.owner_name IS 'Name of the user';
COMMENT ON COLUMN sa.table_sfa_target.terr_terr_id IS 'User-specified ID number of the territory';
COMMENT ON COLUMN sa.table_sfa_target.acct_name IS 'If the forecast target is account based, the account name';
COMMENT ON COLUMN sa.table_sfa_target.acct_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_sfa_target.status IS 'Status of forecast target';
COMMENT ON COLUMN sa.table_sfa_target.status_objid IS 'Status gbst_elm internal record number';
COMMENT ON COLUMN sa.table_sfa_target.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';