CREATE OR REPLACE FORCE VIEW sa.table_diag_hint_inst (objid,logic_id,logic_value,diag_hint_id) AS
select table_hint_inst.objid, table_hint_inst.hint_logic2prog_logic,
 table_hint_inst.logic_value, table_hint_inst.hint_info2diag_hint
 from table_hint_inst
 where table_hint_inst.hint_logic2prog_logic IS NOT NULL
 AND table_hint_inst.hint_info2diag_hint IS NOT NULL
 ;
COMMENT ON TABLE sa.table_diag_hint_inst IS 'Diagnostic hint instance for the particular path';
COMMENT ON COLUMN sa.table_diag_hint_inst.objid IS 'Hint inst internal record number';
COMMENT ON COLUMN sa.table_diag_hint_inst.logic_id IS 'Prog logic internal record number';
COMMENT ON COLUMN sa.table_diag_hint_inst.logic_value IS 'Encoding of True/False/Possible value setting';
COMMENT ON COLUMN sa.table_diag_hint_inst.diag_hint_id IS 'Diagnostic hint internal record number';