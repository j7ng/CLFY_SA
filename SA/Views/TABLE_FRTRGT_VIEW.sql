CREATE OR REPLACE FORCE VIEW sa.table_frtrgt_view (objid,"ID","NAME",s_name,start_date,end_date,product_family,product_line,amount,comments,terr_objid,terr_name,s_terr_name,terr_nodekey,curr_objid,currency_name,s_currency_name,currency_symbol,currency_rate,owner_objid,owner_name,s_owner_name,terr_terr_id,sub_scale) AS
select table_frcst_target.objid, table_frcst_target.id_number,
 table_frcst_target.name, table_frcst_target.S_name, table_frcst_target.start_date,
 table_frcst_target.end_date, table_frcst_target.family,
 table_frcst_target.line, table_frcst_target.amount,
 table_frcst_target.comments, table_territory.objid,
 table_territory.name, table_territory.S_name, table_territory.node_key,
 table_currency.objid, table_currency.name, table_currency.S_name,
 table_currency.symbol, table_currency.conv_rate,
 table_user.objid, table_user.login_name, table_user.S_login_name,
 table_territory.terr_id, table_currency.sub_scale
 from table_frcst_target, table_territory, table_currency,
  table_user
 where table_territory.objid = table_frcst_target.frcst2territory
 AND table_user.objid = table_frcst_target.frcst_target2user
 AND table_currency.objid = table_frcst_target.frcst_target2currency
 ;
COMMENT ON TABLE sa.table_frtrgt_view IS 'Used to display Forecast target Information from the List and Edit Forecast Target form (9690)';
COMMENT ON COLUMN sa.table_frtrgt_view.objid IS 'Forecast target internal record number';
COMMENT ON COLUMN sa.table_frtrgt_view."ID" IS 'Forecast target Id';
COMMENT ON COLUMN sa.table_frtrgt_view."NAME" IS 'Name of the forecast target';
COMMENT ON COLUMN sa.table_frtrgt_view.start_date IS 'Start date of the forecast target';
COMMENT ON COLUMN sa.table_frtrgt_view.end_date IS 'End date of the forecast target';
COMMENT ON COLUMN sa.table_frtrgt_view.product_family IS 'Product family of the forecast target';
COMMENT ON COLUMN sa.table_frtrgt_view.product_line IS 'Product line of the forecast target';
COMMENT ON COLUMN sa.table_frtrgt_view.amount IS 'Amount of the forecast target';
COMMENT ON COLUMN sa.table_frtrgt_view.comments IS 'Comments of the forecast target';
COMMENT ON COLUMN sa.table_frtrgt_view.terr_objid IS 'Territory internal record number';
COMMENT ON COLUMN sa.table_frtrgt_view.terr_name IS 'Name of the territory';
COMMENT ON COLUMN sa.table_frtrgt_view.terr_nodekey IS 'Node Key of the territory';
COMMENT ON COLUMN sa.table_frtrgt_view.curr_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_frtrgt_view.currency_name IS 'Name of the currency';
COMMENT ON COLUMN sa.table_frtrgt_view.currency_symbol IS 'symbol of the currency';
COMMENT ON COLUMN sa.table_frtrgt_view.currency_rate IS 'Rate of the currency to base currency';
COMMENT ON COLUMN sa.table_frtrgt_view.owner_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_frtrgt_view.owner_name IS 'Name of the user';
COMMENT ON COLUMN sa.table_frtrgt_view.terr_terr_id IS 'User-specified ID number of the territory';
COMMENT ON COLUMN sa.table_frtrgt_view.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';