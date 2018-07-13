CREATE OR REPLACE FORCE VIEW sa.table_psfl2gsfi (psfl_objid,gsfl_objid,gsfi_objid,title,s_title,grank,irank) AS
select table_prtkp_subc.objid, table_gbkp_subc.objid,
 table_gb_kp.objid, table_gb_kp.title, table_gb_kp.S_title,
 table_gbkp_cat.rank, table_gb_kp.rank
 from table_prtkp_subc, table_gbkp_subc, table_gb_kp,
  table_gbkp_cat
 where table_gbkp_cat.objid = table_gbkp_subc.gbkp_subc2gbkp_cat
 AND table_gbkp_subc.objid = table_gb_kp.gb_kp2gbkp_subc
 AND table_gbkp_subc.objid = table_prtkp_subc.prtkp_subc2gbkp_subc
 ;
COMMENT ON TABLE sa.table_psfl2gsfi IS 'Used by form Part Number Keyphrase Selection (622)';
COMMENT ON COLUMN sa.table_psfl2gsfi.psfl_objid IS 'Prtkp_subc internal record number';
COMMENT ON COLUMN sa.table_psfl2gsfi.gsfl_objid IS 'Gbkp_subc internal record number';
COMMENT ON COLUMN sa.table_psfl2gsfi.gsfi_objid IS 'Gb kp internal record number';
COMMENT ON COLUMN sa.table_psfl2gsfi.title IS 'Title of the global keyphrase';
COMMENT ON COLUMN sa.table_psfl2gsfi.grank IS 'Presentation rank of the category; used for user interface';
COMMENT ON COLUMN sa.table_psfl2gsfi.irank IS 'Presentation rank of the keyphrase; used for user interface';