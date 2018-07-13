CREATE OR REPLACE FORCE VIEW sa.table_show2psfi (show_objid,psfi_objid,title,s_title,relevancy,s_relevancy) AS
select table_prtnum_kp.objid, table_keyphrase.objid,
 table_gb_kp.title, table_gb_kp.S_title, table_gb_kp.title, table_gb_kp.S_title
 from mtm_keyphrase4_prtnum_kp1, table_prtnum_kp, table_keyphrase, table_gb_kp
 where table_gb_kp.objid = table_keyphrase.keyphrase2gb_kp
 AND table_keyphrase.objid = mtm_keyphrase4_prtnum_kp1.keyphrasechild2prtnum_kp
 AND mtm_keyphrase4_prtnum_kp1.prtnum_kp_chld2keyphrase = table_prtnum_kp.objid 
 ;
COMMENT ON TABLE sa.table_show2psfi IS 'Used by forms Part Number Keyphrase Selection (622), Part Keyphrase Selection (648)';
COMMENT ON COLUMN sa.table_show2psfi.show_objid IS 'Prtnum kp internal record number';
COMMENT ON COLUMN sa.table_show2psfi.psfi_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_show2psfi.title IS 'Title of the global keyphrase';
COMMENT ON COLUMN sa.table_show2psfi.relevancy IS 'Title of the global keyphrase';