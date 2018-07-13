CREATE OR REPLACE FORCE VIEW sa.table_list_sub_dfe (subcase_objid,elm_objid,work_order,description,app_time) AS
select table_disptchfe.disptchfe2subcase, table_disptchfe.objid,
 table_disptchfe.work_order, table_disptchfe.description,
 table_disptchfe.appointment
 from table_disptchfe
 where table_disptchfe.disptchfe2subcase IS NOT NULL
 ;
COMMENT ON TABLE sa.table_list_sub_dfe IS 'Used to display engineer dispatches for a subcase';
COMMENT ON COLUMN sa.table_list_sub_dfe.subcase_objid IS 'Subcase internal record number';
COMMENT ON COLUMN sa.table_list_sub_dfe.elm_objid IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_list_sub_dfe.work_order IS 'Work order number entered by the user';
COMMENT ON COLUMN sa.table_list_sub_dfe.description IS 'Task description';
COMMENT ON COLUMN sa.table_list_sub_dfe.app_time IS 'Proposed date/time of scheduled appointment or commitment';