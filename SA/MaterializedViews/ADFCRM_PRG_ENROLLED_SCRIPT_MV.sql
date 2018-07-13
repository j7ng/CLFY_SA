CREATE MATERIALIZED VIEW sa.adfcrm_prg_enrolled_script_mv (prg_objid,x_prg_script_id,x_prg_script_text,x_prg_desc_script_id,x_prg_desc_script_text,x_language)
ORGANIZATION HEAP 
AS select
  pp.objid prg_objid,
  pp.x_prg_script_id,
  sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => substr(pp.x_prg_script_id,1,instr(pp.x_prg_script_id,'_')-1),
                                                                       ip_script_id => substr(pp.x_prg_script_id,instr(pp.x_prg_script_id,'_')+1),
                                                                       ip_language => 'EN',
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => bo.org_id)  x_prg_script_text,
  pp.x_prg_desc_script_id,
  sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => substr(pp.x_prg_desc_script_id,1,instr(pp.x_prg_desc_script_id,'_')-1),
                                                                       ip_script_id => substr(pp.x_prg_desc_script_id,instr(pp.x_prg_desc_script_id,'_')+1),
                                                                       ip_language => 'EN',
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => bo.org_id) x_prg_desc_script_text,
                                                                       'EN' AS X_LANGUAGE
from sa.x_program_parameters pp,
     sa.table_bus_org bo
where bo.objid = pp.prog_param2bus_org
UNION
select
  pp.objid prg_objid,
  pp.x_prg_script_id,
  sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => substr(pp.x_prg_script_id,1,instr(pp.x_prg_script_id,'_')-1),
                                                                       ip_script_id => substr(pp.x_prg_script_id,instr(pp.x_prg_script_id,'_')+1),
                                                                       ip_language => 'ES',
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => bo.org_id)  x_prg_script_text,
  pp.x_prg_desc_script_id,
  sa.adfcrm_scripts.get_generic_brand_script(ip_script_type => substr(pp.x_prg_desc_script_id,1,instr(pp.x_prg_desc_script_id,'_')-1),
                                                                       ip_script_id => substr(pp.x_prg_desc_script_id,instr(pp.x_prg_desc_script_id,'_')+1),
                                                                       ip_language => 'ES',
                                                                       ip_sourcesystem  => 'TAS',
                                                                       ip_brand_name => bo.org_id) x_prg_desc_script_text,
                                                                       'ES' AS X_LANGUAGE
from sa.x_program_parameters pp,
     sa.table_bus_org bo
where bo.objid = pp.prog_param2bus_org;
COMMENT ON MATERIALIZED VIEW sa.adfcrm_prg_enrolled_script_mv IS 'snapshot table for x_program_parameters script texts';