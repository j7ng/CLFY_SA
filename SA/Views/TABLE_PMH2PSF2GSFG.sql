CREATE OR REPLACE FORCE VIEW sa.table_pmh2psf2gsfg (pmh_objid,psfs_objid,gsfs_objid,gsfg_objid,title,grank) AS
select table_prtkp_set.prtkp_set2part_class, table_prtkp_set.objid,
 table_gbkp_set.objid, table_gbkp_cat.objid,
 table_gbkp_cat.title, table_gbkp_cat.rank
 from table_prtkp_set, table_gbkp_set, table_gbkp_cat
 where table_gbkp_set.objid = table_gbkp_cat.gbkp_cat2gbkp_set
 AND table_prtkp_set.prtkp_set2part_class IS NOT NULL
 AND table_gbkp_set.objid = table_prtkp_set.prtkp_set2gbkp_set
 ;
COMMENT ON TABLE sa.table_pmh2psf2gsfg IS 'Joins keyphrases to their part class';
COMMENT ON COLUMN sa.table_pmh2psf2gsfg.pmh_objid IS 'Part class internal record number';
COMMENT ON COLUMN sa.table_pmh2psf2gsfg.psfs_objid IS 'Prtkp_set internal record number';
COMMENT ON COLUMN sa.table_pmh2psf2gsfg.gsfs_objid IS 'Gbkp set internal record number';
COMMENT ON COLUMN sa.table_pmh2psf2gsfg.gsfg_objid IS 'Gbkp set internal record number';
COMMENT ON COLUMN sa.table_pmh2psf2gsfg.title IS 'Title of the keyphrase category';
COMMENT ON COLUMN sa.table_pmh2psf2gsfg.grank IS 'Presentation rank of the category; used for user interface';