CREATE OR REPLACE FORCE VIEW sa.table_shwipsfi2shwi (shwip_objid,shwic_objid,psfi_objid,title,s_title) AS
select table_psfi_show_p.objid, table_psfi_show_p.parent2prtnum_kp,
 table_keyphrase.objid, table_gb_kp.title, table_gb_kp.S_title
 from mtm_keyphrase4_prtnum_kp1, table_prtnum_kp table_psfi_show_p, table_keyphrase, table_gb_kp
 where table_gb_kp.objid = table_keyphrase.keyphrase2gb_kp
 AND table_keyphrase.objid = mtm_keyphrase4_prtnum_kp1.keyphrasechild2prtnum_kp
 AND mtm_keyphrase4_prtnum_kp1.prtnum_kp_chld2keyphrase = table_psfi_show_p.objid 
 AND table_psfi_show_p.parent2prtnum_kp IS NOT NULL
 ;
COMMENT ON TABLE sa.table_shwipsfi2shwi IS 'Used for display of part keyphrases';
COMMENT ON COLUMN sa.table_shwipsfi2shwi.shwip_objid IS 'Parent prtnum kp internal record number';
COMMENT ON COLUMN sa.table_shwipsfi2shwi.shwic_objid IS 'Child prtnum kp internal record number';
COMMENT ON COLUMN sa.table_shwipsfi2shwi.psfi_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_shwipsfi2shwi.title IS 'Title of the global keyphrase';