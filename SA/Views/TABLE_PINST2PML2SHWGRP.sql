CREATE OR REPLACE FORCE VIEW sa.table_pinst2pml2shwgrp (shwgrp_objid,pml_objid,prdinst_objid) AS
select table_prtnum_cat.objid, table_mod_level.objid,
 table_site_part.objid
 from table_prtnum_cat, table_mod_level, table_site_part
 where table_mod_level.objid = table_site_part.site_part2part_info
 AND table_mod_level.objid = table_prtnum_cat.prtnum_cat2part_info
 ;
COMMENT ON TABLE sa.table_pinst2pml2shwgrp IS 'Joins catalog part information with an installed part. Reserved; not used';
COMMENT ON COLUMN sa.table_pinst2pml2shwgrp.shwgrp_objid IS 'Partnum_cat internal record number';
COMMENT ON COLUMN sa.table_pinst2pml2shwgrp.pml_objid IS 'Part revision internal record number';
COMMENT ON COLUMN sa.table_pinst2pml2shwgrp.prdinst_objid IS 'Part internal record number';