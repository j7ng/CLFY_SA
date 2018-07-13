CREATE OR REPLACE FORCE VIEW sa.table_prtcat2psfi (psfg_objid,psfi_objid,title,s_title,relevancy,s_relevancy) AS
select table_prtkp_subc.prtkp_subc2prtkp_cat, table_keyphrase.objid,
 table_gb_kp.title, table_gb_kp.S_title, table_gb_kp.title, table_gb_kp.S_title
 from table_prtkp_subc, table_keyphrase, table_gb_kp
 where table_prtkp_subc.prtkp_subc2prtkp_cat IS NOT NULL
 AND table_prtkp_subc.objid = table_keyphrase.keyphrase2prtkp_subc
 AND table_gb_kp.objid = table_keyphrase.keyphrase2gb_kp
 ;
COMMENT ON TABLE sa.table_prtcat2psfi IS 'Part keyphrases within the Category; used by forms Solution Paths (329), Keyphrase Selection (381), Path Description (8100), Keyphrase Selection (8102)';
COMMENT ON COLUMN sa.table_prtcat2psfi.psfg_objid IS 'Prtkp_cat internal record number';
COMMENT ON COLUMN sa.table_prtcat2psfi.psfi_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_prtcat2psfi.title IS 'Title of the global keyphrase';
COMMENT ON COLUMN sa.table_prtcat2psfi.relevancy IS 'Title of the global keyphrase';