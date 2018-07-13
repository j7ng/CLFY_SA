CREATE OR REPLACE FORCE VIEW sa.table_case2wip_dfe (case_id,sub_id,wip_id) AS
select table_disptchfe.disptchfe2case, table_disptchfe.objid,
 table_wipbin.objid
 from table_disptchfe, table_wipbin
 where table_disptchfe.disptchfe2case IS NOT NULL
 ;
COMMENT ON TABLE sa.table_case2wip_dfe IS 'Used to join case and dispatch engineer objects';
COMMENT ON COLUMN sa.table_case2wip_dfe.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2wip_dfe.sub_id IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_case2wip_dfe.wip_id IS 'WIPbin internal record number';