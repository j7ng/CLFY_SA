CREATE OR REPLACE FORCE VIEW sa.table_psfl2psfi (psfl_objid,psfi_objid,title,s_title,"RANK",grank) AS
select table_prtkp_subc.objid, table_keyphrase.objid,
 table_gb_kp.title, table_gb_kp.S_title, table_gb_kp.rank,
 table_gbkp_cat.rank
 from table_prtkp_subc, table_keyphrase, table_gb_kp,
  table_gbkp_cat, table_prtkp_cat
 where table_gbkp_cat.objid = table_prtkp_cat.prtkp_cat2gbkp_cat
 AND table_prtkp_cat.objid = table_prtkp_subc.prtkp_subc2prtkp_cat
 AND table_prtkp_subc.objid = table_keyphrase.keyphrase2prtkp_subc
 AND table_gb_kp.objid = table_keyphrase.keyphrase2gb_kp
 ;
COMMENT ON TABLE sa.table_psfl2psfi IS 'Used by form Part Keyphrase Selection (648)';
COMMENT ON COLUMN sa.table_psfl2psfi.psfl_objid IS 'Prtkp_subc internal record number';
COMMENT ON COLUMN sa.table_psfl2psfi.psfi_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_psfl2psfi.title IS 'Title of the global keyphrase';
COMMENT ON COLUMN sa.table_psfl2psfi."RANK" IS 'Presentation rank of the keyphrase; used for user interface';
COMMENT ON COLUMN sa.table_psfl2psfi.grank IS 'Presentation rank of the category; used for user interface';