CREATE OR REPLACE FORCE VIEW sa.table_prtnum2mod2shwgrp (shwgrp_objid,mod_objid,partnum_objid,part_number,s_part_number,mod_level,s_mod_level) AS
select table_prtnum_cat.objid, table_mod_level.objid,
 table_part_num.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_mod_level.mod_level, table_mod_level.S_mod_level
 from table_prtnum_cat, table_mod_level, table_part_num
 where table_mod_level.objid = table_prtnum_cat.prtnum_cat2part_info
 AND table_part_num.objid = table_mod_level.part_info2part_num
 ;