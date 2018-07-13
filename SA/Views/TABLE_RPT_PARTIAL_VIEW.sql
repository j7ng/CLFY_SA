CREATE OR REPLACE FORCE VIEW sa.table_rpt_partial_view (rpt_id,title,sqr_param) AS
select table_rpt.objid, table_rpt.title,
 table_rpt.sqr_param
 from table_rpt;
COMMENT ON TABLE sa.table_rpt_partial_view IS 'Used by form Report Selection (202), Report Parameters (203)';
COMMENT ON COLUMN sa.table_rpt_partial_view.rpt_id IS 'Rpt internal record number';
COMMENT ON COLUMN sa.table_rpt_partial_view.title IS 'Title/name of the report';
COMMENT ON COLUMN sa.table_rpt_partial_view.sqr_param IS 'SQR parameter types and values for the report; used if length of parameter string is 255 characters or less';