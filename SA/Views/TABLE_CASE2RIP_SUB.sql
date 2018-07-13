CREATE OR REPLACE FORCE VIEW sa.table_case2rip_sub (case_id,sub_id,rip_id) AS
select table_subcase.subcase2case, table_subcase.objid,
 table_subcase.subc_rip2ripbin
 from table_subcase
 where table_subcase.subcase2case IS NOT NULL
 AND table_subcase.subc_rip2ripbin IS NOT NULL
 ;
COMMENT ON TABLE sa.table_case2rip_sub IS 'Reserved; obsolete';
COMMENT ON COLUMN sa.table_case2rip_sub.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_case2rip_sub.sub_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_case2rip_sub.rip_id IS 'Ripbin internal record number';