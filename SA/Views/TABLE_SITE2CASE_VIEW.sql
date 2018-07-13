CREATE OR REPLACE FORCE VIEW sa.table_site2case_view (wip_objid,elm_objid,site_objid) AS
select table_case.case_wip2wipbin, table_case.objid,
 table_case.case_reporter2site
 from table_case
 where table_case.case_wip2wipbin IS NOT NULL
 AND table_case.case_reporter2site IS NOT NULL
 ;
COMMENT ON TABLE sa.table_site2case_view IS 'Used in new find caller workflow of Case window';
COMMENT ON COLUMN sa.table_site2case_view.wip_objid IS 'WIPbin internal record number';
COMMENT ON COLUMN sa.table_site2case_view.elm_objid IS 'Case internal record number';
COMMENT ON COLUMN sa.table_site2case_view.site_objid IS 'Site internal record number';