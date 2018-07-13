CREATE OR REPLACE FORCE VIEW sa.table_rpt_param_view (user_id,report_id,param_objid,param_title) AS
select table_rpt_param.param2user, table_rpt_param.param2rpt,
 table_rpt_param.objid, table_rpt_param.title
 from table_rpt_param
 where table_rpt_param.param2rpt IS NOT NULL
 AND table_rpt_param.param2user IS NOT NULL
 ;
COMMENT ON TABLE sa.table_rpt_param_view IS 'Users report parameters. Used by form Report Selection (202)';
COMMENT ON COLUMN sa.table_rpt_param_view.user_id IS 'User internal record number';
COMMENT ON COLUMN sa.table_rpt_param_view.report_id IS 'Rpt internal record number';
COMMENT ON COLUMN sa.table_rpt_param_view.param_objid IS 'Rpt_param internal record number';
COMMENT ON COLUMN sa.table_rpt_param_view.param_title IS 'Title of the option set';