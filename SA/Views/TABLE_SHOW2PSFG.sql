CREATE OR REPLACE FORCE VIEW sa.table_show2psfg (shwgrp_objid,psfg_objid,title,bar_objid,relevancy) AS
select table_prtnum_cat.objid, table_prtkp_cat.objid,
 table_gbkp_cat.title, table_prtkp_cat.prtkp_cat2keyphrase,
 table_gbkp_cat.title
 from mtm_prtkp_cat4_prtnum_cat0, table_prtnum_cat, table_prtkp_cat, table_gbkp_cat
 where table_gbkp_cat.objid = table_prtkp_cat.prtkp_cat2gbkp_cat
 AND table_prtkp_cat.prtkp_cat2keyphrase IS NOT NULL
 AND table_prtkp_cat.objid = mtm_prtkp_cat4_prtnum_cat0.prtkp_cat2prtnum_cat
 AND mtm_prtkp_cat4_prtnum_cat0.prtnum_cat2prtkp_cat = table_prtnum_cat.objid 
 ;
COMMENT ON TABLE sa.table_show2psfg IS 'Keyphrase information used in Matching Solutions form';
COMMENT ON COLUMN sa.table_show2psfg.shwgrp_objid IS 'Prtnum_cat internal record number';
COMMENT ON COLUMN sa.table_show2psfg.psfg_objid IS 'Prtkp_cat internal record number';
COMMENT ON COLUMN sa.table_show2psfg.title IS 'Gbkp cat internal record number';
COMMENT ON COLUMN sa.table_show2psfg.bar_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_show2psfg.relevancy IS 'Title of the keyphrase category';