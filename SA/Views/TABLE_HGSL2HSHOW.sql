CREATE OR REPLACE FORCE VIEW sa.table_hgsl2hshow (objid,show_objid) AS
select table_hgbst_lst.objid, table_hgbst_lst.hgbst_lst2hgbst_show
 from table_hgbst_lst
 where table_hgbst_lst.hgbst_lst2hgbst_show IS NOT NULL
 ;
COMMENT ON TABLE sa.table_hgsl2hshow IS 'Internal; used for pop up list caching';
COMMENT ON COLUMN sa.table_hgsl2hshow.objid IS 'Hgbst lst internal record number';
COMMENT ON COLUMN sa.table_hgsl2hshow.show_objid IS 'Hgbst show internal record number';