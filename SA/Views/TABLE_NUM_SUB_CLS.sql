CREATE OR REPLACE FORCE VIEW sa.table_num_sub_cls (sub_id,case_id,"STATE",behavior,sub_type) AS
select table_subcase.objid, table_subcase.subcase2case,
 table_condition.condition, table_subcase.behavior,
 table_subcase.sub_type
 from table_subcase, table_condition
 where table_subcase.subcase2case IS NOT NULL
 AND table_condition.objid = table_subcase.subc_state2condition
 ;
COMMENT ON TABLE sa.table_num_sub_cls IS 'Contains basic subcase information';
COMMENT ON COLUMN sa.table_num_sub_cls.sub_id IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_num_sub_cls.case_id IS 'Case internal record number';
COMMENT ON COLUMN sa.table_num_sub_cls."STATE" IS 'Code number for condition type';
COMMENT ON COLUMN sa.table_num_sub_cls.behavior IS 'Internal field indicating the behavior of the subcase type; i.e., 1=normal, 2=administrative subcase';
COMMENT ON COLUMN sa.table_num_sub_cls.sub_type IS 'Subcase type -general or administrative';