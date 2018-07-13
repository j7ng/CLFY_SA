CREATE OR REPLACE FORCE VIEW sa.table_psfi_view (psfi_objid,title,s_title) AS
select table_keyphrase.objid, table_gb_kp.title, table_gb_kp.S_title
 from table_keyphrase, table_gb_kp
 where table_gb_kp.objid = table_keyphrase.keyphrase2gb_kp
 ;
COMMENT ON TABLE sa.table_psfi_view IS 'View of global keyphrases';
COMMENT ON COLUMN sa.table_psfi_view.psfi_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_psfi_view.title IS 'Title of the global keyphrase';