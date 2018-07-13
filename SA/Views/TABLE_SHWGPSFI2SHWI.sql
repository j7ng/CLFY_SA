CREATE OR REPLACE FORCE VIEW sa.table_shwgpsfi2shwi (shwi_objid,shwg_objid,psfg_objid) AS
select table_prtnum_kp.objid, table_prtnum_kp.prtnum_kp2prtnum_cat,
 table_prtnum_kp.prtnum_kp2prtkp_cat
 from table_prtnum_kp
 where table_prtnum_kp.prtnum_kp2prtnum_cat IS NOT NULL
 AND table_prtnum_kp.prtnum_kp2prtkp_cat IS NOT NULL
 ;
COMMENT ON TABLE sa.table_shwgpsfi2shwi IS 'Categories for a given part';
COMMENT ON COLUMN sa.table_shwgpsfi2shwi.shwi_objid IS 'Prtnum kp internal record number';
COMMENT ON COLUMN sa.table_shwgpsfi2shwi.shwg_objid IS 'Prtnum_cat internal record number';
COMMENT ON COLUMN sa.table_shwgpsfi2shwi.psfg_objid IS 'Prtkp_cat internal record number';