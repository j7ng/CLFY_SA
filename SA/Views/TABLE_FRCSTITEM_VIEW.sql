CREATE OR REPLACE FORCE VIEW sa.table_frcstitem_view (objid,"ID","NAME",close_date,product_family,product_line,amount,probability,comments,status,terr_objid,terr_name,s_terr_name,terr_nodekey,opp_objid,opp_name,s_opp_name,opp_id,s_opp_id,currency_objid,currency_name,s_currency_name,currency_rate,owner_objid,owner_name,s_owner_name,terr_terr_id,sub_scale) AS
select table_frcst_itm.objid, table_frcst_itm.id_number,
 table_frcst_itm.name, table_frcst_itm.close_date,
 table_frcst_itm.family, table_frcst_itm.line,
 table_frcst_itm.amount, table_frcst_itm.probability,
 table_frcst_itm.comments, table_frcst_itm.status,
 table_territory.objid, table_territory.name, table_territory.S_name,
 table_territory.node_key, table_opportunity.objid,
 table_opportunity.name, table_opportunity.S_name, table_opportunity.id, table_opportunity.S_id,
 table_currency.objid, table_currency.name, table_currency.S_name,
 table_currency.conv_rate, table_user.objid,
 table_user.login_name, table_user.S_login_name, table_territory.terr_id,
 table_currency.sub_scale
 from table_frcst_itm, table_territory, table_opportunity,
  table_currency, table_user
 where table_territory.objid = table_frcst_itm.frcst_itm2territory
 AND table_opportunity.objid (+) = table_frcst_itm.item2opportunity
 AND table_user.objid = table_frcst_itm.originator2user
 AND table_currency.objid = table_frcst_itm.frcst_itm2currency
 ;
COMMENT ON TABLE sa.table_frcstitem_view IS 'Used by forms Forecast Items (9692) and Account (11650)';
COMMENT ON COLUMN sa.table_frcstitem_view.objid IS 'Forecast item internal record number';
COMMENT ON COLUMN sa.table_frcstitem_view."ID" IS 'Forecast item ID';
COMMENT ON COLUMN sa.table_frcstitem_view."NAME" IS 'Name of the forecast target';
COMMENT ON COLUMN sa.table_frcstitem_view.close_date IS 'Close date of the forecast target';
COMMENT ON COLUMN sa.table_frcstitem_view.product_family IS 'Product family of the forecast item';
COMMENT ON COLUMN sa.table_frcstitem_view.product_line IS 'Product line of the forecast item';
COMMENT ON COLUMN sa.table_frcstitem_view.amount IS 'Amount of the forecast item';
COMMENT ON COLUMN sa.table_frcstitem_view.probability IS 'Probability of the forecast item';
COMMENT ON COLUMN sa.table_frcstitem_view.comments IS 'Comments of the forecast item';
COMMENT ON COLUMN sa.table_frcstitem_view.status IS 'Status of the forecast item';
COMMENT ON COLUMN sa.table_frcstitem_view.terr_objid IS 'Territory internal record number';
COMMENT ON COLUMN sa.table_frcstitem_view.terr_name IS 'Name of the territory';
COMMENT ON COLUMN sa.table_frcstitem_view.terr_nodekey IS 'Node Key of the territory';
COMMENT ON COLUMN sa.table_frcstitem_view.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_frcstitem_view.opp_name IS 'Name of the opportunity';
COMMENT ON COLUMN sa.table_frcstitem_view.opp_id IS 'Id of the opportunity';
COMMENT ON COLUMN sa.table_frcstitem_view.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_frcstitem_view.currency_name IS 'Name of the currency';
COMMENT ON COLUMN sa.table_frcstitem_view.currency_rate IS 'Ratio of the currency';
COMMENT ON COLUMN sa.table_frcstitem_view.owner_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_frcstitem_view.owner_name IS 'Name of the user';
COMMENT ON COLUMN sa.table_frcstitem_view.terr_terr_id IS 'User-specified ID number of the territory';
COMMENT ON COLUMN sa.table_frcstitem_view.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';