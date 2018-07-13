CREATE OR REPLACE FORCE VIEW sa.table_case2wip_sub (case_id,sub_id,wip_id,"CONDITION",title,s_title) AS
select table_subcase.subcase2case, table_subcase.objid,
 table_subcase.subc_wip2wipbin, table_condition.condition,
 table_condition.title, table_condition.S_title
 from table_subcase, table_condition
 where table_subcase.subc_wip2wipbin IS NOT NULL
 AND table_condition.objid = table_subcase.subc_state2condition
 AND table_subcase.subcase2case IS NOT NULL
 ;
COMMENT ON TABLE sa.table_case2wip_sub IS 'Information needed to display a subcase in a WIPbin';
COMMENT ON COLUMN sa.table_case2wip_sub.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2wip_sub.sub_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_case2wip_sub.wip_id IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_case2wip_sub."CONDITION" IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_case2wip_sub.title IS 'Title of condition';