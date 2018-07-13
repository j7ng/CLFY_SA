CREATE OR REPLACE FORCE VIEW sa.table_gsfg2psf2pfsg (psfs_objid,gsfg_objid,psfg_objid) AS
select table_prtkp_cat.prtkp_cat2prtkp_set, table_prtkp_cat.prtkp_cat2gbkp_cat,
 table_prtkp_cat.objid
 from table_prtkp_cat
 where table_prtkp_cat.prtkp_cat2prtkp_set IS NOT NULL
 AND table_prtkp_cat.prtkp_cat2gbkp_cat IS NOT NULL
 ;
COMMENT ON TABLE sa.table_gsfg2psf2pfsg IS 'Internal information for keyphrase evaluation';
COMMENT ON COLUMN sa.table_gsfg2psf2pfsg.psfs_objid IS 'Prtkp_set internal record number';
COMMENT ON COLUMN sa.table_gsfg2psf2pfsg.gsfg_objid IS 'Gbkp cat internal record number';
COMMENT ON COLUMN sa.table_gsfg2psf2pfsg.psfg_objid IS 'Prtkp_cat internal record number';