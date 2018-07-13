CREATE OR REPLACE FORCE VIEW sa.table_asaf_user_site (asaf_objid,user_objid,site_objid) AS
select table_asaf_result.objid, table_asaf_result.asaf_result2user,
 table_asaf_result.asaf_result2site
 from table_asaf_result
 where table_asaf_result.asaf_result2user IS NOT NULL
 AND table_asaf_result.asaf_result2site IS NOT NULL
 ;
COMMENT ON TABLE sa.table_asaf_user_site IS 'Used for service interruptions report data. Reserved; option';
COMMENT ON COLUMN sa.table_asaf_user_site.asaf_objid IS 'Internal record number. Reserved; option';
COMMENT ON COLUMN sa.table_asaf_user_site.user_objid IS 'Internal record number. Reserved; option';
COMMENT ON COLUMN sa.table_asaf_user_site.site_objid IS 'Internal record number. Reserved; option';