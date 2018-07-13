CREATE OR REPLACE FORCE VIEW sa.table_case2rip_dfe (case_id,dfe_id,rip_id) AS
select table_disptchfe.disptchfe2case, table_disptchfe.objid,
 table_ripbin.objid
 from table_disptchfe, table_ripbin
 where table_disptchfe.disptchfe2case IS NOT NULL
 ;
COMMENT ON TABLE sa.table_case2rip_dfe IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_case2rip_dfe.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2rip_dfe.dfe_id IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_case2rip_dfe.rip_id IS 'Ripbin internal record number';