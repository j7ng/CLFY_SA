CREATE OR REPLACE FORCE VIEW sa.table_showip2psfi (shwi_objid,psfi_objid,title,s_title) AS
select table_prtnum_kp.objid, table_keyphrase.objid,
 table_gb_kp.title, table_gb_kp.S_title
 from table_prtnum_kp, table_keyphrase, table_gb_kp
 where table_gb_kp.objid = table_keyphrase.keyphrase2gb_kp
 AND table_keyphrase.objid = table_prtnum_kp.prtnum_kp_prnt2keyphrase
 ;
COMMENT ON TABLE sa.table_showip2psfi IS 'Joins global keyphrases to a part number';
COMMENT ON COLUMN sa.table_showip2psfi.shwi_objid IS 'Prtnum kp internal record number';
COMMENT ON COLUMN sa.table_showip2psfi.psfi_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_showip2psfi.title IS 'Title of the global keyphrase';