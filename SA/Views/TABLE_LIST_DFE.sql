CREATE OR REPLACE FORCE VIEW sa.table_list_dfe (case_objid,elm_objid,work_order,description,app_time) AS
select table_disptchfe.disptchfe2case, table_disptchfe.objid,
 table_disptchfe.work_order, table_disptchfe.description,
 table_disptchfe.appointment
 from table_disptchfe
 where table_disptchfe.disptchfe2case IS NOT NULL
 ;
COMMENT ON TABLE sa.table_list_dfe IS 'Relation to case created. Used by form Select Dispatches (451)';
COMMENT ON COLUMN sa.table_list_dfe.case_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_list_dfe.elm_objid IS 'Disptchfe internal record number';
COMMENT ON COLUMN sa.table_list_dfe.work_order IS 'Work order number entered by the user';
COMMENT ON COLUMN sa.table_list_dfe.description IS 'Task description';
COMMENT ON COLUMN sa.table_list_dfe.app_time IS 'Proposed date/time of scheduled appointment or commitment';