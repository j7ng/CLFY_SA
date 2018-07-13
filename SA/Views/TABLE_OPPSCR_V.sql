CREATE OR REPLACE FORCE VIEW sa.table_oppscr_v (objid,role_name,focus_type,"ACTIVE",as_of_date,score,opp_objid,opp_name,s_opp_name,scr_objid,scr_name,s_scr_name) AS
select table_opp_scr_role.objid, table_opp_scr_role.role_name,
 table_opp_scr_role.focus_type, table_opp_scr_role.active,
 table_opp_scr_role.as_of_date, table_opp_scr_role.score,
 table_opportunity.objid, table_opportunity.name, table_opportunity.S_name,
 table_call_script.objid, table_call_script.name, table_call_script.S_name
 from table_opp_scr_role, table_opportunity, table_call_script
 where table_call_script.objid = table_opp_scr_role.scr_role2call_script
 AND table_opportunity.objid = table_opp_scr_role.scr_role2opportunity
 ;
COMMENT ON TABLE sa.table_oppscr_v IS 'Used to display Call Scripts answered for an opportunity (9601)';
COMMENT ON COLUMN sa.table_oppscr_v.objid IS 'Opp_scr_role internal record number';
COMMENT ON COLUMN sa.table_oppscr_v.role_name IS 'Name of the role';
COMMENT ON COLUMN sa.table_oppscr_v.focus_type IS 'Object type ID of the role-player; i.e., 5081=a call script s role, 5000=an opportunity s role';
COMMENT ON COLUMN sa.table_oppscr_v."ACTIVE" IS 'Indicates whether the role is currently being used; i.e., 0=inactive, 1=active';
COMMENT ON COLUMN sa.table_oppscr_v.as_of_date IS 'As of date of the responses';
COMMENT ON COLUMN sa.table_oppscr_v.score IS 'Numeric score of the responses';
COMMENT ON COLUMN sa.table_oppscr_v.opp_objid IS 'Opportunity record number';
COMMENT ON COLUMN sa.table_oppscr_v.opp_name IS 'Name of the Opp';
COMMENT ON COLUMN sa.table_oppscr_v.scr_objid IS 'Script record number';
COMMENT ON COLUMN sa.table_oppscr_v.scr_name IS 'Script name';