CREATE OR REPLACE FORCE VIEW sa.table_head_shwitm (shwitm_id,shwgpr_id,psfgrp_id) AS
select table_prtnum_kp.objid, table_prtnum_kp.prtnum_kp2prtnum_cat,
 table_prtnum_kp.prtnum_kp2prtkp_cat
 from table_prtnum_kp
 where table_prtnum_kp.prtnum_kp2prtnum_cat IS NOT NULL
 AND table_prtnum_kp.prtnum_kp2prtkp_cat IS NOT NULL
 ;
COMMENT ON TABLE sa.table_head_shwitm IS 'Internal information for keyphrase evaluation';
COMMENT ON COLUMN sa.table_head_shwitm.shwitm_id IS 'Prtnum kp internal record number';
COMMENT ON COLUMN sa.table_head_shwitm.shwgpr_id IS 'Prtnum_cat internal record number';
COMMENT ON COLUMN sa.table_head_shwitm.psfgrp_id IS 'Prtkp_cat internal record number';