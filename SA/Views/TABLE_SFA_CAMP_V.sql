CREATE OR REPLACE FORCE VIEW sa.table_sfa_camp_v (objid,owner_objid,price_objid,currency_objid,"NAME",s_name,cam_type,status,start_date,end_date,audience,description,products,objective,"COST",revenue_goal,budget_amt,opps_goal,won_goal,currency_name,s_currency_name,owner_name,s_owner_name,price_name,s_price_name,sub_scale) AS
select table_campaign.objid, table_user.objid,
 table_price_prog.objid, table_currency.objid,
 table_campaign.name, table_campaign.S_name, table_campaign.cam_type,
 table_campaign.status, table_campaign.start_date,
 table_campaign.end_date, table_campaign.audience,
 table_campaign.description, table_campaign.products,
 table_campaign.objective, table_campaign.cost,
 table_campaign.revenue_goal, table_campaign.budget_amt,
 table_campaign.opps_goal, table_campaign.won_goal,
 table_currency.name, table_currency.S_name, table_user.login_name, table_user.S_login_name,
 table_price_prog.name, table_price_prog.S_name, table_currency.sub_scale
 from table_campaign, table_user, table_price_prog,
  table_currency
 where table_currency.objid (+) = table_campaign.campaign2currency
 AND table_user.objid = table_campaign.cam_owner2user
 AND table_price_prog.objid (+) = table_campaign.campaign2price_prog
 ;
COMMENT ON TABLE sa.table_sfa_camp_v IS 'Used by forms Sales Console (12000)';
COMMENT ON COLUMN sa.table_sfa_camp_v.objid IS 'Campaign internal record number';
COMMENT ON COLUMN sa.table_sfa_camp_v.owner_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_sfa_camp_v.price_objid IS 'Price_prog internal record number';
COMMENT ON COLUMN sa.table_sfa_camp_v.currency_objid IS 'Currency internal record number';
COMMENT ON COLUMN sa.table_sfa_camp_v."NAME" IS 'Name of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.cam_type IS 'Type of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.status IS 'Status of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.start_date IS 'Starting date of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.end_date IS 'Ending date of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.audience IS 'Target audience of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.description IS 'description of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.products IS 'Product families addressed by the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.objective IS 'What the campaign is intended to achieve';
COMMENT ON COLUMN sa.table_sfa_camp_v."COST" IS 'Amount spent on campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.revenue_goal IS 'Goal in currency of revenue generated from the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.budget_amt IS 'Goal in currency for the cost of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.opps_goal IS 'Goal in number of opportunities generated from the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.won_goal IS 'Goal in number of deals won from the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.currency_name IS 'Currency in which campaign is denominated';
COMMENT ON COLUMN sa.table_sfa_camp_v.owner_name IS 'Login name of the owner of the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.price_name IS 'Price program used for the campaign';
COMMENT ON COLUMN sa.table_sfa_camp_v.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';