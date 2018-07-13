CREATE OR REPLACE FORCE VIEW sa.table_psfg_view (psfg_objid,bar_item_id,title) AS
select table_prtkp_cat.objid, table_prtkp_cat.prtkp_cat2keyphrase,
 table_gbkp_cat.title
 from table_prtkp_cat, table_gbkp_cat
 where table_gbkp_cat.objid = table_prtkp_cat.prtkp_cat2gbkp_cat
 AND table_prtkp_cat.prtkp_cat2keyphrase IS NOT NULL
 ;
COMMENT ON TABLE sa.table_psfg_view IS 'Joins keyphrases with a keyphrase category';
COMMENT ON COLUMN sa.table_psfg_view.psfg_objid IS 'Prtkp_cat internal record number';
COMMENT ON COLUMN sa.table_psfg_view.bar_item_id IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_psfg_view.title IS 'Title of the keyphrase category';