CREATE OR REPLACE FORCE VIEW sa.table_oppempl_view (objid,terr_objid,stage_objid,empl_objid,user_objid,"ID",s_id,"NAME",s_name,amount,probability,close_date,stage,s_stage,first_name,s_first_name,last_name,s_last_name) AS
select table_opportunity.objid, table_opportunity.opp2territory,
 table_cycle_stage.objid, table_employee.objid,
 table_user.objid, table_opportunity.id, table_opportunity.S_id,
 table_opportunity.name, table_opportunity.S_name, table_opportunity.frcst_cls_amount,
 table_opportunity.frcst_cls_prb, table_opportunity.frcst_cls_dt,
 table_cycle_stage.name, table_cycle_stage.S_name, table_employee.first_name, table_employee.S_first_name,
 table_employee.last_name, table_employee.S_last_name
 from table_opportunity, table_cycle_stage, table_employee,
  table_user
 where table_cycle_stage.objid = table_opportunity.opp2cycle_stage
 AND table_user.objid = table_opportunity.opp_owner2user
 AND table_opportunity.opp2territory IS NOT NULL
 AND table_user.objid = table_employee.employee2user
 ;
COMMENT ON TABLE sa.table_oppempl_view IS 'Used internally to select Opportunities';
COMMENT ON COLUMN sa.table_oppempl_view.objid IS 'Opportunity internal record number';
COMMENT ON COLUMN sa.table_oppempl_view.terr_objid IS 'Territory internal record number';
COMMENT ON COLUMN sa.table_oppempl_view.stage_objid IS 'Cycle state internal record number';
COMMENT ON COLUMN sa.table_oppempl_view.empl_objid IS 'Employee internal record number';
COMMENT ON COLUMN sa.table_oppempl_view.user_objid IS 'User internal record number';
COMMENT ON COLUMN sa.table_oppempl_view."ID" IS 'Opportunity ID number';
COMMENT ON COLUMN sa.table_oppempl_view."NAME" IS 'Opportunity Name';
COMMENT ON COLUMN sa.table_oppempl_view.amount IS 'Forecasted close amount';
COMMENT ON COLUMN sa.table_oppempl_view.probability IS 'Forecasted close probability';
COMMENT ON COLUMN sa.table_oppempl_view.close_date IS 'Forecasted close date';
COMMENT ON COLUMN sa.table_oppempl_view.stage IS 'Cycle stage name';
COMMENT ON COLUMN sa.table_oppempl_view.first_name IS 'Employee first name';
COMMENT ON COLUMN sa.table_oppempl_view.last_name IS 'Employee last name';