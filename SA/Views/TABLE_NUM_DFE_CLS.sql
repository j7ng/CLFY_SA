CREATE OR REPLACE FORCE VIEW sa.table_num_dfe_cls (case_id,"STATE") AS
select table_case.objid, table_condition.condition
 from table_case, table_condition, table_disptchfe
 where table_condition.objid = table_case.case_state2condition
 AND table_case.objid = table_disptchfe.disptchfe2case
 ;
COMMENT ON TABLE sa.table_num_dfe_cls IS 'Used in the API subsytem';
COMMENT ON COLUMN sa.table_num_dfe_cls.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_num_dfe_cls."STATE" IS 'Code number for condition type';