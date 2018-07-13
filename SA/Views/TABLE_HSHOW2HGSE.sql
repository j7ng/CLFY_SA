CREATE OR REPLACE FORCE VIEW sa.table_hshow2hgse (show_objid,elm_objid) AS
select table_hgbst_show.objid, table_hgbst_elm.objid
 from mtm_hgbst_elm0_hgbst_show1, table_hgbst_show, table_hgbst_elm
 where table_hgbst_elm.objid = mtm_hgbst_elm0_hgbst_show1.hgbst_elm2hgbst_show
 AND mtm_hgbst_elm0_hgbst_show1.hgbst_show2hgbst_elm = table_hgbst_show.objid 
 ;
COMMENT ON TABLE sa.table_hshow2hgse IS 'Internal; used for pop up list caching';
COMMENT ON COLUMN sa.table_hshow2hgse.show_objid IS 'Hgbst show internal record number';
COMMENT ON COLUMN sa.table_hshow2hgse.elm_objid IS 'Hgbst_elm internal record number';