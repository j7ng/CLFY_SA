CREATE OR REPLACE FORCE VIEW sa.table_pml2shwg2psfg (pshw_objid,psfg_objid,pml_objid,title) AS
select table_prtnum_cat.objid, table_prtkp_cat.objid,
 table_prtnum_cat.prtnum_cat2part_info, table_gbkp_cat.title
 from mtm_prtkp_cat4_prtnum_cat0, table_prtnum_cat, table_prtkp_cat, table_gbkp_cat
 where table_gbkp_cat.objid = table_prtkp_cat.prtkp_cat2gbkp_cat
 AND table_prtkp_cat.objid = mtm_prtkp_cat4_prtnum_cat0.prtkp_cat2prtnum_cat
 AND mtm_prtkp_cat4_prtnum_cat0.prtnum_cat2prtkp_cat = table_prtnum_cat.objid 
 AND table_prtnum_cat.prtnum_cat2part_info IS NOT NULL
 ;
COMMENT ON TABLE sa.table_pml2shwg2psfg IS 'Selects part keyphrases for a given category for given part. Reserved; not used';
COMMENT ON COLUMN sa.table_pml2shwg2psfg.pshw_objid IS 'Partnum_cat internal record number';
COMMENT ON COLUMN sa.table_pml2shwg2psfg.psfg_objid IS 'Prktp cat internal record number';
COMMENT ON COLUMN sa.table_pml2shwg2psfg.pml_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_pml2shwg2psfg.title IS 'Title of the keyphrase category';