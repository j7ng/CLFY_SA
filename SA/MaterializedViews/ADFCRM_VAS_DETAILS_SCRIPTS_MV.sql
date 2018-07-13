CREATE MATERIALIZED VIEW sa.adfcrm_vas_details_scripts_mv (vas_service_id,vas_script_type,vas_script_id,vas_script_text,x_language)
ORGANIZATION HEAP 
AS select vas.vas_service_id,
       substr(vass.vas_script_id,1,instr(vass.vas_script_id,'_')-1) vas_script_type,
       substr(vass.vas_script_id,instr(vass.vas_script_id,'_')+1) vas_script_id,
       case
       when vass.vas_script_id is null then vas.vas_description_english
       else
            sa.adfcrm_scripts.get_generic_brand_script(
              ip_script_type => substr(vass.vas_script_id,1,instr(vass.vas_script_id,'_')-1),
              IP_SCRIPT_ID =>  substr(vass.vas_script_id,instr(vass.vas_script_id,'_')+1),
              IP_LANGUAGE => 'ENGLISH',
              IP_SOURCESYSTEM => 'TAS',
              ip_brand_name => vas.vas_bus_org)
       end vas_script_text,
    'EN' x_language
from vas_programs_view vas,
     (select vv.vas_programs_objid vas_service_id, vp.vas_param_name, vv.vas_param_value  vas_script_id
      from  x_vas_values vv , x_vas_params vp
      where vv.vas_params_objid    = vp.objid
      and   vp.vas_param_name      ='TAS_SCRIPT_ID') vass
where vas.vas_service_id = vass.vas_service_id (+)
UNION
select vas.vas_service_id,
       substr(vass.vas_script_id,1,instr(vass.vas_script_id,'_')-1) vas_script_type,
       substr(vass.vas_script_id,instr(vass.vas_script_id,'_')+1) vas_script_id,
       case
       when vass.vas_script_id is null then vas.vas_description_spanish
       else
            sa.adfcrm_scripts.get_generic_brand_script(
              ip_script_type => substr(vass.vas_script_id,1,instr(vass.vas_script_id,'_')-1),
              IP_SCRIPT_ID =>  substr(vass.vas_script_id,instr(vass.vas_script_id,'_')+1),
              IP_LANGUAGE => 'SPANISH',
              IP_SOURCESYSTEM => 'TAS',
              ip_brand_name => vas.vas_bus_org)
       end vas_script_text,
    'ES' x_language
from vas_programs_view vas,
     (select vv.vas_programs_objid vas_service_id, vp.vas_param_name, vv.vas_param_value  vas_script_id
      from  x_vas_values vv , x_vas_params vp
      where vv.vas_params_objid    = vp.objid
      and   vp.vas_param_name      ='TAS_SCRIPT_ID') vass
where vas.vas_service_id = vass.vas_service_id (+);
COMMENT ON MATERIALIZED VIEW sa.adfcrm_vas_details_scripts_mv IS 'snapshot table for vas service script texts';