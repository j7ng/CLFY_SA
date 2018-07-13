CREATE OR REPLACE FORCE VIEW sa.table_sfa_opp_v (objid,bus_objid,opp_objid,owner_objid,stage_objid,curr_objid,role_name,bus_name,s_bus_name,"ACTIVE",role_type,comments,focus_type,products,close_date,amount,drop_date,drop_reason,opp_name,s_opp_name,opp_id,s_opp_id,frcst_cls_dt,frcst_cls_amt,frcst_cls_prb,stage,s_stage,"OWNER",s_owner,currency,s_currency,sub_scale) AS
select table_bus_opp_role.objid, table_bus_org.objid,
 table_opportunity.objid, table_user.objid,
 table_cycle_stage.objid, table_currency.objid,
 table_bus_opp_role.role_name, table_bus_org.name, table_bus_org.S_name,
 table_bus_opp_role.active, table_bus_opp_role.role_type,
 table_bus_opp_role.comments, table_bus_opp_role.focus_type,
 table_bus_opp_role.products, table_bus_opp_role.close_date,
 table_bus_opp_role.amount, table_bus_opp_role.drop_date,
 table_bus_opp_role.drop_reason, table_opportunity.name, table_opportunity.S_name,
 table_opportunity.id, table_opportunity.S_id, table_opportunity.frcst_cls_dt,
 table_opportunity.frcst_cls_amount, table_opportunity.frcst_cls_prb,
 table_cycle_stage.name, table_cycle_stage.S_name, table_user.login_name, table_user.S_login_name,
 table_currency.name, table_currency.S_name, table_currency.sub_scale
 from table_bus_opp_role, table_bus_org, table_opportunity,
  table_user, table_cycle_stage, table_currency
 where table_opportunity.objid = table_bus_opp_role.opp_role2opportunity
 AND table_bus_org.objid = table_bus_opp_role.bus_role2bus_org
 AND table_currency.objid = table_opportunity.opp2currency
 AND table_cycle_stage.objid = table_opportunity.opp2cycle_stage
 AND table_user.objid = table_opportunity.opp_owner2user
 ;
COMMENT ON TABLE sa.table_sfa_opp_v IS 'Displays account information. Used on forms Console-Sales (12000) and Opportunity Mgr (13000)';
COMMENT ON COLUMN sa.table_sfa_opp_v.objid IS 'Bus_opp_role internal record nubmer';
COMMENT ON COLUMN sa.table_sfa_opp_v.bus_objid IS 'Bus_org internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_v.opp_objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_v.owner_objid IS ' Opportunity owner internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_v.stage_objid IS 'Opportunity stage internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_v.curr_objid IS 'Opportunity currency internal record number';
COMMENT ON COLUMN sa.table_sfa_opp_v.role_name IS 'Name of the business organization s  role for the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.bus_name IS 'Business organization s name';
COMMENT ON COLUMN sa.table_sfa_opp_v."ACTIVE" IS 'Indicates whether the role is active; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_sfa_opp_v.role_type IS 'Type of role for the opportunity; i.e., 0=partner, 1=competitor';
COMMENT ON COLUMN sa.table_sfa_opp_v.comments IS 'Comments about the role';
COMMENT ON COLUMN sa.table_sfa_opp_v.focus_type IS 'Object type ID of the role-player; i.e., 173=an business organizations s role, 5000=an opportunity s role';
COMMENT ON COLUMN sa.table_sfa_opp_v.products IS 'Products this bus_org is trying to sell in this opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.close_date IS 'Attempted close date for the opportunity by the bus_org';
COMMENT ON COLUMN sa.table_sfa_opp_v.amount IS 'Currenty amount the bus_org is trying to close in this opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.drop_date IS 'Date on which the bus_org dropped out of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.drop_reason IS 'Reason the bus_org left the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.opp_name IS 'Name given to the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.opp_id IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_sfa_opp_v.frcst_cls_dt IS 'Forecasted close date of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.frcst_cls_amt IS 'Forecasted close amount of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.frcst_cls_prb IS 'Forecasted close probability of the opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v.stage IS 'Status/Stage of opportunity';
COMMENT ON COLUMN sa.table_sfa_opp_v."OWNER" IS 'User login name of the opportunity owner';
COMMENT ON COLUMN sa.table_sfa_opp_v.currency IS 'Name of the currency the opporutnity is denominated in';
COMMENT ON COLUMN sa.table_sfa_opp_v.sub_scale IS 'Gives the decimal scale of the sub unit in which the currency will be calculated: e.g., US dollar has a sub unit (cent) whose scale=2; Italian lira has no sub unit, its sub unit scale=0';