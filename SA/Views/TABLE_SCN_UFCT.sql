CREATE OR REPLACE FORCE VIEW sa.table_scn_ufct (objid,title,s_title) AS
select table_diag_hint.objid, table_diag_hint.statement, table_diag_hint.S_statement
 from table_diag_hint;
COMMENT ON TABLE sa.table_scn_ufct IS 'View diagnostic hints in the Solve form';
COMMENT ON COLUMN sa.table_scn_ufct.objid IS 'Diagnostic hint object ID number';
COMMENT ON COLUMN sa.table_scn_ufct.title IS 'Actual diagnostic hint or question';