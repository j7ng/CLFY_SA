CREATE OR REPLACE FORCE VIEW sa.table_down_show (dwn_shw_objid,psfi_objid,up_show_objid) AS
select table_down_show.objid, table_down_show.prtnum_kp_prnt2keyphrase,
 table_down_show.parent2prtnum_kp
 from table_prtnum_kp table_down_show
 where table_down_show.prtnum_kp_prnt2keyphrase IS NOT NULL
 AND table_down_show.parent2prtnum_kp IS NOT NULL
 ;
COMMENT ON TABLE sa.table_down_show IS 'Internal information for keyphrases';
COMMENT ON COLUMN sa.table_down_show.dwn_shw_objid IS 'Prtnum kp internal record number';
COMMENT ON COLUMN sa.table_down_show.psfi_objid IS 'Keyphrase internal record number';
COMMENT ON COLUMN sa.table_down_show.up_show_objid IS 'Prtnum kp internal record number';