CREATE OR REPLACE FORCE VIEW sa.table_partnum_view (objid,part_no,s_part_no,description,s_description,mod_level,s_mod_level,"FAMILY",line,part_type,domain,s_domain,"ACTIVE",part_num_objid,mod_active,dom_serialno,dom_uniquesn,dom_catalogs,dom_boms,dom_at_site,dom_at_parts,dom_at_domain,dom_pt_used_bom,dom_pr_used_dom,model_num,s_model_num,sn_track,dom_pt_used_warn,std_warranty,incl_domain,notes,is_sppt_prog,unit_measure,dom_literature,dom_is_service,p_standalone,p_as_parent,p_as_child,turn_ratio,abc_code,config_type) AS
select table_mod_level.objid, table_part_num.part_number, table_part_num.S_part_number,
 table_part_num.description, table_part_num.S_description, table_mod_level.mod_level, table_mod_level.S_mod_level,
 table_part_num.family, table_part_num.line,
 table_part_num.part_type, table_part_num.domain, table_part_num.S_domain,
 table_part_num.active, table_part_num.objid,
 table_mod_level.active, table_part_num.dom_serialno,
 table_part_num.dom_uniquesn, table_part_num.dom_catalogs,
 table_part_num.dom_boms, table_part_num.dom_at_site,
 table_part_num.dom_at_parts, table_part_num.dom_at_domain,
 table_part_num.dom_pt_used_bom, table_part_num.dom_pt_used_dom,
 table_part_num.model_num, table_part_num.S_model_num, table_part_num.sn_track,
 table_part_num.dom_pt_used_warn, table_part_num.std_warranty,
 table_part_num.incl_domain, table_part_num.notes,
 table_part_num.is_sppt_prog, table_part_num.unit_measure,
 table_part_num.dom_literature, table_part_num.dom_is_service,
 table_part_num.p_standalone, table_part_num.p_as_parent,
 table_part_num.p_as_child, table_part_stats.turn_ratio,
 table_part_stats.abc_code, table_mod_level.config_type
 from table_mod_level, table_part_num, table_part_stats
 where table_part_num.objid = table_mod_level.part_info2part_num
 AND table_part_stats.objid (+) = table_mod_level.part_info2part_stats
 ;