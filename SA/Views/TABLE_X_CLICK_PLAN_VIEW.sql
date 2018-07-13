CREATE OR REPLACE FORCE VIEW sa.table_x_click_plan_view (click_plan_objid,x_plan_id,x_click_local,x_click_ld,x_click_rl,x_click_rld,x_grace_period,x_is_default,x_status,x_dealer_id,x_dealer_name,s_x_dealer_name,x_carrier_id,x_mkt_submkt_name) AS
select table_x_click_plan.objid, table_x_click_plan.x_plan_id,
 table_x_click_plan.x_click_local, table_x_click_plan.x_click_LD,
 table_x_click_plan.x_click_RL, table_x_click_plan.x_click_RLD,
 table_x_click_plan.x_grace_period, table_x_click_plan.x_is_default,
 table_x_click_plan.x_status, table_site.site_id,
 table_site.name, table_site.S_name, table_x_carrier.x_carrier_id,
 table_x_carrier.x_mkt_submkt_name
 from table_x_click_plan, table_site, table_x_carrier
 where table_site.objid = table_x_click_plan.click_plan2dealer
 AND table_x_carrier.objid = table_x_click_plan.click_plan2carrier
 ;
COMMENT ON TABLE sa.table_x_click_plan_view IS 'Discarded; Use x_clickplan_view ';
COMMENT ON COLUMN sa.table_x_click_plan_view.click_plan_objid IS 'Click Plan internal record number';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_plan_id IS 'Click  ID number';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_click_local IS 'Number of Clicks for Local Calls';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_click_ld IS 'Number of Clicks for Long Distance Calls';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_click_rl IS 'Number of Clicks for Roaming Local Calls';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_click_rld IS 'Number of Clicks for Roaming Long Distance Calls';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_grace_period IS 'Grace Period Available';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_is_default IS 'IS Default';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_status IS 'Status of the Click Plan';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_dealer_id IS 'Dealer Id';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_dealer_name IS 'Dealer Name';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_carrier_id IS 'Carrier Id';
COMMENT ON COLUMN sa.table_x_click_plan_view.x_mkt_submkt_name IS 'Carrier Name';