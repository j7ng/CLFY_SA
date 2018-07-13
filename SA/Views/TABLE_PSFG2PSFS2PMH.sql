CREATE OR REPLACE FORCE VIEW sa.table_psfg2psfs2pmh (pmh_objid,psfg_objid,psfs_objid) AS
select table_prtkp_set.prtkp_set2part_class, table_prtkp_cat.objid,
 table_prtkp_set.objid
 from table_prtkp_set, table_prtkp_cat
 where table_prtkp_set.prtkp_set2part_class IS NOT NULL
 AND table_prtkp_set.objid = table_prtkp_cat.prtkp_cat2prtkp_set
 ;
COMMENT ON TABLE sa.table_psfg2psfs2pmh IS 'Joins keyphrases with a part class';
COMMENT ON COLUMN sa.table_psfg2psfs2pmh.pmh_objid IS 'Part class internal record number';
COMMENT ON COLUMN sa.table_psfg2psfs2pmh.psfg_objid IS 'Prtkp_cat internal record number';
COMMENT ON COLUMN sa.table_psfg2psfs2pmh.psfs_objid IS 'Prtkp_set internal record number';